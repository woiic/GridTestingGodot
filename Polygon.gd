extends Node2D
class_name Polygon

var Vertices:Array[Utils.Coordinates]=[]

func _init(CoordsArr:Array[Utils.Coordinates]=[]) -> void:
	if !CoordsArr:
		var c0 = Utils.Coordinates.new()
		var c1 = Utils.Coordinates.new()
		var c2 = Utils.Coordinates.new()
		c0.setByCube(0,0,Utils.TO.Vertex)
		c1.setByCube(1,-1,Utils.TO.Vertex)
		c2.setByCube(1,0,Utils.TO.Vertex)
		CoordsArr = [
			c0,c1,c2
		]
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	
	return


func setInnerCoords():
	pass

func getInnerCoords():
	pass

func getInnerVertices():
	pass
	
#func outterCoords():
	#pass

func getVertices():
	pass

func getEdgesFaces():
	pass

func getEdgesVertices():
	var pairs = self.CoordsArr
	pairs.append(self.CoordsArr[0])
	var edgesVetices = []
	for i in len(self.CoordsArr):
		
		
		pass
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
	for c in self.CoordsArr:
		var pos = c.ToVector2(TileSize)
		draw_circle(pos,radius, color)

func drawEdgeVertices(TileSize, radius = 40.0, color = Color.BLACK):
	for c in self.CoordsArr:
		var pos = c.ToVector2(TileSize)
		draw_circle(pos,radius, color)
