package nl.fur.bright.fileexplorer.views
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.ArrayUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.TileList;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.Application;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.events.ListEvent;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Fieldtype;
	import nl.bs10.brightlib.objects.File;
	import nl.bs10.brightlib.objects.Folder;
	import nl.flexperiments.audio.FlId3;
	import nl.flexperiments.display.Transformations;
	import nl.flexperiments.events.FlDataEvent;
	import nl.flexperiments.events.FlpTreeEvent;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;
	import nl.fur.bright.fileexplorer.commands.DeleteFileCommand;
	import nl.fur.bright.fileexplorer.commands.DeleteFolderCommand;
	import nl.fur.bright.fileexplorer.commands.GetConfigCommand;
	import nl.fur.bright.fileexplorer.commands.GetFilesCommand;
	import nl.fur.bright.fileexplorer.commands.GetSubFoldersCommand;
	import nl.fur.bright.fileexplorer.commands.MoveFileCommand;
	import nl.fur.bright.fileexplorer.controllers.AppController;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinDispatcher;
	import nl.fur.vein.events.VeinEvent;

	public class ExplorerView extends HDividedBox {
		
		protected static const THUMBW:int = 98;
		protected static const THUMBH:int = 74;
		
		[Bindable] public var folder_tree:FlpTree;
		[Bindable] public var files_list:TileList;
		[Bindable] public var thumb_img:Image;
		[Bindable] public var thumbnail:Bitmap;
		[Bindable] public var info_canvas:Canvas;
		[Bindable] public var props_vs:ViewStack;
		[Bindable] public var dimensions:String = '';
		[Bindable] public var id3:Object;
		
		private var _moveObj:Object;
		
		private var _parent:Folder;
		
		
		
		public function setFilters(event:VeinEvent = null):void {
			
			//files_tree.percentWidth = (Model.instance.filesVO.foldersOnly) ? 100 : 30;
			if(Model.instance.filesVO.foldersOnly || !Model.instance.filesVO.files)
				return;
				
			Model.instance.filesVO.files.filterFunction = _fileFilter;
			Model.instance.filesVO.files.refresh();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			info_canvas.graphics.clear();
			info_canvas.graphics.lineStyle(1, 0xd8d8d8, 1);
			info_canvas.graphics.drawRect(2,2,THUMBW,THUMBH);
			
			Model.instance.filesVO.addEventListener("currentFileChanged", _currentFileChangedHandler);
			VeinDispatcher.instance.addEventListener('dataproviderChanged', setFilters);
			VeinDispatcher.instance.addEventListener('selectionChanged', selectionChanged);
			VeinDispatcher.instance.addEventListener('selectedFolderChanged', _selectedFolderChanged);
			VeinDispatcher.instance.addEventListener('initializationReady', _initializationReady);
		}
		
		public function selectionChanged(event:Event = null):void {
			if(event && (event is ListEvent || event is KeyboardEvent ))  {
				var ri:int = files_list.selectedIndex;
				Model.instance.filesVO.selectedFileIndex = ri;
				
				Model.instance.filesVO.currentFile = files_list.selectedItem as File;
				var path:String = (Model.instance.filesVO.currentFile.path && Model.instance.filesVO.currentFile.path != 'null') ? Model.instance.filesVO.currentFile.path : "";
				var file:String = path + Model.instance.filesVO.currentFile.filename;
				var url:String = Model.instance.filesVO.settings.fileurl + file;
				AppController(parent).dispatch('SELECTEDFILECHANGED', {path:path, file:file, url: url});
			}
			
		}
		
		protected function itemOpenEvent(event:FlpTreeEvent):void {
			if(event.data.children && event.data.children.length > 0) 
				return;
			
			if(event.data.numChildren > 0) {
				event.data.children = new ArrayCollection();
				CommandController.addToQueue(new GetSubFoldersCommand(), event.data);
			}
			
			folder_tree.selectedNode = event.currentTarget as Node;
		}
		
		protected function getFilesCommand(event:FlpTreeEvent):void {
			if(event.data is Node || event.data == null) 
				return;

			/*files_list.selectedIndex = -1;*/
			Model.instance.filesVO.currentFile = null;
			Model.instance.filesVO.selectedFileIndex = -1;
			_resetProperties();

			if(event.data is Folder) {
				Model.instance.filesVO.currentFolder = event.data as Folder;
				
			} else {
				Model.instance.filesVO.currentFolder = event.data.children.getItemAt(0) as Folder;
					
			}
			if(Model.instance.filesVO.foldersOnly)
				return;
				
			CommandController.addToQueue(new GetFilesCommand(), Model.instance.filesVO.currentFolder);
		}
		
		protected function startFileDrag(event:DragEvent):void {
			var ds:DragSource = new DragSource();
		  	ds.addData(event.currentTarget.selectedItem, "FlpTreeData");
		  	var ir:IListItemRenderer = TileList(event.currentTarget).itemToItemRenderer(event.currentTarget.selectedItem);
		  	var bmd:BitmapData = new BitmapData(ir.width, ir.height, true, 0x000);
		  	bmd.draw(ir);
		  	
		  	var img:Image = new Image();
		  	img.source = new Bitmap(bmd);
		  	img.width = ir.width;
		  	img.height = ir.height;
		  	img.y += ir.y;
		  	DragManager.doDrag(event.dragInitiator, ds, event, img);
		}
		
		protected function dropFile(event:FlpTreeEvent):void {
			if(event.data.newparent.children)
				event.data.newparent.children.removeItemAt(event.data.newindex);
			event.data.newparent.children.refresh();
			_moveObj = event.data;
			Alert.show("Are you sure you want to move this file?\r\nReferences to this files are NOT updated", "Please Confirm", Alert.YES|Alert.CANCEL, this, _closeHandler);
		}
		
		protected function addFolder():void {
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, NewFolderView, true);
			PopUpManager.centerPopUp(popup);
		}
		
		protected function deleteFolder(node:Node):void {
			if(!Model.instance.filesVO.currentFolder) {
				Alert.show("No folder was selected", "Could not delete");
				return;
			} else {
				
				_parent = node.parentNode.data as Folder;
				if(!_parent) {
					_parent = new Folder();
				}
				Alert.show("Are you sure you want to delete this folder?",
							"Please confirm",
							Alert.YES|Alert.CANCEL,
							null,
							_deleteHandler);
			}
		}
		
		protected function refresh():void {
			Model.instance.filesVO.currentFolder = null;
			Model.instance.filesVO.currentFile = null;
			Model.instance.filesVO.files = null;
			Model.instance.filesVO.folders.removeAll();
			Model.instance.filesVO.folders = new ArrayCollection();
			Model.instance.filesVO.selectedFileIndex = -1;
			CommandController.addToQueue(new GetConfigCommand());
		}
		
		protected function uploadFiles():void {
			Model.instance.filesVO.uploadFiles = new ArrayCollection();
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, UploadViewLayout, true);
			PopUpManager.centerPopUp(popup);
		}
		
		protected function uploadFromUrl():void {
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(Application.application as DisplayObject, UploadFromUrlViewLayout, true);
			PopUpManager.centerPopUp(popup);
			
		}
		
		protected function deleteFile():void {
			if(!Model.instance.filesVO.currentFile) 
				return;
			
			Alert.show("Are you sure you want to delete this file / these files?",
						"Please confirm",
						Alert.YES|Alert.CANCEL,
						null,
						_deleteFileHandler);
			
		}
		
		protected function onKeyUp(event:KeyboardEvent):void {
			if(event.altKey || event.ctrlKey || !Model.instance.filesVO.files) {
				return;
			}
			
			var char:String = String.fromCharCode(event.charCode).toLowerCase(),
				len:int = Model.instance.filesVO.files.length,
				filename:String;
			
			for(var i:uint = 0; i < len; i++) {
				filename = Model.instance.filesVO.files.getItemAt(i).filename;
				filename = filename.toLowerCase();
				if(filename.substr(0,1) === char) {
					Model.instance.filesVO.selectedFileIndex = i;
					i = len;
					selectionChanged(event);
				}
			}
			
		}
		
		protected function selectFile():void {
			if(!Model.instance.filesVO.currentFile) 
				return;
			
			
			if(Application.application.parameters.callback) {
				var path:String = (Model.instance.filesVO.currentFile.path && Model.instance.filesVO.currentFile.path != 'null') ? Model.instance.filesVO.currentFile.path : "";
				var file:String = Model.instance.filesVO.settings.fileurl + path + Model.instance.filesVO.currentFile.filename;
				AppController(parent).dispatch('SELECTFILE', {path:path, file:file});
			} else {
				parent.dispatchEvent(new Event("closePopup"));
				Model.instance.filesVO.callback(Model.instance.filesVO.currentFile);
			}
			Model.instance.filesVO.selectedFileIndex = -1;
		}
		
		protected function selectFolder():void {
			parent.dispatchEvent(new Event("closePopup"));
			Model.instance.filesVO.callback(Model.instance.filesVO.currentFolder);
			
		}
		
		protected function getFileType(file:File):String {
			var ext:String = file.extension.toUpperCase();
			_resetProperties();
			var path:String = (file.path && file.path != 'null') ? file.path : "";
			switch(ext) {
				case "JPG":
				case "JPEG":
				case "PNG":
				case "GIF":
				case "TIFF":
				case "BMP":
					props_vs.selectedIndex = 1;
					_loadImage(file);
					dimensions = file.width + ' x ' + file.height;
					return ext +'-Image';
				case "DOC":
				case "DOCX":
					return "Word Document";
				case "XLS":
				case "XLSX":
					return "Excel Spreadsheet";
				case "PPT":
				case "PPTX":
					return "Powerpoint Presentation";
				case "ZIP":
				case "RAR":
					return "Compressed File";
				case "PDF":
					_loadImage(file);
					return "PDF Document";
				case "MP3":
					props_vs.selectedIndex = 2;
					_loadAudio(file);
					return 'MP3 Audio File';
			}
			return ext + " File";
		}
		
		private function _loadImage(file:File):void {
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, _imageLoaded, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void{}, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, function():void{}, false, 0, true);
			
			var path:String = (file.path && file.path != 'null') ? file.path : "";
			var url:String = '/bright/actions/image.php?mode=brightthumb&src=/' + Model.instance.filesVO.settings.uploadfolder + path + file.filename;
			 
			ldr.load(new URLRequest(url));
		}
		
		private function _imageLoaded(event:Event):void {
			var ldr:LoaderInfo = event.currentTarget as LoaderInfo;
			var bmd:BitmapData = new BitmapData(THUMBW,THUMBH, true, 0xffffff);
			var m:Matrix = Transformations.getScaleMatrix(ldr.content, THUMBW, THUMBH, false);
			m.ty = (THUMBH - (ldr.content.height * m.d)) / 2;
			m.tx = (THUMBW - (ldr.content.width * m.a)) / 2;
			bmd.draw(ldr.content, m, null, null, null, true);
			thumbnail = null;
			thumbnail = new Bitmap(bmd);
			thumbnail.smoothing = true;
			thumbnail.pixelSnapping = PixelSnapping.NEVER;
		}
		
		private function _loadAudio(file:File):void {
			var mp3:FlId3 = new FlId3();
			mp3.addEventListener(FlDataEvent.DATAEVENT, _id3Handler);
			var path:String = (file.path && file.path != 'null') ? file.path : "";
			mp3.loadMp3(Model.instance.filesVO.settings.fileurl + path + file.filename);
		}
		
		private function _id3Handler(event:FlDataEvent):void {
			if(event.data.hasOwnProperty("image")) {
				thumbnail = event.data.image.content as Bitmap;
			}
			
     		id3 = event.data;
		}
		
		private function _closeHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES)			
				CommandController.addToQueue(new MoveFileCommand(), _moveObj.item.path, _moveObj.newparent.path, _moveObj.item.filename);
			_moveObj = null;
		}
		
		private function _fileFilter(obj:File):Boolean {
			var isExt:Boolean = (!Model.instance.filesVO.filters || Model.instance.filesVO.filters.length == 0 || ArrayUtil.arrayContainsValue(Model.instance.filesVO.filters, obj.extension));
			var isThumb:Boolean = obj.filename.indexOf("__thumb__") != -1;
			return isExt && !isThumb;
		}
		
		private function _deleteHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {		
				CommandController.addToQueue(new DeleteFolderCommand(), Model.instance.filesVO.currentFolder, _parent);
			}
		}
		
		private function _deleteFileHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {		
				CommandController.addToQueue(new DeleteFileCommand(), files_list.selectedItems);
				_resetProperties();
			}
		}
		
		private function _currentFileChangedHandler(event:Event):void {
			if(Model.instance.filesVO.currentFile == null)
				_resetProperties();
		}
		
		private function _resetProperties():void {
			dimensions = '';
			thumbnail = null;
			id3 = null;
			props_vs.selectedIndex = 0;
			/*Model.instance.filesVO.selectedFileIndex = -1;*/
			
		}
		
		private function _selectedFolderChanged(event:VeinEvent):void {
			var node:Node = folder_tree.findNodes("data.path", Model.instance.filesVO.currentFolder.path)[0];
			folder_tree.selectedNode = node;
		}
		
		private function _initializationReady(event:VeinEvent):void {
			var node:Node = folder_tree.findNodes("data.path", Model.instance.filesVO.currentFolder.path)[0];
			node.open = true;
		}
	}
}