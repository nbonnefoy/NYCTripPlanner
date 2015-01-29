package controller.components 
{
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class SimpleVideo extends Sprite
	{
		private var url:String;
		private var ns:NetStream;
		private var nc:NetConnection;
		private var vid:Video;
		
		public function SimpleVideo(url:String) 
		{
			this.url = url;
			super();
		}
		
		public function play():void {
			nc = new NetConnection(); 
			nc.connect(null); 
			var customClient:Object = new Object();
			customClient.onMetaData = metaDataHandler;
			
			ns = new NetStream(nc); 
			ns.client = customClient;
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
			ns.play(url); 
			
			vid = new Video();
			vid.attachNetStream(ns); 
			addChild(vid); 
		}
		
		private function metaDataHandler(infoObject:Object):void {
			vid.width = infoObject.width;
			vid.height = infoObject.height;
		}
		
		public function stop():void {
			ns.pause(); 
			ns.seek(0); 
			nc.close();
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void { 
			// ignore error 
		} 
		
	}

}