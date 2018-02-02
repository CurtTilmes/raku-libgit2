use NativeCall;
use Git::Error;
use Git::Object;
use Git::Oid;

enum Git::FileMode (
    GIT_FILEMODE_UNREADABLE          => 0o000000,
    GIT_FILEMODE_TREE                => 0o040000,
    GIT_FILEMODE_BLOB                => 0o100644,
    GIT_FILEMODE_BLOB_EXECUTABLE     => 0o100755,
    GIT_FILEMODE_LINK                => 0o120000,
    GIT_FILEMODE_COMMIT              => 0o160000,
);

class Git::Tree::Entry is repr('CPointer')
{
    sub git_tree_entry_type(Git::Tree::Entry --> int32)
        is native('git2') {}

    method type() { Git::Type(git_tree_entry_type(self)) }

    method name(--> Str)
        is native('git2') is symbol('git_tree_entry_name') {}

    sub git_tree_entry_filemode(Git::Tree::Entry --> int32)
        is native('git2') {}

    sub git_tree_entry_filemode_raw(Git::Tree::Entry --> int32)
        is native('git2') {}

    multi method filemode()
    {
        Git::FileMode(git_tree_entry_filemode(self))
    }

    multi method filemode(Bool :$raw!)
    {
        git_tree_entry_filemode_raw(self)
    }

    method free()
        is native('git2') is symbol('git_tree_entry_free') {}

    method gist
    {
        "Git::Entry($.type():$.name())"
    }
}

class Git::Tree is repr('CPointer') does Git::Objectish
{
    method entrycount(--> size_t)
        is native('git2') is symbol('git_tree_entrycount') {}

    method entry-byindex(size_t $idx --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byindex') {}

    method entry-byid(Git::Oid $oid --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byid') {}

    method entry-byname(Str $name --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byname') {}

    sub git_tree_entry_bypath(Pointer is rw, Git::Tree, Str --> int32)
        is native('git2') {}

    method entry-bypath(Str:D $path)
    {
        my Pointer $ptr .= new;
        check(git_tree_entry_bypath($ptr, self, $path));
        nativecast(Git::Tree::Entry, $ptr)
    }

    submethod DESTROY { self.free }
}
