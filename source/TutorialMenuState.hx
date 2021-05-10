package;

import cse481d.logging.CapstoneLogger;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.FlxAccelerometer;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxRange;

class TutorialMenuState extends FlxState
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

		var introButton = new FlxButton(0, 0, "Concept", startIntro);
		introButton.screenCenter();
		introButton.scale.x = introButton.scale.y = 3;
		introButton.label.size = 14;
		introButton.label.alignment = FlxTextAlign.CENTER;
		introButton.y -= 30;
		add(introButton);

		var selectButton = new FlxButton(0, 0, "Select", startSelect);
		selectButton.screenCenter();
		selectButton.scale.x = selectButton.scale.y = 3;
		selectButton.label.size = 14;
		selectButton.label.alignment = FlxTextAlign.CENTER;
		selectButton.y += 45;
		add(selectButton);

		var typeButton = new FlxButton(0, 0, "Submit", startType);
		typeButton.screenCenter();
		typeButton.scale.x = typeButton.scale.y = 3;
		typeButton.label.size = 14;
		typeButton.label.alignment = FlxTextAlign.CENTER;
		typeButton.y += 120;
		add(typeButton);

		var menuButton = new FlxButton(0, 0, "Menu", startMenu);
		menuButton.screenCenter();
		menuButton.scale.x = menuButton.scale.y = 3;
		menuButton.label.size = 14;
		menuButton.label.alignment = FlxTextAlign.CENTER;
		menuButton.y += 210;
		add(menuButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function startIntro()
	{
		// log it?
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_INTRO, {pressed: "intro", from: "tutorial_menu"});

		FlxG.switchState(new IntroState());
	}

	function startSelect()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SELECT, {pressed: "select", from: "tutorial_menu"});
		FlxG.switchState(new SelectState());
	}

	function startType()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TYPE, {pressed: "type", from: "tutorial_menu"});
		FlxG.switchState(new TypeState());
	}

	function startMenu()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "Menu", from: "tutorial_menu"});
		FlxG.switchState(new MenuState());
	}
}
