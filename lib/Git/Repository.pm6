use NativeCall;
use Git::Error;
use Git::Buffer;
use Git::Config;
use Git::Reference;
use Git::Oid;
use Git::Strarray;
use Git::Remote;
use Git::Commit;
use Git::Blob;
use Git::Tree;
use Git::TreeBuilder;
use Git::Signature;
use Git::Object;
use Git::Blame;

enum Git::Repository::OpenFlag (
    GIT_REPOSITORY_OPEN_NO_SEARCH => 1 +< 0,
    GIT_REPOSITORY_OPEN_CROSS_FS  => 1 +< 1,
    GIT_REPOSITORY_OPEN_BARE      => 1 +< 2,
);

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
    has uint32 $.version;
    has uint32 $.flags;
    has uint32 $.mode;
    has Str $.workdir-path;
    has Str $.description;
    has Str $.template-path;
    has Str $.initial-head;
    has Str $.origin-url;

    submethod BUILD(uint32 :$!flags, uint32 :$!mode, Str :$workdir-path,
                    Str :$description, Str :$template-path, Str :$initial-head,
                    Str :$origin-url)
    {
        $!version = 1;
        $!workdir-path  := $workdir-path;
        $!description   := $description;
        $!template-path := $template-path;
        $!initial-head  := $initial-head;
        $!origin-url    := $origin-url;
    }
}

class Git::Repository is repr('CPointer')
{
    sub git_repository_free(Git::Repository)
        is native('git2') {}

    sub git_repository_new(Pointer is rw)
        is native('git2') {}

    sub git_repository_init(Pointer is rw, Str, uint32 --> int32)
        is native('git2') {}

    sub git_repository_init_ext(Pointer is rw, Str, Git::Repository::InitOptions
                                --> int32)
        is native('git2') {}

    sub git_repository_open(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_repository_open_bare(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_repository_open_ext(Pointer is rw, Str, uint32, Str --> int32)
        is native('git2') {}

    sub git_repository_discover(Git::Buffer, Str, int32, Str --> int32)
        is native('git2') {}

    sub git_clone(Pointer is rw, Str, Str, Pointer --> int32)
        is native('git2') {}

    sub git_repository_config(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_reference_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_dwim(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_name_to_id(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_tag_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_tag_list_match(Git::Strarray, Str, Git::Repository --> int32)
        is native('git2') {}

    sub git_remote_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_remote_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_branch_create(Pointer is rw, Git::Repository, Str,
                          Git::Commit, int32 --> int32)
        is native('git2') {}

    sub git_blob_create_frombuffer(Git::Oid, Git::Repository, Blob, size_t
                                   --> int32)
        is native('git2') {}

    sub git_blob_create_fromdisk(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_treebuilder_new(Pointer is rw, Git::Repository, Git::Tree --> int32)
        is native('git2') {}

    sub git_revparse_single(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_signature_default(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_tag_create(Git::Oid, Git::Repository, Str, Pointer, Git::Signature,
                       Str, int32 --> int32)
        is native('git2') {}

    sub git_tag_delete(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_object_lookup(Pointer is rw, Git::Repository, Git::Oid, int32
                          --> int32)
        is native('git2') {}

    sub git_blame_file(Pointer is rw, Git::Repository, Str, Git::Blame::Options
                   --> int32)
        is native('git2') {}

    method new()
    {
        my Pointer $ptr .= new;
        check(git_repository_new($ptr));
        nativecast(Git::Repostitory, $ptr)
    }

    method init(Str $path, Bool :$bare = False)
    {
        my Pointer $ptr .= new;
        check(git_repository_init($ptr, $path, $bare ?? 1 !! 0));
        nativecast(Git::Repository, $ptr)
    }

    method init-ext(Str $path, Str :$workdir-path, Str :$description,
                Str :$template-path, Str :$initial-head, Str :$origin-url,
                uint32 :$mode is copy = 0, Bool :$shared-group = False,
                Bool :$shared-all = False, Bool :$bare = False,
                Bool :$no-reinit = False, Bool :$no-dotgit-dir = False,
                Bool :$mkdir = False, Bool :$mkpath = False,
                Bool :$external-template = False, Bool :$relative-gitlink)
    {
        my uint32 $flags =
           ($bare              ?? GIT_REPOSITORY_INIT_BARE              !! 0)
        +| ($no-reinit         ?? GIT_REPOSITORY_INIT_NO_REINIT         !! 0)
        +| ($no-dotgit-dir     ?? GIT_REPOSITORY_INIT_NO_DOTGIT_DIR     !! 0)
        +| ($mkdir             ?? GIT_REPOSITORY_INIT_MKDIR             !! 0)
        +| ($mkpath            ?? GIT_REPOSITORY_INIT_MKPATH            !! 0)
        +| ($external-template ?? GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE !! 0)
        +| ($relative-gitlink  ?? GIT_REPOSITORY_INIT_RELATIVE_GITLINK  !! 0);

        $mode = GIT_REPOSITORY_INIT_SHARED_GROUP if $shared-group;
        $mode = GIT_REPOSITORY_INIT_SHARED_ALL   if $shared-all;

        my Git::Repository::InitOptions $opts .= new(version => 1,
                                                     :$flags, :$mode
                                                     :$workdir-path,
                                                     :$description,
                                                     :$template-path,
                                                     :$initial-head,
                                                     :$origin-url);
        my Pointer $ptr .= new;
        check(git_repository_init_ext($ptr, $path, $opts));
        nativecast(Git::Repository, $ptr);
    }

    method open(Str $path)
    {
        my Pointer $ptr .= new;
        check(git_repository_open($ptr, $path));
        nativecast(Git::Repository, $ptr)
    }

    method open-bare(Str $path)
    {
        my Pointer $ptr .= new;
        check(git_repository_open_bare($ptr, $path));
        nativecast(Git::Repository, $ptr)
    }

    method open-ext(Str $path, Str $ceiling-dirs?,
                    Bool :$no-search = False,
                    Bool :$cross-fs = False,
                    Bool :$bare = False)
    {
        my uint32 $flags = ($no-search ?? GIT_REPOSITORY_OPEN_NO_SEARCH !! 0)
                        +| ($cross-fs  ?? GIT_REPOSITORY_OPEN_CROSS_FS  !! 0)
                        +| ($bare      ?? GIT_REPOSITORY_OPEN_BARE      !! 0);

        my Pointer $ptr .= new;
        check(git_repository_open_ext($ptr, $path, $flags, $ceiling-dirs));
        nativecast(Git::Repository, $ptr)
    }

    method discover(Str $start-path, Str $ceiling-dirs?,
                    Bool :$across-fs = False)
    {
        my Git::Buffer $buf .= new;
        check(git_repository_discover($buf, $start-path, $across-fs ?? 1 !! 0,
                                      $ceiling-dirs));
        $buf.str
    }

    method commondir(--> Str)
        is native('git2') is symbol('git_repository_commondir') {}

    method clone(Str $url, Str $local-path)
    {
        my Pointer $ptr .= new;
        check(git_clone($ptr, $url, $local-path, Any));
        nativecast(Git::Repository, $ptr)
    }

    method config()
    {
        my Pointer $ptr .= new;
        check(git_repository_config($ptr, self));
        nativecast(Git::Config, $ptr)
    }

    method reference(Str $name)
    {
        my Pointer $ptr .= new;
        check(git_reference_lookup($ptr, self, $name));
        nativecast(Git::Reference, $ptr)
    }

    method ref(Str $shorthand)
    {
        my Pointer $ptr .= new;
        check(git_reference_dwim($ptr, self, $shorthand));
        nativecast(Git::Reference, $ptr)
    }

    method name-to-id(Str $name)
    {
        my Git::Oid $oid .= new;
        check(git_reference_name_to_id($oid, self, $name));
        $oid
    }

    method reference-list()
    {
        my Git::Strarray $array .= new;
        check(git_reference_list($array, self));
        $array.list
    }

    method tag-list(Str $pattern?)
    {
        my Git::Strarray $array .= new;
        check($pattern ?? git_tag_list_match($array, $pattern, self)
                       !! git_tag_list($array, self));
        $array.list
    }

    method remote-list()
    {
        my Git::Strarray $array .= new;
        check(git_remote_list($array, self));
        $array.list
    }

    method remote-lookup(Str $name)
    {
        my Pointer $ptr .= new;
        check(git_remote_lookup($ptr, self, $name));
        nativecast(Git::Remote, $ptr)
    }

    multi method blob-create(Blob $buf)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_frombuffer($oid, self, $buf, $buf.bytes));
        $oid
    }

    multi method blob-create(Str $str)
    {
        samewith($str.encode)
    }

    multi method blob-create(IO::Path $path)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_fromdisk($oid, self, ~$path));
        $oid
    }

    method treebuilder(Git::Tree $tree = Git::Tree)
    {
        my Pointer $ptr .= new;
        check(git_treebuilder_new($ptr, self, $tree));
        nativecast(Git::TreeBuilder, $ptr)
    }

    method revparse-single(Str $spec)
    {
        my Pointer $ptr .= new;
        check(git_revparse_single($ptr, self, $spec));
        nativecast(Git::Object, $ptr)
    }

    method signature-default(--> Git::Signature)
    {
        my Pointer $ptr .= new;
        check(git_signature_default($ptr, self));
        nativecast(Git::Signature, $ptr)
    }

    method tag-create(Str:D $tag-name, Git::Objectish:D $target,
                      Git::Signature :$tagger = self.signature-default,
                      Str:D :$message = '', Bool :$force = False)
    {
        my Git::Oid $oid .= new;
        check(git_tag_create($oid, self, $tag-name,
                             nativecast(Pointer, $target),
                             $tagger, $message, $force ?? 1 !! 0));
        $oid
    }

    method tag-delete(Str $tag-name)
    {
        check(git_tag_delete(self, $tag-name))
    }

    method tag-lookup(Git::Oid $oid)    { self.lookup($oid, GIT_OBJ_TAG)    }
    method commit-lookup(Git::Oid $oid) { self.lookup($oid, GIT_OBJ_COMMIT) }
    method blob-lookup(Git::Oid $oid)   { self.lookup($oid, GIT_OBJ_BLOB)   }
    method tree-lookup(Git::Oid $oid)   { self.lookup($oid, GIT_OBJ_TREE)   }

    multi method lookup(Git::Oid:D $oid, Git::Type $type = GIT_OBJ_ANY)
    {
        my Pointer $ptr .= new;
        check(git_object_lookup($ptr, self, $oid, $type));
        given Git::Objectish.type($ptr)
        {
            when GIT_OBJ_TAG    { nativecast(Git::Tag, $ptr)    }
            when GIT_OBJ_COMMIT { nativecast(Git::Commit, $ptr) }
            when GIT_OBJ_TREE   { nativecast(Git::Tree, $ptr)   }
            when GIT_OBJ_BLOB   { nativecast(Git::Blob, $ptr)   }
            default             { nativecast(Git::Object, $ptr) }
        }
    }

    multi method lookup(Git::Oid:D $oid, Str:D $type)
    {
        self.lookup($oid, Git::Objectish.type($type))
    }

    method blame-file(Str $path)
    {
        my Pointer $ptr .= new;
        my Git::Blame::Options $opts .= new;
        check(git_blame_file($ptr, self, $path, $opts));
        nativecast(Git::Blame, $ptr)
    }

    submethod DESTROY { git_repository_free(self) }
}
