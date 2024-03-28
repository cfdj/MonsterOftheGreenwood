extends PanelContainer
@export var level:LevelManager

@export var text:Label
@export var button:Button
var tutorialProgress = 0;
@export var tutorialText:Array[String];
func _ready():
	if(Settings.tutorialViewed):
		visible = false;
	else:
		button.grab_focus()
		display();

func display(): 
	if(tutorialProgress < tutorialText.size()):
		text.text = tutorialText[tutorialProgress];
		TTs.speak(tutorialText[tutorialProgress],false);
		tutorialProgress+=1;
	else:
		Settings.tutorialViewed = true;
		tutorialDone();
func tutorialDone():
	level.focus = true;
	level.displayMove();
	visible = false
