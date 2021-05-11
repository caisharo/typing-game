package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class SelectEndState extends BasicMenuState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		if (Main.isLogging)
		{
			Main.logger.logLevelEnd({day_completed: -2, gained_money: 0, total_money: 0});
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
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TYPE, {pressed: "next", from: "select_end"});
		}
		FlxG.switchState(new TypeState());
	}

	function returnToTutorial()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "select_end"});
		}
		FlxG.switchState(new TutorialMenuState());
	}
}
