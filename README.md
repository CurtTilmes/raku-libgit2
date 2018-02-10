LibGit2 -- Direct access to Git via libgit2 library
===================================================

This module provides Perl 6 access to [libgit2](https://libgit2.github.com/)

That library must be installed, and this module will be subject to the
features enabled during the build/install of that library.

This module is **EXPERIMENTAL**.  In particular, I'm still trying to refine
the Perl 6 API to be as friendly as possible, and also as Perl-ish as
possible.  I've converted some callbacks into Channels, and some options
into :pairs, etc.  If you see anything that could be done better, PLEASE
raise an issue.

There are also still some unimplemented corners, so if you see anything
you can't do, raise an issue and we can try to add more libgit2 bindings.

For now, there are also some 64-bit assumptions.  If there is demand for
a 32-bit version, there are ways to adapt it I can work with someone who
wants to tackle that.  It also doesn't currently support Windows, but
could probably do so if someone wants to port it.  Patches welcome!

Global Initialization
---------------------

Always start with `use LibGit2` rather than using individual `Git::*`
modules.  That pulls in the rest of the modules, and also initializes
the library as a whole.

Query some global information about the library:

    use LibGit2;
    say LibGit2.version;
    say LibGit2.features;

    0.26.0
    (GIT_FEATURE_NSEC GIT_FEATURE_SSH GIT_FEATURE_HTTPS GIT_FEATURE_THREADS)

Tracing
-------

If libgit2 is compiled with tracing support, you can enable that tracing
from Perl6.

    LibGit2.trace('debug');  # none,fatal,error,warn,info,debug,trace

The default trace callback just prints the message and its level to
STDOUT.  You can also supply a callback:

    use NativeCall;
    sub my-trace($level, $message) { say "$level $message" }

    LibGit2.trace('info', &my-trace);

Init
----

    my $repo = Git::Repository.init('/my/dir');

    my $repo = Git::Repository.init('/my/dir', :bare);

    my $repo = Git::Repository.init('/my/dir', :mkpath,
    description => 'my description', ...);

See C<Git::Repository::InitOptions> for the complete init option list.

Clone
-----

    my $repo = Git::Repository.clone('https://github.com/...', '/my/dir');

    my $repo = Git::Repository.clone('https://github.com/...', '/my/dir', :bare);

See C<Git::Clone::Options> for the complete clone option list.

Open
----

    my $repo = Git::Repository.open('/my/dir');

    my $repo = Git::Repository.open('/my/dir', :bare);

    my $repo = Git::Repository.open('/my/dir/some/subdir', :search);

See C<Git::Repository::OpenOptions> for the complete open options list.

Config
------

From a `Git::Repository`, you can use the `.config` method to access
configuration information.

    my $config = $repo.config;


