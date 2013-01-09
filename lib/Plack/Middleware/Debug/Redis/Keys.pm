package Plack::Middleware::Debug::Redis::Keys;

use strict;
use warnings;
use v5.10.1;
use Redis 1.955;
use parent 'Plack::Middleware::Debug::Base';
use Plack::Util::Accessor qw/server password db redis_handle/;

our $VERSION = '0.01';

sub prepare_app {
    my $self = shift;

    $self->server('localhost:6379') unless defined $self->server;
    $self->db(0) unless defined $self->db;

    my @opts = (
        server    => $self->server,
        reconnect => 60,
        encoding  => undef,
        debug     => 0,
    );
    push @opts, (password => $self->password) if $self->password;

    $self->redis_handle(Redis->new(@opts));
}

sub run {
    my ($self, $env, $panel) = @_;

    $panel->title('Redis::Keys');
    $panel->nav_title($panel->title);

    return sub {
        my ($res) = @_;

        my ($keyz, $ktype, $klen);
        $self->redis_handle->select($self->db);
        my @keys = $self->redis_handle->keys('*');
        $panel->nav_subtitle('DB #' . $self->db . ' (' . scalar(@keys) . ')');

        for my $key (sort @keys) {
            $ktype = uc($self->redis_handle->type($key));

            given ($ktype) {
                when ('HASH')   { $klen = $self->redis_handle->hlen($key);   }
                when ('LIST')   { $klen = $self->redis_handle->llen($key);   }
                when ('STRING') { $klen = $self->redis_handle->strlen($key); }
                when ('ZSET')   { $klen = $self->redis_handle->zcard($key);  }
                when ('SET')    { $klen = $self->redis_handle->scard($key);  }
                default         { $klen = undef;                }
            }

            $keyz->{$key} = $ktype . ($klen ? ' (' . $klen . ')' : '');
        }

        $self->redis_handle->quit;
        $panel->content($self->render_hash($keyz));
    };
}

1; # End of Plack::Middleware::Debug::Redis::Keys
__END__

=pod

=head1 NAME

Plack::Middleware::Debug::Redis::Keys - Redis keys debug panel

=head1 SYNOPSIS

    # inside your psgi app
    enable 'Debug',
        panels => [
            [ 'Redis::Keys', server => 'redis.example.com:6379', db => 3 ],
        ];

=head1 DESCRIPTION

Plack::Middleware::Debug::Redis::Keys extends Plack::Middleware::Debug by adding redis server keys debug panel.
Panel displays available keys in the redis database and its type.

    coy:knows:pseudonoise:codes             STRING (9000)
    six:slimy:snails:sailed:silently        LIST (35)
    eleven:benevolent:elephants             HASH (17)
    two:tried:and:true:tridents             SET (101)
    tie:twine:to:three:tree:twigs           ZSET (66)

Also in brackets displays key-type specific data. For I<STRING> keys it's key length in bytes; for I<HASH> - number of fields
in a hash; for I<LIST> - length of a list (number of items); for I<SET> and I<ZSET> - number of members in a set.

This panel might be added several times for different databases. Just add it again to Plack Debug panels and provide another
database number.

=head1 METHODS

=head2 prepare_app

See L<Plack::Middleware::Debug>

=head2 run

See L<Plack::Middleware::Debug>

=head2 server

Hostname and port of redis server instance. Default value is 'localhost:6379'.

=head2 password

Password to authenticate on redis server instance in case of enabled redis' option B<requirepass>.

=head2 db

Redis database number to get statistic for keys. Default value is 0.

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/Wu-Wu/Plack-Middleware-Debug-Redis/issues>

=head1 SEE ALSO

L<Plack::Middleware::Debug>

L<Redis>

=head1 AUTHOR

Anton Gerasimov, E<lt>chim@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Anton Gerasimov

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
