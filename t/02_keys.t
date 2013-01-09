use strict;
use warnings;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More;
use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use FakeRedis;

{
    my $app = builder {
        enable 'Debug',
            panels => [
                [ 'Redis::Keys', server => 'localhost:6379', db => 0 ],
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
        is $res->code, 200, 'Redis-Keys: response code 200';

        like $res->content,
            qr|<a href="#" title="Redis::Keys" class="plDebugKeys\d+Panel">|,
            'Redis-Keys: panel found';

        like $res->content,
            qr|<small>DB #0 \(5\)</small>|,
            'Redis-Keys: subtitle points to 5 keys in database 0';

        like $res->content,
            qr|<td>coy:knows:pseudonoise:codes</td>[.\s\n\r]*<td>STRING \(9000\)</td>|m,
            'Redis-Keys: has string key (9000 bytes)';

        like $res->content,
            qr|<td>six:slimy:snails:sailed:silently</td>[.\s\n\r]*<td>LIST \(35\)</td>|m,
            'Redis-Keys: has list key (35 elements)';

        like $res->content,
            qr|<td>eleven:benevolent:elephants</td>[.\s\n\r]*<td>HASH \(17\)</td>|m,
            'Redis-Keys: has hash key (17 fields)';

        like $res->content,
            qr|<td>two:tried:and:true:tridents</td>[.\s\n\r]*<td>SET \(101\)</td>|m,
            'Redis-Keys: has set key (101 members)';

        like $res->content,
            qr|<td>tie:twine:to:three:tree:twigs</td>[.\s\n\r]*<td>ZSET \(66\)</td>|m,
            'Redis-Keys: has sorted set key (66 members)';
    };

}

done_testing();
