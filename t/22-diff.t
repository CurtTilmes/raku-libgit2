use Test;
use LibGit2;
use Git::Submodule;

my $opts = Git::Diff::Options.new(:indent-heuristic, :context-lines(5)
:interhunk-lines(5), old-prefix => 'old', new-prefix => 'new');

say $opts;
