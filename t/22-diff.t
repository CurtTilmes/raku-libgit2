use Test;
use File::Temp;
use LibGit2;

plan 15;

my $testdir = tempdir;

isa-ok my $repo = Git::Repository.init($testdir), Git::Repository, 'init';

$repo.commit(:root, message => 'Initial root commit');

for <a b c>
{
    $testdir.IO.child("{$_}file").spurt("This is some content for file $_.\n");
}

$repo.index.add-bypath('afile').write;

isa-ok my $diff = $repo.diff-tree-to-index,
	Git::Diff, 'diff-index-to-workdir';

is $diff.elems, 1, '1 file added';

ok my $patches = $diff.patches, 'patches';

is $patches.elems, 1, '1 patch';

isa-ok my $patch = $diff.patch(0), Git::Patch, 'first patch';

is $patch, q:to/PATCH/, 'patch content';
	diff --git a/afile b/afile
	new file mode 100644
	index 0000000..5966fc3
	--- /dev/null
	+++ b/afile
	@@ -0,0 +1 @@
	+This is some content for file a.
	PATCH

isa-ok my $delta = $diff.delta(0), Git::Diff::Delta, 'delta';

is $delta.status, 'GIT_DELTA_ADDED', 'status';

is $delta.old-file, Git::Diff::File, 'no old file';
with $delta.new-file
{
    is .id, '5966fc318ca68de951b63a9db21a4c1e07afa1ae', 'id';
    is .path, 'afile', 'path';
    is .size, 33, 'size';
}

isa-ok $diff = $repo.diff-tree-to-workdir-with-index(:include-untracked),
	Git::Diff, 'diff-tree-to-workdir-with-index';

is $diff.elems, 3, '3 files';

