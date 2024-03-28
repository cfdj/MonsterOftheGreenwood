class_name Monster extends AnimatedSprite2D

@export var title:String
@export var map:TileMap;
@export var level:LevelManager
var astar:AStarGrid2D;

var path:Array[Vector2i];
var current:Vector2i;

@export var health:int;
@export var shape:Array[Vector2i]
@export var moveDistance:int = 4;
var currentState:State = State.EXPLORING;

@export var highContrastFrames:SpriteFrames
func _ready():
	if(Settings.highContrast):
		sprite_frames = highContrastFrames
	astar = AStarGrid2D.new();
	astar.region = map.get_used_rect()
	astar.cell_size = map.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for x in map.get_used_rect().size.x:
		for y in map.get_used_rect().size.y:
			var location = Vector2i(x+map.get_used_rect().position.x,y+map.get_used_rect().position.y);
			var tileAbove = map.get_cell_tile_data(1,location);
			if (tileAbove == null or !tileAbove.get_custom_data("MonsterNav")):
				astar.set_point_solid(location);
				
	current = map.local_to_map(position);
func move():
	if(!path.is_empty()):
		var next = path.pop_front();
		var direction = next-current;
		match direction:
			Vector2i.LEFT:
				play("MoveNorthWest")
			Vector2i.RIGHT:
				play("MoveSouthEast");
			Vector2i.UP:
				play("MoveNorthEast")
			Vector2i.DOWN:
				play("MoveSouthWest");
		emit_signal("nextTile",next)
		await animation_finished
		position = map.map_to_local(next);
		current = next;
		move();
	else:
		play("Idle")
		emit_signal("moveComplete")
		
func turn():
	move()

func decideDestination() -> Array[Vector2i]:
	var destination:Vector2i;
	var possible = map.get_used_cells_by_id(1,0,Vector2i(0,2))
	match currentState:
		State.EXPLORING:
			possible.erase(current)
			var inRange:Array[Vector2i];
			for p in possible:
				if astar.get_id_path(current,p).size() <= moveDistance:
					inRange.append(p)
			destination = inRange.pick_random()
		State.ATTACKING:
			possible.erase(current)
			var inRange:Array[Vector2i];
			for p in possible:
				if astar.get_id_path(current,p).size() <= moveDistance:
					inRange.append(p)
			var distance =999;
			var target:Vector2i = level.Shield.location
			var tempdestination:Vector2i
			for d in inRange:
				if(d-target).length_squared() < distance:
					distance = (d-target).length_squared()
					tempdestination = d;
			destination = tempdestination;
		State.RUNNING:
			pass;
	path = astar.get_id_path(current,destination);
	path.pop_front()
	return path;

func getOccupies(pos:Vector2i) -> bool:
	return false;

func takeDamage(damage:int):
	health -= damage;
	currentState = State.ATTACKING
	if health <=0:
		emit_signal("dead")
enum State {EXPLORING,ATTACKING,RUNNING}

signal moveComplete

signal nextTile(pos:Vector2i);

signal dead
