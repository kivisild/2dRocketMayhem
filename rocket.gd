extends Area2D


var speed = 750
@export var velocity: Vector2


func _physics_process(delta):
		position += velocity * delta
		


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		queue_free()
		print("Rocket collision")
