use NativeCall;
use Git::Error;
use Git::Object;

class Git::Tree is repr('CPointer') does Git::Objectish
{
    submethod DESTROY { self.free }
}
