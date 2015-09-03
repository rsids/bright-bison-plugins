package nl.fur.bright.fileexplorer.views
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.core.IToolTip;
	
	import nl.fur.bright.fileexplorer.model.Model;
	import nl.bs10.brightlib.objects.File;

	public class ImageToolTip extends Canvas implements IToolTip {
		
		private var _icon:Image = new Image();
		private var _label:Text = new Text();
		
		private var _file:File;
		private var _iconLoaded:Boolean = false;
		
		public function ImageToolTip() {
			super();
			width = 300;
			height = 300;
			horizontalScrollPolicy = 
			verticalScrollPolicy = "off";
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			_icon.width = 290;
			_icon.height = 265;
			_icon.setStyle("horizontalCenter", 0);
			_icon.addEventListener(Event.COMPLETE, _sizeImage);
			_icon.scaleContent = false;
			_label.height = 55;
			_label.width = 290;
            _label.styleName = this;
            
			
			_label.x = 5;
			_label.y = 275;
			_label.setStyle("textAlign", "left");
			
			_icon.y = 6;
			_icon.x = 5;
			
			addChild(_icon);
			addChild(_label);
			visible = false;
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			
			if(!value) 
				return;
			_iconLoaded = false;
			alpha = 0;
			visible = false;
			graphics.clear();
			
			_file = new File();
			_file.filename = value.filename;
			_file.extension = value.extension;
			_file.filesize = value.filesize;
			_file.path = value.path;
			_label.htmlText = "Filename: <b>" + _file.filename + "</b><br/>" + 
					"Filesize: <b>" + Model.instance.filesVO.formatFileSize(value.filesize) + "</b>";
			_icon.source = Model.instance.filesVO.settings.fileurl + _file.path + _file.filename;
		}
		
		public function set text(value:String):void {
			if(_file) {
				_label.htmlText = "Filename: <b>" + _file.filename + "</b><br/>" + 
					"Filesize: <b>" + Model.instance.filesVO.formatFileSize(_file.filesize) + "</b>";
				if(_iconLoaded) 
					_label.htmlText += "<br/>Image dimensions: <b>" + _icon.content.width + "px x " + _icon.content.height +"px</b>";
			} else {
				_label.text = value;
			}
		}
		
		public function get text():String { 
			return _label.text;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if(stage) {
				if(y + height > stage.stageHeight) {
					y -= (y + height) - stage.stageHeight;
				}
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}

		private function _sizeImage(event:Event):void {
			//max width: 290;
			//max height: 265;
			_iconLoaded = true;
			_label.htmlText = "Filename: <b>" + _file.filename + "</b><br/>" + 
					"Filesize: <b>" + Model.instance.filesVO.formatFileSize(_file.filesize) + "</b>" + 
					"<br/>Image dimensions: <b>" + _icon.content.width + "px x " + _icon.content.height +"px</b>"; 
			
			if(_icon.content.width < _icon.width) {
				_icon.width = _icon.content.width;
 				_label.width = _label.measureHTMLText(_label.htmlText).width / 2; 
				
				width = Math.max(_label.width, _icon.width);
				_icon.x = (.5 * width) - (.5 * _icon.width); 
			} else {
				//Scale width
				var destWidth:Number = 290;
				var destHeight:Number = _icon.content.height * (destWidth / _icon.content.width);
				var scaled:BitmapData = new BitmapData(destWidth, destHeight, true);
				var matrix:Matrix = new Matrix(destWidth / _icon.content.width, 0, 0, destWidth / _icon.content.width);
				scaled.draw(_icon.content, matrix);
				var bitmap:Bitmap = new Bitmap(scaled);
				_icon.source = bitmap;
				_icon.height = bitmap.height;
				_label.y = bitmap.height + 15;
				height = _label.y + 60;
			}
			
			if(_icon.content.height < _icon.height) {
				_icon.height = _icon.content.height;
				_label.y = _icon.height + 15;
				height = _label.y + 60;
			}
			alpha = 1;
			visible = true;
			graphics.clear();
			graphics.beginFill(0xffffff, .95);
			graphics.lineStyle(1, 0x057ddf);
			graphics.drawRoundRect(0,0, width, height, 5,5);
			graphics.endFill();
			filters = [new DropShadowFilter(4,90,0x000000, .3,4,4,1,1)];
		}
	}
}