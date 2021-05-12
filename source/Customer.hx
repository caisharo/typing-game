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
import haxe.Timer;

using flixel.util.FlxSpriteUtil;

class Customer extends FlxTypedGroup<FlxSprite>
{
	var patience:FlxTimer;
	var patienceBar:FlxBar;
	var customer:FlxSprite;
	var nameText:FlxText;
	var orderText:FlxText;
	var customerPosition:FlxText;
	var score:FlxText;

	var position:Int;
	var time:Float;
	var order:Array<String>;
	var isTextShown:Bool = false;

	public var hasPatience:Bool = true;

	public function new(position:Int, order:Array<String>, time:Float)
	{
		super();
		var x = 50 + (position - 1) * 200;
		customer = new FlxSprite(x - 40, 170, AssetPaths.customer__png);
		customer.scale.set(0.7, 0.7);
		add(customer);
		nameText = new FlxText(x, 120, 200, order[0], 16);
		nameText.setFormat("assets/fonts/Kaorigelbold.ttf", 21);
		nameText.color = FlxColor.fromString("#C8D8FA");
		add(nameText);
		var text:String = order[1];
		for (i in 2...order.length)
		{
			text += "\n" + order[i];
		}
		orderText = new FlxText(x, 145, 200, text, 16);
		orderText.setFormat("assets/fonts/Kaorigelbold.ttf", 21);
		orderText.color = FlxColor.fromString("#FFE7DA");
		add(orderText);
		customerPosition = new FlxText(x, 220, 0, Std.string(position), 25);
		customerPosition.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		add(customerPosition);
		patience = new FlxTimer();
		patienceBar = new FlxBar(x, 200, LEFT_TO_RIGHT, Std.int(time * 1.5), 10, patience, "timeLeft", 0, time);
		add(patienceBar);
		this.position = position;
		this.order = order;
		this.time = time;
		this.order = order;
	}

	public function setPosition(position:Int)
	{
		this.position = position;
		customerPosition.text = Std.string(position);

		// Move everything to proper position
		var x = 50 + (position - 1) * 200;
		customer.x = x - 40;
		nameText.x = x;
		orderText.x = x;
		customerPosition.x = x;
		patienceBar.x = x;
	}

	public function getPosition()
	{
		return this.position;
	}

	public function startTimer(tutorial:Bool = false)
	{
		// prevent player from failing in tutorial
		if (tutorial)
		{
			patience.start(time, function(timer:FlxTimer)
			{
				patience.active = false;
			}, 1);
		}
		else
		{
			patience.start(time, deleteBar, 1);
		}
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
		FlxTween.tween(customer, {alpha: 0}, 2);
		FlxTween.tween(patienceBar, {alpha: 0}, 2);
		FlxTween.tween(nameText, {alpha: 0}, 2);
		FlxTween.tween(orderText, {alpha: 0}, 2);
		FlxTween.tween(customerPosition, {alpha: 0}, 2);
	}

	public function showScore(string:String, color:FlxColor)
	{
		score = new FlxText(customer.x, customer.y, 0, string, 30);
		score.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		score.color = color;
		add(score);
		FlxTween.tween(score, {x: 10, y: 10}, 2);
	}

	public function showText(time:Int, cost:Int, tutorial:Bool = false)
	{
		nameText.alpha = 1;
		orderText.alpha = 1;
		if (!isTextShown)
		{
			isTextShown = true;
			var timer = new FlxTimer();
			timer.start(time, hideText, 1);
			patience.start(Math.max(0, patience.timeLeft - cost), deleteBar, 1);
			// prevent player from failing in tutorial
			if (tutorial)
			{
				Timer.delay(function()
				{
					stopPatienceBar();
					patience.active = false;
				}, Std.int((patience.timeLeft - 1) * 1000));
			}
		}
	}

	function hideText(timer:FlxTimer):Void
	{
		nameText.alpha = 0;
		orderText.alpha = 0;
		isTextShown = false;
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
