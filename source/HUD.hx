package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var background:FlxSprite;
	var moneyCounter:FlxText;
	var dayCounter:FlxText;

	// for if/when we eventually add money icon
	var moneyIcon:FlxSprite;

	public function new()
	{
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 30, FlxColor.fromString("#352E2C"));
		background.drawRect(0, 29, FlxG.width, 1, FlxColor.WHITE);
		dayCounter = new FlxText(FlxG.width - 80, 2, 0, "Day 1", 16);
		moneyCounter = new FlxText(2, 2, 0, "$ 0", 16);
		moneyCounter.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
		dayCounter.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);

		add(background);
		add(dayCounter);
		add(moneyCounter);

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	public function updateHUD(day:Int, money:Int)
	{
		dayCounter.text = "Day " + day;
		moneyCounter.text = "$ " + money;
	}
}
