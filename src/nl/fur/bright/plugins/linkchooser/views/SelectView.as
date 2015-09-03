package nl.fur.bright.plugins.linkchooser.views
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.RadioButtonGroup;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.validators.Validator;
	
	import nl.bs10.brightlib.controllers.ValidatorController;
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.events.FileExplorerEvent;
	import nl.flexperiments.events.FlpTreeEvent;
	import nl.flexperiments.tree.FlpTree;
	import nl.flexperiments.tree.Node;
	import nl.fur.bright.plugins.linkchooser.commands.GetChildrenCommand;
	import nl.fur.bright.plugins.linkchooser.model.Model;
	import nl.fur.vein.controllers.CommandController;
	import nl.fur.vein.events.VeinEvent;
	
	public class SelectView extends VBox
	{
		private var _structure:ArrayCollection;
		private var _structureChanged:Boolean;
		
		public var link_rbg:RadioButtonGroup;
		public var int_tree:FlpTree;
		public var ext_txt:TextInput;
		public var email_txt:TextInput;
		public var file_txt:TextInput;
		
		
		public function SelectView() {
			// Reset the tree (easiest way to make sure we've got the most recent changes)
			Model.instance.addEventListener("selectLink", selectLink);
			Model.instance.addEventListener("structureChanged", _onStructureChange);
			Model.instance.addEventListener("propertiesChanged", _onPropertiesChange);
			addEventListener(Event.ADDED_TO_STAGE, _onAdd, false, 0, true);
			
		}
		
		override protected function commitProperties():void {
			if(_structureChanged) {
				_structureChanged = false;
				int_tree.visible = _structure != null;
			}
		}
		
		public function get structure():ArrayCollection
		{
			return _structure;
		}
		
		[Bindable(event="structureChanged")]
		public function set structure(value:ArrayCollection):void {
			if(value !== _structure) {
				_structure = value;
				_structureChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("structureChanged"));
			}
		}
		
		/**
		 * Called from javascript 
		 * @param link The link to the selected file
		 */		
		public function fileExplorerCallback(link:String):void {
			file_txt.text = link;
		}
		
		protected function selectFile():void {
			if(Application.application.parameters.callback) {
				// Loaded in tinymce
				ExternalInterface.addCallback("setFile", fileExplorerCallback );
				ExternalInterface.call('openFileExplorer');
			} else {
				// Loaded in CMS
				parentApplication.openFileExplorer(new FileExplorerEvent(FileExplorerEvent.OPENFILEEXPLOREREVENT, _chosenFileCallback, false));
			}
		}
		
		protected function selectLink(event:BrightEvent = null):void {
			var link:String = "";
			
			var validators:Array = new Array();
			var valresult:Array = new Array();
			switch(link_rbg.selectedValue) {
				case "internal":
					if(int_tree.selectedNode) {
						if(Model.instance.allowedTemplates != null && Model.instance.allowedTemplates.length > 0) {
							var nt:int = Model.instance.allowedTemplates.length;
							var valid:Boolean = false;
							while(--nt > -1) {
								if(int_tree.selectedNode.data.page.itemType == Model.instance.allowedTemplates[nt]) {
									valid = true;
									nt = -1;
								}
							}
							if(!valid) {
								valresult.push("ERROR");
								var templatesac:ArrayCollection = parentApplication.getModelValue('templateVO.templateDefinitions');
								var templates:Array = [];
								nt = Model.instance.allowedTemplates.length;
								while(--nt > -1) {
									var ntac:int = templatesac.length;
									while(--ntac > -1) {
										if(templatesac.getItemAt(ntac).id == Model.instance.allowedTemplates[nt]) {
											templates.push(templatesac.getItemAt(ntac).templatename);
											ntac = -1;
										}
									}
								}
								Alert.show("Invalid page selected. Only the following pagetypes are allowed:\r\n-" + templates.join("\r\n-"), "Invalid page");
							}
						}
						link = '/index.php?tid=' + int_tree.selectedNode.data.treeId;
					} else {
						valresult.push("ERROR");
						Alert.show("Nothing was selected", "Cannot create");
					}
					break;
				case "external":
					validators.push(ValidatorController.createLinkValidator(ext_txt, "text", true));
					valresult = Validator.validateAll(validators);
					link = ext_txt.text;
					break;
				case "email":
					validators.push(ValidatorController.createEmailValidator(email_txt, "text", true));
					valresult = Validator.validateAll(validators);
					link = "mailto:" + email_txt.text;
					break;
				case "file":
					link = file_txt.text;
					break;
			}
			
			if(valresult.length == 0) {
				if(Model.instance.callback != null) {
					Model.instance.callback(link);
					Model.instance.dispatch("close", null);
					
				} else if(Application.application.parameters.callback) {
					var callback:String = Application.application.parameters.callback;						
					ExternalInterface.call(callback, link, Model.instance.title, Model.instance.target, link_rbg.selectedValue);
				}
				
				// Reset structure to prevent flickering when the popup is opened for a 2nd time
				/*structure = null;*/
				
			} else {
				
				switch(link_rbg.selectedValue) {
					
					case "external":
						ext_txt.setFocus();
						break;
					
					case "email":
						email_txt.setFocus();
						break;
				}
			}
		}
		
		protected function structureOpenEvent(event:FlpTreeEvent):void {
			if(event.data.children && event.data.children.length > 0) 
				return;
			
			if(event.data.numChildren > 0) {
				event.data.children = new ArrayCollection();
				CommandController.addToQueue(new GetChildrenCommand(), event.data);
			}
		}
		
		/**
		 * _onAdd function
		 *  
		 **/
		private function _onAdd(event:Event):void {
			structure = null;
			if(Model.instance.propertiesSet) {
				_onPropertiesChange();
			}
			
		}
		
		/**
		 * Called when the setProperties method is called (thus when the popup is opened)
		 * @param event
		 * 
		 */		
		private function _onPropertiesChange(event:BrightEvent = null):void {
			if(!structure) {
				CommandController.addToQueue(new GetChildrenCommand(), null);
			}
		}
		
		private function _onStructureChange(event:BrightEvent):void {
			if(event.data) {
				int_tree.visible = true;
				if(event.data.parent) {
					event.data.parent.children = new ArrayCollection(event.data.children);
					structure.refresh();
					
					if(event.data.parent.parentId == null || event.data.parent.parentId == 0) {
						var node:Node = int_tree.findNodes("data.treeId", event.data.parent.treeId)[0];
						node.open = true;
					}
					
				} else{ 
					structure = new ArrayCollection(event.data.children);
				}
			}
		}
		
		private function _chosenFileCallback(fnvalue:Object):void {
			file_txt.text = fnvalue.path + fnvalue.filename;
		}

	}
}