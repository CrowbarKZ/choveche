extends KinematicBody2D


signal temperature_changed
signal mass_changed
signal game_over


const SCALING_MAX_MASS = 400
const SCALING_MAX_VULNERABILITY = 3


onready var anim_player = $AnimationPlayer

export (float) var mass = 10
export (float) var temperature = 50

export (float) var max_speed = 200
export (float) var max_acceleration = 60

var velocity = Vector2()
var acceleration = 0
var score = 0
var cold_vulnerability = 1
var heat_vulnerability = 1
var can_move = true


func _ready():
    anim_player.current_animation = 'move'
    anim_player.play()  

    connect("mass_changed", self, "adjust_body_params")
    

func initialize():
    position = Vector2(100, 100)
    mass = 100
    temperature = 1.0
    score = 0
    
    emit_signal('temperature_changed', temperature)
    emit_signal('mass_changed', mass, score, heat_vulnerability, cold_vulnerability)    
        
        
func _physics_process(delta):
    movement_loop(delta)
    
    
func movement_loop(delta):
    var v = int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
    var h = int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left'))
    
    acceleration = Vector2(h, v).normalized() * max_acceleration
    var friction = -velocity.normalized() * get_surface_friction()
    velocity = (velocity + acceleration + friction).clamped(max_speed)
        
    # linear decay to avoid weird slow movement with no input
    velocity = velocity * 0.98
    
    if velocity.length() < 1:
        velocity = Vector2()
    
    move_and_slide(velocity)
    

func heat(amount):
    if amount < 0:
        amount *= cold_vulnerability
    else:
        amount *= heat_vulnerability        
        
    temperature += amount 
    emit_signal('temperature_changed', temperature)
    
    if temperature < -100 or temperature > 100:
        emit_signal('game_over')
    
    
func feed(amount):
    can_move = false
    anim_player.current_animation = 'eat'
    anim_player.play()    
    $Munch.play()
    
    mass += amount    
    add_score(abs(amount))
    
    # calculate vulnerabilityes
    var clamped_mass = clamp(mass, 1, SCALING_MAX_MASS)
    cold_vulnerability = clamp(SCALING_MAX_VULNERABILITY * (1 - (clamped_mass / SCALING_MAX_MASS)), 
                               0.1, SCALING_MAX_VULNERABILITY)
    heat_vulnerability = clamp(SCALING_MAX_VULNERABILITY * clamped_mass / SCALING_MAX_MASS, 
                               0.1, SCALING_MAX_VULNERABILITY) 
    
    emit_signal('mass_changed', mass, score, heat_vulnerability, cold_vulnerability)
    
    if mass < 0:
        mass = 0
        emit_signal('game_over')
        
    yield(anim_player, 'animation_finished')
    anim_player.current_animation = 'move'
    can_move = true
    
    
func add_score(amount):
    score += amount
    if score < 0:
        score = 0    
    
    
func adjust_body_params(mass, score, heat_vulnerability, cold_vulnerability):
    # all the magic numbers are found experimentally
    
    max_speed = clamp(SCALING_MAX_MASS - mass, 70, SCALING_MAX_MASS) 
    max_acceleration = max_speed / 3.5    
    
    var scale_factor = clamp(mass / 100, 0.3, SCALING_MAX_MASS / 100)
    $Particles2D.process_material.scale = scale_factor
    
    $Tween.interpolate_property(self, "scale",
                                scale, Vector2(scale_factor, scale_factor), 1,
                                Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)    
    $Tween.start()
    

func get_surface_friction():
    return 15