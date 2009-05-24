<?php
require_once("ikw_common.inc");
/* Pass in by reference! */
function graph_load_report(& $rrdtool_graph) {

   global $context, $cpu_num_color, $cpu_user_color, $hostname, $load_one_color, $num_nodes_color, $proc_run_color, $range, $rrd_dir, $size, $strip_domainname;

   if($strip_domainname) {
      $hostname= strip_domainname($hostname);
   }
   $rrdtool_graph['end']= get_graph_end($range);

   $rrdtool_graph['height'] +=($size == 'medium') ? 28 : 0;
   $title= 'Load';
   if($context != 'host') {
      $rrdtool_graph['title']= $title;
   } else {
      $rrdtool_graph['title']= "$hostname $title last $range";
   }
   $rrdtool_graph['lower-limit']= '0';
   $rrdtool_graph['vertical-label']= 'Load/Procs';
   $rrdtool_graph['extras']= '--rigid';

   $series= "DEF:'load_five'='${rrd_dir}/load_five.rrd':'sum':AVERAGE ".
   "DEF:'proc_run'='${rrd_dir}/proc_run.rrd':'sum':AVERAGE ".
   "DEF:'cpu_num'='${rrd_dir}/cpu_num.rrd':'sum':AVERAGE ";
   $labels= array("5-min Load", "Nodes", "CPUs", "Running Procs");
   $llen= 0;
   foreach($labels as $label) {
      $llen= strlen($label) > $llen ? strlen($label) : $llen;
   }
   $label= str_pad($labels[0], $llen);
   $series .= get_pred("load_five", $load_one_color, "${label}", "AREA");

   if($context != 'host') {
      $series .= "DEF:'num_nodes'='${rrd_dir}/cpu_num.rrd':'num':AVERAGE ";
      $label= str_pad($labels[1], $llen);
      $series .= get_pred("num_nodes", $num_nodes_color, "${label}");
   }
   $label= str_pad($labels[2], $llen);
   $series .= get_pred("cpu_num", $cpu_num_color, "${label}");
   $label= str_pad($labels[3], $llen);
   $series .= get_pred("proc_run", $proc_run_color, "${label}");
   $time= time();
   $series .= "VRULE:${time}#FF0000:\"\tNow\" ";

   $rrdtool_graph['series']= $series;

   return $rrdtool_graph;

}
?>
