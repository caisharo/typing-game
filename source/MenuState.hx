package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	override public function create()
	{
		// Will probably disable mouse since we want our controls to be keyboard-based
		// Currently not disabled just to make testing a bit easier
		// FlxG.mouse.visible = false;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		var titleText = new FlxText(0, 0, 0, "Typing Game", 64);
		titleText.screenCenter();
		titleText.y = 64;
		add(titleText);

		var playText = new FlxText(0, 0, 0, "PRESS ENTER", 32);
		playText.screenCenter();
		playText.y += 32;
		add(playText);
		FlxFlicker.flicker(playText, 0, .7);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedEnter)
		{
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}
