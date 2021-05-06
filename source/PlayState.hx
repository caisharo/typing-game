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
	// HUD stuff
	var hud:HUD;
	var day:Int = 1;
	var money:Int = 0;

	// Customer stuff
	var displayedCustomers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var remainingCustomers:Array<Customer> = [];
	var currentCustomer:Customer;
	var maxCustomersAtOnce = 3;
	var possibleOrders:Map<String, Array<String>> = []; // maps label to array of possible choices (so we don't have to parse file every time)
	var currentCustomerText:FlxText;

	// Player input section
	var yShift = 150; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String>; // the labels for the input fields (e.g "Name", "Order")

	override public function create()
	{
		super.create();

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		// Add HUD (score + day)
		hud = new HUD();
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

		// These will need to change (maybe use values in save data??)
		// With more fields we will need more text files (with the way it is currently implemented)
		addInput(["Name", "Order"]);

		// parse files once
		for (label in labels)
		{
			var fileContent:String = Assets.getText("assets/data/" + label + ".txt");
			var lines:Array<String> = fileContent.split("\n");
			possibleOrders.set(label, lines);
		}

		setMaxCustomers(3);
		addCustomers(10);
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

		// I don't know if we need to reset everything if the player try to submit without selecting customer
		// If so, uncomment the following codes

		// if (pressedEnter && currentCustomer == null)
		// {
		// 	trace("enter");
		// 	resetFields();
		// }

		if (pressedEnter && currentCustomer != null)
		{
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
			if (remainingCustomers.length > 0)
			{
				Timer.delay(replaceCustomer.bind(currentCustomer.getPosition()), 1500);
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
				}
				var customer:Customer = displayedCustomers.get(key);
				customer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				customer.showScore("-5", FlxColor.RED);
				customer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 1500);
				Timer.delay(remove.bind(customer), 1500);
				displayedCustomers.remove(key);

				currentCustomer = null;
				currentCustomerText.text = "Current customer: ";
				resetFields();

				// replace customer?
				if (remainingCustomers.length > 0)
				{
					Timer.delay(replaceCustomer.bind(key), 1500);
				}
			}
		}

		super.update(elapsed);
	}

	public function setMaxCustomers(maxCustomersAtOnce:Int)
	{
		this.maxCustomersAtOnce = maxCustomersAtOnce;
	}

	public function addCustomers(numberOfCustomers:Int)
	{
		// Add customers

		// total # of customers on level - need to figure out a way to only show X at a time
		for (i in 0...numberOfCustomers)
		{
			var position = i + 1;
			var order:Array<String> = [];
			var random = new FlxRandom();
			var patience = 10 + random.float() * 100 / 2;
			if (position <= maxCustomersAtOnce && displayedCustomers.get(position) == null)
			{
				// no customer in position yet - add
				for (label in labels)
				{
					// assumes text files are named based on label - will probably need to adjust later
					order.push(random.getObject(possibleOrders.get(label)));
				}
				// actual customer patience timer length still to be decided
				var customer = new Customer(position, order, patience);
				displayedCustomers.set(position, customer);
				add(customer);
				customer.startTimer();
				customer.showText(5000, 0);
				trace("test: " + customer.getOrder());
			}
			else
			{
				// hidden customers - need to remember to add and start timer later
				// temp position - won't know until player clears a spot
				var order:Array<String> = [];
				for (label in labels)
				{
					// assumes text files are named based on label - will probably need to adjust later
					order.push(random.getObject(possibleOrders.get(label)));
				}
				var customer = new Customer(position, order, patience);
				remainingCustomers.push(customer);
			}
		}
	}

	public function addInput(labels:Array<String>)
	{
		// Add player input section
		this.labels = labels;

		fields = new FlxTypedGroup<FlxUIInputText>();
		currentField = 0;
		for (label in labels)
		{
			addInputField(label);
		}
	}

	function addInputField(label:String = "Name")
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
		newCustomer.setPosition(position);
		displayedCustomers.set(position, newCustomer);
		add(newCustomer);
		newCustomer.startTimer();
	}
}
