use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';
my $oid = Git::Oid.new('9fb51ba4ffc485ee6577bd96ffd77c3ea30bb27e');

my $commit = $repo.commit-lookup($oid);

say $commit;

say $commit.describe.format;
