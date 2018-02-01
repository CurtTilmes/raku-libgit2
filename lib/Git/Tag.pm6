use NativeCall;
use Git::Oid;
use Git::Object;

class Git::Tag is repr('CPointer') does Git::Objectish
{
    submethod DESTROY { self.free }
}
