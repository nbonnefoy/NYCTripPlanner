package helper 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class TextTools 
	{
		/**
		 * scale char size to fit in a specified width
		 * @param	tf
		 * @param	maxWidth
		 */
		public static function fitTextIn(tf:TextField, maxWidth:Number = NaN, maxHeight:Number = NaN):Rectangle {
			var rect:Rectangle = getCharBounds(tf);
			var format:TextFormat;
			var fontSize:int;
			isNaN(maxWidth) ? maxWidth = tf.width : void;
			isNaN(maxHeight) ? maxHeight = tf.height : void;
			
			while (rect == null || (rect.bottomRight.y > maxHeight) || (rect.bottomRight.x > maxWidth) )
			{
				format = tf.getTextFormat();
				fontSize = int(format.size);
				if (fontSize <= 2) { break;	}
				fontSize -= 1;
				format.size = fontSize;
				tf.setTextFormat(format);
				rect = getCharBounds(tf);
				
			}
			return rect;
		}
		
		public static function getCharBounds(tf:TextField):Rectangle {
			var bounds:Rectangle = new Rectangle();
			bounds.left = tf.getCharBoundaries(0).left;
			bounds.top = tf.getCharBoundaries(0).top;
			
			var r:Rectangle;
			var i:int = 0;
			while ( r == null) { //last special char return null boundaries
				i++;
				if (i == tf.length + 1) {
					r = new Rectangle();
					break;
				}
				r = tf.getCharBoundaries(tf.length - i);
			}
			
			bounds.bottom = r.bottom;
			
			//for each line
			for (var j:int = 0; j < tf.numLines; j++) {
				var metrics:TextLineMetrics = tf.getLineMetrics(j);
				//get min left
				bounds.left = bounds.left == 0 ? metrics.x : Math.min(bounds.left, metrics.x);
				//get max right
				bounds.right = Math.max(bounds.right, metrics.width)
			}
			
			return bounds;
		}
		
		
		/**
		 * Center text on vertical axis. Will use TextFieldAutoSize CENTER if NONE set.
		 * @param	tf
		 * @param	relativeRect
		 */
		public static function vAlign(tf:TextField, relativeRect:Rectangle = null):void {
			relativeRect == null ? relativeRect = tf.getRect(tf.parent) : void;
			tf.autoSize == TextFieldAutoSize.NONE ? tf.autoSize = TextFieldAutoSize.CENTER : void;
			tf.y = relativeRect.y + (relativeRect.height - tf.height) / 2;
		}
		
		/**
		 * Format a number using thousand separator
		 * @param	n
		 * @param	sep text separator
		 * @param	floatSep separator of float digits
		 * @return
		 */
		public static function thousandSeparatorFormat(n:Number, sep:String = ",", floatSep:String = "."):String {
			var arrSplit:Array = n.toString().split(".");
			var sbStr:String = (n | 0).toString();
			var finalStr:String = arrSplit[1] != undefined ? floatSep + arrSplit[1] : "";
			var tmpStr:String = "";
			for (var i:int = 0; i < sbStr.length; i += 3) {
				tmpStr = sbStr.slice(Math.max(0, sbStr.length - (i + 3)), sbStr.length - i);
				finalStr = tmpStr.length == 3 ? sep + tmpStr + finalStr : tmpStr + finalStr;
			}
			
			return finalStr;
		}
		
		public static function getPixelHeight(textField:TextField):Rectangle
		{
			// copy textField to bitmap
			var bmd:BitmapData = new BitmapData(textField.width,textField.height,true,0x000000);
			bmd.draw(textField);
			// loop through pixels of bitmap data and store the y location of pixels found.
			var foundy:Vector.<int> = new Vector.<int>();
			
			for (var ny:int = 0; ny < bmd.height; ny++)
			{
				for (var nx:int = 0; nx < bmd.width;nx++)
				{
					var px:uint = bmd.getPixel32(nx, ny);
					if (px != 0)
					{
						foundy.push(ny);
						break;
					}
				}
			}
			
			var rect:Rectangle;
			// get the values for the metrics
			if (foundy.length == 0) {
				rect = new Rectangle();
			}else {
				rect = new Rectangle(0, foundy[0], 0, foundy[foundy.length - 1] - foundy[0]);
			}
			
			// clear vectors
			foundy.length = 0;
			foundy = null;
			// clear bitmapdata
			bmd.dispose();
			bmd = null;
			return rect; // retrurn metric object;
		}
		
	}

}