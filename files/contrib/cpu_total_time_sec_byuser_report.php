<?php

require_once('ikw_common.inc');

/* Pass in by reference! */
function cpu_total_time_sec_byuser_report ( &$rrdtool_graph ) {

  global $context,
	 $hostname,
	 $rrd_dir,
	 $size,
	 $strip_domainname;

  if ($strip_domainname) {
    $hostname = strip_domainname($hostname);
  }
  $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
  $title = 'Total CPU Time by User';
    $rrdtool_graph['title'] = $title;
  #  $rrdtool_graph['title'] = "$hostname $title last $range";
  $series .="";
  $lseries .="";
  $rrdtool_graph['lower-limit']    = '0';
  $rrdtool_graph['vertical-label'] = 'CPU Seconds';
  $bdir = dirname($rrd_dir);
  $firstcol=10;
  $userarr=array();
  $fprefix = "cpu_total_time_sec_";
  $labellength=0;
  foreach (glob("$bdir/*Uni*/${fprefix}*.rrd") as $rrd){
    $fname = basename($rrd);
    $user = preg_replace("/${fprefix}(.*).rrd/","$1",$fname);
    if (! array_key_exists($user,$userarr))
	$userarr[$user]=array();
    $userarr[$user][]=$rrd;
  }
  foreach($userarr as $user => $rrds){
	$def = "";
	$cnt = 0;
	$rpnarr = array();
	$rpnops = "";
	foreach($rrds as $rrd){
		$series .= "DEF:${user}${cnt}='${rrd}':sum:AVERAGE ";
		$rpnarr[] = "${user}${cnt}";
		if ($cnt > 0)
			$rpnops .= ",+";
		$cnt += 1;
	}
	$rpn = implode(",",$rpnarr).$rpnops;
	$series .= "CDEF:${user}=${rpn} "; 
	$color = rgb2html(rand($firstcol,150),rand($firstcol,150),rand($firstcol,100));
	$firstcol += 10;
   	$lseries  .= "LINE2:${user}#${color}:${user} ";
  }

	$rrdtool_graph['series'] = $series." ".$lseries;
	return $rrdtool_graph;

}
?>
