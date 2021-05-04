package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

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
	var selectText = new FlxText(0, 0, 0, "PRESS NUMBER KEY TO SELECT CUSTOMER", 15);
	var typeText = new FlxText(0, 0, 0, "TYPE NAME AND ORDER ABOVE THE CUSTOMER CORRECTLY", 15);
	var typeText_2 = new FlxText(0, 0, 0, "PRESS TAB OR SHIFT TO CHANGE TEXT FIELD", 15);
	var patienceText = new FlxText(0, 0, 0, "HURRY UP! DON'T LET THE GREEN BAR RUN OUT!", 15);
	var submitText = new FlxText(0, 0, 0, "AFTER FINISHED, PRESS ENTER TO SUBMIT", 15);
	var completeText = new FlxText(0, 0, 0, "NOW COMPLETE THE REST OF THE TUTORIAL", 15);
	var finishText = new FlxText(0, 0, 0, "NOW YOU FINISHED THE TUTORIAL, GOOD JOB!", 15);

	// var wellDone = new FlxText(0, 0, 0, "WELL DONE", 15);
	var phase = 1;

	override public function create()
	{
		super.create();

		// FlxG.mouse.visible = false;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		// Add HUD (score + day)
		hud = new HUD();
		add(hud);

		fields = new FlxTypedGroup<FlxUIInputText>();
		currentField = 0;
		for (label in labels)
		{
			addInputField(label);
		}

		// Add customers
		addCustomers();

		showText(selectText);
	}

	private function showText(text:FlxText, offset:Int = 80)
	{
		text.screenCenter();
		text.y += yShift + offset;
		add(text);
		// FlxFlicker.flicker(text, 0, .9);
	}

	private function addCustomers()
	{
		var customer:Customer = new Customer(1, 50, "alice", ["black"], 20);
		customers.set(1, customer);
		left++;
		add(customer);
		customer.startTimer();
		var customer2 = new Customer(2, 200, "bob", ["latte"], 30);
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

			resetFields();

			// TODO: Still need to handle customer satisfaction + points
			// Example image change:
			// customer.loadGraphic(AssetPaths.angry_customer__png);
			remove(currentCustomer);
			if (left == 1)
			{
				left = 0;
				if (phase == 4)
				{
					remove(completeText);
					haxe.Timer.delay(showText.bind(finishText), 500);
				}
				haxe.Timer.delay(FlxG.switchState.bind(new MenuState()), 3000);
			}
			else
			{
				left--;
				currentCustomer = null;
			}
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

		if (phase == 1 && (pressedOne || pressedTwo || pressedThree || pressedFour || pressedFive))
		{
			remove(selectText);
			haxe.Timer.delay(showText.bind(typeText), 800);
			haxe.Timer.delay(showText.bind(typeText_2, 110), 800);
			phase++;
		}

		if (phase == 2 && (pressedShift || pressedTab))
		{
			remove(typeText);
			remove(typeText_2);
			haxe.Timer.delay(showText.bind(patienceText), 800);
			haxe.Timer.delay(showText.bind(submitText, 110), 800);
			phase++;
		}

		if (phase == 3 && pressedEnter)
		{
			remove(submitText);
			remove(patienceText);
			haxe.Timer.delay(showText.bind(completeText), 800);
			phase++;
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
			item.text = " "; // makeshift solution for now - does "remove" the text but weird spacing
			item.caretIndex = 0;
			item.hasFocus = false;
			item.backgroundColor = FlxColor.WHITE;
		});
		fields.getFirstExisting().hasFocus = true;
		fields.getFirstExisting().backgroundColor = FlxColor.YELLOW;
	}
}
