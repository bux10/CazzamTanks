extends "res://tanks/Player.gd"

var burn = false

func _ready():
	$Turret/Flames.emitting = false

#Flame Thrower STuff
export (float) var burn_rate

var targets = []
var can_burn = true


func control(delta):
	$Turret.look_at(get_global_mouse_position())
	var rot_dir = 0
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
		shoot(gun_shots, gun_spread)
	if Input.is_action_pressed('alt_click'):
		burn()
	if Input.is_action_just_released('alt_click'):
		stop_burn()

func _on_FlameCone_body_entered(body):
	if body.has_method('take_damage'):
		#$Turret/Flames.emitting = true
		#$BurnTimer.start()
		can_burn = true
		targets.append(body)
		print(targets)
		#burn()
		
func burn():
	$Turret/Flames.emitting = true
	print(can_burn)
	if can_burn:
		$BurnTimer.start()
		for t in targets:
			t.take_damage(15)
		can_burn = false
		
func stop_burn():
	$Turret/Flames.emitting = false
	$BurnTimer.stop()

func _on_FlameCone_body_exited(body):
	if body.has_method('take_damage'):
		targets.erase(body)
		print(targets)


func _on_BurnTimer_timeout():
	if targets.size() != 0:
		can_burn = true
	else:
		$BurnTimer.stop()
		can_burn = true
