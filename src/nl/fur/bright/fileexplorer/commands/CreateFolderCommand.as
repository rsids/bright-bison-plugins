package nl.fur.bright.fileexplorer.commands
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.brightlib.objects.Folder;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class CreateFolderCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("fileService").createFolder(args[0][0], Model.instance.filesVO.currentFolder.path);
			call.popup = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			for each(var folder:Folder in result.result) {
				if(folder.numChildren > 0) {
					folder.children = new ArrayCollection();
				}
			}
			Model.instance.filesVO.currentFolder.children = new ArrayCollection(result.result as Array);
			Model.instance.filesVO.folders.refresh();
			/* var ev:ExplorerView = ExplorerView(ViewController.instance.getView("explorerView"));
			ev.files_tree.openNode(ev.files_tree.selectedNode); */
			PopUpManager.removePopUp(result.token.popup);
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