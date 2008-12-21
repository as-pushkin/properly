use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XMLConstructor',
    AUTHOR              => 'Andrei Protasovitski <andrei.protasovitski@gmail.com>',
    VERSION_FROM        => 'lib/XMLConstructor.pm',
    ABSTRACT_FROM       => 'lib/XMLConstructor.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XMLConstructor-*' },
);
