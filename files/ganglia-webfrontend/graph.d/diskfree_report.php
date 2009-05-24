<?php
require_once ("ikw_common.inc");

/* Report to predict when the overall diskfree figures will reach zero */

/* Place this in the graph.d/ directory, and add "diskfree" to the
   $optional_graphs array in web/conf.php */

function graph_diskfree_report(& $rrdtool_graph)
{

   /* this is just the cpu_report (from revision r920) as an example, but with extra comments */

   // pull in a number of global variables, many set in conf.php (such as colors and $rrd_dir),
   // but other from elsewhere, such as get_context.php

   global $context, $cpu_idle_color, $cpu_nice_color, $cpu_system_color, $cpu_user_color, $cpu_wio_color, $hostname, $range, $rrd_dir, $size, $strip_domainname;
   //
   // You *MUST* set at least the 'title', 'vertical-label', and 'series' variables.
   // Otherwise, the graph *will not work*.  
   //
   if ($strip_domainname)
   {
      $hostname = strip_domainname($hostname);
   }
   $title = 'Diskfree Report';
   if ($context != "host")
      $rrdtool_graph['title'] = $title;
   else
      $rrdtool_graph['title'] = "$hostname $title last $range";
   //  This will be turned into:   
   //  "Clustername $TITLE last $timerange", so keep it short
   $rrdtool_graph['vertical-label'] = 'Percent Free Space';
   $rrdtool_graph['upper-limit'] = '100';
   $rrdtool_graph['lower-limit'] = '0';
   $rrdtool_graph['extras'] = '--rigid';

   $rrdtool_graph['end'] = get_graph_end($range);

   $series .= "DEF:fsu_a=$rrd_dir/part_max_used.rrd:sum:AVERAGE:step=300  ".
   "DEF:fsu_b=$rrd_dir/part_max_used.rrd:sum:AVERAGE:step=300:start=now-3d  ".
   "DEF:fsu_c=$rrd_dir/part_max_used.rrd:sum:AVERAGE:step=300:start=now-1w  ".
   "DEF:fsu_d=$rrd_dir/part_max_used.rrd:sum:AVERAGE:step=300:start=now-1m ".
   "VDEF:slope_a=fsu_a,LSLSLOPE  ".
   "VDEF:yint_a=fsu_a,LSLINT  ".
   "VDEF:correl_a=fsu_a,LSLCORREL  ".
   "VDEF:slope_b=fsu_b,LSLSLOPE  ".
   "VDEF:yint_b=fsu_b,LSLINT  ".
   "VDEF:correl_b=fsu_b,LSLCORREL  ".
   "VDEF:slope_c=fsu_c,LSLSLOPE  ".
   "VDEF:yint_c=fsu_c,LSLINT  ".
   "VDEF:correl_c=fsu_c,LSLCORREL  ".
   "VDEF:slope_d=fsu_d,LSLSLOPE  ".
   "VDEF:yint_d=fsu_d,LSLINT  ".
   "VDEF:correl_d=fsu_d,LSLCORREL  ".
   "CDEF:projuse_a=fsu_a,POP,yint_a,slope_a,COUNT,*,+  ".
   "CDEF:fyline_a=projuse_a,0,100,LIMIT  ".
   "CDEF:projuse_b=fsu_b,POP,yint_b,slope_b,COUNT,*,+  ".
   "CDEF:fyline_b=projuse_b,0,100,LIMIT  ".
   "CDEF:projuse_c=fsu_c,POP,yint_c,slope_c,COUNT,*,+  ".
   "CDEF:fyline_c=projuse_c,0,100,LIMIT  ".
   "CDEF:projuse_d=fsu_d,POP,yint_d,slope_d,COUNT,*,+  ".
   "CDEF:fyline_d=projuse_d,0,100,LIMIT  ".
   "VDEF:firstv=fsu_a,FIRST  ".
   "VDEF:lastv=projuse_a,LAST  ".
   "CDEF:crosslimit_a=projuse_a,99.99,INF,LIMIT,UN,UNKN,slope_a,0,LT,UNKN,TIME,IF,IF  ".
   "CDEF:crosslimit_b=projuse_b,99.99,INF,LIMIT,UN,UNKN,slope_b,0,LT,UNKN,TIME,IF,IF  ".
   "CDEF:crosslimit_c=projuse_c,99.99,INF,LIMIT,UN,UNKN,slope_c,0,LT,UNKN,TIME,IF,IF  ".
   "CDEF:crosslimit_d=projuse_d,99.99,INF,LIMIT,UN,UNKN,slope_d,0,LT,UNKN,TIME,IF,IF  ".
   "VDEF:co_limit_a=crosslimit_a,FIRST  ".
   "VDEF:co_limit_b=crosslimit_b,FIRST  ".
   "VDEF:co_limit_c=crosslimit_c,FIRST  ".
   "VDEF:co_limit_d=crosslimit_d,FIRST  ".
   "GPRINT:firstv:\"Period between %Y-%m-%d\g\":strftime  ".
   "GPRINT:lastv:\" and %Y-%m-%d\c\":strftime  ".
   "COMMENT:\"  \" ".
   "CDEF:fsu_by_16=fsu_a,16,/  ".
   "AREA:fsu_a#FFCC0066  ".
   "AREA:fsu_by_16#33BC3300  ".
   "AREA:fsu_by_16#33BC3311::STACK  ".
   "AREA:fsu_by_16#33BC3322::STACK  ".
   "AREA:fsu_by_16#33BC3333::STACK  ".
   "AREA:fsu_by_16#33BC3344::STACK  ".
   "AREA:fsu_by_16#33BC3355::STACK  ".
   "AREA:fsu_by_16#33BC3366::STACK  ".
   "AREA:fsu_by_16#33BC3377::STACK  ".
   "AREA:fsu_by_16#33BC3388::STACK  ".
   "AREA:fsu_by_16#33BC3399::STACK  ".
   "AREA:fsu_by_16#33BC33AA::STACK  ".
   "AREA:fsu_by_16#33BC33BB::STACK  ".
   "AREA:fsu_by_16#33BC33CC::STACK  ".
   "AREA:fsu_by_16#33BC33DD::STACK  ".
   "AREA:fsu_by_16#33BC33EE::STACK  ".
   "AREA:fsu_by_16#33BC33FF::STACK  ".
   "LINE:fsu_a#116611  COMMENT:\"Projection\t\t\"  ".
   "COMMENT:\"Co-Variance\t\"  ".
   "COMMENT:\"100% Crossing\l\"  ".
   "COMMENT:\"--------------------\t\"  ".
   "COMMENT:\"-----------\t\"  ".
   "COMMENT:\"-------------\l\"  ".
   "LINE2:fyline_a#FC900098:\"From graph start\t\"  ".
   "GPRINT:correl_a:\"%6.2lf\t\"  ".
   "GPRINT:co_limit_a:\"\t%Y-%m-%d\":strftime  ".
   "COMMENT:\" \l\"  ".
   "LINE2:fyline_b#CC000098:\"From 3 days ago \t\"  ".
   "GPRINT:correl_b:\"%6.2lf\t\"  ".
   "GPRINT:co_limit_b:\"\t%Y-%m-%d\":strftime  ".
   "COMMENT:\" \l\"  ".
   "LINE2:fyline_c#00CCCC98:\"From 1 week ago \t\"  ".
   "GPRINT:correl_c:\"%6.2lf\t\"  ".
   "GPRINT:co_limit_c:\"\t%Y-%m-%d\":strftime  ".
   "COMMENT:\" \l\"  ".
   "LINE2:fyline_d#0000CC98:\"From 1 month ago\t\"  ".
   "GPRINT:correl_d:\"%6.2lf\t\"  ".
   "GPRINT:co_limit_d:\"\t%Y-%m-%d\":strftime  ".
   "COMMENT:\" \l\"  ";

   //   }
   //   if($context != "host")
   //   $series = implode(' ', $series_a);
   $series .= get_time_vrule(time());
   $rrdtool_graph['series'] = $series;
   return $rrdtool_graph;
}
?>
