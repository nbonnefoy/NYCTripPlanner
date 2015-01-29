package controller.components 
{
	import com.greensock.TweenLite;
	import controller.base.IToolTip;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import manager.AssetManager;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class AutoToolTip extends ToolTip implements IToolTip
	{
		private var displayObj:DisplayObjectContainer
		
		//{ region Contructor
		
		public function AutoToolTip(relativeDisplayObject:DisplayObjectContainer, text:String) 
		{
			displayObj = relativeDisplayObject;
			displayObj.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			super(text);
			
			if (displayObj.stage) {
				addToStage();
			}else {
				displayObj.addEventListener(Event.ADDED_TO_STAGE, parentAddedToStageHandler);
			}
			display.visible = false;
		}
		
		//} endregion
		
		//{ region Public
		
		override public function kill():void {
			displayObj.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			displayObj.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			if (isDisplayed) {
				displayObj.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				displayObj.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			}
			super.kill();
		}
		
		//} endregion
		
		//{ region Private
		
		private function rollOverHandler(e:MouseEvent):void {
			displayObj.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			displayObj.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			show();
		}
		
		private function mouseMoveHandler(e:MouseEvent):void {
			updatePosition();
		}
		
		private function rollOutHandler(e:MouseEvent):void {
			displayObj.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			displayObj.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			hide();
		}
		
		private function parentAddedToStageHandler(e:Event):void {
			displayObj.removeEventListener(Event.ADDED_TO_STAGE, parentAddedToStageHandler);
			addToStage();
		}
		
		private function addToStage():void {
			displayObj.stage.addChild(display);
			displayObj.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			display.visible = false;
		}
		
		private function removedFromStageHandler(e:Event):void {
			kill();
		}
		
		//} endregion
	}

}