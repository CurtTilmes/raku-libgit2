use NativeCall;
use Git::Error;
use Git::Oid;

class Git::TreeBuilder is repr('CPointer')
{
    sub git_treebuilder_free(Git::TreeBuilder)
        is native('git2') {}

    sub git_treebuilder_write(Git::Oid, Git::TreeBuilder --> int32)
        is native('git2') {}

    method entrycount(--> uint32)
        is native('git2') is symbol('git_treebuilder_entrycount') {}

    method clear()
        is native('git2') is symbol('git_treebuilder_clear') {}

    method write(--> Git::Oid)
    {
        my Git::Oid $oid .= new;
        check(git_treebuilder_write($oid, self));
        $oid
    }

    submethod DESTROY { git_treebuilder_free(self) }
}
