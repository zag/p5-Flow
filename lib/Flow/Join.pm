#===============================================================================
#
#  DESCRIPTION:  Join flows into one
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::NamedPipesPack;
use strict;
use warnings;
use base 'Flow';

sub begin {
    return;
}

sub flow {
    my $self = shift;
    $self->put_ctl_flow(
        { type => 'named_pipes', name => $self->{name}, stage => 1 } );
    my $res = $self->SUPER::flow(@_);
    $self->put_ctl_flow(
        { type => 'named_pipes', name => $self->{name}, stage => 2 } );
    return $res;
}

sub ctl_flow {
    my $self = shift;
    $self->put_ctl_flow(
        { type => 'named_pipes', name => $self->{name}, stage => 3 } );
    my $res = $self->SUPER::ctl_flow(@_);
    $self->put_ctl_flow(
        { type => 'named_pipes', name => $self->{name}, stage => 4 } );
    return $res;
}

sub end {
    my $self = shift;
    return;
}
1;

package Flow::Join;
use strict;
use warnings;
use Data::Dumper;
use Flow;
use base 'Flow';

sub new {
    my $self  = shift->SUPER::new();
    my @order = ();
    # Flow::Join:: { Data=>$dsd, Test=>$sdsd}
    if ($#_ == 0 ) {
        @_ = %{ shift @_ } ;
    }
    while ( my ( $name, $value ) = splice @_, 0, 2 ) {
        push @order,
          {
            name   => $name,
            flow   => $value,
            origin => [
                Flow::split_flow($value),
                new Flow::NamedPipesPack:: name => $name
            ]
          };
    }
    $self->{flows} = \@order;
    $self;
}

sub set_handler {
    my $self = shift;
    $self->SUPER::set_handler(@_);
    my $handler = $self->get_handler;
    foreach ( @{ $self->{flows} } ) {
        my @flows = reverse( @{ $_->{origin} }, $handler );
        my $next = shift @flows;
        while ( my $h = shift @flows ) {
            $h->set_handler($next);
            $next = $h;
        }
        $_->{flow} = $next;
    }
}

sub _get_flows {
    my $self = shift;
    my @res  = ();
    foreach my $rec ( @{ $self->{flows} } ) {
        push @res, $rec->{flow};
    }
    @res;
}

sub flow() {
    my $self = shift;
    foreach my $f ( $self->_get_flows ) {
        $f->parser->flow(@_);
    }
    return;
}

sub ctl_flow() {
    my $self = shift;
    foreach my $f ( $self->_get_flows ) {
        $f->parser->ctl_flow(@_);
    }
    return;
}

sub begin {
    my $self = shift;
    my $res  = $self->SUPER::begin(@_);
    foreach my $f ( $self->_get_flows ) {
        $f->parser->begin(@_);
    }
    return $res;
}

sub end {
    my $self = shift;
    foreach my $f ( $self->_get_flows ) {
        $f->parser->end(@_);
    }
    return $self->SUPER::end(@_);
}

1;

