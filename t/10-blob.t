use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = tempdir;

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.init($test-repo-dir), 'init';

subtest 'Memory',
{
    plan 7;

    ok my $oid = $repo.blob-create('Add this blob'), 'blob create';

    is $oid, '965fbc02b226a75edf239af95a0a9f0e4755e37e', 'oid';

    ok my $blob = $repo.blob-lookup($oid), 'blob lookup';

    is $blob.is-binary, False, 'is not binary';

    is $blob.id, '965fbc02b226a75edf239af95a0a9f0e4755e37e', 'blob id';

    is $blob.rawsize, 13, 'rawsize';

    is $blob.content.decode, 'Add this blob', 'content';
}

subtest 'File',
{
    my $file = $test-repo-dir.IO.add('afile');

    $file.spurt("This is a blob on disk.\n");

    ok my $oid = $repo.blob-create($file), 'blob create';

    is ~$oid, 'c2af2b49e1503768ae922897b6cd5e47e3097977', 'oid';

    ok my $blob = $repo.blob-lookup($oid), 'blob lookup';

    is $blob.is-binary, False, 'is not binary';

    is $blob.id, 'c2af2b49e1503768ae922897b6cd5e47e3097977', 'blob id';

    is $blob.rawsize, 24, 'rawsize';

    is $blob.content.decode, "This is a blob on disk.\n", 'content';
}
