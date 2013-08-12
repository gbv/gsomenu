gsmenu.json: menu.yaml databases.yaml
	@echo "Updating gsomenu.json"
	@./makemenu.pl

alle-gsomenu-datenbanken.csv: gsomenu.json
	@./json2csv.pl
