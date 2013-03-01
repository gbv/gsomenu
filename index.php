<?php

$ln = (@$_GET['ln'] == 'en' || @$_GET['set_language'] == 'en') ?  'en' : 'de';

include "menu-$ln.php";

?>
