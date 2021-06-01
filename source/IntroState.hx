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

class IntroState extends FlxState
{
	static var colors:Array<String> = ["#C8D8FA", "#FFE7DA"]; // colors for input fields

	var hud:HUD;
	var day:Int = -1;
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
		"Welcome to the introduction!",
		"You will learn the basic concepts here.",
		"This is a customer.",
		"The blue text above the customer's head is the name.",
		"The text below the name is the order.",
		"The bar is the customer's patience bar, and it will decrease over time.",
		"In the actual game, you will need to type the name and order in the corresponding fields before the patience runs out, but not for now.",
		"Now let's get some keyboard interactions involved."
	];

	var welcomeText = new FlxTypeText(0, 0, 0, "Welcome to the introduction!", 20);
	var conceptText = new FlxTypeText(0, 0, 0, "You will learn the basic concepts here.", 20);
	var customerText = new FlxTypeText(0, 0, 0, "This is a customer.", 20);
	var nameText = new FlxTypeText(0, 0, 0, "The blue text above the customer's head is the name.", 20);
	var orderText = new FlxTypeText(0, 0, 0, "The text below the name is the order.", 20);
	var patienceText = new FlxTypeText(0, 0, 0, "The bar is the customer's patience bar, and it will decrease over time.", 20);
	var actualText = new FlxTypeText(0, 0, FlxG.width - 400,
		"In the actual game, you will need to type the name and order in the corresponding fields before the patience runs out, but not for now.", 20);
	var nextText = new FlxTypeText(0, 0, 0, "Now let's get some keyboard interactions involved.", 20);

	var welcomeDone = false;
	var conceptDone = false;
	var customerDone = false;
	var nameDone = false;
	var orderDone = false;
	var patienceDone = false;
	var actualDone = false;

	var skipInput:Array<FlxKey> = [FlxKey.ENTER];
	var enterText = new FlxText(0, 0, 0, "Press ENTER to continue...", 16);
	var text = new FlxText(0, 0, 0, "Press ENTER to continue...", 16);

	var temp:FlxText;

	override public function create()
	{
		super.create();

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		// background image
		var background = new FlxSprite(0, 0, AssetPaths.cafe_background__png);
		add(background);

		// Add HUD (score + day)
		hud = new HUD();
		hud.updateHUD(day, money);
		add(hud);

		// Start with welcome text
		temp = new FlxText(0, 0, 0, tutorialText[0], 20);
		welcomeText.screenCenter();
		welcomeText.y += yShift + 80;
		welcomeText.x = (FlxG.width - temp.width) / 2;
		welcomeText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
		add(welcomeText);
		welcomeText.start(0.04, false, false, skipInput, function()
		{
			welcomeDone = true;
			enterToContinue();
		});

		// logging tutorial level start
		if (Main.isLogging)
		{
			Main.logger.logLevelStart(-1, {day_started: day, money: money});
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (Main.isLogging)
			{
				Main.logger.logLevelAction(LoggingActions.PRESS_TUTORIAL_PAUSE, {pressed: "tutorial_pause", from: "intro_state"});
			}
			FlxTimer.globalManager.forEach(function(timer) timer.active = false);
			openSubState(new TutorialPauseSubState(FlxColor.fromString("#14100E")));
		}

		if (welcomeDone && !conceptDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(welcomeText);
				remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[1], 20);
				conceptText.screenCenter();
				conceptText.y += yShift + 80;
				conceptText.x = (FlxG.width - temp.width) / 2;
				conceptText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(conceptText);
				conceptText.start(0.04, false, false, skipInput, function()
				{
					conceptDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (conceptDone && !customerDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(conceptText);
				// remove(enterText);
				var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
				customers.set(1, customer);
				add(customer);

				temp = new FlxText(0, 0, 0, tutorialText[2], 20);
				customerText.screenCenter();
				customerText.y += yShift + 80;
				customerText.x = (FlxG.width - temp.width) / 2;
				customerText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(customerText);
				customerText.start(0.04, false, false, skipInput, function()
				{
					customerDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (customerDone && !nameDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(customerText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[3], 20);
				nameText.screenCenter();
				nameText.y += yShift + 80;
				nameText.x = (FlxG.width - temp.width) / 2;
				nameText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(nameText);
				nameText.start(0.04, false, false, skipInput, function()
				{
					nameDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (nameDone && !orderDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(nameText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[4], 20);
				orderText.screenCenter();
				orderText.y += yShift + 80;
				orderText.x = (FlxG.width - temp.width) / 2;
				orderText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(orderText);
				orderText.start(0.04, false, false, skipInput, function()
				{
					orderDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (orderDone && !patienceDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(orderText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[5], 20);
				patienceText.screenCenter();
				patienceText.y += yShift + 80;
				patienceText.x = (FlxG.width - temp.width) / 2;
				patienceText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(patienceText);
				patienceText.start(0.04, false, false, skipInput, function()
				{
					patienceDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (patienceDone && !actualDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(patienceText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[6], 20);
				actualText.screenCenter();
				actualText.y += yShift + 80;
				actualText.x = (FlxG.width - actualText.width) / 2;
				actualText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(actualText);
				actualText.start(0.04, false, false, skipInput, function()
				{
					actualDone = true;
					// enterToContinue();
				});
				addInput();
			}, 100);
		}

		if (actualDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(actualText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[7], 20);
				nextText.screenCenter();
				nextText.y += yShift + 80;
				nextText.x = (FlxG.width - temp.width) / 2;
				nextText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(nextText);
				nextText.start(0.04, false, false, skipInput, function()
				{
					Timer.delay(function()
					{
						FlxG.save.data.clearedOne = true;
						FlxG.save.flush();
						if (Main.isLogging)
						{
							Main.logger.logActionWithNoLevel(LoggingActions.PRESS_SELECT, {pressed: "auto-next", from: "intro_end"});
						}
						FlxG.switchState(new SelectState());
					}, 1000);
				});
			}, 100);
		}

		super.update(elapsed);
	}

	function enterToContinue()
	{
		Timer.delay(function()
		{
			enterText.screenCenter();
			enterText.y += yShift + 130;
			enterText.x = (FlxG.width - text.width) / 2 + 150;
			add(enterText);
			FlxFlicker.flicker(enterText, 0, 0.8);
		}, 400);
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
		fieldLabel.setFormat("assets/fonts/Kaorigelbold.ttf", 20);
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
}
