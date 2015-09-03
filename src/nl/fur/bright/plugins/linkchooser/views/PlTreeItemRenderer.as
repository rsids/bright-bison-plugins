package nl.fur.bright.plugins.linkchooser.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import nl.bs10.brightlib.controllers.IconController;
	import nl.flexperiments.tree.FlpTreeItemRenderer;
	import nl.fur.bright.plugins.linkchooser.model.Model;

	[Bindable]
	public class PlTreeItemRenderer extends FlpTreeItemRenderer {
		private var _dataChanged:Boolean = false;
		private var _allowedTemplatesChanged:Boolean = false;
		
		public function PlTreeItemRenderer() {
			super();
			Model.instance.addEventListener('allowedTemplatesChanged', _onAllowedTemplatesChanged, false, 0, true);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			icon_img.height = 18;
			icon_img.setStyle("verticalAlign", "middle");
			icon_img.scaleContent = false;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			_dataChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_dataChanged) {
				_dataChanged = false;
			
				toolTip = "Pid: " + data.page.pageId;
				
				
				var d1:Date = new Date();
				d1.setTime(data.page.publicationdate * 10);	
				var d2:Date = new Date();
				d2.setTime(data.page.expirationdate * 10);
				var d3:Date = new Date();
				
				if(data.page) {
					if(data.page.allwayspublished || (d1.getTime() <= d3.getTime() && d2.getTime() >= d3.getTime())) {
						setStyle('color', 0x000000);
						icon_img.alpha = 1;
					} else {
						setStyle('color', 0x666666);
						icon_img.alpha = .6;
					}
					_allowedTemplatesChanged = true;
				}
			
			
				if(data.shortcut > 0) {
					label_txt.htmlText = "<i>Shortcut to " + label_txt.htmlText + "</i>";
				}
			}
			
			if(_allowedTemplatesChanged) {
				if(Model.instance.allowedTemplates != null && Model.instance.allowedTemplates.length > 0) {
					var found:Boolean = false;
					var nt:uint = Model.instance.allowedTemplates.length;
					while(--nt > -1 && !found) {
						if(data.page.itemType == Model.instance.allowedTemplates[nt]) {
							found = true;
						}
					}
					if(!found) {
						setStyle('color', 0x7b7b7b);
					}
				}
			}
				
			invalidateDisplayList();
		}
		
		private function _onAllowedTemplatesChanged(event:Event):void {
			_allowedTemplatesChanged = true;
			Model.instance.removeEventListener('allowedTemplatesChanged', _onAllowedTemplatesChanged);
		}
	}
}