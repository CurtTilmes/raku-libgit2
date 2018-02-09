use NativeCall;

enum Git::Repository::InitFlag (
    GIT_REPOSITORY_INIT_BARE              => 1 +< 0,
    GIT_REPOSITORY_INIT_NO_REINIT         => 1 +< 1,
    GIT_REPOSITORY_INIT_NO_DOTGIT_DIR     => 1 +< 2,
    GIT_REPOSITORY_INIT_MKDIR             => 1 +< 3,
    GIT_REPOSITORY_INIT_MKPATH            => 1 +< 4,
    GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE => 1 +< 5,
    GIT_REPOSITORY_INIT_RELATIVE_GITLINK  => 1 +< 6,
);

enum Git::Repository::InitMode (
    GIT_REPOSITORY_INIT_SHARED_UMASK => 0,
    GIT_REPOSITORY_INIT_SHARED_GROUP => 0o2775,
    GIT_REPOSITORY_INIT_SHARED_ALL   => 0o2777,
);

class Git::Repository::InitOptions is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.flags;
    has uint32 $.mode;
    has Str $.workdir-path;
    has Str $.description;
    has Str $.template-path;
    has Str $.initial-head;
    has Str $.origin-url;

    submethod BUILD(Bool :$bare, Bool :$no-reinit, Bool :$no-dotgit-dir,
                    Bool :$mkdir, Bool :$mkpath, Bool :$external-template,
                    Bool :$relative-gitlink, uint32 :$!mode,
                    Bool :$shared-all, Bool :$shared-group,
                    Str :$workdir-path, Str :$description,
                    Str :$template-path, Str :$initial-head,
                    Str :$origin-url)
    {
        $!flags =
              ($bare              ?? GIT_REPOSITORY_INIT_BARE             !! 0)
           +| ($no-reinit         ?? GIT_REPOSITORY_INIT_NO_REINIT        !! 0)
           +| ($no-dotgit-dir     ?? GIT_REPOSITORY_INIT_NO_DOTGIT_DIR    !! 0)
           +| ($mkdir             ?? GIT_REPOSITORY_INIT_MKDIR            !! 0)
           +| ($external-template ?? GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE!! 0)
           +| ($relative-gitlink  ?? GIT_REPOSITORY_INIT_RELATIVE_GITLINK !! 0);

        $!mode = GIT_REPOSITORY_INIT_SHARED_GROUP if $shared-group;
        $!mode = GIT_REPOSITORY_INIT_SHARED_ALL   if $shared-all;

        $!workdir-path  := $workdir-path;
        $!description   := $description;
        $!template-path := $template-path;
        $!initial-head  := $initial-head;
        $!origin-url    := $origin-url;
    }
}
