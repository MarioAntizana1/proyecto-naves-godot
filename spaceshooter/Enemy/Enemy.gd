extends Area2D

export (PackedScene) var EnemyBullet
export var velocity = Vector2(0, 100)
export var armor = 4

var can_move = true


func _physics_process(delta):

	if can_move:
		translate(velocity * delta)

	if position.y - 32 >= Utils.view_size.y:
		queue_free()



# =========================
# DISPARO ENEMIGO
# =========================

func _on_ShootTimer_timeout():

	print("DISPARANDO")

	if EnemyBullet:

		var b = EnemyBullet.instance()

		var shoot_point = get_node_or_null("ShootPoint")

		if shoot_point:
			b.global_position = shoot_point.global_position
		else:
			b.global_position = global_position

		get_parent().add_child(b)

		$laserEnemy.play()



# =========================
# DAÑO AL ENEMIGO
# =========================

func _on_Enemy_area_entered(area):

	if area.is_in_group("bullet"):

		print("ME DISPARARON")

		armor -= 1
		area.queue_free()

		$hitenemy.play()



	elif area.is_in_group("player"):

		print("CHOQUÉ CON EL JUGADOR")

		armor = 0



	# =========================
	# MUERTE DEL ENEMIGO
	# =========================

	if armor <= 0:

		if get_parent().has_method("add_score"):
			get_parent().add_score(100)

		print("ENEMIGO DESTRUIDO")

		_spawn_explosion()

		$explotion.play()

		$CollisionShape2D.disabled = true

		hide()

		yield($explotion, "finished")

		queue_free()


func _spawn_explosion():
	var explosion = preload("res://sprites/Explosion.tscn").instance()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
