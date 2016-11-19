package nl.fur.bright.fileexplorer.views.renderers
{
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TileList;
	import mx.controls.listClasses.IListItemRenderer;
	
	import nl.bs10.brightlib.objects.File;
	import nl.fur.bright.fileexplorer.model.Model;

	public class SmallFileRenderer extends Canvas implements IListItemRenderer {
		
		private var _icon:Image = new Image();
		private var _label:Label = new Label();
		private var _selected:Boolean = false;
		private var _file:File;
		private var _notFound:Boolean = false;
		
		public function SmallFileRenderer() {
			
			super();
			mouseChildren = false;
			buttonMode = true;
			
			_icon.addEventListener(IOErrorEvent.IO_ERROR, _iconNotFound);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_icon.width = 16;
			_icon.height = 16;
			_icon.scaleContent = false;
			
			_label.height = 20;
			_label.width = 200;
			
			_label.x = 22;
			_label.setStyle("textAlign", "left");
			_icon.y = 2;
			_icon.x = 2;
			
			addChild(_icon);
			addChild(_label);
			
			var showFile:ContextMenuItem = new ContextMenuItem("Open File (in new window)");
			showFile.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _openItem);
			
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems= [showFile];
			
			contextMenu = cm;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			
			if(!value)
				return;
				
			_file = new File();
			_file.filename = value.filename;
			_file.extension = value.extension;
			_file.filesize = value.filesize;
			_file.path = value.path;
			
			_label.text = toolTip = _file.filename;
			_notFound = false;
			if(_file.extension.length > 2 && _file.extension.length < 5) {
				_icon.source = "/bright/cms/assets/icons/" + _file.extension + ".png";
			} else {
				_icon.source = "/bright/cms/assets/icons/default_small.png";
			}
		}
		
		private function _iconNotFound(event:IOErrorEvent):void {
			if(_notFound)
				return;
				
			_icon.source = "/bright/cms/assets/icons/default_small.png";	
			_notFound = true;
		}
		
		
		private function _openItem(event:ContextMenuEvent):void {
			navigateToURL(new URLRequest(Model.instance.filesVO.settings.fileurl +  _file.path + _file.filename));
		}
		
	}
}