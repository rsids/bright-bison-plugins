package nl.bs10.gmaps.controllers
{
	import com.adobe.serialization.json.JSON;
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
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
	import nl.bs10.gmaps.commands.CreateMarkerCommand;
	import nl.bs10.gmaps.commands.DeleteMarkerCommand;
	import nl.bs10.gmaps.commands.DeletePolyLineCommand;
	import nl.bs10.gmaps.commands.GetDefaultSettingsCommand;
	import nl.bs10.gmaps.commands.GetMarkersCommand;
	import nl.bs10.gmaps.commands.GetPolyLinesCommand;
	import nl.bs10.gmaps.commands.SavePolyLineCommand;
	import nl.fur.bright.gmaps.components.GMapsMarker;
	import nl.fur.bright.gmaps.components.BrightPoint;
	import nl.fur.bright.gmaps.components.BrightPolyLine;
	import nl.bs10.gmaps.events.BrightPointEvent;
	import nl.bs10.gmaps.events.BrightPolyLineEvent;
	import nl.fur.bright.maps.views.LayersViewLayout;
	import nl.fur.bright.maps.views.MapSettingsLayout;
	import nl.fur.vein.controllers.CommandController;
	
	public class AppController extends Module implements IPlugin {
		
		private var _data:Object;
		private var _value:*;
		private var _removedLayer:int;
		private var _selectedlayer:Layer;
		
		private var _displaylabel:String;
		
		private var _dataChanged:Boolean;
		private var _valueChanged:Boolean;
		private var _layersChanged:Boolean;
		private var _apikeyChanged:Boolean;
		private var _mapTypeChanged:Boolean;
		private var _pluginmodeChanged:Boolean;
		
		private var _apikey:String = "";
		private var _mapReady:Boolean;
		
		private var _defaultzoom:Number;
		private var _defaultlat:Number;
		private var _defaultlng:Number; 
		
		private var _settingsChanged:Boolean;
		private var _settings:Object;
		
		
		private var _delete_marker_btn:GrayImageButton;
		private var _delete_point_btn:GrayImageButton;
		private var _hovermarkerId:int;
		private var _deletemarkerId:int;
		private var _pluginmode:Boolean;
		
		[Bindable] public var mapsHolder:Canvas;
		[Bindable] public var gmap:Map;
		[Bindable] public var mapSettings:MapSettingsLayout;
		[Bindable] public var layersView:LayersViewLayout;
		[Bindable] public var center_cvs:Canvas;
		[Bindable] public var settings_btn:GrayImageButton;
		[Bindable] public var layers_btn:GrayImageButton;
		
		public var deleteMarkerTimeout:uint;
		public var deletePointTimeout:uint;
		
		private var _markers:Array;
		private var _polyLines:Array;
		
		private var _currentPolyLine:BrightPolyLine;
		private var _currentPoint:BrightPoint;
		
		public function getProperties():PluginProperties {
			var pp:PluginProperties = new PluginProperties();
			pp.pluginname = "Google Maps Maker";
			pp.version = "2.0.0";
			pp.type = "gmaps";
			pp.modificationdate = new Date(2011,09,13);
			pp.contenttype = "gmaps";
			pp.properties = [{name:"pluginmode", type:"boolean"}, 
							{name:"defaultlat", type:"string"}, 
							{name:"defaultlng", type:"string"}, 
							{name:"defaultzoom", type:"number"}];
			return pp;
		}
		
		public function destroy():void {
			displaylabel = null;
			data = null;
			gmap.deleteReferenceOnParentDocument(this);
			gmap = null;
			_markers = null;
			//_polys = null;
			value = null;
		}
		
		[Bindable(event="displaylabelChanged")]
		public function set displaylabel(val:String):void {
			if(val !== _displaylabel) {
				_displaylabel = val;
				dispatchEvent(new Event("displaylabelChanged"));
			}
		}
		
		public function get displaylabel():String {
			return _displaylabel;
		}
		
		[Bindable(event="pluginmodeChanged")]
		public function set pluginmode(val:Boolean):void {
			if(val !== _pluginmode) {
				_pluginmode = val;
				_pluginmodeChanged = true;
				invalidateDisplayList();
				dispatchEvent(new Event("pluginmodeChanged"));
			}
		}
		
		public function get pluginmode():Boolean {
			return _pluginmode;
		}
		
		override public function set data(val:Object):void {
			super.data = val;
			if(val) {
				_data = val;
				_dataChanged = true;
				invalidateProperties();
			}
		}
		
		override public function get data():Object {
			return null;
		}
		
		[Bindable(event="selectedlayerChanged")]
		public function set selectedlayer(value:Layer):void {
			if(value !== _selectedlayer) {
				_selectedlayer = value;
				dispatchEvent(new Event("selectedlayerChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the selectedlayer property
		 **/
		public function get selectedlayer():Layer {
			return _selectedlayer;
		}
		
		public function set value(fnval:*):void{
			if(fnval !== _value) {
				var val:Object = fnval;
				if(fnval is String) {
					try {
						val = JSON.decode(fnval.toString());
					} catch(ex:Error) {/*Swallow it*/}
				}
				
				_value = val;
				_valueChanged = true;
				invalidateProperties();
			}
		}
		
		public function get value():* {
			if(!_mapReady)
				return _value;
			
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
			
				
			return JSON.encode(_value);
		}
		
		public function validate():Object {
			return {valid:true};
		}
		
		public function getMarkers(layerId:int):void
		{
			CommandController.addToQueue(new GetMarkersCommand(), layerId, _setMarkers);
			
			// Get the polys as well
			getPolyLines(layerId);
		}
		
		public function updateMarkers(layerId:int, color:int):void
		{
			for each (var bm:GMapsMarker in _markers)
			{
				if (bm.layer == layerId && bm.uselayercolor)
				{
					bm.color = color;
				}
			}
			
			updatePolyLines(layerId, color);
		}
		
		public function updateMarker(marker:MarkerPage):void {
			if(_markers[marker.markerId]) {

				_markers[marker.markerId].markerprops = marker;
			}
		}
		
		public function removeMakers(layerId:int):void {
			for each(var bm:GMapsMarker in _markers) {
				if(bm.layer == layerId) {

					var mid:int = bm.markerprops.markerId;
					bm.destroy();
					gmap.removeOverlay(bm);
					delete _markers[mid];
				}
			}
			
			removePolyLines(layerId);
		}
		
		
		public function addMarker():void {
			CommandController.addToQueue(	new CreateMarkerCommand(), 
											gmap.getLatLngBounds().getCenter().lat(),
											gmap.getLatLngBounds().getCenter().lng(),
											selectedlayer,
											_addMarkerCallback);
		}
		
		public function markerClickHandler(marker:Object):void
		{
			dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, marker));
		}
		
		
		public function showMarkerDelete(bounds:Rectangle, markerId:int):void {
			if(pluginmode)
				return;
			_delete_marker_btn.visible = true;
			_hovermarkerId = markerId;
			_delete_marker_btn.x = bounds.x - (bounds.width * .5);
			_delete_marker_btn.y = bounds.y + bounds.height;
		}
		
		public function hideMarkerDelete():void {
			_delete_marker_btn.visible = false;
		}
		
		
		protected function set apikey(key:String):void {
			if(key !== _apikey) {
				_apikey = key;
				_apikeyChanged = true;
				invalidateProperties();
			}
		}
		
		protected function get apikey():String {
			return _apikey;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_markers = new Array();
			_polyLines = new Array();
			
			_delete_marker_btn = new GrayImageButton();
			_delete_marker_btn.addEventListener(MouseEvent.ROLL_OVER, _deleteMarkerHoverHandler);
			_delete_marker_btn.addEventListener(MouseEvent.ROLL_OUT, _deleteMarkerHoverHandler);
			_delete_marker_btn.addEventListener(MouseEvent.CLICK, _deleteMarkerClickHandler);
			_delete_marker_btn.source = IconController.getIcon('delete');
			_delete_marker_btn.visible = false;
			addChild(_delete_marker_btn);
			
			_delete_point_btn = new GrayImageButton();
			_delete_point_btn.addEventListener(MouseEvent.ROLL_OVER, onDeletePointMouseOver);
			_delete_point_btn.addEventListener(MouseEvent.ROLL_OUT, onDeletePointMouseOut);
			_delete_point_btn.addEventListener(MouseEvent.CLICK, onDeletePointMouseClick);
			_delete_point_btn.source = IconController.getIcon('delete');
			_delete_point_btn.visible = false;
			addChild(_delete_point_btn);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			var bm:GMapsMarker;
			
			if(_dataChanged) {
				_dataChanged = false;
				apikey = parentApplication.getModelValue('applicationVO.config.general.googlemapsapikey');
				if(_data) {
					if(_data.hasOwnProperty("defaultzoom"))
						_defaultzoom = _data.defaultzoom;
						
					if(_data.hasOwnProperty("defaultlat"))
						_defaultlat = _data.defaultlat;
						
					if(_data.hasOwnProperty("defaultlng"))
						_defaultlng = _data.defaultlng;
						
					if(_data.hasOwnProperty("pluginmode"))
						pluginmode = Boolean(_data.pluginmode);
						
				}
				if (!pluginmode)
					CommandController.addToQueue(new GetDefaultSettingsCommand(), _setDefaults);
			}
			
			if(_apikeyChanged) {
				_apikeyChanged = false;
				gmap = new Map();
				gmap.key = apikey;
				gmap.x = 0;
				gmap.y = 0;
				gmap.percentHeight = 100;
				gmap.percentWidth = 100;
				gmap.sensor = "false";
				
				gmap.addEventListener("mapevent_mapready", _mapReadyHandler);
				
				mapsHolder.addChildAt(gmap, 0);
				
				
			}
			
			if(_pluginmodeChanged && gmap) {
				_pluginmodeChanged = false;
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
			
			if(_settingsChanged && _mapReady) {
				_settingsChanged = false;
				// Set valueChanged to true, so it can override the defaultsettings
				_valueChanged = true;
				if(isNaN(_defaultlat) && isNaN(_defaultlng) && _settings.hasOwnProperty("lat") && _settings.hasOwnProperty("lng"))
					gmap.setCenter(new LatLng(_settings.lat, _settings.lng));
			
				if(isNaN(_defaultzoom) && _settings.hasOwnProperty("zoom"))
					gmap.setZoom(Number(_settings.zoom));

			}
			
			if(_valueChanged && _mapReady) {
				
				if(_value) {
					_valueChanged = false;
					if(_value.hasOwnProperty("lat") && _value.hasOwnProperty("lng"))
						gmap.setCenter(new LatLng(_value.lat, _value.lng));
			
					if(_value.hasOwnProperty("zoom"))
						gmap.setZoom(Number(_value.zoom));
					
					if(_value.hasOwnProperty("maptype")) {
						mapSettings.addEventListener("maptypeChanged", _mapTypeChangedHandler);
						mapSettings.maptype = _value.maptype;
					}
					
					if(_value.hasOwnProperty("layers")) {
						layersView.layers = new ArrayCollection(_value.layers);
						layersView.layers.refresh();
					}
					
					if(_value.hasOwnProperty("markers")) {
						_setMarkers(_value.markers);
					}
					
				 	mapSettings.lat = gmap.getCenter().lat();
					mapSettings.lng = gmap.getCenter().lng();
					mapSettings.zoom = gmap.getZoom();
					
				}
			}
			
			if(_mapTypeChanged) {
				_mapTypeChanged = false;
				switch(mapSettings.maptype) {
					case 'HYBRID':
						gmap.setMapType(MapType.HYBRID_MAP_TYPE);	
						break;
					case 'ROADMAP':
						gmap.setMapType(MapType.NORMAL_MAP_TYPE);	
						break;
					case 'SATELLITE':
						gmap.setMapType(MapType.SATELLITE_MAP_TYPE);	
						break;
					case 'TERRAIN':
						gmap.setMapType(MapType.PHYSICAL_MAP_TYPE);	
						break;
				}
			}
		}
		
		protected function zoom(dir:int):void {
			gmap.setZoom(gmap.getZoom() + dir);
		}
		
		
		protected function editSettings():void {
			
			mapSettings.visible = settings_btn.toggle;
			if(mapSettings.visible) {
				mapSettings.lat = gmap.getCenter().lat();
				mapSettings.lng = gmap.getCenter().lng();
				mapSettings.zoom = gmap.getZoom();
				layers_btn.toggle = false;
				editLayers();
			} else {
				center_cvs.visible = false;
				
			}
		}
		
		protected function editLayers():void {
			if(layers_btn.toggle) {
				settings_btn.toggle = false;
				editSettings();
			}
			
			layersView.visible = layers_btn.toggle;
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
		
		private function _mapTypeChangedHandler(event:Event):void {
			_mapTypeChanged = true;
			invalidateProperties();
		}
		
		private function _mapReadyHandler(event:MapEvent):void {
			if(!isNaN(_defaultlat) && !isNaN(_defaultlng) )
				gmap.setCenter(new LatLng(_defaultlat, _defaultlng));
			
			if(!isNaN(_defaultzoom))
				gmap.setZoom(_defaultzoom);
			
			gmap.enableScrollWheelZoom();
			
			_mapReady = true;
			
			invalidateProperties();
		}
		
		private function _setDefaults(defaults:Object):void {
			_settings = defaults;
			_settingsChanged = true;
			invalidateProperties();
			
		}
		
		private function _setMarkers(markers:Array):void {
			for each (var marker:MarkerPage in markers) {
				if(!_markers[marker.markerId]) {
					/*var bm:GMapsMarker = new GMapsMarker(new LatLng(marker.lat, marker.lng));
					bm.parent = this;
					bm.markerprops = marker;
					gmap.addOverlay(bm);
					_markers[marker.markerId] = bm;*/
				} else {
					trace('marker Already exists: ' + marker.markerId + '; ' + marker.layer);
				}
			}
		}
		
		private function _addMarkerCallback(marker:MarkerPage):void {
			if(!_markers[marker.markerId]) {
				/*var bm:GMapsMarker = new GMapsMarker(new LatLng(marker.lat, marker.lng));
				bm.parent = this;
				bm.markerprops = marker;
				gmap.addOverlay(bm);
				_markers[marker.markerId] = bm;*/
			}
		}
		
		private function _deleteMarkerHoverHandler(event:MouseEvent):void
		{
			if (event.type == MouseEvent.ROLL_OVER)
			{
				clearTimeout(deleteMarkerTimeout);
			}
			else
			{
				deleteMarkerTimeout = setTimeout(hideMarkerDelete, 500);
			}
		}
		
		
		private function _deleteMarkerClickHandler(event:MouseEvent):void
		{
			Alert.show("Are you sure you want to delete this marker?", "Please Confirm", Alert.YES|Alert.NO, null, _deleteMarkerHandler);
			_deletemarkerId = _hovermarkerId;
		}
		
		private function _deleteMarkerHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				CommandController.addToQueue(new DeleteMarkerCommand(), _deletemarkerId, _deleteMarkerCallback);
			}
		}
		
		
		private function _deleteMarkerCallback(result:Boolean, markerId:int):void {
			if(result) {
				_markers[markerId].destroy();
				gmap.removeOverlay(_markers[markerId]);
				delete _markers[markerId];
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		// POLYLINE PART
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////
		
		
		public function addLine():void
		{
			var polyPage:PolyPage = new PolyPage();
			polyPage.layer = _selectedlayer.layerId;
			polyPage.uselayercolor = true;
			polyPage.color = _selectedlayer.color;
			polyPage.isShape = false;
			polyPage.points = new Array();
			
			if (_currentPolyLine)
			{
				_currentPolyLine.endPolyLine(_currentPolyLine.polyPage.isShape);
			}
			
			_currentPolyLine = new BrightPolyLine(polyPage);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_CHANGED, onPolyLineChanged);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_ENDED, onPolyLineEnded);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER, onPolyLineMouseOver);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, onPolyLineMouseOut);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_DELETED, onPolyLineDeleted);
			
			_currentPolyLine.addEventListener(BrightPointEvent.SHAPE_CLICK, onShapeClicked);
			
			gmap.addOverlay(_currentPolyLine);
			
			_polyLines.push(_currentPolyLine);
		}
		
		
		public function addShape():void
		{
			var polyPage:PolyPage = new PolyPage();
			polyPage.layer = _selectedlayer.layerId;
			polyPage.uselayercolor = true;
			polyPage.color = _selectedlayer.color;
			polyPage.isShape = true;
			polyPage.points = new Array();
			
			if (_currentPolyLine)
			{
				_currentPolyLine.endPolyLine(_currentPolyLine.polyPage.isShape);
			}
			
			_currentPolyLine = new BrightPolyLine(polyPage);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_CHANGED, onPolyLineChanged);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_ENDED, onPolyLineEnded);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER, onPolyLineMouseOver);
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, onPolyLineMouseOut);
			
			_currentPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_DELETED, onPolyLineDeleted);
			
			_currentPolyLine.addEventListener(BrightPointEvent.SHAPE_CLICK, onShapeClicked);
			
			_polyLines.push(_currentPolyLine);
			
			gmap.addOverlay(_currentPolyLine);
		}
		
		
		public function removePolyLines(layerId:int):void
		{
			for each (var polyLine:BrightPolyLine in _polyLines)
			{
				if (polyLine.polyPage.layer == layerId)
				{
					polyLine.visible = false;
				}
			}
		}
		
		
		public function getPolyLines(layerId:int):void
		{
			CommandController.addToQueue(new GetPolyLinesCommand(), layerId, onGetPolyLines);
		}
		
		
		public function updatePolyLines(layerId:Number, color:Number):void
		{
			for each (var polyLine:BrightPolyLine in _polyLines)
			{
				if (polyLine.polyPage.layer == layerId && polyLine.polyPage.uselayercolor)
				{
					polyLine.color = _selectedlayer.color;
				}
			}
		}
		
		
		///////////////////////////////////////////////////////////////////////////////////////
		// EVENT HANDLERS
		///////////////////////////////////////////////////////////////////////////////////////
		
		
		private function onGetPolyLines(polyPages:Array):void
		{
			
			for each (var polyPage:PolyPage in polyPages)
			{
				// Only create polyLines that we don't have in the array yet
				if (polyLineIndex(polyPage.polyId) == -1)
				{
					// Create a new polyline
					var newPolyLine:BrightPolyLine = new BrightPolyLine(polyPage);
					
					// Listen for a complete event
					newPolyLine.addEventListener(BrightPolyLineEvent.POLYLINE_POPULATE_COMPLETED, onPolyLinePopulateCompleted);
					
					// Push it on the array
					_polyLines.push(newPolyLine);
					
					// Add it to the map
					gmap.addOverlay(newPolyLine);
				}
				else
				{
					var existingPolyLine:BrightPolyLine = _polyLines[polyLineIndex(polyPage.polyId)] as BrightPolyLine;
					existingPolyLine.visible = true;
				}
			}
		}
		
		
		private function onPolyLinePopulateCompleted(event:BrightPolyLineEvent):void
		{
			(event.target as BrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_CHANGED, onPolyLineChanged);
			(event.target as BrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER, onPolyLineMouseOver);
			(event.target as BrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, onPolyLineMouseOut);
			(event.target as BrightPolyLine).addEventListener(BrightPolyLineEvent.POLYLINE_DELETED, onPolyLineDeleted);
			(event.target as BrightPolyLine).addEventListener(BrightPointEvent.SHAPE_CLICK, onShapeClicked);
		}
		
		
		private function onShapeClicked(event:BrightPointEvent):void
		{
			dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, (event.currentTarget as BrightPolyLine).polyPage));
		}
		
		
		private function onPolyLineChanged(event:BrightPolyLineEvent):void
		{
			CommandController.addToQueue(new SavePolyLineCommand(), event.target as BrightPolyLine);
		}
		
		
		
		private function onPolyLineEnded(event:BrightPolyLineEvent):void
		{
			_currentPolyLine = null;
			CommandController.addToQueue(new SavePolyLineCommand(), event.target as BrightPolyLine);
		}
		
		
		private function onPolyLineMouseOver(event:BrightPolyLineEvent):void
		{
			clearTimeout(deletePointTimeout);
			var bounds:Rectangle = event.point.square.getBounds(this);
			bounds.width = 14;
			bounds.height = 6;
			showPointDeleteButton(bounds, 0);
			_currentPolyLine = (event.target) as BrightPolyLine;
			_currentPoint = event.point;
		}
		
		
		private function onPolyLineMouseOut(event:BrightPolyLineEvent):void
		{
			deletePointTimeout = setTimeout(hidePointDeleteButton, 500);
		}
		
		
		
		
		public function showPointDeleteButton(bounds:Rectangle, markerId:int):void
		{
			_delete_point_btn.visible = true;
			_hovermarkerId = markerId;
			_delete_point_btn.x = bounds.x - bounds.width;
			_delete_point_btn.y = bounds.y + bounds.height;
		}
		
		
		public function hidePointDeleteButton():void
		{
			_delete_point_btn.visible = false;
		}
		
		
		private function onDeletePointMouseOver(event:MouseEvent):void
		{
			clearTimeout(deletePointTimeout);
		}
		
		
		private function onDeletePointMouseOut(event:MouseEvent):void
		{
			deletePointTimeout = setTimeout(hidePointDeleteButton, 500);
		}
		
		
		private function onDeletePointMouseClick(event:MouseEvent):void
		{
			// Set the labels of the alert to new labels, I misuse the alert a bit so
			// I don't have to create a whole titlewindow, just to show some question 
			Alert.yesLabel = "Point";
			Alert.noLabel = "Shape";
			Alert.cancelLabel = "Cancel";
			
			Alert.show("Delete just this point or the entire shape?", "Please Confirm", Alert.YES|Alert.NO|Alert.CANCEL, null, onDeletePoint);
			
			// Reset the labels of the alert to their default values
			Alert.yesLabel = "Yes";
			Alert.noLabel = "No";
			Alert.cancelLabel = "Cancel";
			
			// There we are, problem solved ;-)
		}
		
		
		private function onDeletePoint(event:CloseEvent):void
		{
			// Delete the point
			if (event.detail == Alert.YES)
			{
				_currentPoint.dispose();
			}
			// Delete the shape
			else if (event.detail == Alert.NO)
			{
				_currentPolyLine.dispose();
				_currentPolyLine = null;
			}
		}
		
		
		private function onPolyLineDeleted(event:BrightPolyLineEvent):void
		{
			var polyLine:BrightPolyLine = event.target as BrightPolyLine;
			
			polyLine.polyPage.deleted = true;
			
			CommandController.addToQueue(new DeletePolyLineCommand(), polyLine);
			
			_currentPolyLine = null;
			//dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, (event.target as BrightPolyLine).polyPage));
		}
		
		
		///////////////////////////////////////////////////////////////////////////////////////
		// UTIL FUNCTIONS
		///////////////////////////////////////////////////////////////////////////////////////
		
		private function polyLineIndex(polyId:Number):int
		{
			var i:int = 0; 
			for each (var polyLine:BrightPolyLine in _polyLines)
			{
				if (polyId == polyLine.polyPage.polyId)
				{
					return i;
				}
				i++;
			}
			
			return -1;
		}
	}
}