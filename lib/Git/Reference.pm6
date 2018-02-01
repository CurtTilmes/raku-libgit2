use NativeCall;
use Git::Error;

class Git::Reference is repr('CPointer')
{
    sub git_reference_free(Git::Reference)
        is native('git2') {}

    sub git_reference_is_branch(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_tag(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_note(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_remote(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_is_checked_out(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_is_head(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_delete(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_name(Pointer is rw, Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_set_upstream(Git::Reference, Str --> int32)
        is native('git2') {}

    sub git_branch_upstream(Pointer is rw, Git::Reference --> int32)
        is native('git2') {}

    method is-branch(--> Bool)
    {
        git_reference_is_branch(self) == 1
    }

    method is-tag(--> Bool)
    {
        git_reference_is_tag(self) == 1
    }

    method is-note(--> Bool)
    {
        git_reference_is_note(self) == 1
    }

    method is-remote(--> Bool)
    {
        git_reference_is_remote(self) == 1
    }

    method is-checked-out(--> Bool)
    {
        git_branch_is_checked_out(self) == 1
    }

    method is-head(--> Bool)
    {
        git_branch_is_head(self) == 1
    }

    method branch-delete()
    {
        check(git_branch_delete(self))
    }

    method branch-name()
    {
        my Pointer $ptr .= new;
        check(git_branch_name($ptr, self));
        nativecast(Str, $ptr)
    }

    method branch-set-upstream(Str $upstream-name = Str)
    {
        check(git_branch_set_upstream(self, $upstream-name))
    }

    method branch-upstream()
    {
        my Pointer $ptr .= new;
        my $ret = git_branch_upstream($ptr, self);
        return if $ret == GIT_ENOTFOUND;
        check($ret);
        nativecast(Git::Reference, $ptr)
    }

    submethod DESTROY { git_reference_free(self) }
}
