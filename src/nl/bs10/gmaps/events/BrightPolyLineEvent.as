package nl.bs10.gmaps.events
{
	import flash.events.Event;
	
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.bright.gmaps.components.BrightPoint;

	public class BrightPolyLineEvent extends Event
	{
		public static const POLYLINE_CHANGED:String = "POLYLINE_CHANGED";
		public static const POLYLINE_DELETED:String = "POLYLINE_DELETED";
		public static const POLYLINE_ENDED:String = "POLYLINE_ENDED";
		public static const POLYLINE_POPULATE_COMPLETED:String = "POLYLINE_POPULATE_COMPLETED";
		
		public static const POLYLINE_POINT_MOUSE_OVER:String = "POLYLINE_POINT_MOUSE_OVER";
		public static const POLYLINE_POINT_MOUSE_OUT:String = "POLYLINE_POINT_MOUSE_OUT";
		
		private var _polyPage:PolyPage;
		private var _point:BrightPoint;
		
		public function BrightPolyLineEvent(type:String, polyPage:PolyPage, point:BrightPoint = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_polyPage = polyPage;
			_point = point;
		}
		
		
		public function get polyPage():PolyPage
		{
			return _polyPage;
		}
		
		public function get point():BrightPoint
		{
			return _point;
		}
	}
}