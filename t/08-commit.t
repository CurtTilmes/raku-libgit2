use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $oid = Git::Oid.new('a011cc6c30a6c4fea486d703af01480ba7bcaf63');

my $commit = $repo.commit-lookup($oid);

say $commit;

my $sig = $commit.author;

say $sig.name;
say $sig.email;
say $sig.when;

say $commit.body;

say $commit.committer;

say $commit.header('committer');
