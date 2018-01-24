use NativeCall;
use Git::Error;
use Git::Checkout;

enum Git::Clone::Local <
    GIT_CLONE_LOCAL_AUTO
    GIT_CLONE_LOCAL
    GIT_CLONE_NO_LOCAL
    GIT_CLONE_LOCAL_NOLINKS
>;

class Git::Clone::Options is repr('CStruct')
{
    uint32 $.version;
    HAS Git::Checkout::Options $.checkout-opts;

    submethod BUILD
    {
        $!version = 1;
    }
}

