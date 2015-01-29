package helper 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import manager.GlobalErrorHandler;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class DisplayLoaderHelper implements ILoaderHelper
	{
		private var loader:Loader;
		private var url:String;
		private var tryCount:int = 0;
		
		private var _callback:Signal
		private var _loaded:Boolean = false;
		
		public function DisplayLoaderHelper() 
		{
			Security.allowDomain('*');
			Security.allowInsecureDomain('*');
			
			tryCount = 0;
		}
		
		//{ region Public
		
		/**
		 * Load any object
		 * @param	url
		 */
		public function load(url:String):void {
			this.url = url;
			var urlRequest:URLRequest = new URLRequest(url);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
           
			var context:LoaderContext = new LoaderContext( true, ApplicationDomain.currentDomain);
			//context.allowCodeImport = true;
			
			try {
				loader.load(urlRequest, context);
			}catch (err:Error) {
				trace("DisplayLoaderHelper : load error : " + err.errorID + err.message);	
				errorHandler(err);
			}
			
		}
		
		public function getRatio():Number {
			if (!loader) {
				return 0;
			}
			if (_loaded) {
				return 1;
			}
			return loader.contentLoaderInfo.bytesLoaded / loader.contentLoaderInfo.bytesTotal;
		}
		
		//} endregion
		
		//{ region Private
		
		private function loadCompleteHandler(e:Event):void {
			_loaded = true;
			tryCount = 0;
			callback.dispatch(loader.content);
		}
		
		/**
		 * Try 3 time to reload and kill
		 * @param	e
		 */
		private function errorHandler(e:*):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			if (tryCount < 3) {
				tryCount++;
				load(url);
			}else {
				tryCount = 0;
				trace("DisplayLoaderHelper : IO error FATAL [" + url +"] " + e);
				GlobalErrorHandler.dispatch(e, "Error loading " + url);
			}
		}
		
		//} endregion
		
		//{ region Accessors
		public function get callback():Signal {
			!_callback ? _callback = new Signal():void;
			return _callback;
		}
		
		public function get loaded():Boolean {
			return _loaded;
		}
		
		//} endregion
		
	}

}