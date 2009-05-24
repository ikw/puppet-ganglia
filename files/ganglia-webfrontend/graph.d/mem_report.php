<?php
require_once("ikw_common.inc");
/* Pass in by reference! */
function graph_mem_report(& $rrdtool_graph) {

   global $context, $hostname, $mem_shared_color, $mem_cached_color, $mem_buffered_color, $mem_swapped_color, $mem_used_color, $cpu_num_color, $range, $rrd_dir, $size, $strip_domainname;

   if($strip_domainname) {
      $hostname= strip_domainname($hostname);
   }
   $rrdtool_graph['end']= get_graph_end($range);
   $title= 'Memory';
   if($context != 'host') {
      $rrdtool_graph['title']= $title;
   } else {
      $rrdtool_graph['title']= "$hostname $title last $range";
   }
   $rrdtool_graph['lower-limit']= '0';
   $rrdtool_graph['vertical-label']= 'Bytes';
   $rrdtool_graph['extras']= '--rigid --base 1024';

   $series= "DEF:'mem_total'='${rrd_dir}/mem_total.rrd':'sum':AVERAGE ".
   "CDEF:'bmem_total'=mem_total,1024,* ".
   "DEF:'mem_shared'='${rrd_dir}/mem_shared.rrd':'sum':AVERAGE ".
   "CDEF:'bmem_shared'=mem_shared,1024,* ".
   "DEF:'mem_free'='${rrd_dir}/mem_free.rrd':'sum':AVERAGE ".
   "CDEF:'bmem_free'=mem_free,1024,* ".
   "DEF:'mem_cached'='${rrd_dir}/mem_cached.rrd':'sum':AVERAGE ".
   "CDEF:'bmem_cached'=mem_cached,1024,* ".
   "DEF:'mem_buffers'='${rrd_dir}/mem_buffers.rrd':'sum':AVERAGE ".
   "CDEF:'bmem_buffers'=mem_buffers,1024,* ".
   "CDEF:'bmem_used'='bmem_total','bmem_shared',-,'bmem_free',-,'bmem_cached',-,'bmem_buffers',- ";
   $series .= get_pred('bmem_used', "${mem_used_color}", str_pad('Used', 9),"AREA");
   $series .= get_pred('bmem_shared', "${mem_shared_color}", str_pad('Shared', 9), "STACK");
   $series .= get_pred('bmem_cached', "${mem_cached_color}", str_pad('Cached', 9), "STACK");
   $series .= get_pred('bmem_buffers', "${mem_buffered_color}", str_pad('Buffered', 9), "STACK");

   if(file_exists("$rrd_dir/swap_total.rrd")) {
      $series .= "DEF:'swap_total'='${rrd_dir}/swap_total.rrd':'sum':AVERAGE ".
      "DEF:'swap_free'='${rrd_dir}/swap_free.rrd':'sum':AVERAGE ".
      "CDEF:'bmem_swapped'='swap_total','swap_free',-,1024,* ";
      $series .= get_pred('bmem_swapped', $mem_swapped_color, str_pad('Swapped',9),"STACK");
   }

   $series .= "LINE2:'bmem_total'#$cpu_num_color:'Total In-Core Memory' ";
   $series .= "GPRINT:'bmem_total':AVERAGE:'%6.2lf%s' ";
   $time = time();
   $series .= "VRULE:${time}#FF0000:\"\tNow\" ";
   $rrdtool_graph['series']= $series;
   return $rrdtool_graph;

}
?>
