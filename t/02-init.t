use Test;
use LibGit2;

my $test-repo-dir = 'testrepo';

ok my $repo = Git::Repository.init($test-repo-dir), 'init';

ok my $config = $repo.config;

for $config.get-all
{
    say .name, ' = ', .value, ' # ', .level;
}

done-testing;
