package nl.fur.bright.osm.components
{
	import com.mapquest.LatLng;
	import com.mapquest.tilemap.IShape;
	import com.mapquest.tilemap.pois.PinMapIcon;
	import com.mapquest.tilemap.pois.Poi;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.flexperiments.display.Transformations;
	import nl.fur.bright.maps.commands.SetMarkerPositionCommand;
	import nl.fur.bright.maps.interfaces.IBrightMarker;
	import nl.fur.bright.maps.interfaces.IMapAppController;
	import nl.fur.bright.maps.interfaces.IMapController;
	import nl.fur.vein.controllers.CommandController;

	public class OSMMarker extends Poi implements IBrightMarker, IShape
	{
		private var _layer:int;
		private var _color:uint;
		private var _uselayercolor:Boolean;
		private var _parent:IMapAppController;
		
		private var _icon:Bitmap;
		private var _colorIcon:PinMapIcon = new PinMapIcon();
		/* private var _infoWindow:InfoWindowOptions; */
		
		private var _markerprops:MarkerPage;
		
		private var _iconChanged:Boolean;
		private var _markerpropsChanged:Boolean;
		private var _colorChanged:Boolean;
		private var _layerChanged:Boolean;
		private var _uselayercolorChanged:Boolean;
		private var _validationRequired:Boolean;
		
		private var _markerlabel:String = '';
		private var _markerlabelChanged:Boolean;
		
		private var _latlng:LatLng;
		
		private var _clickEnabled:Boolean = true;
		
		public function OSMMarker(arg0:LatLng) {
			super(arg0);
			_latlng = arg0;
			draggable = true;
			labelVisible = false;
			
			addEventListener(MouseEvent.CLICK, _markerClickHandler);
			addEventListener(MouseEvent.ROLL_OVER, _hoverHandler);
			addEventListener(MouseEvent.ROLL_OUT, _hoverHandler);
		}
		
		public function destroy():void {
			
			_parent.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			removeEventListener(MouseEvent.CLICK, _markerClickHandler);
			removeEventListener(MouseEvent.ROLL_OVER, _hoverHandler);
			removeEventListener(MouseEvent.ROLL_OUT, _hoverHandler);
			markerprops = null;
			parent = null;
			map.removeShape(this);
		} 
		
		private function _commitProperties():void {
			//var opt:MarkerOptions = getOptions();
			
			if(_markerpropsChanged) {
				_markerpropsChanged = false;
				if(markerprops) {
					layer = markerprops.hasOwnProperty("layer") ? Number(markerprops.layer) : 1;

					if(markerprops.hasOwnProperty("color")) {
						color = uint(markerprops.color);
					}
					if(markerprops.hasOwnProperty("uselayercolor")) {
						uselayercolor = markerprops.uselayercolor;
					}
					//opt.icon = null;
					if(markerprops.icon && markerprops.icon != "") {
						 _loadImage(markerprops.icon);
					}
					
					super.latLng = new LatLng(markerprops.lat, markerprops.lng);
					
					markerlabel = markerprops.label;
				
				}
			}
			
			if(_markerlabelChanged) {
				_markerlabelChanged = false;
				rolloverAndInfoTitleText = markerlabel;
			}
			if(_uselayercolorChanged || _layerChanged) {
				if(_uselayercolor) {
					
					var layers:ArrayCollection;
					if(parent.pluginmode) {
						layers = parent['layersView'].layers;
					} else {
						layers = parent.parentApplication.getModelValue('markerVO.alayers')
						
					} 
					
					for each(var la:Object in layers) {
						if(la.layerId == layer) {
							color = uint(la.color);
							layers = null;
							break;
						}
					}
					layers = null;
				}
				_uselayercolorChanged = false;
				_layerChanged = false;
			}
			
			if(_colorChanged) {
				_colorChanged = false;
				_colorIcon.gradientBaseColors = [0x000000, color];
				icon = _colorIcon;
			}
		}
		
		private function _markerClickHandler(event:MouseEvent):void {
			if(_clickEnabled) {
				parent.editMarker(markerprops);
				parent.hideMarkerDelete();
			}

		}
		
		private function _enterFrameHandler(event:Event):void {
			if(_validationRequired) {
				_commitProperties();
				_validationRequired = false;
			}
		}
		
		private function _hoverHandler(event:MouseEvent):void {
			if(event.type == MouseEvent.ROLL_OVER) {
				
				clearTimeout(parent.deleteMarkerTimeout);
				var r:Rectangle = new Rectangle(event.currentTarget['parent'].mouseX,event.currentTarget['parent'].mouseY,20,23);
				parent.showMarkerDelete(r, markerprops.markerId);
			} else {
				clearTimeout(parent.deleteMarkerTimeout);
				parent.deleteMarkerTimeout = setTimeout(_hideDelete, 500);
			}
		}
		
		private function _loadImage(url:String):void {
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(parent.parentApplication.getModelValue('applicationVO.config.filesettings.fileurl') + url));
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, _loadComplete, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,  function():void{}, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, function():void{}, false, 0, true);
		}
		
		private function _hideDelete():void {
			parent.hideMarkerDelete();
		}
		
		private function _loadComplete(event:Event):void {
			var ldr:LoaderInfo = event.currentTarget as LoaderInfo;
			var bmd:BitmapData = new BitmapData(markerprops.iconsize,markerprops.iconsize, true, 0x000000);
			var m:Matrix = Transformations.getScaleMatrix(ldr.content, markerprops.iconsize,markerprops.iconsize, false);
			bmd.draw(ldr.content, m, null, null, null, true);
			_icon = new Bitmap(bmd);
			_icon.smoothing = true;
			_icon.pixelSnapping = 'never';
			_iconChanged = true;
			_validationRequired = true;
		}
		
		override public function set latLng(mqLatLng:LatLng):void {
			super.latLng = mqLatLng;
			if(_latlng && mqLatLng.toString() != _latlng.toString()) {
				parent.hideMarkerDelete();
				if(markerprops && markerprops.hasOwnProperty("markerId") && markerprops.markerId > 0) {
					_clickEnabled = false;
					setTimeout(function():void{_clickEnabled = true},200);
					CommandController.addToQueue(new SetMarkerPositionCommand(), markerprops.markerId, mqLatLng.lat, mqLatLng.lng);
				}
			}
		} 
		
		public function set layer(value:int):void {
			if(_layer !== value) {
				_layer = value;
				_layerChanged = true;
				_validationRequired = true;
			}
		}
		
		public function get layer():int {
			return _layer;
		}
		
		public function set color(value:uint):void {
			if(_color !== value) {
				_color = value;
				_colorChanged = true;
				_validationRequired = true;
			}
		}
		
		public function get color():uint {
			return _color;
		}
		
		public function set parent(value:IMapAppController):void {
			if(value !== _parent) {
				if(_parent)
					_parent.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
				
				_parent = value;
				if(_parent)
					_parent.addEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			}
		}
		
		public function get parent():IMapAppController {
			return _parent;
		}
		
		public function set markerprops(value:MarkerPage):void {
			if(_markerprops !== value) {
				_markerprops = value;
				_markerpropsChanged = true;
				_validationRequired = true;
			}
		}
		
		public function get markerprops():MarkerPage {
			return _markerprops;
		}
		
		
		[Bindable(event="markerlabelChanged")]
		public function set markerlabel($value:String):void {
			if($value !== _markerlabel) {
				_markerlabel = $value;
				_markerlabelChanged = true;
				dispatchEvent(new Event("markerlabelChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the markerlabel property
		 **/
		public function get markerlabel():String {
			return _markerlabel;
		}
		
		public function set uselayercolor(value:Boolean):void {
			if(_uselayercolor !== value) {
				_uselayercolor = value;
				_uselayercolorChanged = true;
				_validationRequired = true;
			}
		}
		
		public function get uselayercolor():Boolean {
			return _uselayercolor;
		}
			
	}
}