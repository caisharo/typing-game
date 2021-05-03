package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var hud:HUD;
	var day:Int;
	var money:Int;
	var customers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var currentCustomer:Customer;

	// Player input section
	var yShift = 150; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = ["Name", "Order"];
	var submitText:FlxText;

	override public function create()
	{
		super.create();

		// Add HUD (score + day)
		hud = new HUD();
		add(hud);

		// Add player input section
		submitText = new FlxText(0, 0, 0, "PRESS ENTER TO COMPLETE ORDER", 15);
		submitText.screenCenter();
		submitText.y += yShift + 20;
		add(submitText);

		fields = new FlxTypedGroup<FlxUIInputText>();
		currentField = 0;
		for (label in labels)
		{
			addInputField(label);
		}

		// Add customers
		var customer:Customer = new Customer(50, "name", ["order"], 10);
		customers.set(1, customer);
		add(customer);
		customer.startTimer();
		var customer2 = new Customer(200, "bob", ["latte"], 20);
		customers.set(2, customer2);
		add(customer2);
		customer2.startTimer();
	}

	override public function update(elapsed:Float)
	{
		// Player typing input
		var pressedTab = FlxG.keys.justPressed.TAB;
		var pressedShift = FlxG.keys.justPressed.SHIFT;
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedTab)
		{
			trace("tab");
			changeSelected(1);
		}
		if (pressedShift)
		{
			trace("shift");
			changeSelected(-1);
		}
		if (pressedEnter && currentCustomer != null)
		{
			trace("enter");
			var customerOrder:Array<String> = currentCustomer.getOrder();
			fields.forEach(function(item:FlxUIInputText)
			{
				trace(labels[item.ID] + ": " + item.text);
				if (item.text == customerOrder[item.ID])
				{
					trace(labels[item.ID] + " matches");
				}
			});
		}

		// Customer selection
		var pressedOne = FlxG.keys.justPressed.ONE;
		var pressedTwo = FlxG.keys.justPressed.TWO;
		var pressedThree = FlxG.keys.justPressed.THREE;
		var pressedFour = FlxG.keys.justPressed.FOUR;
		var pressedFive = FlxG.keys.justPressed.FIVE;
		if (pressedOne)
		{
			trace("customer 1 selected");
			currentCustomer = customers.get(1);
		}
		if (pressedTwo)
		{
			trace("customer 2 selected");
			currentCustomer = customers.get(2);
		}
		if (pressedThree)
		{
			trace("customer 3 selected");
			currentCustomer = customers.get(3);
		}
		if (pressedFour)
		{
			trace("customer 4 selected");
			currentCustomer = customers.get(4);
		}
		if (pressedFive)
		{
			trace("customer 5 selected");
			currentCustomer = customers.get(5);
		}

		super.update(elapsed);
	}

	function addInputField(label:String = "Label")
	{
		var newField = new FlxUIInputText();
		newField.filterMode = FlxInputText.ONLY_ALPHA;
		newField.forceCase = FlxInputText.LOWER_CASE;
		newField.ID = fields.length;
		newField.screenCenter();
		newField.y += yShift + (20 * fields.length);

		var fieldLabel = new FlxText(0, 0, 0, label, 15);
		fieldLabel.screenCenter();
		fieldLabel.x = newField.x - 75;
		fieldLabel.y += yShift + (20 * fields.length);
		add(fieldLabel);

		if (fields.length == 0)
		{
			newField.hasFocus = true;
			newField.backgroundColor = FlxColor.YELLOW;
		}

		fields.add(newField);
		add(newField);

		submitText.y += 20;
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
}
