package controller.hud 
{
	import com.greensock.TweenLite;
	import com.rafaelrinaldi.sound.sound;
	import controller.base.Controller;
	import controller.components.ToggleBtn;
	import controller.components.AutoToolTip;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.utils.getDefinitionByName;
	import manager.DataManager;
	import net.I18N;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class Toolbar extends Controller
	{
		public var btnFullScreen:ToggleBtn;
		public var btnSound:ToggleBtn;
		public var btnList:ToggleBtn;
		public var btnHighlight:ToggleBtn;
		
		public var onHiglightChanged:Signal;
		public var onDisplayListChanged:Signal;
		
		//{ region Constructor
		
		public function Toolbar() 
		{
			onHiglightChanged = new Signal(Boolean);
			onDisplayListChanged = new Signal(Boolean);
			
			var DC_ToolbarView:Class = getDefinitionByName("ToolbarView") as Class;
			super(new DC_ToolbarView());
		}
		
		override protected function ready():void {
			btnFullScreen = new ToggleBtn(display.btnFullScreen);
			btnFullScreen.selected = Boolean(display.stage.displayState == StageDisplayState.FULL_SCREEN); 
			btnSound = new ToggleBtn(display.btnSound);
			btnList = new ToggleBtn(display.btnList);
			btnHighlight = new ToggleBtn(display.btnHighlight);
			
			addListeners();
			
			btnFullScreen.selected = (display.stage.displayState == StageDisplayState.FULL_SCREEN);
			btnFullScreen.attachToolTip(btnFullScreen.selected ? I18N.getString("ttFullScreenOn") : I18N.getString("ttFullScreenOff"));
			btnSound.selected = DataManager.getInstance().soundEnabled;
			btnList.selected = false;
			
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function setHighlight(value:Boolean):void {
			btnHighlight.selected = value;
		}
		
		public function playBtnListNotifAnim():void {
			TweenLite.from(btnList.display, 0.3, { transformAroundCenter: { scale:1.5 } } );
			sound().item("snd_hint").play();
		}
		
		//} endregion
		
		//{ region Private
		
		private function addListeners():void {
			display.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
			btnFullScreen.clicked.add(btnFullScreenClickHandler);
			
			btnSound.selectionChanged.add(soundChangedHandler);
			btnHighlight.selectionChanged.add(highlightChangedHandler);
			btnList.selectionChanged.add(btnListChangedHandler);
		}
		
		private function btnListChangedHandler(value:Boolean):void {
			btnList.attachToolTip(btnList.selected ? I18N.getString("ttListOn") : I18N.getString("ttListOff"));
			onDisplayListChanged.dispatch(btnList.selected);
		}
		
		private function soundChangedHandler(value:Boolean):void {
			DataManager.getInstance().soundEnabled = value;
			btnSound.attachToolTip(btnSound.selected ? I18N.getString("ttSoundOn") : I18N.getString("ttSoundOff"));
		}
		
		//{ region FullScreen Event Handlers
		
		private function btnFullScreenClickHandler(id:int):void {
			if (btnFullScreen.selected) {
				display.stage.displayState = StageDisplayState.FULL_SCREEN; 
			}else {
				display.stage.displayState = StageDisplayState.NORMAL; 
			}
		}
		
		private function fullScreenEventHandler(e:FullScreenEvent):void {
			btnFullScreen.selected = e.fullScreen;
			btnFullScreen.toolTip.text = btnFullScreen.selected ? I18N.getString("ttFullScreenOn") : I18N.getString("ttFullScreenOff");
		}
		
		//} endregion
		
		private function highlightChangedHandler(value:Boolean):void {
			onHiglightChanged.dispatch(value);
			btnHighlight.attachToolTip(btnHighlight.selected ? I18N.getString("ttHighlightOn") : I18N.getString("ttHighlightOff"));
		}
		
		//} endregion
		
	}

}