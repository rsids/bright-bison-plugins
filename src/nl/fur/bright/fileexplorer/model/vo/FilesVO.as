package nl.fur.bright.fileexplorer.model.vo {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import nl.bs10.brightlib.objects.File;
	import nl.bs10.brightlib.objects.Folder;
	import nl.bs10.brightlib.objects.ProgressObject;	
	
	[Bindable]
	public class FilesVO extends EventDispatcher {
		
		private var _currentFile:File;
		
		public var resizeImages:Boolean;

		public var folders:ArrayCollection = new ArrayCollection();
		
		public var folders2:ArrayCollection = new ArrayCollection();
		
		public var files:ArrayCollection = new ArrayCollection();
		
		public var currentFolder:Folder;
		
		public var settings:Object = {};
		
		public var uploadFiles:ArrayCollection = new ArrayCollection();
		
		public var totalProgress:ProgressObject;
		
		public var filters:Array = new Array();
		public var multiple:Boolean = false;
		public var callback:Function;
		public var showSelect:Boolean = false;
		public var showUpload:Boolean = false;
		public var showDelete:Boolean = false;
		public var foldersOnly:Boolean = false;
		public var showThumbs:Boolean = false;
		
		public function formatFileSize(numSize:Number):String {
			var kb:Number = Number(numSize / 1024);
			var mb:Number = Number(numSize / 1048576);
			var gb:Number = Number(numSize / 1073741824);
			
			if(gb > 1)
				return String(gb.toFixed(1) + " gB");
			if(mb > 1)
				return String(mb.toFixed(1) + " mB");
			if(kb > 1)
				return String(kb.toFixed(1) + " kB");
			
			return String(numSize.toFixed(1) + " bytes");
				
		}
		
		[Bindable(event="currentFileChanged")]
		public function set currentFile(file:File):void {
			if(file !== _currentFile) {
				_currentFile = file;
				dispatchEvent(new Event("currentFileChanged"));
			}
		}
		
		public function get currentFile():File {
			return _currentFile;
		}
		
		private var _fileProperties:Object;
		
		[Bindable(event="filePropertiesChanged")]
		public function set fileProperties(value:Object):void {
			if(value !== _fileProperties) {
				_fileProperties = value;
				dispatchEvent(new Event("filePropertiesChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the fileProperties property
		 **/
		public function get fileProperties():Object {
			return _fileProperties;
		}

		private var _selectedFileIndex:int = -1;
		private var _selectedFileIndexChanged:Boolean;
		
		public function get selectedFileIndex():int {
			return _selectedFileIndex;
		}
		
		[Bindable(event="selectedFileIndexChanged")]
		public function set selectedFileIndex(val:int):void	{
			if(_selectedFileIndex != val) {
				_selectedFileIndex = val;
				dispatchEvent(new Event('selectedFileIndexChanged'));
			}
		}
	}
}