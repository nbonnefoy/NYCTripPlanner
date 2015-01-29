package controller.base 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public interface IToolTip 
	{
		function get text():String;
		function set text(value:String):void;
		function get display():Sprite;
		function set display(value:Sprite):void;
		function get isDisplayed():Boolean;
		function set isDisplayed(value:Boolean):void;
		function show():void;
		function hide():void;
		function kill():void;
		function updatePosition():void;
	}
	
}