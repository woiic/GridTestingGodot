extends Node2D
class_name Polygon

var Vertices:Array[Utils.Coordinates]=[]

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
	#draw_vertices(232)
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
