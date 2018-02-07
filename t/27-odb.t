use Test;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $odb = $repo.odb;

is Git::Odb.hash('this', GIT_OBJ_BLOB),
    'a2a3f4f1e30c488bfbd52aabfbcfcc1f5822158d', 'hash';

#dd $odb.read-header('9fb51ba4ffc485ee6577bd96ffd77c3ea30bb27e');

#for $odb.objects.list
#{
#    say $odb.read($_)
#}


my $object = $odb.read('06b5df928b45bbeacf9dbfb38f4bd2cba0b385bc');
