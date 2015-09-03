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
	import nl.fur.vein.controllers.ServiceController;
	import nl.fur.vein.events.VeinDispatcher;

	public class DeleteFileCommand extends BaseCommand implements IAsyncCommand, ICommand {
		override public function execute(...args):void {
			super.execute(args);
			var files:Array = [];
			for(var i:int = 0; i < args[0][0].length; i++) {
				files.push([args[0][0][i].filename, args[0][0][i].path]);
			}
			var call:Object = ServiceController.getService("fileService").deleteFiles(files, Model.instance.filesVO.currentFile.path);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			if(result.result is String && result.result == "ERROR") {
				Alert.show("Could not delete the file");
				super.resultHandler(event);
				return;
			} else {
				Model.instance.filesVO.currentFile = null;
				Model.instance.filesVO.files = new ArrayCollection(result.result as Array);
				
				VeinDispatcher.instance.dispatch('selectionChanged', null);
				VeinDispatcher.instance.dispatch('dataproviderChanged', null);
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