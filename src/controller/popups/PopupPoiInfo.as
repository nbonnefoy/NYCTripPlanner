package controller.popups 
{
	import controller.base.PopupController;
	import controller.components.BtnBase;
	import controller.components.PointOfInterest;
	import controller.components.ScrollBar;
	import behaviors.ScrollPane;
	import controller.components.ToggleBtn;
	import controller.popups.content.PopupContentPoiInfo;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import helper.TextTools;
	import net.I18N;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class PopupPoiInfo extends PopupController
	{
		private var btnClose:BtnBase;
		private var btnValid:ToggleBtn;
		private var txtTitle:TextField;
		private var contentZone:MovieClip;
		private var scrollBar:ScrollBar;
		private var scrollPane:ScrollPane;
		private var content:PopupContentPoiInfo;
		private var poi:PointOfInterest;
		
		public var onValidClick:Signal;
		
		//{ region Constructor
		
		public function PopupPoiInfo(poi:PointOfInterest) 
		{
			this.poi = poi;
			this.content = new PopupContentPoiInfo(poi.data);
			onValidClick = new Signal(PointOfInterest);
			hasShader = true;
			autoCenter = true;
			
			var DC_PopupInfoView:Class = getDefinitionByName("PopupInfoView") as Class;
			super(new DC_PopupInfoView());
		}
		
		override protected function ready():void {
			contentZone = display.contentZone;
			
			btnValid = new ToggleBtn(display.btnValid, 1, poi.selected ? I18N.getString("btnRemoveFromList") : I18N.getString("btnAddToList"));
			btnValid.clicked.addOnce(validClickHandler);
			btnValid.selected = poi.selected;
			
			btnClose = new BtnBase(display.btnClose);
			btnClose.clicked.addOnce(close);
			
			display.txtTitle.htmlText = content.poiData.title;
			TextTools.fitTextIn(display.txtTitle, contentZone.width - 20);
			
			content.onReady.addOnce(contentChangedHandler);
			content.onChanged.add(contentChangedHandler);
			
			display.addChildAt(content.display, display.getChildIndex(contentZone));
			
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function close(id:*=null):void {
			popOut();
		}
		
		//} endregion
		
		//{ region Private
		
		private function validClickHandler(id:*= null):void {
			btnValid.display.visible = false;
			poi.selected = btnValid.selected;
			onValidClick.dispatch(poi);
		}
		
		private function contentChangedHandler():void {
			//content overflow
			if (content.display.height > contentZone.height) {
				//no scroll bar / scroll pane : add one
				if (scrollBar == null) {
					display.scrollBar.visible = true;
					scrollBar = new ScrollBar(display.scrollBar);
					setupScrollPane();
				}else if (scrollPane) {
					//else refresh scroll pane
					scrollPane.update();
				}
			}else {
				//content fit : remove scroll controllers
				if (scrollBar) {
					scrollBar.removed.addOnce(function ():void {
						scrollBar = null;
					});
					scrollBar.kill();
					scrollPane.kill();
					scrollPane = null;
				}
				display.scrollBar.visible = false;
				content.display.x = contentZone.x;
				content.display.y = contentZone.y;
			}
		}
		
		/**
		 * Assure that all controllers are up and ready befor setting up scroll pane
		 */
		private function setupScrollPane():void {
			if (scrollBar.isReady) {
				scrollPane = new ScrollPane(content.display, contentZone, scrollBar);
			}else {
				scrollBar.onReady.addOnce(setupScrollPane);
			}
		}
		
		//} endregion
		
	}

}