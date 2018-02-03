use NativeCall;
use Git::Oid;

enum Git::Diff::Option (
    GIT_DIFF_NORMAL                          => 0,
    GIT_DIFF_REVERSE                         => 1 +< 0,
    GIT_DIFF_INCLUDE_IGNORED                 => 1 +< 1,
    GIT_DIFF_RECURSE_IGNORED_DIRS            => 1 +< 2,
    GIT_DIFF_INCLUDE_UNTRACKED               => 1 +< 3,
    GIT_DIFF_RECURSE_UNTRACKED_DIRS          => 1 +< 4,
    GIT_DIFF_INCLUDE_UNMODIFIED              => 1 +< 5,
    GIT_DIFF_INCLUDE_TYPECHANGE              => 1 +< 6,
    GIT_DIFF_INCLUDE_TYPECHANGE_TREES        => 1 +< 7,
    GIT_DIFF_IGNORE_FILEMODE                 => 1 +< 8,
    GIT_DIFF_IGNORE_SUBMODULES               => 1 +< 9,
    GIT_DIFF_IGNORE_CASE                     => 1 +< 10,
    GIT_DIFF_INCLUDE_CASECHANGE              => 1 +< 11,
    GIT_DIFF_DISABLE_PATHSPEC_MATCH          => 1 +< 12,
    GIT_DIFF_SKIP_BINARY_CHECK               => 1 +< 13,
    GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS      => 1 +< 14,
    GIT_DIFF_UPDATE_INDEX                    => 1 +< 15,
    GIT_DIFF_INCLUDE_UNREADABLE              => 1 +< 16,
    GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED => 1 +< 17,
    GIT_DIFF_FORCE_TEXT                      => 1 +< 20,
    GIT_DIFF_FORCE_BINARY                    => 1 +< 21,
    GIT_DIFF_IGNORE_WHITESPACE               => 1 +< 22,
    GIT_DIFF_IGNORE_WHITESPACE_CHANGE        => 1 +< 23,
    GIT_DIFF_IGNORE_WHITESPACE_EOL           => 1 +< 24,
    GIT_DIFF_SHOW_UNTRACKED_CONTENT          => 1 +< 25,
    GIT_DIFF_SHOW_UNMODIFIED                 => 1 +< 26,
    GIT_DIFF_PATIENCE                        => 1 +< 28,
    GIT_DIFF_MINIMAL                         => 1 +< 29,
    GIT_DIFF_SHOW_BINARY                     => 1 +< 30,
    GIT_DIFF_INDENT_HEURISTIC                => 1 +< 31,
);

enum Git::Diff::Flag (
    GIT_DIFF_FLAG_BINARY     => 1 +< 0,
    GIT_DIFF_FLAG_NOT_BINARY => 1 +< 1,
    GIT_DIFF_FLAG_VALID_ID   => 1 +< 2,
    GIT_DIFF_FLAG_EXISTS     => 1 +< 3,
);

enum Git::Delta::Type <
    GIT_DELTA_UNMODIFIED
    GIT_DELTA_ADDED
    GIT_DELTA_DELETED
    GIT_DELTA_MODIFIED
    GIT_DELTA_RENAMED
    GIT_DELTA_COPIED
    GIT_DELTA_IGNORED
    GIT_DELTA_UNTRACKED
    GIT_DELTA_TYPECHANGE
    GIT_DELTA_UNREADABLE
    GIT_DELTA_CONFLICTED
>;

class Git::Diff::File is repr('CStruct')
{
    HAS Git::Oid $.id;
    has Str $.path;
    has int64 $.size;
    has uint32 $.flags;
    has uint16 $.mode;
    has uint16 $.id-abbrev;
}

class Git::Diff::Delta is repr('CStruct')
{
    has int32 $.status;
    has uint32 $.flags;
    has uint16 $.similarity;
    has uint16 $.nfiles;
    HAS Git::Diff::File $.old-file;
    HAS Git::Diff::File $.new-file;
}

class Git::Diff is repr('CPointer')
{
    sub git_diff_free(Git::Diff)
        is native('git2') {}

    submethod DESTROY { git_diff_free(self) }
}
