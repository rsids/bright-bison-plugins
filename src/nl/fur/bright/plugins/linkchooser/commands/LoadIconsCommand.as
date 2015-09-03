package nl.fur.bright.plugins.linkchooser.commands
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	import nl.bs10.brightlib.controllers.IconController;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;

	public class LoadIconsCommand extends BaseCommand implements ICommand, IAsyncCommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var myLoader:Loader = new Loader();
			var myUrlReq:URLRequest = new URLRequest("/bright/cms/assets/swf/icons.swf");
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, resultHandler);
			myLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, faultHandler);
			myLoader.load(myUrlReq);
		}
		
		
		override public function resultHandler(event:Event):void {
			super.resultHandler(event);
			IconController.icons = event.target as LoaderInfo;	
		}
		
		override public function faultHandler(event:Event):void {
			var fault:Fault = new Fault("4005", "File not found");
			var fe:FaultEvent = new FaultEvent(FaultEvent.FAULT, false, true, fault);
			super.faultHandler(fe);
		}
		
	}
}