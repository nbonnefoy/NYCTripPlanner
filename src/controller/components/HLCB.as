package controller.components 
{
	import com.gskinner.geom.ColorMatrix;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import vo.PoiData;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class HLCB extends PointOfInterest
	{
		
		public function HLCB() 
		{
			super( { name:"hlcb", rect: { x:1380, y:4018, w:149, h:162 } }, 777);
		}
		
		override protected function init():void {
			var DC_HlcbView:Class = getDefinitionByName("HlcbView") as Class;
			bmp = new Bitmap(new DC_HlcbView() , PixelSnapping.NEVER);
			
			data = new PoiData(XML(<item name="hlcb">
				<title><![CDATA[Half-Life Crowbar?!]]></title>
				<desc><![CDATA[Congratulations! You've found Gordon Freeman's crowbar!<br/><br/>Another clue about the big announcement?<br/>Who knows...]]></desc>
				<img><![CDATA[http://nicolasbonnefoy.com/nycmap/hlcb/hlcb.jpg]]></img>
			</item>));
			data.vidPath = "http://nicolasbonnefoy.com/nycmap/hlcb/video.mp4";
			
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
			bmp.visible = false;
		}
		
		override protected function updateStatus():void {
			return;
		}
		
	}

}