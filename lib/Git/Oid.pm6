use NativeCall;
use Git::Error;

constant \GIT_OID_RAWSZ := 20;
constant \GIT_OID_HEXSZ := GIT_OID_RAWSZ * 2;

class Git::Oid is repr('CStruct')
{
    has uint8 $.b0;
    has uint8 $.b1;
    has uint8 $.b2;
    has uint8 $.b3;
    has uint8 $.b4;
    has uint8 $.b5;
    has uint8 $.b6;
    has uint8 $.b7;
    has uint8 $.b8;
    has uint8 $.b9;
    has uint8 $.b10;
    has uint8 $.b11;
    has uint8 $.b12;
    has uint8 $.b13;
    has uint8 $.b14;
    has uint8 $.b15;
    has uint8 $.b16;
    has uint8 $.b17;
    has uint8 $.b18;
    has uint8 $.b19;

    method Str(--> Str)
        is native('git2') is symbol('git_oid_tostr_s') {}
}

