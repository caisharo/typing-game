package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class DayEndState extends BasicMenuState
{
	public static var day = 0;
	public static var money = 0;
	public static var performance = 0.0;

	override public function create()
	{
		// save day and money
		FlxG.save.data.dayCompleted = day;
		var lastSavedMoney = 0;
		if (FlxG.save.data.playerMoney != null)
		{
			lastSavedMoney = FlxG.save.data.playerMoney;
		}
		FlxG.save.data.playerMoney = money;
		var difference = money - lastSavedMoney;
		FlxG.save.data.performance = performance;
		FlxG.save.flush(); // save data

		// logging level end
		if (Main.isLogging)
		{
			Main.logger.logLevelEnd({
				day_completed: day,
				gained_money: difference,
				total_money: money,
				avg_patience_left: performance
			});
		}

		var mainText = new FlxText(0, 0, 0, "END OF DAY " + day, 64);
		mainText.setFormat("assets/fonts/Kaorigelbold.ttf", 64, FlxColor.fromString("#FAF4E9"));
		mainText.screenCenter();
		mainText.y -= 150;
		add(mainText);

		var subText = new FlxText(0, 0, 0, "Money Earned: " + difference, 32);
		subText.setFormat("assets/fonts/Kaorigel.ttf", 32);
		subText.screenCenter();
		subText.y -= 90;
		add(subText);

		var subText2 = new FlxText(0, 0, 0, "Total: " + money, 32);
		subText2.setFormat("assets/fonts/Kaorigel.ttf", 32);
		subText2.screenCenter();
		subText2.y -= 45;
		add(subText2);

		menuItems = new FlxTypedGroup<FlxText>();
		yShift = 375;
		addMenuItem("Continue", nextLevel);
		addMenuItem("Shop", openShop);
		addMenuItem("Main Menu", returnToMenu);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function openShop()
	{
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SHOP, {pressed: "shop", from: "main_menu"});
		}
		FlxG.switchState(new ShopState());
	}

	function returnToMenu()
	{
		// log it?
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_RETURN_TO_MENU, {pressed: "menu", from: "day_end"});
		}
		FlxG.switchState(new MenuState());
	}

	function nextLevel()
	{
		// log it?
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.PRESS_NEXT_LEVEL, {pressed: "next", from: "day_end"});
		}

		PlayState.day = day + 1;
		FlxG.switchState(new PlayState());
	}
}
