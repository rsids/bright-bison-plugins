package nl.fur.bright.gmaps.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import nl.bs10.gmaps.events.BrightPointEvent;
	
	
	public class BrightFill extends Sprite
	{
		
		public function BrightFill(color:Number)
		{
			super();
			
			addEventListener(MouseEvent.CLICK, onFillClick);
		}
		
		
		internal function redraw(viewportCoordinates:Array, color:Number):void
		{
			graphics.clear();
			
			graphics.beginFill(color, 0.8);
			
			if (viewportCoordinates.length)
			{
				var firstPoint:Point = viewportCoordinates[0] as Point;
				graphics.moveTo(firstPoint.x, firstPoint.y);
			}
			
			
			for each (var currentPoint:Point in viewportCoordinates)
			{
				graphics.lineTo(currentPoint.x, currentPoint.y);
			}
			
			graphics.endFill();
		}
		
		private function onFillClick(event:MouseEvent):void
		{
			dispatchEvent(new BrightPointEvent(BrightPointEvent.SHAPE_CLICK, true));
		}
	}
}