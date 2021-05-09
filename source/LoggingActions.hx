package;

class LoggingActions
{
	// Feel free to add more but DO NOT change existing values!!!
	//
	// logActionWithNoLevel
	//
	// Menu presses - log {pressed: "what", from: "where"}
	public static var PRESS_START:Int = 1;
	public static var PRESS_TUTORIAL:Int = 2;
	public static var PRESS_NEXT_LEVEL:Int = 3;
	public static var PRESS_RETURN_TO_MENU:Int = 4;
	// public static var PRESS_PAUSE:Int = 5;
	// public static var PRESS_OPTIONS:Int = 6;
	//
	// Skipping some numbers in case we add more menus
	//
	// logLevelAction
	//
	// Customer satisfaction - log {day: day, customer_state: "state", percent_matched: percent, matched: "field: expected;", failed: "field: expected, actual;"}
	public static var HAPPY_CUSTOMER:Int = 10;
	public static var SATISFIED_CUSTOMER:Int = 11;
	public static var ANGRY_CUSTOMER:Int = 12; // only from incorrect matching
	public static var ANGRY_NO_PATIENCE:Int = 13; // angry customer due to running out of patience - log {day: day, customer_state: "state", order: "order"}
	//
	public static var NO_CUSTOMER_SELECTED:Int = 20;
	public static var SHOW_ORDER_AGAIN:Int = 21; // {day: day, customer_position: number}

	public function new() {}
}
