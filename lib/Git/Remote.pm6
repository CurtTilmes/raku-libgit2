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
