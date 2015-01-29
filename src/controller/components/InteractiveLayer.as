package controller.components {
	import controller.base.Controller;
	import controller.components.PointOfInterest;
	import controller.components.ToolTip;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import fx.ZoneParticleFx;
	import helper.LoaderHelper;
	import org.osflash.signals.Signal;
	
	/**
	 * Interative map layer, contain and manage hightlight and click on points of interests using
	 * pixel hit test to detect collision on POIs.
	 * @author Nicolas Bonnefoy
	 */
	public class InteractiveLayer extends Controller
	{
		private var _enabled:Boolean;
		private var _popIsDisplayed:Boolean = false;
		private var _highlighted:Boolean = true;
		private var mouseOverPoi:Boolean = false;
		
		private var scaleRatio:Number = 1;
		private var pois:Vector.<PointOfInterest>;
		private var currentPoiIndex:int = -1;
		private var lastPoiIndex:int = -1;
		private var particleFX:ZoneParticleFx;
		private var toolTip:ToolTip;
		
		public var mouseCaptureLayer:Sprite;
		public var poiClick:Signal;
		private var hlcb:HLCB;
		
		//{ region Constructor
		
		public function InteractiveLayer() 
		{
			poiClick = new Signal(PointOfInterest);
			super(new MovieClip());
		}
		
		override protected function ready():void {
			display.mouseChildren = display.mouseEnabled = false;
			loadConf();
			toolTip = new ToolTip("");
			display.stage.addChild(toolTip.display);
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		/**
		 * Popin closed refresh state
		 */
		public function popClosedHandler():void {
			_popIsDisplayed = false;
			_enabled = true;
			updateState();
		}
		
		public function updateScale(scale:Number):void {
			scaleRatio = scale;
			display.scaleX = display.scaleY = scaleRatio;
			for (var i:int = 0; i < pois.length; i++) {
				pois[i].currentScaleRatio = scaleRatio;
			}
		}
		
		public function updatePosition(px:Number, py:Number):void {
			if (particleFX) {
				particleFX.x -= display.x+px;
				particleFX.y -= display.y+py;
			}
			display.x = -px;
			display.y = -py;
		}
		
		/**
		 * Set hightlighted buildings on/off
		 * @param	value
		 */
		public function toggleHightlight(value:Boolean):void {
			_highlighted = value;
			for (var i:int = 0; i < pois.length; i++) {
				pois[i].highLighted = _highlighted;
			}
		}
		
		//} endregion
		
		//{ region Private
		
		private function loadConf():void {
			pois = new Vector.<PointOfInterest>();
			var ldr:LoaderHelper = new LoaderHelper();
			ldr.callback.addOnce(parseConf);
			ldr.load("data/pois.json");
		}
		
		private function parseConf(data:String):void {
			var jsonData:Object = JSON.parse(data);
			for (var i:int = 0; i < jsonData.pois.length; i++) {
				pois.push(new PointOfInterest(jsonData.pois[i], i));
			}
			hlcb = new HLCB();
			pois.push(hlcb);
			drawPois();
		}
		
		private function drawPois():void {
			for (var i:int = 0; i < pois.length; i++) {
				display.addChild(pois[i].display);
				pois[i].setPosition();
				pois[i].currentScaleRatio = scaleRatio;
				pois[i].onFocusIn.addOnce(onPoiFocusIn);
			}
		}
		
		private function updateState():void {
			if (currentPoiIndex != -1) {
				poiMouseOut();
			}
			
			if ((_enabled == true) && (_popIsDisplayed == false)) {
				mouseCaptureLayer.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				mouseCaptureLayer.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			}else {
				mouseCaptureLayer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				mouseCaptureLayer.removeEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			}
		}
		
		/**
		 * Hit test to detect mouse Over POI
		 */
		private function hitTest():void {
			var foundId:int = -1;
			//break if hit on same POI than previous one
			if ((currentPoiIndex != -1) && pois[currentPoiIndex].hitTest()) {
				return;
			}
			//perform hit test on each POI
			for (var i:int = 0; i < pois.length; i++) {
				if (pois[i].hitTest()) {
					foundId = i;
					break;
				}
			}
			
			//unselect prev poi and kill listener
			if (currentPoiIndex != -1) {
				poiMouseOut();
			}
			
			//select new POI if found and listend for click
			currentPoiIndex = foundId;
			if (foundId != -1) {
				pois[foundId].focused = true;
				poiMouseOver();
			}
		}
		
		//{ region POI envent handlers
		
		/**
		 * Unselect POI and remove current click listener if mouse out of clickable zone
		 * @param	e
		 */
		private function mouseOutHandler(e:MouseEvent):void {
			if (currentPoiIndex != -1) {
				poiMouseOut();
			}
		}
		
		private function mouseMoveHandler(e:MouseEvent):void {
			if (e.buttonDown) { //drag begin
				return;
			}
			hitTest();
		}
		
		/**
		 * Mouse is over a POI, set mouse click listener ON
		 */
		private function poiMouseOver():void {
			Mouse.cursor = MouseCursor.BUTTON;
			mouseCaptureLayer.addEventListener(MouseEvent.CLICK, clickHandler);
			
			toolTip.text = pois[currentPoiIndex].data.title;
			toolTip.show();
		}
		
		/**
		 * Add particle fx on poi mouse over
		 * @param	poiId
		 */
		private function onPoiFocusIn(poiId:uint):void {
			pois[poiId].onFocusOut.addOnce(onPoiFocusOut);
			particleFX = new ZoneParticleFx(pois[poiId].getScaledBitmapData(), 10+20 * scaleRatio);
			particleFX.x = display.x + pois[poiId].scaledRect.x;
			particleFX.y = display.y + pois[poiId].scaledRect.y;
			display.parent.addChild(particleFX);
		}
		
		private function onPoiFocusOut(poiId:uint):void {
			pois[poiId].onFocusIn.addOnce(onPoiFocusIn);
			particleFX.kill();
		}
		
		/**
		 * Set poi state to idle
		 * Set mouse click OFF and reset current POI index
		 */
		private function poiMouseOut():void {
			mouseCaptureLayer.removeEventListener(MouseEvent.CLICK, clickHandler);
			Mouse.cursor = MouseCursor.AUTO;
			
			pois[currentPoiIndex].focused = false;
			lastPoiIndex = currentPoiIndex;
			currentPoiIndex = -1;
			toolTip.hide();
		}
		
		/**
		 * POI Click handler : lock iLayer and add poin
		 * @param	e
		 */
		private function clickHandler(e:MouseEvent):void {
			if (_enabled == false) {
				return;
			}
			_popIsDisplayed = true;
			_enabled = false;
			poiClick.dispatch(pois[currentPoiIndex]);
			poiMouseOut();
			updateState();
		}
		
		//} endregion
		
		//} endregion
		
		//{ region Accessors
		
		/**
		 * Lock/unlock user input
		 */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void {
			if (_enabled == value) {
				return;
			}
			if (_popIsDisplayed) {
				_enabled = false;
				return;
			}
			_enabled = value;
			updateState();
		}
		
		public function get highlighted():Boolean { return _highlighted; }
		
		public function get popIsDisplayed():Boolean { return _popIsDisplayed; }
		
		//} endregion
	}

}