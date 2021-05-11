package;

import cse481d.logging.CapstoneLogger;
import flixel.FlxGame;
import hscript.Expr.VarDecl;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var logger:CapstoneLogger;
	public static var isLogging = true; // just in case we don't want to log when we're debugging or something?

	public function new()
	{
		super();

		var gameId:Int = 202105;
		var gameName:String = "typing";
		var gameKey:String = "79a131f53a8376e7c93e04af79a0b81c";
		var categoryId:Int = 1;
		// categoryId: A number you assign to help categorize data from different releases for your game.
		// debugging = 1
		// release to family/friends = 2,
		// release it to a public website = 3.
		// IMPORTANT: Change this when you have a new version of your game! (We will probably increase by 10 each version?)

		if (Main.isLogging)
		{
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
		else
		{
			addChild(new FlxGame(0, 0, MenuState));
		}
	}

	function onSessionReady(sessionRecieved:Bool):Void
	{
		addChild(new FlxGame(0, 0, MenuState));
	}
}
