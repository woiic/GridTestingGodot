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
	
	var tablero = {}
	
	func DisplayAxialBoard():
		for i in Size[0]:
			for j in Size[1]:
				SpawnTile(Utils.Coordinates.new(i +j, -j, Utils.TO.Low))
				SpawnTile(Utils.Coordinates.new(i +j, -j, Utils.TO.High))
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
	
	func DisplayRadialBoard():
		
		return
		
	func getTilesByPos(CoordsArr:Array=[]):
		var retArr = []
		for i in CoordsArr:
			if str(i) in tablero.keys():
				retArr.append(tablero[str(i)])
		return retArr
	
	
	

## Jogo things

var MyBoard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MyBoard = Board.new()
	MyBoard.Size = [5,5]
	MyBoard.BoardRef = TBoard
	MyBoard.TileSize = 202
	MyBoard.DisplayAxialBoard()
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var a = delta
	a = a+1
	var mouse = get_viewport().get_mouse_position()
	MyBoard.last_coords = Utils.Vector2ToCoords(mouse, MyBoard.TileSize)
	queue_redraw() # redraw
	print("Mouse: ", mouse.x, ", ", mouse.y)
	#print("Screen:", get_viewport().get_mouse_position())
	#print("World:", get_global_mouse_position())
	pass
	
func _draw():
	if MyBoard.last_coords == null:
		return
	
	var tri = get_triangle_points(MyBoard.last_coords.p, MyBoard.last_coords.q, MyBoard.last_coords.r, MyBoard.TileSize)

	var color = Color.BLUE if MyBoard.last_coords.r else Color.RED
	draw_polygon(tri, [color])
	
func get_triangle_points(p:int, q:int, r:bool, tile_size:float) -> PackedVector2Array:
	var sqrt3 = sqrt(3)

	# Convert back to math space
	var x = p + q/2.0
	var y = q * (sqrt3/2.0)

	# Convert math → screen (Y-down)
	x *= tile_size
	y *= -tile_size

	var center = Vector2(x, y)

	# triangle height
	var h = tile_size * sqrt3 / 2.0

	var pts = PackedVector2Array()

	if r:
		# ⬆ triangle (UP)
		pts.append(center + Vector2(0, 0))
		pts.append(center + Vector2(tile_size, 0))
		pts.append(center + Vector2(tile_size/2, -h))
	else:
		# ⬇ triangle (DOWN)
		pts.append(center + Vector2( 2*tile_size, - 3/2*h))
		pts.append(center + Vector2(tile_size/2, -h))
		pts.append(center + Vector2(tile_size, 0))

	return pts
