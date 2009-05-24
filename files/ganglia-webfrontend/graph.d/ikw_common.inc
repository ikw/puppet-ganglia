<?php
function rgb2html($r, $g= -1, $b= -1) {
   if(is_array($r) && sizeof($r) == 3)
      list($r, $g, $b)= $r;

   $r= intval($r);
   $g= intval($g);
   $b= intval($b);

   $r= dechex($r < 0 ? 0 :($r > 255 ? 255 : $r));
   $g= dechex($g < 0 ? 0 :($g > 255 ? 255 : $g));
   $b= dechex($b < 0 ? 0 :($b > 255 ? 255 : $b));

   $color=(strlen($r) < 2 ? '0' : '').$r;
   $color .=(strlen($g) < 2 ? '0' : '').$g;
   $color .=(strlen($b) < 2 ? '0' : '').$b;
   return $color;
}

function get_color($string) {
   return substr(md5($string), 0, 6);
}

function get_pred($var, $color, $label, $graphtype= "LINE2") {
   $graphline = "${graphtype}:${var}#${color}:\"${label}\"";
   
   if($graphtype == "AREA" || $graphtype == "STACK"){
      $graphline = "CDEF:${var}_by_16=${var},16,/  " .
                  "${graphtype}:${var}#${color}11  " .
                  "AREA:${var}_by_16#${color}00  " .
                  "AREA:${var}_by_16#${color}10::STACK  " .
                  "AREA:${var}_by_16#${color}20::STACK  " .
                  "AREA:${var}_by_16#${color}30::STACK  " .
                  "AREA:${var}_by_16#${color}40::STACK  " .
                  "AREA:${var}_by_16#${color}50::STACK  " .
                  "AREA:${var}_by_16#${color}60::STACK  " .
                  "AREA:${var}_by_16#${color}70::STACK  " .
                  "AREA:${var}_by_16#${color}80::STACK  " .
                  "AREA:${var}_by_16#${color}84::STACK  " .
                  "AREA:${var}_by_16#${color}88::STACK  " .
                  "AREA:${var}_by_16#${color}91::STACK  " .
                  "AREA:${var}_by_16#${color}93::STACK  " .
                  "AREA:${var}_by_16#${color}95::STACK  " .
                  "AREA:${var}_by_16#${color}97::STACK  " .
                  "AREA:${var}_by_16#${color}99::STACK  " .
                  "LINE:${var}#${color}:\"${label}\" ";  
   }
   
   return "VDEF:${var}slope=${var},LSLSLOPE \
         VDEF:${var}lslint=${var},LSLINT \
         VDEF:${var}cor=${var},LSLCORREL \
         CDEF:${var}pred=${var},POP,${var}lslint,${var}slope,COUNT,*,+ \
         LINE2:${var}pred#${color}::dashes=2,5 \
         ${graphline} \
         GPRINT:${var}:AVERAGE:\"%6.2lf%s\" \
         GPRINT:${var}pred:AVERAGE:\"pred\: %6.2lf%s\" \
         GPRINT:${var}cor:\"corr\: %1.2lf\l\" ";

}

function get_graph_end($range) {
   $end= "";
   
   switch($range) {
      case "day" :
         $end= '+6h';
         break;
      case "week" :
         $end= '+3d';
         break;
      case "month" :
         $end= '+2w';
         break;
      case "year" :
         $end= '+4m';
         break;
      default :
         $end= '+30m';
         break;
   }
   return $end;
}

function get_time_vrule($time= "") {
   if (!is_int($time))
      $time= time();
   return "VRULE:${time}#B00CF4:\"\tNow\" ";
}

?>
