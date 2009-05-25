<?php
require_once('ikw_common.inc');

/* Pass in by reference! */
function graph_cpu_report(& $rrdtool_graph)
{

   global $context, $cpu_idle_color, $cpu_nice_color, $cpu_system_color, $cpu_user_color, $cpu_wio_color, $hostname, $range, $rrd_dir, $size, $strip_domainname;

   if ($strip_domainname)
   {
      $hostname = strip_domainname($hostname);
   }
   $rrdtool_graph['end'] = get_graph_end($range);
   $rrdtool_graph['height'] += ($size == 'medium') ? 14 : 0;
   $title = 'CPU';
   if ($context != 'host')
   {
      $rrdtool_graph['title'] = $title;
   } else
   {
      $rrdtool_graph['title'] = "$hostname $title last $range";
   }
   $rrdtool_graph['upper-limit'] = '100';
   $rrdtool_graph['lower-limit'] = '0';
   $rrdtool_graph['vertical-label'] = 'Percent';
   $rrdtool_graph['extras'] = '--rigid';

   if ($context != "host")
   {

      /*
       * If we are not in a host context, then we need to calculate
       * the average
       */
      $series = "DEF:'num_nodes'='${rrd_dir}/cpu_user.rrd':'num':AVERAGE ".
      "DEF:'cpu_user'='${rrd_dir}/cpu_user.rrd':'sum':AVERAGE ".
      "CDEF:'ccpu_user'=cpu_user,num_nodes,/ ".
      "DEF:'cpu_nice'='${rrd_dir}/cpu_nice.rrd':'sum':AVERAGE ".
      "CDEF:'ccpu_nice'=cpu_nice,num_nodes,/ ".
      "DEF:'cpu_system'='${rrd_dir}/cpu_system.rrd':'sum':AVERAGE ".
      "CDEF:'ccpu_system'=cpu_system,num_nodes,/ "."DEF:'cpu_idle'='${rrd_dir}/cpu_idle.rrd':'sum':AVERAGE ".
      "CDEF:'ccpu_idle'=cpu_idle,num_nodes,/ HRULE:0#ffffff00 ";
      
      $series .= get_pred('ccpu_idle', $cpu_idle_color, str_pad('Idle',7), "STACK");
      $series .= get_pred('ccpu_user',$cpu_user_color,str_pad('User',7),"STACK");
      $series .= get_pred('ccpu_system', $cpu_system_color, str_pad('System',7), "STACK");
      $series .= get_pred('ccpu_nice', $cpu_nice_color, str_pad('Nice',7), "STACK");

      if (file_exists("$rrd_dir/cpu_wio.rrd"))
      {
         $series .= "DEF:'cpu_wio'='${rrd_dir}/cpu_wio.rrd':'sum':AVERAGE ".
         "CDEF:'ccpu_wio'=cpu_wio,num_nodes,/ ";
         $series .= get_pred('ccpu_wio', $cpu_wio_color, str_pad('Wait',7), "STACK");
      }

   } else
   {

      /* Context is not "host" */

      $series = "DEF:'cpu_user'='${rrd_dir}/cpu_user.rrd':'sum':AVERAGE ".
      "DEF:'cpu_nice'='${rrd_dir}/cpu_nice.rrd':'sum':AVERAGE ".
      "DEF:'cpu_system'='${rrd_dir}/cpu_system.rrd':'sum':AVERAGE ".
      "DEF:'cpu_idle'='${rrd_dir}/cpu_idle.rrd':'sum':AVERAGE HRULE:0#ffffff00 ";
       $series .= get_pred('cpu_user',$cpu_user_color,str_pad('User',7),"STACK");
      $series .= get_pred('cpu_nice', $cpu_nice_color, str_pad('Nice',7), "STACK");
      $series .= get_pred('cpu_system', $cpu_system_color, str_pad('System',7), "STACK");


      if (file_exists("$rrd_dir/cpu_wio.rrd"))
      {
         $series .= "DEF:'cpu_wio'='${rrd_dir}/cpu_wio.rrd':'sum':AVERAGE ";
         $series .= get_pred('cpu_wio', $cpu_wio_color, str_pad('Wait',7), "STACK");
      }

      $series .= get_pred('cpu_idle', $cpu_idle_color, str_pad('Idle',7), "STACK");
   }
    $series .= get_time_vrule(time());
   $rrdtool_graph['series'] = $series;

   return $rrdtool_graph;
}
?>
