use NativeCall;
use Git::Error;

class Git::Tree is repr('CPointer')
{
    method free() is native('git2') is symbol('git_tree_free') {}
}
