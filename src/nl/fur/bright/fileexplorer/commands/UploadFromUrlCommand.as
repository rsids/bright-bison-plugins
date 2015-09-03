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

	public class UploadFromUrlCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var call:Object = ServiceController.getService("fileService").uploadFromUrl(args[0][0], args[0][1], Model.instance.filesVO.currentFolder.path);
			call.popup = args[0][2];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			result.token.popup.close();
			Model.instance.filesVO.files = new ArrayCollection(result.result.files as Array);
			var nf:uint = Model.instance.filesVO.files.length;
			while(--nf > -1) {
				if(Model.instance.filesVO.files[nf].filename == result.result.file) { 
					Model.instance.filesVO.currentFile = Model.instance.filesVO.files[nf];
					Model.instance.filesVO.selectedFileIndex = nf;
				}
			}
			VeinDispatcher.instance.dispatch('dataproviderChanged', null);
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