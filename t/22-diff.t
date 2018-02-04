use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

my $diff = $repo.diff-index-to-workdir;

say $diff.num-deltas;

my $patch = $diff.patch(0);

say $patch.Str;
