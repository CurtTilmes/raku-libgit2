use NativeCall;
use Git::Error;
use Git::Repository;
use Git::Config;
use Git::Tree;
use Git::Object;
use Git::Message;
use Git::Index;
use Git::Status;

my package EXPORT::DEFAULT {}

BEGIN  # Re-export some enums defined in other modules
{
    for Git::Config::Level, Git::Status::Flags, Git::FileMode,
        Git::Type, Git::ErrorCode -> $enum
    {
        for $enum.enums
        {
            EXPORT::DEFAULT::{.key} = ::(.key)
        }
    }
}

sub git_libgit2_init(--> int32) is native('git2') {}
sub git_libgit2_shutdown(--> int32) is native('git2') {}

INIT git_libgit2_init;
END git_libgit2_shutdown;

enum Git::Feature (
    GIT_FEATURE_THREADS => 1 +< 0,
    GIT_FEATURE_HTTPS   => 1 +< 1,
    GIT_FEATURE_SSH     => 1 +< 2,
    GIT_FEATURE_NSEC    => 1 +< 3,
);

class LibGit2
{
    sub git_libgit2_version(int32 is rw, int32 is rw, int32 is rw)
        is native('git2') {}

    sub git_libgit2_features(--> int32)
        is native('git2') {}

    method version
    {
        my int32 $major;
        my int32 $minor;
        my int32 $rev;
        git_libgit2_version($major, $minor, $rev);
        "$major.$minor.$rev"
    }

    method features
    {
        my $features = git_libgit2_features;
        set do for Git::Feature.enums { .key if $features +& .value }
    }
}
