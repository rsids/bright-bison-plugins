package nl.fur.bright.fileexplorer.commands {
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.brightlib.objects.Folder;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class GetSubFoldersCommand extends BaseCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var pa:String = String(args[0][0].path);
			if(pa.substring(0,1) == "/");
				pa.substring(1);
			var call:Object = ServiceController.getService("fileService").getSubFolders(pa);
			call.parent = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			result.token.parent.children = new ArrayCollection(result.result as Array);
			for each(var folder:Folder in result.token.parent.children) {
				if(folder.numChildren > 0) {
					folder.children = new ArrayCollection();
				}
			}
			Model.instance.filesVO.folders.refresh();
			if(result.token.parent.path == "/") {
				Model.instance.filesVO.currentFolder = result.token.parent as Folder;
				/*CommandController.addToQueue(new GetFilesCommand(), Model.instance.filesVO.currentFolder);*/
				VeinDispatcher.instance.dispatch('selectedFolderChanged', null);
				VeinDispatcher.instance.dispatch('initializationReady', null);
			}
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