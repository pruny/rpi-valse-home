<?php
$dir    = '../csv/';
$files1 = array_diff(scandir($dir), array('..', '.'));
//print_r($files1);
//echo(json_encode($files1));
echo(implode(",", $files1));
?>
