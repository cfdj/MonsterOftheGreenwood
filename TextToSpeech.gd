class_name tts extends Node

var volume:int = 50;
var rate:float = 1.0;
var voice:int = 0;
var enabled:bool = true;

func speak(text:String,interrupt:bool):
	if(enabled):
		var voiceString = DisplayServer.tts_get_voices_for_language("en")[voice];
		if(interrupt):
			DisplayServer.tts_stop()
		DisplayServer.tts_speak(text,voiceString,volume,1.0,rate)

func readTile(map:TileMap,cursorPosition:Vector2i,monster:Monster,axe:Character,bow:Character,shield:Character,selected:Character):
	var string = String.chr(65+cursorPosition.x) +str(cursorPosition.y)
	var monsterLocation:bool = false;
	if(axe.location == cursorPosition):
		string += " Axe"
	if(bow.location == cursorPosition):
		string += " Bow"
	if(shield.location == cursorPosition):
		string += " Shield"
	if(!map.get_cell_tile_data(0,cursorPosition).get_custom_data("PlayerNav")):
		string += " impassable"
	elif(selected != null):
		if selected.getPath(cursorPosition).size()< selected.moveDistance:
			string += " in move range"
	if(cursorPosition == map.local_to_map(monster.position)):
		string += " " + monster.title
		monsterLocation = true;
	else:
		for p in monster.shape:
			if(cursorPosition == p+map.local_to_map(monster.position)):
				monsterLocation = true;
				string += " " + monster.title
	if(!monsterLocation):
		if map.get_cell_tile_data(2,cursorPosition) !=null:
			string += " in the monster's path"
	speak(string,true)			
