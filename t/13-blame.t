use Test;
use LibGit2;

ok my $repo = Git::Repository.open('/tmp/mine'), 'open';

my $blame = $repo.blame-file('afile');

say $blame;

say $blame.hunk-count;

my $hunk = $blame.hunk(0);

say $hunk.lines-in-hunk;
say $hunk.final_commit_id;
say $hunk.final_start_line_number;
say $hunk.final_signature;
say $hunk.orig_commit_id;
say $hunk.orig_path;
say $hunk.orig_start_line_number;
say $hunk.orig_signature;
say $hunk.boundary;

$hunk = $blame.hunk(1);

say $hunk.lines-in-hunk;
say $hunk.final_commit_id;
say $hunk.final_start_line_number;
say $hunk.final_signature;
say $hunk.orig_commit_id;
say $hunk.orig_path;
say $hunk.orig_start_line_number;
say $hunk.orig_signature;
say $hunk.boundary;

$hunk = $blame.line(2);

say $hunk.lines-in-hunk;
say $hunk.final_commit_id;
say $hunk.final_start_line_number;
say $hunk.final_signature;
say $hunk.orig_commit_id;
say $hunk.orig_path;
say $hunk.orig_start_line_number;
say $hunk.orig_signature;
say $hunk.boundary;
