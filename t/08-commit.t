use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $oid = Git::Oid.new('09b0f95e3618ccb1284adbf4a210afc6d849c8c8');

my $commit = $repo.commit-lookup($oid);

say $commit;

my $sig = $commit.author;

say $sig.name;
say $sig.email;
say $sig.when;

say $commit.body;

say $commit.committer;

say $commit.header('committer');

say ~$commit.id;

say $commit.owner;

say $commit.type;

say $commit.summary;

say $commit.message;

say $commit.encoding;

say $commit.time;

say $commit.raw-header;

say ~$commit.tree-id;

say ~$commit.tree.id;

say $commit.parentcount;

say ~$commit.parent-id;


my $parent = $commit.parent;

say $parent.message;

my $anc = $commit.ancestor(1);

say $anc.message;
