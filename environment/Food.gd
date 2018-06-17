extends Area2D


export (float) var nutrition = 5
export (float) var lifetime = 10


func _ready():
    if nutrition > 0:
        $Sprite.frame = 7
    else:
        $Sprite.frame = 6
    
    $AnimationPlayer.current_animation = 'idle'
    $AnimationPlayer.play()
    
    connect("body_entered", self, "get_eaten")
    
    $Label.text = "%3.1f" % nutrition
    
    $Life.wait_time = lifetime
    $Life.connect("timeout", self, "expire")
    $Life.start()
    
    
func expire():
    queue_free()
    
    
func get_eaten(body):
    body.feed(nutrition)
    queue_free()
    
    