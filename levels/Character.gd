class_name Character extends AnimatedSprite2D

@export var characterName:String;
@export var map:TileMap;
var health:Health = Health.UP
@export var moveDistance:int = 2;
@export var attackStrength:int = 2;
var astar:AStarGrid2D;
enum Health{UP,INJURED,DOWN}

var location:Vector2i;
var moved:bool = false;
var attacked:bool = false;
@export var highContrast:SpriteFrames
func _ready():
	if(Settings.highContrast):
		sprite_frames = highContrast
	play("Idle")
	location = map.local_to_map(position);	
	astar = AStarGrid2D.new();
	astar.region = map.get_used_rect()
	astar.cell_size = map.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for x in map.get_used_rect().size.x:
		for y in map.get_used_rect().size.y:
			var place = Vector2i(x+map.get_used_rect().position.x,y+map.get_used_rect().position.y);
			var tile = map.get_cell_tile_data(0,place);
			if (tile == null or !tile.get_custom_data("PlayerNav")):
				astar.set_point_solid(place);
	
func setState(h:Health):
	health = h;
	if h == Health.DOWN:
		play("Down");
	else:
		play("Idle")
func getPath(destination:Vector2i) ->Array[Vector2i]:
	var path = astar.get_id_path(location,destination);
	path.pop_front()
	return path;

func move(path:Array[Vector2i]):
	TTs.speak("Moving  "+ characterName+ " to " + String.chr(65+path.back().x) +str(path.back().y),false)
	moved = true;
	while !path.is_empty():
		location = path.pop_front()
		position = map.map_to_local(location)

func attack(monster:Monster):
	if(!health == Health.DOWN && !attacked):
		attacked = true;
		play("Attack")
		var string = characterName + " attacks"
		TTs.speak(string,false)
		monster.takeDamage(attackStrength)
		await animation_finished
		play("Idle")
