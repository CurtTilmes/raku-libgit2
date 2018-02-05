use Test;
use LibGit2;
use Git::Oid;

my $repo = Git::Repository.open('/tmp/mine');

my $revwalk = $repo.revwalk;

$revwalk.push('f213e199f06e017f5c0f77cb95a5e7656d0a59ec');

$revwalk.sorting(:time, :reverse);

$revwalk.simplify-first-parent;

.say for $revwalk.walk;
