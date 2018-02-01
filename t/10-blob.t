use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = '/tmp/mine'; tempdir(:!unlink);

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.init($test-repo-dir), 'init';

ok my $oid = $repo.blob-create('Add this blob'), 'blob create';

is $oid, '965fbc02b226a75edf239af95a0a9f0e4755e37e', 'oid';

ok my $blob = $repo.blob-lookup($oid), 'blob lookup';

is $blob.is-binary, False, 'is not binary';

is $blob.id, '965fbc02b226a75edf239af95a0a9f0e4755e37e', 'blob id';

is $blob.rawsize, 13, 'rawsize';

is $blob.content.decode, 'Add this blob', 'content';

