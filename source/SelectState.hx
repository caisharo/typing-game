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
	var yShift = 120; // how much to move everything down by
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

	var tutorialTextTwo:Array<String> = [
		"Both the yellow color and the text on the screen \n show the current selected customer. Be aware of these.",
		"Now we try to switch between customers.",
		"Here's Bob.",
		"Press 2 to select him."
	];

	var awareText = new FlxTypeText(0, 0, 0, "Both the yellow color and the text on the screen \n show the current selected customer. Be aware of these.", 20);
	var tryText = new FlxTypeText(0, 0, 0, "Now we try to switch between customers.", 20);
	var bobText = new FlxTypeText(0, 0, 0, "Here's Bob.", 20);
	var twoText = new FlxTypeText(0, 0, 0, "Press 2 to select him.", 20);

	var tutorialTextThree:Array<String> = ["Great! It's time to learn more things."];

	var moreText = new FlxTypeText(0, 0, 0, "Great! It's time to learn more things.", 20);

	var temp:FlxText;
	var stageOneDone = false;
	var stageTwoDone = false;

	var customer:Customer = new Customer(1, ["alice", "coffee"], 25);
	var newCustomer:Customer = new Customer(2, ["bob", "latte"], 20);

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
		aliceText.screenCenter();
		aliceText.y += yShift + 80;
		aliceText.x = (FlxG.width - temp.width) / 2;
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
		add(currentCustomerText);
		aliceText.start(0.04, false, false, [], function()
		{
			Timer.delay(function()
			{
				remove(aliceText);
				temp = new FlxText(0, 0, 0, tutorialText[1], 20);
				numberText.screenCenter();
				numberText.y += yShift + 80;
				numberText.x = (FlxG.width - temp.width) / 2;
				add(numberText);
				numberText.start(0.04, false, false, [], function()
				{
					Timer.delay(function()
					{
						remove(numberText);
						temp = new FlxText(0, 0, 0, tutorialText[2], 20);
						pressText.screenCenter();
						pressText.y += yShift + 80;
						pressText.x = (FlxG.width - temp.width) / 2;
						add(pressText);
						pressText.start(0.04, false, false, [], function()
						{
							stageOneDone = true;
						});
					}, 1500);
				});
			}, 1500);
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
			FlxTimer.globalManager.forEach(function(timer) timer.active = false);
			openSubState(new TutorialPauseSubState(FlxColor.fromString("#14100E")));
		}

		if (stageOneDone && FlxG.keys.justPressed.ONE)
		{
			remove(pressText);
			remove(currentCustomerText);

			var text = "Current customer: 1";
			currentCustomer = customer;
			currentCustomerText = new FlxText(0, 0, 0, text, 18);
			currentCustomerText.screenCenter();
			currentCustomerText.y += 160;
			currentCustomerText.x -= 300;
			add(currentCustomerText);
			currentCustomer.changeNumColor(FlxColor.YELLOW);

			temp = new FlxText(0, 0, 0, tutorialTextTwo[0], 20);
			awareText.screenCenter();
			awareText.y += yShift + 80;
			awareText.x = (FlxG.width - temp.width) / 2;
			add(awareText);
			awareText.start(0.04, false, false, [], function()
			{
				Timer.delay(function()
				{
					remove(awareText);
					temp = new FlxText(0, 0, 0, tutorialTextTwo[1], 20);
					tryText.screenCenter();
					tryText.y += yShift + 80;
					tryText.x = (FlxG.width - temp.width) / 2;
					add(tryText);
					tryText.start(0.04, false, false, [], function()
					{
						Timer.delay(function()
						{
							remove(tryText);
							customers.set(2, newCustomer);
							add(newCustomer);

							temp = new FlxText(0, 0, 0, tutorialTextTwo[2], 20);
							bobText.screenCenter();
							bobText.y += yShift + 80;
							bobText.x = (FlxG.width - temp.width) / 2;
							add(bobText);
							bobText.start(0.04, false, false, [], function()
							{
								Timer.delay(function()
								{
									remove(bobText);
									temp = new FlxText(0, 0, 0, tutorialTextTwo[3], 20);
									twoText.screenCenter();
									twoText.y += yShift + 80;
									twoText.x = (FlxG.width - temp.width) / 2;
									add(twoText);
									twoText.start(0.04, false, false, [], function()
									{
										stageTwoDone = true;
									});
								}, 1500);
							});
						}, 1500);
					});
				}, 2500);
			});
		}

		if (stageTwoDone && FlxG.keys.justPressed.TWO)
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
			add(currentCustomerText);
			currentCustomer.changeNumColor(FlxColor.YELLOW);

			temp = new FlxText(0, 0, 0, tutorialTextThree[0], 20);
			moreText.screenCenter();
			moreText.y += yShift + 80;
			moreText.x = (FlxG.width - temp.width) / 2;
			add(moreText);
			moreText.start(0.04, false, false, [], function()
			{
				Timer.delay(function()
				{
					FlxG.switchState(new SelectEndState());
				}, 1500);
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
}
