use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

my $status = $repo.status-list('README.md');

for $status[^$status.elems]
{
    .status.say;
    .say;
}

