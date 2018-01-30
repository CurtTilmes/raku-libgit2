use NativeCall;

class Git::Remote::Callbacks is repr('CStruct')
{
    has int32 $.version;

    submethod BUILD
    {
        $!version = 1;
    }
}

class Git::Fetch::Options is repr('CStruct')
{
    has int32 $.version;

    submethod BUILD
    {
        $!version = 1;
    }
}

class Git::Remote is repr('CPointer')
{
    sub git_remote_free(Git::Remote)
        is native('git2') {}

    submethod DESTROY { git_remote_free(self) }

    method url(--> Str)
        is native('git2') is symbol('git_remote_url') {}

    method name(--> Str)
        is native('git2') is symbol('git_remote_name') {}

#    method owner(--> Git::Repository)
#        is native('git2') is symbol('git_remote_owner') {}
}


