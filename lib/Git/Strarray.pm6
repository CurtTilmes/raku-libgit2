use NativeCall;

class Git::Strarray is repr('CStruct') does Positional
{
    has CArray[Str] $.strings handles <AT-POS>;
    has size_t $.elems;

    method free
        is native('git2') is symbol('git_strarray_free') {}

    multi method new(*@list where *.elems > 0) { Git::Strarray.new(:@list) }

    multi method BUILD(:@list)
    {
        if @list
        {
            $!elems = @list.elems;
            $!strings := CArray[Str].new(@list);
        }
    }

    method list(:$free)
    {
        LEAVE self.free if $free;
        $!strings[^$!elems]
    }
}
