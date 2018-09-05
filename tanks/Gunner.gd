extends "res://tanks/Player.gd"

export (float) var _overheat
export (float) var _oh_cooldown

var overheated
var bar_red = preload("res://assets/UI/barHorizontal_red_mid 200.png")
var bar_green = preload("res://assets/UI/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://assets/UI/barHorizontal_yellow_mid 200.png")

signal overheating
signal cooling

func _ready():
	overheated = false
	$Overheat.wait_time = _overheat
	$OH_Cooldown.wait_time = _oh_cooldown
	$OverHeatDisplay/HealthBar.max_value = _overheat

func control(delta):
	$Turret.look_at(get_global_mouse_position())
	var rot_dir = 0
	if Input.is_action_just_pressed('reset'):
		get_tree().reload_current_scene()
	if Input.is_action_pressed('turn_right'):
		rot_dir += 1
	if Input.is_action_pressed('turn_left'):
		rot_dir -= 1
	rotation += rotation_speed * rot_dir * delta
	velocity = Vector2()
	if Input.is_action_pressed('forward'):
		velocity += Vector2(max_speed, 0).rotated(rotation)
	if Input.is_action_pressed('back'):
		velocity += Vector2(-max_speed, 0).rotated(rotation)
		velocity /= 2.0
	if Input.is_action_just_pressed('click'):
		if !$Overheat.paused:
			$Overheat.start()
		else:
			$Overheat.paused = false
	if Input.is_action_pressed('click'):
		if !overheated:
			emit_signal('overheating', $Overheat.time_left)
			shoot(gun_shots, gun_spread)
			$Turret.play('shooting')
	if Input.is_action_just_released('click'):
		$Turret.play('idle')
		$Overheat.paused = true
		$OH_Cooldown.start()

func _process(delta):
	if !$OH_Cooldown.is_stopped():
		emit_signal('cooling', $OH_Cooldown.time_left)
		#_on_Player_cooling($OH_Cooldown.time_left)

func shoot(num, spread, target=null):
	if can_shoot:
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1, 0).rotated($Turret.global_rotation)
		if num > 1:
			for i in range(num):
				var a = -spread + i * (2*spread)/(num-1)
				emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir.rotated(a), target)
		else:
			emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir, target)
		$AnimationPlayer.play('muzzle_flash')

func _on_Overheat_timeout():
	overheated = true
	can_shoot = false
	$OH_Cooldown.start()
	$Overheat.stop()

func _on_OH_Cooldown_timeout():
	$OH_Cooldown.stop()
	overheated = false
	can_shoot = true
	#$Overheat.paused = false
	$Overheat.wait_time = _overheat
	$OH_Cooldown.wait_time = _oh_cooldown

func _on_Player_overheating(value):
	$OverHeatDisplay/HealthBar.texture_progress = bar_green
	value = value/$OverHeatDisplay/HealthBar.max_value
	$OverHeatDisplay/HealthBar.value = value*$OverHeatDisplay/HealthBar.max_value
	print(value)
	if value < 0.6:
		$OverHeatDisplay/HealthBar.texture_progress = bar_yellow
	if value < 0.25:
		$OverHeatDisplay/HealthBar.texture_progress = bar_red
	if value < 1:
		$OverHeatDisplay/HealthBar.show()

func _on_Player_cooling(value):
	value = value/$OverHeatDisplay/HealthBar.max_value
	print(value)