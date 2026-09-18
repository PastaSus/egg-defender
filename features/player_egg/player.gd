class_name Player
extends CharacterBody2D

## Player - Handles movement input for the egg character.

@export_range(0.0, 1000.0) var speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * speed
	move_and_slide()
