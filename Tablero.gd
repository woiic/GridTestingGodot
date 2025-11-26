extends Node2D


@onready var BoardBGSprite = $BoardDGSprite
@onready var TBoard: Node2D = $"."

class Board:
	var Size=[0,0]
	var BasicTile = preload("res://Tile.tscn")
	var BoardRef
	var TileSize = 1
	
	func DisplayBoard():
		for i in Size[0]:
			for j in Size[1]:
				print(i)
				print(j)
				var BDTileL = BasicTile.instantiate()
				var BDTileH = BasicTile.instantiate()
				# coordinadas cubicas ->(i +j, -j)
				var CoordL = Utils.Coordinates.new(i +j, -j, Utils.TO.Low)
				var CoordH = Utils.Coordinates.new(i +j, -j, Utils.TO.High)
				#BDTile
				BDTileL.Coord = CoordL
				BDTileH.Coord = CoordH
				BDTileL.position = CoordL.ToVector2(TileSize)
				print(CoordL.ToVector2(TileSize))
				BDTileH.position = CoordH.ToVector2(TileSize)
				print(CoordH.ToVector2(TileSize))
				BDTileH.rotation = PI
				BoardRef.add_child(BDTileL)
				BoardRef.add_child(BDTileH)
		return
	
	

## Jogo things

var MyBoard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MyBoard = Board.new()
	MyBoard.Size = [5,5]
	MyBoard.BoardRef = TBoard
	MyBoard.TileSize = 202
	MyBoard.DisplayBoard()
	
	
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(MyBoard.x)
	pass
