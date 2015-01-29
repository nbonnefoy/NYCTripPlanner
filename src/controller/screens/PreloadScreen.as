package controller.screens 
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import controller.base.Controller;
	import controller.components.ProgressBarSmall;
	import flash.display.MovieClip;
	import flash.events.Event;
	import manager.AssetManager;
	/**
	 * Main preloader
	 * @author Nicolas Bonnefoy
	 */
	public class PreloadScreen extends Controller
	{
		public var progressBar:ProgressBarSmall;
		
		//{ region Constructor
		
		public function PreloadScreen() 
		{
			super(new SplashView());
		}
		
		override protected function ready():void {
			//init progress bar
			progressBar = new ProgressBarSmall(display.progressBar);
			init();
			super.ready();
		}
		
		private function init():void {
			super.ready();
			display.addEventListener(Event.ENTER_FRAME, updateProgress);
		}
		
		//} endregion
		
		//{ region Public
		
		/**
		 * Stop and remove progress bar
		 */
		public function setComplete():void {
			display.removeEventListener(Event.ENTER_FRAME, updateProgress);
			progressBar.setLabel("Loading complete");
			progressBar.ratio = 1;
			TweenLite.to(display.progressBar, 0.4, { y:display.stage.stageHeight, ease:Back.easeIn, delay:1, onComplete:removeView } );
		}
		
		//} endregion
		
		//{ region Private
		
		private function updateProgress(e:Event):void 
		{
			var r:Number = AssetManager.getInstance().getLoadingProgress();
			progressBar.ratio = isNaN(r) ? progressBar.ratio : r;
			progressBar.setLabel("Loading " + AssetManager.getInstance().lastLoadingName);
		}
		
		//} endregion
		
	}

}