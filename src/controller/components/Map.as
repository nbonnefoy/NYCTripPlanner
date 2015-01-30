package controller.components {
	import behaviors.DragInput;
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import com.rafaelrinaldi.sound.sound;
	import controller.base.Controller;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import manager.AssetManager;
	import org.osflash.signals.Signal;
	
	/**
	 * Map controller.
	 * Manage main map (canvas) display and interaction using DragInput and InteractiveLayer.
	 * @author Nicolas Bonnefoy
	 */
	public class Map extends Controller
	{
		private const zoomPercents:Vector.<int> = new <int>[25,50,100];
		private const oPoint:Point = new Point();
		
		private var zoomLevel:int = 0;
		private var canvasContainer:Sprite;
		private var bitmapDrawRect:Rectangle; //rectangle used to copy pixels
		private var dragInput:DragInput;
		private var mapTween:TweenLite;
		
		public var canvas:Bitmap;
		public var currentBmpSrc:BitmapData;
		public var iLayer:InteractiveLayer;
		public var onViewChanged:Signal;
		
		//{ region Constructor
		
		public function Map() 
		{
			onViewChanged = new Signal(Rectangle);
			super(new MovieClip());
		}
		
		override protected function ready():void {
			//add canvas : main map bitmap container
			canvasContainer = new Sprite();
			display.addChild(canvasContainer);
			canvas = new Bitmap(new BitmapData(display.stage.stageWidth, display.stage.stageHeight), PixelSnapping.NEVER, true);
			bitmapDrawRect = canvas.bitmapData.rect.clone();
			
			canvasContainer.addChild(canvas);
			
			setSourceBitmap();
			
			//init drag listerners
			dragInput = new DragInput(canvasContainer, currentBmpSrc.rect);
			dragInput.reverseControl = true;
			dragInput.onDrag.add(dragHandler);
			dragInput.onRelease.add(dragReleaseHandler);
			
			//add interactive layer
			iLayer = new InteractiveLayer();
			iLayer.mouseCaptureLayer = canvasContainer;
			display.addChild(iLayer.display);
			
			setZoom(0);
			super.ready();
		}
		
		//} endregion
		
		//{ region Public
		
		/**
		 * recalculate map size and coords
		 */
		public function resize():void {
			resizeViewport(currentBmpSrc.rect);
			setZoom(zoomLevel);
		}
		
		/**
		 * Return relative coord of a point on map
		 * @return
		 */
		public function getRelativeCoord(targetPoint:Point):Point {
			var pt:Point = new Point();
			pt.x = targetPoint.x / currentBmpSrc.width;
			pt.y = targetPoint.y / currentBmpSrc.height;
			return pt;
		}
		
		/**
		 * Move and center to poi. Takes absolute scaled rect as argument.
		 * @param	toRect
		 */
		public function moveToPoi(targetPoint:Point):void {
			//get relative coords
			var pt:Point = getRelativeCoord(targetPoint);
			var rect:Rectangle = dragInput.getRatioRect().clone();
			//clamp values and center on viewport
			pt.x = Math.min(1 - rect.width, Math.max(0, pt.x - rect.width * 0.5));
			pt.y = Math.min(1 - rect.height, Math.max(0, pt.y - rect.height * 0.5));
			
			//tween to desired position
			sound().item("snd_slide").play();
			mapTween = TweenLite.to(rect, 0.4, { x:pt.x, y:pt.y, onUpdate:moveToPoiAnimUpdate, onUpdateParams:[rect], ease:Quad.easeOut } );
		}
		
		/**
		 * Update view from ratio rect on drag from mini map handler
		 * @param	ratioRect
		 */
		public function updateViewRect(ratioRect:Rectangle):void {
			dragInput.setRatioRect(ratioRect);
			updateBitmapDrawRect(dragInput.dragRect);
			drawMap();
		}
		
		/**
		 * Tween to new zoom value
		 * @param	val
		 */
		public function changeZoom(val:int):void {
			if (val == zoomLevel) {
				return;
			}
			
			sound().item(zoomLevel < val ? "snd_grow" : "snd_reduce").play();
			iLayer.enabled = false;
			var scale:Number = zoomPercents[val] / zoomPercents[zoomLevel];
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 1, 1);
			mapTween = TweenLite.to(matrix, 0.4, { a:scale, d:scale, onUpdate:changeZoomAnimUpdate, onUpdateParams:[matrix], onComplete:setZoom, onCompleteParams:[val] } );
		}
		
		//} endregion
		
		//{ region Private
		
		private function tweenIsPlaying():Boolean {
			if (mapTween && mapTween.ratio < 1) {
				return true;
			}
			return false;
		}
		
		/**
		 * Drag map handler
		 * @param	translation
		 */
		private function dragHandler():void {
			if (tweenIsPlaying()) {
				//prevent errors when tween is active
				return;
			}
			iLayer.enabled = false;
			onViewChanged.dispatch(dragInput.getRatioRect());
			updateBitmapDrawRect(dragInput.dragRect);
			drawMap();
		}
		
		private function dragReleaseHandler():void {
			iLayer.enabled = true;
		}
		
		private function updateBitmapDrawRect(pos:Rectangle):void {
			bitmapDrawRect.x = pos.x;
			bitmapDrawRect.y = pos.y;
		}
		
		/**
		 * Update moveToPoi transition : set view rect and notify minimap
		 * @param	ratioRect
		 */
		private function moveToPoiAnimUpdate(ratioRect:Rectangle):void {
			updateViewRect(ratioRect);
			onViewChanged.dispatch(ratioRect);
		}
		
		/**
		 * Draw scaled bitmap source, used in zoom transition on update
		 * @param	matrix
		 */
		private function changeZoomAnimUpdate(matrix:Matrix):void {
			var scaledRect:Rectangle = currentBmpSrc.rect.clone();
			scaledRect.width *= matrix.a;
			scaledRect.height *= matrix.d;
			
			//update viewport to get correct translation
			resizeViewport(scaledRect);
			
			//draw scaleed bitmap
			updateBitmapDrawRect(dragInput.dragRect);
			matrix.tx = -dragInput.dragRect.x;
			matrix.ty = -dragInput.dragRect.y;
			canvas.bitmapData.draw(currentBmpSrc, matrix, null, null, null, false);
			iLayer.updateScale(zoomPercents[zoomLevel] * 0.01 * matrix.a);
			iLayer.updatePosition(bitmapDrawRect.x - canvas.x, bitmapDrawRect.y - canvas.y);
			
			//update minimap
			onViewChanged.dispatch(dragInput.getRatioRect());
		}
		
		/**
		 * Change zoom +1 or -1 and redraw canvas
		 * @param	val
		 */
		private function setZoom(val:int):void {
			canvasContainer.transform.matrix = new Matrix();
			zoomLevel = val;
			setSourceBitmap();
			if ((currentBmpSrc.rect.width < display.stage.stageWidth) || (currentBmpSrc.rect.height < display.stage.stageHeight)) {
				resizeViewport(currentBmpSrc.rect);
			}else {
				dragInput.updateBoundaries(currentBmpSrc.rect);
			}
			updateBitmapDrawRect(dragInput.dragRect);
			drawMap();
			onViewChanged.dispatch(dragInput.getRatioRect());
			iLayer.updateScale(zoomPercents[zoomLevel] * 0.01);
			iLayer.enabled = true;
		}
		
		/**
		 * Switch canvas's bitmap
		 */
		private function setSourceBitmap():void {
			//currentBmpSrc.unlock();
			currentBmpSrc = AssetManager.getInstance().getImage("map" + zoomPercents[zoomLevel].toString() ).bitmapData;
			currentBmpSrc.lock();
		}
		
		/**
		 * Draw visible rect from source bitmap data
		 */
		private function drawMap():void {
			canvas.bitmapData.copyPixels(currentBmpSrc, bitmapDrawRect, oPoint);
			iLayer.updatePosition(bitmapDrawRect.x - canvas.x, bitmapDrawRect.y - canvas.y);
		}
		
		/**
		 * Resize bitmap canvas and view rect relatively to stage and source bitmap
		 * @param	bmpSrcRect
		 */
		private function resizeViewport(bmpSrcRect:Rectangle):void {
			canvas.bitmapData = new BitmapData(Math.min(bmpSrcRect.width, display.stage.stageWidth), Math.min(bmpSrcRect.height, display.stage.stageHeight));
			bitmapDrawRect = canvas.bitmapData.rect.clone();
			
			canvas.x = (display.stage.stageWidth - canvas.width) / 2;
			canvas.y = (display.stage.stageHeight - canvas.height) / 2;
			dragInput.updateContainer(canvasContainer);
			dragInput.updateBoundaries(bmpSrcRect);
		}
		
		//} endregion
		
	}

}