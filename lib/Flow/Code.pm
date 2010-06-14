#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::Code;
use strict;
#use warnings;
use base 'Flow';

=head2  new 

    new Flow::Code:: { flow=>sub{ shift; [] }[, begin=>sub{ shift ..}, end .., cnt_flow=>... };
    new Flow::Code:: sub{ shift;} #default handle flow
=cut

foreach my $method  ( "begin", "flow", "ctl_flow","end" ) {
    my $s_method = "SUPER::".$method;
    no strict 'refs';
    *{ __PACKAGE__ . "::$method" } = sub {
        my $self = shift;
        if ( my $code = $self->{$method}) {
            return &$code(@_)
        } else {
            return $self->$s_method(@_)
        }
    };
}

sub new {
    my $class = shift;
    if ( $#_ == 0  and ref($_[0]) eq 'CODE') {
        unshift @_, 'flow';
    }
    my $self  = $class->SUPER::new(@_);
    #clean up hnot valided handlers
    foreach my $method  ( qw/ begin flow  ctl_flow end /) {
     my $code = $self->{$method} || next;
     delete $self->{$method} unless ref($code) eq 'CODE';
    }
    return $self
}


1;


