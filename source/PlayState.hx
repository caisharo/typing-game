package;

import flixel.FlxState;

class PlayState extends FlxState
{
	var hud:HUD;
	var day:Int;
	var money:Int;
	var playerInput:PlayerInput;

	override public function create()
	{
		super.create();

		hud = new HUD();
		add(hud);

		playerInput = new PlayerInput();
		add(playerInput);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
