extends Node


func hide():
    for child in get_children():
        child.hide()
        
        
func show():
    for child in get_children():
        child.show()