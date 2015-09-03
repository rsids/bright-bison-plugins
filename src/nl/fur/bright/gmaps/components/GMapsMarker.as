package nl.fur.bright.gmaps.components
{
	import com.google.maps.LatLng;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.interfaces.IMarker;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.brightlib.objects.MarkerPage;
	import nl.flexperiments.display.Transformations;
	import nl.fur.bright.gmaps.controllers.GMapController;
	import nl.fur.bright.maps.commands.SetMarkerPositionCommand;
	import nl.fur.bright.maps.interfaces.IBrightMarker;
	import nl.fur.bright.maps.interfaces.IMapAppController;
	import nl.fur.vein.controllers.CommandController;

	public class GMapsMarker extends Marker implements IBrightMarker, IMarker
	{
		private var _layer:int;
		private var _color:uint;
		private var _uselayercolor:Boolean;
		private var _parent:IMapAppController;
		
		private var _icon:Bitmap;
		/* private var _infoWindow:InfoWindowOptions; */
		
		private var _markerprops:MarkerPage;
		
		private var _iconChanged:Boolean;
		private var _markerpropsChanged:Boolean;
		private var _colorChanged:Boolean;
		private var _layerChanged:Boolean;
		private var _uselayercolorChanged:Boolean;
		private var _validationRequired:Boolean;
		
		public function GMapsMarker(arg0:LatLng, arg1:MarkerOptions=null) {
			arg1 = new MarkerOptions({draggable:true});
			super(arg0, arg1);
			addEventListener(MapMouseEvent.CLICK, _markerClickHandler);
			addEventListener(MapMouseEvent.DRAG_END, _markerDropped);
			addEventListener(MapMouseEvent.ROLL_OVER, _hoverHandler);
			addEventListener(MapMouseEvent.ROLL_OUT, _hoverHandler);
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
		
		public function destroy():void {
			_parent.map.destroyMarker(this);
			_parent.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			removeEventListener(MapMouseEvent.CLICK, _markerClickHandler);
			removeEventListener(MapMouseEvent.DRAG_END, _markerDropped);
			removeEventListener(MapMouseEvent.ROLL_OVER, _hoverHandler);
			removeEventListener(MapMouseEvent.ROLL_OUT, _hoverHandler);
			markerprops = null;
			parent = null;
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
		
		private function _commitProperties():void {
			var opt:MarkerOptions = getOptions();
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
					opt.icon = null;
					if(markerprops.icon && markerprops.icon != "") {
						 _loadImage(markerprops.icon);
					}
					
					setLatLng(new LatLng(markerprops.lat, markerprops.lng));
					
					markerlabel = opt.tooltip = markerprops.label;
				}
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
				opt.fillStyle.color = color;
			}
			
			if(_iconChanged) {
				opt.icon = _icon;
			}
			setOptions(opt);
		}
		
		private function _markerClickHandler(event:MapMouseEvent):void {
			parent.editMarker(markerprops);
			parent.hideMarkerDelete();

		}
		
		private function _enterFrameHandler(event:Event):void {
			if(_validationRequired) {
				_commitProperties();
				_validationRequired = false;
			}
		}
		
		private function _markerDropped(event:MapMouseEvent):void {
			parent.hideMarkerDelete();
			if(markerprops && markerprops.hasOwnProperty("markerId") && markerprops.markerId > 0) {
				CommandController.addToQueue(new SetMarkerPositionCommand(), markerprops.markerId, getLatLng().lat(), getLatLng().lng());
			}
		}
		
		private function _hoverHandler(event:MapMouseEvent):void {
			if(event.type == MapMouseEvent.ROLL_OVER) {
				clearTimeout(parent.deleteMarkerTimeout);
				parent.showMarkerDelete(foreground.getBounds(parent as DisplayObject), markerprops.markerId);
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
		
		private var _markerlabel:String;
		private var _markerlabelChanged:Boolean;
		
		
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
			
	}
}