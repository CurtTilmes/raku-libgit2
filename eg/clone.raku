#!/usr/bin/env raku

use LibGit2;


my $g = Git::Repository.clone('https://github.com/CurtTilmes/perl6-epoll.git', '/tmp/mine');

say $g;
