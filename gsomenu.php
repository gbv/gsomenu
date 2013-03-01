<?php
/**
 * Gibt das volle GSO-Menu, gegeben in der Datei gsomenu.json, als 
 * HTML-Baumstruktur aus. Für den Ein-/Ausklappeffekt und die
 * Formatierung werden zusätzlich eine JavaScript und eine CSS-Datei
 * geladen (benötigt jQuery).
 */
?>
<script type="text/javascript">
var base = document.location.href.split('?')[0];
$('head base').attr('href',base); // to use relative path

$('head').append('<link rel="stylesheet" type="text/css" href="./gsomenu.css"/>');
// optional:
$('#portal-languageselector .language-en a').attr('href','?ln=en');
$('#portal-languageselector .language-de a').attr('href','?ln=de');
</script>
<script type="text/javascript" src="./gsomenu.js"></script>
<?php

$ln = (@$_GET['ln'] == 'en' || @$_GET['set_language'] == 'en') ?  'en' : 'de';

$gsomenu = json_decode(file_get_contents('gsomenu.json'),1);

function dbmenu($menu) {
	if(!@$menu['databases']) return;
	echo @$menu['sorted'] ? "<ul class='dbsorted'>\n" : "<ul>\n";
	foreach ($menu['databases'] as $db) {
		echo "<li>";
		$title =  @$db['title_en'];
		// uncomment for testing:
		if (!$title || $ln == 'de') $title = @$db['title_de'];

		$access = @$db['access'];
		$dbkey  = @$db['dbkey'];
		if ($access) {
			echo "<a class='dbentry' href='$access' title='$dbkey'>";
			echo htmlspecialchars($title);
			echo "</a>";
		} else {
			echo htmlspecialchars($title);
		}
		if (@$db['info']) {
			echo " <a href='".$db['info']."'><img alt='info' title='info' src='http://www.gbv.de/gsomenu/img/info.gif'></a>\n";
		}
		if (@$db['databases']) {
			dbmenu($db);
		}
		echo "</li>\n";
	}
	echo "</ul>\n";
}

echo "<div class='dblist'>";
dbmenu($gsomenu);
echo "</div>";

?>


