package controller.base 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	/**
	 * Proxy to view for any controller
	 * @author Nicolas Bonnefoy
	 */
	public class Controller implements IController
	{
		private var _display:MovieClip;
		public var onReady:Signal;
		private var _isReady:Boolean;
		public var removed:Signal;
		
		//{ region Constructor
		
		public final function Controller(dsp:MovieClip) 
		{
			_display = dsp;
			_isReady = false;
			onReady = new Signal();
			removed = new Signal();
			if (_display.stage) {
				ready();
			}else {
				_display.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
			_display.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		//} endregion
		
		//{ region Public
		
		public function removeView():void {
			if (_display) {
				if (_display.parent) {
					_display.parent.removeChild(_display);
					removed.dispatch();
				}
			}
		}
		
		//} endregion
		
		//{ region Private
		
		protected function ready():void {
			_isReady = true;
			onReady.dispatch();
		}
		
		private function removedFromStageHandler(e:Event):void {
			_display.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			if (_display) {
				_display.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		private final function addedToStageHandler(e:Event):void {
			_display.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			ready();
		}
		//} endregion
		
		//{ region Accessors
		
		public function get display():MovieClip { return _display; }
		public function set display(value:MovieClip):void {
			_display = value;
		}
		
		public function get isReady():Boolean { return _isReady; }
		
		//} endregion
	}

}