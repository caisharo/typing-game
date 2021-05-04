package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import js.lib.Set;

class TutorialState extends FlxState
{
	var hud:HUD;
	var day:Int;
	var money:Int;
	var customers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var currentCustomer:Customer;
	var left = 0;

	// Player input section
	var yShift = 150; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = ["Name", "Order"];
	var submitText:FlxText;

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

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
		addCustomers();
	}

	private function addCustomers()
	{
		var customer:Customer = new Customer(1, 50, "name", ["order"], 10);
		customers.set(1, customer);
		left++;
		add(customer);
		customer.startTimer();
		var customer2 = new Customer(2, 200, "bob", ["latte"], 20);
		customers.set(2, customer2);
		left++;
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
			// Go through each input field to validate matches
			fields.forEach(function(item:FlxUIInputText)
			{
				trace(labels[item.ID] + ": " + item.text);
				if (StringTools.trim(item.text) == customerOrder[item.ID])
				{
					trace(labels[item.ID] + " matches");
					// maybe do some sort of counter to calculate % of matches? (e.g. 100% = happy, 50%+ = satsified, <50% = angry)
					// we could do something more intense like how correct each match is (# of characters??) but that's more complex, esp if we have long strings
				}
			});

			// Reset fields doesn't work properly
			resetFields();
			remove(currentCustomer);
			if (left == 1)
			{
				left = 0;
				FlxG.switchState(new MenuState());
			}
			else
			{
				left--;
			}

			// TODO: Still need to handle customer satisfaction + points
			// Example image change:
			// customer.loadGraphic(AssetPaths.angry_customer__png);
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

		// Backspace "fix" - looks a bit weird/inconsistent with extra space sometimes in the beginning
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
		if (pressedOne)
		{
			trace("customer 1 selected");
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			currentCustomer = customers.get(1);
			currentCustomer.changeNumColor(FlxColor.YELLOW);
		}
		if (pressedTwo)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 2 selected");
			currentCustomer = customers.get(2);
			currentCustomer.changeNumColor(FlxColor.YELLOW);
		}
		if (pressedThree)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 3 selected");
			currentCustomer = customers.get(3);
			currentCustomer.changeNumColor(FlxColor.YELLOW);
		}
		if (pressedFour)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 4 selected");
			currentCustomer = customers.get(4);
			currentCustomer.changeNumColor(FlxColor.YELLOW);
		}
		if (pressedFive)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			trace("customer 5 selected");
			currentCustomer = customers.get(5);
			currentCustomer.changeNumColor(FlxColor.YELLOW);
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

	function resetFields()
	{
		fields.forEach(function(item:FlxUIInputText)
		{
			// DOES NOT PROPERLY UPDATE VISUALLY
			item.text = " "; // makeshift solution for now - does "remove" the text but weird spacing
			item.caretIndex = 0;
			if (item.ID == currentField)
			{
				item.hasFocus = true;
				item.backgroundColor = FlxColor.YELLOW;
			}
			else
			{
				item.hasFocus = false;
				item.backgroundColor = FlxColor.WHITE;
			}
		});
	}
}
