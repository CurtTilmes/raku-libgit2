use NativeCall;

class Git::Strarray is repr('CStruct')
{
    has CArray[Str] $.strings;
    has size_t $.count;

    sub git_strarray_free(Git::Strarray)
        is native('git2') {}

    submethod DESTROY { git_strarray_free(self) }

    method list { $!strings[^$!count] }
}
