package controller.components 
{
	import controller.base.Controller;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import helper.TextTools;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class TripListItem extends Controller
	{
		public var poi:PointOfInterest;
		public var image:ImgAutoLoader;
		public var iconOver:MovieClip;
		public var onClick:Signal;
		
		//{ region Constructor
		
		public function TripListItem(poi:PointOfInterest) 
		{
			onClick = new Signal();
			this.poi = poi;
			
			var DC_TripListItemView:Class = getDefinitionByName("TripListItemView") as Class;
			super(new DC_TripListItemView());
		}
		
		override protected function ready():void {
			
			var rect:Rectangle = display.txt.getRect(display).clone();
			TextField(display.txt).text = poi.data.title;
			TextTools.fitTextIn(display.txt, rect.width);
			TextTools.vAlign(display.txt, rect);
			image = new ImgAutoLoader(display.imgContainer, poi.data.imgPath);
			iconOver = display.iconOver;
			iconOver.visible = false;
			
			display.buttonMode = display.useHandCursor = true;
			display.mouseChildren = false;
			initListeners();
			
			super.ready();
		}
		
		//} endregion
		
		//{ region Private
		
		private function initListeners():void {
			display.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			display.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			display.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		//{ region Detect click VS Drag event
		
		private function mouseDownHandler(e:MouseEvent):void {
			display.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			display.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			display.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(e:MouseEvent):void {
			onClick.dispatch(poi.getScaledCenterPosition());
			//reset events
			display.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			display.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			display.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		/**
		 * Mouse moved betwen down and up -> scroll detected, cancel click
		 * @param	e
		 */
		private function mouseMoveHandler(e:MouseEvent):void {
			display.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			display.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			display.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		//} endregion
		
		private function rollOutHandler(e:MouseEvent):void {
			poi.focused = false;
			iconOver.visible = false;
		}
		
		private function rollOverHandler(e:MouseEvent):void {
			poi.focused = true;
			iconOver.visible = true;
		}
		
		//} endregion
		
	}

}