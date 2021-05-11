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
import js.html.TextTrackCueList;

class TypeState extends FlxState
{
	static var colors:Array<String> = ["#C8D8FA", "#FFE7DA"]; // colors for input fields

	var hud:HUD;
	var day:Int = -3;
	var money:Int = 0;
	var customers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var currentCustomer:Customer;

	// Player input section
	var yShift = 120; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = ["Name", "Order"];
	var currentCustomerText:FlxText;

	var tutorialText:Array<String> = [
		"There are some last information to share before you get started.",
		"First, you are always welcomed to switch between customers.",
		"Second, the content of name and order will \n be automatically hidden after some time.",
		"Third, if you want to reveal those content, press the number key again.",
		"Note that such an action will cost you some patience.",
		"Lastly, your award will be account on your correctness.",
		"That's all information you need, now let's get start it!",
		"Use TAB or SHIFT to choose fields, press ENTER to submit.",
		"You have finished all tutorials. Have fun in the actual game!"
	];

	var lastText = new FlxTypeText(0, 0, 0, "There are some last information to share before you get started.", 20);
	var firstText = new FlxTypeText(0, 0, 0, "First, you are always welcomed to switch between customers.", 20);
	var secondText = new FlxTypeText(0, 0, 0, "Second, the content of name and order will \n be automatically hidden after some time.", 20);
	var thirdText = new FlxTypeText(0, 0, 0, "Third, if you want to reveal those content, press the number key again.", 20);
	var noteText = new FlxTypeText(0, 0, 0, "Note that such an action will cost you some patience.", 20);
	var awardText = new FlxTypeText(0, 0, 0, "Lastly, your award will be account on your correctness.", 20);
	var allText = new FlxTypeText(0, 0, 0, "That's all information you need, now let's get start it!", 20);
	var submitText = new FlxTypeText(0, 0, 0, "Use TAB or SHIFT to choose fields, press ENTER to submit.", 20);
	var funText = new FlxTypeText(0, 0, 0, "You have finished all tutorials. Have fun in the actual game!", 20);

	var temp:FlxText;

	var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
	var newCustomer:Customer = new Customer(2, ["bob", "latte"], 20);

	var stageDone = false;

	var total = 2;

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
		temp = new FlxText(0, 0, 0, tutorialText[0], 20);
		lastText.screenCenter();
		lastText.y += 80;
		lastText.x = (FlxG.width - temp.width) / 2;
		add(lastText);
		lastText.start(0.04, false, false, [], function()
		{
			Timer.delay(function()
			{
				remove(lastText);
				temp = new FlxText(0, 0, 0, tutorialText[1], 20);
				firstText.screenCenter();
				firstText.y += 80;
				firstText.x = (FlxG.width - temp.width) / 2;
				add(firstText);
				firstText.start(0.04, false, false, [], function()
				{
					Timer.delay(function()
					{
						remove(firstText);
						temp = new FlxText(0, 0, 0, tutorialText[2], 20);
						secondText.screenCenter();
						secondText.y += 80;
						secondText.x = (FlxG.width - temp.width) / 2;
						add(secondText);
						secondText.start(0.04, false, false, [], function()
						{
							Timer.delay(function()
							{
								remove(secondText);
								temp = new FlxText(0, 0, 0, tutorialText[3], 20);
								thirdText.screenCenter();
								thirdText.y += 80;
								thirdText.x = (FlxG.width - temp.width) / 2;
								add(thirdText);
								thirdText.start(0.04, false, false, [], function()
								{
									Timer.delay(function()
									{
										remove(thirdText);
										temp = new FlxText(0, 0, 0, tutorialText[4], 20);
										noteText.screenCenter();
										noteText.y += 80;
										noteText.x = (FlxG.width - temp.width) / 2;
										add(noteText);
										noteText.start(0.04, false, false, [], function()
										{
											Timer.delay(function()
											{
												remove(noteText);
												temp = new FlxText(0, 0, 0, tutorialText[5], 20);
												awardText.screenCenter();
												awardText.y += 80;
												awardText.x = (FlxG.width - temp.width) / 2;
												add(awardText);
												awardText.start(0.04, false, false, [], function()
												{
													Timer.delay(function()
													{
														remove(awardText);
														temp = new FlxText(0, 0, 0, tutorialText[6], 20);
														allText.screenCenter();
														allText.y += 80;
														allText.x = (FlxG.width - temp.width) / 2;
														add(allText);
														allText.start(0.04, false, false, [], function()
														{
															Timer.delay(function()
															{
																remove(allText);
																Timer.delay(function()
																{
																	var customer:Customer = new Customer(1, ["alice", "coffee"], 40);
																	var newCustomer:Customer = new Customer(2, ["bob", "latte"], 35);
																	add(customer);
																	add(newCustomer);
																	temp = new FlxText(0, 0, 0, tutorialText[7], 20);
																	submitText.screenCenter();
																	submitText.y += yShift + 80;
																	submitText.x = (FlxG.width - temp.width) / 2;
																	add(submitText);
																	submitText.start(0.04, false, false);
																	customers.set(1, customer);
																	customers.set(2, newCustomer);
																	addInput();
																	var text = "Current customer: ";
																	currentCustomerText = new FlxText(0, 0, 0, text, 18);
																	currentCustomerText.screenCenter();
																	currentCustomerText.y += 160;
																	currentCustomerText.x -= 300;
																	// try to prevent player from failing - stop patience bar before time runs out
																	// however doesn't account for time loss due to player showing text again...
																	// currently just giving customers extra time, and stopping with 7 seconds left (which should give them 2 show text again attempts)
																	Timer.delay(customer.stopPatienceBar, 33000);
																	Timer.delay(newCustomer.stopPatienceBar, 28000);
																	customer.startTimer();
																	newCustomer.startTimer();
																	customer.showText(5, 0);
																	newCustomer.showText(5, 0);
																	add(currentCustomerText);
																	stageDone = true;
																}, 300);
															}, 1500);
														});
													}, 1500);
												});
											}, 2000);
										});
									}, 2000);
								});
							}, 2000);
						});
					}, 2000);
				});
			}, 1500);
		});

		// logging tutorial level start
		if (Main.isLogging)
		{
			Main.logger.logLevelStart(-3, {day_started: day, money: money});
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (Main.isLogging)
			{
				Main.logger.logLevelAction(LoggingActions.PRESS_TUTORIAL_PAUSE, {pressed: "tutorial_pause", from: "type_state"});
			}
			FlxTimer.globalManager.forEach(function(timer) timer.active = false);
			openSubState(new TutorialPauseSubState(FlxColor.fromString("#14100E")));
		}
		if (stageDone)
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
					Main.logger.logLevelAction(LoggingActions.PRESS_PAUSE, {pressed: "pause", from: "type_state"});
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
				customers.remove(currentCustomer.getPosition());
				currentCustomer = null;
				currentCustomerText.text = "Current customer: ";
				total--;
				if (total == 0)
				{
					// no more customers - end of day
					end();
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
			if (pressedOne)
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
				currentCustomer = customers.get(1);
				if (currentCustomer != null)
				{
					currentCustomerText.text = "Current customer: 1";
					currentCustomer.changeNumColor(FlxColor.YELLOW);
				}
			}
			if (pressedTwo)
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
				currentCustomer = customers.get(2);
				if (currentCustomer != null)
				{
					currentCustomerText.text = "Current customer: 2";
					currentCustomer.changeNumColor(FlxColor.YELLOW);
				}
			}
			for (key in customers.keys())
			{
				if (!customers.get(key).hasPatience)
				{
					if (currentCustomer == customers.get(key))
					{
						currentCustomer = null;
						currentCustomerText.text = "Current customer: ";
					}
					var customer:Customer = customers.get(key);
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
					customers.remove(key);
					resetFields();
					customers.remove(currentCustomer.getPosition());
					currentCustomer = null;
					currentCustomerText.text = "Current customer: ";
					total--;
					if (total == 0)
					{
						end();
					}
				}
			}
		}
		super.update(elapsed);
	}

	function end()
	{
		remove(submitText);
		if (Main.isLogging)
		{
			Main.logger.logLevelEnd({tutorial_completed: true, money: money});
		}
		// save that player cleared tutorial?
		FlxG.save.data.clearedTutorial = true;
		FlxG.save.flush(); // save data
		temp = new FlxText(0, 0, 0, tutorialText[8], 20);
		funText.screenCenter();
		funText.y += yShift + 80;
		funText.x = (FlxG.width - temp.width) / 2;
		add(funText);
		funText.start(0.04, false, false, [], function()
		{
			Timer.delay(FlxG.switchState.bind(new TypeEndState()), 1000);
		});
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
}
