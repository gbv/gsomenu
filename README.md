Dieses Repository enthält Konfiguration des Datenbankverzeichnis (aka GSO-Menü),
das unter <http://www.gbv.de/gsomenu/> angezeigt wird.

Wesentlich für die Darstellung des GSO-Menü ist lediglich die Datei
`gsomenu.json` in diesem Repository. Die Datei lässt sich mit dem Skript
`update` aus folgenden Datenquellen aktualisieren:
 
* `menu.yaml`: Definition der Menustruktur

* GBV-Datenbankverzeichnis (<http://uri.gbv.de/database/>) als Linked Open Data

* `databases.csv`: Konfiguration englischer Titel und Info-URLs für Datenbanken.
  Diese Informationen sollen in Zukunft auch im Datenbankverzeichnis
  verwaltet werden, so dass diese Datei dann überflüssig wird!

Das Skript `update` benötigt Perl ab Version 5.14 und verschiedene Perl-Module,
die mittels [cpanminus](https://metacpan.org/pod/App::cpanminus) installiert
werden können. Insgesamt lässt sich ein Update folgendermaßen durchführen:

```.bash
$ git clone git@github.com:gbv/gsomenu.git
$ sudo apt-get install cpanminus # einmalig, falls cpanm nicht installiert
$ sudo cpanm --installdeps .     # einmalig oder bei Systemänderungen
$ ./update
$ git push origin master
```
