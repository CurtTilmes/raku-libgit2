use NativeCall;
use Git::Error;
use Git::Oid;

subset Git::Glob of Str where /<[*?\[]>/;
subset Git::Range of Str where /'..'/;

enum Git::Sort
(
    GIT_SORT_NONE        => 0,
    GIT_SORT_TOPOLOGICAL => 1 << 0,
    GIT_SORT_TIME        => 1 << 1,
    GIT_SORT_REVERSE     => 1 << 2,
);

class Git::Revwalk is repr('CPointer')
{
    sub git_revwalk_free(Git::Revwalk)
        is native('git2') {}

    sub git_revwalk_hide(Git::Revwalk, Git::Oid --> int32)
        is native('git2') {}

    sub git_revwalk_hide_glob(Git::Revwalk, Str --> int32)
        is native('git2') {}

    sub git_revwalk_hide_ref(Git::Revwalk, Str --> int32)
        is native('git2') {}

    method hide(*@args)
    {
        for @args
        {
            when Git::Oid     { check(git_revwalk_hide(self, $_))      }
            when Git::Oidlike { check(git_revwalk_hide(self, Git::Oid.new($_))) }
            when Git::Glob    { check(git_revwalk_hide_glob(self, $_)) }
            default           { check(git_revwalk_hide_ref(self, $_))  }
        }
    }

    sub git_revwalk_push(Git::Revwalk, Git::Oid --> int32)
        is native('git2') {}

    sub git_revwalk_push_ref(Git::Revwalk, Str --> int32)
        is native('git2') {}

    sub git_revwalk_push_glob(Git::Revwalk, Str --> int32)
        is native('git2') {}

    sub git_revwalk_push_range(Git::Revwalk, Str --> int32)
        is native('git2') {}

    method push(*@args)
    {
        for @args
        {
            when Git::Oid     { check(git_revwalk_push(self, $_)) }
            when Git::Oidlike { check(git_revwalk_push(self, Git::Oid.new($_))) }
            when Git::Glob    { check(git_revwalk_push_glob($_)) }
            when Git::Range   { check(git_revwalk_push_range(self, $_)) }
            default           { check(git_revwalk_push_ref($_)) }
        }
    }

    method simplify-first-parent()
        is native('git2') is symbol('git-revwalk_simplify_first_parent') {}

    sub git_revwalk_sorting(Git::Revwalk, uint32)
        is native('git2') {}

    method sorting(Bool :$topological, Bool :$time, Bool :$reverse)
    {
        my uint32 $sorting =
               ($topological ?? GIT_SORT_TOPOLOGICAL !! 0)
            +| ($time        ?? GIT_SORT_TIME        !! 0)
            +| ($reverse     ?? GIT_SORT_REVERSE     !! 0);

        git_revwalk_sorting(self, $sorting)
    }

    method reset()
        is native('git2') is symbol('git_revwalk_reset') {}

    sub git_revwalk_repository(Git::Revwalk --> Pointer)
        is native('git2') {}

    method repository()
    {
        nativecast(::('Git::Repository'), git_revwalk_repository(self))
    }

    submethod DESTROY { git_revwalk_free(self) }
}
