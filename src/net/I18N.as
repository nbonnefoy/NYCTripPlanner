package net 
{
	import flash.display.Sprite;
	import helper.LoaderHelper;
	import org.osflash.signals.Signal;
	/**
	 * Utility to manage localized strings.
	 * XML provided must follow the scheme below :
	 * <data>
	 * 		<str key="stingKey"><![CDATA[String Value]]></str>
	 * <data/>
	 * @author Nicolas Bonnefoy
	 */
	public class I18N
	{
		private static const fileNamePrefix:String = "strings_";
		private static const fileExt:String = ".xml";
		
		public static var isReady:Boolean = false;
		public static var onReady:Signal;
		
		private static var _currentLocale:String;
		private static var filePath:String;
		private static var strXML:XML;
		
		
		//-----------------------------------------
		// Public
		//-----------------------------------------
		
		/**
		 * Load Localization file
		 * @param	locale
		 * @param	path
		 * @return ready Signal
		 */
		public static function load(locale:String, path:String = ""):Signal {
			_currentLocale = locale;
			if (path.length > 0) {
				filePath = path;
			}
			var url:String = filePath + fileNamePrefix + _currentLocale + fileExt;
			var dataLoader:LoaderHelper = new LoaderHelper();
			onReady = new Signal();
			isReady = false;
			dataLoader.callback.addOnce(strXMLLoadCompleteHandler);
			dataLoader.load(url);
			return onReady;
		}
		
		public static function getString(key:String):String {
			if (isReady == false) {
				throw new Error("I18N Error : XML file not loaded yet", 181818);
			}
			return String(strXML.str.(@key == key)[0]);
		}
		
		// Private
		//-----------------------------------------
		private static function strXMLLoadCompleteHandler(data:*):void {
			strXML = new XML(data);
			isReady = true;
			onReady.dispatch();
		}
		
		static public function get currentLocale():String { return _currentLocale; }
		
		
	}

}