#!/usr/bin/perl

use strict;
#use warnings;

#sub get_device_IDs
#{
# The Hex IDs off all detected 1-wire devices on the bus are stored in the file
# "w1_master_slaves"

# we read this file, and make a new fixed file with all the device IDs and fixed indexes. You can also put
# calibration information into the sensors.config file after detect.pl has created it.
# sensors.config format is:
# 
# index         ,calibration factor              	,1-Wire Device ID
# 0		,0.0					,28-000005dfe8c5
# 1		,0.0					,28-000005e05c68
# 2		,0.0					,28-000005e086ad
# 3		,0.0					,28-000005e0cfa7
# 4		,0.0					,28-000005e0d7c1
# 5		,0.0					,28-000005fd58dd

# or you can use descriptive names for the device ID, but again you'll have to edit the sensors.config file to
# add them after detect.pl has created sensors.config for you.
#
# index		        ,calibration factor	        	,1-Wire Device ID
# T1			,0.0					,28-000005dfe8c5
# T2			,100.123				,28-000005e05c68
# T3			,-273.1			        	,28-000005e086ad
# T4		  	,6000					,28-000005e0cfa7
# T5			,-1.2					,28-000005e0d7c1
# T6			,0.0					,28-000005fd58dd
 

# open file
open(INFILE, "/sys/bus/w1/devices/w1_bus_master1/w1_master_slaves") or die("Unable to open file");
 
# read file into an array
my @deviceIDs = <INFILE>; 
close(INFILE);

my $index;
open(OUTFILE,">", "sensors.config") or die ("Unable to create sonsors.conf");
foreach (@deviceIDs) {
	print OUTFILE $index++ . "," . "0.0" . "," . $_;
}
close(OUTFILE);


