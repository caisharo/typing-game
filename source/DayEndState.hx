package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class DayEndState extends FlxState
{
	public static var day = 0;
	public static var money = 0;

	override public function create()
	{
		// Mouse has to be visible for now since we use buttons
		FlxG.mouse.visible = true;

		// save day and money
		FlxG.save.data.dayCompleted = day;
		var lastSavedMoney = 0;
		if (FlxG.save.data.playerMoney != null)
		{
			lastSavedMoney = FlxG.save.data.playerMoney;
		}
		FlxG.save.data.playerMoney = money;
		var difference = money - lastSavedMoney;

		// logging level end
		Main.logger.logLevelEnd({day_completed: day, gained_money: difference, total_money: money});

		var mainText = new FlxText(0, 0, 0, "END OF DAY " + day, 64);
		mainText.screenCenter();
		mainText.y -= 70;
		add(mainText);

		var subText = new FlxText(0, 0, 0, "Money Earned: " + difference, 32);
		subText.screenCenter();
		add(subText);

		var nextButton = new FlxButton(0, 0, "Continue", nextLevel);
		nextButton.screenCenter();
		nextButton.scale.x = nextButton.scale.y = 3;
		nextButton.label.size = 14;
		nextButton.label.alignment = FlxTextAlign.CENTER;
		nextButton.y += 100;
		add(nextButton);

		var menuButton = new FlxButton(0, 0, "Menu", returnToMenu);
		menuButton.screenCenter();
		menuButton.scale.x = menuButton.scale.y = 3;
		menuButton.label.size = 14;
		menuButton.label.alignment = FlxTextAlign.CENTER;
		menuButton.y += 200;
		add(menuButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function returnToMenu()
	{
		// log it?
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_RETURN_TO_MENU, {pressed: "menu", from: "day_end"});
		FlxG.switchState(new MenuState());
	}

	function nextLevel()
	{
		// log it?
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_NEXT_LEVEL, {pressed: "next", from: "day_end"});

		PlayState.day = day + 1;
		FlxG.switchState(new PlayState());
	}
}
