use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $oid = Git::Oid.new('09b0f95e3618ccb1284adbf4a210afc6d849c8c8');

my $commit = $repo.commit-lookup($oid);

say $commit.describe;
