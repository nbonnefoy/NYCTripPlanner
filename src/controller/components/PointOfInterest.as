package controller.components 
{
	import com.gskinner.geom.ColorMatrix;
	import com.rafaelrinaldi.sound.sound;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import helper.BitmapTools;
	import manager.AssetManager;
	import manager.DataManager;
	import org.osflash.signals.Signal;
	import vo.PoiData;
	
	/**
	 * Map point of interest : contain POI data and graphics
	 * @author Nicolas Bonnefoy
	 */
	public class PointOfInterest
	{
		private const glowFilterIn:GlowFilter = new GlowFilter(0, 1, 2, 2, 3, 1, true, true);
		private const glowFilterOut:GlowFilter = new GlowFilter(0, 1, 2, 2, 3, 1, false, false);
		protected var overBmp:Bitmap;
		protected var scaledBmpDataPool:Dictionary;
		protected var selColorMatrixFilter:ColorMatrixFilter;
		
		public var coord:Point;
		public var bmp:Bitmap;
		public var name:String;
		public var data:PoiData;
		public var scaledRect:Rectangle;
		public var display:Sprite;
		
		private var _id:uint;
		private var _focused:Boolean = false;
		private var _highLighted:Boolean = true;
		private var _selected:Boolean = false;
		private var _currentScaleRatio:Number = 1;
		
		public var onFocusIn:Signal;
		public var onFocusOut:Signal;
		
		//{ region Constructor
		
		public function PointOfInterest(rawData:Object, id:int) 
		{
			_id = id;
			name = rawData.name;
			coord = new Point(rawData.rect.x, rawData.rect.y);
			
			onFocusIn = new Signal(uint);
			onFocusOut = new Signal(uint);
			
			init();
		}
		
		protected function init():void {
			bmp = new Bitmap(AssetManager.getInstance().getSprite(name) , PixelSnapping.NEVER);
			data = DataManager.getInstance().getPoiData(name);
			
			scaledRect = bmp.bitmapData.rect.clone();
			scaledBmpDataPool = new Dictionary();
			
			overBmp = new Bitmap(bmp.bitmapData, PixelSnapping.NEVER);
			overBmp.visible = false;
			
			display = new Sprite();
			display.addChild(bmp);
			display.addChild(overBmp);
			
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustHue(160);
			colorMatrix.adjustSaturation( -10);
			selColorMatrixFilter = new ColorMatrixFilter(colorMatrix);
			updateStatus();
		}
		
		//} endregion
		
		//{ region Public
		
		public function setPosition():void {
			display.x = coord.x;
			display.y = coord.y;
		}
		
		public function getScaledCenterPosition():Point {
			var pt:Point = new Point(scaledRect.x + scaledRect.width * 0.5, scaledRect.y + scaledRect.height * 0.5);
			return pt;
		}
		
		/**
		 * Operate pixel hit test on alpha channel
		 * @return
		 */
		public function hitTest():Boolean {
			return bmp.bitmapData.getPixel32(bmp.mouseX, bmp.mouseY) >> 24 & 0xFF > 1 ? true : false;
		}
		
		public function getScaledBitmapData():BitmapData {
			//scaled bmp data already computed : reuse pool
			if (scaledBmpDataPool[currentScaleRatio]) {
				return scaledBmpDataPool[currentScaleRatio] as BitmapData;
			}
			//simple operation if no scale :
			if (currentScaleRatio == 1) {
				scaledBmpDataPool[currentScaleRatio] = bmp.bitmapData.clone();
				return scaledBmpDataPool[currentScaleRatio];
			}
			
			//resizebitmap data and store it to memory
			scaledBmpDataPool[currentScaleRatio] = BitmapTools.resizeBitmapData(bmp.bitmapData, currentScaleRatio);
			return scaledBmpDataPool[currentScaleRatio];
		}
		
		//} endregion
		
		//{ region Private
		
		protected function updateStatus():void {
			if (_focused) {
				overBmp.visible = true;
				overBmp.filters = [glowFilterIn, glowFilterOut];
				bmp.visible = _selected;
				onFocusIn.dispatch(_id);
				sound().item("snd_magic").play(-1);
				return;
			}else {
				overBmp.visible = false;
				overBmp.filters = [];
				sound().item("snd_magic").cancel();
				sound().item("snd_magic").stop();
			}
			
			onFocusOut.dispatch(_id);
			
			if (_selected) {
				bmp.visible = true;
				bmp.filters = [selColorMatrixFilter];
				bmp.blendMode = BlendMode.OVERLAY;
			}else {
				bmp.visible = _highLighted;
				bmp.filters = [];
				bmp.blendMode = BlendMode.OVERLAY;
			}
		}
		
		private function updateScaledRect():void {
			scaledRect.x = coord.x * _currentScaleRatio;
			scaledRect.y = coord.y * _currentScaleRatio;
			scaledRect.width = bmp.bitmapData.rect.width * _currentScaleRatio;
			scaledRect.height = bmp.bitmapData.rect.height * _currentScaleRatio;
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get focused():Boolean { return _focused; }
		public function set focused(value:Boolean):void {
			_focused = value;
			updateStatus();
		}
		
		public function get highLighted():Boolean { return _highLighted; }
		public function set highLighted(value:Boolean):void {
			_highLighted = value;
			updateStatus();
		}
		
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void {
			_selected = value;
			updateStatus();
		}
		
		public function get currentScaleRatio():Number { return _currentScaleRatio; }
		public function set currentScaleRatio(value:Number):void {
			_currentScaleRatio = value;
			updateScaledRect();
		}
		
		public function get id():uint { return _id; }
		
		//} endregion
		
	}

}