extends Node2D


@onready var buttons_container: VBoxContainer = $Camera2D/ButtonsContainer
@onready var for_grid: Button = $ButtonsContainer/ForGrid


var TTablero = preload("res://Tablero.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_for_grid_pressed() -> void:
	var TBoard =  TTablero.instantiate()
	$".".add_child(TBoard)
	buttons_container.queue_free()

func _on_for_editor_pressed() -> void:
	var TBoard =  TTablero.instantiate()
	TBoard.bIsForEditor=true
	$".".add_child(TBoard)
	buttons_container.queue_free()
