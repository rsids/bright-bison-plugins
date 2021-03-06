package nl.fur.bright.fileexplorer.commands
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class DeleteFolderCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("fileService").deleteFolder(args[0][0].label, args[0][1].path);
			//call.popup = args[0][0];
			call.parent = args[0][1];
			call.label = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;

			result.token.parent.children = new ArrayCollection(result.result as Array);
			
			Model.instance.filesVO.folders.refresh();
			
			// Select parent folder
			Model.instance.filesVO.currentFolder = result.token.parent;
			CommandController.addToQueue(new GetFilesCommand(), Model.instance.filesVO.currentFolder);
			VeinDispatcher.instance.dispatch('selectedFolderChanged', null);
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