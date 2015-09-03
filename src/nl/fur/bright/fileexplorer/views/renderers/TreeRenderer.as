package nl.fur.bright.fileexplorer.views.renderers {
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.bs10.brightlib.objects.Folder;
	import nl.flexperiments.events.FlpTreeEvent;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;

	public class TreeRenderer extends FlpTree {
		
		private var _folder:Folder;
		
		public function TreeRenderer() {
			super();
			dataProvider = Model.instance.filesVO.folders2;
			addEventListener(FlpTreeEvent.OPEN, _openItem);
			setStyle("selectedItemBackgroundColor", 0xeeeeee);
			setStyle("backgroundColor", 0xffffff);
			setStyle("borderColor", 0x333333);
			setStyle("borderStyle", "solid");
			setStyle("borderThickness", 1);
		}
		
		private function _openItem(event:FlpTreeEvent):void {
			this.selectedNode = event.currentTarget as Node;
		}
		
		[Bindable]
		public function get folder():Folder {
			if(!this.selectedNode) {
				this.selectedNode = this.findNodes("data.path", "/")[0];
			}
			_folder = selectedNode.data as Folder;
			/* closeAll(); */
			return _folder;
		}
		
		public function set folder(value:Folder):void {
			this._folder = value;
		}
		
	}
}