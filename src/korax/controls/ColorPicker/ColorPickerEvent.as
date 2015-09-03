package korax.controls.ColorPicker
{
	import flash.events.Event;

	public class ColorPickerEvent extends Event
	{
		public var color:uint
		public function ColorPickerEvent(type:String, color:uint)
		{
			this.color = color;
			super(type, false, false);
		}
		
	}
}