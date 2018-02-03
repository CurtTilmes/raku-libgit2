use NativeCall;
use Git::Error;
use Git::Strarray;
use Git::Tree;
use Git::Diff;

enum Git::Status::Show <
    GIT_STATUS_SHOW_INDEX_AND_WORKDIR
    GIT_STATUS_SHOW_INDEX_ONLY
    GIT_STATUS_SHOW_WORKDIR_ONLY
>;

enum Git::Status::Type (
    GIT_STATUS_CURRENT          => 0,

    GIT_STATUS_INDEX_NEW        => 1 +< 0,
    GIT_STATUS_INDEX_MODIFIED   => 1 +< 1,
    GIT_STATUS_INDEX_DELETED    => 1 +< 2,
    GIT_STATUS_INDEX_RENAMED    => 1 +< 3,
    GIT_STATUS_INDEX_TYPECHANGE => 1 +< 4,

    GIT_STATUS_WT_NEW           => 1 +< 7,
    GIT_STATUS_WT_MODIFIED      => 1 +< 8,
    GIT_STATUS_WT_DELETED       => 1 +< 9,
    GIT_STATUS_WT_TYPECHANGE    => 1 +< 10,
    GIT_STATUS_WT_RENAMED       => 1 +< 11,
    GIT_STATUS_WT_UNREADABLE    => 1 +< 12,

    GIT_STATUS_IGNORED          => 1 +< 14,
    GIT_STATUS_CONFLICTED       => 1 +< 15,
);

enum Git::Status::Opt (
    GIT_STATUS_OPT_INCLUDE_UNTRACKED                => 1 +< 0,
    GIT_STATUS_OPT_INCLUDE_IGNORED                  => 1 +< 1,
    GIT_STATUS_OPT_INCLUDE_UNMODIFIED               => 1 +< 2,
    GIT_STATUS_OPT_EXCLUDE_SUBMODULES               => 1 +< 3,
    GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS           => 1 +< 4,
    GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH           => 1 +< 5,
    GIT_STATUS_OPT_RECURSE_IGNORED_DIRS             => 1 +< 6,
    GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX            => 1 +< 7,
    GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR         => 1 +< 8,
    GIT_STATUS_OPT_SORT_CASE_SENSITIVELY            => 1 +< 9,
    GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY          => 1 +< 10,
    GIT_STATUS_OPT_RENAMES_FROM_REWRITES            => 1 +< 11,
    GIT_STATUS_OPT_NO_REFRESH                       => 1 +< 12,
    GIT_STATUS_OPT_UPDATE_INDEX                     => 1 +< 13,
    GIT_STATUS_OPT_INCLUDE_UNREADABLE               => 1 +< 14,
    GIT_STATUS_OPT_INCLUDE_UNREADABLE_AS_UNTRACKED  => 1 +< 15,
);

class Git::Status::Options is repr('CStruct')
{
    has uint32        $.version = 1;
    has int32         $.show;
    has uint32        $.flags;
    HAS Git::Strarray $.pathspec;
    has Git::Tree     $.baseline;

    submethod BUILD(:$!show, :$!flags, Git::Strarray :$pathspec,
                    Git::Tree :$baseline)
    {
        $!pathspec := $pathspec;
        $!baseline := $baseline;
    }
}

class Git::Status::Entry is repr('CStruct')
{
    has int32 $.status;
    has Git::Diff::Delta $.head-to-index;
    has Git::Diff::Delta $.index-to-workdir;

    method status
    {
        set do for Git::Status::Type.enums { .key if $!status +& .value }
    }
}

class Git::Status::List is repr('CPointer') does Positional
{
    sub git_status_list_free(Git::Status::List)
        is native('git2') {}

    sub git_status_list_entrycount(Git::Status::List --> size_t)
        is native('git2') {}

    multi method elems { git_status_list_entrycount(self) }

    sub git_status_byindex(Git::Status::List, size_t --> Git::Status::Entry)
        is native('git2') {}

    multi method AT-POS($index) { git_status_byindex(self, $index) }

    multi method EXISTS-POS($index) { so git_status_byindex(self, $index) }

    submethod DESTROY { git_status_list_free(self) }
}
