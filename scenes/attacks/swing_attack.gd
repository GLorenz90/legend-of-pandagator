extends Attack

@export var swing_arc_degrees := 120.0;

func _on_attack_start() -> void:
  effect.rotation_degrees.y = swing_arc_degrees / 2.0;
  var tween := create_tween();
  tween.tween_property(effect, "rotation_degrees:y", -swing_arc_degrees / 2.0, lifetime);
#/_on_attack_start
