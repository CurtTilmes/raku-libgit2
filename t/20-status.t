use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

my $status = $repo.status-list;

say $status;

say $status.elems;

my $entry = $status[0];

say $entry;
