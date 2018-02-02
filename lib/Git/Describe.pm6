use NativeCall;
use Git::Buffer;
use Git::Error;

constant \GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE = 7;

enum Git::Describe::Strategy <
    GIT_DESCRIBE_DEFAULT
    GIT_DESCRIBE_TAGS
    GIT_DESCRIBE_ALL
>;

class Git::Describe::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.max-candidates-tags = 10;
    has uint32 $.describe_strategy;
    has Pointer $.pattern;
    has int32 $.only-follow-first-parent;
    has int32 $.show-commit-oid-as-fallback;
}

class Git::Describe::Format::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.abbreviated-size = GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE;
    has int32 $.always-use-long-format;
    has Str $.dirty-suffix;
}

class Git::Describe::Result is repr('CPointer')
{
    sub git_describe_result_free(Git::Describe::Result)
        is native('git2') {}

    submethod DESTROY { git_describe_result_free(self) }
}
