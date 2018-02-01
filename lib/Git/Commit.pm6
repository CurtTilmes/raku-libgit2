use NativeCall;
use Git::Signature;

class Git::Commit is repr('CPointer')
{
    sub git_commit_free(Git::Commit)
        is native('git2') {}

    method author(--> Git::Signature)
        is native('git2') is symbol('git_commit_author') {}

    submethod DESTROY { git_commit_free(self) }
}
