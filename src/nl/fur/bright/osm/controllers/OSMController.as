package nl.fur.bright.osm.controllers
{
	import com.mapquest.LatLng;
	import com.mapquest.tilemap.Size;
	import com.mapquest.tilemap.TileMap;
	import com.mapquest.tilemap.pois.Poi;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.bright.maps.interfaces.IBrightMarker;
	import nl.fur.bright.maps.interfaces.IBrightPolyLine;
	import nl.fur.bright.maps.interfaces.IMapAppController;
	import nl.fur.bright.maps.interfaces.IMapController;
	import nl.fur.bright.osm.components.OSMMarker;
	
	public class OSMController extends UIComponent implements IMapController {
		
		private var _polys:Vector.<IBrightPolyLine>;
		private var _polysChanged:Boolean;
		private var _apikey:String;
		
		
		private var _lng:Number;
		private var _latLngChanged:Boolean;
		
		private var _parentApp:IMapAppController;
		
		private var _lat:Number;
		private var _zoomValue:Number;
		private var _zoomValueChanged:Boolean;
		
		protected var map:TileMap;
		
		public function OSMController(apikey:String) {
			super();
			_apikey = apikey;
			
			percentHeight = 100;
			percentWidth = 100;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			
			map = new TileMap(_apikey);
			map.size = new Size(width,height);
			map.x = 0;
			map.y = 0;
			addChild(map);
			
			dispatchEvent(new Event('mapReady'));
			addEventListener(ResizeEvent.RESIZE, _onResize, false, 0, true);
		}
		
		
		public function addShape(polyPage:PolyPage):IBrightPolyLine {
			var pl:IBrightPolyLine;// = new BrightPolyLine(polyPage);
			//map.addOverlay(pl as IPolyline);
			return pl;
		}
		
		public function addMarker(lat:Number, lng:Number):IBrightMarker {
			var om:OSMMarker = new OSMMarker(new LatLng(lat,lng));
			om.parent = parentApp;
			map.addShape(om);
			return om;
		}
		
		
		public function destroy():void {
			removeEventListener(ResizeEvent.RESIZE, _onResize);
		}
		
		
		
		public function destroyMarker(marker:IBrightMarker):void {
			map.removeShape(marker as OSMMarker);
		}
		
		public function zoom(direction:int):void {
			if(direction == 1) {
				map.zoomIn();
			} else {
				map.zoomOut();
				
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_zoomValueChanged) {
				_zoomValueChanged = false;
				map.zoom = _zoomValue;
			}
			
			if(_latLngChanged) {
				_latLngChanged = false;
				map.setCenter(new LatLng(_lat, _lng));
			}
			
			if(_maptypeChanged) {
				_maptypeChanged = false;
				
				switch(maptype) {
					case 'HYBRID':
						map.mapType = 'hyb';
						break;
					case 'ROADMAP':
						map.mapType = 'map';
						break;
					case 'SATELLITE':
						map.mapType = 'sat';
						break;
					case 'TERRAIN':
						map.mapType = 'map';
						break;
				}
				/*"map" - 2D normal map
				"sat" - satellite imagery
				"hyb" - hybrid map
				"none" - no layer
				"custom" - custom layer on map*/
			}
		}
		
		/**
		 * _onResize function
		 *  
		 **/
		private function _onResize(event:ResizeEvent):void {
			map.size = new Size(width, height);
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
			if(map)
				return map.center.lng;
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
			if(map)
				return map.center.lat;
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
			if(map)
				return map.zoom;
			return _zoomValue;
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