package nl.fur.bright.linklist.renderers {
	import mx.containers.HBox;
	import mx.controls.Label;
	
	import nl.bs10.brightlib.events.BrightEvent;
	
	public class LinkListRenderer extends Label {
		
		private var _urlChanged:Boolean;
		private var _dataChanged:Boolean;
		private var _data:Object;
		private var _url:String;
		
		public function LinkListRenderer()
		{
			super();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(_dataChanged) {
				_dataChanged = false;
				if(!_data)
					return;
				
				_url = _data.toString();
				if(_url.indexOf('/index.php') == 0) {
					// Internal link
					var pa:Array = _url.split('=');
					owner.parent.dispatchEvent(new BrightEvent(BrightEvent.DATAEVENT, {type:"getPathForTid", callback:_setRealPath, tid:pa[1]}));
				} else if(_url.indexOf('mailto:') == 0) {
					// email
					_url = _url.substr(7);
				}
				_urlChanged = true;
			}
			
			if(_urlChanged) {
				_urlChanged = false;
				text = _url;
			}
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if(value !== _data) {
				_data = value;
				_dataChanged = true;
				invalidateProperties();
			}
		}
		
		private function _setRealPath(value:String):void {
			_url = value;
			_urlChanged = true;
			invalidateProperties();
		}
	}
}