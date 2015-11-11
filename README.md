Dieses Repository enthält Konfiguration des Datenbankverzeichnis (aka GSO-Menü),
das unter <http://www.gbv.de/gsomenu/> angezeigt wird.

Wesentlich für die Darstellung des GSO-Menü ist lediglich die Datei
`gsomenu.json` in diesem Repository, die in regelmäßigen Abständen abgefragt
wird. Die Datei lässt sich mit dem Skript `update` aus folgenden Datenquellen
aktualisieren:
 
* `menu.yaml`: Definition der Menustruktur

* GBV-Datenbankverzeichnis (<http://uri.gbv.de/database/>) als Linked Open Data

* `databases.csv`: Konfiguration englischer Titel und Info-URLs für Datenbanken.
  Diese Informationen sollen in Zukunft auch im Datenbankverzeichnis
  verwaltet werden, so dass diese Datei dann überflüssig wird!

Fehlende Englische Datenbanknamen werden in `error.log` protokolliert.

Das Skript `update` benötigt Perl ab Version 5.14 und drei Perl Module. Am
einfachsten ist die Installation als Debian/Ubuntu-Package:

```.bash
sudo apt-get install libcatmandu-perl libcatmandu-importer-getjson-perl libhash-merge-perl
```
Anschließend lässt sich ein Update folgendermaßen durchführen:

```.bash
$ git clone git@github.com:gbv/gsomenu.git
$ # ggf. menu.yaml/databases.csv bearbeiten und committen
$ ./update
$ git diff # zeigt an, was geändert wurde
$ git add gsomenu.json
$ git push origin master
```
