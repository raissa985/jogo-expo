extends Enemy

@export var speed: float = 100.0
@export var attack_range: float = 80.0 
var player: Node2D = null

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("Player")
	set_state(State.IDLE)
	add_to_group("Skeleton") 

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if player and is_instance_valid(player):
		var direction_to_player = (player.global_position - global_position).normalized()
		
		if direction_to_player.x > 0:
			anim_sprite.flip_h = false
		elif direction_to_player.x < 0:
			anim_sprite.flip_h = true  

		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player <= attack_range:
			set_state(State.ATTACK)
			velocity = Vector2.ZERO 
			if anim_sprite.animation != "Attack":
				anim_sprite.play("Attack")
			attack(player)
			
		elif distance_to_player > attack_range and distance_to_player < 400:
			set_state(State.CHASE)
			velocity = direction_to_player * speed
			move_and_slide()
			
			if anim_sprite.animation != "Chase":
				anim_sprite.play("Chase")
		else:
			set_state(State.IDLE)
			velocity = Vector2.ZERO
			if anim_sprite.animation != "Idle":
				anim_sprite.play("Idle")
	else:
		set_state(State.IDLE)
		velocity = Vector2.ZERO
		if anim_sprite.animation != "Idle":
			anim_sprite.play("Idle")

func die():
	set_state(State.DEAD)
	anim_sprite.play("Dead")
	await anim_sprite.animation_finished
	super.die()
