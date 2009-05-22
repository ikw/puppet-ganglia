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
  $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
  $title = 'Pystones';
    $rrdtool_graph['title'] = $title;
  #  $rrdtool_graph['title'] = "$hostname $title last $range";
  $series .="";
  $lseries .="";
  $rrdtool_graph['lower-limit']    = '0';
  $rrdtool_graph['vertical-label'] = 'Pystones';
  $rrdtool_graph['extras']         = '--rigid';
  $bdir = dirname($rrd_dir);
  $firstcol=10;
  foreach (glob("$bdir/*Uni*") as $rrd){
    $fqdn = basename($rrd);
    $hname = strip_domainname($fqdn);
    $fname = "${rrd}/Pystones Current.rrd";
    $color = rgb2html(rand($firstcol,150),rand($firstcol,150),rand($firstcol,100));
    $firstcol += 10;
    if(is_file($fname)){
      $series .= "DEF:${hname}='${fname}':sum:AVERAGE ";
      $lseries  .= "LINE2:${hname}#${color}:${hname} ";
    }
  }
  $rrdtool_graph['series'] = $series." ".$lseries;
  return $rrdtool_graph;

}

?>
