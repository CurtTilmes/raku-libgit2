use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

plan 5;

is $repo.is-ignored('foo.c'), False, 'foo.c not ignored';

lives-ok { $repo.ignore-add('*.c') }, 'ignore-add *.c';

is $repo.is-ignored('foo.c'), True, 'foo.c now ignored';

lives-ok { $repo.ignore-clear }, 'clear ignore';

is $repo.is-ignored('foo.c'), False, 'Not ignored';

