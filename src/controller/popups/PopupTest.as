package controller.popups 
{
	import com.rafaelrinaldi.sound.sound;
	import controller.base.PopupController;
	import controller.components.BtnBase;
	import controller.components.PointOfInterest;
	import controller.components.SimpleVideo;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class PopupTest extends PopupController
	{
		
		private var vid:SimpleVideo;
		private var poi:PointOfInterest;
		private var btnClose:BtnBase;
		private var btnValid:BtnBase;
		private var btnCancel:BtnBase;
		
		public function PopupTest(poi:PointOfInterest) 
		{
			this.poi = poi;
			onValidClick = new Signal(PointOfInterest);
			hasShader = true;
			autoCenter = true;
			var DC_HLPopView:Class = getDefinitionByName("PopTestView") as Class;
			super(new DC_HLPopView());
		}
		
		override protected function ready():void {
			super.ready();
			sound().item("snd_camClick").play();
			btnClose = new BtnBase(display.btnClose, 0);
			btnCancel = new BtnBase(display.btnCancel, 1, "Cancel");
			btnValid = new BtnBase(display.btnValid, 2, "OK");
			btnClose.sndClick = btnValid.sndClick = btnCancel.sndClick = "snd_camClick";
			
			display.txtTitle.htmlText = poi.data.title;
			display.txtDesc.htmlText = poi.data.desc;
			btnCancel.clicked.addOnce(btnClickedHandler);
			btnClose.clicked.addOnce(btnClickedHandler);
			btnValid.clicked.addOnce(btnClickedHandler);
			
			vid = new SimpleVideo(poi.data.vidPath);
			display.vidContainer.addChild(vid);
			sound().group("music").mute();
			vid.play();
		}
		
		private function btnClickedHandler(id:int):void {
			
			btnCancel.clicked.remove(btnClickedHandler);
			btnClose.clicked.remove(btnClickedHandler);
			btnValid.clicked.remove(btnClickedHandler);
			if (id == 2) {
				poi.selected = !poi.selected;
				onValidClick.dispatch(poi);
			}else {
				close();
			}
		}
		
		override public function popOutCompleteHandler():void {
			vid.stop();
			sound().group("music").unmute();
			super.popOutCompleteHandler();
		}
		
	}

}