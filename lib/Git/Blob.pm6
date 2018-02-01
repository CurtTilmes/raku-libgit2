use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Object;

class Git::Blob is repr('CPointer') does Git::Objectish
{
    sub git_blob_is_binary(Git::Blob --> int32)
        is native('git2') {}

    sub git_blob_id(Git::Blob --> Pointer)
        is native('git2') {}

    sub git_blob_owner(Git::Blob --> Pointer)
        is native('git2') {}

    sub git_blob_rawcontent(Git::Blob --> CArray[uint8])
        is native('git2') {}

    method rawsize(--> int64)
        is native('git2') is symbol('git_blob_rawsize') {}

    method is-binary { git_blob_is_binary(self) == 1 }

    method content
    {
        my $array = git_blob_rawcontent(self);
        buf8.new($array[0..^$.rawsize])
    }

    submethod DESTROY { self.free }
}
