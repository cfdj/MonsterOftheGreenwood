extends Monster

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
			moveDistance = 10;
			possible.erase(current)
			var inRange:Array[Vector2i];
			for p in possible:
				if astar.get_id_path(current,p).size() <= moveDistance && astar.get_id_path(current,p).size() >=5:
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
