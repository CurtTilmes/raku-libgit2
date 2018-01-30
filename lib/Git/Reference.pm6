use NativeCall;

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

    method is-branch(--> Bool) { git_reference_is_branch(self) == 1 }
    method is-tag(--> Bool)    { git_reference_is_tag(self)    == 1 }
    method is-note(--> Bool)   { git_reference_is_note(self)   == 1 }
    method is-remote(--> Bool) { git_reference_is_remote(self) == 1 }

    submethod DESTROY { git_reference_free(self) }
}
