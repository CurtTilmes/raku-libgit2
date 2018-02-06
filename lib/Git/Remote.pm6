use NativeCall;
use Git::Error;
use Git::Buffer;
use Git::Proxy;
use Git::Strarray;

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
                    Str  :$tags where Str|'auto'|'none'|'all' )
    {
        check(git_fetch_init_options(self, 1));

        with $prune { $!prune = $_ ?? GIT_FETCH_PRUNE !! GIT_FETCH_NO_PRUNE }

        with $tags
        {
            say "tags";
            $!download-tags = do given $tags
            {
                when 'auto' { GIT_REMOTE_DOWNLOAD_TAGS_AUTO }
                when 'none' { GIT_REMOTE_DOWNLOAD_TAGS_NONE }
                when 'all'  { GIT_REMOTE_DOWNLOAD_TAGS_ALL  }
            }
        }
    }

    method prune { Git::Fetch::Prune($!prune) }

    method download-tags { Git::Remote::Autotag::Option($!download-tags) }
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

    method disconnect()
        is native('git2') is symbol('git_remote_disconnect') {}
}


