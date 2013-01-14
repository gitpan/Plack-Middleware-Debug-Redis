use strict;
use warnings;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More;
use Test::MockObject;

my $INFO = {
    'redis_version'     => '0.1.99',
    'db0'               => 'keys=167,expires=145',
    'db1'               => 'keys=75,expires=0',
    'uptime_in_seconds' => '1591647',
    'role'              => 'master',
};

my $fakeredis = Test::MockObject->new;
Test::MockObject->fake_module('Redis', new => sub { $fakeredis }, VERSION => sub { '1.955' });
$fakeredis->set_true('select', 'quit', 'ping');
$fakeredis->mock('info', sub { $INFO });

{
    my $app = builder {
        enable 'Debug',
            panels => [
                [ 'Redis::Info', server => 'localhost:6379' ],
            ];
        sub {
            [
                200,
                [ 'Content-Type' => 'text/html' ],
                [ '<html><body>OK</body></html>' ]
            ];
        };
    };

    test_psgi $app, sub {
        my ($cb) = @_;

        my $res = $cb->(GET '/');
        is $res->code, 200, 'Redis-Info: response code 200';

        like $res->content,
            qr|<a href="#" title="Redis::Info" class="plDebugInfo\d+Panel">|m,
            'Redis-Info: panel found';

        like $res->content,
            qr|<small>Version: \d\.\d{1,2}\.\d{1,2}</small>|,
            'Redis-Info: subtitle points to redis version';

        like $res->content,
            qr|<td>db0_expires</td>[.\s\n\r]*<td>145</td>|m,
            'Redis-Info: 145 expires keys in db0';

        like $res->content,
            qr|<td>db0_keys</td>[.\s\n\r]*<td>167</td>|m,
            'Redis-Info: 167 total keys in db0';

        like $res->content,
            qr|<td>db1_expires</td>[.\s\n\r]*<td>0</td>|m,
            'Redis-Info: 0 expires keys in db1';

        like $res->content,
            qr|<td>db1_keys</td>[.\s\n\r]*<td>75</td>|m,
            'Redis-Info: 75 total keys in db1';

        like $res->content,
            qr|<td>redis_version</td>[.\s\n\r]*<td>\d\.\d{1,2}\.\d{1,2}</td>|m,
            'Redis-Info: Redis version presented';

        like $res->content,
            qr|<td>uptime_in_seconds</td>[.\s\n\r]*<td>1591647</td>|m,
            'Redis-Info: server uptime match';

        like $res->content,
            qr|<td>role</td>[.\s\n\r]*<td>master</td>|m,
            'Redis-Info: server role match';
    };
}

done_testing();
