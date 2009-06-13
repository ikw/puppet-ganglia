#!/usr/bin/env perl
#
# a simple script to report some per user stats to ganglia
# contributed by Ryan Sweet <ryan@end.org>
#
chomp(my $gmetric=`which gmetric`);
exit 0 if ($? != 0);
my $users,@ps; 

# RS: get ps aux output and skip the first line
# RS: ps has different behaviour on IRIX vs Linux
my $uname=`uname`;
#if ( $uname =~ /Linux/ ) 
#{
#        @ps=`ps aux| grep -v USER`;
#}else{
#        # RS: pcpu is repeated because this ps doesn't give %mem stats
#        @ps=`ps -xeo user,pid,pcpu,pcpu,vsz,rss,tty,state,time,comm|grep -v USER`;
#}
@ps=`ps xaeo user,pcpu,pmem,vsz,rss,time|grep -v USER`;

# RS: iterate over each line of the ps output
foreach my $line (@ps) 
{
        # RS: eat any leading whitespace
        $line =~ s/^\s+//;
        
        # RS: split the line on whitespace, assigning vars
        my ($user,$cpu,$mem,$vsz,$rss,$time,@args) = split(/\s+/, $line);     

        # RS: populate the hash %users with references to the cumulative cpu,memz,time vars
        $users->{$user}{cpu}+=$cpu;
        $users->{$user}{mem}+=$mem;
        $users->{$user}{vsz}+=$vsz;
        # RS: calculate the time in seconds rather than min:sec
        my ($min,$sec)=split(/:/,$time);
        $sec+=($min*60);
        $users->{$user}{time}+=$time;
        $users->{$user}{procs}+=1; # total number of procs per user
        
}
$gmetric="$gmetric -d 30000 -x 300 --type=float";
# RS: for each user that was found, send the stats to gmond
foreach my $user (keys %$users)
{
        # cpu total
        system("$gmetric --name=cpu_percent_$user --value=$users->{$user}{cpu} --units=\%cpu");
	# mem percent
	system("$gmetric --name=mem_percent_$user --value=$users->{$user}{mem} --units=\%mem");
        # vsz total
        system("$gmetric --name=mem_vsz_kb_$user --value=$users->{$user}{vsz} --units=kilobytes");
        # cputime total
        system("$gmetric --name=cpu_total_time_sec_$user --value=$users->{$user}{time} --units=seconds");
        # processes total
        system("$gmetric --name=procs_total_$user --value=$users->{$user}{procs} --units=processes");
} 
