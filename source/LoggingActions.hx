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
	public static var PRESS_PAUSE:Int = 5;
	public static var PRESS_TUTORIAL_PAUSE:Int = 6;
	public static var PRESS_SHOP:Int = 7;
	// public static var PRESS_OPTIONS:Int = 8;  // not used yet - this one is ok to change
	//
	// Tutorial levels
	public static var PRESS_INTRO:Int = -1;
	public static var PRESS_SELECT:Int = -2;
	public static var PRESS_TYPE:Int = -3;
	//
	// logLevelAction
	//
	// Customer satisfaction - log {day: day, customer_state: "state", percent_matched: percent, matched: "field: expected; ", failed: "field: expected, actual; "}
	public static var HAPPY_CUSTOMER:Int = 10;
	public static var SATISFIED_CUSTOMER:Int = 11;
	public static var ANGRY_CUSTOMER:Int = 12; // only from incorrect matching
	public static var ANGRY_NO_PATIENCE:Int = 13; // angry customer due to running out of patience - log {day: day, customer_state: "state", order: "order"}
	//
	public static var NO_CUSTOMER_SELECTED:Int = 20;
	public static var SHOW_ORDER_AGAIN:Int = 21; // {day: day, customer_position: number, order: name,order}
	public static var SWITCH_CUSTOMER:Int = 22; // {from: null/old customer position, to: new customer position}
	//
	// Shop stuff
	public static var BOUGHT_ITEM:Int = 30; // {previous_balance: money, item_name: "Name", item_price: price: total_owned: number}

	public function new() {}
}
