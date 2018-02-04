use NativeCall;

class Git::Channel
{
    my %channels;
    my int64 $i = 0;
    my $lock = Lock.new;

    method id
    {
        my $channel = Channel.new;
        my int64 $id;
        $lock.protect: { %channels{$index = $i++} = $channel }
        $id
    }

    method channel(int64 $id)
    {
        %channels{$id}
    }

    method done(int64 $id)
    {
        $.channel.close;
        $lock.protect: { %channels{$id}:delete }
    }
}
