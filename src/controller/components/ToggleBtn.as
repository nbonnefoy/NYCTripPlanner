package controller.components 
{
	import flash.display.MovieClip;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ToggleBtn extends BtnBase
	{
		private var _selected:Boolean = false;
		
		public var selectionChanged:Signal;
		
		//{ region Constructor
		
		public function ToggleBtn(dsp:MovieClip,  id:int = -1, label:String = null) 
		{
			selectionChanged = new Signal(Boolean);
			super(dsp, id, label);
		}
		
		//} endregion
		
		//{ region Public
		
		override public function kill():void {
			selectionChanged.removeAll();
			super.kill();
		}
		
		//} endregion
		
		//{ region Private
		
		override protected function gotoLabel(label:String):void {
			//goto label for sub MCs
			
			if (hasLabel(display.unselectedGfx, label)) {
				display.unselectedGfx.gotoAndPlay(label);
			}
			if (hasLabel(display.selectedGfx, label)) {
				display.selectedGfx.gotoAndPlay(label);
			}
			super.gotoLabel(label);
		}
		
		/**
		 * Test if movie clip has label in its timeline
		 * @param	mc
		 * @param	label
		 * @return
		 */
		private function hasLabel(mc:MovieClip, label:String):Boolean {
			for (var i:int = 0; i < mc.currentLabels.length; i++) {
				if (mc.currentLabels[i].name == label) {
					return true;
				}
			}
			return false;
		}
		
		override protected function clickHandler():void {
			selected = !_selected;
			super.clickHandler();
		}
		
		override protected function updateState():void {
			if ( !display) {
				return;
			}
			display.unselectedGfx.visible = !_selected;
			display.selectedGfx.visible = _selected;
			super.updateState();
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void {
			_selected = value;
			updateState();
			selectionChanged.dispatch(_selected);
		}
		
		//} endregion
		
	}

}