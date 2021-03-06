use NativeCall;

enum Git::ErrorCode (
    GIT_OK              =>   0,
    GIT_ERROR           =>  -1,
    GIT_ENOTFOUND       =>  -3,
    GIT_EEXISTS         =>  -4,
    GIT_EAMBIGUOUS      =>  -5,
    GIT_EBUFS           =>  -6,
    GIT_EUSER           =>  -7,
    GIT_EBAREREPO       =>  -8,
    GIT_EUNBORNBRANCH   =>  -9,
    GIT_EUNMERGED       => -10,
    GIT_ENONFASTFORWARD => -11,
    GIT_EINVALIDSPEC    => -12,
    GIT_ECONFLICT       => -13,
    GIT_ELOCKED         => -14,
    GIT_EMODIFIED       => -15,
    GIT_EAUTH           => -16,
    GIT_ECERTIFICATE    => -17,
    GIT_EAPPLIED        => -18,
    GIT_EPEEL           => -19,
    GIT_EEOF            => -20,
    GIT_EINVALID        => -21,
    GIT_EUNCOMMITTED    => -22,
    GIT_EDIRECTORY      => -23,
    GIT_EMERGECONFLICT  => -24,
    GIT_PASSTHROUGH     => -30,
    GIT_ITEROVER        => -31,
);

enum Git::ErrorClass <
    GITERR_NONE
    GITERR_NOMEMORY
    GITERR_OS
    GITERR_INVALID
    GITERR_REFERENCE
    GITERR_ZLIB
    GITERR_REPOSITORY
    GITERR_CONFIG
    GITERR_REGEX
    GITERR_ODB
    GITERR_INDEX
    GITERR_OBJECT
    GITERR_NET
    GITERR_TAG
    GITERR_TREE
    GITERR_INDEXER
    GITERR_SSL
    GITERR_SUBMODULE
    GITERR_THREAD
    GITERR_STASH
    GITERR_CHECKOUT
    GITERR_FETCHHEAD
    GITERR_MERGE
    GITERR_SSH
    GITERR_FILTER
    GITERR_REVERT
    GITERR_CALLBACK
    GITERR_CHERRYPICK
    GITERR_DESCRIBE
    GITERR_REBASE
    GITERR_FILESYSTEM
>;

class X::Git is Exception
{
    has Git::ErrorCode $.code;
    has Git::ErrorClass $.class;
    has Str $.message;

    class Git::Error is repr('CStruct')
    {
        has Str $.message;
        has int32 $.klass;
    }

    sub giterr_last(--> Git::Error) is native('git2') {}
    sub giterr_clear() is native('git2') {}

    submethod TWEAK
    {
        my $err = giterr_last;
        with $err
        {
            $!class = Git::ErrorClass(.klass);
            $!message = .message;
        }
        else
        {
            $!message = ~$!code;
        }
        giterr_clear;
    }
}

sub check(int32 $code) is export
{
    die X::Git.new(code => Git::ErrorCode($code)) if $code < 0;
    $code
}
