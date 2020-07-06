##############################################
# $Id: myUtilsTemplate.pm 7570 2015-01-14 18:31:44Z rudolfkoenig $
#
# Save this file as 99_myUtils.pm, and create your own functions in the new
# file. They are then available in every Perl expression.

package main;

use strict;
use warnings;
use POSIX;
use JSON;

sub
myUtils_01_WM_Initialize($$)
{
  my ($hash) = @_;
}

# Enter you functions below _this_ line.


sub myUtils_WM_Get_ReadingName {
    my ( $hash, $name, $topic, $message, $readname ) = @_;
    
    my $json = decode_json( $message );
    readingsBeginUpdate( $hash );
    readingsBulkUpdate( $hash, $json->{$readname}, $message );
    readingsEndUpdate( $hash, 1 );
}

sub myUtils_WM_Get_ReadingEntry {
    my ( $name, $devtype, $devread ) = @_;
    
    return((decode_json(ReadingsVal($name, $devtype, "{}")))->{$devread});
}

1;
