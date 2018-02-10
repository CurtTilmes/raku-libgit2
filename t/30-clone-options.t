use Test;
use LibGit2;

use NativeCall;

say nativesizeof(Git::Clone::Options);

my $options = Git::Clone::Options.new(tags => 'unspecified');

say $options;
