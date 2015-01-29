package controller.popups 
{
	import controller.base.PopupController;
	import controller.components.BtnBase;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import helper.TextTools;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class PopupMessage extends PopupController 
	{
		private var btnClose:BtnBase;
		private var btnValid:BtnBase;
		private var btnRefuse:BtnBase;
		private var txtTitle:TextField;
		private var txtContent:TextField;
		private var txtContentRect:Rectangle;
		private var txtTitleRect:Rectangle;
		
		public var onValidClick:Signal;
		public var validated:Boolean = false;
		public var autoClose:Boolean = false;
		
		private var _strTitle:String;
		private var _strContent:String;
		private var _strBtnValid:String;
		private var _strBtnRefuse:String;
		
		//{ region Constructor
		
		public function PopupMessage(title:String ="", content:String ="", autoClose:Boolean = false) 
		{
			this.autoClose = autoClose;
			_strTitle = title;
			_strContent = content;
			onValidClick = new Signal();
			hasShader = true;
			autoCenter = true;
			
			var DC_PopupMessageView:Class = getDefinitionByName("PopupMessageView") as Class;
			super(new DC_PopupMessageView());
		}
		
		override protected function ready():void {
			btnClose = new BtnBase(display.btnClose, 0);
			btnClose.clicked.addOnce(close);
			
			btnRefuse = new BtnBase(display.btnRefuse, 1);
			btnRefuse.clicked.addOnce(close);
			
			btnValid = new BtnBase(display.btnValid, 2);
			btnValid.clicked.addOnce(validClickHandler);
			
			txtTitle = display.txtTitle;
			txtContent = display.txContent;
			
			//save original txt bounds to center later
			txtContentRect = txtContent.getRect(display).clone();
			txtTitleRect = txtTitle.getRect(display).clone();
			
			updateContent();
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function close(id:*= null):void {
			validated = false;
			popOut();
		}
		
		//} endregion
		
		//{ region Private
		
		private function updateContent():void {
			btnValid.label = _strBtnValid;
			
			txtTitle.htmlText = _strTitle;
			TextTools.fitTextIn(txtTitle, txtTitleRect.width);
			
			txtContent.htmlText = _strContent;
			
			//TextTools.fitTextIn(txtContent, txtContentRect.width, txtContentRect.height);
			TextTools.vAlign(txtContent, txtContentRect);
				
			if (_strBtnRefuse.length > 1) {
				btnRefuse.display.visible = true;
				btnRefuse.label = _strBtnRefuse;
			}else {
				btnRefuse.display.visible = false;
				display.background.heigth -= btnRefuse.display.height;
			}
		}
		
		private function validClickHandler(id:*= null):void {
			validated = true;
			onValidClick.dispatch();
			if (autoClose) {
				popOut();
			}
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get strTitle():String { return _strTitle; }
		public function set strTitle(value:String):void {
			_strTitle = value;
		}
		
		public function get strContent():String { return _strContent; }
		public function set strContent(value:String):void {
			_strContent = value;
		}
		
		public function get strBtnValid():String { return _strBtnValid; }
		public function set strBtnValid(value:String):void {
			_strBtnValid = value;
		}
		
		public function get strBtnRefuse():String { return _strBtnRefuse; }
		public function set strBtnRefuse(value:String):void {
			_strBtnRefuse = value;
		}
		
		//} endregion
		
	}

}