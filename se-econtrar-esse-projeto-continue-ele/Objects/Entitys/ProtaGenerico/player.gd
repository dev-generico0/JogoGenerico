# Godot 4.x
extends CharacterBody2D

# Velocidades
@export var walk_speed := 160.0
@export var sprint_speed := 260.0

# Stamina
@export var max_stamina := 20.0
@export var stamina_drain := 20.0
@export var stamina_recovery := 20.0
@export var recovery_delay := 1.5

var stamina := max_stamina
var recovery_timer := 0.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):

	z_index = int(global_position.y)
	
	var direction = Vector2.ZERO

	# Inputs
	if Input.is_action_pressed("right"):
		direction.x += 1

	if Input.is_action_pressed("left"):
		direction.x -= 1

	if Input.is_action_pressed("down"):
		direction.y += 1

	if Input.is_action_pressed("up"):
		direction.y -= 1

	direction = direction.normalized()

	# Sprint
	var sprinting = Input.is_action_pressed("sprint") and stamina > 0 and direction != Vector2.ZERO

	var current_speed = walk_speed

	if sprinting:
		current_speed = sprint_speed

		# Gasta stamina
		stamina -= stamina_drain * delta
		stamina = clamp(stamina, 0, max_stamina)

		# Reseta timer de recuperação
		recovery_timer = recovery_delay

	else:
		# Conta o tempo até recuperar
		if recovery_timer > 0:
			recovery_timer -= delta
		else:
			# Recupera stamina
			stamina += stamina_recovery * delta
			stamina = clamp(stamina, 0, max_stamina)

	# Movimento
	velocity = direction * current_speed
	move_and_slide()

	# Animações
	if direction != Vector2.ZERO:

		# Nome da animação
		var anim_prefix = "run" if sprinting else "walk"

		# Horizontal
		if abs(direction.x) > abs(direction.y):

			if direction.x > 0:
				anim.play(anim_prefix + "R")
			else:
				anim.play(anim_prefix + "L")

		# Vertical
		else:

			if direction.y > 0:
				anim.play(anim_prefix + "D")
			else:
				anim.play(anim_prefix + "U")

	else:
		# Idle baseado na última animação
		match anim.animation:

			"walkR", "runR":
				anim.play("idleR")

			"walkL", "runL":
				anim.play("idleL")

			"walkU", "runU":
				anim.play("idleU")

			"walkD", "runD":
				anim.play("idleD")
