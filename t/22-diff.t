use Test;
use LibGit2;
use Git::Status;

my $repo = Git::Repository.open('/tmp/mine');

my $tree = $repo.revparse-single('HEAD^{tree}');

my $diff = $repo.diff-tree-to-workdir-with-index(:$tree);

say $diff.delta($_) for ^$diff.num-deltas;
