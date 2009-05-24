<?php
require_once('ikw_common.inc');

/* Pass in by reference! */
function graph_cpu_total_time_sec_byuser_report(& $rrdtool_graph) {

   global $context, $hostname, $rrd_dir, $size, $range, $strip_domainname;

   $rrdtool_graph['end']= get_graph_end($range);

   if($strip_domainname) {
      $hostname= strip_domainname($hostname);
   }
   $rrdtool_graph['height'] +=($size == 'medium') ? 28 : 0;
   $title= 'Total CPU Time by User';
   if($context != "host")
      $rrdtool_graph['title']= $title;
   else
      $rrdtool_graph['title']= "$hostname $title last $range";
   $series .= "";
   $lseries .= "";
   $rrdtool_graph['lower-limit']= '1';
   $rrdtool_graph['vertical-label']= 'CPU Seconds';
   $rrdtool_graph['extras']= ' --slope-mode --logarithmic ';
   $bdir= dirname($rrd_dir);
   $firstcol= 10;
   $userarr= array();
   $fprefix= "cpu_total_time_sec_";
   if($context != 'host')
      $files= glob("$bdir/*Uni*/${fprefix}*.rrd");
   else
      $files= glob("$rrd_dir/${fprefix}*.rrd");
   $labellen= 0;

   foreach($files as $rrd) {
      $fname= basename($rrd);
      $user= preg_replace("/${fprefix}(.*).rrd/", "$1", $fname);
      if(!array_key_exists($user, $userarr))
         $userarr[$user]= array();
      $userarr[$user][]= $rrd;
      $labellen= strlen($user) > $labellen ? strlen($user) : $labellen;
   }
   $first= "";
   ksort($userarr);
   foreach($userarr as $user => $rrds) {
      $user= is_int($user) ? "_$user" : $user;
      $def= "";
      $cnt= 0;
      $rpnarr= array();
      $rpnops= "";
      foreach($rrds as $rrd) {
         $series .= "DEF:${user}${cnt}='${rrd}':sum:AVERAGE ";
         $rpnarr[]= "${user}${cnt}";
         if($cnt > 0)
            $rpnops .= ",+";
         $cnt += 1;
      }
      $rpn= implode(",", $rpnarr).$rpnops;
      $series .= "CDEF:${user}=${rpn} ";
      $color= get_color($user);
      $firstcol += 10;
      $label= str_pad($user, $labellen);
      $pseries .= get_pred($user, $color, $label);
   }
   $lseries .= get_time_vrule(time());
   $rrdtool_graph['series']= $series." ".$pseries." ".$lseries;
   return $rrdtool_graph;

}
?>
