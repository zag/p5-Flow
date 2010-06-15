use Module::Build;
use 5.8.0;
Module::Build->new
    ( module_name => 'Flow',
    dist_version_from=>'lib/Flow.pm',
    license => 'perl',
    prereq =>{
	JSON=>0,
	XML::Flow=>0,
    },
    dist_author=>'Zahatski Aliaksandr zag@cpan.org',
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
