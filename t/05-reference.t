use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open-ext($*PROGRAM.Str), 'open';

ok my $ref = $repo.reference-lookup('refs/heads/master'), 'reference master';

is $ref.is-branch, True, 'is-branch';

is $ref.is-tag, False, 'is-tag';

is $ref.is-note, False, 'is-note';

is $ref.is-remote, False, 'is-remote';

ok $ref = $repo.ref('master'), 'ref master';

is $ref.is-branch, True, 'is-branch';

ok (my @list = $repo.reference-list()), 'reference-list';

like 'refs/tags/0.1', /@list/, 'tag 0.1 in reference list';

like 'refs/heads/master', /@list/, 'master head in reference list';
