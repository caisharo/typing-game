package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// Pretty much same as BasicMenuState, but needed one for SubStates too
// Not sure if there's a better way to not have duplicated code
// Menus should extend this to have menu "buttons" selectable using keyboard
// Classes that extend should do something like this in create():
// menuItems = new FlxTypedGroup<FlxText>();
// addMenuItem("Name", function);
class BasicMenuSubState extends FlxSubState
{
	// Stuff for menu "buttons"
	var yShift = 400; // how much to move everything down by
	var yGap = 50; // gap between menu items
	var fontSize = 30;
	var currentMenuItem = 0;
	var menuItems:FlxTypedGroup<FlxText>;
	var menuFunctions:Array<Void->Void> = [];
	var selectedTextFormat = new FlxTextFormat(FlxColor.WHITE, true, false, FlxColor.BLACK);
	var unselectedTextFormat = new FlxTextFormat(FlxColor.GRAY, false, false);

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var pressedUp = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
		var pressedDown = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
		if (pressedDown && !pressedUp)
		{
			// Go to next input field
			changeSelected(1);
		}
		if (pressedUp && !pressedDown)
		{
			// Go to previous input field
			changeSelected(-1);
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
		newMenuItem.ID = menuItems.length;
		newMenuItem.screenCenter();
		newMenuItem.y = yShift + (yGap * menuItems.length);

		if (menuItems.length == 0)
		{
			newMenuItem.addFormat(selectedTextFormat);
		}
		else
		{
			newMenuItem.addFormat(unselectedTextFormat);
		}

		menuItems.add(newMenuItem);
		add(newMenuItem);

		// Add function to array
		menuFunctions.push(menuFunction);
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

		menuItems.forEach(function(item:FlxText)
		{
			if (item.ID == currentMenuItem)
			{
				item.addFormat(selectedTextFormat);
			}
			else
			{
				item.addFormat(unselectedTextFormat);
			}
		});
	}
}
