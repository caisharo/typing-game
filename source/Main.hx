package;

import cse481d.logging.CapstoneLogger;
import flixel.FlxGame;
import hscript.Expr.VarDecl;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var logger:CapstoneLogger;

	public function new()
	{
		super();

		var gameId:Int = 202105;
		var gameName:String = "typing";
		var gameKey:String = "79a131f53a8376e7c93e04af79a0b81c";
		var categoryId:Int = 1;
		Main.logger = new CapstoneLogger(gameId, gameName, gameKey, categoryId);

		// Get user
		var userId:String = Main.logger.getSavedUserId();
		if (userId == null)
		{
			userId = Main.logger.generateUuid();
			Main.logger.setSavedUserId(userId);
		}
		Main.logger.startNewSession(userId, this.onSessionReady);
	}

	function onSessionReady(sessionRecieved:Bool):Void
	{
		addChild(new FlxGame(0, 0, MenuState));
	}
}
