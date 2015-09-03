package nl.fur.bright.fileexplorer.views {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ProgressBar;
	import mx.events.CloseEvent;
	
	import nl.fur.bright.fileexplorer.model.Model;

	public class ProgressBarView extends TitleWindow {
		
		public var fileProgress:ProgressBar = new ProgressBar();
		public var totalProgress:ProgressBar = new ProgressBar();
		public var cancelBut:Button = new Button();
	
		public function ProgressBarView() {
			layout = "vertical";
			
			title = "Progress";
			setStyle("paddingTop", 40);
			
			fileProgress.indeterminate = 
			totalProgress.indeterminate = false;
			
			fileProgress.mode = "event";
			totalProgress.mode = "polled";
			
			fileProgress.label = "";
			totalProgress.label = "";
		
			fileProgress.width = 200;
			totalProgress.width = 200;
			
			totalProgress.addEventListener(ProgressEvent.PROGRESS, _progressHandler);
			
			fileProgress.source = Model.instance.filesVO;
			totalProgress.source = Model.instance.filesVO.totalProgress;
			
			cancelBut.label = "Cancel upload";
			cancelBut.addEventListener(MouseEvent.CLICK, _cancelHandler);
			
			addChild(fileProgress);
			addChild(totalProgress);
			addChild(cancelBut);	
		}
		
		private function _progressHandler(event:ProgressEvent):void {
			title = "Progress: " + Math.round(totalProgress.percentComplete).toString() + "%";
		}
		
		private function _cancelHandler(event:MouseEvent):void {
			Alert.show("Are you sure you want to cancel the upload?", 
						"Please confirm", 
						Alert.YES | Alert.NO, 
						null, 
						_closeHandler);
		}
		
		private function _closeHandler(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				dispatchEvent(new Event("uploadCanceled"));
			}
		}
	}
}