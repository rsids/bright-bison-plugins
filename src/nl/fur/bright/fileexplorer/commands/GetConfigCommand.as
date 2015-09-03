package nl.fur.bright.fileexplorer.commands
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.brightlib.objects.Folder;
	import nl.fur.bright.fileexplorer.controllers.AppController;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class GetConfigCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("fileService").getConfig();
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			Model.instance.filesVO.settings = result.result;
			
			var folder:Folder = new Folder();
			folder.path = "/";
			folder.label = Model.instance.filesVO.settings.uploadfolder.split("/")[0];
			
			// Cannot send the whole result object,
			// for some reason, it's empty
			VeinDispatcher.instance.dispatch('fileSettingsChanged', ({baseUrl: result.result.baseurl,imageModes: result.result.imageModes, uploadFolder: result.result.uploadfolder}));
			Model.instance.filesVO.folders.addItem(folder);
			CommandController.addToQueue(new GetSubFoldersCommand(), folder);
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:Fault = event["fault"];
			var fc:Number = Number(fault.faultCode);
			if(fc == 1001) {
				// Login
				Alert.show("Your session has expired, please login again", "Session expired");
			} else if(fc > 1000 && fc < 10000) {
				Alert.show(fault.faultString, "Error");
			} else {
				// General server error
				Alert.show("An error occured, please try again", "Error");
			}
		}
	}
}