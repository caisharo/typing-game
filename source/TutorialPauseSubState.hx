package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class TutorialPauseSubState extends BasicMenuSubState
{
	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		var mainText = new FlxText(0, 0, 0, "PAUSED", 64);
		mainText.setFormat("assets/fonts/Kaorigelbold.ttf", 64);
		mainText.screenCenter();
		mainText.y -= 70;
		add(mainText);

		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Return", returnToGame);
		addMenuItem("Menu", returnToTutorial);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function returnToTutorial()
	{
		FlxG.switchState(new TutorialMenuState());
	}

	function returnToGame()
	{
		FlxTimer.globalManager.forEach(function(timer) timer.active = true);
		close();
	}
}
