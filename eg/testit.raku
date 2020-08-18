#!/usr/bin/env raku

use LibGit2;

say LibGit2.version;
say LibGit2.features;

try my $repo = Git::Repository.init('testing');

if $!
{
    say $!.code;
    exit;
}


say $repo;
