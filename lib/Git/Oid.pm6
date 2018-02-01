use NativeCall;
use Git::Error;

constant \GIT_OID_RAWSZ := 20;
constant \GIT_OID_HEXSZ := GIT_OID_RAWSZ * 2;

class Git::Oid is repr('CPointer')
{
    sub oid-alloc(size_t, size_t --> Git::Oid) is native is symbol('calloc') {}
    sub oid-free(Git::Oid) is native is symbol('free') {}

    sub git_oid_iszero(Git::Oid --> int32)
        is native('git2') {}

    sub git_oid_fromstr(Git::Oid, Str --> int32)
        is native('git2') {}

    sub git_oid_cpy(Git::Oid, Pointer)
        is native('git2') {}

    multi method new(--> Git::Oid) { oid-alloc(GIT_OID_RAWSZ, 1) }

    multi method new(Str $str --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        check(git_oid_fromstr($oid, $str));
        $oid
    }

    multi method new(Pointer $ptr --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        git_oid_cpy($oid, $ptr);
        $oid
    }

    submethod DESTROY { oid-free(self) }

    method is-zero { git_oid_iszero(self) == 1 }

    method Str(--> Str)
        is native('git2') is symbol('git_oid_tostr_s') {}
}

