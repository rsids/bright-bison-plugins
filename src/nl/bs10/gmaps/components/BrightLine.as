package nl.bs10.gmaps.components
{
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import nl.bs10.gmaps.events.BrightPointEvent;
	
	
	public class BrightLine extends Sprite
	{
		
		private var _line:Sprite;
		private var _hitarea:Sprite;
		public var square:Sprite;
		
		public function BrightLine()
		{
			super();
			
			_line = new Sprite();
			_line.addEventListener(MouseEvent.CLICK, onLineClick);
			addChild(_line);
			
			_hitarea = new Sprite();
			_hitarea.alpha = 0;
			_hitarea.addEventListener(MouseEvent.CLICK, onLineClick);
			addChild(_hitarea);
			
			square = new Sprite();
			square.buttonMode = true;
			square.alpha = 0;
			addChild(square);
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		
		internal function redraw(startPosition:Point, endPosition:Point, thickness:Number, color:Number):void
		{
			x = startPosition.x;
			y = startPosition.y;
			
			var deltaX:Number = endPosition.x - x;
			var deltaY:Number = endPosition.y - y;
			
			// Draw the visible line
			_line.graphics.clear();
			_line.graphics.lineStyle(thickness, color, 0.8, true);
			_line.graphics.moveTo(0, 0);
			_line.graphics.lineTo(endPosition.x - x, endPosition.y - y);
			
			// Draw the hitarea
			_hitarea.graphics.clear();
			_hitarea.graphics.lineStyle(16, color, 0.4, true);
			_hitarea.graphics.moveTo(0, 0);
			_hitarea.graphics.lineTo(deltaX, deltaY);
			
			// Draw the square in the middle
			square.graphics.clear();
			square.x = deltaX / 2;
			square.y = deltaY / 2;
			square.graphics.moveTo(0, 0);
			square.graphics.lineStyle(1, 0x000000, 1, true);
			square.graphics.beginFill(0x5555ff, 1);
			square.graphics.drawRect(- 4, - 4, 8, 8);
			square.graphics.endFill();
		}
		
		
		private function onMouseOver(event:MouseEvent):void
		{
			square.alpha = 1;
			_hitarea.alpha = 1;
		}
		
		
		private function onMouseOut(event:MouseEvent):void
		{
			square.alpha = 0;
			_hitarea.alpha = 0;
		}
		
		
		private function onLineClick(event:MouseEvent):void
		{
			dispatchEvent(new BrightPointEvent(BrightPointEvent.SHAPE_CLICK, true));
		}
	}
}