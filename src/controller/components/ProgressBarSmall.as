package controller.components 
{
	import controller.base.Controller;
	import flash.display.MovieClip;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ProgressBarSmall extends Controller 
	{
		private const barWidth:int = 160;
		private const barHeight:int = 4;
		private const barPosX:int = 1;
		private const barPosY:int = 21;
		
		private var fillShape:Shape;
		private var color:uint;
		
		private var _ratio:Number;
		
		//{ region Constructor
		
		public function ProgressBarSmall(dsp:MovieClip, color:uint = 0x0099FF) 
		{
			this.color = color;
			super(dsp);
		}
		
		override protected function ready():void {
			fillShape = new Shape();
			display.addChild(fillShape);
			display.txtPercent.text = "0 %";
			display.txtLabel.text = "";
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function setLabel(str:String):void {
			display.txtLabel.text = str;
		}
		
		//} endregion
		
		//{ region Private
		
		private function update():void {
			fillShape.graphics.clear();
			fillShape.graphics.beginFill(color);
			fillShape.graphics.drawRect(barPosX, barPosY, int(barWidth * _ratio), barHeight);
			fillShape.graphics.endFill();
			
			display.txtPercent.text = int(_ratio * 100).toString() + " %";
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get ratio():Number { return _ratio; }
		public function set ratio(value:Number):void {
			_ratio = value;
			update();
		}
		
		//} endregion
		
	}

}