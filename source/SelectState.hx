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

class SelectState extends FlxState
{
	static var colors:Array<String> = ["#C8D8FA", "#FFE7DA"]; // colors for input fields

	var hud:HUD;
	var day:Int = -2;
	var money:Int = 0;
	var customers:Map<Int, Customer> = []; // map customer position (numkey) to customer
	var currentCustomer:Customer;

	// Player input section
	var yShift = 140; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = ["Name", "Order"];
	var currentCustomerText:FlxText;

	var tutorialText:Array<String> = [
		"Here's Alice again.",
		"She is assigned with number 1, as you can see next to her.",
		"Press 1 to select her."
	];

	var aliceText = new FlxTypeText(0, 0, 0, "Here's Alice again.", 20);
	var numberText = new FlxTypeText(0, 0, 0, "She is assigned with number 1, as you can see next to her.", 20);
	var pressText = new FlxTypeText(0, 0, 0, "Press 1 to select her.", 20);

	var aliceDone = false;
	var numberDone = false;

	var tutorialTextTwo:Array<String> = [
		"Both the yellow color and the text on the screen show the current selected customer. Be aware of these.",
		"Now we try to switch between customers.",
		"Here's Bob.",
		"Press 2 to select him."
	];

	var awareText = new FlxTypeText(0, 0, FlxG.width - 400,
		"Both the yellow color and the text on the screen show the current selected customer. Be aware of these.", 20);
	var tryText = new FlxTypeText(0, 0, 0, "Now we try to switch between customers.", 20);
	var bobText = new FlxTypeText(0, 0, 0, "Here's Bob.", 20);
	var twoText = new FlxTypeText(0, 0, 0, "Press 2 to select him.", 20);

	var awareDone = false;
	var tryDone = false;
	var bobDone = false;

	var tutorialTextThree:Array<String> = ["Great! It's time to learn more things."];

	var moreText = new FlxTypeText(0, 0, 0, "Great! It's time to learn more things.", 20);

	var temp:FlxText;
	var stageOneDone = false;
	var stageTwoDone = false;

	var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
	var newCustomer:Customer = new Customer(2, ["bob", "latte"], 20);

	var skipInput:Array<FlxKey> = [FlxKey.ENTER];
	var enterText = new FlxText(0, 0, 0, "Press ENTER to continue...", 16);
	var text = new FlxText(0, 0, 0, "Press ENTER to continue...", 16);

	override public function create()
	{
		super.create();

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		// Add HUD (score + day)
		hud = new HUD();
		hud.updateHUD(day, money);
		add(hud);

		// Start with welcome text
		temp = new FlxText(0, 0, 0, tutorialText[0], 20);
		aliceText.screenCenter();
		aliceText.y += yShift + 80;
		aliceText.x = (FlxG.width - temp.width) / 2;
		aliceText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
		add(aliceText);
		// var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
		customers.set(1, customer);
		add(customer);
		addInput();
		var text = "Current customer: ";
		currentCustomerText = new FlxText(0, 0, 0, text, 18);
		currentCustomerText.screenCenter();
		currentCustomerText.y += 160;
		currentCustomerText.x -= 300;
		currentCustomerText.setFormat("assets/fonts/Kaorigelbold.ttf", 23);
		add(currentCustomerText);
		aliceText.start(0.04, false, false, skipInput, function()
		{
			aliceDone = true;
			enterToContinue();
		});

		// logging tutorial level start
		if (Main.isLogging)
		{
			Main.logger.logLevelStart(-2, {day_started: day, money: money});
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (Main.isLogging)
			{
				Main.logger.logLevelAction(LoggingActions.PRESS_TUTORIAL_PAUSE, {pressed: "tutorial_pause", from: "select_state"});
			}
			FlxTimer.globalManager.forEach(function(timer) timer.active = false);
			openSubState(new TutorialPauseSubState(FlxColor.fromString("#14100E")));
		}

		if (aliceDone && !numberDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(aliceText);
				remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[1], 20);
				numberText.screenCenter();
				numberText.y += yShift + 80;
				numberText.x = (FlxG.width - temp.width) / 2;
				numberText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(numberText);
				numberText.start(0.04, false, false, skipInput, function()
				{
					numberDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (numberDone && !stageOneDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(numberText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialText[2], 20);
				pressText.screenCenter();
				pressText.y += yShift + 80;
				pressText.x = (FlxG.width - temp.width) / 2;
				pressText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(pressText);
				pressText.start(0.04, false, false, skipInput, function()
				{
					stageOneDone = true;
				});
			}, 100);
		}

		if (stageOneDone && !awareDone && FlxG.keys.justPressed.ONE)
		{
			Timer.delay(function()
			{
				remove(pressText);
				remove(currentCustomerText);

				var text = "Current customer: 1";
				currentCustomer = customer;
				currentCustomerText = new FlxText(0, 0, 0, text, 18);
				currentCustomerText.screenCenter();
				currentCustomerText.y += 160;
				currentCustomerText.x -= 300;
				currentCustomerText.setFormat("assets/fonts/Kaorigelbold.ttf", 23);
				add(currentCustomerText);
				currentCustomer.changeNumColor(FlxColor.YELLOW);

				temp = new FlxText(0, 0, 0, tutorialTextTwo[0], 20);
				awareText.screenCenter();
				awareText.y += yShift + 80;
				awareText.x = (FlxG.width - awareText.width) / 2;
				awareText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(awareText);
				awareText.start(0.04, false, false, skipInput, function()
				{
					awareDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (awareDone && !tryDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(awareText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialTextTwo[1], 20);
				tryText.screenCenter();
				tryText.y += yShift + 80;
				tryText.x = (FlxG.width - temp.width) / 2;
				tryText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(tryText);
				tryText.start(0.04, false, false, skipInput, function()
				{
					tryDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (tryDone && !bobDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(tryText);
				// remove(enterText);
				customers.set(2, newCustomer);
				add(newCustomer);

				temp = new FlxText(0, 0, 0, tutorialTextTwo[2], 20);
				bobText.screenCenter();
				bobText.y += yShift + 80;
				bobText.x = (FlxG.width - temp.width) / 2;
				bobText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(bobText);
				bobText.start(0.04, false, false, skipInput, function()
				{
					bobDone = true;
					// enterToContinue();
				});
			}, 100);
		}

		if (bobDone && !stageTwoDone && FlxG.keys.justPressed.ENTER)
		{
			Timer.delay(function()
			{
				remove(bobText);
				// remove(enterText);
				temp = new FlxText(0, 0, 0, tutorialTextTwo[3], 20);
				twoText.screenCenter();
				twoText.y += yShift + 80;
				twoText.x = (FlxG.width - temp.width) / 2;
				twoText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(twoText);
				twoText.start(0.04, false, false, skipInput, function()
				{
					stageTwoDone = true;
				});
			}, 100);
		}

		if (stageTwoDone && FlxG.keys.justPressed.TWO)
		{
			Timer.delay(function()
			{
				remove(twoText);
				remove(currentCustomerText);
				currentCustomer.changeNumColor(FlxColor.WHITE);

				var text = "Current customer: 2";
				currentCustomer = newCustomer;
				currentCustomerText = new FlxText(0, 0, 0, text, 18);
				currentCustomerText.screenCenter();
				currentCustomerText.y += 160;
				currentCustomerText.x -= 300;
				currentCustomerText.setFormat("assets/fonts/Kaorigelbold.ttf", 23);
				add(currentCustomerText);
				currentCustomer.changeNumColor(FlxColor.YELLOW);

				temp = new FlxText(0, 0, 0, tutorialTextThree[0], 20);
				moreText.screenCenter();
				moreText.y += yShift + 80;
				moreText.x = (FlxG.width - temp.width) / 2;
				moreText.setFormat("assets/fonts/Kaorigelbold.ttf", 25);
				add(moreText);
				moreText.start(0.04, false, false, skipInput, function()
				{
					Timer.delay(function()
					{
						FlxG.save.data.clearedTwo = true;
						FlxG.save.flush();
						FlxG.switchState(new SelectEndState());
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
