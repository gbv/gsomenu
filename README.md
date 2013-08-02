Dieses Repository enthält Konfiguration des Datenbankverzeichnis (aka GSOMenu),
das unter <http://www.gbv.de/gsomenu/> angezeigt wird. Das Verzeichnis speist
sich aus folgenden Quellen:

* Menustruktur - in der Datei `menu.yaml`.
* Datenbankverzeichnis (aka unAPI-Konfiguration) als Linked Open Data von
  <http://uri.gbv.de/database/>
* Zusätzliche Datenbankinformationen, die noch nicht als Linked Open Data
  vorhanden sind - in der Datei `databases.yaml`.

Aus diesen Quellen erzeugt das Skript `makemenu.pl` die Datei `gsomenu.json`,
in der Inhalt des gesamten Datenbankmenu enthalten ist.

Die HTML-Ansicht des Datenbankmenu wird aus `gsomenu.json` durch Aufruf der
Datei `index.php` erzeugt. Je nach Sprache (URL-Parameter `ln` oder
`set_language`) wird entweder das Deutsche oder das Englische Verzeichnis
angezeigt. Die Dateien `menu-de.php` bzw. `menu-en.php` enthalten dazu die
gesamte Webseite (angepasste Kopie aus dem Plone-CMS) auf Deutsch bzw. auf
Englisch, wobei an einer Stelle das Menu mit `gsomenu.php` eingebunden wird.

