package nl.bs10.list {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.HRule;
	
	import nl.bs10.brightlib.components.GrayImageButton;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.interfaces.IPlugin;

	public class ListItem extends VBox {
		
		private var _down_img:GrayImageButton;
		private var _up_img:GrayImageButton;
		private var _delete_img:GrayImageButton;
		private var _type:String;
		private var _divider:HRule;
		private var _plugin:IPlugin;
		private var _pluginChanged:Boolean = false;
		private var _buttondir:String;

		protected var _hb:HBox;

		/**
		 * 
		 * @param buttondir Either ud (up/down) of lr (left/right);
		 * 
		 */		
		public function ListItem(buttondir:String = "ud") {
			super();
			_buttondir = buttondir;
			percentWidth = 100;
			setStyle('horizontalAlign', 'center');
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_hb = new HBox();
			_hb.percentWidth = 100;
			_hb.setStyle("paddingBottom", 16);
			_divider = new HRule();
			_divider.setStyle('strokeColor', '#C9C9C9');
			_divider.setStyle('strokeWidth', 2);
			_divider.percentWidth = 99;
			
			_down_img = new GrayImageButton();
			_up_img = new GrayImageButton();
			_delete_img = new GrayImageButton();
			
			if(_buttondir == "ud") {
				_down_img.source = IconController.DOWNARROW;
				_up_img.source = IconController.UPARROW;
				_down_img.addEventListener(MouseEvent.CLICK, _moveDown);
				_up_img.addEventListener(MouseEvent.CLICK, _moveUp);
			} else {
				_down_img.source = IconController.LEFTARROW;
				_up_img.source = IconController.RIGHTARROW;
				_down_img.addEventListener(MouseEvent.CLICK, _moveUp);
				_up_img.addEventListener(MouseEvent.CLICK, _moveDown);
				
			}
			_delete_img.source = IconController.getIcon('delete');
			
			_down_img.width =
			_up_img.width =
			_delete_img.width = 16;
			
			_down_img.height =
			_up_img.height =
			_delete_img.height = 20;
			
			_delete_img.addEventListener(MouseEvent.CLICK, _moveDelete);
			
			_hb.addChild(_down_img);
			_hb.addChild(_up_img);
			_hb.addChild(_delete_img);
			addChild(_hb);
			addChild(_divider);
			
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(!_pluginChanged)
				return;
				
			_pluginChanged = false;
			if(_hb.numChildren == 4)
				_hb.removeChildAt(0);
				
			_hb.addChildAt(_plugin as DisplayObject, 0);
		}
		
		public function get value():* {
			if(!plugin)
				return null;
				
			return plugin.value;
		}
		
		public function set type(value:String):void {
			_type = value;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function validate():Object {
			return plugin.validate();
		}
		
		public function set plugin(value:IPlugin):void {
			_pluginChanged = true;
			_plugin = value;
			invalidateProperties();
		}
		
		public function get plugin():IPlugin {
			return _plugin;
		}
		
		private function _moveDown(event:MouseEvent):void {
			dispatchEvent(new Event("movedown"));
		}
		
		private function _moveUp(event:MouseEvent):void {
			dispatchEvent(new Event("moveup"));
		}
		
		private function _moveDelete(event:MouseEvent):void {
			parent.removeChild(this);
		}
		
	}
}