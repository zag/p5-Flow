use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Flow',
    VERSION_FROM => 'lib/Flow.pm', # finds $VERSION
    ABSTRACT     => '',
    PREREQ_PM    => {
                     'Test::More' => 0.45,
                    },
);
