package korax.controls.ColorPicker
{
	import mx.core.UIComponent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class ColorPickerCanvas extends UIComponent
	{
		public var bd:BitmapData = null;
		public var bm:Bitmap = null;

		public function ColorPickerCanvas()
		{
			super();
		}

   		override protected function createChildren():void {
			bd = new BitmapData(width, height, false, 0x000000);
			bm = new Bitmap(bd);
   			addChild(bm);
   		}		
		
	}
}