use NativeCall;
use Git::Error;

constant \GIT_OID_RAWSZ := 20;
constant \GIT_OID_HEXSZ := GIT_OID_RAWSZ * 2;

class Git::Oid is repr('CStruct')
{
    has int64 $.b0;
    has int64 $.b1;
    has int32 $.b2;

    sub git_oid_iszero(Git::Oid --> int32)
        is native('git2') {}

    sub git_oid_fromstr(Git::Oid, Str --> int32)
        is native('git2') {}

    sub git_oid_cpy(Git::Oid, Pointer)
        is native('git2') {}

    multi method new(Str:D $str --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        check(git_oid_fromstr($oid, $str));
        $oid
    }

    multi method new(Pointer:D $ptr --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        git_oid_cpy($oid, $ptr);
        $oid
    }

    method is-zero { git_oid_iszero(self) == 1 }

    method Str(--> Str)
        is native('git2') is symbol('git_oid_tostr_s') {}

    method gist { ~self }
}

