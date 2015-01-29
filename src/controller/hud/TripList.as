package controller.hud 
{
	import behaviors.ScrollPane;
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import controller.base.Controller;
	import controller.components.PointOfInterest;
	import controller.components.ScrollBar;
	import controller.components.TripListItem;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class TripList extends Controller
	{
		private var contentZone:MovieClip;
		private var content:Sprite;
		private var scrollBar:ScrollBar;
		private var scrollPane:ScrollPane;
		private var listItems:Vector.<TripListItem>;
		
		public var itemClicked:Signal;
		
		//{ region Constructor
		
		public function TripList() 
		{
			itemClicked = new Signal(Point);
			listItems = new Vector.<TripListItem>();
			
			var DC_TripListPanelView:Class = getDefinitionByName("TripListPanelView") as Class;
			super(new DC_TripListPanelView());
		}
		
		override protected function ready():void {
			contentZone = display.contentZone;
			content = new Sprite();
			display.addChild(content);
			display.scrollBar.visible = false;
			
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		public function removeItem(poi:PointOfInterest):void {
			for (var i:int = 0; i < listItems.length; i++) {
				if (listItems[i].poi.id == poi.id) {
					//remove item
					listItems[i].onClick.remove(itemClicked.dispatch);
					content.removeChild(listItems[i].display);
					listItems.splice(i, 1);
					redraw();
					break;
				}
			}
			
			//anim add on last item
			if (listItems.length == 0) {
				return;
			}
			var lastItemDsp:MovieClip = listItems[listItems.length - 1].display;
			TweenLite.from(lastItemDsp, 0.3, { alpha:0, y: lastItemDsp.y +lastItemDsp.height, ease:Quad.easeOut } );
		}
		
		public function addItem(poi:PointOfInterest):void {
			var item:TripListItem = new TripListItem(poi);
			listItems.push(item);
			item.onClick.add(itemClicked.dispatch);
			content.addChild(item.display);
			redraw();
			//anim add on last item
			var lastItemDsp:MovieClip = listItems[listItems.length - 1].display;
			TweenLite.from(lastItemDsp, 0.3, { alpha:0, y: lastItemDsp.y -lastItemDsp.height, ease:Quad.easeOut } );
		}
		
		//} endregion
		
		//{ region Private
		
		private function redraw():void {
			for (var i:int = 0; i < listItems.length; i++) {
				listItems[i].display.y = i * listItems[i].display.height;
			}
			
			updateScrollPane();
		}
		
		private function updateScrollPane():void {
			//content overflow
			if (content.height > contentZone.height) {
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
					scrollBar.kill();
					scrollPane.kill();
					scrollPane = null;
					scrollBar = null;
				}
				display.scrollBar.visible = false;
				content.x = contentZone.x + display.scrollBar.width/2;
				content.y = contentZone.y;
			}
		}
		
		/**
		 * Assure that all controllers are up and ready befor setting up scroll pane
		 */
		private function setupScrollPane():void {
			if (scrollBar.isReady) {
				scrollPane = new ScrollPane(content, contentZone, scrollBar, false);
			}else {
				scrollBar.onReady.addOnce(setupScrollPane);
			}
		}
		
		//} endregion
	}

}