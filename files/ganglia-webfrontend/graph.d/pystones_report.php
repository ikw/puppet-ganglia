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
  foreach (glob("$bdir/*Uni*") as $rrd){
    $fqdn = basename($rrd);
    $hname = strip_domainname($fqdn);
    $fname = "${rrd}/Pystones Current.rrd";
    $color = get_color($hname);
    if(is_file($fname)){
      $series .= "DEF:${hname}='${fname}':sum:AVERAGE ";
      $lseries .= get_pred($hname,$color,$hname);
      #$lseries  .= "LINE2:${hname}#${color}:${hname} ";
    }
  }
  $time= time();
  $series .= "VRULE:${time}#FF00ff:\"\tNow\" ";
  $rrdtool_graph['series'] = $series." ".$lseries;
  return $rrdtool_graph;

}

?>
