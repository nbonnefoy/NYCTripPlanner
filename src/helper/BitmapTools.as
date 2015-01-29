package helper
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * @author Nicolas Bonnefoy
	 */
	public class BitmapTools
	{
		/**
		 * Simple scale bitmap data
		 * @param	bmp
		 * @param	ratio
		 * @param	transparent
		 * @return
		 */
		public static function resizeBitmapData(bmp:BitmapData, ratio:Number, transparent:Boolean = true):BitmapData
		{
			var scaledBmpData:BitmapData = new BitmapData(bmp.width * ratio, bmp.height * ratio, transparent, 0x00000000);
			var matrix:Matrix = new Matrix(ratio, 0, 0, ratio, 0, 0);
			scaledBmpData.draw(bmp, matrix, null, null, null, false);
			
			return scaledBmpData;
		}
		
		/**
		 * Use alpha channel from a bitmap to cutout a bitmapdata
		 * @param	img
		 * @param	alphaMap
		 * @return
		 */
		public static function alphaCutout(bmp:BitmapData, alphaMap:BitmapData):BitmapData {
			var bmpData:BitmapData = new BitmapData(bmp.width, bmp.height, true, 0x00000000);
			var po:Point = new Point();
			bmpData.copyPixels(bmp, bmp.rect, po);
			bmpData.copyChannel(alphaMap, alphaMap.rect, po, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			return bmpData;
		}
		
		/**
		 * Crop a bitmap using a new rectangle
		 * @param	bmp
		 * @param	cropRect
		 * @return
		 */
		public static function cropBitmap(bmp:BitmapData, cropRect:Rectangle):BitmapData {
			var bmpData:BitmapData;
			
			if (cropRect.width > bmp.width) {
				cropRect.x = 0;
				cropRect.width = bmp.width;
			}
			if (cropRect.height > bmp.height) {
				cropRect.y = 0;
				cropRect.height = bmp.height;
			}
			
			bmpData = new BitmapData(cropRect.width, cropRect.height, true, 0x00000000);
			bmpData.copyPixels(bmp, cropRect, new Point());
			
			return bmpData;
		}
		
		/**
		 * Resizes BitmapData objects smoothly, using bilinear algorithm.
		 * @param	bmp
		 * @param	ratio
		 * @param	transparent
		 * @return
		 */
		public static function resampleBitmapData(bmp:BitmapData, ratio:Number, transparent:Boolean = true):BitmapData {
			if (ratio >= 1)	{
				return (BitmapTools.resizeBitmapData(bmp, ratio, transparent));
			}else {
				var bmpData:BitmapData = bmp.clone();
				var appliedRatio:Number = 1;
				
				do {
					if (ratio < 0.5 * appliedRatio) {
						bmpData = BitmapTools.resizeBitmapData(bmpData, 0.5, transparent);
						appliedRatio = 0.5 * appliedRatio;
					}else {
						bmpData = BitmapTools.resizeBitmapData(bmpData, ratio / appliedRatio, transparent);
						appliedRatio = ratio;
					}
				}while (appliedRatio != ratio);
				
				return bmpData;
			}
		}
	}
}
