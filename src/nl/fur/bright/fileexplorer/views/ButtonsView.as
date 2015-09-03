package nl.fur.bright.fileexplorer.views
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.ButtonBar;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.ItemClickEvent;
	import mx.managers.PopUpManager;
	
	import nl.fur.bright.fileexplorer.commands.DeleteFileCommand;
	import nl.fur.bright.fileexplorer.commands.DeleteFolderCommand;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.bs10.brightlib.objects.Folder;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.controllers.ViewController;
	import nl.fur.vein.views.IView;

	public class ButtonsView extends ButtonBar implements IView	{

		private var _viewId:String;
		
		private var _parent:Folder;
		
		public function ButtonsView() {
			this.addEventListener(ItemClickEvent.ITEM_CLICK, _itemClick);
		}
		
		public function get viewId():String {
			return this._viewId;
		}
		
		public function set viewId(value:String):void {
			this._viewId = value;
			ViewController.instance.registerView(this);
		}
		
		private function _itemClick(event:ItemClickEvent):void {
			var popup:IFlexDisplayObject;
			var callback:String;
			var file:String;
			
			switch(event.label) {
				case "New Folder":
					popup = PopUpManager.createPopUp(Application.application as DisplayObject, NewFolderView, true);
					PopUpManager.centerPopUp(popup);
					break;
					
				case "Delete Folder":
					if(!Model.instance.filesVO.currentFolder) {
						Alert.show("No folder was selected", "Could not delete");
						return;
					} else {
						var explorerView:ExplorerView = ViewController.instance.getView("explorerView") as ExplorerView;
						this._parent = explorerView.folder_tree.selectedNode.parentNode.data as Folder;
						if(!this._parent) {
							this._parent = new Folder();
						}
					}
					break;
				
				case "Upload File(s)":
					Model.instance.filesVO.uploadFiles = new ArrayCollection()
					popup = PopUpManager.createPopUp(Application.application as DisplayObject, UploadViewLayout, true);
					PopUpManager.centerPopUp(popup);
					break;
					
				case "Delete File":
					if(!Model.instance.filesVO.currentFile) 
						return;
					Alert.show("Are you sure you want to delete this file?",
								"Please confirm",
								Alert.YES|Alert.CANCEL,
								null,
								_deleteFileHandler);
					break;
					
				case "Select File":
					if(!Model.instance.filesVO.currentFile) 
						return;
					if(Application.application.parameters.callback) {
						callback = Application.application.parameters.callback;
						file = Model.instance.filesVO.settings.fileurl + Model.instance.filesVO.currentFile.path + Model.instance.filesVO.currentFile.filename;
						ExternalInterface.call(callback, file);
					} else {
						this.parent.dispatchEvent(new Event("closePopup"));
						Model.instance.filesVO.callback(Model.instance.filesVO.currentFile);
					}
					/* ExplorerViewLayout(ViewController.instance.getView('explorerView')).files_tree.closeAll(); */
					break;
					
				case "Select Folder":
					if(!Model.instance.filesVO.currentFolder) 
						return;
					if(Application.application.parameters.callback) {
						callback = Application.application.parameters.callback;
						file = Model.instance.filesVO.settings.fileurl + Model.instance.filesVO.currentFolder.path;
						ExternalInterface.call(callback, file);
					} else {
						this.parent.dispatchEvent(new Event("closePopup"));
						Model.instance.filesVO.callback(Model.instance.filesVO.currentFolder);
					}
			}
		}
		
		
		private function _deleteFileHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {		
				CommandController.addToQueue(new DeleteFileCommand(), Model.instance.filesVO.currentFile);
			}
		}
	}
}