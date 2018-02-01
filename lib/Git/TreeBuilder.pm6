use NativeCall;
use Git::Error;

class Git::TreeBuilder is repr('CPointer')
{
    sub git_treebuilder_free(Git::TreeBuilder)
        is native('git2') {}

    submethod DESTROY { git_treebuilder_free(self) }
}
