use Test;
use File::Temp;
use LibGit2;

my $testdir = tempdir;
Git::Repository.init($testdir);

isa-ok my $repo = Git::Repository.open($testdir), Git::Repository, 'open';

is $repo.is-empty, True, 'is empty';

is $repo.is-bare, False, 'is not bare';

is $repo.is-shallow, False, 'is shallow';

isa-ok $repo = Git::Repository.open($testdir.IO.child('.git').Str, :bare),
    Git::Repository, 'open bare';

is $repo.is-bare, True, 'is bare';

