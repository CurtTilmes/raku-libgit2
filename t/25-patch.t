use Test;
use LibGit2;
use Git::Status;
use Git::Diff;

my $repo = Git::Repository.open('/tmp/mine');

my $tree = $repo.revparse-single('HEAD^{tree}');

my $diff = $repo.diff-tree-to-workdir-with-index(:$tree);

for $diff.deltas
{
    .say
}

for $diff.patches
{
    .delta.say;
    for .hunks
    {
        for .lines
        {
            .say
        }
    }
}

