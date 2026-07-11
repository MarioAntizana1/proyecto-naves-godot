extends Area2D

export var speed = 600
export (PackedScene) var Bullet

onready var sprite = $Sprite

onready var life1 = $"../CanvasLayer/life1"
onready var life2 = $"../CanvasLayer/life2"
onready var life3 = $"../CanvasLayer/life3"
onready var life4 = $"../CanvasLayer/life4"
onready var shield_bar = $"../CanvasLayer/ShieldBar"
onready var shield_break_icon = $"ShieldBreakIcon"
onready var damage_overlay = $"DamageOverlay"

var screen_size
var can_shoot = true

var lives = 4

var max_shield = 100.0
var shield = 100.0
var shield_recharge_time = 10.0
var shield_recharging = false
var shield_recharge_progress = 0.0

var shield_break_timer = 0.0

var damage_anim_playing = false
var damage_anim_frame = 0
var damage_anim_timer = 0.0
var damage_frames = [
	Rect2(1, 0, 15, 29),
	Rect2(22, 0, 27, 29),
	Rect2(54, 0, 17, 29),
	Rect2(79, 0, 15, 29),
	Rect2(102, 0, 15, 29),
	Rect2(125, 0, 13, 29),
]

var dash_speed = 900
var dash_time = 0.15
var is_dashing = false
var dash_timer = 0.0


func _ready():
	screen_size = get_viewport_rect().size
	update_lives()
	_update_shield_bar()
	_setup_controller_inputs()


func _setup_controller_inputs():
	if not InputMap.has_action("controller_shoot"):
		var ev = InputEventJoypadButton.new()
		ev.button_index = 5
		InputMap.add_action("controller_shoot")
		InputMap.action_add_event("controller_shoot", ev)

	if not InputMap.has_action("controller_dash"):
		InputMap.add_action("controller_dash")
		var ev_lb = InputEventJoypadButton.new()
		ev_lb.button_index = 4
		InputMap.action_add_event("controller_dash", ev_lb)
		var ev_a = InputEventJoypadButton.new()
		ev_a.button_index = 0
		InputMap.action_add_event("controller_dash", ev_a)

	if not InputMap.has_action("controller_pause"):
		var ev = InputEventJoypadButton.new()
		ev.button_index = 11
		InputMap.add_action("controller_pause")
		InputMap.action_add_event("controller_pause", ev)


func _get_connected_device():
	var devices = Input.get_connected_joypads()
	if devices.size() > 0:
		return devices[0]
	return -1


func update_lives():
	life1.visible = lives >= 1
	life2.visible = lives >= 2
	life3.visible = lives >= 3
	life4.visible = lives >= 4


func damage():
	if not shield_recharging and shield >= max_shield:
		shield = 0
		shield_recharging = true
		shield_recharge_progress = 0.0
		_update_shield_bar()
		_show_shield_break()
		$SonidoEscudoRoto.play()
		print("ESCUDO ROTO")
		return

	lives -= 1
	update_lives()
	$SonidoDano.play()
	_play_damage_anim()

	print("Vidas:", lives)

	if lives <= 0:
		get_parent().game_over()
		queue_free()


func _on_Player_area_entered(area):

	if area.is_in_group("meteor"):
		print("METEORITO")
		damage()
		area.queue_free()

	elif area.is_in_group("enemy_bullet"):
		print("BALA ENEMIGA")
		damage()
		area.queue_free()

	elif area.is_in_group("enemy"):
		print("ENEMIGO")
		damage()


func shoot():
	var bullet_left = Bullet.instance()
	var bullet_right = Bullet.instance()

	get_parent().add_child(bullet_left)
	get_parent().add_child(bullet_right)

	bullet_left.global_position = $Cannons/LeftCannon.global_position
	bullet_right.global_position = $Cannons/RightCannon.global_position
	$SonidoLanza.play()


func _physics_process(delta):
	_update_shield_recharge(delta)
	_update_shield_break(delta)
	_update_damage_anim(delta)

	var velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1

	var device = _get_connected_device()
	if device >= 0:
		var deadzone = 0.15
		var right_x = Input.get_joy_axis(device, 2)
		var right_y = Input.get_joy_axis(device, 3)
		if abs(right_x) > deadzone:
			velocity.x = right_x
		if abs(right_y) > deadzone:
			velocity.y = right_y

	if velocity.length() > 0:
		velocity = velocity.normalized()

	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = dash_time
		sprite.modulate = Color(0.5, 0.8, 1)

	if device >= 0 and Input.is_action_just_pressed("controller_dash") and not is_dashing:
		is_dashing = true
		dash_timer = dash_time
		sprite.modulate = Color(0.5, 0.8, 1)

	if is_dashing:
		position += velocity * dash_speed * delta
		dash_timer -= delta

		if dash_timer <= 0:
			is_dashing = false
			sprite.modulate = Color(1, 1, 1)
	else:
		position += velocity * speed * delta

	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		$ShootTimer.start()

	if device >= 0 and Input.is_action_just_pressed("controller_shoot") and can_shoot:
		shoot()
		can_shoot = false
		$ShootTimer.start()

	if device >= 0:
		var trigger = Input.get_joy_axis(device, 7)
		if trigger > 0.5 and can_shoot:
			shoot()
			can_shoot = false
			$ShootTimer.start()

	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

	if device >= 0 and Input.is_action_just_pressed("controller_pause"):
		get_tree().paused = !get_tree().paused


func _update_shield_recharge(delta):
	if not shield_recharging:
		return

	shield_recharge_progress += delta
	var ratio = min(shield_recharge_progress / shield_recharge_time, 1.0)
	shield = max_shield * ratio
	_update_shield_bar()

	if ratio >= 1.0:
		shield = max_shield
		shield_recharging = false
		$SonidoEscudoRecarga.play()
		print("ESCUDO RECARGADO")


func _update_shield_bar():
	if not shield_bar:
		return

	var frame_count = 5
	var shield_ratio = shield / max_shield
	var frame_idx = (frame_count - 1) - int(shield_ratio * (frame_count - 1))

	shield_bar.frame = frame_idx


func _show_shield_break():
	if not shield_break_icon:
		return
	shield_break_icon.visible = true
	shield_break_timer = 1.5


func _update_shield_break(delta):
	if not shield_break_icon or not shield_break_icon.visible:
		return
	shield_break_timer -= delta
	if shield_break_timer <= 0:
		shield_break_icon.visible = false


func _play_damage_anim():
	if not damage_overlay:
		return
	damage_overlay.visible = true
	damage_anim_frame = 0
	damage_anim_timer = 0.0
	damage_anim_playing = true
	damage_overlay.region_rect = damage_frames[0]


func _update_damage_anim(delta):
	if not damage_anim_playing or not damage_overlay:
		return
	damage_anim_timer += delta
	if damage_anim_timer >= 0.1:
		damage_anim_timer -= 0.1
		damage_anim_frame += 1
		if damage_anim_frame >= damage_frames.size():
			damage_anim_playing = false
			damage_overlay.visible = false
		else:
			damage_overlay.region_rect = damage_frames[damage_anim_frame]


func _on_ShootTimer_timeout():
	can_shoot = true
