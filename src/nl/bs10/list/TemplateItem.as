package nl.bs10.list {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import nl.bs10.brightlib.components.GrayImageButton;
	import nl.bs10.brightlib.components.PluginBox;
	import nl.bs10.brightlib.controllers.IconController;
	import nl.bs10.brightlib.interfaces.IPlugin;
	
	public class TemplateItem extends ListItem {
		
		private var _template:PluginBox;
		private var _templateChanged:Boolean;
		
		private var _collapse:Boolean = false;
		private var _collapse_img:GrayImageButton;
		
		public function TemplateItem(buttondir:String = "ud", collapse:Boolean = false) {
			super(buttondir);
			_collapse = collapse;
		}
		
		
		public function set template(value:PluginBox):void {
			if(value !== _template) {
				_template = value;
				_templateChanged = true;
				invalidateProperties();
			}
		}
		
		public function get template():PluginBox {
			return _template;
		}
		
		override public function set plugin(value:IPlugin):void {
			// nothin...
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_templateChanged) {
				_templateChanged = false;
				if(_hb.numChildren >= 4) {
					_hb.getChildAt(0).removeEventListener(FlexEvent.UPDATE_COMPLETE, _onTemplateUpdate);
					_hb.removeChildAt(0);
				}
					
				_hb.addChildAt(_template as DisplayObject, 0);
				if(_collapse) {
					_template.addEventListener(FlexEvent.UPDATE_COMPLETE, _onTemplateUpdate, false, 0, true);
					_collapse_img = new GrayImageButton();
					_collapse_img.source = IconController.EDIT;
					_collapse_img.addEventListener(MouseEvent.CLICK, _onCollapseClick, false, 0, true);
					_hb.addChildAt(_collapse_img,1);
				}
			}
		}
		
		override public function get value():* {
			var obj:Object = {};
			_template.validate(obj);
			return obj;
		}
		
		override public function validate():Object {
			return _template.validate({});
		}
		
		private function _onCollapseClick(event:MouseEvent):void {
			_hb.getChildAt(0).removeEventListener(FlexEvent.UPDATE_COMPLETE, _onTemplateUpdate);
			var nc:int = _template.numChildren;
			while(--nc > 0) {
				_template.getChildAt(nc).visible = true;
				(_template.getChildAt(nc) as UIComponent).includeInLayout = true;
			}

			_collapse_img.removeEventListener(MouseEvent.CLICK, _onCollapseClick, false);
			_hb.removeChild(_collapse_img);
			_collapse_img = null;
			
		}

		private function _onTemplateUpdate(event:FlexEvent):void {
			var nc:int = _template.numChildren;
			while(--nc > 0) {
				_template.getChildAt(nc).visible = false;
				(_template.getChildAt(nc) as UIComponent).includeInLayout = false;
				
			}
		}
	}
}