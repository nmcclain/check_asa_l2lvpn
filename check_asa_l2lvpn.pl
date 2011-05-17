#!/usr/bin/perl -w

# This check is intended to show up/down status for
# a site-to-site VPN on a Cisco ASA firewall.
#
# The next 4 lines should go in your checkcommands.cfg file:
#   define command{
#     command_name check_asa_l2lvpn
#     command_line $USER1$/check_asa_l2lvpn $HOSTADDRESS$ $ARG1$ $ARG2$ $ARG3$
#   }
#
# You might put somethign like this in your Nagios service definition:
#   check_command  check_asa_l2lvpn!mySecret!10.15.14.1!salesoffice
#
# Where mySecret is your community string, 10.15.14.1 is the VPN peer IP,
# and salesoffice is the friendly name.  The friendly name is used for the
# service_description, which would be VPN-salesoffice in this example.
#
# http://www.barkingseal.com/2009/08/monitoring-sit…on-a-cisco-asa/
#
# Sun Aug  2 11:53:17 MDT 2009
# Version 1.0
#
#

unless (($#ARGV == 2) or ($#ARGV == 3)) { print("usage:\tcheck_asa_l2lvpn <IP address> <community> <peer IP> [friendlyname]\n"); exit(1);}

$IP = $ARGV[0];
$community = $ARGV[1];
$peerip = $ARGV[2];
if (defined($ARGV[3])) { $friendlyname = $ARGV[3]; }

$uptunnels = `/usr/local/bin/snmpwalk -v1 -c $community $IP 1.3.6.1.4.1.9.9.171.1.2.3.1.7`;

$state = "CRIT";
$msg = "Site-to-site VPN tunnel to peer ".$peerip." is down!";
$output = "";

foreach (split("\n", $uptunnels)) {
	if ($_ =~ /SNMPv2-SMI::enterprises.9.9.171.1.2.3.1.7.\d+ = STRING: "$peerip"/) {
		$state = "OK";
		$msg = "Site-to-site VPN tunnel to peer ".$peerip." is up.";
	}
}

print "VPN-".$friendlyname." " . $state . " " . $msg . "|" . $output . "\n";

if ($state eq "OK") { exit 0;
} elsif ($state eq "WARN") { exit 1;
} elsif ($state eq "CRIT") { exit 2;
} else { #unknown!
	exit 3;
}


