package nl.bs10.gmaps.events
{
	import flash.events.Event;

	public class BrightPointEvent extends Event
	{
		public static const POINT_MOVED:String = "POINT_MOVED";
		public static const POINT_MOVE_ENDED:String = "POINT_MOVE_ENDED";
		
		public static const POINT_REMOVED:String = "POINT_REMOVED";
		public static const POINT_INSERTED:String = "POINT_INSERTED";
		public static const POINT_MOUSE_OVER:String = "POINT_MOUSE_OVER";
		public static const POINT_MOUSE_OUT:String = "POINT_MOUSE_OUT";
		public static const CLOSE_POLYLINE:String = "CLOSE_POLYLINE";
		public static const END_POLYLINE:String = "END_POLYLINE";
		
		public static const SHAPE_CLICK:String = "SHAPE_CLICK";
		
		public function BrightPointEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}