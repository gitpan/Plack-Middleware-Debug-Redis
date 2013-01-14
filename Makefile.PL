use v5.10.1;
use ExtUtils::MakeMaker;

my $meta_merge = {
    META_MERGE => {
        resources => {
            repository => 'https://github.com/Wu-Wu/Plack-Middleware-Debug-Redis',
            bugtracker => 'https://github.com/Wu-Wu/Plack-Middleware-Debug-Redis/issues',
        },
    }
};

my %options = (
    'NAME'          => 'Plack::Middleware::Debug::Redis',
    'VERSION_FROM'  => 'lib/Plack/Middleware/Debug/Redis.pm',
    'AUTHOR'        => 'Anton Gerasimov <chim@cpan.org>',
    'ABSTRACT_FROM' => 'lib/Plack/Middleware/Debug/Redis.pm',
    'LICENSE'       => 'perl',
    'PREREQ_PM'     => {
        'Redis'                    => '1.955',
        'Plack'                    => '0.9979',
        'Plack::Middleware::Debug' => 0,
        'strict'                   => 0,
    },
    'BUILD_REQUIRES' => {
        'Test::More'       => '0.98',
        'Test::Pod'        => '1.22',
        'Plack'            => '0.9979',
        'HTTP::Message'    => 0,
        'Test::MockObject' => 0,
    },
    'MIN_PERL_VERSION' => '5.10.1',
    'test' => {
        'TESTS' => 't/*.t',
    },
    'clean' => {
        'FILES' => '*.tar.gz',
    },
    $ExtUtils::MakeMaker::VERSION >= 6.50 ? (%$meta_merge) : (),
);

WriteMakefile(%options);
