package controller.base 
{
	import flash.display.MovieClip;
	
	/**
	 * Proxy to view for any controller
	 * @author Nicolas Bonnefoy
	 */
	public interface IController
	{
		function get display():MovieClip;
		function set display(value:MovieClip):void;
		
		function removeView():void
		function get isReady():Boolean
	}
	
}