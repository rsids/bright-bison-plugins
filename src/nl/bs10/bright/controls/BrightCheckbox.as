package nl.bs10.bright.controls
{
	import nl.bs10.brightlib.interfaces.IBrightControl;
	import mx.controls.CheckBox;

	public class BrightCheckbox extends CheckBox implements IBrightControl
	{
		private var _fieldname:String;
		
		[Bindable]
		public function set fieldname(value:String):void {
			_fieldname = value;
		}
		
		public function get fieldname():String {
			return _fieldname;	
		}
		
	}
}