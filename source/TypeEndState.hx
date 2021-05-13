package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class TypeEndState extends BasicMenuState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		if (Main.isLogging)
		{
			Main.logger.logLevelEnd({day_completed: -3, gained_money: 0, total_money: 0});
		}

		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Tutorial", returnToTutorial);
		addMenuItem("Menu", returnToMenu);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function returnToTutorial()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "type_end"});
		}
		FlxG.switchState(new TutorialMenuState());
	}

	function returnToMenu()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_RETURN_TO_MENU, {pressed: "menu", from: "type_end"});
		}
		FlxG.switchState(new MenuState());
	}
}
