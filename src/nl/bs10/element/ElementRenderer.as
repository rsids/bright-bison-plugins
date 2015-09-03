package nl.bs10.element
{
	import mx.containers.HBox;
	import mx.controls.Image;
	import mx.controls.Label;
	
	import nl.bs10.brightlib.controllers.IconController;

	public class ElementRenderer extends HBox
	{
		
		private var _image:Image;
		private var _label:Label;
		private var _dataChanged:Boolean = false;
		
		override protected function createChildren():void {
			super.createChildren();
			
			_image = new Image();
			_image.width = 16;
			_image.height = 16;
			
			_label = new Label();
			_label.percentWidth = 100;
			
			addChild(_image);
			addChild(_label);
		}
		
		
		override public function set data(value:Object):void {
			super.data = value;
			
			if(value) {
				_dataChanged = true;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_dataChanged) 
				_dataChanged = false;
				
			if(data && data.hasOwnProperty("label")) {
				_label.text = data.label;
				_image.source = IconController.getIcon(data, "itemType");	
			}
		}
	}
}