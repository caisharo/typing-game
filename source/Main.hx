package;

import cse481d.logging.CapstoneLogger;
import flixel.FlxG;
import flixel.FlxGame;
import hscript.Expr.VarDecl;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var logger:CapstoneLogger;
	public static var isLogging = true; // just in case we don't want to log when we're debugging or something?
	public static var isDebugging = true; // for traces

	public function new()
	{
		super();

		var gameId:Int = 202105;
		var gameName:String = "typing";
		var gameKey:String = "79a131f53a8376e7c93e04af79a0b81c";
		var categoryId:Int = 1;
		// categoryId: A number you assign to help categorize data from different releases for your game.
		// debugging = 1
		// release to family/friends = 2, (NOTE: 2 will be our restricted itch.io family/friends)
		// release it to a public website = 3 (NOTE: IGNORE 3 - failed initial itch.io)
		// 5/11 playtesting = 4
		// IMPORTANT: Change this when you have a new version of your game! (We will probably increase by 10 each version?)

		if (Main.isLogging)
		{
			Main.logger = new CapstoneLogger(gameId, gameName, gameKey, categoryId);

			// Get user saved id (if possible - need to check in case user blocks third-party cookies)
			try
			{
				var userId:String = Main.logger.getSavedUserId();
				if (userId == null)
				{
					userId = Main.logger.generateUuid();
					Main.logger.setSavedUserId(userId);
				}
				Main.logger.startNewSession(userId, this.onSessionReady);
			}
			catch (e)
			{
				var userId = Main.logger.generateUuid();
				Main.logger.startNewSession(userId, this.onSessionReady);
			}
		}
		else
		{
			addChild(new FlxGame(0, 0, MenuStateTutorialForced));
		}
	}

	function onSessionReady(sessionRecieved:Bool):Void
	{
		addChild(new FlxGame(0, 0, MenuStateTutorialForced));
	}
}
