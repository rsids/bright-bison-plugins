package nl.fur.bright.maps.interfaces
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import nl.bs10.brightlib.objects.PolyPage;

	public interface IBrightPolyLine extends IEventDispatcher {
		
		function endPolyLine($value:Boolean):void;
		function getPosition($lat:Number,$lng:Number):Point;
		
		function set polyPage($value:PolyPage):void;
		function get polyPage():PolyPage;
		
		function set visible($value:Boolean):void;
		function get visible():Boolean;
		
		function set color($value:uint):void;
		function get color():uint;
		
	}
}