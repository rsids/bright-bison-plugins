package nl.fur.bright.fileexplorer.views {
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.net.FileReferenceList;
	
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.managers.PopUpManager;
	
	import nl.fur.bright.fileexplorer.commands.GetStructureCommand;
	import nl.fur.bright.fileexplorer.commands.UploadFileCommand;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.vein.controllers.CommandController;

	public class UploadView extends TitleWindow  {
		
		[Bindable] public var files_dg:DataGrid;
		[Bindable] public var chb_resize:CheckBox;
		
		protected var frl:FileReferenceList = new FileReferenceList();
		
		protected function uploadFiles():void {
			this.enabled = false;
			Model.instance.filesVO.resizeImages = chb_resize.selected;
			CommandController.addToQueue(new UploadFileCommand(), this);
		}
		
		protected function browseFiles():void {
			frl.addEventListener(Event.SELECT, _selectHandler);
			frl.browse();
		}
		
		protected function getFolders():void {
			CommandController.addToQueue(new GetStructureCommand());
		}
		
		protected function removeFile():void {
			Model.instance.filesVO.uploadFiles.removeItemAt(Model.instance.filesVO.uploadFiles.getItemIndex(this.files_dg.selectedItem));
		}
		
		protected function formatDir(data:Object, column:Object):String {
			if(data.remotedir.path == "/")
				return Model.instance.filesVO.folders.getItemAt(0).label + "/";
				
			return Model.instance.filesVO.folders.getItemAt(0).label + "/" + data.remotedir.path;
		}
		
		protected function sanitize(event:FocusEvent):void {
		}
		
		protected function closePopup():void {
			PopUpManager.removePopUp(this);
		}
		
		private function _cleanFilename(filename:String):String {
			//visual-p+r-transferium-hoogkerk.jpg
			var filearr:Array = filename.split('.');
			var ext:String = filearr.pop();
			var r:RegExp = new RegExp('[^A-z0-9\-_]', 'g');
			
			filename = filearr.join('-').toLowerCase().replace(r, '-') + '.' + ext.toLowerCase();
			return filename;
		}
		
		private function _getExt(filename:String):String {
			var filearr:Array = filename.split('.');
			var ext:String = filearr.pop();
			ext = ext.toLowerCase();
			return ext;
		}
		
		private function _isImage(filename:String):Boolean {
			var filearr:Array = filename.split('.');
			var ext:String = filearr.pop();
			ext = ext.toLowerCase();
			return ext == 'jpg' || ext == 'png' || ext == 'jpeg';
			
		}
		
		private function _selectHandler(event:Event):void {
			var arrFoundList:Array = new Array();
			var sizeList:Array = new Array();
			// Get list of files from fileList, make list of files already on upload list
			for (var i:Number = 0; i < Model.instance.filesVO.uploadFiles.length; i++) {
				
				for (var j:Number = 0; j < this.frl.fileList.length; j++) {
				
					if (Model.instance.filesVO.uploadFiles.getItemAt(i).name == this.frl.fileList[j].name) {
						arrFoundList.push(this.frl.fileList[j].name);
						this.frl.fileList.splice(j, 1);
						j--;
					}
				}
			}

			if (this.frl.fileList.length > 0) {                
				
				for (var k:Number = 0; k < this.frl.fileList.length; k++) {
					
					if(this.frl.fileList[k].size < 10000000 || (_isImage(this.frl.fileList[k].name) && chb_resize.selected)) {
						
						Model.instance.filesVO.uploadFiles.addItem({
							resize: (_isImage(this.frl.fileList[k].name) && chb_resize.selected),
							extension: _getExt(this.frl.fileList[k].name),
							name:this.frl.fileList[k].name,
							size:Model.instance.filesVO.formatFileSize(this.frl.fileList[k].size),
							file:this.frl.fileList[k],
							remotename:_cleanFilename(this.frl.fileList[k].name),//this.frl.fileList[k].name.toLowerCase().split(' ').join('-'),
							remotedir:Model.instance.filesVO.currentFolder});
					
					} else {
						sizeList.push(this.frl.fileList[k].name);
					}
				}
			}                
			if (sizeList.length > 0) {
				Alert.show("The file(s): \n\• " + sizeList.join("\n• ") + "\n\n...exceed the maximum filesize. The maximum filesize is 10 MB.", "File(s) too big");
			}
			if (arrFoundList.length >= 1) {
				Alert.show("The file(s): \n\n• " + arrFoundList.join("\n• ") + "\n\n...are already on the upload list. Please change the filename(s) or pick a different file.", "File(s) already on list");
			}
		}
	}
}