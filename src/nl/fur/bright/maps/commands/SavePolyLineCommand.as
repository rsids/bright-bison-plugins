package nl.fur.bright.maps.commands
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.ResultEvent;
	
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.fur.bright.maps.interfaces.IBrightPolyLine;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.ServiceController;

	public class SavePolyLineCommand extends BaseCommand implements IAsyncCommand, ICommand
	{
		
		private var _polyLine:IBrightPolyLine;
		
		override public function execute(...args):void
		{
			super.execute(args);
			
			_polyLine = args[0][0] as IBrightPolyLine;
			
			var call:Object = ServiceController.getService("mapsService").setPoly(_polyLine.polyPage);
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void
		{
			var result:ResultEvent = event as ResultEvent;
			_polyLine.polyPage.polyId = (result.result as PolyPage).polyId;
			
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void
		{
			super.faultHandler(event);
			var fault:Fault = event["fault"];
			var fc:Number = Number(fault.faultCode);
			if (fc == 1001)
			{
				// Login
				Alert.show("Your session has expired, please login again", "Session expired");
			}
			else if (fc > 1000 && fc < 10000)
			{
				Alert.show(fault.faultString, "Error");
			}
			else
			{
				// General server error
				Alert.show("An error occured, please try again", "Error");
			}
		}
		
	}
}