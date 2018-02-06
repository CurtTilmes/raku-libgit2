use NativeCall;
use Git::Error;
use Git::Buffer;

enum Git::Remote::Autotag::Option <
    GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED
    GIT_REMOTE_DOWNLOAD_TAGS_AUTO
    GIT_REMOTE_DOWNLOAD_TAGS_NONE
    GIT_REMOTE_DOWNLOAD_TAGS_ALL
>;

class Git::Remote::Callbacks is repr('CStruct')
{
    has int32 $.version = 1;
}

class Git::Fetch::Options is repr('CStruct')
{
    has int32 $.version = 1;
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
}


