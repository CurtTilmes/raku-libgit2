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

class Git::Object is repr('CPointer')
{
    sub git_object_free(Git::Object)
        is native('git2') {}

    method id(--> GID::Oid)
        is native('git2') is symbol('git_object_id') {}

    sub git_object_type(Git::Object --> int32)
        is native('git2') {}

    method type(--> Git::Type) { Git::Type(git_object_type(self)) }

    submethod DESTROY { git_object_free(self) }
}
