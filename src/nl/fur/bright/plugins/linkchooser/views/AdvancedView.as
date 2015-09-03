package nl.fur.bright.plugins.linkchooser.views
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.containers.VBox;
	
	import nl.fur.bright.plugins.linkchooser.model.Model;
	
	public class AdvancedView extends VBox
	{
		
		public static const TARGETS:Array = [{data:'_self', label:'Current tab / window'}, {data:'_blank', label:'New tab / window'}];
		
		public function AdvancedView()
		{
			super();
		}
		
		protected function onTitleFocusOut(event:FocusEvent):void {
			Model.instance.title = event.currentTarget.text;
		}
		
		protected function onTargetChange(event:Event):void {
			Model.instance.target = event.currentTarget.selectedItem.data;
		}
	}
}