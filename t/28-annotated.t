use Test;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

