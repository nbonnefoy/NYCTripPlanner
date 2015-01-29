package manager {
	import com.rafaelrinaldi.sound.sound;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.text.Font;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import helper.DisplayLoaderHelper;
	import helper.ILoaderHelper;
	import helper.LoaderHelper;
	import helper.SpriteSheet;
	import org.osflash.signals.Signal;

	/**
	 * Asset Manager load and store assets reference.
	 * Used to access assets at anytime from everywhere in the program.
	 * @author Nicolas Bonnefoy
	 */
	public class AssetManager {
	
		/* Auto Déclaration */
		private static var instance:AssetManager;
		private static var localCall:Boolean;
		
		public var onReady:Signal;
		public var isReady:Boolean = false;
		
		public var lastLoadingName:String = '';
		private var loadingQueue:Array;
		private var lastLoadingQueueLength:int;
		private var ldr:ILoaderHelper;
		private var spriteSheets:Vector.<SpriteSheet> = new Vector.<SpriteSheet>();
		
		private var images:Dictionary = new Dictionary();
		private var swfs:Dictionary = new Dictionary();
		private var fonts:Dictionary = new Dictionary();
		
		/**
		* Return the unique instance of the class
		*/
		public static function getInstance():AssetManager {
			if (instance == null) {
				localCall = true;
				instance = new AssetManager();
				localCall = false;
			}
			return instance;
		}
		
		/**
		* CONSTRUCTOR This class is a Singleton, use getInstance()
		*/
		public function AssetManager ():void {
			if (!localCall) {
				throw new Error("Error: Instantiation not allowed : Use AssetManager.getInstance() instead of new.");
			} else {
				onReady = new Signal();
			}
		}
		
		//{ region Public
		
		/**
		 * Init Class, load all assets
		 * @return onReady Signal
		 */
		public function init():Signal {
			var imgPath:String = "assets/"
			loadingQueue = [
				["bmp", "map25", imgPath + "map25.jpg"],
				["bmp", "map50", imgPath + "map50.jpg"],
				["bmp", "map100", imgPath + "map100.jpg"],
				["bmp", "miniMap", imgPath + "miniMap.jpg"],
				["swf", "assets", imgPath + "assets.swf"],
				["bmp", "ssPois", imgPath + "ssPois.png"],
				["sprt", "ssPois", imgPath + "ssPois.json"],
				["bmp", "flare1", imgPath + "flare1.png"],
				["bmp", "flare2", imgPath + "flare2.png"],
				["bmp", "flare3", imgPath + "flare3.png"]
			];
			lastLoadingQueueLength = loadingQueue.length;
			
			chainLoad(loadingQueue, assetsLoadedHandler);
			
			return onReady;
		}
		
		/**
		 * Destroy Singleton instance
		 */
		public static function kill():void {
			instance = null;
		}
		
		public function getSprite(name:String):BitmapData {
			for (var i:int = 0; i < spriteSheets.length; i++) {
				if (spriteSheets[i].hasSprite(name)) {
					return spriteSheets[i].getSpriteByName(name);
				}
			}
			trace('Sprite ', name, ' is not registered');
			return null;
		}
		
		public function getImage(name:String):Bitmap {
			if (images[name] == null) {
				trace('Image ', name, ' is not registered');
				return null;
			}
			return images[name] as Bitmap;
		}
		
		public function getSwf(name:String):MovieClip {
			if (swfs[name] == null) {
				trace('Image ', name, ' is not registered');
				return null;
			}
			return swfs[name] as MovieClip;
		}
		
		public function getFontName(name:String):String {
			if (fonts[name] == null) {
				trace('Font ', name, ' is not registered');
				return null;
			}
			return (fonts[name] as Font).fontName;
		}
		
		public function getLoadingProgress():Number
		{
			var prevComplete:Number = (lastLoadingQueueLength - loadingQueue.length) - 1;
			trace(prevComplete);
			return (prevComplete + ldr.getRatio()) / lastLoadingQueueLength;
		}
		
		//} endregion
		
		//{ region Private
		
		/**
		 * Images loaded, dipatch onReady Signal
		 */
		private function assetsLoadedHandler():void {
			initFonts();
			isReady = true;
			loadSound();
			onReady.dispatch();
		}
		
		/**
		 * Register loaded fonts
		 */
		private function initFonts():void {
			var TextFontClass:Class = getDefinitionByName("TextFont") as Class;
			var TitleFontClass:Class = getDefinitionByName("TitleFont") as Class;
			fonts["TextFont"] = new TextFontClass() as Font;
			fonts["TitleFont"] = new TitleFontClass() as Font;
			
			Font.registerFont(getDefinitionByName("TextFont") as Class);
			Font.registerFont(getDefinitionByName("TitleFont") as Class);
		}
		
		/**
		 * Load images recursively
		 * @param	list
		 * @param	res
		 */
		private function chainLoad(list:Array, res:Function):void {
			if (list.length <= 0) {
				res.apply();
				return;
			}
			var itm:Array = list.shift();
			
			//select type of loader (txt or display)
			if (itm[0] == "sprt") {
				ldr = new LoaderHelper();
			}else {
				ldr = new DisplayLoaderHelper();
			}
			
			lastLoadingName = itm[1];
			
			ldr.callback.addOnce(function (data:*):void {
				trace("---loaded " + itm[0] + itm[1]);
				switch (itm[0]) 
				{
					case "bmp":
						//store bitmaps
						images[itm[1]] = data;
					break;
					case "swf":
						//store swfs
						swfs[itm[1]] = data;
					break;
					case "sprt":
						//store spritesheets (must have loaded bmp before json in queue)
						spriteSheets.push(new SpriteSheet(getImage(itm[1]).bitmapData, data));
					break;
				default:
					break;
				}
				
				chainLoad(list, res);
			});
			
			ldr.load(itm[2]);
		}
		
		/**
		 * setup sounds
		 */
		private function loadSound():void {
			sound().group("music").add("main").load("assets/music/main_theme.mp3");
			sound().add("snd_click", "SndClick");
			sound().add("snd_grow", "SndGrow");
			sound().add("snd_reduce", "SndReduce");
			sound().add("snd_slide", "SndSlide");
			sound().add("snd_popIn", "SndPopIn");
			sound().add("snd_popOut", "SndPopOut");
			sound().add("snd_hint", "SndHint");
			sound().add("snd_magic", "SndMagic");
		}
		
		//} endregion
	}
}