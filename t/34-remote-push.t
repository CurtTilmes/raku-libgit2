use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

my $remote-url = 'git@github.com:CurtTilmes/test-push.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote-url, $repodir,
    foo => 'bar'), 'clone';

shell "tree -a $repodir";
