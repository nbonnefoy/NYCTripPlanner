package behaviors 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class BackroundBlurShader 
	{
		public var display:Sprite;
		
		private var canvas:Bitmap;
		private var target:DisplayObjectContainer;
		private var parent:DisplayObjectContainer;
		
		private const colorTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1);
		private const blurFilter:BlurFilter = new BlurFilter(8, 8, 2);
		
		//{ region constructor
		
		public function BackroundBlurShader(target:DisplayObjectContainer) 
		{
			this.target = target;
			this.parent = target.parent;
			display = new Sprite();
			
			build();
		}
		
		//} endregion
		
		//{ region Public
		
		public function rebuild():void {
			kill();
			build();
			add();
		}
		
		public function add():void {
			display.addChild(canvas);
			display.x = parent.x;
			display.y = parent.y;
			parent.addChildAt(display, parent.getChildIndex(target) );
		}
		
		public function remove():void {
			display.removeChild(canvas);
			if (parent.getChildIndex(display) != -1) {
				parent.removeChild(display);
			}
		}
		
		public function kill():void {
			remove();
			canvas.bitmapData.dispose();
			canvas = null;
		}
		
		//} endregion
		
		//{ region Private
		private function cleanObjUnderTarget(visible:Boolean):void {
			
			for (var i:int = parent.numChildren-1; i >= parent.getChildIndex(target); --i) {
				parent.getChildAt(i).visible = visible;
			}
		}
		
		private function build():void {
			var bmpData:BitmapData = new BitmapData(parent.width, parent.height, false, 0);
			cleanObjUnderTarget(false);
			bmpData.drawWithQuality(parent, null, colorTransform, null, null, false, StageQuality.LOW);
			bmpData.applyFilter(bmpData, bmpData.rect, bmpData.rect.topLeft, blurFilter);
			cleanObjUnderTarget(true);
			
			canvas = new Bitmap(bmpData);
		}
		
		//} endregion
		
	}

}