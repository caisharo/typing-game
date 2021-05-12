package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ShopState extends FlxState
{
	var shopItems:FlxTypedGroup<FlxTypedGroup<FlxText>>;
	var currentItem = 0;
	var yGap = 100; // gap between items

	var selectedTextFormat = new FlxTextFormat(FlxColor.WHITE, true, false, FlxColor.BLACK);
	var unselectedTextFormat = new FlxTextFormat(FlxColor.GRAY, false, false);

	override public function create()
	{
		var mainText = new FlxText(0, 0, 0, "SHOP", 64);
		mainText.screenCenter();
		mainText.y -= 200;
		add(mainText);

		shopItems = new FlxTypedGroup<FlxTypedGroup<FlxText>>();
		addItem();
		addItem("test");
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var pressedUp = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
		var pressedDown = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
		if (pressedDown && !pressedUp)
		{
			// Go to next input field
			changeSelected(1);
		}
		if (pressedUp && !pressedDown)
		{
			// Go to previous input field
			changeSelected(-1);
		}
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedEnter)
		{
			// menuFunctions[currentItem]();
		}

		super.update(elapsed);
	}

	function addItem(name:String = "Item", description:String = "An item...", price:Int = 0)
	{
		// could probably add item images later
		var newItem = new FlxTypedGroup<FlxText>();
		newItem.ID = shopItems.length;
		var y = 250 + (yGap * shopItems.length);
		var newItemName = new FlxText(100, y, 250, name, 20);
		var newItemDescription = new FlxText(420, y, 440, description, 20);
		var newItemPrice = new FlxText(880, y, 140, "" + price, 20);
		var newItemOwned = new FlxText(1040, y, 140, "0", 20);
		newItem.add(newItemName);
		newItem.add(newItemDescription);
		newItem.add(newItemPrice);
		newItem.add(newItemOwned);
		// newItem.screenCenter();
		// newItem.y = 100 + (50 * shopItems.length);

		shopItems.add(newItem);
		add(newItem);
	}

	function changeSelected(direction:Int = 0)
	{
		currentItem += direction;
		if (currentItem >= shopItems.length)
		{
			currentItem = 0;
		}
		else if (currentItem < 0)
		{
			currentItem = shopItems.length - 1;
		}

		shopItems.forEach(function(itemGroup:FlxTypedGroup<FlxText>)
		{
			if (itemGroup.ID == currentItem)
			{
				formatAllText(itemGroup, selectedTextFormat);
			}
			else
			{
				formatAllText(itemGroup, unselectedTextFormat);
			}
		});
	}

	function formatAllText(textGroup:FlxTypedGroup<FlxText>, format:FlxTextFormat)
	{
		textGroup.forEach(function(item:FlxText)
		{
			item.addFormat(format);
		});
	}
}
