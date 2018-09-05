extends "res://ui/UnitDisplay.gd"

func update_healthbar():
	pass
	
func update_overheat(value):
	$HealthBar.texture_progress = bar_green
	if value < 60:
		$HealthBar.texture_progress = bar_yellow
	if value < 25:
		$HealthBar.texture_progress = bar_red
	if value < 100:
		$HealthBar.show()
	$HealthBar.value = value
