package nl.fur.bright.fileexplorer.views.renderers {
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TileList;
	import mx.controls.listClasses.IListItemRenderer;
	
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.bs10.fileexplorer.model.objects.File;
	
	public class FileRenderer extends Canvas implements IListItemRenderer {
		
		public var filename_lbl:Label = new Label();
		public var icon_img:Image = new Image();
		
		private var _file:File;
		
		private var _selected:Boolean = false;
		
		private var _thumbfailed:Boolean = false;
		
		public function FileRenderer() {
			
			super();
			mouseChildren = false;
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_OVER, _hoverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, _hoverHandler);
			icon_img.addEventListener(IOErrorEvent.IO_ERROR, _iconNotFound);
			
			width = 120;
			height = 130;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			icon_img.width = 96;
			icon_img.height = 96;
			
			icon_img.x = 12;
			icon_img.y = 7;
			
			icon_img.setStyle("horizontalAlign", "center");
			icon_img.setStyle("verticalAlign", "middle");
			
			filename_lbl.width  = 100;
			filename_lbl.x = 10;
			filename_lbl.y = 104;
			addChild(icon_img);
			addChild(filename_lbl);
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if(!value) return;
			
			_file = new File();
			_file.filename = value.filename;
			_file.extension = value.extension;
			_file.filesize = value.filesize;
			_file.path = value.path;
			filename_lbl.text = _file.filename;
			if(_file.extension == "jpg" || _file.extension == "png" || _file.extension == "gif" || _file.extension == 'pdf') {
				_thumbfailed = false;
				
				var arr:Array = _file.filename.split(".");
				var thumbname:String = "";
				arr[arr.length -2] += "__thumb__";
				if(_file.extension == 'pdf') {
					arr.pop();
					arr.push('jpg');
				}
				thumbname = arr.join(".");

				icon_img.source = Model.instance.filesVO.settings.fileurl + _file.path + thumbname;
			} else {				
				icon_img.source = "assets/icons/" + _file.extension + ".png";
			}
		}
		
		private function _iconNotFound(event:IOErrorEvent):void {
			if(!_thumbfailed && (_file.extension == "jpg" || _file.extension == "png" || _file.extension == "gif")) {
				_thumbfailed = true;	
				icon_img.source = Model.instance.filesVO.settings.fileurl + _file.path + _file.filename;
				return;
			}
			if(icon_img.source != "assets/icons/" + _file.extension + ".png") {
				icon_img.source = "assets/icons/" + _file.extension + ".png";
				return
			}
			icon_img.source = "assets/icons/default.png";			
		}
		
		private function _hoverHandler(event:MouseEvent):void {
			graphics.clear();
			if(event.type == MouseEvent.MOUSE_OVER) {
				graphics.lineStyle(1, 0x99DEFD, 1);
				graphics.beginFill(0xE8F6FD, 1);
				graphics.drawRoundRect(5,5,110,120,10,10);
				graphics.endFill();
			} else if(_selected) {
				graphics.lineStyle(1, 0x99DEFD, 1);
				graphics.beginFill(0xC6E8FA, 1);
				graphics.drawRoundRect(5,5,110,120,10,10);
				graphics.endFill();
			}
		}
		
		private function _selectionChanged(event:Event):void {
			var tl:TileList = event.currentTarget as TileList;
			
			graphics.clear();
			_selected = (tl.selectedItem == data);
			if(_selected) {
				graphics.lineStyle(1, 0x99DEFD, 1);
				graphics.beginFill(0xC6E8FA, 1);
				graphics.drawRoundRect(5,5,110,120,10,10);
				graphics.endFill();
			}
		}
		
		override public function set owner(value:DisplayObjectContainer):void {
			super.owner = value;
			if(!value) 
				return;
			owner.removeEventListener("SelectedFileChanged", _selectionChanged);
			owner.addEventListener("SelectedFileChanged", _selectionChanged);
		}
		
	}
}