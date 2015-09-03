package nl.fur.bright.maps.controllers
{
	import com.adobe.serialization.json.JSON;
	import com.google.maps.interfaces.IMarker;
	import com.google.maps.overlays.Marker;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.ResizeEvent;
	import mx.modules.Module;
	
	import nl.bs10.brightlib.components.GrayImageButton;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.bs10.brightlib.objects.Layer;
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.bs10.brightlib.objects.PluginProperties;
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.bright.gmaps.controllers.GMapController;
	import nl.fur.bright.maps.commands.CreateMarkerCommand;
	import nl.fur.bright.maps.commands.DeleteMarkerCommand;
	import nl.fur.bright.maps.commands.DeletePolyLineCommand;
	import nl.fur.bright.maps.commands.GetMarkersCommand;
	import nl.fur.bright.maps.commands.GetPolyLinesCommand;
	import nl.fur.bright.maps.commands.SavePolyLineCommand;
	import nl.fur.bright.maps.events.BrightPointEvent;
	import nl.fur.bright.maps.events.BrightPolyLineEvent;
	import nl.fur.bright.maps.interfaces.IBrightMarker;
	import nl.fur.bright.maps.interfaces.IBrightPoint;
	import nl.fur.bright.maps.interfaces.IBrightPolyLine;
	import nl.fur.bright.maps.interfaces.IMapAppController;
	import nl.fur.bright.maps.interfaces.IMapController;
	import nl.fur.bright.maps.views.LayersViewLayout;
	import nl.fur.bright.maps.views.MapSettingsLayout;
	import nl.fur.bright.osm.controllers.OSMController;
	import nl.fur.vein.controllers.CommandController;
	
	public class AppController extends Module implements IPlugin, IMapAppController {
		
		private var _deleteMarkerTimeout:uint;
		private var _displaylabel:String;
		
		
		private var _delete_marker_btn:GrayImageButton;
		
		private var _data:Object;
		private var _dataChanged:Boolean;
		
		private var _deletemarkerId:uint;
		private var _hovermarkerId:uint;
		
		private var _value:*;
		private var _valueChanged:Boolean;
		
		private var _pluginmode:Boolean;
		private var _pluginmodeChanged:Boolean;
		
		private var _selectedlayer:Layer;
		private var _selectedlayerChanged:Boolean;
		private var _mapTypeChanged:Boolean;
		
		private var _mapReady:Boolean;
		
		private var _apikey:String;
		private var _maptype:String;
		
		private var _markers:Vector.<IBrightMarker>;
		
		private var _map:IMapController;
		
		private var _currentPoint:IBrightPoint;
		private var _currentPolyLine:IBrightPolyLine;
		private var _polyLines:Vector.<IBrightPolyLine>;
		
		[Bindable] public var mapsHolder:Canvas;
		[Bindable] public var layersView:LayersViewLayout;
		[Bindable] public var mapSettings:MapSettingsLayout;
		[Bindable] public var center_cvs:Canvas;
		[Bindable] public var settings_btn:GrayImageButton;
		[Bindable] public var layers_btn:GrayImageButton;
		
		public function addMarker():void {
			CommandController.addToQueue(new CreateMarkerCommand(), 
				map.lat,
				map.lng,
				selectedlayer,
				_onAddMarker);
		}
		
		public function addShape(isShape:Boolean):void {
			var polyPage:PolyPage = new PolyPage();
			polyPage.layer = _selectedlayer.layerId;
			polyPage.uselayercolor = true;
			polyPage.color = _selectedlayer.color;
			polyPage.isShape = isShape;
			polyPage.points = new Array();
			
			if (_currentPolyLine) {
				_currentPolyLine.endPolyLine(_currentPolyLine.polyPage.isShape);
			}
			
			_currentPolyLine = map.addShape(polyPage);//new BrightPolyLine(polyPage);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_CHANGED, _onPolyLineChanged);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_ENDED, _onPolyLineEnded);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER, _onPolyLineMouseOver);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, _onPolyLineMouseOut);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_DELETED, _onPolyLineDeleted);
			
			_currentPolyLine.addEventListener(BrightPointEvent.SHAPE_CLICK, _onShapeClicked);
			
			
			
			_polyLines.push(_currentPolyLine);
		}
		
		public function destroy():void {
			
		}
		
		public function editMarker($marker:MarkerPage):void {
			dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, $marker));
		}
		
		public function getPolyLines(layerId:uint):void {
			CommandController.addToQueue(new GetPolyLinesCommand(), layerId, _onGetPolyLines);
		}
		
		public function getMarkers(layerId:uint):void {
			CommandController.addToQueue(new GetMarkersCommand(), layerId, _onGetMarkers);
			// Get the polys as well
			getPolyLines(layerId);
		}
		
		
		
		public function removePolyLines($layer:uint):void {
			for each (var polyLine:IBrightPolyLine in _polyLines) {
				if (polyLine.polyPage.layer == $layer) {
					polyLine.visible = false;
				}
			}
		}
		
		public function removeMarkers($layer:uint):void {
			for each (var marker:IBrightMarker in _markers) {
				if (marker.layer == $layer) {
					marker.visible = false;
				}
			}
		}
		
		public function updatePolyLines($layer:uint, $color:uint):void
		{
			for each (var polyLine:IBrightPolyLine in _polyLines) {
				if (polyLine.polyPage.layer == $layer && polyLine.polyPage.uselayercolor) {
					polyLine.color = _selectedlayer.color;
				}
			}
		}
		
		public function updateMarkers($layer:uint, $color:uint):void
		{
			for each (var bm:IBrightMarker in _markers) {
				if (bm.layer == $layer && bm.uselayercolor) {
					bm.color = $color;
				}
			}
			
			updatePolyLines($layer, $color);
		}
		
		public function updateMarker($marker:MarkerPage):void {
			if(_markerIndex($marker.markerId) != -1) {				
				_markers[_markerIndex($marker.markerId)].markerprops = $marker;
			}
		}
		
		public function getProperties():PluginProperties {
			var pp:PluginProperties = new PluginProperties();
			pp.pluginname = "Maps Maker";
			pp.version = "2.2.1";
			pp.type = "gmaps";
			pp.modificationdate = new Date(2012,09,04);
			pp.contenttype = "gmaps";
			pp.properties = [{name:"pluginmode", type:"boolean"}, 
							{name:"defaultlat", type:"string"}, 
							{name:"defaultlng", type:"string"}, 
							{name:"defaultzoom", type:"number"}];
			return pp;
		}
		
		public function hideMarkerDelete():void {
			_delete_marker_btn.visible = false;
		}
		
		public function showMarkerDelete($bounds:Rectangle, $markerId:uint):void {
			if(pluginmode)
				return;
			_delete_marker_btn.visible = true;
			_hovermarkerId = $markerId;
			_delete_marker_btn.x = $bounds.x - ($bounds.width * .5);
			_delete_marker_btn.y = $bounds.y + $bounds.height;
		}
		
		public function validate():Object {
			return {valid:true};
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_dataChanged) {
				_dataChanged = false;
				_apikey = parentApplication.getModelValue('applicationVO.config.general.googlemapsapikey');
				_maptype = parentApplication.getModelValue('applicationVO.config.general.maptype');
				
				switch(_maptype) {
					case 'osm':
						map = new OSMController(_apikey);
						break;
					default:
						map = new GMapController(_apikey);
						break;
				}
				map.addEventListener('mapReady', _onMapReady, false, 0, true);
				map.parentApp = this;
				mapsHolder.addChild(map as DisplayObject);
				if(_data) {
					if(!_data.hasOwnProperty("defaultzoom"))
						_data.defaultzoom = 8;
					
					if(!_data.hasOwnProperty("defaultlat"))
						_data.defaultlat = 53;
					
					if(!_data.hasOwnProperty("defaultlng"))
						_data.defaultlng = 6.5;
					
					if(_data.hasOwnProperty("pluginmode"))
						pluginmode = Boolean(_data.pluginmode);
					
					mapSettings.zoom = map.zoomvalue = _data.defaultzoom;
					mapSettings.lat = map.lat = _data.defaultlat;
					mapSettings.lng = map.lng = _data.defaultlng;
				}

			}
			
			if(_mapTypeChanged) {
				_mapTypeChanged = false;
				map.maptype = mapSettings.maptype;
			}
			
			if(_pluginmodeChanged) {
				if(pluginmode) {
					mapsHolder.x = 159;
					mapsHolder.height = 440;
					height = 440;
				} else {
					mapsHolder.x = 0;
					mapsHolder.percentHeight = 100;
					percentHeight = 100;
				}
			}
			
			if(_mapReady) {
				if(_valueChanged) {
					
					if(_value) {
						_valueChanged = false;
						if(_value.hasOwnProperty("lat") && _value.hasOwnProperty("lng")) {
							mapSettings.lat = map.lat = _value.lat;
							mapSettings.lng = map.lng = _value.lng;
						}
						
						
						if(_value.hasOwnProperty("zoom"))
							mapSettings.zoom = map.zoomvalue = Number(_value.zoom);
						
						if(_value.hasOwnProperty("maptype")) {
							mapSettings.maptype = _value.maptype;
						}
						
						if(_value.hasOwnProperty("layers")) {
							layersView.layers = new ArrayCollection(_value.layers);
							layersView.layers.refresh();
						}
						
						if(_value.hasOwnProperty("markers")) {
							_onGetMarkers(_value.markers);
						}
						
					}
				}
			
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_polyLines = new Vector.<IBrightPolyLine>();
			
			_delete_marker_btn = new GrayImageButton();
			_delete_marker_btn.addEventListener(MouseEvent.ROLL_OVER, _onDeleteMarkerHover);
			_delete_marker_btn.addEventListener(MouseEvent.ROLL_OUT, _onDeleteMarkerHover);
			_delete_marker_btn.addEventListener(MouseEvent.CLICK, _onDeleteMarkerClick);
			_delete_marker_btn.source = IconController.getIcon('delete');
			_delete_marker_btn.visible = false;
			addChild(_delete_marker_btn);
			mapSettings.addEventListener("maptypeChanged", _onMapTypeChange);
			
		}
		
		protected function editLayers():void {
			if(layers_btn.toggle) {
				settings_btn.toggle = false;
				editSettings();
			}
			
			layersView.visible = layers_btn.toggle;
		}
		
		protected function editSettings():void {
			mapSettings.visible = settings_btn.toggle;
			if(mapSettings.visible) {
				mapSettings.lat = map.lat;
				mapSettings.lng = map.lng;
				mapSettings.zoom = map.zoomvalue;
				layers_btn.toggle = false;
				editLayers();
			} else {
				center_cvs.visible = false;
				
			}
		}
		
		protected function renderBorders(event:ResizeEvent):void {
			var cvs:Canvas = event.currentTarget as Canvas;
			cvs.graphics.clear();
			cvs.graphics.lineStyle(2, 0x000, 1);
			
			cvs.graphics.moveTo(40,1);
			cvs.graphics.lineTo(1,1);
			cvs.graphics.lineTo(1,40);
			
			cvs.graphics.moveTo(40,cvs.height-1);
			cvs.graphics.lineTo(1,cvs.height-1);
			cvs.graphics.lineTo(1,cvs.height - 40);
			
			cvs.graphics.moveTo(cvs.width-1 - 40,1);
			cvs.graphics.lineTo(cvs.width-1,1);
			cvs.graphics.lineTo(cvs.width-1,40);
			
			cvs.graphics.moveTo(cvs.width - 40,cvs.height-1);
			cvs.graphics.lineTo(cvs.width-1,cvs.height-1);
			cvs.graphics.lineTo(cvs.width-1,cvs.height - 40);
			
			cvs.graphics.moveTo(cvs.width / 2, (cvs.height / 2) - 20);
			cvs.graphics.lineTo(cvs.width / 2, (cvs.height / 2) + 20);
			cvs.graphics.moveTo((cvs.width / 2) - 20, cvs.height / 2);
			cvs.graphics.lineTo((cvs.width / 2) + 20, cvs.height / 2);
			
		}
		
		protected function zoom(direction:int):void {
			map.zoom(direction);
		}
		
		private function _deleteMarkerHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeleteMarkerCommand(), _deletemarkerId, _deleteMarkerCallback);
			}
		}
		
		
		private function _deleteMarkerCallback(result:Boolean, markerId:int):void {
			if(result) {
				var i:int = _markerIndex(markerId);
				_markers[i].destroy();
				_markers.splice(i,1);
			}
		}
		
		/**
		 * _onAddMarker function
		 *  
		 **/
		private function _onAddMarker(marker:MarkerPage):void {
			if(_markerIndex(marker.markerId) == -1) {
				var bm:IBrightMarker = map.addMarker(marker.lat, marker.lng);
				bm.markerprops = marker;
				_markers.push(bm);
			}
		}
		
		
		private function _onDeleteMarkerHover(event:MouseEvent):void {
			if (event.type == MouseEvent.ROLL_OVER) {
				clearTimeout(deleteMarkerTimeout);
			} else {
				deleteMarkerTimeout = setTimeout(hideMarkerDelete, 500);
			}
		}
		
		
		private function _onDeleteMarkerClick(event:MouseEvent):void {
			Alert.show("Are you sure you want to delete this marker?", "Please Confirm", Alert.YES|Alert.NO, null, _deleteMarkerHandler);
			_deletemarkerId = _hovermarkerId;
		}
		
		
		/**
		 * _onGetMarkers function
		 *  
		 **/
		private function _onGetMarkers(markers:Array):void {
			if(!_markers) 
				_markers = new Vector.<IBrightMarker>;
			
			for each (var marker:MarkerPage in markers) {
				if(_markerIndex(marker.markerId) == -1) {
					var bm:IBrightMarker = map.addMarker(marker.lat, marker.lng);
					bm.markerprops = marker;
					_markers.push(bm);
				} else {
					_markers[_markerIndex(marker.markerId)].visible = true;
				}
			}
		}
		
		/**
		 * _onGetPolyLines function
		 *  
		 **/
		private function _onGetPolyLines(polyPages:Array):void {
			for each (var polyPage:PolyPage in polyPages) {
				// Only create polyLines that we don't have in the array yet
				if (_polyLineIndex(polyPage.polyId) == -1) {
					// Create a new polyline
					var newPolyLine:IBrightPolyLine = map.addShape(polyPage);
					
					// Listen for a complete event
					newPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POPULATE_COMPLETED, _onPolyLinePopulateCompleted);
					// Push it on the array
					_polyLines.push(newPolyLine);
				} else {
					var existingPolyLine:IBrightPolyLine = _polyLines[_polyLineIndex(polyPage.polyId)] as IBrightPolyLine;
					existingPolyLine.visible = true;
				}
			}
		}
		
		/**
		 * _onMapReady function
		 *  
		 **/
		private function _onMapReady(event:Event):void {
			_mapReady = true;
			invalidateProperties();
		}
		
		/**
		 * _onMapTypeChange function
		 * @param event The event  
		 **/
		private function _onMapTypeChange(event:Event):void {
			_mapTypeChanged = true;
			invalidateProperties();
		}
		
		
		private function _onShapeClicked(event:BrightPointEvent):void{
			dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, (event.currentTarget as IBrightPolyLine).polyPage));
		}
		
		
		private function _onPolyLineChanged(event:BrightPolyLineEvent):void	{
			CommandController.addToQueue(new SavePolyLineCommand(), event.target as IBrightPolyLine);
		}
		
		
		private function _onPolyLineDeleted(event:BrightPolyLineEvent):void {
			var polyLine:IBrightPolyLine = event.target as IBrightPolyLine;
			
			polyLine.polyPage.deleted = true;
			CommandController.addToQueue(new DeletePolyLineCommand(), polyLine);
			_currentPolyLine = null;
		}
		
		
		
		private function _onPolyLineEnded(event:BrightPolyLineEvent):void {
			_currentPolyLine = null;
			CommandController.addToQueue(new SavePolyLineCommand(), event.target as IBrightPolyLine);
		}
		
		
		private function _onPolyLineMouseOver(event:BrightPolyLineEvent):void{
			//clearTimeout(deletePointTimeout);
			var bounds:Rectangle = event.point.square.getBounds(this);
			bounds.width = 14;
			bounds.height = 6;
			//showPointDeleteButton(bounds, 0);
			_currentPolyLine = (event.target) as IBrightPolyLine;
			_currentPoint = event.point;
		}
		
		
		private function _onPolyLineMouseOut(event:BrightPolyLineEvent):void{
			//deletePointTimeout = setTimeout(hidePointDeleteButton, 500);
		}
		
		
		private function _onPolyLinePopulateCompleted(event:BrightPolyLineEvent):void {
			(event.target as IBrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_CHANGED, _onPolyLineChanged);
			(event.target as IBrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER,_onPolyLineMouseOver);
			(event.target as IBrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, _onPolyLineMouseOut);
			(event.target as IBrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_DELETED, _onPolyLineDeleted);
			(event.target as IBrightPolyLine).addEventListener(BrightPointEvent.SHAPE_CLICK, _onShapeClicked);
		}
		
		private function _markerIndex(markerId:Number):int {
			var i:int = 0; 
			for each (var marker:IBrightMarker in _markers) {
				if (markerId == marker.markerprops.markerId) {
					return i;
				}
				i++;
			}
			
			return -1;
		}
		
		private function _polyLineIndex(polyId:Number):int {
			var i:int = 0; 
			for each (var polyLine:IBrightPolyLine in _polyLines) {
				if (polyId == polyLine.polyPage.polyId) {
					return i;
				}
				i++;
			}
			
			return -1;
		}
		
		public function set deleteMarkerTimeout($value:uint):void {
			if($value !== _deleteMarkerTimeout) {
				_deleteMarkerTimeout = $value;
			}
		}
		
		/** 
		 * Getter/Setter methods for the deleteMarkerTimeout property
		 **/
		public function get deleteMarkerTimeout():uint {
			return _deleteMarkerTimeout;
		}
		
		[Bindable(event="displaylabelChanged")]
		public function set displaylabel($value:String):void {
			if($value !== _displaylabel) {
				_displaylabel = $value;
				dispatchEvent(new Event("displaylabelChanged"));
			}
		}
		 
		/** 
		 * Getter/Setter methods for the displaylabel property
		 **/
		public function get displaylabel():String {
			return _displaylabel;
		}
				
		[Bindable(event="dataChanged")]
		override public function set data($value:Object):void {
			super.data = $value;
			if($value !== _data) {
				_data = $value;
				_dataChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("dataChanged"));
			}
		}
		
		[Bindable(event="mapChanged")]
		public function set map($value:IMapController):void {
			if($value !== _map) {
				_map = $value;
				dispatchEvent(new Event("mapChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the map property
		 **/
		public function get map():IMapController {
			return _map;
		}
		
		
		[Bindable(event="pluginmodeChanged")]
		public function set pluginmode($value:Boolean):void {
			if($value !== _pluginmode) {
				_pluginmode = $value;
				_pluginmodeChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("pluginmodeChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the pluginmode property
		 **/
		public function get pluginmode():Boolean {
			return _pluginmode;
		}
		
		
		[Bindable(event="selectedlayerChanged")]
		public function set selectedlayer($value:Layer):void {
			if($value !== _selectedlayer) {
				_selectedlayer = $value;
				_selectedlayerChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("selectedlayerChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the selectedlayer property
		 **/
		public function get selectedlayer():Layer {
			return _selectedlayer;
		}
		
		[Bindable(event="valueChanged")]
		public function set value($value:*):void {
			if($value !== _value) {
				_value = $value;
				_valueChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("valueChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the value property
		 **/
		public function get value():* {
			
			// A map without layers is no map
			if(!layersView || layersView.layers.length == 0)
				return null;
			
			_value = {};
			_value.lat = mapSettings.lat;
			_value.lng = mapSettings.lng;
			_value.zoom = mapSettings.zoom;
			_value.maptype = mapSettings.maptype;
			_value.layers = new Array();
			for each (var layer:Layer in layersView.layers) {
				_value.layers.push({layerId: layer.layerId, visible:layer.visible});
			}
			
			var enc:String = JSON.encode(_value);
			return enc;
		}
	}
}