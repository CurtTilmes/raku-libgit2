use NativeCall;

class Git::Commit is repr('CPointer')
{
    sub git_commit_free(Git::Commit)
        is native('git2') {}

    submethod DESTROY { git_commit_free(self) }
}
