use NativeCall;

class Git::Buffer is repr('CStruct')
{
    has Pointer $.ptr;
    has size_t $.asize;
    has size_t $.size;

    method buf
    {
        buf8.new(nativecast(CArray[uint8], $!ptr)[0..^$!size])
    }

    method str
    {
        self.buf.decode
    }

    method free() is native('git2') is symbol('git_buf_free') {}
}
