#!/usr/bin/env perl
# $Id$
#
# 2007-06-01    Zoltan HERPAI <wigyori@uid0.hu>
# 2009-05-29    udo.waechter@uos.de rewritten for ganglia
#
# Credits goes for:
# Adam Crews for his xen_cpu plugin
# Mario Manno for his xen_traffic_all plugin
#
# Script to monitor the I/O usage of Xen domains
# Version 0.1

# Location of xm tools
$XM = '/usr/sbin/xm';
$XMTOP = '/usr/sbin/xentop';

# No args, get rolling
{
  local $/ = undef;
  @chunks = split(/^xentop - .*$/m, `$XMTOP -b -i1`);
}
$dom0_cpus=1;
@stats = split (/\n/, pop(@chunks));
foreach $domain (@stats)
{
  if ($domain =~ /Domain-0/i) {
    @tmp = split(/\s\s+/, $domain);
    $dom0_cpus = $tmp[8];
  }
}
foreach $domain (@stats)
{
  $domain =~ s/^\s+//;
  next if $domain =~ /NAME/i;
  next if $domain =~ /Domain-0/i; 
  @tmp = split(/\s+/, $domain);
  $domname = $tmp[0];
  $domname =~ s/[-.]/_/g;
  $vbdrd = $tmp[14];
  $vbdwr = $tmp[15];
  system("gmetric --name=\"Xen IO read $domname\" --value=$vbdrd --type=uint16 --tmax=300 --dmax=30000");
  system("gmetric --name=\"Xen IO write $domname\" --value=$vbdwr --type=uint16 --tmax=300 --dmax=30000");
## cpu usage
  $cpu_percent = $tmp[3];
  $vcpu        = $tmp[8];
  $cpu = $cpu_percent/$vcpu;
  system("gmetric --name=\"Xen CPU used $domname\" --value=$cpu --type=uint16 --units=% --tmax=300 --dmax=30000");
}
