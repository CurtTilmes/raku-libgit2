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
use Git::Message;
use Git::Index;
use Git::Status;
use Git::Revwalk;
use Git::Checkout;

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

enum Git::Branch::Type (
    GIT_BRANCH_LOCAL  => 1,
    GIT_BRANCH_REMOTE => 2,
    GIT_BRANCH_ALL    => 3,
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

class Git::Repository is repr('CPointer') {...}

class Git::Branch::Iterator does Iterator
{
    has Pointer $.iter;

    sub git_branch_iterator_new(Pointer is rw, Git::Repository, int32 --> int32)
        is native('git2') {}

    sub git_branch_next(Pointer is rw, int32 is rw, Pointer --> int32)
        is native('git2') {}

    sub git_branch_iterator_free(Pointer)
        is native('git2') {}

    multi method new(Git::Repository $repo,
                     Bool :$local = False, Bool :$remote = False)
    {
        my Git::Branch::Type $type =
            $local && $remote ?? GIT_BRANCH_ALL
                              !! $local ?? GIT_BRANCH_LOCAL
                                        !! $remote ?? GIT_BRANCH_REMOTE
                                                   !! GIT_BRANCH_ALL;

        my Pointer $iter .= new;
        check(git_branch_iterator_new($iter, $repo, $type));
        samewith(:$iter)
    }

    method pull-one
    {
        my Pointer $ptr .= new;
        my int32 $type = 0;
        my $ret = git_branch_next($ptr, $type, $!iter);
        return IterationEnd if $ret == GIT_ITEROVER;
        check($ret);
        nativecast(Git::Reference, $ptr)
    }

    submethod DESTROY { git_branch_iterator_free($_) with $!iter }
}

class Git::Repository
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

    sub git_remote_create(Pointer is rw, Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_create_anonymous(Pointer is rw, Git::Repository, Str
                                    --> int32)
        is native('git2') {}

    sub git_remote_create_with_fetchspec(Pointer is rw, Git::Repository, Str,
                                         Str, Str --> int32)
        is native('git2') {}

    sub git_remote_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_remote_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_remote_add_fetch(Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_add_push(Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_set_autotag(Git::Repository, Str, int32 --> int32)
        is native('git2') {}

    sub git_remote_delete(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_branch_create(Pointer is rw, Git::Repository, Str,
                          Git::Commit, int32 --> int32)
        is native('git2') {}

    sub git_branch_lookup(Pointer is rw, Git::Repository, Str, int32 --> int32)
        is native('git2') {}

    sub git_blob_create_frombuffer(Git::Oid, Git::Repository, Blob, size_t
                                   --> int32)
        is native('git2') {}

    sub git_blob_create_fromdisk(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_blob_create_fromworkdir(Git::Oid, Git::Repository, Str --> int32)
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

    sub git_tree_entry_to_object(Pointer is rw, Git::Repository,
                                 Git::Tree::Entry --> int32)
        is native('git2') {}

    sub git_commit_create(Git::Oid, Git::Repository, Str, Git::Signature,
                          Git::Signature, Str, Str, Git::Tree, size_t,
                          CArray[Git::Commit] --> int32)
        is native('git2') {}

    sub git_repository_index(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_ignore_add_rule(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_ignore_clear_internal_rules(Git::Repository --> int32)
        is native('git2') {}

    sub git_ignore_path_is_ignored(int32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_status_list_new(Pointer is rw, Git::Repository,
                            Git::Status::Options --> int32)
        is native('git2') {}

    sub git_status_file(uint32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_status_should_ignore(int32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_diff_index_to_workdir(Pointer is rw, Git::Repository, Git::Index,
                                  Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_index(Pointer is rw, Git::Repository, Git::Tree,
                               Git::Index, Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_workdir_with_index(Pointer is rw, Git::Repository,
                                   Git::Tree, Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_tree(Pointer is rw, Git::Repository,
                              Git::Tree, Git::Tree, Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_revwalk_new(Pointer is rw, Git::Repository --> int32)
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
        $array.list(:free)
    }

    method tag-list(Str $pattern?)
    {
        my Git::Strarray $array .= new;
        check($pattern ?? git_tag_list_match($array, $pattern, self)
                       !! git_tag_list($array, self));
        $array.list(:free)
    }

    method remote-create(Str:D :$url, Str :$name, Str :$fetch)
    {
        my Pointer $ptr .= new;
        check($name ??
              ($fetch ?? git_remote_create_with_fetchspec($ptr, self, $name,
                                                          $url, $fetch)
                      !! git_remote_create($ptr, self, $name, $url))
              !! git_remote_create_anonymous($ptr, self, $url));
        nativecast(Git::Remote, $ptr)
    }

    method remote-list()
    {
        my Git::Strarray $array .= new;
        check(git_remote_list($array, self));
        $array.list(:free)
    }

    method remote-lookup(Str $name)
    {
        my Pointer $ptr .= new;
        check(git_remote_lookup($ptr, self, $name));
        nativecast(Git::Remote, $ptr)
    }

    method remote-add-fetch(Str:D $remote, Str:D $refspec)
    {
        check(git_remote_add_fetch(self, $remote, $refspec))
    }

    method remote-add-push(Str:D $remote, Str:D $refspec)
    {
        check(git_remote_add_push(self, $remote, $refspec))
    }

    method remote-set-autotag(Str:D $remote,
                              Bool :$auto,
                              Bool :$none,
                              Bool :$all)
    {
        my int32 $opt = $auto ?? GIT_REMOTE_DOWNLOAD_TAGS_AUTO
                     !! $none ?? GIT_REMOTE_DOWNLOAD_TAGS_NONE
                     !! $all  ?? GIT_REMOTE_DOWNLOAD_TAGS_ALL
                     !! die "Autotag must be auto, none or all";
        say $opt;
        check(git_remote_set_autotag(self, $remote, $opt))
    }

    method remote-delete(Str:D $name)
    {
        check(git_remote_delete(self, $name))
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

    multi method blob-create(Str $path, :$workdir!)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_fromworkdir($oid, self, $path));
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
        Git::Objectish.object($ptr)
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
        Git::Objectish.object($ptr)
    }

    multi method lookup(Git::Oid:D $oid, Str:D $type)
    {
        samewith($oid, Git::Objectish.type($type))
    }

    multi method lookup(Str:D $oid-str, Git::Type $type = GIT_OBJ_ANY)
    {
        samewith(Git::Oid.new($oid-str), $type)
    }

    multi method lookup(Str:D $oid-str, Str:D $type)
    {
        samewith(Git::Oid.new($oid-str, Git::Objectish.type($type)))
    }

    method blame-file(Str $path)
    {
        my Pointer $ptr .= new;
        my Git::Blame::Options $opts .= new;
        check(git_blame_file($ptr, self, $path, $opts));
        nativecast(Git::Blame, $ptr)
    }

    method branch-create(Str $branch-name, Git::Commit $target,
                         Bool :$force = False)
    {
        my Pointer $ptr .= new;
        check(git_branch_create($ptr, self, $branch-name, $target,
                                $force ?? 1 !! 0));
        nativecast(Git::Reference, $ptr)
    }

    method branch-lookup(Str $branch-name, Bool :$remote = False)
    {
        my Pointer $ptr .= new;
        check(git_branch_lookup($ptr, self, $branch-name,
              $remote ?? GIT_BRANCH_REMOTE !! GIT_BRANCH_LOCAL));
        nativecast(Git::Reference, $ptr)
    }

    method branch-list(--> Seq)
    {
        Seq.new(Git::Branch::Iterator.new(self))
    }

    method object(Git::Tree::Entry $entry)
    {
        my Pointer $ptr .= new;
        check(git_tree_entry_to_object($ptr, self, $entry));
        Git::Objectish.object($ptr)
    }

    method commit(Str:D :$update-ref = 'HEAD',
                  Git::Signature:D :$author = !.signature-default,
                  Git::Signature:D :$committer = $author,
                  Str:D :$encoding =  'UTF-8',
                  Str:D :$message!,
                  Git::Tree:D :$tree,
                  Bool :$prettify = False,
                  *@parents)
    {
        my Pointer $ptr .= new;
        my @parents-array := CArray[Git::Commit].new(@parents);

        check(git_commit_create($ptr, self, $update-ref,
                                $author, $committer, $encoding,
                                $prettify ?? Git::Message.prettify($message)
                                          !! $message,
                                $tree, @parents.elems, @parents-array));
        nativecast(Git::Oid, $ptr)
    }

    method index(--> Git::Index)
    {
        my Pointer $ptr .= new;
        check(git_repository_index($ptr, self));
        nativecast(Git::Index, $ptr)
    }

    method ignore-add(Str $rules)
    {
        check(git_ignore_add_rule(self, $rules));
    }

    method ignore-clear()
    {
        check(git_ignore_clear_internal_rules(self))
    }

    method is-ignored(Str $path)
    {
        my int32 $ignored = 0;
        check(git_ignore_path_is_ignored($ignored, self, $path));
        $ignored == 1
    }

    method status-list(*@pathspec, |opts)
    {
        my $opts = Git::Status::Options.new(
            :pathspec(Git::Strarray.new(|@pathspec)), |opts);

        my Pointer $ptr .= new;
        check(git_status_list_new($ptr, self, $opts));
        nativecast(Git::Status::List, $ptr)
    }

    method status-file(Str $path)
    {
        my uint32 $flags = 0;
        check(git_status_file($flags, self, $path));
        Git::Status::File.new(:$flags, :$path)
    }

    method status-each(*@pathspec, |opts)
    {
        if @pathspec || opts
        {
            my $opts = Git::Status::Options.new(
                :pathspec(Git::Strarray.new(|@pathspec)), |opts);
            return Git::Status.foreach(nativecast(Pointer, self), $opts)
        }
        else
        {
            return Git::Status.foreach(nativecast(Pointer, self))
        }
    }

    method status-should-ignore(Str $path)
    {
        my int32 $ignored = 0;
        check(git_status_should_ignore($ignored, self, $path));
        $ignored == 1
    }

    method diff-index-to-workdir(Git::Index :$index, |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_index_to_workdir($ptr, self, $index, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-index(Git::Tree :$tree,
                              Git::Index :$index,
                              |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_index($ptr, self, $tree, $index, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-workdir-with-index(Git::Tree :$tree, |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_workdir_with_index($ptr, self, $tree, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-tree(Git::Tree $old-tree,
                             Git::Tree $new-tree,
                             |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_tree($ptr, self, $old-tree, $new-tree, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method revwalk
    {
        my Pointer $ptr .= new;
        check(git_revwalk_new($ptr, self));
        nativecast(Git::Revwalk, $ptr)
    }

    method checkout(|opts)
    {
        Git::Checkout.checkout(repo => self, |opts)
    }

    submethod DESTROY { git_repository_free(self) }
}
