<?php


// This report is used for specific metric graphs at the bottom of the
// cluster_view page.
include ('ikw_common.inc');

/* Pass in by reference! */
function graph_metric(& $rrdtool_graph)
{
   global $context, $default_metric_color, $hostname, $jobstart, $load_color, $max, $meta_designator, $metricname, $metrictitle, $min, $range, $rrd_dir, $size, $summary, $value, $vlabel, $strip_domainname;
   if ($strip_domainname)
   {
      $hostname = strip_domainname($hostname);
   }

   $rrdtool_graph['height'] += 0; //no fudge needed
   $rrdtool_graph['end'] = get_graph_end($range);
   switch ($context)
   {

      case 'host' :

         if ($summary)
         {
            $rrdtool_graph['title'] = $hostname;
            $prefix = $metricname;
         } else
         {
            $prefix = $hostname;
            if ($metrictitle)
            {
               $rrdtool_graph['title'] = "$metrictitle last $range";
            } else
            {
               $rrdtool_graph['title'] = "$metricname last $range";
            }
         }

         $prefix = $summary ? $metricname : $hostname;
         $value = ($value > 1000) ? number_format($value) : number_format($value, 2);

         if ($range == 'job')
         {
            $hrs = intval(- $jobrange / 3600);
            $subtitle = "$prefix last ${hrs} (now $value)";
         } else
         {
            if ($summary)
            {
               $subtitle_one = "$metricname";
            } else
            {
               $subtitle_one = "$hostname";
            }
            $subtitle_two = "  (now $value)";
         }

         break;

      case 'meta' :
         $rrdtool_graph['title'] = "$meta_designator ".$rrdtool_graph['title']."last $range";
         break;

      case 'grid' :
         $rrdtool_graph['title'] = "$meta_designator ".$rrdtool_graph['title']."last $range";
         break;

      case 'cluster' :
         $rrdtool_graph['title'] = "$clustername ".$rrdtool_graph['title']."last $range";
         break;

      default :
         if ($size == 'small')
         {
            $rrdtool_graph['title'] = $hostname;
         } else
            if ($summary)
            {
               $rrdtool_graph['title'] = $hostname;
            } else
            {
               $rrdtool_graph['title'] = $metricname;
            }
         break;

   }

   if ($load_color)
      $rrdtool_graph['color'] = "BACK#'$load_color'";

   if (isset ($max) && is_numeric($max))
      $rrdtool_graph['upper-limit'] = $max;

   if (isset ($min) && is_numeric($min))
      $rrdtool_graph['lower-limit'] = $min;

   if ($vlabel)
   {
      // We should set $vlabel, even if it isn't used for spacing
      // and alignment reasons.  This is mostly for aesthetics
      $temp_vlabel = trim($vlabel);
      $rrdtool_graph['vertical-label'] = strlen($temp_vlabel) ? $temp_vlabel : ' ';
   } else
   {
      $rrdtool_graph['vertical-label'] = ' ';
   }
   //# the actual graph...
   $series = "DEF:'sum'='$rrd_dir/$metricname.rrd:sum':AVERAGE ";
   $series .= get_pred('sum', get_color($rrdtool_graph["vertical-label"]), $subtitle_one, "AREA");
   //$series .= "COMMENT:'$subtitle_two'";

   if ($jobstart)
   {
      $series .= "VRULE:$jobstart#$jobstart_color ";
   }
   $series .= " ".get_time_vrule(time());
   $rrdtool_graph['series'] = $series;

   return $rrdtool_graph;

}
?>
