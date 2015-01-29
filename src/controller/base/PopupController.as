package controller.base 
{
	import behaviors.BackroundBlurShader;
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import com.rafaelrinaldi.sound.sound;
	import controller.base.Controller;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class PopupController extends Controller
	{
		public var popInComplete:Signal;
		public var popOutComplete:Signal;
		
		public var autoCenter:Boolean = false;
		public var hasShader:Boolean = false;
		private var shader:BackroundBlurShader;
		
		public var onValidClick:Signal;
		
		//{ region Constructor
		
		public function PopupController(dsp:MovieClip) 
		{
			popInComplete = new Signal();
			popOutComplete = new Signal();
			super(dsp);
		}
		
		override protected function ready():void {
			if (autoCenter) {
				display.stage.addEventListener(Event.RESIZE, stageResizedHandler);
				center();
			}
			super.ready();
			popIn();
		}
		
		//} endregion
		
		//{ region Public
		
		public function close(id:*= null):void {
			popOut();
		}
		
		public function popIn():void {
			if (hasShader) {
				shader = new BackroundBlurShader(display);
				shader.add();
				TweenLite.from(shader.display, 0.3, { alpha:0, ease:Quad.easeOut } );
			}
			sound().item("snd_popIn").play();
			TweenLite.from(display, 0.4, { alpha:0, transformAroundCenter: { scale:0.25 }, delay:0.1, ease:Quad.easeOut, onComplete:popInCompleteHandler } );
			
		}
		
		public function popInCompleteHandler():void {
			popInComplete.dispatch();
		}
		
		public function popOut():void {
			if (hasShader) {
				TweenLite.to(shader.display, 0.3, { alpha:0, ease:Quad.easeIn } );
			}
			TweenLite.to(display, 0.3, { alpha:0, transformAroundCenter: { scale:0.25 }, ease:Quad.easeIn, onComplete:popOutCompleteHandler } );
			sound().item("snd_popOut").play();
		}
		
		public function removeShader():void {
			if (hasShader) {
				shader.kill();
				shader = null;
			}
		}
		
		/**
		 * Auto remove popup
		 */
		public function popOutCompleteHandler():void {
			removeShader();
			popOutComplete.dispatch();
			if (autoCenter) {
				display.stage.removeEventListener(Event.RESIZE, stageResizedHandler);
			}
			removeView();
		}
		
		//} endregion
		
		private function stageResizedHandler(e:Event):void {
			center();
			if (hasShader) {
				shader.rebuild();
			}
		}
		
		private function center():void {
			display.x = int((display.stage.stageWidth - display.background.width) / 2);
			display.y = int((display.stage.stageHeight - display.background.height) / 2);
		}
		
	}

}