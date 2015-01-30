package controller.hud 
{
	import behaviors.DragInput;
	import com.greensock.TweenLite;
	import controller.base.Controller;
	import controller.components.BtnBase;
	import controller.components.MiniMapPoint;
	import controller.components.PointOfInterest;
	import controller.components.ToggleBtn;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import manager.AssetManager;
	import net.I18N;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class MiniMap extends Controller
	{
		private var btnZoomIn:BtnBase;
		private var btnZoomOut:BtnBase;
		private var mapContainer:MovieClip;
		private var radioBtns:Vector.<ToggleBtn>;
		private var mapPoints:Vector.<MiniMapPoint>;
		private var viewGuizmo:Sprite;
		private var viewMask:Shape;
		private var containerRect:Rectangle; //current view size (stage)
		private var guizmoDrawRect:Rectangle;
		private var dragInput:DragInput;
		private var zoomLocked:Boolean = false;
		
		public var onZoomChanged:Signal;
		public var onDrag:Signal;
		
		public var totalZoomLevels:int;
		public var currentZoomIndex:int = -1;
		
		//{ region Constructor
		
		public function MiniMap() 
		{
			var DC_MiniMapView:Class = getDefinitionByName("MiniMapView") as Class;
			super(new DC_MiniMapView());
			
			onZoomChanged = new Signal(int);
			onDrag = new Signal(Rectangle);
			mapPoints = new Vector.<MiniMapPoint>();
		}
		
		override protected function ready():void {
			btnZoomIn = new BtnBase(display.btnZoomIn, 0);
			btnZoomIn.attachToolTip(I18N.getString("ttZoomIn"));
			btnZoomOut = new BtnBase(display.btnZoomOut, 1);
			btnZoomOut.attachToolTip(I18N.getString("ttZoomOut"));
			radioBtns = new Vector.<ToggleBtn>();
			for (var i:int = 0; i < 3; i++) {
				radioBtns.push(new ToggleBtn(display.getChildByName("radioBtn" + i) as MovieClip, i));
			}
			
			//setup map image
			mapContainer = display.mapContainer as MovieClip;
			mapContainer.addChild(AssetManager.getInstance().getImage("miniMap"));
			containerRect = new Rectangle(0, 0, mapContainer.width, mapContainer.height);
			
			//setup view guizmo
			guizmoDrawRect = new Rectangle();
			viewGuizmo = new Sprite();
			viewGuizmo.useHandCursor = viewGuizmo.buttonMode = true;
			viewMask = new Shape();
			display.addChild(viewMask);
			
			display.addChild(viewGuizmo);
			
			initListeners();
			
			setZoom(0);
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		/**
		 * Update rectangle relative size and position (sync from main map)
		 * @param	relPos
		 */
		public function updateViewRect(ratioRect:Rectangle):void {
			dragInput.setRatioRect(ratioRect);
			drawViewGuizmo();
		}
		
		/**
		 * Add a visual point on map from relative coordinates
		 * @param	targetPoint
		 */
		public function addPoint(targetPoint:Point, poi:PointOfInterest):void {
			var tx:Number = targetPoint.x * mapContainer.width;
			var ty:Number = targetPoint.y * mapContainer.height;
			var pointView:MiniMapPoint = new MiniMapPoint(poi);
			
			pointView.display.x = mapContainer.x + tx;
			pointView.display.y = mapContainer.y + ty;
			display.addChild(pointView.display);
			mapPoints.push(pointView);
		}
		
		public function removePoint(poi:PointOfInterest):void {
			for (var i:int = 0; i < mapPoints.length; i++) {
				if (mapPoints[i].poi.id == poi.id) {
					//remove item
					mapPoints[i].kill();
					display.removeChild(mapPoints[i].display);
					mapPoints.splice(i, 1);
					break;
				}
			}
		}
		
		//} endregion
		
		//{ region Private
		
		/**
		 * Change current zoom value and dispatch Signal
		 * @param	val
		 */
		private function setZoom(val:int):void {
			if (currentZoomIndex == val) {
				return;
			}
			
			currentZoomIndex = val;
			
			for (var i:int = 0; i < radioBtns.length; i++) {
				if (i == currentZoomIndex) {
					radioBtns[i].selected = true;
				}else {
					radioBtns[i].selected = false;
				}
			}
			btnZoomIn.enabled = Boolean(currentZoomIndex < totalZoomLevels - 1);
			btnZoomOut.enabled = Boolean(currentZoomIndex > 0);
			dragInput.updateBoundaries(containerRect);
			
			onZoomChanged.dispatch(currentZoomIndex);
		}
		
		private function initListeners():void {
			btnZoomIn.clicked.add(btnZoomClicked);
			btnZoomOut.clicked.add(btnZoomClicked);
			for (var i:int = 0; i < radioBtns.length; i++) {
				radioBtns[i].clicked.add(radioBtnClickHandler);
			}
			
			dragInput = new DragInput(viewGuizmo, containerRect);
			dragInput.useSmoothRelease = false;
			dragInput.onDrag.add(dragHandler);
		}
		
		private function dragHandler():void {
			drawViewGuizmo();
			onDrag.dispatch(dragInput.getRatioRect());
		}
		
		private function btnZoomClicked(id:int):void {
			if (zoomLocked) { return };
			lockZoom();
			if (id == 0) {
				setZoom(Math.min(totalZoomLevels - 1, Math.max(0, currentZoomIndex + 1 )));
			}else {
				setZoom(Math.min(totalZoomLevels - 1, Math.max(0, currentZoomIndex - 1 )));
			}
		}
		
		private function radioBtnClickHandler(id:int):void {
			if (id == currentZoomIndex) {
				radioBtns[id].selected = true;
				return;
			}
			if (zoomLocked) { return };
			lockZoom();
			setZoom(id);
		}
		
		/**
		 * Ad a delay between zoom btns click to prevent error on zoom animation
		 */
		private function lockZoom():void {
			zoomLocked = true;
			TweenLite.delayedCall(0.4, unlockZoom);
		}
		
		private function unlockZoom():void {
			zoomLocked = false;
		}
		
		/**
		 * Draw guizmo rectangle over mini map
		 */
		private function drawViewGuizmo():void {
			guizmoDrawRect.x = mapContainer.x + dragInput.dragRect.x;
			guizmoDrawRect.y = mapContainer.y + dragInput.dragRect.y;
			guizmoDrawRect.width = dragInput.dragRect.width;
			guizmoDrawRect.height = dragInput.dragRect.height;
			
			viewGuizmo.graphics.clear();
			viewGuizmo.graphics.lineStyle(1, 0x000000, 0.6, true);
			viewGuizmo.graphics.drawRect(guizmoDrawRect.x, guizmoDrawRect.y, guizmoDrawRect.width, guizmoDrawRect.height);
			viewGuizmo.graphics.lineStyle(1, 0xffffff, 0.9, true);
			viewGuizmo.graphics.beginFill(0xff0000,0);
			viewGuizmo.graphics.drawRect(guizmoDrawRect.x+1, guizmoDrawRect.y+1, guizmoDrawRect.width-2, guizmoDrawRect.height-2);
			viewGuizmo.graphics.endFill();
			
			viewMask.graphics.clear();
			viewMask.graphics.beginFill(0x000000, 0.2);viewMask.graphics.drawRect(mapContainer.x, mapContainer.y, mapContainer.width, mapContainer.height);
			viewMask.graphics.drawRect(guizmoDrawRect.x, guizmoDrawRect.y, guizmoDrawRect.width, guizmoDrawRect.height);
			viewGuizmo.graphics.endFill();
		}
		
		//} endregion
		
	}

}