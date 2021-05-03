package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayerInput extends FlxTypedGroup<FlxSprite>
{
	var yShift = 150; // how much to move everything down by
	var currentField = -1;
	var fields:FlxTypedGroup<FlxUIInputText>;
	var labels:Array<String> = [];
	var submitText:FlxText;

	public function new()
	{
		super();

		submitText = new FlxText(0, 0, 0, "PRESS ENTER TO COMPLETE ORDER", 15);
		submitText.screenCenter();
		submitText.y += yShift + 20;
		add(submitText);

		fields = new FlxTypedGroup<FlxUIInputText>();
		currentField = 0;
		addInputField("Name");
		addInputField("Order");
		addInputField();
	}

	override public function update(elapsed:Float)
	{
		var pressedTab = FlxG.keys.justPressed.TAB;
		var pressedShift = FlxG.keys.justPressed.SHIFT;
		var pressedEnter = FlxG.keys.justPressed.ENTER;
		if (pressedTab)
		{
			trace("tab");
			changeSelected(1);
		}
		if (pressedShift)
		{
			trace("shift");
			changeSelected(-1);
		}
		if (pressedEnter)
		{
			trace("enter");
			fields.forEach(function(item:FlxUIInputText)
			{
				trace(labels[item.ID] + ": " + item.text);
			});
		}
		super.update(elapsed);
	}

	function addInputField(label:String = "Label")
	{
		labels.push(label);

		var newField = new FlxUIInputText();
		newField.filterMode = FlxInputText.ONLY_ALPHA;
		newField.forceCase = FlxInputText.LOWER_CASE;
		newField.ID = fields.length;
		newField.screenCenter();
		newField.y += yShift + (20 * fields.length);

		var fieldLabel = new FlxText(0, 0, 0, label, 15);
		fieldLabel.screenCenter();
		fieldLabel.x = newField.x - 75;
		fieldLabel.y += yShift + (20 * fields.length);
		add(fieldLabel);

		if (fields.length == 0)
		{
			newField.hasFocus = true;
			newField.backgroundColor = FlxColor.YELLOW;
		}

		fields.add(newField);
		add(newField);

		submitText.y += 20;
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
				trace(item.ID + " is focused");
			}
			else
			{
				item.hasFocus = false;
				item.backgroundColor = FlxColor.WHITE;
			}
		});
	}
}
