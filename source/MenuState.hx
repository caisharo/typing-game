package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuState extends BasicMenuState
{
	override public function create()
	{
		// Will probably disable mouse since we want our controls to be keyboard-based
		// Currently not disabled just to make testing a bit easier
		#if (!FLX_NO_MOUSE)
		FlxG.mouse.visible = false;
		#end

		if (FlxG.save.data.clearedTutorial != null)
		{
			trace("tutorial completed: " + FlxG.save.data.clearedTutorial);
		}

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		var titleText = new FlxText(0, 0, 0, "type a latte", 150);
		titleText.setFormat("assets/fonts/SuperSimpleBrushScript.ttf", 150, FlxColor.fromString("#FAF4E9"));
		titleText.screenCenter();
		titleText.y = 64;
		add(titleText);

		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Start", startGame);
		addMenuItem("Tutorial", startTutorial);
		addMenuItem("Shop", openShop);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function startGame()
	{
		// log it?
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_START, {pressed: "start", from: "main_menu"});
		}

		// Use saved value?
		if (FlxG.save.data.dayCompleted != null)
		{
			PlayState.day = FlxG.save.data.dayCompleted + 1;
		}
		if (FlxG.save.data.playerMoney != null)
		{
			PlayState.money = FlxG.save.data.playerMoney;
		}
		FlxG.switchState(new PlayState());
	}

	function startTutorial()
	{
		// log it?
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "main_menu"});
		}

		FlxG.switchState(new TutorialMenuState());
	}

	function openShop()
	{
		FlxG.switchState(new ShopState());
	}
}
