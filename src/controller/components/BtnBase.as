package controller.components 
{
	import com.rafaelrinaldi.sound.sound;
	import controller.base.Controller;
	import controller.base.IToolTip;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import helper.TextTools;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class BtnBase extends Controller
	{
		private static const OUT:String = "out";
		private static const OVER:String = "over";
		private static const DOWN:String = "down";
		private static const DISABLED:String = "disabled";
		
		public var clicked:Signal;
		public var over:Signal;
		public var out:Signal;
		public var down:Signal;
		public var up:Signal;
		public var toolTip:IToolTip;
		public var sndClick:String;
		
		private var _id:int;
		private var _enabled:Boolean = true;
		private var _label:String = "";
		
		//{ region Construcot
		
		public function BtnBase(dsp:MovieClip, id:int = -1, label:String = null) 
		{
			if (label) {
				_label = label;
			}
			_id = id;
			clicked = new Signal();
			over = new Signal();
			out = new Signal();
			down = new Signal();
			up = new Signal();
			sndClick = "snd_click";
			super(dsp);
		}
		
		override protected function ready():void {
			display.mouseChildren = false;
			updateState();
			updateLabel();
			addListeners();
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function attachToolTip(text:String):void {
			detachToolTip();
			toolTip = new AutoToolTip(display, text);
		}
		
		public function detachToolTip():void {
			if (toolTip) {
				toolTip.kill();
			}
		}
		
		public function kill():void {
			clicked.removeAll();
			removeListeners();
			super.removeView();
		}
		
		//} endregion
		
		//{ region Event Handlers
		private function addListeners():void {
			display.addEventListener(MouseEvent.CLICK, mouseEventHandler);
			display.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			display.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			display.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			display.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			
		}
		
		private function removeListeners():void {
			display.removeEventListener(MouseEvent.CLICK, mouseEventHandler);
			display.removeEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			display.removeEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			display.removeEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			display.removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		}
		
		//} endregion
		
		//{ region Protected
		
		protected function mouseEventHandler(e:MouseEvent):void {
			if (_enabled == false) {
				gotoLabel(DISABLED);
				return;
			}
			switch (e.type) {
				case MouseEvent.CLICK:
					clickHandler();
					gotoLabel(OVER);
				break;
				case MouseEvent.MOUSE_DOWN:
					gotoLabel(DOWN);
					down.dispatch();
				break;
				case MouseEvent.ROLL_OVER:
					over.dispatch();
					gotoLabel(OVER);
				break;
				case MouseEvent.MOUSE_UP:
					gotoLabel(OVER);
					up.dispatch();
				break;
				case MouseEvent.ROLL_OUT:
				default:
					out.dispatch();
					gotoLabel(OUT);
				break;
			}
		}
		
		protected function clickHandler():void {
			sound().item(sndClick).play();
			clicked.dispatch(_id);
		}
		
		/**
		 * Move to frame label
		 * @param	seq
		 */
		protected function gotoLabel(label:String):void {
			display.gotoAndPlay(label);
		}
		
		protected function updateState():void {
			if ( !display) {
				return;
			}
			display.buttonMode = display.useHandCursor = _enabled;
			_enabled == false ? gotoLabel(DISABLED) : gotoLabel(OUT);
		}
		
		protected function updateLabel():void {
			if (display && display.txt) {
				if (_label.length == 0) {
					return;
				}
				var rect:Rectangle = display.txt.getRect(display).clone();
				TextField(display.txt).htmlText = _label;
				TextTools.fitTextIn(display.txt, rect.width);
				TextTools.vAlign(display.txt, rect);
			}
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			_enabled = value;
			updateState();
		}
		
		public function get label():String { return _label; }
		public function set label(value:String):void {
			_label = value;
			updateLabel();
		}
		
		public function get id():int { return _id; }
		
		//} endregion
		
	}

}