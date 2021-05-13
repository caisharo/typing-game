package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class ShopConfirmSubState extends BasicMenuSubState
{
	public static var itemName = "Item";
	public static var itemPrice = 0;

	override public function create()
	{
		super.create();

		var mainText = new FlxText(0, 0, 0, "Are you sure you want to buy " + itemName + " for $" + itemPrice + "?", 30);
		mainText.setFormat("assets/fonts/Kaorigelbold.ttf", 30);
		mainText.screenCenter();
		mainText.y += 230;
		add(mainText);

		yShift = 615;
		yGap = 35;
		fontSize = 30;
		menuItems = new FlxTypedGroup<FlxText>();
		addMenuItem("Yes", pressYes);
		addMenuItem("No", pressNo);

		changeSelected(1); // make "no" default so player doesn't accidentally buy
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function pressYes()
	{
		if (Main.isDebugging)
		{
			trace("yes");
		}

		var totalOwned = FlxG.save.data.itemsOwned.get(itemName) + 1;
		if (Main.isLogging)
		{
			Main.logger.logActionWithNoLevel(LoggingActions.BOUGHT_ITEM, {
				previous_balance: ShopState.money,
				item_name: itemName,
				item_price: itemPrice,
				total_owned: totalOwned
			});
		}

		// Deduct cost from player (and save)
		ShopState.money -= itemPrice;
		ShopState.hud.updateHUD(0, ShopState.money); // Update money in shop HUD
		FlxG.save.data.playerMoney = ShopState.money;

		// Increase # owned (and save)
		FlxG.save.data.itemsOwned.set(itemName, totalOwned);
		ShopState.updateOwned();

		// Add and save effects (PlayState will use saved values)
		// Hardcoded - will have to change everytime we modify items :(
		if (itemName == "Marvelous Milk")
		{
			if (FlxG.save.data.satisfiedCustomerIncrease == null)
			{
				FlxG.save.data.satisfiedCustomerIncrease = 1;
			}
			else
			{
				FlxG.save.data.satisfiedCustomerIncrease += 1;
			}
		}
		else if (itemName == "Better Beans")
		{
			if (FlxG.save.data.happyCustomerIncrease == null)
			{
				FlxG.save.data.happyCustomerIncrease = 1;
			}
			else
			{
				FlxG.save.data.happyCustomerIncrease += 1;
			}
		}
		else if (itemName == "Comfy Chair")
		{
			if (FlxG.save.data.basePatienceIncrease == null)
			{
				FlxG.save.data.basePatienceIncrease = 1;
			}
			else
			{
				FlxG.save.data.basePatienceIncrease += 1;
			}
		}
		else if (itemName == "Soft Sofa")
		{
			if (FlxG.save.data.basePatienceIncrease == null)
			{
				FlxG.save.data.basePatienceIncrease = 10;
			}
			else
			{
				FlxG.save.data.basePatienceIncrease += 10;
			}
		}

		// Save everything
		FlxG.save.flush();

		close();
	}

	function pressNo()
	{
		if (Main.isDebugging)
		{
			trace("no");
		}

		close();
	}
}
