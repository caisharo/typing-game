package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Timer;

class TutorialState extends FlxState
{
	static var colors:Array<String> = ["#C8D8FA", "#FFE7DA"]; // colors for input fields

	var hud:HUD;
	var day:Int = 0;
	var money:Int = 0;
	var customers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var currentCustomer:Customer;

	// Player input section
	var yShift = 120; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = ["Name", "Order"];
	var currentCustomerText:FlxText;

	var phase = 0;

	var tutorialText:Array<String> = [
		"Welcome to the tutorial!", "Look, a customer has appeared!", "Number keys are used to select customers.", "Press 1 to select this customer!",
		"Now type the customer's name!", "Press TAB to go to the next field (SHIFT to go back).", "Now type the customer's order!",
		"Press ENTER to submit your order!",
		"You finished before the customer's patience (green bar) ran out! \n If a customer's patience runs out, they'll be angry and leave.",
		"You have finished the tutorial!", "Returning you to the main menu..."
	];

	// phase 0
	var welcomeText = new FlxTypeText(0, 0, 0, "Welcome to the tutorial!", 20);
	var customerAppearsText = new FlxTypeText(0, 0, 0, "Look, a customer has appeared!", 20);

	// phase 1 - need to press 1
	var selectCustomerText = new FlxTypeText(0, 0, 0, "Number keys are used to select customers.", 20);
	var selectCustomerText2 = new FlxTypeText(0, 0, 0, "Press 1 to select this customer!", 20);

	// phase 2 - need to type anything
	var typeNameText = new FlxTypeText(0, 0, 0, "Now type the customer's name!", 20);

	// phase 3 - need to hit tab or shift
	var tabText = new FlxTypeText(0, 0, 0, "Press TAB to go to the next field (SHIFT to go back).", 20);

	// phase 4 - need to type anything
	var typeOrderText = new FlxTypeText(0, 0, 0, "Now type the customer's order!", 20);

	// phase 5 - need to press enter
	var enterText = new FlxTypeText(0, 0, 0, "Press ENTER to submit your order!", 20);

	// finished
	var finishedText = new FlxTypeText(0, 0, 0,
		"You finished before the customer's patience (green bar) ran out! \n If a customer's patience runs out, they'll be angry and leave.", 20);
	var finishedText2 = new FlxTypeText(0, 0, 0, "You have finished the tutorial!", 20);
	var returnToMenuText = new FlxTypeText(0, 0, 0, "Returning you to the main menu...", 20);

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		// Add HUD (score + day)
		hud = new HUD();
		hud.updateHUD(day, money);
		add(hud);

		// Start with welcome text
		welcomeText.screenCenter();
		welcomeText.y += yShift + 80;
		// welcomeText.x -= 120;
		var temp = new FlxText(0, 0, 0, tutorialText[0], 20);
		welcomeText.x = (FlxG.width - temp.width) / 2;
		add(welcomeText);
		welcomeText.eraseDelay = 0.018;
		welcomeText.eraseCallback = function()
		{
			// Customer appears
			var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
			customers.set(1, customer);
			add(customer);

			// Show text
			customerAppearsText.screenCenter();
			customerAppearsText.y += yShift + 80;
			var temp = new FlxText(0, 0, 0, tutorialText[1], 20);
			// customerAppearsText.x -= 150;
			customerAppearsText.x = (FlxG.width - temp.width) / 2;
			add(customerAppearsText);
			customerAppearsText.eraseDelay = 0.02;
			customerAppearsText.eraseCallback = function()
			{
				// Tell player to select customer
				selectCustomerText.screenCenter();
				selectCustomerText.y += yShift + 80;
				// selectCustomerText.x -= 220;
				var temp = new FlxText(0, 0, 0, tutorialText[2], 20);
				selectCustomerText.x = (FlxG.width - temp.width) / 2;
				add(selectCustomerText);
				selectCustomerText.eraseDelay = 0.02;
				selectCustomerText.eraseCallback = function()
				{
					selectCustomerText2.screenCenter();
					selectCustomerText2.y += yShift + 80;
					// selectCustomerText2.x -= 200;
					var temp = new FlxText(0, 0, 0, tutorialText[3], 20);
					selectCustomerText2.x = (FlxG.width - temp.width) / 2;
					add(selectCustomerText2);
					selectCustomerText2.start(0.02);

					// Start ticking down patience
					Timer.delay(customer.stopPatienceBar, 24000);
					customer.startTimer();

					// Add current customer text
					addCurrentCustomerText();

					phase = 1;
				};
				selectCustomerText.start(0.02, false, true);
			};
			customerAppearsText.start(0.02, false, true);
		};
		welcomeText.start(0.02, false, true);
	}

	override public function update(elapsed:Float)
	{
		// Player typing input
		var pressedTab = FlxG.keys.justPressed.TAB;
		var pressedShift = FlxG.keys.justPressed.SHIFT;
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedTab && !pressedShift && phase >= 3)
		{
			changeSelected(1);
		}
		if (pressedShift && !pressedTab && phase >= 3)
		{
			changeSelected(-1);
		}
		if (pressedEnter && currentCustomer == null && phase >= 5)
		{
			var selectReminder = new FlxText(0, 0, 0, "Please select customer first!", 20);
			selectReminder.screenCenter();
			selectReminder.y += 190;
			selectReminder.x -= 320;
			selectReminder.color = FlxColor.RED;
			add(selectReminder);
			Timer.delay(remove.bind(selectReminder), 1000);
		}
		if (pressedEnter && currentCustomer != null && phase >= 5)
		{
			var customerOrder:Array<String> = currentCustomer.getOrder();
			var matches:Float = 0;

			// Go through each input field to validate matches
			fields.forEach(function(item:FlxUIInputText)
			{
				if (StringTools.trim(item.text) == customerOrder[item.ID])
				{
					matches++;
				}
			});

			// currently doing this for matches: 100% = happy, 50%+ = satsified, <50% = angry
			// we could do something more intense like how correct each match is (# of characters??) but that's more complex, esp if we have long strings
			var score = matches / labels.length;
			if (score == 1)
			{
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
				currentCustomer.stopPatienceBar();
				currentCustomer.changeSprite(AssetPaths.angry_customer__png);
				money -= 5;
				currentCustomer.showScore("-5", FlxColor.RED);
				currentCustomer.fadeAway();
				Timer.delay(hud.updateHUD.bind(day, money), 2000);
				Timer.delay(remove.bind(currentCustomer), 2000);
			}

			resetFields();
			currentCustomer = null;
			currentCustomerText.text = "Current customer: ";

			// Enter was pressed so erase text and show final text before returning to main menu
			enterText.eraseDelay = 0.02;
			enterText.erase(0.02, false, [], function()
			{
				finishedText.screenCenter();
				finishedText.y += yShift + 80;
				// finishedText.x -= 300;
				var temp = new FlxText(0, 0, 0, tutorialText[8], 20);
				finishedText.x = (FlxG.width - temp.width) / 2;
				add(finishedText);
				finishedText.eraseDelay = 0.009;
				finishedText.eraseCallback = function()
				{
					finishedText2.screenCenter();
					finishedText2.y += yShift + 80;
					// finishedText2.x -= 120;
					var temp = new FlxText(0, 0, 0, tutorialText[9], 20);
					finishedText2.x = (FlxG.width - temp.width) / 2;
					add(finishedText2);
					finishedText2.eraseDelay = 0.015;
					finishedText2.eraseCallback = function()
					{
						// Return to main menu
						returnToMenuText.screenCenter();
						returnToMenuText.y += yShift + 80;
						// returnToMenuText.x -= 120;
						var temp = new FlxText(0, 0, 0, tutorialText[10], 20);
						returnToMenuText.x = (FlxG.width - temp.width) / 2;
						add(returnToMenuText);
						returnToMenuText.start(0.02, false, false, [], function()
						{
							FlxFlicker.flicker(returnToMenuText, 0, .5);
							Timer.delay(FlxG.switchState.bind(new MenuState()), 1500);
						});
					};
					finishedText2.start(0.015, false, true);
				};
				finishedText.start(0.009, false, true);
			});
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
		if (pressedOne && phase >= 1)
		{
			if (currentCustomer != null)
			{
				currentCustomer.changeNumColor(FlxColor.WHITE);
			}
			currentCustomer = customers.get(1);
			if (currentCustomer != null)
			{
				currentCustomerText.text = "Current customer: 1";
				currentCustomer.changeNumColor(FlxColor.YELLOW);
			}
		}

		// Phase checking for tutorial
		if (phase == 1 && pressedOne)
		{
			selectCustomerText.eraseDelay = 0.02;
			selectCustomerText2.erase(0.02, false, [], function()
			{
				addInput();
				typeNameText.screenCenter();
				typeNameText.y += yShift + 80;
				// typeNameText.x -= 200;
				var temp = new FlxText(0, 0, 0, tutorialText[4], 20);
				typeNameText.x = (FlxG.width - temp.width) / 2;
				add(typeNameText);
				typeNameText.start(0.02);
				phase = 2;
			});
		}

		var isTyping = FlxG.keys.anyPressed([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]);

		if (phase == 2 && isTyping)
		{
			typeNameText.eraseDelay = 0.02;
			typeNameText.erase(0.02, false, [], function()
			{
				tabText.screenCenter();
				tabText.y += yShift + 80;
				// tabText.x -= 170;
				var temp = new FlxText(0, 0, 0, tutorialText[5], 20);
				tabText.x = (FlxG.width - temp.width) / 2;
				add(tabText);
				tabText.start(0.02);
				phase = 3;
			});
		}

		if (phase == 3 && (pressedTab || pressedShift || currentField == 1))
		{
			tabText.eraseDelay = 0.02;
			tabText.erase(0.02, false, [], function()
			{
				typeOrderText.screenCenter();
				typeOrderText.y += yShift + 80;
				// typeOrderText.x -= 120;
				var temp = new FlxText(0, 0, 0, tutorialText[6], 20);
				typeOrderText.x = (FlxG.width - temp.width) / 2;
				add(typeOrderText);
				typeOrderText.start(0.02);
				phase = 4;
			});
		}

		if (phase == 4 && isTyping)
		{
			typeOrderText.eraseDelay = 0.02;
			typeOrderText.erase(0.02, false, [], function()
			{
				enterText.screenCenter();
				enterText.y += yShift + 80;
				// enterText.x -= 120;
				var temp = new FlxText(0, 0, 0, tutorialText[7], 20);
				enterText.x = (FlxG.width - temp.width) / 2;
				add(enterText);
				enterText.start(0.02);
				phase = 5;
			});
		}

		super.update(elapsed);
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

	function addCurrentCustomerText()
	{
		var text = "Current customer: ";
		if (currentCustomer != null)
		{
			text += currentCustomer.getPosition();
		}
		currentCustomerText = new FlxText(0, 0, 0, text, 18);
		currentCustomerText.screenCenter();
		currentCustomerText.y += 130;
		currentCustomerText.x -= 300;
		add(currentCustomerText);
	}
}
