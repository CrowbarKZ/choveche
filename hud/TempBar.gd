extends TextureRect


export (float) var temperature = 0 setget _update_temp
    

func _update_temp(value): 
    if is_inside_tree():        
        var fraction = (value + 100) / 200                
        $Arrow.rect_position.x = lerp(27, 124, fraction)