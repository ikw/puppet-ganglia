<?php

require_once('ikw_common.inc');

/* Pass in by reference! */
function graph_workusage_report ( &$rrdtool_graph ) {

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

  $title = 'Work Usage';
  if($context != "host")
    $rrdtool_graph['title']= $title;
  else
    $rrdtool_graph['title']= "$hostname $title last $range";
  $series .="";
  $lseries .="";
  $rrdtool_graph['lower-limit']    = '1';
  $rrdtool_graph['vertical-label'] = 'Usage in Megabytes';
  $rrdtool_graph['extras']= ' --slope-mode --logarithmic ';
  $bdir = dirname($rrd_dir);
  $userarr=array();
  $labellen=0;
  $fprefix= "workusage_";
  $files= glob("$rrd_dir/${fprefix}*.rrd");
  $labellen= 0;
  if(count($files) == 0)
    return "";
  foreach ($files as $rrd){
    $fname = basename($rrd);
    $user = preg_replace("/workusage_(.*).rrd/","$1",$fname);

    if (! array_key_exists($user,$userarr))
      $userarr[$user]=array();
    $userarr[$user][]=$rrd;
    $labellen = (strlen($user) > $labellen) ? strlen($user) : $labellen;
  }
  ksort($userarr);
  foreach($userarr as $user => $rrds){
    $user= is_int($user) ? "_$user" : $user;
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
    $color = get_color($user);
    $label = str_pad($user,$labellen);
    $pseries .= get_pred($user, $color,$label);
  }
  $lseries .= get_time_vrule(time());
  $rrdtool_graph['series']= $series." ".$pseries." ".$lseries;
  return $rrdtool_graph;

}

?>
