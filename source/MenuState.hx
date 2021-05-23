package;

import flixel.FlxG;
import flixel.effects.FlxFlicker;
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

		if (Main.isDebugging && FlxG.save.data.clearedTutorial != null)
		{
			trace("tutorial completed: " + FlxG.save.data.clearedTutorial);
		}

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		yShift = 350;

		var titleText = new FlxText(0, 0, 0, "type a latte", 150);
		titleText.setFormat("assets/fonts/SuperSimpleBrushScript.ttf", 150, FlxColor.fromString("#FAF4E9"));
		titleText.screenCenter();
		titleText.y = 80;
		add(titleText);

		menuItems = new FlxTypedGroup<FlxText>();
		if (FlxG.save.data.clearedTutorial != null)
		{
			addMenuItem("Start", startGame);
			addMenuItem("Tutorial", startTutorial);
			addMenuItem("Shop", openShop);
		}
		else
		{
			// Only show tutorial if player hasn't finished
			addMenuItem("Tutorial", startTutorial);
		}

		var keyboardOnlyText = new FlxText(0, 0, 0, "This is a keyboard only game.", 20);
		keyboardOnlyText.setFormat("assets/fonts/Kaorigelbold.ttf", 20);
		keyboardOnlyText.screenCenter();
		keyboardOnlyText.y = 600;
		keyboardOnlyText.alpha = .7;
		add(keyboardOnlyText);
		// FlxFlicker.flicker(keyboardOnlyText, 0, 0.9);

		var menuControlText = new FlxText(0, 0, 0, "Use UP/DOWN, W/S, or TAB to navigate menus.", 20);
		menuControlText.setFormat("assets/fonts/Kaorigelbold.ttf", 20);
		menuControlText.screenCenter();
		menuControlText.y = 630;
		menuControlText.alpha = .7;
		add(menuControlText);
		// FlxFlicker.flicker(menuControlText, 0, 0.9);

		var enterText = new FlxText(0, 0, 0, "Press ENTER to select.", 20);
		enterText.setFormat("assets/fonts/Kaorigelbold.ttf", 20);
		enterText.screenCenter();
		enterText.y = 660;
		enterText.alpha = .7;
		add(enterText);
		// FlxFlicker.flicker(enterText, 0, 0.9);

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
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SHOP, {pressed: "shop", from: "main_menu"});
		}
		FlxG.switchState(new ShopState());
	}
}
