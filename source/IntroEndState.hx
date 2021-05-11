package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class IntroEndState extends BasicMenuState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		if (Main.isLogging)
		{
			Main.logger.logLevelEnd({day_completed: -1, gained_money: 0, total_money: 0});
		}

		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Next", nextTutorial);
		addMenuItem("Tutorial", returnToTutorial);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function nextTutorial()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SELECT, {pressed: "next", from: "intro_end"});
		}
		FlxG.switchState(new SelectState());
	}

	function returnToTutorial()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "intro_end"});
		}
		FlxG.switchState(new TutorialMenuState());
	}
}
