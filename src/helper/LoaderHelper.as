package helper 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import manager.GlobalErrorHandler;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class LoaderHelper implements ILoaderHelper
	{
		private var loader:URLLoader;
		private var url:String;
		private var tryCount:int = 0;
		
		private var _callback:Signal
		private var _loaded:Boolean = false;
		
		public function LoaderHelper() 
		{
			tryCount = 0;
		}
		
		//{ region Public
		
		public function post(url:String, data:Object):void {
			this.url = url;
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.contentType = "application/json" ;
			urlRequest.data = JSON.stringify(data) ;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			try {
				loader.load(urlRequest);
			}catch (err:Error){
				errorHandler(err);
			}
		}
		
		/**
		 * Load any object
		 * @param	url
		 */
		public function load(url:String):void {
			this.url = url;
			var urlRequest:URLRequest = new URLRequest(url);
			loader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			try {
				loader.load(urlRequest);
			}catch (err:Error){
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
			return loader.bytesLoaded / loader.bytesTotal;
		}
		
		//} endregion
		
		//{ region Private
		
		private function loadCompleteHandler(e:Event):void {
			if (checkResponseError(String(loader.data))){
				errorHandler(loader.data);
			}else {
				_loaded = true;
				tryCount = 0;
				callback.dispatch(loader.data);
			}
		}
		
		private function checkResponseError(data:String):Boolean {
			var hasError:Boolean = false;
			try {
				var obj:Object = JSON.parse(data);
				if (obj.code != 200) {
					if (obj.message) {
						if ((obj.message.search("Error") != -1) || (obj.message.search("error") != -1)) {
							hasError = true;
						}
					}
				}
			}catch (err:Error) {
				hasError = false;
			}
			return hasError;
		}
		
		/**
		 * Try 3 time to reload and kill
		 * @param	e
		 */
		private function errorHandler(e:*):void {
			loader.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			if (tryCount < 3) {
				tryCount++;
				load(url);
			}else {
				tryCount = 0;
				GlobalErrorHandler.dispatch(e, "Error loading " + url);
				//GameManager.getInstance().displayErrorFn();
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