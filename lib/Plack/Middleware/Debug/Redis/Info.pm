package Plack::Middleware::Debug::Redis::Info;

use strict;
use warnings;
use v5.10.1;
use Redis 1.955;
use parent 'Plack::Middleware::Debug::Base';
use Plack::Util::Accessor qw/server password redis_handle/;

our $VERSION = '0.01';

sub prepare_app {
    my $self = shift;

    $self->server('localhost:6379') unless defined $self->server;

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

    $panel->title('Redis::Info');
    $panel->nav_title($panel->title);

    my $info = $self->redis_handle->info;

    # tweak db keys
    foreach my $db (grep { /^db\d{1,2}/ } keys %$info) {
        my $flatten = $self->flatten_db($db, $info->{$db});
        my @keys_flatten = keys %$flatten;
        @$info{@keys_flatten} = @$flatten{@keys_flatten};
        delete $info->{$db};
    }

    $panel->nav_subtitle('Version: ' . $info->{redis_version});

    return sub {
        $panel->content($self->render_hash($info));
    };
}

sub flatten_db {
    my ($self, $database, $value) = @_;

    my %flatten = ();

    %flatten = map {
        my @ary = split /=/;
        $database . '_' . $ary[0] => $ary[1];
    } split /,/, $value;

    \%flatten;
}


1; # End of Plack::Middleware::Debug::Redis::Info
__END__

=pod

=head1 NAME

Plack::Middleware::Debug::Redis::Info - Redis info debug panel

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    # inside your psgi app
    enable 'Debug',
        panels => [
            [ 'Redis::Info', server => 'redis.example.com:6379' ],
        ];

=head1 DESCRIPTION

Plack::Middleware::Debug::Redis::Info extends Plack::Middleware::Debug by adding redis server info debug panel.
Panel displays data which available through INFO command issued in redis-cli. Before displaying info some tweaks
were processed. Normally INFO command shows total and expires keys in one line such as

    db0 => 'keys=167,expires=145',
    db1 => 'keys=75,expires=0',

This module turn in to

    db0_expires => '145',
    db0_keys    => '167',
    db1_expires => '0',
    db1_keys    => '75',

=head1 METHODS

=head2 prepare_app

See L<Plack::Middleware::Debug>

=head2 run

See L<Plack::Middleware::Debug>

=head2 server

Hostname and port of redis server instance. Default value is 'localhost:6379'.

=head2 password

Password to authenticate on redis server instance in case of enabled redis' option B<requirepass>.

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
