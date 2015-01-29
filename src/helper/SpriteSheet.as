package helper 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * SpriteSheet Object is a combination of a bitmap and its coordinates datafile
	 * @author Nicolas Bonnefoy
	 */
	public class SpriteSheet 
	{
		private var spNameList:Vector.<String>;
		private var _sheet:BitmapData;
		private var _data:String;
		private var _jsonObject:Object;
		private var _name:String;
		
		//{ region Constructor
		
		public function SpriteSheet(atlas:BitmapData, coordinates:String) 
		{
			_sheet = atlas;
			_data = coordinates;
			
			parseJsonData();
		}
		
		/**
		 * Parse data, get name, create jsonObject and sprite name list
		 */
		private function parseJsonData():void {
			_jsonObject = new Object();
			_jsonObject = JSON.parse(_data);
			_name = _jsonObject.meta.image;
			spNameList = new Vector.<String>();
			for (var i:int = 0; i < _jsonObject.frames.length; i++) {
				spNameList.push(_jsonObject.frames[i].filename);
			}
		}
		
		//} endregion
		
		//{ region Public
		
		public function getSpriteById(id:int):BitmapData {
			var output:BitmapData;
			var spd:Object = _jsonObject.frames[id];
			//create bitmap data
			output = new BitmapData(spd.sourceSize.w, spd.sourceSize.h, true, 0x00000000);
			
			//copy pixels into bitmap data
			var rect:Rectangle = new Rectangle(spd.frame.x, spd.frame.y, spd.frame.w, spd.frame.h);
			output.copyPixels(_sheet, rect, new Point(spd.spriteSourceSize.x, spd.spriteSourceSize.y));
			return output;
		}
		
		public function hasSprite(sName:String):Boolean {
			return spNameList.indexOf(sName) == -1 ? false : true;
		}
		
		/**
		 * Get a sprite stored in this spriteSheet
		 * @param	sName
		 * @return BitmapData
		 */
		public function getSpriteByName(sName:String):BitmapData {
			
			var idx:int = spNameList.indexOf(sName);
			//test if name exists
			if (idx == -1) {
				throw new Error("Sprite name " + sName + " not found in spriteSheet " + _name + ".", 500);
				return null;
			}
			return getSpriteById(idx);
		}
		
		//} endregion
		
		//{ region Accessors
		
		public function get sheet():BitmapData { return _sheet; }
		public function set sheet(value:BitmapData):void { _sheet = value; }
		
		public function get data():String { return _data; }
		public function set data(value:String):void { _data = value; }
		
		public function get jsonObject():Object { return _jsonObject; }
		
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		//} endregion
		
	}

}