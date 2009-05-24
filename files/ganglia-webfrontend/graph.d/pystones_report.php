<?php

require_once('ikw_common.inc');

/* Pass in by reference! */
function graph_pystones_report ( &$rrdtool_graph ) {

  global $context,
	 $cpu_num_color,
	 $cpu_user_color,
	 $hostname,
	 $load_one_color,
	 $num_nodes_color,
	 $proc_run_color,
	 $range,
	 $rrd_dir,
	 $size,
	 $strip_domainname;

  if ($strip_domainname) {
    $hostname = strip_domainname($hostname);
  }
  $rrdtool_graph['end']= get_graph_end($range);
  $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
  $title = 'Pystones';
  if($context != "host"){
    $rrdtool_graph['title'] = $title;
  }else{
    $rrdtool_graph['title'] = "$hostname $title last $range";
  }
  $series .="";
  $lseries .="";
  $rrdtool_graph['lower-limit']    = '0';
  $rrdtool_graph['vertical-label'] = 'Pystones';
  $rrdtool_graph['extras']         = '--rigid';
  $bdir = dirname($rrd_dir);
  $fprefix="Pystones Current";
  
  if($context != 'host')
      $files= glob("$bdir/*Uni*/${fprefix}*.rrd");
   else
      $files= glob("$rrd_dir/${fprefix}*.rrd");
   $labellen= 0;
   foreach ($files as $rrd){
    $fqdn = basename(dirname($rrd));
    $hname = strip_domainname($fqdn);
    $labellen = strlen($hname) > $labellen ? strlen($hname) : $labellen;
   }
  foreach ($files as $rrd){
    $fqdn = basename(dirname($rrd));
    $hname = strip_domainname($fqdn);
    $color = get_color($hname);
    if(is_file($rrd)){
      $series .= "DEF:${hname}='${rrd}':sum:AVERAGE ";
      $lseries .= get_pred($hname,$color,str_pad($hname,$labellen));
    }
  }
  
 $lseries .= get_time_vrule(time());
  $rrdtool_graph['series'] = $series." ".$lseries;
  return $rrdtool_graph;

}

?>
