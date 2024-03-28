extends Control

@export var TTsenable:CheckButton;
@export var TTSVolume:Slider;
@export var TTSRate:Slider;
@export var keyboard:CheckButton;
@export var voices:OptionButton;
@export var contrast:CheckButton;
func _ready():
	TTsenable.set_pressed_no_signal(TTs.enabled)
	TTSVolume.set_value_no_signal(TTs.volume)
	TTSRate.set_value_no_signal(TTs.rate)
	keyboard.set_pressed_no_signal(!Settings.mouse)	
	contrast.set_pressed_no_signal(Settings.highContrast);
	var voiceArray = DisplayServer.tts_get_voices_for_language("en")
	for i in voiceArray.size():
		voices.add_item(str(i));
	TTsenable.grab_focus()
	TTs.speak("Monsters of the Greenwood",false)
	
func _on_start_game_focus_entered():
	TTs.speak("Start Game",false)

func _on_start_game_pressed():
	TTs.speak("entering the greenwood",false)
	get_tree().change_scene_to_file("res://levels/Level1.tscn")


func _on_tts_enabled_toggled(toggled_on):
	TTs.enabled = toggled_on


func _on_tts_enabled_focus_entered():
	TTs.speak("TTS enabled",false)


func _on_volume_drag_ended(value_changed):
	TTs.volume = TTSVolume.value;
	TTs.speak(str(TTs.volume),false)

func _on_volume_focus_entered():
	TTs.speak("TTS volume",false)


func _on_rate_drag_ended(value_changed):
	TTs.rate = TTSRate.value
	TTs.speak(str(TTs.rate),false)


func _on_voices_focus_entered():
	TTs.speak("TTS voice",false)


func _on_voices_item_focused(index):
	TTs.speak(str(index),false)

func _on_voices_item_selected(index):
	TTs.speak("Voice selected",false)
	if(index != -1):
		TTs.voice = index


func _on_check_button_toggled(toggled_on):
	if toggled_on:
		TTs.speak("Keyboard/Controller enabled",false)
		Settings.mouse = !toggled_on
	else:
		TTs.speak("Mouse controls enabled",false)
		Settings.mouse = !toggled_on


func _on_check_button_focus_entered():
	TTs.speak("Enable keyboard/controller",false)


func _on_quit_pressed():
	get_tree().quit()


func _on_quit_focus_entered():
	TTs.speak("Quit game",false)


func _on_contrast_mode_focus_entered():
	TTs.speak("Enable high contrast",false)

func _on_contrast_mode_toggled(toggled_on):
	Settings.highContrast = toggled_on


func _on_rate_focus_entered():
	TTs.speak("TTs rate",false)
