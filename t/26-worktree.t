use Test;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $worktree = $repo.worktree-lookup('worktree1');

$worktree.validate;
