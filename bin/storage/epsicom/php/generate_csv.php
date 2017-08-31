<?php

if (isset($_POST['module']) && isset($_POST['id'])) {

  function ss_to_hhmmss($tm) {
    $hh = (int)($tm / 3600);
    $mm = (int)(($tm-($hh*3600)) / 60);
    $ss = (int)($tm-($hh*3600)-($mm*60));

    return sprintf('%02d:%02d:%02d',$hh,$mm,$ss);
  }

  $db = new SQLite3('../storage/pwm.db');
  $query="SELECT start,end,value,enabled FROM configs where group_id=:module and id=:id ORDER BY start;";

  $statement = $db->prepare($query);
  $statement->bindValue(':id', $_POST['id']);
  $statement->bindValue(':module', $_POST['module']);

  $result = $statement->execute();

  $file = fopen(sprintf('../csv/%02d.%02d.csv', $_POST['module'], $_POST['id']),"w");

  //$header = array("MD", "ID", "START", "END", "VAL", "CFG");
  $header = array("START", "END", "VAL", "CFG");
  fputcsv($file,$header);

  while ($row = $result->fetchArray(SQLITE3_NUM)) {
    $row[0]=ss_to_hhmmss($row[0]);
    $row[1]=ss_to_hhmmss($row[1]);
    fputcsv($file,$row);
  }

  fclose($file);
}
else {
  echo("ERROR");
}

?>
