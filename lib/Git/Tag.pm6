use NativeCall;
use Git::Oid;

class Git::Tag is repr('CPointer')
{
    sub git_tag_free(Git::Tag)
        is native('git2') {}

    method id(--> Git::Oid)
        is native('git2') is symbol('git_tag_id') {}

    submethod DESTROY { git_tag_free(self) }
}
