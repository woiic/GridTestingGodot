extends Node2D
class_name Polygon

var Vertices:Array[Utils.Coordinates]=[]
var TileSize : int

func _init(CoordsArr:Array[Utils.Coordinates]=[]) -> void:
	#if !CoordsArr:
		#var c0 = Utils.Coordinates.new()
		#var c1 = Utils.Coordinates.new()
		#var c2 = Utils.Coordinates.new()
		#c0.setByCube(0,0,Utils.TO.Vertex)
		#c1.setByCube(1,-1,Utils.TO.Vertex)
		#c2.setByCube(1,0,Utils.TO.Vertex)
		#CoordsArr = [
			#c0,c1,c2
		#]
	Vertices = CoordsArr
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var a = delta
	a = a+1
	queue_redraw()
	pass

func _draw() -> void:
	draw_edges(TileSize)
	draw_vertices(TileSize)
	return

func _to_string() -> String:
	var ret = "%s" % [Vertices]
	return ret

func setInnerCoords():
	pass

func getInnerCoords():
	pass

func getInnerVertices():
	pass
	
#func outterCoords():
	#pass

func setVertices(array : Array[Utils.Coordinates]):
	Vertices = array

func getVertices():
	return Vertices

func append(coord : Utils.Coordinates):
	Vertices.append(coord)

func getEdgesFaces():
	pass

func getEdgesVertices(orientation = 1):
	var pairs = Vertices
	pairs.append(Vertices[0])
	var edgesVetices = []
	for i in len(Vertices):
		edgesVetices.append(Utils.find_vertex_line(pairs[i],pairs[i+1],orientation))
	return edgesVetices

func innerBorder():
	pass

func outteBorder():
	pass

func Vector2IsInside():
	pass

func getCenter():
	pass

func getArea():
	pass

func drawVertices(TileSize, radius = 40.0, color = Color.BLACK):
	for c in Vertices:
		var pos = c.ToVector2(TileSize)
		print(c)
		draw_circle(pos,radius, color)

func drawEdgeVertices(TileSize, radius = 40.0, color = Color.BLACK):
	for c in Vertices:
		var pos = c.ToVector2(TileSize)
		draw_circle(pos,radius, color)


func draw_vertices(TileSize, color = Color.BLACK, radius = 45.0):
	for c in self.Vertices:
		var pos = c.ToVector2(TileSize)
		draw_circle(pos,radius, color)

func draw_edges(TileSize, color = Color.DIM_GRAY,orientation = 1, radius = 45.0):
	if !Vertices:
		return
	var pairs = Vertices.duplicate()
	pairs.append(pairs[0])
	for i in len(Vertices):
		draw_edge_grid_line(pairs[i+1], pairs[i])
		#draw_line(pairs[i+1].ToVector2(MyBoard.TileSize), pairs[i].ToVector2(MyBoard.TileSize), Color.GREEN, 30.0)
		draw_vertex_grid_line(pairs[i+1], pairs[i],orientation,color,radius)


func draw_edge_grid_line(C1 :Utils.Coordinates, c0 = Utils.Coordinates.new(0,0,Utils.TO.Vertex), orientation = 1 ,color: Color = Color.GREEN, width := 30.0):
	# orientation = 1 for positive -1 for negative
	if !C1:
		return
	if C1.is_equal_to(c0):
		return
	#var c0 = Utils.Coordinates.new(0,0,Utils.TO.Vertex)
	var pairs = find_vertex_line(c0,C1, orientation).duplicate()
	#pairs.append(pairs[0])
	for i in len(pairs)-1:
		draw_line(pairs[i+1].ToVector2(TileSize), pairs[i].ToVector2(TileSize), color, width)


func draw_vertex_grid_line(C1 :Utils.Coordinates, c0 = Utils.Coordinates.new(0,0,Utils.TO.Vertex), orientation = 1 ,color: Color = Color.BLACK, radius := 45.0):
	# orientation = 1 for positive -1 for negative
	if !C1:
		return
	#var c0 = Utils.Coordinates.new(0,0,Utils.TO.Vertex)
	for c in find_vertex_line(c0,C1, orientation):
		var pts = c.ToVector2(TileSize)
		draw_circle(pts, radius, color)



func find_vertex_line(coord1: Utils.Coordinates, coord2: Utils.Coordinates, orientation = 1) -> Array:
	# 1 for positive orientation -1 for negative
	var N = coord1.weakDistance(coord2)
	if N == 0:
		return [coord1]

	var out := []
	var pts = coord1.lerp_plane_weak_points(coord2)
	var i = 0
	var last_class = null
	for e in pts:
		var tri = Utils.Coordinates.new()
		var x = e.x
		var y = e.y
		var z = e.z
		var classes = Utils.classify_hex_coset_direct(x,y,z)
		if !classes:
			tri.setByWCube(e.x,e.y,e.z)
			out.append(tri)
		else:
			if last_class:
				var dir1 = e - pts[i-1]
				var dir2 = Utils.rotateWeakCube(dir1, orientation)
				var c = pts[i-1] + dir2
				tri.setByWCube(c.x,c.y,c.z)
				out.append(tri)
			#else:
				#var F = Utils.Coordinates.new()
				
				#var f = pts[i-1] + dir3
				#var g = e + dir3
				#F.setByWCube(f.x,f.y,f.z)
				#out.append(F)
				#tri.setByWCube(g.x,g.y,g.z)
		
		i += 1
		last_class = classes

	return out
