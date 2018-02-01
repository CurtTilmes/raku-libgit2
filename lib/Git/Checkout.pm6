use NativeCall;
use Git::Error;
use Git::Strarray;
use Git::Tree;
use Git::Index;

enum Git::Checkout::Strategy (
    GIT_CHECKOUT_NONE                         = 0,
    GIT_CHECKOUT_SAFE                         = 1 +< 0,
    GIT_CHECKOUT_FORCE                        = 1 +< 1,
    GIT_CHECKOUT_RECREATE_MISSING             = 1 +< 2,
    GIT_CHECKOUT_ALLOW_CONFLICTS              = 1 +< 4,
    GIT_CHECKOUT_REMOVE_UNTRACKED             = 1 +< 5,
    GIT_CHECKOUT_REMOVE_IGNORED               = 1 +< 6,
    GIT_CHECKOUT_UPDATE_ONLY                  = 1 +< 7,
    GIT_CHECKOUT_DONT_UPDATE_INDEX            = 1 +< 8,
    GIT_CHECKOUT_NO_REFRESH                   = 1 +< 9,
    GIT_CHECKOUT_SKIP_UNMERGED                = 1 +< 10,
    GIT_CHECKOUT_USE_OURS                     = 1 +< 11,
    GIT_CHECKOUT_USE_THEIRS                   = 1 +< 12,
    GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH       = 1 +< 13,
    GIT_CHECKOUT_UPDATE_SUBMODULES            = 1 +< 16,
    GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED = 1 +< 17,
    GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES      = 1 +< 18,
    GIT_CHECKOUT_DONT_OVERWRITE_IGNORED       = 1 +< 19,
    GIT_CHECKOUT_CONFLICT_STYLE_MERGE         = 1 +< 20,
    GIT_CHECKOUT_CONFLICT_STYLE_DIFF3         = 1 +< 21,
    GIT_CHECKOUT_DONT_REMOVE_EXISTING         = 1 +< 22,
    GIT_CHECKOUT_DONT_WRITE_INDEX             = 1 +< 23,

);

enum Git::Checkout::Notify (
    GIT_CHECKOUT_NOTIFY_NONE      => 0,
    GIT_CHECKOUT_NOTIFY_CONFLICT  => 1 +< 0,
    GIT_CHECKOUT_NOTIFY_DIRTY     => 1 +< 1,
    GIT_CHECKOUT_NOTIFY_UPDATED   => 1 +< 2,
    GIT_CHECKOUT_NOTIFY_UNTRACKED => 1 +< 3,
    GIT_CHECKOUT_NOTIFY_IGNORED   => 1 +< 4,

    GIT_CHECKOUT_NOTIFY_ALL       => 0x0FFFF
);

class Git::Checkout::Perfdata is repr('CStruct')
{
    has size_t $.mkdir-calls;
    has size_t $.stat-calls;
    has size_t $.chmod-calls;
}

class Git::Checkout::Options is repr('CStruct')
{
    uint32 $.version;
    uint32 $.checkout-strategy;
    int32  $.disable-filters;
    uint32 $.dir-mode;
    uint32 $.file-mode;
    int32  $.file-open-flags;
    uint32 $.notify-flags;
    Pointer $.notify-cb;
    Pointer $.notify-payload;
    Pointer $.progress-cb;
    Pointer $.progress-payload;
    HAS Git::Strarray $.paths;
    has Git::Tree $.baseline;
    has Git::Index $.baseline-index;
    has Str $.target-directory;
    has Str $.ancestor-label;
    has Str $.our-label;
    has Str $.their-label;
    has Pointer $.perfdata-cb;
    has Pointer $.perfdata-payload;

    submethod BUILD { $!version = 1 }
}
