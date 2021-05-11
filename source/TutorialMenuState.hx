package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TutorialMenuState extends BasicMenuState
{
	override public function create()
	{
		// Will probably disable mouse since we want our controls to be keyboard-based
		// Currently not disabled just to make testing a bit easier
		FlxG.mouse.visible = true;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		var titleText = new FlxText(0, 0, 0, "I want to know about...", 64);
		titleText.screenCenter();
		titleText.y = 64;
		add(titleText);

		yShift = 300;
		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Concept", startIntro);
		addMenuItem("Select", startSelect);
		addMenuItem("Submit", startType);
		addMenuItem("Menu", startMenu);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function startIntro()
	{
		// log it?
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_INTRO, {pressed: "intro", from: "tutorial_menu"});
		}

		FlxG.switchState(new IntroState());
	}

	function startSelect()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SELECT, {pressed: "select", from: "tutorial_menu"});
		}
		FlxG.switchState(new SelectState());
	}

	function startType()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TYPE, {pressed: "type", from: "tutorial_menu"});
		}
		FlxG.switchState(new TypeState());
	}

	function startMenu()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "Menu", from: "tutorial_menu"});
		}
		FlxG.switchState(new MenuState());
	}
}
