use NativeCall;
use Git::Oid;
use Git::Signature;

enum Git::Blame::Flag
(
    GIT_BLAME_NORMAL                          => 0,
    GIT_BLAME_TRACK_COPIES_SAME_FILE          => 1 +< 0,
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_MOVES  => 1 +< 1,
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_COPIES => 1 +< 2,
    GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES  => 1 +< 3,
    GIT_BLAME_FIRST_PARENT                    => 1 +< 4,
);

class Git::Blame::Options is repr('CStruct')
{
    has uint32 $.version;
    has uint32 $.flags;
    has uint16 $.min_match_characters;
    HAS Git::Oid $.newest_commit;
    HAS Git::Oid $.oldest_commit;
    has size_t $.min_line;
    has size_t $.max_line;

    submethod BUILD { $!version = 1 }
}

class Git::Blame::Hunk is repr('CStruct')
{
    has size_t $.lines-in-hunk;
    HAS Git::Oid $.final_commit_id;
    has size_t $.final_start_line_number;
    has Git::Signature $.final_signature;
    HAS Git::Oid $.orig_commit_id;
    has Str $.orig_path;
    has size_t $.orig_start_line_number;
    has Git::Signature $.orig_signature;
    has uint8 $.boundary;
}

class Git::Blame is repr('CPointer')
{
    sub git_blame_free(Git::Blame)
        is native('git2') {}

    method hunk-count(--> uint32)
        is native('git2') is symbol('git_blame_get_hunk_count') {}

    method hunk(uint32 $index --> Git::Blame::Hunk)
        is native('git2') is symbol('git_blame_get_hunk_byindex') {}

    method line(size_t $lineno --> Git::Blame::Hunk)
        is native('git2') is symbol('git_blame_get_hunk_byline') {}

    submethod DESTROY { git_blame_free(self) }
}
