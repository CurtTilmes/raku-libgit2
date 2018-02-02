use Test;
use LibGit2;

my $message = q:to/END/;
This is my message foo
I like it
# comment
ignore the comment
END

say $message;

my $pretty = Git::Message.prettify($message);

say $pretty;
