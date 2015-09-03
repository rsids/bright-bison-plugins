package nl.fur.bright.maps.interfaces {
	
	import nl.bs10.brightlib.objects.MarkerPage;
	
	public interface IBrightMarker {
		
		function set layer($value:int):void;
		function get layer():int;
		
		function set markerlabel($value:String):void
		function get markerlabel():String;
		
		function set color($value:uint):void
		function get color():uint;
	
		function set uselayercolor($value:Boolean):void
		function get uselayercolor():Boolean 

		function set parent($value:IMapAppController):void
		function get parent():IMapAppController;

		function set markerprops($value:MarkerPage):void
		function get markerprops():MarkerPage;
		
		function set visible($value:Boolean):void;
		function get visible():Boolean;

		function destroy():void;
	}
}