package vo 
{
	/**
	 * Value Object for POI Data
	 * @author Nicolas Bonnefoy
	 */
	public class PoiData 
	{
		public var name:String;
		public var title:String;
		public var desc:String;
		public var imgPath:String;
		public var vidPath:String;
		
		/**
		 * Value Object for POI data (from json)
		 * @param	rawData
		 */
		public function PoiData(rawData:XML) 
		{
			name = rawData.@name;
			title = rawData.title;
			desc = rawData.desc;
			imgPath = rawData.img;
		}
		
	}

}