package nl.bs10.bright.controls
{
	import mx.controls.ComboBox;
	
	import nl.bs10.brightlib.interfaces.IBrightControl;

	public class BrightCombobox extends ComboBox implements IBrightControl
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