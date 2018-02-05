use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

my $revwalk = $repo.revwalk;

$revwalk.push('HEAD~3..HEAD');

say $revwalk;
