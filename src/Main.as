package 
{
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.EndArrayPlugin;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import controller.screens.MapScreen;
	import controller.screens.PreloadScreen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import manager.AssetManager;
	import manager.DataManager;
	import manager.GlobalErrorHandler;
	import net.hires.debug.Stats;
	import net.I18N;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class Main extends Sprite 
	{
		private var preloadScreen:PreloadScreen;
		private var mapScreen:MapScreen;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//setup stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			//setup global error handler
			GlobalErrorHandler.displayTarget = stage;
			GlobalErrorHandler.autoDisplayPopups = true;
			//add preload screen
			preloadScreen = new PreloadScreen();
			addChild(preloadScreen.display);
			
			//init asset manager
			AssetManager.getInstance().init().addOnce(initCompleteHandler);
			//init data manger
			DataManager.getInstance().init().addOnce(initCompleteHandler);
			//init localization
			I18N.load("en", "data/").addOnce(initCompleteHandler);
			//init Greesock plugins
			TweenPlugin.activate([AutoAlphaPlugin, TransformAroundCenterPlugin, EndArrayPlugin]);
		}
		
		/**
		 * All assets are loded, close preload screen and display map
		 */
		private function initCompleteHandler():void {
			//wait for all to be ready
			if (!I18N.isReady || !AssetManager.getInstance().isReady || !DataManager.getInstance().isReady) {
				return;
			}
			
			mapScreen = new MapScreen(stage);
			preloadScreen.removed.addOnce(function ():void {
				addMapScreen();
			});
			preloadScreen.setComplete();
		}
		
		private function addMapScreen():void {
			mapScreen.init();
			
			//add stats if complation is in debug mode
			if (CONFIG::debug == true) {
				var stats:Stats = new Stats();
				stats.x = stage.stageWidth - 70;
				stage.addChild(stats);
			}
			
		}
		
	}
	
}