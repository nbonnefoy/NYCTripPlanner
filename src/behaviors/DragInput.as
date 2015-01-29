package behaviors 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class DragInput 
	{
		
		public var onDrag:Signal;
		public var onRelease:Signal;
		private var relativePos:Rectangle;
		
		private var _useSmoothRelease:Boolean = true;
		private var _reverseControl:Boolean = false;
		
		private var velocity:Number = 0.1;
		private var container:DisplayObjectContainer;
		private var _boundRect:Rectangle;
		public var dragRect:Rectangle;
		
		private var oPos:Point = new Point(); // original position on start drag
		private var lPos:Point = new Point(); // last drag update postion
		private var tPos:Point = new Point(); // target postion on drag update
		private var prevPos:Point = new Point(); //position before drag
		private var translation:Point;
		private var releaseTween:TweenLite;
		public var mouseCaptureLayer:Sprite;
		
		//{ region constructor
		
		public function DragInput(container:DisplayObjectContainer, boundaries:Rectangle, mouseCaptureLayer:Sprite = null) 
		{
			this.container = container;
			_boundRect = boundaries;
			dragRect = new Rectangle(container.x, container.y, container.width, container.height);
			onDrag = new Signal();
			onRelease = new Signal();
			relativePos = new Rectangle(0,0,1,1); //relative rect to be dragged
			
			if (mouseCaptureLayer == null) {
				this.mouseCaptureLayer = container as Sprite;
			}else {
				this.mouseCaptureLayer = mouseCaptureLayer;
			}
			initListeners();
		}
		
		//} endregion
		
		//{ region Public
		
		public function kill():void {
			if (releaseTween) {
				releaseTween.kill();
			}
			onDrag.removeAll();
			onRelease.removeAll();
		}
		
		public function updateContainer(target:DisplayObjectContainer):void {
			this.container = target;
			dragRect.width = target.width;
			dragRect.height = target.height;	
		}
		
		/**
		 * Recalculate relatives values when boundaries changed
		 * @param	boundaries
		 */
		public function updateBoundaries(newBoundRect:Rectangle):void {
			if (_boundRect.isEmpty()) {
				_boundRect = newBoundRect;
				return;
			}
			
			//calculate relative coord of prev situation
			var rx:Number = (dragRect.x + dragRect.width/2) / _boundRect.width;
			var ry:Number = (dragRect.y + dragRect.height/2 ) / _boundRect.height;
			//replace target rect coord relative to new boundaries
			dragRect.x = Math.max(newBoundRect.x, Math.min(newBoundRect.width * rx - dragRect.width / 2, newBoundRect.width - dragRect.width));
			dragRect.y = Math.max(newBoundRect.y, Math.min(newBoundRect.height * ry - dragRect.height / 2, newBoundRect.height - dragRect.height));
			
			_boundRect = newBoundRect.clone();
			prevPos = dragRect.topLeft.clone();
			oPos = tPos.clone();
		}
		
		/**
		 * Get target size and position relative to its boundaries
		 * @return
		 */
		public function getRatioRect():Rectangle {
			relativePos.x = dragRect.x / _boundRect.width;
			relativePos.y = dragRect.y / _boundRect.height;
			relativePos.width = dragRect.width / _boundRect.width;
			relativePos.height = dragRect.height / _boundRect.height;
			
			return relativePos;
		}
		
		public function setDragRectPosition(pos:Point):void {
			dragRect.x = pos.x;
			dragRect.y = pos.y;
			prevPos = pos.clone();
			oPos = tPos.clone();
		}
		
		/**
		 * Set target size and position from relative rectangle
		 */
		public function setRatioRect(rect:Rectangle):void {
			relativePos = rect.clone();
			dragRect.x = relativePos.x * _boundRect.width;
			dragRect.y = relativePos.y * _boundRect.height;
			dragRect.width = relativePos.width * _boundRect.width;
			dragRect.height = relativePos.height * _boundRect.height;
			prevPos = dragRect.topLeft.clone();
		}
		
		//} endregion
		
		//{ region Private
		
		private function initListeners():void {
			mouseCaptureLayer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		/**
		 * Drag begin
		 * @param	e
		 */
		private function mouseDownHandler(e:MouseEvent):void {
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			if (releaseTween && releaseTween.isActive()) {
				releaseTween.kill();
			}
			
			oPos.x = container.mouseX;
			oPos.y = container.mouseY;
			lPos = oPos.clone();
			
			container.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			container.stage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
		}
		
		/**
		 * Fly mode drag translation update
		 * @param	e
		 */
		private function enterFrameHandler(e:Event):void {
			updateTanslation();
			if (tPos.equals(lPos)) {
				return;
			}
			
			if (_useSmoothRelease) {
				//calculate velocity
				lPos = tPos.subtract(lPos);
				lPos.x /= dragRect.width * 0.5;
				lPos.y /= dragRect.height * 0.5;
				velocity = lPos.length;
				
				lPos = tPos.clone();
			}
			
			dragRect.x = Math.max(0, Math.min(_boundRect.width - dragRect.width, prevPos.x - translation.x));
			dragRect.y = Math.max(0, Math.min(_boundRect.height - dragRect.height, prevPos.y - translation.y));
			
			onDrag.dispatch();
		}
		
		/**
		 * Drag release
		 * @param	e
		 */
		private function mouseUpHandler(e:*):void {
			container.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			container.stage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			
			updateTanslation();
			
			prevPos.x = dragRect.x;
			prevPos.y = dragRect.y;
			oPos = tPos.clone();
			
			//smooth release
			if (_useSmoothRelease) {
				releaseTween = TweenLite.to(translation, Math.max(0.1, Math.min(1, 2 * velocity)), { x:0, y:0, onUpdate:smoothRelease, onUpdateParams:[translation], onComplete:onRelease.dispatch } );
			}else {
				onRelease.dispatch();
			}
			
			initListeners();
		}
		
		private function smoothRelease(translation:Point):void {
			dragRect.x = Math.max(0, Math.min(_boundRect.width - dragRect.width, prevPos.x - translation.x * velocity));
			dragRect.y = Math.max(0, Math.min(_boundRect.height - dragRect.height, prevPos.y - translation.y * velocity));
			prevPos.x = dragRect.x;
			prevPos.y = dragRect.y;
			onDrag.dispatch();
		}
		
		private function updateTanslation():void {
			tPos.x = container.mouseX;
			tPos.y = container.mouseY;
			translation = !_reverseControl ? oPos.subtract(tPos) : tPos.subtract(oPos);
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get useSmoothRelease():Boolean { return _useSmoothRelease; }
		public function set useSmoothRelease(value:Boolean):void {
			_useSmoothRelease = value;
		}
		
		public function get reverseControl():Boolean { return _reverseControl; }
		public function set reverseControl(value:Boolean):void {
			_reverseControl = value;
		}
		
		public function get boundRect():Rectangle { return _boundRect; }
		
		//} endregion
	}

}