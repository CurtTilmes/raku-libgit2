use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Tree;

enum Git::Index::Capabilities (
    GIT_INDEXCAP_IGNORE_CASE => 1,
    GIT_INDEXCAP_NO_FILEMODE => 2,
    GIT_INDEXCAP_NO_SYMLINKS => 4,
    GIT_INDEXCAP_FROM_OWNER  => -1,
);

class Git::Index::Time is repr('CStruct')
{
    has int32 $.seconds;
    has uint32 $.nanoseconds;
}

class Git::Index::Entry is repr('CStruct')
{
    HAS Git::Index::Time $.ctime;
    HAS Git::Index::Time $.mtime;
    has uint32 $.dev;
    has uint32 $.ino;
    has uint32 $.mode;
    has uint32 $.uid;
    has uint32 $.gid;
    has uint32 $.file-size;
    HAS Git::Oid $.id;
    has uint16 $.flags;
    has uint16 $.flags-extended;
    has Str $.path;
}

class Git::Index is repr('CPointer')
{
    sub git_index_free(Git::Index)
        is native('git2') {}

    sub git_index_new(Pointer is rw --> int32)
        is native('git2') {}

    sub git_index_open(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_index_read(Git::Index, int32 --> int32)
        is native('git2') {}

    sub git_index_write(Git::Index --> int32)
        is native('git2') {}

    sub git_index_set_version(Git::Index, uint32 --> int32)
        is native('git2') {}

    method version(--> uint32)
        is native('git2') is symbol('git_index_version') {}

    method set-version(uint32 $version)
    {
        check(git_index_set_version(self, $version))
    }

    method checksum(--> Git::Oid)
        is native('git2') is symbol('git_index_checksum') {}

    method new(--> Git::Index)
    {
        my Pointer $ptr .= new;
        check(git_index_new($ptr));
        nativecast(Git::Index, $ptr)
    }

    method open(Str $path)
    {
        my Pointer $ptr .= new;
        check(git_index_open($ptr, $path));
        nativecast(Git::Index, $ptr)
    }

    method read(Bool :$force = False)
    {
        check(git_index_read(self, $force ?? 1 !! 0))
    }

    method write
    {
        check(git_index_write(self))
    }

    method capabilities(--> int32)
        is native('git2') is symbol('git_index_caps') {}

    sub git_index_clear(Git::Index --> int32)
        is native('git2') {}

    method clear { check(git_index_clear(self)) }

    sub git_index_read_tree(Git::Index, Git::Tree --> int32)
        is native('git2') {}

    method read-tree(Git::Tree:D $tree)
    {
        check(git_index_read_tree(self, $tree))
    }

    sub git_index_write_tree(Git::Oid, Git::Index --> int32)
        is native('git2') {}

    sub git_index_write_tree_to(Git::Oid, Git::Index, Pointer --> int32)
        is native('git2') {}

    method write-tree($repo? --> Git::Oid)
    {
        my Git::Oid $oid .= new;
        if $repo
        {
            check(git_index_write_tree_to($oid, self,
                                          nativecast(Pointer, $repo)));
        }
        else
        {
            check(git_index_write_tree($oid, self));
        }
        $oid
    }

    method entrycount(--> size_t)
        is native('git2') is symbol('git_index_entrycount') {}

    method get-byindex(size_t $index --> Git::Index::Entry)
        is native('git2') is symbol('git_index_get_byindex') {}

    method get-bypath(Str $path, int32 $stage --> Git::Index::Entry)
        is native('git2') is symbol('git_index_get_bypath') {}

    submethod DESTROY { git_index_free(self) }
}
