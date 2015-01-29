package helper 
{
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public interface ILoaderHelper 
	{
		function getRatio():Number;
		function load(url:String):void;
		function get callback():Signal;
		function get loaded():Boolean;
	}
	
}