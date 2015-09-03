package nl.bs10.gmaps.commands
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SetMarkerPositionCommand extends BaseCommand implements IAsyncCommand, ICommand
	{
		override public function execute(...args):void {
			super.execute(args);
			
			var call:Object = ServiceController.getService("mapsService").setMarkerPosition(args[0][0], args[0][1], args[0][2]);
			call.callback = args[0][3];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
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