use NativeCall;

class Git::Strarray is repr('CStruct')
{
    has CArray[Pointer] $.strings;
    size_t $.count;

    method free() is native('git2') is symbol('git_strarray_free') {}
}
