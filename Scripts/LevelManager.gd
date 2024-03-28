class_name LevelManager extends Node2D

@export var map:TileMap;
@export var monster:Monster;
@export var hintTile:Vector2i;
@export var finishTile:Vector2i;

@export var turnButton:Button;
@export var undoButton:Button;
var moving:bool = false;
var focus:bool = false;
var mouse:bool = true;
var currentMonsterMove:Array[Vector2i];

var hints:Array[Vector2i];
@export var levelID = 1;
@export_category("Characters")
@export var Axe:Character;
@export var Bow:Character;
@export var Shield:Character;
@export var cursor:AnimatedSprite2D
var previousCursor:Vector2i;
var selected:Character;
var movePath:Array[Vector2i];

##Turn saving
var axeSave:Vector2i;
var bowSave:Vector2i;
var shieldSave:Vector2i;
var monsterSave:Vector2i;
var saveDestination:Vector2i;
var saved:bool = false;
func _ready():
	mouse = Settings.mouse;
	monster.nextTile.connect(checkAttacks)
	if(Settings.tutorialViewed == true):
		focus = true;
		displayMove();
	else:
		focus = false
func displayMove():
	currentMonsterMove = monster.decideDestination();
	saveTurn()
	for h in hints:
		map.erase_cell(2,h);
	hints.clear();
	hints.append(monster.current);
	for m in monster.shape:
		hints.append(monster.current+m)
	for t in currentMonsterMove:
		if(!hints.has(t)):
			hints.append(t)
		for n in monster.shape:
			if(!hints.has(t+n)):
				hints.append(t+n)
	for h in hints:
		map.set_cell(2,h,0,hintTile)
	var end = currentMonsterMove.back()
	map.set_cell(2,end,0,finishTile)
	for n in monster.shape:
		map.set_cell(2,end+n,0,finishTile)
	var string = "Monster will move to" + String.chr(65+currentMonsterMove.back().x) +str(currentMonsterMove.back().y)
	TTs.speak(string,false)
	turnButton.disabled = false;
func turn():
	var string = "Monster moving"
	TTs.speak(string,false)
	monster.turn();
	turnButton.release_focus()
	turnButton.disabled = true;
	await monster.moveComplete
	Axe.moved = false
	Axe.attacked = false
	Bow.moved = false
	Bow.attacked = false
	Shield.moved = false;
	Shield.attacked = false;
	if(Axe.Health.DOWN == Axe.health && Bow.Health.DOWN == Bow.health):
		endLevel();
	if(monster.health<=0):
		win();
	displayMove()

func checkAttacks(pos:Vector2i):
	if (Axe.location == pos):
		Axe.setState(Axe.Health.DOWN)
	else:
		var neighbours = map.get_surrounding_cells(Axe.location)
		for l in monster.shape:
			if (Axe.location == pos+l):
				Axe.setState(Axe.Health.DOWN)
			elif(neighbours.has(l+pos)):
				Axe.attack(monster)
	if(Bow.location == pos):
		Bow.setState(Bow.Health.DOWN)
	else:
		var neighbours = map.get_surrounding_cells(Bow.location)
		for l in monster.shape:
			if (Bow.location == pos+l):
				Bow.setState(Bow.Health.DOWN)
			elif(neighbours.has(l+pos)):
				Bow.attack(monster)
	if(Shield.location == pos):
		Shield.setState(Shield.Health.DOWN)
	else:
		var neighbours = map.get_surrounding_cells(Shield.location)
		for l in monster.shape:
			if (Shield.location == pos+l):
				Shield.setState(Shield.Health.DOWN)
			elif(neighbours.has(l+pos)):
				Shield.attack(monster)	
func endLevel():
	get_tree().reload_current_scene()

func _input(event):
	if(!moving && !mouse && focus):
		var cursorPos = map.local_to_map(cursor.position);
		var tempPos = cursorPos
		if(event.is_action_pressed("Left")):
			tempPos += Vector2i.LEFT;
		elif (event.is_action_pressed("Right")):
			tempPos += Vector2i.RIGHT;		
		elif (event.is_action_pressed("Down")):
			tempPos += Vector2i.DOWN;
		elif  (event.is_action_pressed("Up")):
			tempPos += Vector2i.UP;
		if(map.get_cell_tile_data(0,tempPos) != null):
			cursor.position = map.map_to_local(tempPos);
		if(selected != null):
			for p in movePath:
				map.erase_cell(3,p);
			if(selected.getPath(cursorPos).size()< selected.moveDistance):
				var tempPath = selected.getPath(cursorPos);
				if(!tempPath.is_empty()):
					movePath = tempPath
					for p in movePath:
						map.set_cell(3,p,0,Vector2i(0,3))
		if(event.is_action_pressed("ui_accept")):
			if(cursorPos == Axe.location):
				if !Axe.moved && !Axe.health == Axe.Health.DOWN:
					for p in movePath:
						map.erase_cell(3,p);
					movePath.clear()
					selected = Axe;
					var string = "Selected" + selected.characterName
					TTs.speak(string,false)
			elif(cursorPos == Bow.location):
				if !Bow.moved && !Bow.health == Bow.Health.DOWN:
					for p in movePath:
						map.erase_cell(3,p);
					movePath.clear()
					selected = Bow;
					var string = "Selected" + selected.characterName
					TTs.speak(string,false)
			elif(cursorPos == Shield.location):
				if !Shield.moved && !Shield.health == Shield.Health.DOWN:
					for p in movePath:
						map.erase_cell(3,p);
					movePath.clear()
					selected = Shield;
					var string = "Selected" + selected.characterName
					TTs.speak(string,false)
			else:
				for p in movePath:
					map.erase_cell(3,p);
				if (selected!= null && selected.getPath(cursorPos).size()< selected.moveDistance):
					movePath = selected.getPath(cursorPos)
					selected.move(movePath);
					movePath.clear()
					selected = null
	elif(!moving && mouse && focus):
		var mouseLocation = get_viewport().get_mouse_position();
		mouseLocation = map.to_local(mouseLocation);
		mouseLocation = map.local_to_map(mouseLocation);
		if(map.get_cell_tile_data(0,mouseLocation) != null):
			cursor.position = map.map_to_local(mouseLocation);
			if(selected != null &&!(selected.location-mouseLocation).length() == 0):
				for p in movePath:
					map.erase_cell(3,p);
				if(selected.getPath(mouseLocation).size()< selected.moveDistance):
					var tempPath = selected.getPath(mouseLocation);
					if(tempPath != null):
						movePath = tempPath
						for p in movePath:
							map.set_cell(3,p,0,Vector2i(0,3))
			if(event.is_action_pressed("Click")):
				if mouseLocation == Axe.location:
					if !Axe.moved&&!Axe.health == Axe.Health.DOWN:
						for p in movePath:
							map.erase_cell(3,p);
						movePath.clear()
						selected = Axe;
						var string = "Selected" + selected.characterName
						TTs.speak(string,false)
				elif(mouseLocation == Bow.location):
					if !Bow.moved &&!Bow.health == Bow.Health.DOWN:
						for p in movePath:
							map.erase_cell(3,p);
						movePath.clear()
						selected = Bow;
						var string = "Selected" + selected.characterName
						TTs.speak(string,false)
				elif(mouseLocation == Shield.location):
					if !Shield.moved && !Shield.health == Shield.Health.DOWN:
						for p in movePath:
							map.erase_cell(3,p);
						movePath.clear()
						selected = Shield;
						var string = "Selected" + selected.characterName
						TTs.speak(string,false)
				else:
					if(selected != null):
						for p in movePath:
							map.erase_cell(3,p);
						var tempPath = selected.getPath(mouseLocation)
						if(!tempPath.is_empty()):
							if (selected!= null && tempPath.size()< selected.moveDistance):
								movePath = tempPath
								if(movePath!= null):
									selected.move(movePath);
									movePath.clear()
									selected = null
	if(map.local_to_map(cursor.position) != previousCursor &&focus):
		previousCursor = map.local_to_map(cursor.position);
		TTs.readTile(map,previousCursor,monster,Axe,Bow,Shield,selected)
	if(event.is_action_pressed("Turn")):
		turn()
	elif (event.is_action_pressed("Undo")):
		loadTurn();
	elif (event.is_action_pressed("Quit")):
		get_tree().change_scene_to_file("res://StartMenu.tscn")
func saveTurn():
	saved = true;
	axeSave = map.local_to_map(Axe.position);
	bowSave = map.local_to_map(Bow.position);
	shieldSave = map.local_to_map(Shield.position);
	monsterSave = monster.current
	saveDestination = monster.path.back()
func loadTurn():
	if(saved):
		var undo:String = "Undoing turn"
		TTs.speak(undo,false)
		undoButton.release_focus()
		Axe.moved = false;
		Axe.location = axeSave
		Axe.position = map.map_to_local(axeSave)
		Bow.moved = false;
		Bow.location = bowSave;
		Bow.position = map.map_to_local(bowSave);
		Shield.moved = false;
		Shield.location = shieldSave;
		Shield.position = map.map_to_local(shieldSave);
		for h in hints:
			map.erase_cell(2,h);
		hints.clear();
		for t in currentMonsterMove:
			if(!hints.has(t)):
				hints.append(t)
			for n in monster.shape:
				if(!hints.has(t+n)):
					hints.append(t+n)
		for h in hints:
			map.set_cell(2,h,0,hintTile)
		var end = currentMonsterMove.back()
		map.set_cell(2,end,0,finishTile)
		for n in monster.shape:
			map.set_cell(2,end+n,0,finishTile)
		var string = "Monster will move to" + String.chr(65+currentMonsterMove.back().x) +str(currentMonsterMove.back().y)
		TTs.speak(string,false)
		turnButton.disabled = false;
func win():
	if levelID == 1:
		TTs.speak("The monster is slain, but greater foes emerge",false)
		get_tree().change_scene_to_file("res://levels/Level2.tscn");	
	elif levelID == 2:
		TTs.speak("The monster is slain, but greater foes emerge",false)
		get_tree().change_scene_to_file("res://levels/Level3.tscn");	
	else:
		get_tree().change_scene_to_file("res://levels/WinScreen.tscn")
