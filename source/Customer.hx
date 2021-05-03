package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

using flixel.util.FlxSpriteUtil;

class Customer extends FlxTypedGroup<FlxSprite>
{
	var patience:FlxTimer;
	var patienceBar:FlxBar;
	var customer:FlxSprite;
	var textbox:FlxText;

	var time:Float;
	var order:Array<String>;

	public function new(x:Float, name:String, order:Array<String>, time:Float)
	{
		super();
		customer = new FlxSprite(x - 40, 170, AssetPaths.customer__png);
		customer.scale.set(0.7, 0.7);
		add(customer);
		var text:String = name;
		for (part in order)
		{
			text += "\n" + part;
		}
		textbox = new FlxText(x, 120, 200, text, 16);
		add(textbox);
		patience = new FlxTimer();
		patienceBar = new FlxBar(x, 200, LEFT_TO_RIGHT, 100, 10, patience, "timeLeft", 0, time);
		add(patienceBar);
		this.order = order;
		this.time = time;
		this.order = [name].concat(order);
	}

	public function startTimer()
	{
		patience.start(time, deleteBar, 1);
	}

	public function getOrder()
	{
		return order;
	}

	function deleteBar(timer:FlxTimer):Void
	{
		patienceBar.destroy();
	}
}
