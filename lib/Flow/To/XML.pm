#===============================================================================
#
#  DESCRIPTION:  Export flows to XML
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::To::XML;
use strict;
use warnings;
use Flow;
use base 'Flow';
use XML::Flow qw( ref2xml xml2ref);

=head2 new  dst
    
    new Flow::To::XML:: \$str

=cut

sub new {
    my $class = shift;
    my $dst   = shift;
    my $xflow = ( new XML::Flow:: $dst );
    return $class->SUPER::new( @_, _xml_flow => $xflow, );
}

sub begin {
    my $self = shift;
    $self->{_xml_flow}->startTag( "FLOW", makedby => __PACKAGE__ );
    return $self->SUPER::begin(@_);
}

sub flow {
    my $self = shift;
    my $xfl  = $self->{_xml_flow};
    $xfl->startTag("flow");
    $xfl->write( \@_ );
    $xfl->endTag("flow");
    return $self->SUPER::flow(@_)

}

sub ctl_flow {
    my $self = shift;
    my $xfl  = $self->{_xml_flow};
    $xfl->startTag("ctl_flow");
    $xfl->write( \@_ );
    $xfl->endTag("ctl_flow");
    return $self->SUPER::ctl_flow(@_)

}

sub end {
    my $self = shift;
    my $res  = $self->SUPER::end(@_);
    $self->{_xml_flow}->endTag("FLOW");
    return $res

}
1;

