package nl.fur.bright.colorpicker.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class HSB extends EventDispatcher
	{
		private var _h:uint;
		private var _s:uint;
		private var _b:uint;
		
		public function HSB(h:uint, s:uint, b:uint) {
			this.h = h;
			this.s = s;
			this.b = b;
		}
		
		public function get h():uint {
			return _h;
		}
		
		[Bindable(event="hChanged")]
		public function set h(val:uint):void	{
			if(_h != val) {
				_h = val;
				dispatchEvent(new Event('hChanged'));
			}
		}
		
		public function get s():uint {
			return _s;
		}
		
		[Bindable(event="sChanged")]
		public function set s(val:uint):void	{
			if(_s != val) {
				_s = val;
				dispatchEvent(new Event('sChanged'));
			}
		}
		
		public function get b():uint {
			return _b;
		}
		
		[Bindable(event="bChanged")]
		public function set b(val:uint):void	{
			if(_b != val) {
				_b = val;
				dispatchEvent(new Event('bChanged'));
			}
		}
	}
}