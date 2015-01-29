package controller.components 
{
	import com.greensock.TweenLite;
	import controller.base.Controller;
	import controller.base.IToolTip;
	import flash.display.Shape;
	import flash.display.Sprite;
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
	public class ToolTip implements IToolTip
	{
		private const bgColor:uint = 0xf7f3e7;
		private const bgAlpha:Number = 1;
		private const vMargin:int = 4;
		private const hMargin:int = 8;
		private const offsetPosBottom:int = 24;
		private const offsetPosTop:int = 8;
		private const cursorRelPosX:int = 0;
		private const dropShadowFilter:DropShadowFilter = new DropShadowFilter(4, 90, 0, 0.75, 4, 4, 1, 2);
		
		private var tfContent:TextField;
		private var format:TextFormat;
		private var minW:int = 80;
		private var maxW:int = 160;
		private var tweenDrag:TweenLite;
		private var bg:Shape;
		private var displayArea:Rectangle;
		
		private var _text:String;
		private var _isDisplayed:Boolean = false;
		private var _display:Sprite;
		
		//{ region Constructor
		
		public function ToolTip(text:String) 
		{
			_text = text;
			_display = new Sprite();
			format = new TextFormat(AssetManager.getInstance().getFontName("TextFont") , 14, 0x24200c, true, null, null, null, null, TextFormatAlign.LEFT);
			build();
			_display.visible = false;
		}
		
		//} endregion
		
		//{ region Public
		
		public function show():void {
			updatePosition();
			
			setOnTop();
			
			_display.startDrag();
			
			_display.visible = true;
			_isDisplayed = true;
		}
		
		public function hide():void {
			_display.stopDrag();
			_display.visible = false;
			_isDisplayed = false;
		}
		
		public function updatePosition():void {
			_display.x = _display.stage.mouseX + cursorRelPosX;
			_display.y = _display.stage.mouseY + offsetPosBottom;
			
			//switch to left
			if (_display.stage.mouseX + _display.width + cursorRelPosX > _display.stage.stageWidth) {
				_display.x = _display.stage.mouseX - _display.width - cursorRelPosX;
			}
			//switch to top
			if (_display.stage.mouseY + _display.height + offsetPosBottom > _display.stage.stageHeight) {
				_display.y = _display.stage.mouseY - _display.height - offsetPosBottom;
			}
		}
		
		public function kill():void {
			if (_display.stage) {
				_display.parent.removeChild(_display);
				_isDisplayed = false;
			}
		}
		
		//} endregion
		
		//{ region Private
		
		private function setOnTop():void {
			_display.parent.setChildIndex(_display, _display.parent.numChildren - 1);
		}
		
		private function build():void {
			bg = new Shape();
			displayArea = new Rectangle();
			_display.addChild(bg);
			updateText();
		}
		
		private function updateText():void {
			if (tfContent) {
				_display.removeChild(tfContent);
				tfContent = null;
			}
			
			tfContent = new TextField();
			_display.addChild(tfContent);
			tfContent.defaultTextFormat = format;
			tfContent.embedFonts = true;
			tfContent.htmlText = _text;
			tfContent.autoSize = TextFieldAutoSize.LEFT;
			
			displayArea.width = minW;
			displayArea.height = 0;
			
			if (tfContent.width > maxW) {
				tfContent.multiline = true;
				tfContent.wordWrap = true;
				tfContent.width = maxW;
				tfContent.width = tfContent.textWidth+2;
			}
			
			if (_text.length > 1) {
				displayArea.width = Math.max(displayArea.width, tfContent.width);
				displayArea.height += tfContent.height;
			}
			
			displayArea.height += vMargin;
			displayArea.width += hMargin;
			
			tfContent.x = (displayArea.width - tfContent.width) / 2;
			tfContent.y = (displayArea.height - tfContent.height) / 2;
			//redraw background
			drawBg();
		}
		
		private function drawBg():void {
			bg.graphics.clear();
			bg.graphics.lineStyle(2, 0, 1, true);
			bg.graphics.beginFill(bgColor, bgAlpha);
			bg.graphics.drawRoundRect(0, 0, displayArea.width, displayArea.height, 8, 8);
			bg.graphics.endFill();
			bg.filters = [dropShadowFilter];
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get isDisplayed():Boolean { return _isDisplayed; }
		public function set isDisplayed(value:Boolean):void {
			_isDisplayed = value;
			if (isDisplayed != value) {
				_isDisplayed ? show() : hide();
			}
		}
		
		public function get display():Sprite { return _display; }
		public function set display(value:Sprite):void {
			_display = value;
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			updateText();
		}
		
		//} endregion
		
	}

}