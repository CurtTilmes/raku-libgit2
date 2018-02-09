use Test;
use LibGit2;

LibGit2.trace('trace');

my $repo = Git::Repository.init('/tmp/foo');

say $repo;
