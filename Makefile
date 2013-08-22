gsomenu.json: menu.yaml databases.csv
	@echo "Updating gsomenu.json"
	@./makemenu.pl

alle-gsomenu-datenbanken.csv: gsomenu.json
	@./json2csv.pl
