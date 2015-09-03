package nl.fur.bright.maps.views
{
	import flash.events.Event;
	
	import mx.containers.Panel;
	import mx.controls.ComboBox;
	
	import nl.bs10.gmaps.controllers.AppController;
	import nl.fur.bright.maps.interfaces.IMapAppController;

	public class MapSettings extends Panel {
		
		private var _maptypeChanged:Boolean;
		private var _maptype:String;
		private var _lng:Number;
		private var _lat:Number;
		private var _zoom:int;
		private var _setsavelabel:String = "Set location & Zoom";
		
		[Bindable] public var maptype_cmb:ComboBox;
		
		protected const maptypes:Array = [{id:"HYBRID", label:'Hybrid'},{id:"ROADMAP", label:'Roadmap'},{id:"SATELLITE", label:'Satellite'},{id:"TERRAIN", label:'Terrain'}];
		
		public function MapSettings()
		{
			super();
		}
		
		
		[Bindable(event="latChanged")]
		public function set lat(value:Number):void {
			if(_lat !== value) {
				_lat = value;
				dispatchEvent(new Event("latChanged"));
			}
		}
		
		public function get lat():Number {
			return _lat;
		}
		
		[Bindable(event="lngChanged")]
		public function set lng(value:Number):void {
			if(_lng !== value) {
				_lng = value;
				dispatchEvent(new Event("lngChanged"));
			}
		}
		
		public function get lng():Number {
			return _lng;
		}
		
		[Bindable(event="zoomChanged")]
		public function set zoom(value:int):void {
			if(_zoom !== value) {
				_zoom = value;
				dispatchEvent(new Event("zoomChanged"));
			}
		}
		
		public function get zoom():int {
			return _zoom;
		}
		
		[Bindable(event="maptypeChanged")]
		public function set maptype(value:String):void {
			if(_maptype !== value) {
				_maptype = value;
				_maptypeChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("maptypeChanged"));
			}
		}
		
		public function get maptype():String {				
			return _maptype;
		}


		[Bindable(event="setsavelabelChanged")]
		public function set setsavelabel(value:String):void {
			if(_setsavelabel !== value) {
				_setsavelabel = value;
				dispatchEvent(new Event("setsavelabelChanged"));
			}
		}
		
		public function get setsavelabel():String {
			return _setsavelabel;
		}	
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			if(!value && parent) {
				parent['center_cvs'].visible = false;
				setsavelabel = "Set location & Zoom";
			}
		}
		
		protected function setSave():void {
			if(setsavelabel == "Set location & Zoom") {
				setsavelabel = "Save";
				parent['center_cvs'].visible = true;
			} else {
				setsavelabel = "Set location & Zoom";
				parent['center_cvs'].visible = false;
				this['parent'].invalidateDisplayList();
				lat = IMapAppController(parent).map.lat;
				lng = IMapAppController(parent).map.lng;
				zoom = IMapAppController(parent).map.zoomvalue;
			}
		}
		
		protected function maptypeChangeHandler(event:Event):void {
			maptype = event.currentTarget.selectedItem.id;
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_maptypeChanged) {
				_maptypeChanged = false;
				for each(var mtype:Object in maptypes) {
					if(mtype.id == maptype) {
						maptype_cmb.selectedItem = mtype;
						break;
					}
				}
			}
		}
	}
}