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
  $rrdtool_graph['end']= get_graph_end($range);
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
  $labellen=0;
  $files = glob("$bdir/*Uni*");
  $farr = array();
  foreach ($files as $file){
    $fqdn = basename($file);
    $hname = strip_domainname($fqdn);
    $labellen = strlen($hname) > $labellen ? strlen($hname) : $labellen;
    $farr[$hname] = $file;
  } 
  foreach ($farr as $hname => $rrd){
    $fname = "${rrd}/SGE Complex seq_no.rrd";
    $color = get_color($hname);
    if(is_file($fname)){
      $hlabel = str_pad($hname, $labellen);
      $series .= "DEF:${hname}='${fname}':sum:AVERAGE ";
      $series .= get_pred($hname,$color,$hlabel);
    }
  }
  $time= time();
  $series .= "VRULE:${time}#FF00ff:\"\tNow\" ";
  $rrdtool_graph['series'] = $series." ".$lseries;
  return $rrdtool_graph;

}

?>
