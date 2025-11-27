extends Node2D


@onready var BoardBGSprite = $BoardDGSprite
@onready var TBoard: Node2D = $"."

enum BoardType {Axial=0, Radial}

class Board:
	var Size=[0,0]
	var BasicTile = preload("res://Tile.tscn")
	var BoardRef
	var TileSize = 1
	
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
	pass
