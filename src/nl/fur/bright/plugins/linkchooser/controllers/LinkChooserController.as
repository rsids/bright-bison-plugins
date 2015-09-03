package nl.fur.bright.plugins.linkchooser.controllers {
	
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.PluginProperties;
	import nl.fur.bright.plugins.linkchooser.commands.LoadIconsCommand;
	import nl.fur.bright.plugins.linkchooser.model.Model;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;

	public class LinkChooserController extends PluginController {
		
		public function LinkChooserController() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, _onComplete, false, 0, true);	
		}
		
		/**
		 * Set up the properties of the LinkChooser plugin
		 * @param properties:Object An object with properties, containing the following:
		 * @param callback Function the callback function
		 * @param internalOnly Only internal links allowed
		 * @param showAdvancedOptions Show options like 'target' & 'title'
		 * @param allowedTemplates An array of template id's which are valid for selection. Leave null when every page is valid
		 */		
		public function setProperties(properties:Object):void {
			Model.instance.callback = properties.hasOwnProperty('callback') ? properties.callback : null;
			Model.instance.internalOnly = properties.hasOwnProperty('internalOnly') ? properties.internalOnly : false;
			Model.instance.showAdvancedOptions = properties.hasOwnProperty('showAdvancedOptions') ? properties.showAdvancedOptions : false;
			Model.instance.allowedTemplates = properties.hasOwnProperty('allowedTemplates') ? properties.allowedTemplates : null;
			
			Model.instance.dispatch("propertiesChanged", null);
		}
		
		override public function getProperties():PluginProperties {
			var pp:PluginProperties = new PluginProperties();
			pp.isplugin = false;
			pp.type = "linkchooser";
			pp.pluginname = "Link Chooser";
			pp.contenttype = "String";
			pp.version = "3.0.4";
			pp.modificationdate = new Date(2014,00,17);
			return pp;
		}
		
		private function _onComplete(event:FlexEvent):void {
			if(!ServiceController.serviceExists("treeService")) {
				var trs:RemoteObject = new RemoteObject("gateway");
				trs.endpoint = Application.application.parameters.gateway;
				trs.source = "tree.Tree";
				ServiceController.addRemotingService(trs, "treeService");
			}
			
			CommandController.addToQueue(new LoadIconsCommand());
			
			Model.instance.addEventListener("close", _onClose);
			Model.instance.dispatch("propertiesChanged", null);
		}
		
		private function _onClose(event:BrightEvent):void {
			dispatchEvent(new Event("closePopup"));
		}
	}
}