use Test;
use File::Temp;
use LibGit2;

my $remote = 'https://github.com/CurtTilmes/perl6-epoll.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote, $repodir), 'clone';

ok "$repodir/README.md".IO.e, 'README.md present';
ok "$repodir/META6.json".IO.e, 'META6.json present';

done-testing;
