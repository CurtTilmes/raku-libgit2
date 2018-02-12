use NativeCall;
use Git::Error;
use Git::Buffer;
use Git::Proxy;
use Git::Strarray;
use Git::Oid;

# git_direction
enum Git::Direction
<
    GIT_DIRECTION_FETCH
    GIT_DIRECTION_PUSH
>;

# git_remote_callbacks
class Git::Remote::Callbacks is repr('CStruct')
{
    has int32 $.version = 1;
    has Pointer $.side-band-progress;
    has Pointer $.completion;
    has Pointer $.credentials;
    has Pointer $.certificate_check;
    has Pointer $.transfer-progress;
    has Pointer $.update-tips;
    has Pointer $.pack-progress;
    has Pointer $.push-transfer-progress;
    has Pointer $.push-update-reference;
    has Pointer $.push-negotiation;
    has Pointer $.transport;
    has Pointer $.payload;
}

enum Git::Fetch::Prune <
    GIT_FETCH_PRUNE_UNSPECIFIED
    GIT_FETCH_PRUNE
    GIT_FETCH_NO_PRUNE
>;

enum Git::Remote::Autotag::Option <
    GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED
    GIT_REMOTE_DOWNLOAD_TAGS_AUTO
    GIT_REMOTE_DOWNLOAD_TAGS_NONE
    GIT_REMOTE_DOWNLOAD_TAGS_ALL
>;

class Git::Fetch::Options is repr('CStruct')
{
    has int32 $.version = 1;
    HAS Git::Remote::Callbacks $.callbacks;
    has int32 $.prune;
    has int32 $.update-fetchhead;
    has int32 $.download-tags;
    HAS Git::Proxy::Options $.proxy-opts;
    HAS Git::Strarray $.custom-headers;

    sub git_fetch_init_options(Git::Fetch::Options, int32 --> int32)
        is native('git2') {}

    submethod BUILD(Bool :$prune,
                    Str  :$tags where 'unspecified'|'auto'|'none'|'all'
                         = 'unspecified',
                    int32 :$!update-fetchhead)
    {
        check(git_fetch_init_options(self, 1));

        with $prune { $!prune = $_ ?? GIT_FETCH_PRUNE !! GIT_FETCH_NO_PRUNE }

        with $tags
        {
            $!download-tags = do given $tags
            {
                when 'auto' { GIT_REMOTE_DOWNLOAD_TAGS_AUTO }
                when 'none' { GIT_REMOTE_DOWNLOAD_TAGS_NONE }
                when 'all'  { GIT_REMOTE_DOWNLOAD_TAGS_ALL  }
            }
        }
    }
}

# git_remote_head
class Git::Remote::Head is repr('CStruct')
{
    has int32 $.local;
    HAS Git::Oid $.oid;
    HAS Git::Oid $.loid;
    has Str $.name;
    has Str $.symref-target;
}

class Git::Remote is repr('CPointer')
{
    sub git_remote_free(Git::Remote)
        is native('git2') {}

    submethod DESTROY { git_remote_free(self) }

    sub git_remote_create_detached(Pointer is rw, Str --> int32)
        is native('git2') {}

    multi method new(Str:D $url)
    {
        my Pointer $ptr .= new;
        check(git_remote_create_detached($ptr, $url));
        nativecast(Git::Remote, $ptr)
    }

    method url(--> Str)
        is native('git2') is symbol('git_remote_url') {}

    method name(--> Str)
        is native('git2') is symbol('git_remote_name') {}

    sub git_remote_owner(Git::Remote --> Pointer)
        is native('git2') {}

    method owner
    {
        nativecast(::('Git::Repository'), git_remote_owner(self))
    }

    sub git_remote_autotag(Git::Remote --> int32)
        is native('git2') {}

    method autotag
    {
        Git::Remote::Autotag::Option(git_remote_autotag(self))
    }

    sub git_remote_connected(Git::Remote --> int32)
        is native('git2') {}

    method connected { git_remote_connected(self) == 1 }

    sub git_remote_default_branch(Git::Buffer, Git::Remote --> int32)
        is native('git2') {}

    method default-branch
    {
        my Git::Buffer $buf .= new;
        check(git_remote_default_branch($buf, self));
        $buf.str
    }

    sub git_remote_connect(Git::Remote, int32, Git::Remote::Callbacks,
                           Git::Proxy::Options, Git::Strarray --> int32)
        is native('git2') {}

    method connect(Str :$dir where 'fetch'|'push', |opts)
    {
        my int32 $direction = $dir eq 'fetch' ?? GIT_DIRECTION_FETCH
                                              !! GIT_DIRECTION_PUSH;

        my Git::Remote::Callbacks $callbacks .= new(|opts);

        my Git::Proxy::Options $proxy-opts .= new(|opts);

        my Git::Strarray $custom-headers .= new;

        check(git_remote_connect(self, $direction, $callbacks, $proxy-opts,
                                 $custom-headers));
        self
    }

    method disconnect()
        is native('git2') is symbol('git_remote_disconnect') {}

    sub git_remote_ls(Pointer is rw, size_t is rw, Git::Remote
                      --> int32)
        is native('git2') {}


    method ls()
    {
        my Pointer $ptr .= new;
        my size_t $size .= new;
        check(git_remote_ls($ptr, $size, self));
        nativecast(CArray[Git::Remote::Head], $ptr)[^$size];
    }

    sub git_remote_download(Git::Remote, Git::Strarray, Git::Fetch::Options
                            --> int32)
        is native('git2') {}

    method download(|opts)
    {
        my Git::Strarray $refspecs;
        my Git::Fetch::Options $opts .= new(|opts);
        check(git_remote_download(self, $refspecs, $opts))
    }
}


