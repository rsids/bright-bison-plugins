package nl.fur.bright.fileexplorer.utils
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import nl.flexperiments.display.Transformations;

	public class ImageUtils
	{
		
		public static function resize(fr:FileReference, type:String, maxW:int, maxH:int, cb:Function):void {
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				var bm:Bitmap = Bitmap(e.target.content);
				var bmd:BitmapData;
				bm.smoothing = true;
				if(bm.width < maxW && bm.height < maxH) {
					// Do not resize
					cb(fr.data);
					ldr.unloadAndStop();
					
				} else {
					var m:Matrix = Transformations.getScaleMatrix(bm, maxW,maxH, false);
					bmd = new BitmapData(bm.width * m.a,bm.height * m.d, true, 0x000000);
					bmd.draw(bm, m, null, null, null, true);
										
					var ba:ByteArray;
					if(type == 'jpg' || type=='jpeg') {
						var jenc:JPGEncoder = new JPGEncoder(90);
						ba = jenc.encode(bmd);
					} else if(type=='png') {
						ba = PNGEncoder.encode(bmd);
					}
					ldr.unloadAndStop();
					cb(ba);
				}
			});
			
			fr.addEventListener(Event.COMPLETE, function(e:Event):void {
				ldr.loadBytes(fr.data);
			});
			fr.load();
		}
	}
}