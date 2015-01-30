package helper 
{
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class console 
	{
		
		public function console() 
		{
			
		}
		
		/**
		 * Send a message to console.log to javascript
		 */
		public static function log(message:*):void {
			if ( ExternalInterface.available ) {
				ExternalInterface.call("console.log", "[Flash said] : " + String(message));
			}else {
				trace(message);
			}
		}
		
	}

}