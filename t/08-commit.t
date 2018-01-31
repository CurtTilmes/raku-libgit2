use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open-ext($*PROGRAM.Str), 'open';

my $tag = $repo.tag
