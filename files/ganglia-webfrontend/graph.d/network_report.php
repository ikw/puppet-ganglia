<?php
require_once("ikw_common.inc");

/* Pass in by reference! */
function graph_network_report(& $rrdtool_graph) {

   global $context, $hostname, $mem_cached_color, $mem_used_color, $cpu_num_color, $range, $rrd_dir, $size, $strip_domainname;

   if($strip_domainname) {
      $hostname= strip_domainname($hostname);
   }
   $rrdtool_graph['end']= get_graph_end($range);

   $title= 'Network';
   $rrdtool_graph['height'] +=($size == 'medium') ? 28 : 0;
   if($context != 'host') {
      $rrdtool_graph['title']= $title;
   } else {
      $rrdtool_graph['title']= "$hostname Network last $range";
   }
   $rrdtool_graph['lower-limit']= '0';
   $rrdtool_graph['vertical-label']= 'Bytes/sec';
   $rrdtool_graph['extras']= '--rigid --base 1024';

   $series= "DEF:'bytes_in'='${rrd_dir}/bytes_in.rrd':'sum':AVERAGE ".
   "DEF:'bytes_out'='${rrd_dir}/bytes_out.rrd':'sum':AVERAGE ";
   $series .= get_pred("bytes_in", $mem_cached_color, str_pad("In", 3));
   $series .= get_pred("bytes_out", $mem_used_color, "Out");
   $time= time();
   $series .= "VRULE:${time}#FF0000:\"\tNow\" ";
   $rrdtool_graph['series']= $series;
   return $rrdtool_graph;

}
?>
