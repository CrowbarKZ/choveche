extends CanvasLayer


signal start_game

onready var temp_bar = $InGame/TempBar
onready var mass_label = $InGame/TopBar/Line2/Mass
onready var score_label = $InGame/TopBar/Line3/Score
onready var heatv_label = $InGame/TopBar/Line5/HeatV
onready var coldv_label = $InGame/TopBar/Line6/ColdV
onready var difficulty_label = $InGame/TopBar/Line4/Difficulty

onready var menu_score = $StartMenu/Panel/Lines/Score
onready var menu_start = $StartMenu/Panel/Lines/Start

onready var main_menu = $StartMenu
onready var in_game_hud = $InGame


func _ready():
    menu_start.connect("pressed", self, "start")
    

func _input(event):    
    if event.is_action_pressed('fullscreen'):
        OS.window_fullscreen = !OS.window_fullscreen


func update_mass(mass, score, heatv, coldv):    
    mass_label.text = "%3.1f" % mass
    score_label.text = "%3.0f" % score    
    heatv_label.text = "%3.2f" % heatv
    coldv_label.text = "%3.2f" % coldv
    

func update_temperature(temperature):    
    temp_bar.temperature = temperature
    

func update_difficulty(difficulty):
    difficulty_label.text = "%3.1f" % difficulty
    
    
func start():
    emit_signal("start_game")