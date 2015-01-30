package controller.screens 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import com.rafaelrinaldi.sound.sound;
	import controller.base.PopupController;
	import controller.hud.TripList;
	import controller.components.Map;
	import controller.hud.MiniMap;
	import controller.components.PointOfInterest;
	import controller.popups.PopupMessage;
	import controller.popups.PopupPoiInfo;
	import controller.hud.Toolbar;
	import controller.popups.PopupTest;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import helper.BitmapTools;
	import net.I18N;
	/**
	 * Main app screen eq : Level.
	 * Instanciate HUD components, map and layers
	 * Manage binding between components
	 * @author Nicolas Bonnefoy
	 */
	public class MapScreen
	{
		private const uiMargin:int = 5;
		
		private var miniMap:MiniMap;
		private var toolbar:Toolbar;
		private var map:Map;
		private var tripList:TripList;
		private var popPoi:PopupController;
		private var stage:Stage;
		private var poiBmp:Bitmap;
		
		//{ region Constructor
		
		public function MapScreen(stage:Stage) 
		{
			this.stage = stage;
		}
		
		public function init():void {
			
			//setup map
			map = new Map();
			stage.addChild(map.display);
			//setup mini map
			miniMap = new MiniMap();
			miniMap.totalZoomLevels = 3;
			stage.addChild(miniMap.display);
			//setup Toolbar
			toolbar = new Toolbar();
			stage.addChild(toolbar.display);
			toolbar.setHighlight(map.iLayer.highlighted);
			toolbar.onHiglightChanged.add(map.iLayer.toggleHightlight);
			toolbar.onDisplayListChanged.add(toggleTripList);
			//setup triplist
			tripList = new TripList();
			stage.addChild(tripList.display);
			tripList.itemClicked.add(map.moveToPoi);
			tripList.display.visible = false;
			
			//bind signals minimap to map
			miniMap.onZoomChanged.add(map.changeZoom);
			miniMap.onDrag.add(map.updateViewRect);
			//bind signals map to minimap
			map.onViewChanged.add(miniMap.updateViewRect);
			//add stage resize listener
			stage.addEventListener(Event.RESIZE, stageResizedHandler);
			//add listener on poi click
			map.iLayer.poiClick.add(poiInfoPopup);
			
			//init view
			updateView();
			
			//display invite popup full screen
			TweenLite.delayedCall(0.3, inviteFullScreenPopup);
			//play main music
			sound().group("music").item("main").play(-1);
		}
		
		//} endregion
		
		//{ region Popups
		
		/**
		 * Add popin to invite user to switch to full screen
		 */
		private function inviteFullScreenPopup():void {
			if (toolbar.btnFullScreen.selected) { //already full screen
				return;
			}
			
			var popFullScreen:PopupMessage = new PopupMessage(I18N.getString("titlePlayFullScreen"), I18N.getString("contentPlayFullScreen"), true);
			popFullScreen.strBtnCancel = I18N.getString("btnFullScreenNok");
			popFullScreen.strBtnValid = I18N.getString("btnFullScreenOk");
			
			popFullScreen.onValidClick.addOnce(function():void {
				stage.displayState = StageDisplayState.FULL_SCREEN; 
			});
			stage.addChild(popFullScreen.display);
		}
		
		/**
		 * Display poi info popup
		 * @param	poi
		 */
		private function poiInfoPopup(poi:PointOfInterest):void {
			popPoi = poi.id == 777 ? new PopupTest(poi) : new PopupPoiInfo(poi);
			stage.addChild(popPoi.display);
			popPoi.popOutComplete.addOnce(map.iLayer.popClosedHandler);
			popPoi.onValidClick.addOnce(popPoiValidClickedHandler);
		}
		
		/**
		 * Popup poi valid button clicked : Add to or Remove POI from List
		 * @param	poi
		 */
		private function popPoiValidClickedHandler(poi:PointOfInterest):void {
			if (poi.selected) {
				//add list item
				popPoi.popOutComplete.addOnce(function ():void {
					playPoiSelectedAnim(poi);
				});
			}else {
				//remove list item
				popPoi.popOutComplete.addOnce(function ():void {
					toolbar.playBtnListNotifAnim();
					tripList.removeItem(poi);
					miniMap.removePoint(poi);
				});
			}
			
			popPoi.close();
		}
		
		//} endregion
		
		//{ region POI
		
		/**
		 * tween poi bmp to toolbar List button
		 */
		private function playPoiSelectedAnim(poi:PointOfInterest):void {
			poiBmp = new Bitmap(BitmapTools.alphaCutout(BitmapTools.cropBitmap(map.currentBmpSrc, poi.scaledRect), poi.getScaledBitmapData()));
			poiBmp.x = poi.scaledRect.x + map.iLayer.display.x;
			poiBmp.y = poi.scaledRect.y + map.iLayer.display.y;
			poiBmp.bitmapData.applyFilter(poiBmp.bitmapData, poiBmp.bitmapData.rect, poiBmp.bitmapData.rect.topLeft, new GlowFilter(0, 1, 6, 6, 4, 1, true, false));
			stage.addChild(poiBmp);
			
			miniMap.addPoint(map.getRelativeCoord(poi.getScaledCenterPosition()), poi);
			
			var ratio:Number = Math.min(toolbar.btnList.display.width/poiBmp.width, toolbar.btnList.display.height/poiBmp.height);
			var dstPt:Point = toolbar.btnList.display.localToGlobal(new Point(toolbar.btnList.display.width / 2, toolbar.btnList.display.height / 2));
			TweenLite.to(poiBmp, 0.8, { transformAroundCenter: { x:dstPt.x, y:dstPt.y, scale:ratio }, ease:Quad.easeOut, onComplete:poiSelectedAnimComplete, onCompleteParams:[poi] } );
		}
		
		/**
		 * Select poi animation complete : add poi item to trip list and to minimap
		 * @param	poi
		 */
		private function poiSelectedAnimComplete(poi:PointOfInterest):void {
			tripList.addItem(poi);
			toolbar.playBtnListNotifAnim();
			stage.removeChild(poiBmp);
			poiBmp.bitmapData.dispose();
			poiBmp = null;
		}
		
		//} endregion
		
		//{ region HUD
		
		/**
		 * Toggle tripList visible / hidden
		 */
		private function toggleTripList(visible:Boolean):void {
			if (visible) {
				TweenLite.fromTo(tripList.display, 0.3, { autoAlpha:0, x: -tripList.display.width }, { autoAlpha:1, x:uiMargin, ease:Quad.easeOut } );
			}else {
				TweenLite.to(tripList.display, 0.3, { autoAlpha:0, x:-tripList.display.width, ease:Quad.easeIn } );
			}
		}
		
		private function stageResizedHandler(e:Event):void {
			updateView();
		}
		
		private function updateView():void {
			//replace UI
			miniMap.display.x = stage.stageWidth - miniMap.display.width - uiMargin;
			miniMap.display.y = stage.stageHeight - miniMap.display.height - uiMargin;
			
			toolbar.display.x = uiMargin;
			toolbar.display.y = uiMargin;
			
			tripList.display.x = uiMargin;
			tripList.display.y = toolbar.display.y + toolbar.display.height + 2 * uiMargin;
			
			//recalculate map
			map.resize();
		}
		
		//} endregion
		
	}

}