#
# This file is part of Dancer-Plugin-Redis
#
# This software is copyright (c) 2011 by celogeek <me@celogeek.com>.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package FakeRedis;

use strict;
use warnings;
{

    package Redis;
    $INC{'Redis.pm'} = 1;
    our $VERSION = 2;
    our $AUTOLOAD;

    # faked 'INFO'
    my $INFO = {
        'redis_version'     => '0.1.99',
        'db0'               => 'keys=167,expires=145',
        'db1'               => 'keys=75,expires=0',
        'uptime_in_seconds' => '1591647',
        'role'              => 'master',
    };

    # faked 'KEYS'
    my $KEYS = {
        # STRING
        'coy:knows:pseudonoise:codes'       => [ 'string', 9000 ],
        # LIST
        'six:slimy:snails:sailed:silently'  => [ 'list', 35 ],
        # HASH
        'eleven:benevolent:elephants'       => [ 'hash', 17 ],
        # SET
        'two:tried:and:true:tridents'       => [ 'set', 101 ],
        # ZSET
        'tie:twine:to:three:tree:twigs'     => [ 'zset', 66 ],
    };

    sub new {
        my ( $class, %args ) = @_;
        bless \%args => $class;
    }

    sub keys {
        keys %$KEYS;
    }

    sub type {
        exists $KEYS->{$_[1]} ? $KEYS->{$_[1]}->[0] : undef;
    }

    sub info {
        $INFO;
    }

    sub _generic_len {
        exists $KEYS->{$_[1]} ? $KEYS->{$_[1]}->[1] : undef;
    }

    *strlen = *_generic_len;
    *hlen   = *_generic_len;
    *llen   = *_generic_len;
    *scard  = *_generic_len;
    *zcard  = *_generic_len;

    sub AUTOLOAD {
        shift;
        my $name = $AUTOLOAD;
        $name =~ s/.*://;
        return $name, @_;
    }
}

1;
