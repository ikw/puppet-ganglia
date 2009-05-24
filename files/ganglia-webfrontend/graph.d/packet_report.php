<?php
require_once ("ikw_common.inc");

/* Pass in by reference! */
function graph_packet_report(& $rrdtool_graph)
{

   global $context, $hostname, $mem_cached_color, $mem_used_color, $cpu_num_color, $range, $rrd_dir, $size, $strip_domainname;

   if ($strip_domainname)
   {
      $hostname = strip_domainname($hostname);
   }
   $rrdtool_graph['end'] = get_graph_end($range);
   $title = 'Packets';
   $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
   if ($context != 'host')
   {
      $rrdtool_graph['title'] = $title;
   } else
   {
      $rrdtool_graph['title'] = "$hostname $title last $range";
   }

   $rrdtool_graph['vertical-label'] = 'Packets/sec';
   $rrdtool_graph['extras'] = '--rigid';

   $series = "DEF:'bytes_in'='${rrd_dir}/pkts_in.rrd':'sum':AVERAGE ".
   "DEF:'bytes_out1'='${rrd_dir}/pkts_out.rrd':'sum':AVERAGE ".
   "CDEF:'bytes_out'=0,bytes_out1,- ";
   $series .= get_pred("bytes_in", $mem_cached_color, str_pad("In", 3), "AREA");
   $series .= get_pred("bytes_out", $mem_used_color, "Out", "AREA");
   
   $series .= " HRULE:0#000000 ";
   $series .= get_time_vrule(time());
   $rrdtool_graph['series'] = $series;

   return $rrdtool_graph;

}
?>
