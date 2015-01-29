package controller.components 
{
	import flash.display.Shape;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class MiniMapPoint 
	{
		private var alpha:Number = 0.7;
		private var radius:int = 4;
		private var line:int = 1;
		
		public var display:Shape;
		public var poi:PointOfInterest;
		
		//{ region Constructor
		
		public function MiniMapPoint(poi:PointOfInterest) 
		{
			this.poi = poi;
			display = new Shape();
			draw();
			poi.onFocusIn.addOnce(poiFocusInHandler);
		}
		
		//} endregion
		
		//{ region Public
		
		public function kill():void {
			poi.onFocusIn.remove(poiFocusInHandler);
			poi.onFocusOut.addOnce(poiFocusOutHandler);
			poi = null;
		}
		
		//} endregion
		
		//{ region Private
		private function poiFocusInHandler(poiId:uint):void {
			if (!poi) { return };
			poi.onFocusOut.addOnce(poiFocusOutHandler);
			alpha = 1;
			radius = 6;
			line = 2;
			draw();
			display.parent.setChildIndex(display, display.parent.numChildren-1);
		}
		
		private function poiFocusOutHandler(poiId:uint):void {
			if (!poi) { return };
			poi.onFocusIn.addOnce(poiFocusInHandler);
			alpha = 0.7;
			radius = 4;
			line = 1;
			draw();
		}
		
		private function draw():void {
			display.graphics.clear();
			display.graphics.lineStyle(line, 0, 1);
			display.graphics.beginFill(0xFF1A00, alpha);
			display.graphics.drawCircle(0, 0, radius);
			display.graphics.endFill();
		}
		
		//} endregion
		
	}

}