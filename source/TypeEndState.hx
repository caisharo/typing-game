package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import js.html.SelectElement;

class TypeEndState extends FlxState
{
	public var isPersistent:Bool = false;

	public var displayedCustomers:Map<Int, Customer> = [];

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		Main.logger.logLevelEnd({day_completed: -3, gained_money: 0, total_money: 0});

		var tutorialButton = new FlxButton(0, 0, "Tutorial", returnToTutorial);
		tutorialButton.screenCenter();
		tutorialButton.scale.x = tutorialButton.scale.y = 3;
		tutorialButton.label.size = 14;
		tutorialButton.label.alignment = FlxTextAlign.CENTER;
		tutorialButton.y += 100;
		add(tutorialButton);

		var menuButton = new FlxButton(0, 0, "Menu", returnToMenu);
		menuButton.screenCenter();
		menuButton.scale.x = menuButton.scale.y = 3;
		menuButton.label.size = 14;
		menuButton.label.alignment = FlxTextAlign.CENTER;
		menuButton.y += 200;
		add(menuButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function returnToTutorial()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_TUTORIAL, {pressed: "tutorial", from: "type_end"});
		FlxG.switchState(new TutorialMenuState());
	}

	function returnToMenu()
	{
		Main.logger.logActionWithNoLevel(LoggingActions.PRESS_RETURN_TO_MENU, {pressed: "menu", from: "type_end"});
		FlxG.switchState(new MenuState());
	}
}
