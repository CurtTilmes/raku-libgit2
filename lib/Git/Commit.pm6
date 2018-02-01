use NativeCall;
use Git::Signature;
use Git::Buffer;
use Git::Error;

class Git::Commit is repr('CPointer')
{
    sub git_commit_free(Git::Commit)
        is native('git2') {}

    sub git_commit_header_field(Git::Buffer, Git::Commit, Str --> int32)
        is native('git2') {}

    method author(--> Git::Signature)
        is native('git2') is symbol('git_commit_author') {}

    method body(--> Str)
        is native('git2') is symbol('git_commit_body') {}

    method committer(--> Git::Signature)
        is native('git2') is symbol('git_commit_committer') {}

    method header(Str $field --> Str)
    {
        my Git::Buffer $buf .= new;
        check(git_commit_header_field($buf, self, $field));
        $buf.str
    }

    submethod DESTROY { git_commit_free(self) }
}
