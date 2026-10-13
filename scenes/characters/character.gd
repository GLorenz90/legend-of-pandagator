extends CharacterBody3D
class_name Character;

#region PRIVATE VARS =============================================================
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity");
var _max_health := 1;
var _cur_health := 1:
  set(value):
    _cur_health = clampi(value, 0, _max_health);
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
func _is_interrupted() -> bool:
  return !($InterruptTimer.is_stopped()) && !($HurtTimer.is_stopped());
#/_is_interrupted

func _damage_recoil(_damage_location: Vector3) -> void:
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
  if($InvulnTimer.is_stopped()):
    _cur_health -= value;
    _damage_recoil(from_location);
    $HurtTimer.start();
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
