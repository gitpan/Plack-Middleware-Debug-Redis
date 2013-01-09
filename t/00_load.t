use strict;
use Test::More tests => 3;

BEGIN {
    use_ok('Plack::Middleware::Debug::Redis');
    use_ok('Plack::Middleware::Debug::Redis::Info');
    use_ok('Plack::Middleware::Debug::Redis::Keys');
};
