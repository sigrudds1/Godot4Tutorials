extends Node3D

var _speed: float = 20.0
var _distance: float = 150.0
var _half_distance: float = _distance / 2.0
var _start: float = _half_distance * -1.0

func _ready() -> void:
	transform.origin.x = _start
	
func _physics_process(p_delta):
	transform.origin.x += p_delta * _speed
	if transform.origin.x > _half_distance:
		transform.origin.x = _start
