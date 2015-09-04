package nl.fur.bright.fileexplorer.controllers {
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.modules.Module;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.interfaces.IPlugin;
	import nl.bs10.brightlib.objects.PluginProperties;
	import nl.fur.bright.fileexplorer.commands.GetConfigCommand;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class AppController extends Module implements IPlugin {
		
		private var _gatewayset:Boolean = false;
		private var _propertiesset:Boolean = false;
		
		private var _dataproviderChanged:Boolean = false;
		private var _buttonsData:Array;
		
		private var _displaylabel:String;
		private var _label:String;
		private var _value:Object;

		public function AppController():void {
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, _completeHandler, false, 0, true);	
		}
		
		public function destroy():void {
			
		}
		
		/**
		 * Dispatches an event where parent components can listen to (selected file change)
		 * @param string type The type of event: SELECTEDFILECHANGED, SELECTFILE
		 * @param objct data Additional event data
		 */
		public function dispatch(type:String, data:*):void {
			dispatchEvent(new BrightEvent(type, data));
		}
		
		protected function reload():void {
			if(!_gatewayset || !_propertiesset)
				return;
				
			Model.instance.filesVO.currentFile = null;
		}
		
		private function _completeHandler(event:FlexEvent):void {
			if(Application.application.parameters.gateway)
				setGateway(Application.application.parameters.gateway);
				
			if(Application.application.parameters.hasOwnProperty("showSelectView")) {
				Model.instance.filesVO.showSelect = (Application.application.parameters.showSelectView == true); 
			}
		}
		
		public function setGateway(value:String):void {
			Application.application.parameters.gateway = value;
			var trs:RemoteObject = new RemoteObject("gateway");
			trs.endpoint = Application.application.parameters.gateway;
			trs.source = "files.Files";
			ServiceController.addRemotingService(trs, "fileService");
			
			CommandController.addToQueue(new GetConfigCommand());
			_gatewayset = true;
		}
		
		public function setProperties(callback:Function = null, showSelect:Boolean = false, multiple:Boolean = false, filter:Array = null, showUpload:Boolean = false, showDelete:Boolean = false, foldersOnly:Boolean = false):void {

			_dataproviderChanged = true;
			
			Model.instance.filesVO.callback = callback;
			Model.instance.filesVO.foldersOnly = foldersOnly;
			Model.instance.filesVO.showDelete = showDelete;
			Model.instance.filesVO.showUpload = showUpload;
			Model.instance.filesVO.showSelect = showSelect;
			Model.instance.filesVO.multiple = multiple;
			Model.instance.filesVO.filters = filter;
			_propertiesset = true;
			invalidateProperties()
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_dataproviderChanged) {
				_dataproviderChanged = false;
				VeinDispatcher.instance.dispatch('dataproviderChanged', null);
			}
		}
		
		
		public function get displaylabel():String {
			return _displaylabel;
		}
		
		public function set displaylabel(value:String):void
		{
			_displaylabel = value;
		}
		
		override public function get label():String
		{
			return _label;
		}
		
		override public function set label(value:String):void
		{
			_label = value;
		}
		
		public function get value():*
		{
			return _value;
		}
		
		public function set value(value:*):void {
			_value = value;
		}
		
		public function validate():Object {
			return null;
		}
		
		public function getProperties():PluginProperties {
			var pp:PluginProperties = new PluginProperties();
			pp.pluginname = "Bright File Manager";
			pp.version = "5.1.2";
			pp.modificationdate = new Date(2015,10,04);
			pp.type = "explorer";
			pp.isplugin = false;
			return pp;
		}
		
	}
}