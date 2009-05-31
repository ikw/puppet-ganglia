<?php
require_once ('ikw_common.inc');

/* Pass in by reference! */
function graph_xen_io_report(& $rrdtool_graph)
{

   global $context, $hostname, $range, $rrd_dir, $size, $strip_domainname;

   if ($strip_domainname)
   {
      $hostname = strip_domainname($hostname);
   }
   $rrdtool_graph['end'] = get_graph_end($range);
   $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
   $title = 'Xen IO';
   if ($context != "host")
   {
      $rrdtool_graph['title'] = $title;
   } else
   {
      $rrdtool_graph['title'] = "$hostname $title last $range";
   }
   $series .= "";
   $lseries .= "";
   $rrdtool_graph['vertical-label'] = 'Read (-)/Write (+)';
   $rrdtool_graph['extras'] = '--rigid';
   $bdir = dirname($rrd_dir);
   $fprefix = "Xen IO";
   if ($context != 'host')
      $files = glob("$bdir/*Uni*/${fprefix}*.rrd");
   else
      $files = glob("$rrd_dir/${fprefix}*.rrd");
   $labellen = 0;
   $domains = array ();
   foreach ($files as $rrd)
   {
      $mtch = array ();
      $res = preg_match('/.*Xen\ IO\ (.*)\ (.*).rrd/', $rrd, $mtch);
      if ($res != 0)
      {
         $domains[$mtch[2]][$mtch[1]] = $rrd;
         $labellen = strlen("$mtch[2] $mtch[1]") > $labellen ? strlen("$mtch[2] $mtch[1]") : $labellen;
      }
   }
   foreach ($domains as $domain => $value)
   {
      foreach ($value as $type => $rrd)
      {
         if ($type == "write")
         {
            $series .= "DEF:'${domain}write'='${rrd}':'sum':AVERAGE ";
            $series .= get_pred("${domain}write", get_color("${domain} ${type}"), str_pad("${domain} ${type}", $labellen), "AREA");
         } else
            if ($type == "read")
            {
               $series .= "DEF:'${domain}read1'='${rrd}':'sum':AVERAGE " .
                     "CDEF:'${domain}read'=0,${domain}read1,- ";
            $series .= get_pred("${domain}read", get_color("${domain} ${type}"), str_pad("${domain} ${type}", $labellen), "AREA");
            }
      }
   }
   $series .= " HRULE:0#000000 ";
   $series .= get_time_vrule(time());
   $rrdtool_graph['series']= $series;
   
   return $rrdtool_graph;
}
?>