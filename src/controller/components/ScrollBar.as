package controller.components 
{
	import behaviors.DragInput;
	import controller.base.Controller;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ScrollBar extends Controller
	{
		private const overColor:uint = 0xF6F1E6;
		private const upColor:uint = 0xE7E3DA;
		private const downColor:uint = 0xD7CFBF;
		
		private var thumbColor:uint = upColor;
		private var mouseIsOver:Boolean;
		private var thumb:Sprite;
		private var thumbRect:Rectangle;
		
		public var dragInput:DragInput;
		public var onDrag:Signal;
		
		//{ region Constructor
		
		public function ScrollBar(mc:MovieClip) 
		{
			onDrag = new Signal(Rectangle);
			super(mc);
		}
		
		override protected function ready():void {
			//setup view guizmo
			thumbRect = new Rectangle(0,0,12,50);
			thumb = new Sprite();
			mouseIsOver = false;
			thumb.addEventListener(MouseEvent.ROLL_OVER, thumbRollOverHandler);
			thumb.addEventListener(MouseEvent.ROLL_OUT, thumbRollOutHandler);
			thumb.useHandCursor = thumb.buttonMode = true;
			
			display.addChild(thumb);
			drawThumb();
			
			initListeners();
			trace("scroll bar ready");
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function kill():void {
			dragInput.kill();
			onDrag.removeAll();
			if (thumb) {
				thumb.removeEventListener(MouseEvent.ROLL_OVER, thumbRollOverHandler);
				thumb.removeEventListener(MouseEvent.ROLL_OUT, thumbRollOutHandler);
				display.removeChild(thumb);
				thumb = null;
			}
			
		}
		
		/**
		 * Update position and size from ratio
		 * @param	ratioRect
		 */
		public function setRatioRect(ratioRect:Rectangle):void {
			dragInput.setRatioRect(ratioRect);
			updateRect();
			drawThumb();
		}
		
		//} endregion
		
		//{ region Private
		
		private function thumbRollOutHandler(e:MouseEvent):void {
			mouseIsOver = false;
			thumbColor = upColor;
			drawThumb();
		}
		
		private function thumbRollOverHandler(e:MouseEvent):void {
			mouseIsOver = true;
			thumbColor = overColor;
			drawThumb();
		}
		
		private function initListeners():void {
			dragInput = new DragInput(thumb, new Rectangle(0,0,display.width, display.height));
			dragInput.useSmoothRelease = false;
			dragInput.onDrag.add(dragHandler);
			dragInput.onRelease.add(releaseHandler);
		}
		
		private function releaseHandler():void {
			thumbColor = mouseIsOver ? overColor : upColor;
			drawThumb();
		}
		
		private function dragHandler():void {
			thumbColor = downColor;
			updateRect();
			drawThumb();
			onDrag.dispatch(dragInput.getRatioRect());
		}
		
		private function updateRect():void {
			thumbRect.y = dragInput.dragRect.y;
			thumbRect.x = dragInput.dragRect.x;
			thumbRect.width = dragInput.dragRect.width;
			thumbRect.height = dragInput.dragRect.height;
		}
		
		/**
		 * Draw guizmo rectangle over mini map
		 */
		private function drawThumb():void {
			thumb.graphics.clear();
			thumb.graphics.lineStyle(1, 0x2B241E, 0.6, true);
			thumb.graphics.drawRect(thumbRect.x, thumbRect.y, thumbRect.width, thumbRect.height);
			thumb.graphics.lineStyle(1, 0xffffff, 0.9, true);
			thumb.graphics.beginFill(thumbColor, 1);
			thumb.graphics.drawRect(thumbRect.x+1, thumbRect.y+1, thumbRect.width-2, thumbRect.height-2);
			thumb.graphics.endFill();
		}
		
		//} endregion
	}

}