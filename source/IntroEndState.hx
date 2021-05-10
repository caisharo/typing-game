package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import js.html.SelectElement;

class IntroEndState extends FlxState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		Main.logger.logLevelEnd({day_completed: -1, gained_money: 0, total_money: 0});

		var nextButton = new FlxButton(0, 0, "Next", nextTutorial);
		nextButton.screenCenter();
		nextButton.scale.x = nextButton.scale.y = 3;
		nextButton.label.size = 14;
		nextButton.label.alignment = FlxTextAlign.CENTER;
		nextButton.y += 100;
		add(nextButton);

		var tutorialButton = new FlxButton(0, 0, "Tutorial", returnToTutorial);
		tutorialButton.screenCenter();
		tutorialButton.scale.x = tutorialButton.scale.y = 3;
		tutorialButton.label.size = 14;
		tutorialButton.label.alignment = FlxTextAlign.CENTER;
		tutorialButton.y += 200;
		add(tutorialButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function nextTutorial()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SELECT, {pressed: "next", from: "intro_end"});
		FlxG.switchState(new SelectState());
	}

	function returnToTutorial()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "intro_end"});
		FlxG.switchState(new TutorialMenuState());
	}
}
