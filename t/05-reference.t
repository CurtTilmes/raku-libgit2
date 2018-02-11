use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open($*PROGRAM.Str, :search), 'open';

ok my $ref = $repo.reference-lookup('refs/heads/master'), 'reference master';

is $ref.is-branch, True, 'is-branch';

is $ref.is-tag, False, 'is-tag';

is $ref.is-note, False, 'is-note';

is $ref.is-remote, False, 'is-remote';

ok $ref = $repo.ref('master'), 'ref master';

is $ref.is-branch, True, 'is-branch';

ok (my @list = $repo.reference-list()), 'reference-list';

.name.say for $repo.references;

.short.say for $repo.references;
