package nl.fur.bright.plugins.linkchooser.controllers
{
	import mx.modules.Module;
	
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.bs10.brightlib.objects.PluginProperties;
	
	public class PluginController extends Module implements IPlugin
	{
		private var _displaylabel:String;
		private var _value:*;
		
		public function PluginController()
		{
			super();
		}
		
		public function getProperties():PluginProperties {
			var pp:PluginProperties = new PluginProperties();
			return pp;
		}
		
		public function validate():Object {
			return null;
		}
		
		public function destroy():void {
			
		}

		public function get displaylabel():String {
			return _displaylabel;
		}

		public function set displaylabel(value:String):void {
			_displaylabel = value;
		}

		public function get value():* {
			return _value;
		}

		public function set value(value:*):void {
			_value = value;
		}
		
	}
}