# Godot 4.x
extends CharacterBody2D

@export var player_path : NodePath

# Velocidades
@export var walk_speed := 160.0
@export var run_speed := 230.0

# Distâncias
@export var follow_distance := 50.0
@export var run_distance := 200.0

# Tempo antes de começar a seguir
@export var follow_delay := 0.6

var wait_timer := 0.0
var following := false

@onready var anim = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../player"

func _physics_process(delta):

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	z_index = int(global_position.y)
	# -------------------------
	# Controle de espera
	# -------------------------

	# Se o player estiver longe o suficiente
	if distance > follow_distance:

		# Conta tempo antes de seguir
		wait_timer += delta

		if wait_timer >= follow_delay:
			following = true

	else:
		# Para quando chegar perto
		following = false
		wait_timer = 0.0

	# -------------------------
	# Movimento
	# -------------------------

	if following:

		var current_speed = walk_speed
		var animation_prefix = "walk"

		# Corre se estiver MUITO longe
		if distance >= run_distance:
			current_speed = run_speed
			animation_prefix = "run"

		velocity = direction * current_speed
		move_and_slide()

		# -------------------------
		# Animações andando
		# -------------------------

		if abs(direction.x) > abs(direction.y):

			if direction.x > 0:
				anim.play(animation_prefix + "R")
			else:
				anim.play(animation_prefix + "L")

		else:

			if direction.y > 0:
				anim.play(animation_prefix + "D")
			else:
				anim.play(animation_prefix + "U")

	else:

		velocity = Vector2.ZERO

		# -------------------------
		# Idle
		# -------------------------

		match anim.animation:

			"walkR", "runR":
				anim.play("idleR")

			"walkL", "runL":
				anim.play("idleL")

			"walkU", "runU":
				anim.play("idleU")

			"walkD", "runD":
				anim.play("idleD")
