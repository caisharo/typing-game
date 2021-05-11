package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.util.FlxTimer;
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
	var difficultyChangeStep = 5; // difficulty increases every # of days
	var nameRangeSize = 0.1; // the length of range of name/order considered
	var orderRangeSize = 0.1;
	// ideally *RangeSize should be greater than or equal to *IncreaseRate so as to use all potential words
	var nameIncreaseRate = 0.1; // how much the difficulty would increase in each # of days
	var orderIncreaseRate = 0.1;

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

		// logging level start
		if (Main.isLogging)
		{
			Main.logger.logLevelStart(day, {day_started: day, money: money});
		}
	}

	function setRange()
	{
		var nameRange:Array<Float> = [
			Math.min(Math.max(Std.int(day / difficultyChangeStep) * nameIncreaseRate, 0), 1 - nameRangeSize),
			Math.min(nameRangeSize + Std.int(day / difficultyChangeStep) * nameIncreaseRate, 1)
		];
		var orderRange:Array<Float> = [
			Math.min(Math.max(Std.int(day / difficultyChangeStep) * orderIncreaseRate, 0), 1 - orderRangeSize),
			Math.min(orderRangeSize + Std.int(day / difficultyChangeStep) * orderIncreaseRate, 1)
		];

		range.set("Name", nameRange);
		range.set("Order", orderRange);
	}

	override public function update(elapsed:Float)
	{
		// Player typing input
		var pressedTab = FlxG.keys.justPressed.TAB;
		var pressedShift = FlxG.keys.justPressed.SHIFT;
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		var pressedEscape = FlxG.keys.justPressed.ESCAPE;
		if (pressedTab && !pressedShift)
		{
			// Go to next input field
			changeSelected(1);
		}
		if (pressedShift && !pressedTab)
		{
			// Go to previous input field
			changeSelected(-1);
		}
		if (pressedEscape)
		{
			if (Main.isLogging)
			{
				Main.logger.logLevelAction(LoggingActions.PRESS_PAUSE, {pressed: "pause", from: "play_state"});
			}
			FlxTimer.globalManager.forEach(function(timer) timer.active = false);
			openSubState(new PauseSubState(FlxColor.fromString("#14100E")));
		}

		if (pressedEnter && currentCustomer == null)
		{
			// log it?
			if (Main.isLogging)
			{
				Main.logger.logLevelAction(LoggingActions.NO_CUSTOMER_SELECTED);
			}

			var selectReminder = new FlxText(0, 0, 0, "Please select customer first!", 20);
			selectReminder.screenCenter();
			selectReminder.y += 190;
			selectReminder.x -= 320;
			selectReminder.color = FlxColor.RED;
			add(selectReminder);
			Timer.delay(remove.bind(selectReminder), 1000);
		}

		if (pressedEnter && currentCustomer != null)
		{
			var currentPosition = currentCustomer.getPosition();
			var customerOrder:Array<String> = currentCustomer.getOrder();
			var matches:Int = 0;
			var matchedString = "";
			var failedString = "";
			// Go through each input field to validate matches
			fields.forEach(function(item:FlxUIInputText)
			{
				var fieldName = labels[item.ID];
				var input = StringTools.trim(item.text);
				var expected = customerOrder[item.ID].toLowerCase();
				trace(fieldName + ": " + input);
				if (input == expected)
				{
					trace(fieldName + " matches");
					matches++;
					matchedString += fieldName + ": " + expected + ";";
				}
				else
				{
					trace(fieldName + " does not match");
					failedString += fieldName + ": " + expected + ", " + input + ";";
				}
			});

			// currently doing this for matches: 100% = happy, 50%+ = satsified, <50% = angry
			// we could do something more intense like how correct each match is (# of characters??) but that's more complex, esp if we have long strings
			var score = matches / labels.length;
			trace("matches score: " + score);
			if (score == 1)
			{
				// logging
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.HAPPY_CUSTOMER, {
						day: day,
						customer_state: "happy",
						percent_matched: score,
						matched: matchedString,
						failed: failedString
					});
				}

				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.happy_customer__png);
				money += 10;
				currentCustomer.showScore("+10", FlxColor.GREEN);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 2000);
				Timer.delay(remove.bind(currentCustomer), 2000);
			}
			else if (score >= 0.5)
			{
				// logging
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SATISFIED_CUSTOMER, {
						day: day,
						customer_state: "satisfied",
						percent_matched: score,
						matched: matchedString,
						failed: failedString
					});
				}

				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.satisfied_customer__png);
				money += 5;
				currentCustomer.showScore("+5", FlxColor.YELLOW);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 2000);
				Timer.delay(remove.bind(currentCustomer), 2000);
			}
			else
			{
				// logging
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.ANGRY_CUSTOMER, {
						day: day,
						customer_state: "angry",
						percent_matched: score,
						matched: matchedString,
						failed: failedString
					});
				}

				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				currentCustomer.showScore("-5", FlxColor.RED);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 2000);
				Timer.delay(remove.bind(currentCustomer), 2000);
			}

			// Reset fields doesn't work 100% properly
			resetFields();
			currentCustomer = null;
			currentCustomerText.text = "Current customer: ";

			// Replace customer?
			displayedCustomers.remove(currentPosition);
			if (remainingCustomers.length > 0)
			{
				Timer.delay(replaceCustomer.bind(currentPosition), 2000);
			}
			else if (!displayedCustomers.keys().hasNext())
			{
				// no more customers - end of day
				endDay();
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
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			// only show text again if customer is already selected
			if (currentCustomer != null && currentCustomer.getPosition() == 1)
			{
				// log it?
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SHOW_ORDER_AGAIN, {day: day, customer_position: 1});
				}

				currentCustomer.showText(3, 3);
			}
			currentCustomer = displayedCustomers.get(1);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 1";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}
		if (pressedTwo && maxCustomersAtOnce >= 2)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			// only show text again if customer is already selected
			if (currentCustomer != null && currentCustomer.getPosition() == 2)
			{
				// log it?
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SHOW_ORDER_AGAIN, {day: day, customer_position: 2});
				}

				currentCustomer.showText(3, 3);
			}
			currentCustomer = displayedCustomers.get(2);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 2";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}
		if (pressedThree && maxCustomersAtOnce >= 3)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			// only show text again if customer is already selected
			if (currentCustomer != null && currentCustomer.getPosition() == 3)
			{
				// log it?
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SHOW_ORDER_AGAIN, {day: day, customer_position: 3});
				}

				currentCustomer.showText(3, 3);
			}
			currentCustomer = displayedCustomers.get(3);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 3";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}
		if (pressedFour && maxCustomersAtOnce >= 4)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			// only show text again if customer is already selected
			if (currentCustomer != null && currentCustomer.getPosition() == 4)
			{
				// log it?
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SHOW_ORDER_AGAIN, {day: day, customer_position: 4});
				}

				currentCustomer.showText(3, 3);
			}
			currentCustomer = displayedCustomers.get(4);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 4";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}
		if (pressedFive && maxCustomersAtOnce >= 5)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			// only show text again if customer is already selected
			if (currentCustomer != null && currentCustomer.getPosition() == 5)
			{
				// log it?
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.SHOW_ORDER_AGAIN, {day: day, customer_position: 5});
				}

				currentCustomer.showText(3, 3);
			}
			currentCustomer = displayedCustomers.get(5);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 5";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}

		// check if a customer has run out of patience
		for (key in displayedCustomers.keys())
		{
			if (!displayedCustomers.get(key).hasPatience)
			{
				if (currentCustomer == displayedCustomers.get(key))
				{
					resetFields();
					currentCustomer = null;
					currentCustomerText.text = "Current customer: ";
				}
				var customer:Customer = displayedCustomers.get(key);
				var order = customer.getOrder();

				// logging
				if (Main.isLogging)
				{
					Main.logger.logLevelAction(LoggingActions.ANGRY_NO_PATIENCE, {day: day, customer_state: "angry", order: order});
				}

				customer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				customer.showScore("-5", FlxColor.RED);
				customer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 2000);
				Timer.delay(remove.bind(customer), 2000);
				displayedCustomers.remove(key);

				// replace customer?
				if (remainingCustomers.length > 0)
				{
					Timer.delay(replaceCustomer.bind(key), 2000);
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

	function randomChoose(random:FlxRandom, label:String):String
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
				customer.showText(5, 0);
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
			newCustomer.showText(5, 0);
		}
	}

	function endDay()
	{
		DayEndState.day = day;
		DayEndState.money = money;
		Timer.delay(FlxG.switchState.bind(new DayEndState()), 3000);
	}
}
