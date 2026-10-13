extends CharacterBody3D
class_name Character;

#region PRIVATE VARS =============================================================
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity");
@export var _max_health := 1;
@export var _cur_health := 1:
  set(value):
    _cur_health = clampi(value, 0, _max_health);
@export var _invulnerable = false;
#endregion

#region PUBLIC VARS =============================================================
@export var has_gravity:bool = true;
#endregion

#region BUILT IN ===================================================================================
func _ready() -> void:
  pass
#/_ready

func _physics_process(_delta: float) -> void:
  if _cur_health <= 0:
    _die();
  #/if
#/_physics_process
#endregion =========================================================================================

#region PRIVATE ====================================================================================
func _handle_damage(from_location := Vector3.FORWARD) -> void:
  #override me
  pass
#/_damage_recoil()

func _die():
  #override me
  queue_free();
#/_die
#endregion =========================================================================================

#region PUBLIC =====================================================================================
func damage(value: int, from_location := Vector3.FORWARD) -> void:
  if($InvulnTimer.is_stopped() && !_invulnerable):
    _cur_health -= value;
    _handle_damage(from_location);
    $InvulnTimer.start();
  #/if
#/damage

func heal(value: int) -> void:
  if($HealTimer.is_stopped()):
    _cur_health += value;
    $HealTimer.start();
  #/if
#/damage
#endregion =========================================================================================
