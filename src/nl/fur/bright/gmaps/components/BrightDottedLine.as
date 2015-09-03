package nl.fur.bright.gmaps.components
{
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	
	public class BrightDottedLine extends Sprite
	{
		private static const _LINE_COLOR:Number = 0x999999;
		private static const _LINE_THICKNESS:Number = 2;
		
		private var _target:BrightPoint;
		private var _timer:Timer;
		private var _line:Shape;
		
		public function BrightDottedLine(color:Number)
		{
			super();
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		
		internal function set target(value:BrightPoint):void
		{
			_target = value;
			_timer.start();
		}
		
		
		internal function redraw():void
		{
			x = _target.x;
			y = _target.y;
			
			var startPoint:Point = new Point();
			var endPoint:Point = new Point(mouseX, mouseY);
			
			graphics.clear();
			graphics.lineStyle(_LINE_THICKNESS, _LINE_COLOR, 0.5, true);
			graphics.moveTo(0, 0);
			graphics.lineTo(endPoint.x, endPoint.y);
		}
		
		
		internal function dispose():void
		{
			if (parent)
			{
				parent.removeChild(this);
			}
			
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
		}
		
		
		private function onTimer(event:TimerEvent):void
		{
			if (_target)
			{
				redraw(); 
			}
		}
	}
}