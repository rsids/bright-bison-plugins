package nl.fur.bright.maps.commands {
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;
	
	public class DeleteMarkerCommand extends BaseCommand implements IAsyncCommand, ICommand {
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("mapsService").deleteMarker(args[0][0]);
			call.markerId = args[0][0];
			call.callback = args[0][1];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			result.token.callback(result.result, result.token.markerId);
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