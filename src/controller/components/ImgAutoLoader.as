package controller.components 
{
	import controller.base.Controller;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import helper.BitmapTools;
	import helper.DisplayLoaderHelper;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ImgAutoLoader extends Controller
	{
		public var onImgLoaded:Signal;
		public var imgLoaded:Boolean;
		
		private var url:String;
		private var image:Bitmap;
		
		//{ region Constructor
		
		public function ImgAutoLoader(dsp:MovieClip, url:String) 
		{
			this.url = url;
			imgLoaded = false;
			onImgLoaded = new Signal();
			loadImage();
			super(dsp);
		}
		
		override protected function ready():void {
			if (imgLoaded) {
				display.addChild(image);
			}
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function kill():void {
			onImgLoaded.removeAll();
			if (imgLoaded) {
				image.bitmapData.dispose();
				display.removeChild(image);
			}
			removeView();
		}
		
		//} endregion
		
		//{ region Private
		
		private function loadImage():void {
			var ldr:DisplayLoaderHelper = new DisplayLoaderHelper();
			ldr.callback.addOnce(imgLoadedHandler);
			ldr.load(url);
		}
		
		private function imgLoadedHandler(bmp:Bitmap):void {
			if ((bmp.width > display.width) || (bmp.height > display.height)) {
				image = new Bitmap(BitmapTools.resampleBitmapData(bmp.bitmapData, Math.min(display.width / bmp.width, display.height / bmp.height)));
				image.x = (display.width - image.width) / 2;
				image.y = (display.height - image.height) / 2;
			}else {
				image = bmp;
			}
			
			imgLoaded = true;
			if (isReady) {
				display.addChild(image);
			}
			onImgLoaded.dispatch();
		}
		
		//} endregion
	}

}