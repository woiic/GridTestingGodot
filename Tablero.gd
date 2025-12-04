extends Node2D


@onready var BoardBGSprite = $BoardDGSprite
@onready var TBoard: Node2D = $"."

enum BoardType {Axial=0, Radial}

class Board:
	var Size=[0,0]
	var BasicTile = preload("res://Tile.tscn")
	var BoardRef
	var TileSize = 1
	var last_coords = null
	var last_hex = null
	var last_vertex = null
	var last_clicked_coords = null
	const EPSILON := Vector3(1e-6, 2e-6, -3e-6)
	
	var tablero = {}
	
	func DisplayAxialBoard():
		for i in Size[0]:
			for j in Size[1]:
				var c_low = Utils.Coordinates.new()
				var c_high = Utils.Coordinates.new()
				#c_low.setByPush(i , -j, Utils.TO.Low)
				c_low.setByCuadratic(i , -j, Utils.TO.Low)
				#c_high.setByPush(i , -j, Utils.TO.High)
				c_high.setByCuadratic(i , -j, Utils.TO.High)
				SpawnTile(c_low)
				SpawnTile(c_high)
				print(c_low)
				print(c_high)
		return
	
	func SpawnTile(InCoords:Utils.Coordinates):
		var BDTile = BasicTile.instantiate()
		# coordinadas cubicas ->(i +j, -j)
		var Coord = InCoords
		#BDTile
		BDTile.Coord = Coord
		BDTile.position = Coord.ToVector2(TileSize)
		if Coord.r:
			BDTile.rotation = PI
		# añadir tiles al tablero
		BoardRef.add_child(BDTile)
		tablero[str(Coord)] = BDTile
		return
	
	func DisplayRadialBoardEdge():
		var n =  Size[0]
		var triples = find_triplets_leq(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			c.setByCubeFace(x, y, z)
			#c = c.getCubeCoords()
			#print(x,y,z)
			#print(c.getCubeFaceCoords())
			SpawnTile(c)
		print(len(triples))
		return
		
	func DisplayRingBoardEdge():
		var n =  Size[0]
		var triples = find_triplets(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			c.setByCubeFace(x, y, z)
			#c = c.getCubeCoords()
			#print(x,y,z)
			#print(c.getCubeFaceCoords())
			#print(c)
			
			SpawnTile(c)
		print(len(triples))
		return
	
	func DisplayWeakRadialBoard():
		var n =  Size[0]
		var triples = find_weak_triplets_leq(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			if Utils.classify_hex_coset_direct(x,y,z):
				c.setByWCube(x, y, z)
				SpawnTile(c)
		return
		
	func DisplayWeakRingBoard():
		var n =  Size[0]
		var triples = find_weak_triplets(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			if Utils.classify_hex_coset_direct(x,y,z):
				c.setByWCube(x, y, z)
				SpawnTile(c)
		return
	
	
	
	func DisplayRadialBoard():
		var n =  Size[0]
		var triples = find_triplets_max_leq(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			c.setByCubeFace(x, y, z)
			#c = c.getCubeCoords()
			#print(x,y,z)
			#print(c.getCubeFaceCoords())
			SpawnTile(c)
		print(len(triples))
		return
		
	func DisplayRingBoard():
		var n =  Size[0]
		var triples = find_triplets_max_eq(n)
		for xyz in triples:
			var x = xyz[0]
			var y = xyz[1]
			var z = xyz[2]
			var c = Utils.Coordinates.new()
			c.setByCubeFace(x, y, z)
			#c = c.getCubeCoords()
			print(x,y,z)
			print(c.getCubeFaceCoords())
			print(c)
			
			SpawnTile(c)
		print(len(triples))
		return
		
	func getTilesByPos(CoordsArr:Array=[]):
		var retArr = []
		for i in CoordsArr:
			if str(i) in tablero.keys():
				retArr.append(tablero[str(i)])
		return retArr
		
		
		
	# Radial Stuff
	func weak_compositions(total: int, parts: int) -> Array:
		var out := []
		if parts == 0:
			if total == 0:
				out.append([])
			return out

		if parts == 1:
			out.append([total])
			return out

		if parts == 2:
			for a in total + 1:
				out.append([a, total - a])
			return out

		if parts == 3:
			for a in total + 1:
				for b in (total - a) + 1:
					out.append([a, b, total - a - b])
			return out

		return out


	func find_triplets(n: int) -> Array:
		var k : int = n % 2
		# Feasibility
		if abs(k) > n or ((n + k) % 2) != 0:
			return []
		
		var p := (n + k) / 2
		var q := (n - k) / 2
		
		var results := {}
		var indices = [0, 1, 2]
		
		# Iterate subsets of positive indices
		for r in range(4):
			var combs := Utils._combinations(indices, r)
			for pos_indices in combs:
				var neg_indices := []
				for i in indices:
					if not pos_indices.has(i):
						neg_indices.append(i)

				var pos_vals_list = weak_compositions(p, pos_indices.size())
				var neg_vals_list = weak_compositions(q, neg_indices.size())

				for pos_vals in pos_vals_list:
					for neg_vals in neg_vals_list:
						var xyz = [0, 0, 0]

						for i in pos_indices.size():
							xyz[pos_indices[i]] = pos_vals[i]

						for i in neg_indices.size():
							xyz[neg_indices[i]] = -neg_vals[i]

						# Store as a key for dedupe
						results[str(xyz)] = xyz

		return results.values()

	func find_triplets_leq(n: int) -> Array:
		var out := []
		for e in range(n + 1):
			var arr := find_triplets(e)
			for xyz in arr:
				out.append(xyz)
		return out
	
	
	func find_triplets_max_eq_S(n: int, S: int) -> Array:
		var results := {}
		var indices = [0, 1, 2]

		# All non-empty subsets of indices
		var all_subsets := []
		for r in range(1, 4):
			all_subsets += Utils._combinations(indices, r)

		# Iterate each subset I = indices where |coord| == n
		for I in all_subsets:
			var J := []
			for i in indices:
				if not I.has(i):
					J.append(i)

			# Sign assignments for coordinates in I
			var sign_choices := []
			Utils._sign_assignments(I.size(), [], sign_choices)

			for signs in sign_choices:
				# Compute C = sum(sign[i] * n)
				var C := 0
				for t in I.size():
					C += signs[t] * n

				# Case 1: |J| = 0
				if J.size() == 0:
					if C == S:
						var xyz = [0,0,0]
						for t in I.size():
							xyz[I[t]] = signs[t] * n
						results[str(xyz)] = xyz
					continue

				# Case 2: |J| = 1
				if J.size() == 1:
					var t_val = S - C
					if abs(t_val) <= n - 1:
						var xyz = [0,0,0]
						for k in I.size():
							xyz[I[k]] = signs[k] * n
						xyz[J[0]] = t_val
						results[str(xyz)] = xyz
					continue

				# Case 3: |J| = 2
				var lo = -(n - 1)
				var hi = (n - 1)
				for a in range(lo, hi + 1):
					var b = S - C - a
					if abs(b) <= n - 1:
						var xyz = [0,0,0]
						for k in I.size():
							xyz[I[k]] = signs[k] * n
						xyz[J[0]] = a
						xyz[J[1]] = b
						results[str(xyz)] = xyz

		return results.values()
		
	func find_triplets_max_eq(n: int) -> Array:
		var results := {}

		# S = 0
		var r0 = find_triplets_max_eq_S(n, 0)
		for xyz in r0:
			results[str(xyz)] = xyz

		# S = 1
		var r1 = find_triplets_max_eq_S(n, 1)
		for xyz in r1:
			results[str(xyz)] = xyz

		return results.values()
		
	func find_triplets_max_leq(n: int) -> Array:
		var results := {}

		for r in range(n + 1):
			var r0 = find_triplets_max_eq_S(r, 0)
			for xyz in r0:
				results[str(xyz)] = xyz

			var r1 = find_triplets_max_eq_S(r, 1)
			for xyz in r1:
				results[str(xyz)] = xyz

		return results.values()
	
	func find_weak_triplets(n : int):
		return find_triplets(2 * n)
	
	func find_weak_triplets_leq(n : int):
		return find_triplets_leq(2 * n)
	
	func find_line(coord1: Utils.Coordinates, coord2: Utils.Coordinates) -> Array:

		var N = coord1.edgeDistance(coord2)
		if N == 0:
			return [coord1]

		var out := []
		var pts = coord1.lerp_plane_points(coord2, TileSize)
		
		for e in pts:
			var tri = Utils.Vector2ToCoords(e, TileSize)
			out.append(tri)

		return out
	
	func find_weak_line(coord1: Utils.Coordinates, coord2: Utils.Coordinates) -> Array:
		var N = coord1.weakDistance(coord2)
		if N == 0:
			return [coord1]

		var out := []
		var pts = coord1.lerp_plane_weak_points(coord2)
		var i = 0
		for e in pts:
			var tri = Utils.Coordinates.new()
			var x = e.x
			var y = e.y
			var z = e.z
			if Utils.classify_hex_coset_direct(x,y,z):
				tri.setByWCube(e.x,e.y,e.z)
			else:
				var dir1 = e - pts[i-1]
				var dir2 = pts[i+1] - e
				if dir1 != dir2:
					var c = pts[i-1] + dir2
					tri.setByWCube(c.x,c.y,c.z)
				else:
					var F = Utils.Coordinates.new()
					var dir3 = Utils.rotateWeakCube(dir1)
					var f = pts[i-1] + dir3
					var g = e + dir3
					F.setByWCube(f.x,f.y,f.z)
					out.append(F)
					tri.setByWCube(g.x,g.y,g.z)
			out.append(tri)
			i += 1

		return out


	func _cube_lerp(a: Vector3, b: Vector3, t: float) -> Vector3:
		return a + (b - a) * t


	func _cube_round(v: Vector3) -> Vector3:
		var rx = round(v.x)
		var ry = round(v.y)
		var rz = round(v.z)

		var dx = abs(rx - v.x)
		var dy = abs(ry - v.y)
		var dz = abs(rz - v.z)

		if dx > dy and dx > dz:
			rx = -ry - rz
		elif dy > dz:
			ry = -rx - rz
		else:
			rz = -rx - ry

		return Vector3(rx, ry, rz)
## Jogo things

var MyBoard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MyBoard = Board.new()
	MyBoard.Size = [15,15]
	MyBoard.BoardRef = TBoard
	MyBoard.TileSize = 202
	#MyBoard.DisplayAxialBoard()
	#MyBoard.DisplayRingBoardEdge()
	#MyBoard.DisplayRadialBoardEdge()
	#MyBoard.DisplayWeakRingBoard()
	MyBoard.DisplayWeakRadialBoard()
	#MyBoard.DisplayRingBoard()
	#MyBoard.DisplayRadialBoard()
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var a = delta
	a = a+1
	var mouse = get_viewport().get_mouse_position()
	var view_to_world_transform: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	mouse = view_to_world_transform * mouse
	MyBoard.last_coords = Utils.Vector2ToCoords(mouse, MyBoard.TileSize)
	MyBoard.last_hex = Utils.Vector2ToHex(mouse, MyBoard.TileSize)
	MyBoard.last_vertex = Utils.Vector2ToHexCoord(mouse, MyBoard.TileSize)
	if Input.is_action_just_pressed("left_click"):
		MyBoard.last_clicked_coords = MyBoard.last_coords
		#print("Mouse: ", mouse.x, ", ", mouse.y)
		print("Last Hex: ", MyBoard.last_hex)
		print("Last Vertex: ", MyBoard.last_vertex)
		#print("Coord : ", MyBoard.last_clicked_coords)
		#print("Coord_CF : ", MyBoard.last_clicked_coords.getCubeFaceCoords())
		#print("Coord_WC : ", MyBoard.last_clicked_coords.getWCubeCoords())
	queue_redraw() # redraw
	
	#print("Screen:", get_viewport().get_mouse_position())
	#print("World:", get_global_mouse_position())
	pass
	
func _draw():
	if MyBoard.last_coords == null:
		return
	#print(MyBoard.last_coords.getCubeFaceCoords())
	#draw_triangle_pos(MyBoard.last_coords)
	draw_ring_edge_pos(MyBoard.last_coords)
	#draw_ring_pos(MyBoard.last_coords)
	#draw_weak_ring_pos(MyBoard.last_coords)
	#draw_triangle_pos_C(MyBoard.last_clicked_coords,Color.LIME_GREEN)
	#draw_grid_line(MyBoard.last_clicked_coords,Color.LIME_GREEN)
	#draw_weak_grid_line(MyBoard.last_clicked_coords,Color.LIME_GREEN)
	#draw_lerp_points_in_plane(Utils.Coordinates.new(),MyBoard.last_clicked_coords,Color.BLACK,20)
	draw_vertex_in_plane(MyBoard.last_vertex)
	
func coords_to_triangle_points(InCoords:Utils.Coordinates, tile_size:float) -> PackedVector2Array:
	var theta_base = 30
	var theta = PI * theta_base / 180
	var h = tile_size * cos(theta)
	# 2) Convertir a pixeles (Y positivo hacia abajo)
	
	#var vec = InCoords.getCubeCoords().ToVector2(tile_size)
	var vec = InCoords.ToVector2(tile_size)
	var cx = vec.x
	var cy = vec.y
	# 3) Altura del triángulo equilátero
	

	var pts := PackedVector2Array()

	# 4) Sólo dos orientaciones: arriba o abajo
	if InCoords.r:
		# Triángulo hacia arriba
		pts.append(Vector2(cx - tile_size/2 , cy + h/2))
		pts.append(Vector2(cx + tile_size/2 , cy + h/2))
		pts.append(Vector2(cx , cy - h/2))
	else:
		# Triángulo hacia abajo
		pts.append(Vector2(cx - tile_size/2, cy - h/2))
		pts.append(Vector2(cx + tile_size/2, cy - h/2))
		pts.append(Vector2(cx, cy + h/2))

	return pts
	



func draw_triangle_pos(Coords:Utils.Coordinates):
	var pts = coords_to_triangle_points(Coords, MyBoard.TileSize)
	var color = Color.BLUE if Coords.r else Color.RED

	draw_polygon(pts, [color])

func draw_triangle_pos_C(Coords:Utils.Coordinates,desire_color: Color):
	if !Coords:
		return
	var pts = coords_to_triangle_points(Coords, MyBoard.TileSize)

	var color: Color
	if desire_color == null:
		color = Color.BLUE if Coords.r != 0 else Color.RED
	else:
		color = desire_color
	draw_polygon(pts, [color])

func draw_ring_edge_pos(Coords:Utils.Coordinates):
	var d = Coords.edgeDistance()
	var triplets = MyBoard.find_triplets(d)
	for xyz in triplets:
		var c = Utils.Coordinates.new()
		var x = xyz[0]
		var y = xyz[1]
		var z = xyz[2]
		c.setByCubeFace(x, y, z)
		var pts = coords_to_triangle_points(c, MyBoard.TileSize)
		var color = Color.BLUE if c.r else Color.RED
		draw_polygon(pts, [color])
		
func draw_ring_pos(Coords:Utils.Coordinates):
	var d = Coords.vertexDistance()
	var triplets = MyBoard.find_triplets_max_eq(d)
	for xyz in triplets:
		var c = Utils.Coordinates.new()
		var x = xyz[0]
		var y = xyz[1]
		var z = xyz[2]
		c.setByCubeFace(x, y, z)
		var pts = coords_to_triangle_points(c, MyBoard.TileSize)
		var color = Color.BLUE if c.r else Color.RED
		draw_polygon(pts, [color])

func draw_weak_ring_pos(Coords:Utils.Coordinates):
	var d = Coords.weakDistance()
	var triplets = MyBoard.find_weak_triplets(d)
	#print("d: ", d)
	#print("Triplets: ")
	for xyz in triplets:
		#print("xyz : ", xyz)
		var c = Utils.Coordinates.new()
		var x = xyz[0]
		var y = xyz[1]
		var z = xyz[2]
		#print("class : ", Utils.classify_hex_coset_direct(x,y,z))
		if Utils.classify_hex_coset_direct(x,y,z) !=0:
			c.setByWCube(x, y, z)
			var pts = coords_to_triangle_points(c, MyBoard.TileSize)
			var color = Color.BLUE if c.r else Color.RED
			draw_polygon(pts, [color])
func draw_grid_line(Coords:Utils.Coordinates, color):
	if !Coords:
		return
	for c in MyBoard.find_line(Utils.Coordinates.new(),Coords):
		var pts = coords_to_triangle_points(c, MyBoard.TileSize)
		draw_polygon(pts, [color])

func draw_weak_grid_line(Coords :Utils.Coordinates, color):
	if !Coords:
		return
	for c in MyBoard.find_weak_line(Utils.Coordinates.new(),Coords):
		var pts = coords_to_triangle_points(c, MyBoard.TileSize)
		draw_polygon(pts, [color])

func draw_lerp_points_in_plane(coord1: Utils.Coordinates, coord2: Utils.Coordinates, color: Color, radius := 20.0):
	if !(coord1 and coord2):
		return
		
	var pts = coord1.lerp_plane_points(coord2, MyBoard.TileSize)
	for p in pts:
		draw_circle(p, radius, color)
		

func draw_vertex_in_plane(coord: Utils.Coordinates, color: Color = Color.BLACK, radius := 40.0):
	if !(coord):
		return
	var p = coord.ToVector2(MyBoard.TileSize)
	draw_circle(p, radius, color)
	
