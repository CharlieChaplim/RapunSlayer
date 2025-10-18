extends CharacterBody2D

@onready var animations = $AnimatedSprite2D
const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if animations.animation == "idle":
			animations.play("walk")
			

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x != 0:
		if direction > 0:
			animations.flip_h = true
		else:
			animations.flip_h = false
	
	if velocity == Vector2.ZERO:
		animations.play("idle")
		
	move_and_slide()
