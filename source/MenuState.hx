package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	override public function create()
	{
		// Will probably disable mouse since we want our controls to be keyboard-based
		// Currently not disabled just to make testing a bit easier
		// FlxG.mouse.visible = false;

		// background color
		FlxG.cameras.bgColor = FlxColor.fromString("#14100E");

		var titleText = new FlxText(0, 0, 0, "Typing Game", 64);
		titleText.screenCenter();
		titleText.y = 64;
		add(titleText);

		var startButton = new FlxButton(0, 0, "Start", startGame);
		startButton.screenCenter();
		startButton.scale.x = startButton.scale.y = 3;
		startButton.label.size = 14;
		startButton.label.alignment = FlxTextAlign.CENTER;
		startButton.y += 50;
		add(startButton);

		var tutorialButton = new FlxButton(0, 0, "Tutorial", startTutorial);
		tutorialButton.screenCenter();
		tutorialButton.scale.x = tutorialButton.scale.y = 3;
		tutorialButton.label.size = 14;
		tutorialButton.label.alignment = FlxTextAlign.CENTER;
		tutorialButton.y += 150;
		add(tutorialButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	private function startGame()
	{
		// Use saved value?
		if (FlxG.save.data.dayCompleted != null)
		{
			PlayState.day = FlxG.save.data.dayCompleted + 1;
		}
		if (FlxG.save.data.playerMoney != null)
		{
			PlayState.money = FlxG.save.data.playerMoney;
		}
		FlxG.switchState(new PlayState());
	}

	private function startTutorial()
	{
		FlxG.switchState(new TutorialState());
	}
}
