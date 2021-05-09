package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends FlxSubState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		var mainText = new FlxText(0, 0, 0, "PAUSED", 64);
		mainText.screenCenter();
		mainText.y -= 70;
		add(mainText);

		var returnButton = new FlxButton(0, 0, "Return", returnToGame);
		returnButton.screenCenter();
		returnButton.scale.x = returnButton.scale.y = 3;
		returnButton.label.size = 14;
		returnButton.label.alignment = FlxTextAlign.CENTER;
		returnButton.y += 100;
		add(returnButton);

		var menuButton = new FlxButton(0, 0, "Menu", returnToMenu);
		menuButton.screenCenter();
		menuButton.scale.x = menuButton.scale.y = 3;
		menuButton.label.size = 14;
		menuButton.label.alignment = FlxTextAlign.CENTER;
		menuButton.y += 200;
		add(menuButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function returnToMenu()
	{
		FlxG.switchState(new MenuState());
	}

	function returnToGame()
	{
		FlxTimer.globalManager.forEach(function(timer) timer.active = true);
		close();
	}
}
