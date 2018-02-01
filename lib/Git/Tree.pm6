use NativeCall;
use Git::Error;

class Git::Tree is repr('CPointer')
{
    sub git_tree_free(Git::Tree)
        is native('git2') {}

    submethod DESTROY { git_tree_free(self) }
}
