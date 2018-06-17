extends Node


signal difficulty_changed

var climate = preload('res://environment/LocalClimate.tscn')
var food = preload('res://environment/Food.tscn')

var walkable_area_start
var walkable_area_end

var difficulty = 1.0


func _ready():
    randomize()
    var screen_limits = Vector2($Ground.get_used_rect().end.x * $Ground.cell_size.x,
                                $Ground.get_used_rect().end.y * $Ground.cell_size.y)
    
    walkable_area_start = Vector2($Ground.cell_size.x, $Ground.cell_size.y)
    walkable_area_end = Vector2(screen_limits.x - $Ground.cell_size.x, screen_limits.y - $Ground.cell_size.y)
    
    $Player.get_node("Camera2D").limit_right = $Ground.get_used_rect().end.x * $Ground.cell_size.x
    $Player.get_node("Camera2D").limit_bottom = $Ground.get_used_rect().end.y * $Ground.cell_size.y
    
    $Player.connect("temperature_changed", $HUD, "update_temperature")
    $Player.connect("mass_changed", $HUD, "update_mass")
    $Player.connect("game_over", self, "game_over")
    
    connect("difficulty_changed", $HUD, "update_difficulty")
    
    $HUD.connect("start_game", self, "start_game")
    
    $FoodSpawn.connect("timeout", self, "spawn_food")
    $FoodSpawn.start()
    
    $ClimateSpawn.connect("timeout", self, "spawn_climate")
    $ClimateSpawn.start()
    
    $DifficultyRamp.connect("timeout", self, "difficulty_ramp_up")
    $DifficultyRamp.start()
    
    $HUD.in_game_hud.hide()
    
    get_tree().paused = true
    

func difficulty_ramp_up():
    var old_difficulty = difficulty
    difficulty += 0.1
    
    $FoodSpawn.wait_time = $FoodSpawn.wait_time * old_difficulty / difficulty
    $ClimateSpawn.wait_time = $ClimateSpawn.wait_time * old_difficulty / difficulty
    
    emit_signal("difficulty_changed", difficulty)


func spawn_food():
    var new_food = food.instance()    
    var nutrition = rand_range(-5, 5)
    if nutrition < 0:
        clamp(nutrition, -5, -2)
    else:
        clamp(nutrition, 2, 5)
    new_food.nutrition = nutrition * difficulty
    
    new_food.lifetime = rand_range(5, 10)
    
    var location = Vector2(rand_range(walkable_area_start.x, walkable_area_end.x),
                           rand_range(walkable_area_start.y, walkable_area_end.y))
                        
    $Food.add_child(new_food)
    new_food.set_position(location)
    
    
func spawn_climate():
    var new_climate = climate.instance()
    new_climate.strength = rand_range(-20, 20)
    new_climate.lifetime = rand_range(5, 30)
    new_climate.radius = rand_range(100, 600)
    
    var location = Vector2(rand_range(walkable_area_start.x, walkable_area_end.x),
                           rand_range(walkable_area_start.y, walkable_area_end.y))
                        
    $Climate.add_child(new_climate)
    new_climate.set_position(location)
    
    
func start_game():            
    $FoodSpawn.wait_time = 2
    $ClimateSpawn.wait_time = 5
    
    $Player.initialize()
    difficulty = 1    
    
    $HUD.main_menu.hide()
    $HUD.in_game_hud.show()
    
    get_tree().paused = false
    
    
func game_over():
    $HUD.menu_score.text = "%3.0f" % $Player.score
    get_tree().paused = true
    
    for child in $Climate.get_children():
        child.queue_free()
    
    for child in $Food.get_children():
        child.queue_free()
    
    $HUD.main_menu.show()
    $HUD.in_game_hud.hide()