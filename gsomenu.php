<div class='dblist'>
<?php

$language = (@$_GET['ln'] == 'en' || @$_GET['set_language'] == 'en') ?  'en' : 'de';
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
    $items = array();

    $n=0;
	foreach ($menu['databases'] as $db) {
        $html = "";

		$title = @$db["title_$language"];

        if (!$title && !$debug) $title = @$db['title_de'];
        if (!$title) $title = "???";

		$access = @$db['access'];
		$dbkey  = @$db['dbkey'];
		if ($access) {
			$html .= "<a class='dbentry' href='$access' title='$dbkey'>";
			$html .= htmlspecialchars($title);
			$html .= "</a>";
		} else {
			$html .= htmlspecialchars($title);
		}
		if (@$db['info']) {
			$html .= " <a href='".$db['info']."'><img alt='info' title='info' src='http://www.gbv.de/gsomenu/img/info.gif'></a>\n";
		}
        if ($debug) {
			$html .= " [<a href='".$db['uri']."'>$dbkey</a>]\n";
        }
		if (@$db['databases']) {
			$html .= menu2html($db, $language, $debug);
		}

        $d = sprintf("%04d",$n++);
        if (@$menu['sorted']) {
    		$items[$title.$d] = "<li>$html</li>";
        } else {
    	    $items[$d] = "<li>$html</li>";
        }
	}
    ksort($items);
	return "<ul>\n".implode("\n",$items)."</ul>";
}

$menu = json_decode(file_get_contents('gsomenu.json'),1);
echo menu2html($menu, $language, $debug);

?>
</div>
