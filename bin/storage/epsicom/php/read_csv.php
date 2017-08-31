<?php
if (isset($_POST['file'])) {
  $csv_content = file( sprintf('../csv/%s', $_POST['file']) ) or die('{"error": "file not found"}');
  $error_desc = "";


  function hhmmss_to_seconds($time, $check=false) {
    $tm = explode(":", $time);
    if(count($tm) != 3) {
      return false;
    }

    if(!(is_numeric($tm[0])) || !(is_numeric($tm[1])) || !(is_numeric($tm[2])) ) {
      return false;
    }

    $hh = (int)$tm[0];
    $mm = (int)$tm[1];
    $ss = (int)$tm[2];
    $return_s = ($hh * 3600) + ($mm * 60) + $ss;

    if((int)$return_s < 0 || (int)$return_s > 86399) {
      return false;
    }

    if($check) {
      return true;
    } else {
      return $return_s;
    }

  }

  function check_start_end($st, $en) {
    global $error_desc;
    if(!hhmmss_to_seconds($st, $check=true) || !hhmmss_to_seconds($en, $check=true)) {
      $error_desc = "START/END format mismatch";
      return false;
    }

    if((int)$st > (int)$en) {
      $error_desc = "START TIME can't be grater than END TIME";
      return false;
    }

    return true;
  }

  function check_value($val) {
    global $error_desc;
    if(!is_numeric($val) || $val < 0 || $val > 100) {
      $error_desc = "VALUE must be a number between 0-100";
      return false;
    }

    return true;
  }

  function check_enabled($en) {
    global $error_desc;
    if(!is_numeric($en) || ((int)$en != 1 && (int)$en != 0) ) {
      $error_desc = "CFG must be 1 or 0";
      return false;
    }

    return true;
  }

  $return_array = array();

  for($i=1; $i<count($csv_content); $i++) {
    $line_array = explode(",", $csv_content[$i]);

    if( check_start_end($line_array[0], $line_array[1]) && check_value($line_array[2]) && check_enabled(trim(preg_replace('/\s\s+/', ' ', $line_array[3]))) ) {
      $row_array = array();
      $row_array["start"] = (string)hhmmss_to_seconds($line_array[0]);
      $row_array["end"] = (string)hhmmss_to_seconds($line_array[1]);
      $row_array["value"] = $line_array[2];
      $row_array["enabled"] = trim(preg_replace('/\s\s+/', ' ', $line_array[3]));
      array_push($return_array, $row_array);
    } else {
      exit( sprintf('{"error": "ERROR [LINE: %s] - %s"}',  $i+1,$error_desc) );
    }

  }

  print_r(json_encode($return_array));
} else {
  exit();
}
?>
