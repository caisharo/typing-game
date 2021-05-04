package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Customer extends FlxTypedGroup<FlxSprite>
{
	var patience:FlxTimer;
	var patienceBar:FlxBar;
	var customer:FlxSprite;
	var textbox:FlxText;
	var customerPosition:FlxText;
	var score:FlxText;

	var index:Int;
	var time:Float;
	var order:Array<String>;

	public var hasPatience:Bool = true;

	public function new(index:Int, x:Float, order:Array<String>, time:Float)
	{
		super();
		customer = new FlxSprite(x - 40, 170, AssetPaths.customer__png);
		customer.scale.set(0.7, 0.7);
		add(customer);
		var text:String = "";
		for (part in order)
		{
			text += "\n" + part;
		}
		textbox = new FlxText(x, 120, 200, text, 16);
		add(textbox);
		customerPosition = new FlxText(x, 220, 0, Std.string(index), 25);
		add(customerPosition);
		patience = new FlxTimer();
		patienceBar = new FlxBar(x, 200, LEFT_TO_RIGHT, 100, 10, patience, "timeLeft", 0, time);
		add(patienceBar);
		this.index = index;
		this.order = order;
		this.time = time;
		this.order = order;
	}

	public function setPosition(position:Int)
	{
		this.index = position;
		customerPosition.text = Std.string(index);
	}

	public function getPosition()
	{
		return this.index;
	}

	public function startTimer()
	{
		patience.start(time, deleteBar, 1);
	}

	public function getOrder()
	{
		return order;
	}

	public function changeNumColor(color:FlxColor)
	{
		customerPosition.color = color;
	}

	public function changeSprite(image:FlxGraphicAsset)
	{
		customer.loadGraphic(image);
	}

	public function stopPatienceBar()
	{
		patienceBar.parent = null;
		patienceBar.value = patience.timeLeft;
	}

	public function fadeAway()
	{
		FlxTween.tween(customer, {alpha: 0}, 1.5);
		FlxTween.tween(patienceBar, {alpha: 0}, 1.5);
		FlxTween.tween(textbox, {alpha: 0}, 1.5);
		FlxTween.tween(customerPosition, {alpha: 0}, 1.5);
	}

	public function showScore(string:String, color:FlxColor)
	{
		score = new FlxText(customer.x, customer.y, 0, string, 30);
		score.color = color;
		add(score);
		FlxTween.tween(score, {x: 10, y: 10}, 1.5);
	}

	// function so that bar gets properly deleted when time runs out (killOnEmpty doesn't seem to work)
	function deleteBar(timer:FlxTimer):Void
	{
		if (patienceBar.parent != null)
		{
			hasPatience = false;
			patienceBar.destroy();
		}
	}
}
