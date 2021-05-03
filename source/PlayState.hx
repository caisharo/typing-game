package;

import flixel.FlxState;

class PlayState extends FlxState
{
	var hud:HUD;
	var day:Int;
	var money:Int;

	override public function create()
	{
		super.create();

		var hud = new HUD();
		add(hud);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
