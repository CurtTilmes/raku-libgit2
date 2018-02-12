use Test;
use Test::When <online>;
use File::Temp;
use LibGit2;

plan 11;

my $remote-url = 'https://github.com/CurtTilmes/test-repo.git';

my $repodir = tempdir;

ok my $repo = Git::Repository.clone($remote-url, $repodir), 'clone';

isa-ok my $remote = $repo.remote-lookup('origin'),
    'Git::Remote', 'remote-lookup';

is $remote.name, 'origin', 'name';

is $remote.url, $remote-url, 'url';

isa-ok $remote.autotag, Git::Remote::Autotag::Option, 'autotag';

lives-ok { $remote.connect(dir => 'fetch') }, 'remote connect';

is $remote.connected, True, 'connected';

is $remote.default-branch, 'refs/heads/master', 'default-branch';

is set($remote.ls».name), set(<HEAD refs/heads/master>), 'remote ls';

lives-ok { $remote.disconnect }, 'remote disconnect';

is $remote.connected, False, 'disconnected';

