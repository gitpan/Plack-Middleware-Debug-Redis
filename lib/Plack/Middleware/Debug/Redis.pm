package Plack::Middleware::Debug::Redis;

use strict;
use warnings;

our $VERSION = '0.01';


1; # End of Plack::Middleware::Debug::Redis
__END__

=head1 NAME

Plack::Middleware::Debug::Redis - Extend Plack::Middleware::Debug with Redis panels

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    # inside your psgi app
    use Plack::Builder;

    my $app = sub {[
        200,
        [ 'Content-Type' => 'text/html' ],
        [ '<html><body>OK</body></html>' ]
    ]};
    my $redis_host = 'redi.example.com:6379';

    builder {
        mount '/' => builder {
            enable 'Debug',
                panels => [
                    [ 'Redis::Info', server => $redis_host ],
                    [ 'Redis::Keys', server => $redis_host, db => 3 ],
                ];
            $app;
        };
    };

=head1 DESCRIPTION

This distribution extends Plack::Middleware::Debug with some Redis panels. At the moment, the following panels
available:

=head1 PANELS

=head2 Redis::Info

Diplay panel with generic Redis server information which is available by the command INFO.
See L<Plack::Middleware::Debug::Redis::Info> for additional information.

=head2 Redis::Keys

Diplay panel with keys Redis server information. See L<Plack::Middleware::Debug::Redis::Keys>
for additional information.

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/Wu-Wu/Plack-Middleware-Debug-Redis/issues>

=head1 SEE ALSO

L<Plack::Middleware::Debug::Redis::Info>

L<Plack::Middleware::Debug::Redis::Keys>

L<Plack::Middleware::Debug>

L<Redis>

=head1 AUTHOR

Anton Gerasimov, E<lt>chim@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Anton Gerasimov

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
