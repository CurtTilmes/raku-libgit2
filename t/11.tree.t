use Test;
use File::Temp;
use LibGit2;

my $test-repo-dir = '/tmp/mine'; # tempdir;

diag "Test Repo $test-repo-dir";

ok my $repo = Git::Repository.open($test-repo-dir), 'open';

my $tree = $repo.revparse-single('HEAD^{tree}');

say $tree;

#my $commit = $repo.lookup('f213e199f06e017f5c0f77cb95a5e7656d0a59ec');
#my $tree = $commit.tree;

#my $tree = $repo.lookup('63f62cea33f976ea666c7c5679b36ff5ca9ceec8');

#my $tree = $repo.lookup(Git::Oid.new('2195527d5ae4c2607be69e58292a641a979cddea'));

#say $tree.entrycount;

#for 0..^$tree.entrycount
#{
#    my $entry = $tree.entry-byindex($_);
#
#    say $entry;
#    say $repo.object($entry).id;
#}

my $channel = $tree.walk;

say "listing channel";

for $channel.list -> ($root, $entry)
{
    say "$root$entry.name()" if $entry.type == GIT_OBJ_BLOB
}
