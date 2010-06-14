#===============================================================================
#
#  DESCRIPTION:  Split flow into more( alternate Join)
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::Split;
use strict;
use warnings;
use base 'Flow';

sub new {
    my $self  = shift->SUPER::new();
    my @order = ();
    # Flow::Split:: { Data=>$dsd, Test=>$sdsd}
    if ($#_ == 0 ) {
        @_ = %{ shift @_ } ;
    }
    while ( my ( $name, $value ) = splice @_, 0, 2 ) {
        push @order,
          {
            name   => $name,
            flow   => $value,
          };
    }
    $self->{flows} = \@order;
    $self;
}

sub _get_flows {
    my $self = shift;
    my @res  = ();
    foreach my $rec ( @{ $self->{flows} } ) {
        push @res, $rec->{flow};
    }
    @res;
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

sub current_pipe {
    my $self = shift;
     $self->{_cp} || $self->get_handler()  || new Flow::To::Null::;
}

sub flow {
    my $self = shift;
    return $self->current_pipe->parser->flow(@_);
}

sub ctl_flow {
    my $self = shift;
    foreach my $rec ( @_ ) {
        #check if  switch pipe
        if ( (ref($rec) eq 'HASH') && ( my $type= $rec->{type} )) {
               if ( $type eq  'named_pipes' ) {
                    my $stage  = $rec->{stage};
                    my $name = $rec->{name};
                    if ( $stage == 2 ||$stage == 4 ) {
                       #close switch
                       delete $self->{_cp};
                       next;
                    }
                    #now get pipe by name and set as default
                    my $flow;
                    foreach my $f ( @{ $self->{flows} } ) {
                       if ( $name eq $f->{name}) {
                         $flow = $f->{flow};
                         last;
                       }
                    }
                    if ( $flow ) {
                    $self->{_cp} = $flow;
                    next;
                    } else {
                        warn "can't get flow for name $name"
                    }
               }
        }
        return $self->current_pipe->parser->ctl_flow( $rec )
    }
    return ;
}

1;


