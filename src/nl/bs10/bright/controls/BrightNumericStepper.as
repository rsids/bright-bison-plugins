package nl.bs10.bright.controls
{
	import nl.bs10.brightlib.interfaces.IBrightControl;
	import mx.controls.NumericStepper;

	public class BrightNumericStepper extends NumericStepper implements IBrightControl
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