package controller.popups.content {
	import com.gskinner.text.TextFlow;
	import controller.base.Controller;
	import controller.components.ImgAutoLoader;
	import controller.components.SimpleVideo;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	import vo.PoiData;
	
	/**
	 * Popup content for POI info
	 * @author Nicolas Bonnefoy
	 */
	public class PopupContentPoiInfo extends Controller
	{
		private var textFlow:TextFlow;
		private var _text:String = "";
		private var vid:SimpleVideo;
		public var image:ImgAutoLoader;
		public var poiData:PoiData;
		
		public var onChanged:Signal;
		
		//{ region Constructor
		
		public function PopupContentPoiInfo(poiData:PoiData) 
		{
			onChanged = new Signal();
			this.poiData = poiData;
			var DC_PopInfoContentView:Class = getDefinitionByName("PopInfoContentView") as Class;
			super(new DC_PopInfoContentView());
		}
		
		override protected function ready():void {
			textFlow = new TextFlow([display.text1, display.text2], _text);
			_text = poiData.desc;
			
			super.ready();
			
			updateText();
			image = new ImgAutoLoader(display.imgContainer, poiData.imgPath);
			image.onImgLoaded.addOnce(onChanged.dispatch);
			display.addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
		}
		
		//} endregion
		
		//{ region Private
		
		private function removedHandler(e:Event):void {
			display.removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			image.kill();
		}
		
		private function updateText():void {
			textFlow.text = _text;
			var resizableTf:TextField = display.text2;
			resizableTf.appendText(textFlow.getOverflow(1));
			resizableTf.autoSize = TextFieldAutoSize.LEFT;
			
			drawBg();
			onChanged.dispatch();
		}
		
		private function drawBg():void {
			display.graphics.clear();
			display.graphics.beginFill(0xF6F1E6, 1);
			display.graphics.drawRect(0, 0, display.width + 20, display.text2.y + display.text2.height + 10);
			display.graphics.endFill();
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			updateText();
		}
		
		//} endregion
		
	}

}