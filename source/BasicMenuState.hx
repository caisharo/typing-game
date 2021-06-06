package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// Menus should extend this to have menu "buttons" selectable using keyboard
// Classes that extend should do something like this in create():
// menuItems = new FlxTypedGroup<FlxText>();
// addMenuItem("Name", function);
class BasicMenuState extends FlxState
{
	// Stuff for menu "buttons"
	var yShift = 400; // how much to move everything down by
	var yGap = 60; // gap between menu items
	var fontSize = 42;
	var currentMenuItem = 0;
	var menuItems:FlxTypedGroup<FlxText>;
	var menuFunctions:Array<Void->Void> = [];

	var selectedTextFormat = new FlxTextFormat(FlxColor.WHITE, false, false);
	var unselectedTextFormat = new FlxTextFormat(FlxColor.GRAY, false, false);

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var pressedPrevious = FlxG.keys.justPressed.UP
			|| FlxG.keys.justPressed.W
			|| (FlxG.keys.justPressed.TAB && FlxG.keys.pressed.SHIFT);
		var pressedNext = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S || FlxG.keys.justPressed.TAB;
		if (pressedPrevious)
		{
			// Go to previous input field
			FlxG.sound.play(AssetPaths.menuSwitch__wav);
			changeSelected(-1);
		}
		else if (pressedNext)
		{
			// Go to next input field
			FlxG.sound.play(AssetPaths.menuSwitch__wav);
			changeSelected(1);
		}
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedEnter)
		{
			menuFunctions[currentMenuItem]();
		}

		super.update(elapsed);
	}

	function addMenuItem(name:String = "Option", menuFunction:Void->Void)
	{
		var newMenuItem = new FlxText(0, 0, 0, name, fontSize);
		newMenuItem.setFormat("assets/fonts/Kaorigelbold.ttf", fontSize);
		newMenuItem.ID = menuItems.length;
		if (Main.isDebugging)
		{
			trace(name + ": new id " + newMenuItem.ID);
		}
		newMenuItem.screenCenter();
		newMenuItem.y = yShift + (yGap * menuItems.length);

		menuItems.add(newMenuItem);
		add(newMenuItem);

		// Add function to array
		menuFunctions.push(menuFunction);

		changeSelected();
	}

	function changeSelected(direction:Int = 0)
	{
		currentMenuItem += direction;
		if (currentMenuItem >= menuItems.length)
		{
			currentMenuItem = 0;
		}
		else if (currentMenuItem < 0)
		{
			currentMenuItem = menuItems.length - 1;
		}
		if (Main.isDebugging)
		{
			trace(currentMenuItem);
		}
		menuItems.forEach(function(item:FlxText)
		{
			item.clearFormats();
			item.addFormat(unselectedTextFormat);
			if (item.ID == currentMenuItem)
			{
				if (Main.isDebugging)
				{
					trace("selected " + item.ID);
				}
				item.clearFormats();
				item.addFormat(selectedTextFormat);
			}
		});
	}
}
