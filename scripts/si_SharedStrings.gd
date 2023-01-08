extends Node

enum Lang {en,fr,cs} #Custim language/locale system for displaying multiple languages at once

var file = File.new()

var items = [PoolStringArray(),PoolStringArray(),PoolStringArray()]
var seasons = [PoolStringArray(),PoolStringArray(),PoolStringArray()]
var csv = [PoolStringArray(),PoolStringArray(),PoolStringArray()]

#var _items_en = load("res://props/setups/Data/String/item-en.csv")
#var _items_fr = load("res://props/setups/Data/String/item-fr.csv")
#var _items_cs = load("res://props/setups/Data/String/item-cs.csv")

func _enter_tree():
	file.open("res://props/setups/Data/String/items.csv",file.READ)
#	for fi in file.get_len()
	var _csv_i = 0
#	for x in range(2):
#		csv.append([])
#		csv[x] = []
#		for y in range(_csv1.size()):
#			csv[x].append([])
#			csv[x][y]=""
#	var _csv1 = file.get_csv_line(";")
#	csv[0] = (_csv1 as PoolStringArray)
	while !file.eof_reached():
		csv[_csv_i] = file.get_csv_line(";")
		_csv_i += 1
#        if csv.size()>=7:
#                if csv[2] != groupname:
#                        groupname=csv[2]

	file.close()
	items[Lang.en] = csv[0]
	items[Lang.fr] = csv[1]
	items[Lang.cs] = csv[2]
	
	csv = [PoolStringArray(),PoolStringArray(),PoolStringArray()]
	file.open("res://props/setups/Data/String/seasons.csv",file.READ)
#	for fi in file.get_len()
	_csv_i = 0
	while !file.eof_reached():
		csv[_csv_i] = file.get_csv_line(";")
		_csv_i += 1
	file.close()
	seasons[Lang.en] = csv[0]
	seasons[Lang.fr] = csv[1]
	seasons[Lang.cs] = csv[2]
	print(items)
	print(items[2])
	
