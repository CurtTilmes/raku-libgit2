use Test;
use File::Temp;
use LibGit2;

ok my $repo = Git::Repository.open-ext($*PROGRAM.Str), 'open';

ok (my @tag-list = $repo.tag-list), 'tag list';

like '0.1', /@tag-list/, 'tag 0.1 in tag list';

ok (@tag-list = $repo.tag-list('0*')), 'tag list match';

like '0.1', /@tag-list/, 'tag 0.1 in tag list';
