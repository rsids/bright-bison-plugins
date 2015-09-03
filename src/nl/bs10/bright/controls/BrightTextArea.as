package nl.bs10.bright.controls
{
	import flash.events.MouseEvent;
	
	import mx.controls.TextArea;
	
	import nl.bs10.brightlib.interfaces.IBrightControl;

	public class BrightTextArea extends TextArea implements IBrightControl
	{
		private var _fieldname:String;
		
		override protected function createChildren():void {
			super.createChildren();
			textField.mouseWheelEnabled = false;
			mouseChildren = false;
			
			addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				event.stopImmediatePropagation();
				}, true);

		}
		
		[Bindable]
		public function set fieldname(value:String):void {
			_fieldname = value;
		}
		
		public function get fieldname():String {
			return _fieldname;	
		}
		
	}
}