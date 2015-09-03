package nl.fur.bright.plugins.linkchooser.commands {
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import nl.fur.bright.plugins.linkchooser.model.Model;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ServiceController;

	public class GetChildrenCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		override public function execute(...args):void {
			super.execute(args);
			var parentId:int = 0;
			if(args[0][0] != null) 
				parentId = args[0][0].treeId;
				
			var call:Object = ServiceController.getService("treeService").getChildren(parentId, true, false, true);
			call.parent = args[0][0];
			call.resultHandler = this.resultHandler;
			call.faultHandler = this.faultHandler;
		}
		
		override public function resultHandler(event:Event):void {
			var result:ResultEvent = event as ResultEvent;
			/*var child:Object;*/
			
			Model.instance.dispatch("structureChanged", {parent:result.token.parent, children:result.result as Array});
			if(result.token.parent == null || result.token.parent.parentId == null) {
				for each(var child:* in result.result as Array) {
					CommandController.addToQueue( new GetChildrenCommand(), child);
				}
			}
			/*
			for each(child in result.result as Array) {
				result.token.structurearr[child.treeId] = child;
			}
			if(result.token.parent == null) {
				for each(child in result.result as Array) {
					result.token.structure.addItem(child);
				}
			} else {
				result.token.structurearr[result.token.parent.treeId].children = new ArrayCollection(result.result as Array);
			}
			result.token.structure.refresh();*/
			super.resultHandler(event);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
		}
		
	}
}