#===============================================================================
#
#  DESCRIPTION:
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

=head1 NAME

Collection - Collections framework for  B<CRUD> of the data or objects.

=head1 SYNOPSIS

    package MyCollection;
    use Collection;
    @MyCollection::ISA = qw(Collection);

=head1 DESCRIPTION

A collection - sometimes called a container - is simply an object that groups multiple elements into a single unit. I<Collection> are used to store, retrieve, manipulate, and communicate aggregate data.

The primary advantages of a I<Collection> framework are that it reduces programming effort by providing useful data structures and algorithms so you don't have to write them yourself.


The I<Collection> framework consists of:
=cut

package Flow;
use Flow::Code;
use Flow::Splice;
use Flow::To::XML;
use Flow::To::JXML;
use Flow::From::XML;
use Flow::Join;
use Flow::Split;
use strict;
use warnings;

#require Exporter;
use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(create_flow);
our $VERSION = 0.1;
use constant MODS_MAP => {
    Splice  => 'Flow::Splice',
    Join    => 'Flow::Join',
    ToXML   => 'Flow::To::XML',
    Code    => 'Flow::Code',
    FromXML => 'Flow::From::XML',
    Split   => 'Flow::Split',
    ToJXML  => 'Flow::To::JXML'
};

our %tmp_map = %{ (MODS_MAP) };

sub define_event {
    __make_methods($_) for @_;
}

sub __make_methods {
    my $method = shift;
    no strict 'refs';
    my $put_method    = "put_${method}";
    my $pivate_method = "_${method}";
    *{ __PACKAGE__ . "::$method" } = sub {
        my $self = shift;
        return $self->$put_method(@_);
    };
    *{ __PACKAGE__ . "::$put_method" } = sub {
        my $self = shift;
        if ( my $h = $self->__handler ) {
            return $h->$pivate_method(@_);
        }

        #clear return results
        return;
    };

    *{ __PACKAGE__ . "::$pivate_method" } = sub {
        my $self = shift;
        my $res  = $self->$method(@_);

        #ERROR STATE
        return $res unless ref($res);
        if ( ref($res) eq 'ARRAY' ) {
            return $self->$put_method(@$res);
        }
    };
}

define_event( "begin", "flow", "ctl_flow", "end" );

sub import {
    my ($class) = shift;
    __PACKAGE__->export_to_level( 1, $class, 'create_flow' );
    while ( my ( $alias, $module ) = splice @_, 0, 2 ) {
        if ( defined($alias) && defined($module) ) {
            $tmp_map{$alias} = $module;
        }
    }
}

=head1 create_flow "MyFlow::Pack"=>{param1=>$val},$my_flow_object, "MyFlow::Pack1"=>12, "MyFlow::Pack3"=>{}

use last arg as handler for out.

return flow object ref.

    my $h1     = new MyHandler1::;
    my $flow = create_flow( 'MyHandler1', $h1 );
    #also create pipe of flows
    my $filter1 = create_flow( 'MyHandler1'=>{}, 'MyHandler2'=>{} );
    my $h1     = new MyHandler3::;
    my $flow = create_flow(  $filter1, $h1);

=cut

sub create_flow {

    #firest make objects
    my @objects = ();
    while ( $#_ >= 0 ) {
        my $method = shift @_;

        #if object ?
        if ( ref($method) ) {
            if ( ref($method) eq 'CODE' ) {

                #use Flow::Code by default
                $method = new Flow::Code:: $method;
            }
            if ( UNIVERSAL::isa( $method, "Flow" ) ) {
                push @objects, $method;
                next;
            }
            die "bad method $method";
        }
        my $param = shift @_;
        if ( defined $tmp_map{$method} ) {
            $method = $tmp_map{$method};
        }
        push @objects, $method->new($param);
    }
    my @in = reverse map { split_flow($_) } @objects;
    my $next_handler = shift @in;
    foreach my $f (@in) {
        die "$f not isa of Flow::" unless UNIVERSAL::isa( $f, "Flow" );
        $f->set_handler($next_handler);
        $next_handler = $f;
    }
    return $next_handler;
}

sub split_flow {
    my $obj = shift;
    use Data::Dumper;
    if ( @_ > 1 ) {
        return split_flow($_) for @_;
    }
    my @res = ($obj);
    if ( my $h = $obj->get_handler ) {
        push @res, split_flow($h);
    }
    @res;
}

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $opt = ( $#_ == 0 ) ? shift : {@_};
    my $self = bless( $opt, $class );
    return $self;
}

sub set_handler {
    my $self    = shift;
    my $handler = shift;
    if ( UNIVERSAL::isa( $handler, 'Flow' ) ) {
        $self->__handler($handler);
    }
}

sub get_handler {
    my $self = shift;
    return $self->__handler();
}

sub __handler {
    my $self = shift;
    if (@_) {
        $self->{Handler} = shift @_;
    }
    return $self->{Handler};
}

sub parser {
    my $self = shift;
    my $run_flow = Flow::create_flow( __PACKAGE__->new(), $self );
    return $run_flow;
}

sub run {
    my $self = shift;
    my $p    = $self->parser;
    $p->begin();
    $p->flow(@_);
    $p->end();
}

1;

