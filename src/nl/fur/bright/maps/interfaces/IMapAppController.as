package nl.fur.bright.maps.interfaces
{
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;
	import nl.bs10.brightlib.objects.MarkerPage;

	public interface IMapAppController extends IUIComponent
	{
		
		function set deleteMarkerTimeout($value:uint):void;
		function get deleteMarkerTimeout():uint;
		function set pluginmode($value:Boolean):void;
		function get pluginmode():Boolean;
		
		function get parentApplication():Object;
		
		function set map($value:IMapController):void;
		function get map():IMapController;
		
		function editMarker($marker:MarkerPage):void;
		
		function removePolyLines(layer:uint):void;
		function removeMarkers(layer:uint):void;
		
		function updatePolyLines(layer:uint, color:uint):void;
		function updateMarkers(layer:uint, color:uint):void;
		function updateMarker($marker:MarkerPage):void;
		
		function getMarkers(layer:uint):void;
		
		function hideMarkerDelete():void;
		function showMarkerDelete($bounds:Rectangle, $markerId:uint):void;
	}
}