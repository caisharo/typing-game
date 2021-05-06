package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Timer;
import lime.utils.Assets;

class PlayState extends FlxState
{
	// public static variables - so we can set to different values for different "levels"
	public static var day = 1;
	public static var money = 0;
	public static var maxCustomersAtOnce = 3;
	public static var totalCustomers = 5;
	public static var labels:Array<String> = ["Name", "Order"]; // the labels for the input fields
	public static var colors:Array<String> = ["#C8D8FA", "#FFE7DA"]; // colors for input fields

	// HUD
	var hud:HUD;

	// Customer stuff
	var displayedCustomers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var remainingCustomers:Array<Customer> = [];
	var currentCustomer:Customer;
	var possibleOrders:Map<String, Array<String>> = []; // maps label to array of possible choices (so we don't have to parse file every time)
	var currentCustomerText:FlxText;

	// Player input section
	var yShift = 150; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;

	// the following implementation might be changed when more fields are added
	// but temporarily used for now
	// the range of possible names being selected, scaled to 0-1
	// the value need to checked, otherwise an error may come up
	var range:Map<String, Array<Float>> = [];

	override public function create()
	{
		super.create();

		if (FlxG.save.data.dayCompleted != null)
		{
			trace("last day completed: " + FlxG.save.data.dayCompleted);
		}

		if (FlxG.save.data.playerMoney != null)
		{
			trace("last saved player money: " + FlxG.save.data.playerMoney);
		}

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		setRange();

		// Add HUD (score + day)
		hud = new HUD();
		hud.updateHUD(day, money);
		add(hud);

		var text = "Current customer: ";
		if (currentCustomer != null)
		{
			text += currentCustomer.getPosition();
		}
		currentCustomerText = new FlxText(0, 0, 0, text, 18);
		currentCustomerText.screenCenter();
		currentCustomerText.y += 160;
		currentCustomerText.x -= 300;
		add(currentCustomerText);

		// parse files once
		for (label in labels)
		{
			// assumes files are named base on label (matching case too) - might need to change
			var fileContent:String = Assets.getText("assets/data/" + label + ".txt");
			var lines:Array<String> = fileContent.split("\n");
			possibleOrders.set(label, lines);
		}

		addInput();
		addCustomers(totalCustomers);
	}

	private function setRange()
	{
		var nameRange:Array<Float> = [0, 1];
		var orderRange:Array<Float> = [0, 0.5];

		range.set("Name", nameRange);
		range.set("Order", orderRange);
	}

	override public function update(elapsed:Float)
	{
		// Player typing input
		var pressedTab = FlxG.keys.justPressed.TAB;
		var pressedShift = FlxG.keys.justPressed.SHIFT;
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedTab)
		{
			// Go to next input field
			trace("tab");
			changeSelected(1);
		}
		if (pressedShift)
		{
			// Go to previous input field
			trace("shift");
			changeSelected(-1);
		}

		if (pressedEnter && currentCustomer != null)
		{
			var currentPosition = currentCustomer.getPosition();
			trace("enter");
			var customerOrder:Array<String> = currentCustomer.getOrder();
			var matches:Int = 0;
			// Go through each input field to validate matches
			fields.forEach(function(item:FlxUIInputText)
			{
				trace(labels[item.ID] + ": " + item.text);
				if (StringTools.trim(item.text) == customerOrder[item.ID].toLowerCase())
				{
					trace(labels[item.ID] + " matches");
					matches++;
				}
			});

			// currently doing this for matches: 100% = happy, 50%+ = satsified, <50% = angry
			// we could do something more intense like how correct each match is (# of characters??) but that's more complex, esp if we have long strings
			var score = matches / labels.length;
			trace("matches score: " + score);
			if (score == 1)
			{
				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.happy_customer__png);
				money += 10;
				currentCustomer.showScore("+10", FlxColor.GREEN);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 1500);
				Timer.delay(remove.bind(currentCustomer), 1500);
			}
			else if (score >= 0.5)
			{
				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.satisfied_customer__png);
				money += 5;
				currentCustomer.showScore("+5", FlxColor.YELLOW);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 1500);
				Timer.delay(remove.bind(currentCustomer), 1500);
			}
			else
			{
				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				currentCustomer.showScore("-5", FlxColor.RED);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 1500);
				Timer.delay(remove.bind(currentCustomer), 1500);
			}

			// Reset fields doesn't work 100% properly
			resetFields();

			// Replace customer?
			displayedCustomers.remove(currentPosition);
			if (remainingCustomers.length > 0)
			{
				Timer.delay(replaceCustomer.bind(currentPosition), 1500);
			}
			else if (!displayedCustomers.keys().hasNext())
			{
				// no more customers - end of day
				trace("end day");
				endDay();
			}

			currentCustomer = null;
			currentCustomerText.text = "Current customer: ";
		}

		// Enable spaces in input
		var pressedSpace = FlxG.keys.justPressed.SPACE;
		if (pressedSpace && currentField >= 0)
		{
			fields.forEach(function(item:FlxUIInputText)
			{
				if (item.ID == currentField)
				{
					item.text += " ";
					item.caretIndex++;
				}
			});
		}

		// Backspace workaround/"fix" for now - looks a bit weird/inconsistent with extra space sometimes in the beginning
		var pressedBackspace = FlxG.keys.justPressed.BACKSPACE;
		if (pressedBackspace && currentField >= 0)
		{
			fields.forEach(function(item:FlxUIInputText)
			{
				if (item.ID == currentField && item.text == "")
				{
					item.text = " ";
					item.caretIndex = 0;
				}
			});
		}

		// Customer selection
		var pressedOne = FlxG.keys.justPressed.ONE;
		var pressedTwo = FlxG.keys.justPressed.TWO;
		var pressedThree = FlxG.keys.justPressed.THREE;
		var pressedFour = FlxG.keys.justPressed.FOUR;
		var pressedFive = FlxG.keys.justPressed.FIVE;
		// Will we have more than 5 at a time?

		if (pressedOne && maxCustomersAtOnce >= 1)
		{
			trace("customer 1 selected");
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			currentCustomer = displayedCustomers.get(1);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 1";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
				currentCustomer.showText(3000, 3);
			}
		}
		if (pressedTwo && maxCustomersAtOnce >= 2)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 2 selected");
			currentCustomer = displayedCustomers.get(2);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 2";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
				currentCustomer.showText(3000, 3);
			}
		}
		if (pressedThree && maxCustomersAtOnce >= 3)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 3 selected");
			currentCustomer = displayedCustomers.get(3);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 3";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
				currentCustomer.showText(3000, 3);
			}
		}
		if (pressedFour && maxCustomersAtOnce >= 4)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 4 selected");
			currentCustomer = displayedCustomers.get(4);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 4";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
				currentCustomer.showText(3000, 3);
			}
		}
		if (pressedFive && maxCustomersAtOnce >= 5)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 5 selected");
			currentCustomer = displayedCustomers.get(5);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 5";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
				currentCustomer.showText(3000, 3);
			}
		}

		// check if a customer has run out of patience
		for (key in displayedCustomers.keys())
		{
			if (!displayedCustomers.get(key).hasPatience)
			{
				if (currentCustomer == displayedCustomers.get(key))
				{
					currentCustomer = null;
					currentCustomerText.text = "Current customer: ";
				}
				var customer:Customer = displayedCustomers.get(key);
				customer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				customer.showScore("-5", FlxColor.RED);
				customer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 1500);
				Timer.delay(remove.bind(customer), 1500);
				displayedCustomers.remove(key);

				// replace customer?
				if (remainingCustomers.length > 0)
				{
					Timer.delay(replaceCustomer.bind(key), 1500);
				}
				else if (!displayedCustomers.keys().hasNext())
				{
					// no more customers - end of day
					endDay();
				}
			}
		}

		super.update(elapsed);
	}

	function randomChoose(random:FlxRandom, label:String)
	{
		var choices = possibleOrders.get(label);
		var size = choices.length;
		var start = Math.floor(size * range.get(label)[0]);
		var end = Math.floor(size * range.get(label)[1] - 0.1);

		var index = random.int(start, end);
		return choices[index];
	}

	function addCustomers(numberOfCustomers:Int)
	{
		// total # of customers on level - only show maxCustomersAtOnce at a time
		for (i in 0...numberOfCustomers)
		{
			var position = i + 1;
			var order:Array<String> = [];
			var random = new FlxRandom();
			var patience = 15 + random.float() * 80 / 2;
			if (position <= maxCustomersAtOnce && displayedCustomers.get(position) == null)
			{
				// no customer in position yet - add
				for (label in labels)
				{
					// assumes text files are named based on label - will probably need to adjust later
					order.push(randomChoose(random, label));
				}
				// actual customer patience timer length still to be decided
				var customer = new Customer(position, order, patience);
				displayedCustomers.set(position, customer);
				add(customer);
				customer.startTimer();
				customer.showText(5000, 0);
			}
			else
			{
				// hidden customers - need to remember to add and start timer later
				// temp position - won't know until player clears a spot
				var order:Array<String> = [];
				for (label in labels)
				{
					// assumes text files are named based on label - will probably need to adjust later
					order.push(randomChoose(random, label));
				}
				var customer = new Customer(position, order, patience);
				remainingCustomers.push(customer);
			}
		}
	}

	function addInput()
	{
		// Add player input section
		fields = new FlxTypedGroup<FlxUIInputText>();
		currentField = 0;
		for (label in labels)
		{
			addInputField(label, colors[labels.indexOf(label)]);
		}
	}

	function addInputField(label:String = "Name", color:String)
	{
		var newField = new FlxUIInputText(0, 0, 200, "", 15);
		newField.filterMode = FlxInputText.ONLY_ALPHA;
		newField.forceCase = FlxInputText.LOWER_CASE;
		newField.ID = fields.length;
		newField.screenCenter();
		newField.x += 35;
		newField.y += yShift + (25 * fields.length);

		var fieldLabel = new FlxText(0, 0, 0, label, 15);
		fieldLabel.screenCenter();
		fieldLabel.x = newField.x - 75;
		fieldLabel.y += yShift + (25 * fields.length);
		fieldLabel.color = FlxColor.fromString(color);
		add(fieldLabel);

		if (fields.length == 0)
		{
			newField.hasFocus = true;
			newField.backgroundColor = FlxColor.YELLOW;
		}

		fields.add(newField);
		add(newField);
	}

	function changeSelected(direction:Int = 0)
	{
		currentField += direction;
		if (currentField >= fields.length)
		{
			currentField = 0;
		}
		else if (currentField < 0)
		{
			currentField = fields.length - 1;
		}

		fields.forEach(function(item:FlxUIInputText)
		{
			if (item.ID == currentField)
			{
				item.hasFocus = true;
				item.backgroundColor = FlxColor.YELLOW;
				trace(item.ID + " is focused");
			}
			else
			{
				item.hasFocus = false;
				item.backgroundColor = FlxColor.WHITE;
			}
		});
	}

	function resetFields()
	{
		fields.forEach(function(item:FlxUIInputText)
		{
			item.text = " "; // makeshift solution for now - does "remove" the text but weird spacing
			item.caretIndex = 0;
			item.hasFocus = false;
			item.backgroundColor = FlxColor.WHITE;
		});
		fields.getFirstExisting().hasFocus = true;
		fields.getFirstExisting().backgroundColor = FlxColor.YELLOW;
		currentField = 0;
	}

	function replaceCustomer(position:Int)
	{
		remove(displayedCustomers.get(position));
		var newCustomer:Customer = remainingCustomers.shift();
		if (newCustomer != null)
		{
			newCustomer.setPosition(position);
			displayedCustomers.set(position, newCustomer);
			add(newCustomer);
			newCustomer.startTimer();
		}
	}

	function endDay()
	{
		DayEndState.day = day;
		DayEndState.money = money;
		Timer.delay(FlxG.switchState.bind(new DayEndState()), 3000);
	}
}
