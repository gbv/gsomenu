Der Aufbau des Datenbankmenu ist in der Datei `menu.yaml` konfiguriert.  Das
Skript `makemenu.pl` erzeugt daraus die Datei `gsomenu.json`, in der Inhalt des
gesamten Datenbankmenu enthalten ist.

Die HTML-Ansicht des Datenbankmenu wird in der Datei `index.php` erzeugt.

    *.yaml ---makemenu.pl---> gsomenu.json ---index.php---> HTML

