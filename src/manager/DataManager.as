package manager
{
	import com.rafaelrinaldi.sound.sound;
	import flash.net.SharedObject;
	import helper.LoaderHelper;
	import org.osflash.signals.Signal;
	import vo.PoiData;

	/**
	 * Data manager centralize game state data, user data and data from server
	 * @author Nicolas Bonnefoy
	 */
	public class DataManager {
		
		/* Auto Déclaration */
		private static var instance:DataManager;
		private static var localCall:Boolean;
		
		/* callback */
		public var onReady:Signal;
		public var isReady:Boolean = false;
		
		private var _soundEnabled:Boolean;
		private var soundLocalSave:SharedObject;
		private var ldr:LoaderHelper;
		
		private var poisDescXML:XML;
		
		/**
		* Return the unique instance of the class
		*/
		public static function getInstance():DataManager {
			if (instance == null) {
				localCall = true;
				instance = new DataManager();
				localCall = false;
			}
			return instance;
		}
		
		/**
		* CONSTRUCTOR This class is a Singleton, use getInstance()
		*/
		public function DataManager ():void {
			if (!localCall) {
				throw new Error("Error: Instantiation not allowed : Use DataManager.getInstance() instead of new.");
			}else {
				
				/* sound Shared Object */
				soundLocalSave = SharedObject.getLocal("snd_moneydrop");
				if (soundLocalSave.data.snd == undefined) {
					soundEnabled = true;
				}else {
					soundEnabled = soundLocalSave.data.snd;
				}
				/* callbacks */
				onReady = new Signal();
			}
		}
		
		/**
		 * Load configs setup
		 */
		public function init():Signal {
			ldr = new LoaderHelper();
			ldr.callback.addOnce(function (data:*):void {
				poisDescXML = new XML(data);
				isReady = true;
				onReady.dispatch();
			});
			ldr.load("data/poisDesc.xml");
			return onReady;
		}
		
		/**
		 * get PoiData by name
		 * @param	poiName
		 * @return PoiData
		 */
		public function getPoiData(poiName:String):PoiData {
			return new PoiData(poisDescXML.item.(@name == poiName)[0]);
		}
		
		public static function kill():void {
			instance = null;
		}
		
		/* stores sound status in shared object on change */
		public function get soundEnabled():Boolean { return _soundEnabled; }
		public function set soundEnabled(value:Boolean):void {
			_soundEnabled = value;
			soundLocalSave.data.snd = _soundEnabled;
			value ? sound().global().unmute() : sound().global().mute();
		}
	}
}