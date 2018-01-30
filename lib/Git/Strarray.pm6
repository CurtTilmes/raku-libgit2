use NativeCall;

class Git::Strarray is repr('CStruct')
{
    has CArray[Str] $.strings;
    has size_t $.count;

    method free() is native('git2') is symbol('git_strarray_free') {}

    method list
    {
        LEAVE self.free;
        do for 0..^$!count { ~$!strings[$_] }
    }
}
