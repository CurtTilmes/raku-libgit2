use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

$repo.checkout(Git::Tree);
