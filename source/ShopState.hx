package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ShopState extends FlxState
{
	var hud:HUD;
	var money = 0;

	var shopItems:FlxTypedGroup<FlxTypedGroup<FlxText>>;
	var numOwned:Array<Int> = [];
	var shopPrices:Array<Int> = [];
	var currentItem = 0;
	var yGap = 75; // gap between items

	var selectedTextFormat = new FlxTextFormat(FlxColor.WHITE, true, false, FlxColor.BLACK);
	var unselectedTextFormat = new FlxTextFormat(FlxColor.GRAY, false, false);

	override public function create()
	{
		if (FlxG.save.data.playerMoney != null)
		{
			money = FlxG.save.data.playerMoney;
		}
		hud = new HUD(false);
		hud.updateHUD(0, money);
		add(hud);

		var mainText = new FlxText(0, 0, 0, "SHOP", 64);
		mainText.setFormat("assets/fonts/Kaorigelbold.ttf", 70);
		mainText.screenCenter();
		mainText.y -= 200;
		add(mainText);

		var y = 250;
		var itemHeader = new FlxText(100, y, 250, "Name", 20);
		var descriptionHeader = new FlxText(370, y, 440, "Description", 20);
		var priceHeader = new FlxText(880, y, 140, "Price", 20);
		var ownedHeader = new FlxText(1040, y, 140, "# Owned", 20);
		itemHeader.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		descriptionHeader.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		priceHeader.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		ownedHeader.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		add(itemHeader);
		add(descriptionHeader);
		add(priceHeader);
		add(ownedHeader);

		shopItems = new FlxTypedGroup<FlxTypedGroup<FlxText>>();
		addItem("Marvelous Milk", "Satisfied customers will now tip $2 extra.", 20);
		addItem("Better Beans", "Happy customers will now tip $3 extra.", 50);
		addItem("Comfy Chair", "Increases customer's base patience by 1.", 60);
		addItem("Soft Sofa", "Increases customer's base patience by 10.", 500);
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
			// Deduct cost from player (and save)
			// Increase # owned
			// Apply effects to PlayState (and save)
		}

		super.update(elapsed);
	}

	function addItem(name:String = "Item", description:String = "An item...", price:Int = 0)
	{
		// could probably add item images later
		var newItem = new FlxTypedGroup<FlxText>();
		newItem.ID = shopItems.length;
		var y = 300 + (yGap * shopItems.length);
		var newItemName = new FlxText(100, y, 250, name, 20);
		var newItemDescription = new FlxText(370, y, 440, description, 20);
		var newItemPrice = new FlxText(880, y, 140, "$" + price, 20);
		var newItemOwned = new FlxText(1040, y, 140, "0", 20);
		newItemName.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemDescription.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemPrice.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemOwned.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItem.add(newItemName);
		newItem.add(newItemDescription);
		newItem.add(newItemPrice);
		newItem.add(newItemOwned);

		shopPrices.push(price);

		if (shopItems.length == 0)
		{
			formatAllText(newItem, selectedTextFormat);
		}
		else
		{
			formatAllText(newItem, unselectedTextFormat);
		}
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
