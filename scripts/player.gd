"""
This script controls the player character.
source: https://www.youtube.com/watch?v=Wzrw6_KDMl4
"""
extends CharacterBody2D


@onready var chain = $Chain

const JUMP_FORCE = 450			# Force applied on jumping
const MOVE_SPEED = 1000			# Speed to walk with
const GRAVITY = 750				# Gravity applied every second
const MAX_SPEED = 650			# Maximum speed the player is allowed to move
const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground
const CHAIN_PULL = 125

var chain_velocity := Vector2(0,0)

func _input(event: InputEvent) -> void:
	if event.is_action("grab"):
		if event.pressed:
			# We clicked the mouse -> shoot()
			chain.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release()
			chain.release()
	elif event.is_action("attack"):
		modulate = Color.DARK_RED
		

func _physics_process(delta: float) -> void:
	movimentos(delta)
	gravidade(delta)

func movimentos(delta):
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * MOVE_SPEED
	
	if chain.hooked:
		walk = 0
		
	velocity.y += GRAVITY * delta

	# Hook physics
	if chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local(chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity
	
	velocity.x += walk
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()	# Actually apply all the forces
	
	velocity.x -= walk

func gravidade(delta):
	# Manage friction and refresh jump and stuff
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if !grounded && chain.hooked:
		velocity.x *= FRICTION_AIR
		print("A")
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if grounded:
			velocity.y = -JUMP_FORCE
	
	velocity.x = velocity.x * delta
