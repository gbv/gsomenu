Dieses Repository enthält Konfiguration des Datenbankverzeichnis (aka GSO-Menu),
das unter <http://www.gbv.de/gsomenu/> angezeigt wird. Das Verzeichnis speist
sich aus folgenden Quellen:

* `menu.yaml`: Definition der Menustruktur

* GBV-Datenbankverzeichnis (<http://uri.gbv.de/database/>) als Linked Open Data

* `databases.csv`: Konfiguration englischer Titel und Info-URLs für Datenbanken.
  Diese Informationen sollen in Zukunft auch im Datenbankverzeichnis
  verwaltet werden, so dass diese Datei dann überflüssig wird!

Aus diesen Quellen erzeugt das Skript `makemenu.pl` die Datei `gsomenu.json`,
in der Inhalt des gesamten Datenbankmenu enthalten ist.

Die Aktualisierung wird per WebHook von GitHub getriggert. Dazu müssen alle
Dateien der Gruppe www-data gehören:

    chmod -R g+w .
    chown -R `whoami`:www-data .

Außerdem muss bei GitHub die deploy-URL als WebHook eingetragen werden.
