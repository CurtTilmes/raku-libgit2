use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = '/tmp/mine'; #tempdir;

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.init($test-repo-dir), 'init';

my $commit = $repo.commit-lookup(Git::Oid.new('09b0f95e3618ccb1284adbf4a210afc6d849c8c8'));

#my $ref = $repo.reference('refs/heads/abranch');
#my $ref = $repo.branch-create('abranch', $commit);

my $ref = $repo.branch-lookup('mybranch');

say $ref.is-head;
say $ref.is-branch;

say $ref.branch-name;

#$ref.branch-delete;

#for $repo.branch-list -> $r
#{
#    say $r.branch-name;
#}

say $ref.branch-upstream;

#$ref.branch-set-upstream();
