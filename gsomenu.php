<div class='dblist'>
<?php

$ln = (@$_GET['ln'] == 'en' || @$_GET['set_language'] == 'en') ?  'en' : 'de';
$script = !@$_GET['noscript'];
$debug = @$_GET['debug'];

/**
 * Gibt das volle GSO-Menu, gegeben in der Datei gsomenu.json, als 
 * HTML-Baumstruktur aus. Für den Ein-/Ausklappeffekt und die
 * Formatierung werden zusätzlich eine JavaScript und eine CSS-Datei
 * geladen (benötigt jQuery).
 */


if ($script) { ?>
  <script type="text/javascript">
    var base = document.location.href.split('?')[0];
    $('head base').attr('href',base); // to use relative path

    $('head').append('<link rel="stylesheet" type="text/css" href="./gsomenu.css"/>');
    $('head').append('<script type="text/javascript" src="./gsomenu.js"/>');

    // optional:
    // $('#portal-languageselector .language-en a').attr('href','?ln=en');
    // $('#portal-languageselector .language-de a').attr('href','?ln=de');
  </script>
<?php }

function menu2html($menu, $language='de', $debug=FALSE) {
	
	if(!@$menu['databases']) return;
	echo @$menu['sorted'] ? "<ul class='dbsorted'>\n" : "<ul>\n";
	foreach ($menu['databases'] as $db) {
		echo "<li>";
		$title =  @$db['title_en'];
		// uncomment for testing:
		if (!$debug) {
			if (!$title || $ln == 'de') $title = @$db['title_de'];
		}

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
			menu2html($db, $language, $debug);
		}
		echo "</li>\n";
	}
	echo "</ul>\n";
}

$menu = json_decode(file_get_contents('gsomenu.json'),1);
menu2html($menu, $ln, $debug);

?>
</div>
