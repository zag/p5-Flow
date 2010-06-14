#===============================================================================
#
#  DESCRIPTION:  Splice flow
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::Splice;
use warnings;
use strict;
use Data::Dumper;
use Flow;
use base 'Flow';

sub new {
    my $class = shift;
    my $count = shift;
    my $self  = $class->SUPER::new(@_);
    $self->{stack}   = [];
    $self->{_Splice} = $count;
    return $self;

}

sub purge_stack {
    my $self  = shift;
    my $stack = $self->{stack};
    if ( scalar(@$stack) ) {
        $self->put_flow(@$stack);
        @$stack = ();
    }

}

sub ctl_flow {
    my $self = shift;
    $self->purge_stack();
    return $self->SUPER::ctl_flow(@_);
}

sub flow {
    my $self  = shift;
    my $stack = $self->{stack};
    my $count = $self->{_Splice};
    foreach (@_) {
        if ( @$stack >= $count ) {
            $self->purge_stack();
        }
        push @$stack, $_;
    }
    return undef;
}

sub end {
    my $self  = shift;
    my $stack = $self->{stack};
    $self->purge_stack();
    return \@_;
}

1;

