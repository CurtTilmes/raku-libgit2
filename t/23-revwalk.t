use Test;
use LibGit2;
use Git::Oid;

my $repo = Git::Repository.open('/tmp/mine');

.say for $repo.revwalk.sorting(:time)
    .walk(push => 'HEAD', :simplify-first-parent)
