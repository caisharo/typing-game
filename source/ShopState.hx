package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Timer;

class ShopState extends FlxState
{
	// Lets ShopConfirmSubState modify
	public static var hud:HUD;
	public static var money = 0;

	// Need to let ShopConfirmSubState update # owned
	// Items owned is stored as saved data FlxG.save.data.itemsOwned (map of name => # owned)
	public static var shopItems:FlxTypedGroup<FlxTypedGroup<FlxText>>;
	public static var currentItem = 0;

	var itemNames:Array<String> = [];
	var itemPrices:Array<Int> = [];
	var priceIncreases:Array<Int> = [];
	var maxNumItems:Array<Int> = [];
	var yGap = 50; // gap between items

	var selectedTextFormat = new FlxTextFormat(FlxColor.WHITE, false, false);
	var unselectedTextFormat = new FlxTextFormat(FlxColor.GRAY, false, false);

	override public function create()
	{
		// Get player money to set up HUD
		if (FlxG.save.data.playerMoney != null)
		{
			money = FlxG.save.data.playerMoney;
		}
		else
		{
			money = 0;
		}

		// Create empty map for save data if it doesn't already exist
		if (FlxG.save.data.itemsOwned == null)
		{
			FlxG.save.data.itemsOwned = new Map<String, Int>();
			FlxG.save.flush();
		}

		currentItem = 0;

		hud = new HUD(false);
		hud.updateHUD(0, money);
		add(hud);

		var mainText = new FlxText(0, 0, 0, "SHOP", 64);
		mainText.setFormat("assets/fonts/Kaorigelbold.ttf", 70);
		mainText.screenCenter();
		mainText.y -= 200;
		add(mainText);

		var returnText = new FlxText(810, 50, 0, "Note: Press ESC to return to the main menu.", 20);
		returnText.setFormat("assets/fonts/Kaorigelbold.ttf", 20);
		returnText.addFormat(unselectedTextFormat);
		add(returnText);

		// Set up headers
		var y = 250;
		var itemHeader = new FlxText(100, y, 240, "Name", 20);
		var descriptionHeader = new FlxText(360, y, 440, "Description", 20);
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

		// Add shop items
		shopItems = new FlxTypedGroup<FlxTypedGroup<FlxText>>();
		addItem("Soothing Syrup", "Lose $1 less from angry customers.", 25, 10, 4); // item cap of 4 so player can only go up to -1
		addItem("Marvelous Milk", "Earn $1 more from satisfied customers.", 25, 10);
		addItem("Better Beans", "Earn $1 more from happy customers.", 25, 10);
		addItem("Comfy Chair", "Increase customer base patience by a bit.", 20, 10);
		addItem("Soft Sofa", "Increase customer base patience by a lot.", 100, 50);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		var pressedPrevious = FlxG.keys.justPressed.UP
			|| FlxG.keys.justPressed.W
			|| (FlxG.keys.justPressed.TAB && FlxG.keys.pressed.SHIFT);
		var pressedNext = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S || FlxG.keys.justPressed.TAB;
		if (pressedPrevious)
		{
			// Go to previous input field
			FlxG.sound.play(AssetPaths.menuSwitch__wav);
			changeSelected(-1);
		}
		else if (pressedNext)
		{
			// Go to next input field
			FlxG.sound.play(AssetPaths.menuSwitch__wav);
			changeSelected(1);
		}

		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedEnter)
		{
			var currentNumOwned = FlxG.save.data.itemsOwned.get(itemNames[currentItem]);
			if (money < itemPrices[currentItem])
			{
				// check if player has enough money
				var notEnoughMoneyText = new FlxText(0, 0, 0, "You don't have enough money!", 18);
				notEnoughMoneyText.setFormat("assets/fonts/Kaorigelbold.ttf", 23);
				notEnoughMoneyText.screenCenter();
				notEnoughMoneyText.y += 250;
				notEnoughMoneyText.color = FlxColor.RED;
				add(notEnoughMoneyText);
				Timer.delay(remove.bind(notEnoughMoneyText), 1000);
			}
			else if (maxNumItems[currentItem] > 0 && currentNumOwned >= maxNumItems[currentItem])
			{
				// check if player can buy more of the item
				var alertText = new FlxText(0, 0, 0, "You can't buy any more of this item!", 18);
				alertText.setFormat("assets/fonts/Kaorigelbold.ttf", 23);
				alertText.screenCenter();
				alertText.y += 250;
				alertText.color = FlxColor.RED;
				add(alertText);
				Timer.delay(remove.bind(alertText), 1000);
			}
			else
			{
				// pop up confirmation message
				var actualPrice = itemPrices[currentItem] + (priceIncreases[currentItem] * currentNumOwned);
				ShopConfirmSubState.itemName = itemNames[currentItem];
				ShopConfirmSubState.itemPrice = actualPrice;
				ShopConfirmSubState.itemPriceIncrease = priceIncreases[currentItem];
				openSubState(new ShopConfirmSubState());
			}
		}

		var pressedEscape = FlxG.keys.justPressed.ESCAPE;
		if (pressedEscape)
		{
			if (Main.isLogging)
			{
				Main.logger.logActionWithNoLevel(LoggingActions.PRESS_RETURN_TO_MENU, {pressed: "menu", from: "shop"});
			}
			FlxG.switchState(new MenuState());
		}

		super.update(elapsed);
	}

	public static function updateOwned(priceIncrease:Int)
	{
		shopItems.forEach(function(itemGroup:FlxTypedGroup<FlxText>)
		{
			if (itemGroup.ID == currentItem)
			{
				itemGroup.forEach(function(item:FlxText)
				{
					if (item.ID == 2)
					{
						// Change price and text
						item.text = "$" + (Std.parseInt(item.text.substring(1, item.text.length)) + priceIncrease);
					}
					else if (item.ID == 3)
					{
						// Change # owned text
						item.text = "" + (Std.parseInt(item.text) + 1);
					}
				});
			}
		});
	}

	function addItem(name:String = "Item", description:String = "An item...", price:Int = 0, priceIncrease = 0, maxNumber = 0)
	{
		// could probably add item images later?

		// Get number owned from saved data (if saved)
		var numOwned = 0;
		if (FlxG.save.data.itemsOwned.get(name) != null)
		{
			numOwned = FlxG.save.data.itemsOwned.get(name);
		}
		else
		{
			// If no save data for item, add it
			FlxG.save.data.itemsOwned.set(name, 0);
			FlxG.save.flush();
		}
		var actualPrice = price + (numOwned * priceIncrease);

		var newItem = new FlxTypedGroup<FlxText>();
		newItem.ID = shopItems.length;
		var y = 300 + (yGap * shopItems.length);
		var newItemName = new FlxText(100, y, 250, name, 20);
		var newItemDescription = new FlxText(360, y, 490, description, 20);
		var newItemPrice = new FlxText(880, y, 140, "$" + actualPrice, 20);
		var newItemOwned = new FlxText(1040, y, 140, "" + numOwned, 20);
		newItemName.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemDescription.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemPrice.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemOwned.setFormat("assets/fonts/Kaorigel.ttf", 25);
		newItemName.ID = 0;
		newItemDescription.ID = 1;
		newItemPrice.ID = 2;
		newItemOwned.ID = 3; // setting IDs so we can change text easier later
		newItem.add(newItemName);
		newItem.add(newItemDescription);
		newItem.add(newItemPrice);
		newItem.add(newItemOwned);

		// Add to arrays
		itemNames.push(name);
		itemPrices.push(price);
		priceIncreases.push(priceIncrease);
		maxNumItems.push(maxNumber);

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
			formatAllText(itemGroup, unselectedTextFormat);
			if (itemGroup.ID == currentItem)
			{
				formatAllText(itemGroup, selectedTextFormat);
			}
		});
	}

	function formatAllText(textGroup:FlxTypedGroup<FlxText>, format:FlxTextFormat)
	{
		textGroup.forEach(function(item:FlxText)
		{
			item.clearFormats();
			item.addFormat(format);
		});
	}
}
