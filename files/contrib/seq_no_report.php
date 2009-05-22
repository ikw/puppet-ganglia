<?php

require_once('ikw_common.inc');

/* Pass in by reference! */
function graph_seq_no_report ( &$rrdtool_graph ) {

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
  $title = 'SGE Seq_no';
  if ($context != 'host') {
    $rrdtool_graph['title'] = $title;
  } else {
    $rrdtool_graph['title'] = "$hostname $title last $range";
  }
  $series .="";
  $lseries .="";
  $rrdtool_graph['lower-limit']    = '0';
  $rrdtool_graph['vertical-label'] = 'Seq_no';
  $rrdtool_graph['extras']         = '--rigid';
  $bdir = dirname($rrd_dir);
  $firstcol=10;
  foreach (glob("$bdir/*Uni*") as $rrd){
    $fqdn = basename($rrd);
    $hname = strip_domainname($fqdn);
    $fname = "${rrd}/SGE Complex seq_no.rrd";
    $color = rgb2html(rand($firstcol,150),rand($firstcol,150),rand($firstcol,100));
    $firstcol += 10;
    if(is_file($fname)){
      $series .= "DEF:${hname}='${fname}':sum:AVERAGE ";
      $lseries  .= "LINE2:${hname}#${color}:${hname} ";
    }
  }
  /* if( $context != 'host' ) {
     $series .="DEF:'num_nodes'='${rrd_dir}/cpu_num.rrd':'num':AVERAGE ";
     $series .= "AREA:'num_nodes'#$num_nodes_color:'Nodes' ";
     }
   */
  //    $series .="LINE2:'cpu_num'#$cpu_num_color:'CPUs' ";
  //    $series .="LINE2:'proc_run'#$proc_run_color:'Running Processes' ";

  $rrdtool_graph['series'] = $series." ".$lseries;
#var_dump($rrdtool_graph['series']);
  return $rrdtool_graph;

}

?>
