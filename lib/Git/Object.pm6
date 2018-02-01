use NativeCall;
use Git::Oid;

enum Git::Type (
    GIT_OBJ_ANY       => -2,
    GIT_OBJ_BAD       => -1,
    GIT_OBJ__EXT1     => 0,
    GIT_OBJ_COMMIT    => 1,
    GIT_OBJ_TREE      => 2,
    GIT_OBJ_BLOB      => 3,
    GIT_OBJ_TAG       => 4,
    GIT_OBJ__EXT2     => 5,
    GIT_OBJ_OFS_DELTA => 6,
    GIT_OBJ_REF_DELTA => 7,
);

role Git::Objectish
{
    sub git_object_free(Pointer)
        is native('git2') {}

    method free
    {
        git_object_free(nativecast(Pointer, self))
    }

    sub git_object_id(Pointer --> Git::Oid)
        is native('git2') {}

    method id(--> Git::Oid)
    {
        git_object_id(nativecast(Pointer, self))
    }

    sub git_object_type(Pointer --> int32)
        is native('git2') {}

    method type(--> Git::Type)
    {
        Git::Type(git_object_type(nativecast(Pointer, self)))
    }

    sub git_object_owner(Pointer --> Pointer)
        is native('git2') {}

    method owner
    {
        my $ptr = git_object_owner(nativecast(Pointer, self));
        nativecast(::("Git::Repository"), $ptr)
    }
}

class Git::Object is repr('CPointer') does Git::Objectish
{
    submethod DESTROY { self.free }
}
