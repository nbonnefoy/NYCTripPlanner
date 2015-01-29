package behaviors 
{
	import behaviors.DragInput;
	import com.greensock.BlitMask;
	import controller.components.ScrollBar;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ScrollPane
	{
		
		private var dragInput:DragInput;
		private var content:Sprite;
		private var container:Sprite;
		private var scrollBar:ScrollBar;
		private var blitMask:BlitMask;
		private var regularMask:Sprite;
		private var useBlitMask:Boolean;
		
		//{ region constructor
		
		public function ScrollPane(content:Sprite, container:Sprite, scrollBar:ScrollBar, useBlitMask:Boolean = true) 
		{
			this.content = content;
			this.container = container;
			this.scrollBar = scrollBar;
			this.useBlitMask = useBlitMask;
			
			init();
		}
		
		private function init():void {
			dragInput = new DragInput(container, new Rectangle(content.x, content.y, content.width, content.height), useBlitMask ? container : content);
			dragInput.reverseControl = true;
			dragInput.useSmoothRelease = true;
			dragInput.onDrag.add(dragHandler);
			scrollBar.onDrag.add(scrollDragHandler);
			
			dragInput.setDragRectPosition(new Point(0, 0));
			
			scrollBar.setRatioRect(dragInput.getRatioRect()); 
			content.x = container.x;
			content.y = container.y;
			//add mask
			if (useBlitMask) {
				blitMask = new BlitMask(content, container.x, container.y, container.width, container.height, true, false);
			}else {
				regularMask = new Sprite();
				regularMask.graphics.beginFill(0xFF0000);
				regularMask.graphics.drawRect(container.x, container.y, container.width, container.height);
				content.parent.addChild(regularMask);
				content.mask = regularMask;
			}
		}
		
		//} endregion
		
		//{ region Public
		
		public function kill():void {
			if (useBlitMask) {
				blitMask.parent.removeChild(blitMask);
			}else {
				content.parent.removeChild(regularMask);
				content.mask = null;
			}
			dragInput.kill();
			dragInput = null;
			blitMask = null;
		}
		/**
		 * Refresh content and mask
		 */
		public function update():void {
			if (useBlitMask) {
				blitMask.update(null, true);
			}
			//keep position when adding/removing items
			if (content.height > dragInput.boundRect.height) {
				var prevPos:Point = dragInput.dragRect.topLeft.clone();
				dragInput.updateBoundaries(new Rectangle(0, 0, content.width, content.height));
				dragInput.setDragRectPosition(prevPos);
			}else {
				dragInput.updateBoundaries(new Rectangle(0, 0, content.width, content.height));
			}
			
			dragHandler();
		}
		
		//} endregion
		
		//{ region Private
		
		/**
		 * Scroolbar drag
		 * @param	rect
		 */
		private function scrollDragHandler(rect:Rectangle):void {
			dragInput.setRatioRect(rect);
			content.y = container.y - dragInput.dragRect.y;
			if (useBlitMask) {
				blitMask.update();
			}
		}
		
		/**
		 * Drag map handler
		 * @param	translation
		 */
		private function dragHandler():void {
			scrollBar.setRatioRect(dragInput.getRatioRect()); 
			content.y = container.y - dragInput.dragRect.y;
			if (useBlitMask) {
				blitMask.update();
			}
		}
		
		//} endregion
		
	}

}