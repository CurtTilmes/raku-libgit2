use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

my $index = $repo.index;

say $index.entrycount;

my $entry = $index.get-byindex(0);

say "here";

say $entry;

exit;

subtest 'Memory', {

    ok my $index = Git::Index.new, 'new';

    ok $index.version, 'version';

    lives-ok { $index.set-version(3) }, 'set-version';

    is $index.checksum, '0000000000000000000000000000000000000000', 'checksum';

    is $index.entrycount, 0, 'entrycount';

    throws-like { $index.read }, X::Git, 'Read in-memory fails',
        code => GIT_ERROR, message => /:s index is in'-'memory only/;

    throws-like { $index.write }, X::Git, 'Write in-memory fails',
        code => GIT_ERROR, message => /:s index is in'-'memory only/;
}

subtest 'Repo', {
    ok my $index = $repo.index, 'index';

    say $index.entrycount;

    say $index.get-byindex(0);

    lives-ok { $index.read }, 'read';

    lives-ok { $index.write }, 'read';
}

subtest 'By File', {
    ok my $index = Git::Index.open('/tmp/mine/.git/index'), 'open';

    lives-ok { $index.read }, 'read';

    lives-ok { $index.write }, 'read';

}

