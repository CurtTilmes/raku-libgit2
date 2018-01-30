use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = tempdir;

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.init($test-repo-dir), 'init';

ok my $config = $repo.config, 'repo config';

done-testing;
