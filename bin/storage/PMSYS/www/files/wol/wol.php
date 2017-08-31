<!DOCTYPE html>
<html>
<head>
<title>WOL</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
<style>
<!-- a{text-decoration:none} -->
h1 span { font-size:200%; }
</style>
</head>
<body background="../../files/data/img/carbon_fibre.png">

<a href="javascript:javascript:history.go(-1)"><i><h2 style="color:green"><i class="fa fa-mail-reply"></i> &nbsp; &nbsp;inapoi la pagina anterioara</h2><span class="value_text"></i></a>

<h1><span style="color:#990000">
... sending magic packet ...
<br><br>
the local machine turns ON
<?php
     exec ( "wakeonlan 00:13:20:c7:72:76" );
?>
</span></h1>
</body>
</html>
