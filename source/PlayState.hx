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

		// test code for customers
		var customer:Customer = new Customer(50, "name", ["order", "topping"], 10);
		add(customer);
		customer.startTimer();
		var customer2 = new Customer(200, "bob", ["latte", "whipped cream"], 20);
		add(customer2);
		customer2.startTimer();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
