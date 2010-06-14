#===============================================================================
#
#  DESCRIPTION:  Serialize to mixied XML and JSON
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Flow::To::JXML;
use strict;
use warnings;
use JSON;
use Flow::To::XML;
use base 'Flow::To::XML';
sub flow {
    my $self = shift;
    my $xfl  = $self->{_xml_flow};
    $xfl->startTag("flow");
    $xfl->_get_writer->cdata(encode_json(\@_));
    $xfl->endTag("flow");
    return $self->Flow::flow(@_)

}

sub ctl_flow {
    my $self = shift;
    my $xfl  = $self->{_xml_flow};
    $xfl->startTag("ctl_flow");
    $xfl->_get_writer->cdata(encode_json(\@_));
    $xfl->endTag("ctl_flow");
    return $self->Flow::ctl_flow(@_)

}

1;



