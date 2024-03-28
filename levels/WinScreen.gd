extends Control

func _ready():
	TTs.speak("The hunters are victorious", true);
	TTs.speak("Return to main menu",false)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://StartMenu.tscn")
