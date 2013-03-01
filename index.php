<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<?php 
$ln = @$_GET['ln'] == 'en' ? 'en' : 'de';
echo "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='$ln' lang='$ln'>\n";
?>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="css/gsomenu.css" />
    <script type="text/javascript" src="http://www.gbv.de/++resource++plone.app.jquery.js"></script>
    <script type="text/javascript" src="js/gsomenu.js"></script>
    <title>Datenbanken &mdash; Verbundzentrale des GBV</title>
    <link rel="shortcut icon" type="image/x-icon" href="http://www.gbv.de/favicon.ico" />
    <link rel="home" href="http://www.gbv.de" title="Startseite" />
    <link rel="contents" href="http://www.gbv.de/sitemap" title="Übersicht" />
    <link rel="search" href="http://www.gbv.de/search_form" title="Search this site" />
    <!-- Disable IE6 image toolbar -->
    <meta http-equiv="imagetoolbar" content="no" />
  </head>
  <body>
    <div id="main"> 
      <div id="header"> 
	    <ul id="portal-languageselector" style="margin: 0; padding: 0 0 5px 1em; z-index: 1; float:right;">
		<li class="<?php if ($ln == 'en') echo 'currentLanguage' ?> language-en">
            <a title="English" href="?ln=en">
              <img width="14" height="11" src="https://www.gbv.de/++resource++country-flags/gb.gif" title="English" alt="English">
            </a>
          </li>
		<li class="<?php if ($ln == 'de') echo 'currentLanguage' ?> language-de">
          <li class="language-de">
            <a title="Deutsch" href="?ln=de">
             <img width="14" height="11" src="https://www.gbv.de/++resource++country-flags/de.gif" title="Deutsch" alt="Deutsch">
            </a>
          </li>
        </ul>
      </div> 
      <ul id="globalnav">
        <li id="portaltab-index_html"><a href="http://www.gbv.de">Startseite</a></li>
        <li id="portaltab-benutzer"><a href="http://www.gbv.de/benutzer">Benutzer</a></li>
        <li id="portaltab-bibliotheken"><a href="http://www.gbv.de/bibliotheken">Bibliotheken</a></li>
        <li id="portaltab-Verbundzentrale"><a href="http://www.gbv.de/Verbundzentrale">Verbundzentrale</a></li>
        <li id="portaltab-Verbund"><a href="http://www.gbv.de/Verbund">Verbund</a></li>
        <li id="portaltab-Termine"><a href="http://www.gbv.de/Termine">Termine</a></li>
        <li id="portaltab-news"><a href="http://www.gbv.de/news">Aktuelles</a></li>
        <li id="portaltab-kontakt"><a href="http://www.gbv.de/kontakt">Kontakt</a></li>
      </ul>
      <div id="content"> 
        <div id="content-wrapper">
          <div id="breadcrumbs">
            sie sind hier:
            <a href="http://www.gbv.de">Startseite</a>
            › Datenbanken 
          </div>
          <div class="dblist">
            <h1 id="togglebds">Datenbanken</h1>
<?php

$gsomenu = json_decode(file_get_contents('gsomenu.json'),1);

function dbmenu($menu) {
	if(!@$menu['databases']) return;
	echo @$menu['sorted'] ? "<ul class='dbsorted'>\n" : "<ul>\n";
	foreach ($menu['databases'] as $db) {
		echo "<li>";
		$title  = @$db['title_de'];
		$access = @$db['access'];
		$dbkey  = @$db['dbkey'];
		if ($access) {
			echo "<a class='dbentry' href='$access' title='$dbkey'>";
			echo htmlspecialchars(@$title);
			echo "</a>";
		} else {
			echo htmlspecialchars(@$title);
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

dbmenu($gsomenu);

?>
          </div>
          <p>
            Sie haben keinen Zugriff?
            <a href="http://www.gbv.de/benutzer/datenbanken/zugangsprobleme">Dann schauen Sie bitte hier!</a>
          </p>
          <p>
            Informationen über <a href="http://www.gbv.de/benutzer/faq/sfx">SFX</a> 
            und <a href="http://www.gbv.de/benutzer/z39.50-zugang/informationen-zum-z39.50-zugang-des-gbv">Literaturverwaltungsprogramme (Z39.50)</a>
          </p>
        </div>
      </div>
      <div id="nav">
        <dl>
          <dt><a href="#">Datenbanken</a></dt>
          <dd></dd>
          <dt>Digitale Bibliothek</dt>
          <dd>
            <ul class="navTree">
              <li><a href="http://www.gbv.de/digitale-bibliothek">Übersicht</a></li>
            </ul>
          </dd>
          <dt><a href="http://www.gbv.de/sitemap">Informationen</a></dt>
          <dd>
            <ul class="navTree">
              <li><a href="http://www.gbv.de/benutzer">Benutzer</a></li>
              <li><a href="http://www.gbv.de/bibliotheken">Bibliotheken</a></li>
              <li><a href="http://www.gbv.de/Verbundzentrale">Verbundzentrale</a></li>
              <li><a href="http://www.gbv.de/Verbund">Verbund</a></li>
              <li><a href="http://www.gbv.de/Termine">Termine</a></li>
              <li><a href="http://www.gbv.de/news">Aktuelles</a></li>
              <li><a href="http://www.gbv.de/kontakt">Kontakt</a></li>
            </ul>
          </dd>
          <dt></dt>
          <dd>
            <form action="http://www.gbv.de/vzgsearchform" method="post" enctype="multipart/form-data" id="search">
              <input name="form.catalog-empty-marker" type="hidden" value="1" />
              <div>
                <input class="textType" id="form.q" name="form.q" size="15" type="text" />
              </div>
              <div>
                <input type="submit" id="form.actions.submit" name="form.actions.submit" value="Suche" class="submit" />
              </div>
              <div>
                <input type="radio" id="form.catalog" name="form.catalog" value="GVK" checked="checked" />
                Verbundkatalog <br/>
                <input type="radio" id="form.catalog" name="form.catalog" value="Website" />
                GBV-Website
              </div>
            </form>
          </dd>
        </dl>
      </div>
      <div class="clearboth"><!-- --></div>
      <div id='footer'>
        <ul>
          <li>
            <a href="http://www.gbv.de/kurz">Abkürzungen</a>
          </li>
          <li>
            <a href="http://www.gbv.de/impressum">Impressum</a>
          </li>
          <li>
            <a href="http://www.gbv.de/urn">URN</a>
          </li>
          <li>
            <a href="http://www.gbv.de/links">Links</a>
          </li>
        </ul>
      </div>
    </div> <!-- main -->
  </body> 
</html>
