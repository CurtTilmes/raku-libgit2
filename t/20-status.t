use Test;
use LibGit2;

my $repo = Git::Repository.open('/tmp/mine');

#my $status = $repo.status-list;

#for $status[^$status.elems]
#{
#    .status.say;
#    .say;
#}

say $repo.status-file('subdir/thisfile').is-current;

#for $repo.status-each
#{
#    .say
#}
