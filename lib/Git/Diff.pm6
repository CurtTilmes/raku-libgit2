use NativeCall;

class Git::Diff is repr('CPointer')
{
    sub git_diff_free(Git::Diff)
        is native('git2') {}

    submethod DESTROY { git_diff_free(self) }
}
