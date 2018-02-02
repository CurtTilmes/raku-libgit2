use NativeCall;
use Git::Error;
use Git::Object;
use Git::Oid;

enum Git::FileMode (
    GIT_FILEMODE_UNREADABLE          => 0o000000,
    GIT_FILEMODE_TREE                => 0o040000,
    GIT_FILEMODE_BLOB                => 0o100644,
    GIT_FILEMODE_BLOB_EXECUTABLE     => 0o100755,
    GIT_FILEMODE_LINK                => 0o120000,
    GIT_FILEMODE_COMMIT              => 0o160000,
);

enum Git::Treewalk::Mode <
    GIT_TREEWALK_PRE
    GIT_TREEWALK_POST
>;

class Git::Tree::Entry is repr('CPointer')
{
    sub git_tree_entry_type(Git::Tree::Entry --> int32)
        is native('git2') {}

    method type() { Git::Type(git_tree_entry_type(self)) }

    method name(--> Str)
        is native('git2') is symbol('git_tree_entry_name') {}

    sub git_tree_entry_filemode(Git::Tree::Entry --> int32)
        is native('git2') {}

    sub git_tree_entry_filemode_raw(Git::Tree::Entry --> int32)
        is native('git2') {}

    multi method filemode()
    {
        Git::FileMode(git_tree_entry_filemode(self))
    }

    multi method filemode(Bool :$raw!)
    {
        git_tree_entry_filemode_raw(self)
    }

    method free()
        is native('git2') is symbol('git_tree_entry_free') {}

    method gist
    {
        "Git::Entry($.type():$.name())"
    }
}

my %walk-channels;
my $walk-channels-lock = Lock.new;

sub treewalk(Str $root, Git::Tree::Entry $entry, int64 $nonce --> int32)
{
    try %walk-channels{$nonce}.send([$root, $entry]);
    $! ?? -1 !! 0
}

class Git::Tree is repr('CPointer') does Git::Objectish
{
    method elems(--> size_t)
        is native('git2') is symbol('git_tree_entrycount') {}

    multi method entry(size_t $idx --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byindex') {}

    multi method entry(Git::Oid $oid --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byid') {}

    multi method entry(Str $name --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byname') {}

    sub git_tree_entry_bypath(Pointer is rw, Git::Tree, Str --> int32)
        is native('git2') {}

    method entry-bypath(Str:D $path --> Git::Tree::Entry)
    {
        my Pointer $ptr .= new;
        check(git_tree_entry_bypath($ptr, self, $path));
        nativecast(Git::Tree::Entry, $ptr)
    }

    sub git_tree_walk(Git::Tree, int32,
                      &callback (Str, Git::Tree::Entry, int64 --> int32),
                      int64 --> int32)
        is native('git2') {}

    method walk(Bool :$post = False, int64 :$nonce = nativecast(int64, self))
    {
        my $mode = $post ?? GIT_TREEWALK_POST !! GIT_TREEWALK_PRE;

        my $channel = Channel.new;

        $walk-channels-lock.protect: { %walk-channels{$nonce} = $channel }

        start
        {
            my $ret = git_tree_walk(self, $mode, &treewalk, $nonce);
            if $ret != 0
            {
                $channel.fail: X::Git.new(code => Git::ErrorCode($ret))
            }
            $walk-channels-lock.protect: { %walk-channels{$nonce}:delete }
            $channel.close
        }

        $channel
    }

    submethod DESTROY { self.free }
}
