<!DOCTYPE html>
<html>
	<head>
		<link href="css/style.css" rel="stylesheet" type="text/css">
		<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
		<meta http-equiv="refresh" content="5">
		<meta charset="utf-8" />
		<title>POWER STATUS</title>
	</head>
	<body>

    <div id="container">
	<!-- On/Off button's picture -->


	<?php
	//this php script generate the first page in function of the gpio's status

		//INPUTS
		$current_label = 0;
		$status = array (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		$labels = array (
		//  Sensor Labels
		"RETEA CLADIRE",
		"PORNIRE GENERATOR",
		"GENERATOR",
		"SYMMETRA",
		"REZERVA",
		"APC4    RACK#1~4   ",
		"APC5    RACK5~7bis",
		"APC7.1  RACK7",
		"APC7.2  RACK7",
		"APC8    RACK8",
		"APC9.1  RACK9",
		"APC9.2  RACK9",
		"APC10.1 RACK10",
		"APC10/2 RACK10",
		"REZERVA"
		);
		//the used pins are: 0, 2, 3, 4, 5, 21, 22, 23, 24, 25, 26, 28, 29

		echo("<br><br>");
		echo('<div class="warning"><div class="main_text"><h1 style="color:red">&nbsp; &nbsp; ALIMENTARE CU ELECTRICITATE</h1><span class="value_text"></div></div>');

		foreach (array(0,2,3,26,6) as $index=>$i) {
		//set the pin's mode to input and read them
		system("gpio mode ".$i." in");
		exec ("gpio read ".$i, $status[$i], $return );
		if($index % 5 == 0) { echo("<br>"); }
		//if off
		if ($status[$i][0] == 0 ) {
		echo ("<div class='btn_div'><a class='btn_off' rel='external' id='button_".$i."' target='off'>&#xf046;</a><span id='light_red'></span><div class='btn_label'><h4>".$labels[$current_label]."</h4></div></div>");
		}
		//if on
		if ($status[$i][0] == 1 ) {
		echo ("<div class='btn_div'><a class='btn_on' rel='external' id='button_".$i."' target='on'>&#xf046;</a><span id='light_green'></span><div class='btn_label'><h4>".$labels[$current_label]."</h4></div></div>");
		}
		//go to next label
		$current_label++;
		}

		echo("<br><br>");
		echo('<div class="warning"><div class="main_text"><h1 style="color:orange">&nbsp; &nbsp; STARE UPS-uri / RACK-uri</h1><span class="value_text"></div></div>');

		foreach (array(21,22,23,24,25,4,5,28,29,27) as $index=>$i) {
		//set the pin's mode to input and read them
		system("gpio mode ".$i." in");
		exec ("gpio read ".$i, $status[$i], $return );
		if($index % 5 == 0) { echo("<br>"); }
		//if off
		if ($status[$i][0] == 0 ) {
		echo ("<div class='btn_div'><a class='btn_off' rel='external' id='button_".$i."' target='off'>&#xf046;</a><span id='light_red'></span><div class='btn_label'><h4>".$labels[$current_label]."</h4></div></div>");
		}
		//if on
		if ($status[$i][0] == 1 ) {
		echo ("<div class='btn_div'><a class='btn_on' rel='external' id='button_".$i."' target='on'>&#xf046;</a><span id='light_green'></span><div class='btn_label'><h4>".$labels[$current_label]."</h4></div></div>");
		}
		//go to next label
		$current_label++;
		}

	?>
		<br>
		<!-- All buttons = ALL -->
		<!-- <div class='btn_div'><a class='btn_off' rel='external' id='toggle_btn' target='off'>&#xF011;</a><span id='light_red'></span><h4>ALL-OUT</h4></div> -->
	</div>

		<!-- javascript -->
		<script src="js/script.js"></script>

	</body> 
</html>
