use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = '/tmp/mine'; # tempdir;

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.open($test-repo-dir), 'open';

my $builder = $repo.treebuilder;

say $builder;

my $obj = $repo.revparse-single('HEAD:README.md');

say $obj;
