extends Area2D

signal params_changed

export (float) var radius = 100
export (float) var strength = 10 
export (float) var lifetime = 10.0

var player = false
var current_lifetime
var age_modifier = 1.0


func _ready():
    current_lifetime = lifetime
    
    var shape = CircleShape2D.new()    
    $CollisionShape2D.shape = shape              
    
    var anim = 'cold'  
    if strength > 0:
        anim = 'hot'
    
    $AnimationPlayer.current_animation = anim
    $AnimationPlayer.play()                          
    
    connect("params_changed", self, "_update_params")        
    connect("body_entered", self, "_body_entered")    
    connect("body_exited", self, "_body_exited")
    
    $Life.connect("timeout", self, "age")
    $Life.start()
    
    emit_signal("params_changed")
    

func _body_entered(body):
    player = body
    
    
func _body_exited(body):
    player = null
    
    
func _update_params():
    var shade = clamp(0.2 + abs(strength * age_modifier / 100), 0, 1)    
    var color = Color(0, 0, shade)    
    
    if strength > 0:    
        color = Color(shade, 0, 0)                    
    
    $Label.text = "%3.1f" % (strength * age_modifier)
    $Label.add_color_override("font_color", color)
    
    $BackgroundLight.color = color
    $BackgroundLight.energy = 2 + 3 * abs(strength * age_modifier) / 100
    $BackgroundLight.texture_scale = radius * age_modifier * 1.07 / 100
    
    $CollisionShape2D.shape.radius = radius * age_modifier      
    
    
func age():
    current_lifetime -= $Life.wait_time
    
    if current_lifetime <= 0:
        queue_free()
    
    age_modifier = current_lifetime / lifetime    
    emit_signal("params_changed")
    

func _physics_process(delta):
    # adjust player heat
    if player:        
        var distance = to_local(player.get_global_position()).length() - player.get_node('CollisionShape2D').shape.radius * player.scale.x
        var distance_modifier = 1 - clamp(distance / radius, 0, 1)
        player.heat(strength * delta * distance_modifier * age_modifier)
        
