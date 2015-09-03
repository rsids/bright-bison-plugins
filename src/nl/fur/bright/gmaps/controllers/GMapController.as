package nl.fur.bright.gmaps.controllers
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapType;
	import com.google.maps.interfaces.IMarker;
	import com.google.maps.interfaces.IOverlay;
	import com.google.maps.interfaces.IPolyline;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.bright.gmaps.components.BrightPolyLine;
	import nl.fur.bright.gmaps.components.GMapsMarker;
	import nl.fur.bright.maps.interfaces.IBrightMarker;
	import nl.fur.bright.maps.interfaces.IBrightPolyLine;
	import nl.fur.bright.maps.interfaces.IMapAppController;
	import nl.fur.bright.maps.interfaces.IMapController;
	
	public class GMapController extends UIComponent implements IMapController {

		private var _markers:Vector.<IBrightMarker>;
		private var _markersChanged:Boolean;
		
		private var _polys:Vector.<IBrightPolyLine>;
		private var _polysChanged:Boolean;
		private var _apikey:String;
		
		
		private var _lng:Number;
		private var _latLngChanged:Boolean;
		
		private var _parentApp:IMapAppController;
		
		private var _lat:Number;
		private var _zoomValue:Number;
		private var _zoomValueChanged:Boolean;
		
		private var _mapReady:Boolean;
		
		public var map:Map;
		
		public function GMapController($apikey:String)
		{
			super();
			_apikey = $apikey;
			percentHeight = 100;
			percentWidth = 100;
		}
		
		public function addShape(polyPage:PolyPage):IBrightPolyLine {
			var pl:IBrightPolyLine = new BrightPolyLine(polyPage);
			map.addOverlay(pl as IOverlay);
			return pl;
		}
		
		
		public function destroy():void {
			map.deleteReferenceOnParentDocument(this);
		}
		
		public function destroyMarker(marker:IBrightMarker):void {
			map.removeOverlay(marker as IOverlay);
		}
		
		public function removePolyLines(layer:uint):void {
		}
		
		public function removePolyShapes(layer:uint):void {
		}
		
		public function removeMarkers(layer:uint):void {
		}
		
		public function zoom(direction:int):void {
			map.setZoom(map.getZoom() + direction);
		}
		
		public function addMarker(lat:Number, lng:Number):IBrightMarker {
			var marker:IBrightMarker = new GMapsMarker(new LatLng(lat, lng));
			marker.parent = parentApp;
			map.addOverlay(marker as IMarker);
			return marker;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			map = new Map();
			map.key = _apikey;
			map.x = 0;
			map.y = 0;
			map.percentHeight = 100;
			map.percentWidth = 100;
			map.sensor = "false";
			
			
			map.addEventListener("mapevent_mapready", _onMapReady);
			
			addChild(map);
			addEventListener(ResizeEvent.RESIZE, _onResize, false, 0, true);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(!_mapReady)
				return;
			
			
			if(_zoomValueChanged) {
				_zoomValueChanged = false;
				map.setZoom(_zoomValue);
			}
			
			if(_latLngChanged && !isNaN(_lat) && !isNaN(_lng)) {
				_latLngChanged = false;
				map.setCenter(new LatLng(_lat, _lng));
			}
			
			if(_maptypeChanged) {
				_maptypeChanged = false;
				switch(maptype) {
					case 'HYBRID':
						map.setMapType(MapType.HYBRID_MAP_TYPE);	
						break;
					case 'ROADMAP':
						map.setMapType(MapType.NORMAL_MAP_TYPE);	
						break;
					case 'SATELLITE':
						map.setMapType(MapType.SATELLITE_MAP_TYPE);	
						break;
					case 'TERRAIN':
						map.setMapType(MapType.PHYSICAL_MAP_TYPE);	
						break;
				}
			}
			
		}
		
		/**
		 * _onMapReady function
		 * @param event The event  
		 **/
		private function _onMapReady(event:Event):void {
			_mapReady = true;
			map.enableScrollWheelZoom();
			invalidateProperties();
			
			dispatchEvent(new Event('mapReady'));
		}
		/**
		 * _onResize function
		 *  
		 **/
		private function _onResize(event:ResizeEvent):void {
			map.height = height;
			map.width = width;
		}
		
		[Bindable(event="defaultLatChanged")]
		public function set lng($value:Number):void {
			if($value !== _lng) {
				_lng = $value;
				_latLngChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("defaultLatChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the defaultLat property
		 **/
		public function get lng():Number {
			if(_mapReady)
				return map.getCenter().lng();
			return _lng;
		}
		
		
		[Bindable(event="defaultLngChanged")]
		public function set lat($value:Number):void {
			if($value !== _lat) {
				_lat = $value;
				_latLngChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("defaultLngChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the defaultLng property
		 **/
		public function get lat():Number {
			if(_mapReady)
				return map.getCenter().lat();
			return _lat;
		}
		
		private var _maptype:String;
		private var _maptypeChanged:Boolean;
		
		
		[Bindable(event="maptypeChanged")]
		public function set maptype($value:String):void {
			if($value !== _maptype) {
				_maptype = $value;
				_maptypeChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("maptypeChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the maptype property
		 **/
		public function get maptype():String {
			return _maptype;
		}
		
		
		public function set parentApp(value:IMapAppController):void {
			if(value !== _parentApp) {
				_parentApp = value;
				
			}
		}
		
		public function get parentApp():IMapAppController {
			return _parentApp;
		}
		
		
		[Bindable(event="defaultZoomChanged")]
		public function set zoomvalue($value:Number):void {
			if($value !== _zoomValue) {
				_zoomValue = $value;
				_zoomValueChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("defaultZoomChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the defaultZoom property
		 **/
		public function get zoomvalue():Number {
			if(_mapReady)
				return map.getZoom();
			return _zoomValue;
		}
		
		[Bindable(event="markersChanged")]
		public function set markers($value:Vector.<IBrightMarker>):void {
			if($value !== _markers) {
				_markers = $value;
				_markersChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("markersChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the markers property
		 **/
		public function get markers():Vector.<IBrightMarker> {
			return _markers;
		}
		
		
		[Bindable(event="polysChanged")]
		public function set polys($value:Vector.<IBrightPolyLine>):void {
			if($value !== _polys) {
				_polys = $value;
				_polysChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("polysChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the polys property
		 **/
		public function get polys():Vector.<IBrightPolyLine> {
			return _polys;
		}
	}
}