package nl.fur.bright.maps.interfaces
{
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;
	
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.bs10.brightlib.objects.PolyPage;
	
	public interface IMapController extends IUIComponent
	{
		function IMapController(apikey:String):void;
		
		function addShape(polyPage:PolyPage):IBrightPolyLine;
		
		function addMarker(lat:Number, lng:Number):IBrightMarker;
		
		function destroy():void;
		
		function destroyMarker($marker:IBrightMarker):void;

		function zoom(direction:int):void;
		
		/*function set markers($value:Vector.<IBrightMarker>):void;
		function get markers():Vector.<IBrightMarker>;*/
		
		function set polys($value:Vector.<IBrightPolyLine>):void;
		function get polys():Vector.<IBrightPolyLine>;
		
		function set zoomvalue($value:Number):void;
		function get zoomvalue():Number;
		
		function set lat($value:Number):void;
		function get lat():Number;
		
		function set lng($value:Number):void;
		function get lng():Number;
		
		function set maptype($value:String):void;
		function get maptype():String;
		
		
		function set parentApp($value:IMapAppController):void
		function get parentApp():IMapAppController;
	}
}