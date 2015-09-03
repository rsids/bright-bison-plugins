package nl.fur.bright.fileexplorer.commands
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.DisplayObject;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.rpc.Fault;
	import mx.utils.Base64Encoder;
	
	import nl.bs10.brightlib.objects.ProgressObject;
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.fur.bright.fileexplorer.utils.ImageUtils;
	import nl.fur.bright.fileexplorer.views.ProgressBarView;
	import nl.fur.bright.fileexplorer.views.UploadViewLayout;
	import nl.fur.vein.commands.BaseCommand;
	import nl.fur.vein.commands.IAsyncCommand;
	import nl.fur.vein.commands.ICommand;
	import nl.fur.vein.controllers.CommandController;

	public class UploadFileCommand extends BaseCommand implements IAsyncCommand, ICommand {
		
		private var _current:int = 0;
		private var _uploadPopup:IFlexDisplayObject;
		private var _progressPopup:IFlexDisplayObject;
		
		private var _fr:FileReference;
		
		private var _failed:Array = new Array();
		
		private var _uploaded:Number;
		
		override public function execute(...args):void {
			super.execute(args);
			_uploaded = 
			_current = 0;
			_failed = new Array();
			Model.instance.filesVO.totalProgress = new ProgressObject();
			
			Model.instance.filesVO.totalProgress.bytesLoaded = 0;
			Model.instance.filesVO.totalProgress.bytesTotal = Model.instance.filesVO.uploadFiles.length;
			
			_progressPopup = PopUpManager.createPopUp(Application.application as DisplayObject, ProgressBarView, true);
			_progressPopup.addEventListener("uploadCanceled", _cancelUploads);
			PopUpManager.centerPopUp(_progressPopup);
			
			_fr = new FileReference();
			
			_uploadPopup = args[0][0];
			_uploadNextFile();			
		}
		
		private function _uploadNextFile():void {
			var sendVars:URLVariables = new URLVariables();
			var request:URLRequest = new URLRequest();
			var uploadData:Object = Model.instance.filesVO.uploadFiles.getItemAt(_current);
			
			sendVars.action = "upload";
			sendVars.sessionId = Model.instance.filesVO.settings.sessionId;
			sendVars.remotename = uploadData.remotename;
			sendVars.remotedir = uploadData.remotedir.path.toString();
			
			request.method = URLRequestMethod.POST;
			request.data = sendVars;
			request.url	= Model.instance.filesVO.settings.uploadpath;
			
			if(uploadData.resize && Model.instance.filesVO.resizeImages) {
				
				ImageUtils.resize(uploadData.file, uploadData.extension, 1920,1080, function(ba:ByteArray):void {
					var enc:Base64Encoder = new Base64Encoder();
					enc.encodeBytes(ba);
					sendVars.filedata = enc.toString();
					
					var loader:URLLoader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					loader.addEventListener(ProgressEvent.PROGRESS, _progressHandler);
					loader.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler, false, 0, true);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler, false, 0, true);
					loader.addEventListener(Event.COMPLETE, _uploadHandler, false, 0, true);
					
					loader.load(request);
				});

			} else {
				
				_fr.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,	_uploadHandler);
				_fr.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
				_fr.removeEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
				_fr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
				
				_fr = uploadData.file as FileReference;
				_fr.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, _uploadHandler);
				_fr.addEventListener(ProgressEvent.PROGRESS, _progressHandler);
				_fr.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
				_fr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
				_fr.upload(request, "file", false);	
			}

		}
		
		private function _progressHandler(event:ProgressEvent):void {
			Model.instance.filesVO.dispatchEvent(event);
			Model.instance.filesVO.totalProgress.bytesLoaded = _uploaded + (event.bytesLoaded / event.bytesTotal);
		}
		
		private function _uploadHandler(event:Event):void {
			var result:Object;
			if(event is DataEvent) {
				// Normal upload
				result = JSON.decode(event['data']);
				
			} else {
				// Image resize upload
				result = JSON.decode(event.target.data.toString());
			}
			_uploaded++;
			if(result.result == "ERROR") {
				_failed.push("- " + result.message + ": " + result.thefile);
				_current++;
			} else {
				Model.instance.filesVO.uploadFiles.removeItemAt(_current);
			}
			if(Model.instance.filesVO.uploadFiles.length > _current) {
				_uploadNextFile(); 
			} else {
				if(_fr) {
					_fr.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,	_uploadHandler);
					_fr.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
					_fr.removeEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
					_fr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
				}
				
				if(_failed.length == 0) {
					PopUpManager.removePopUp(_uploadPopup);
				} else {
					Alert.show("Some errors occured during the upload. The following files are not uploaded:\r\n" + _failed.join("\r\n"), "Upload failed");
					UploadViewLayout(_uploadPopup).enabled = true;
				}
				resultHandler(new Event("result"));
				
			}
		}
		
		private function _ioErrorHandler(event:IOErrorEvent):void {
			super.faultHandler(new Event("fault"));		
		}
		
		private function _securityErrorHandler(event:SecurityErrorEvent):void {
			super.faultHandler(new Event("fault"));
		}
		
		private function _cancelUploads(event:Event):void {
			_uploadPopup["enabled"] = true;
			resultHandler(new Event("result"));
		}
		
		override public function resultHandler(event:Event):void {
			super.resultHandler(event);
			PopUpManager.removePopUp(_progressPopup);
			CommandController.addToQueue(new GetFilesCommand(), Model.instance.filesVO.currentFolder);
		}
		
		override public function faultHandler(event:Event):void {
			super.faultHandler(event);
			var fault:Fault = event["fault"];
			var fc:Number = Number(fault.faultCode);
			if(fc == 1001) {
				// Login
				Alert.show("Your session has expired, please login again", "Session expired");
			} else if(fc > 1000 && fc < 10000) {
				Alert.show(fault.faultString, "Error");
			} else {
				// General server error
				Alert.show("An error occured, please try again", "Error");
			}
			
			PopUpManager.removePopUp(_progressPopup);
		}
	}
}