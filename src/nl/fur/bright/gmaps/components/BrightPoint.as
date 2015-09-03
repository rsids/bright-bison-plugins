package nl.fur.bright.gmaps.components
{
	import com.google.maps.LatLng;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import nl.fur.bright.maps.events.BrightPointEvent;
	import nl.fur.bright.maps.interfaces.IBrightPoint;
	import nl.fur.bright.maps.interfaces.IBrightPolyLine;

	public class BrightPoint extends Sprite implements IBrightPoint	{
		private static const _LINE_COLOR:Number = 0x333333;
		private static const _FILL_COLOR:Number = 0x0000ff;
		private static const _FILL_OVER_COLOR:Number = 0x5555ff;
		
		
		private var _previous:BrightPoint;
		private var _next:BrightPoint;
		
		private var _latLng:LatLng;
		private var _polyLine:IBrightPolyLine;
		
		private var _point:Sprite;
		private var _square:Sprite;
		private var _circle:Sprite;
		private var _line:BrightLine;
		
		private var _dragTimer:Timer;
		private var _dragMouseOffset:Point;
		private var _dragOffset:Point;
		private var _isEnded:Boolean = false;
		private var _isClosed:Boolean = false;
		private var _thickness:Number;
		private var _color:Number;
		
		
		public function BrightPoint($latLng:LatLng, $polyLine:IBrightPolyLine, $startDragging:Boolean = false)
		{
			super();
			_latLng = $latLng;
			_polyLine = $polyLine;
			
			// Create a line, every Point has a line to the next point
			_line = new BrightLine();
			addChild(_line);
			
			// Create the point that holds the square and the circle
			_point = new Sprite();
			addChild(_point);
			
			// Create the circle
			_circle = new Sprite();
			// and add the circle
			_point.addChild(_circle);
			_circle.alpha = 0;
			
			// Create the square
			_square = new Sprite();
			_square.x = -4;
			_square.y = -4;
			// draw the square
			_square.graphics.moveTo(0, 0);
			_square.graphics.lineStyle(1, 0x000000, 1, true);
			_square.graphics.beginFill(_FILL_COLOR, 1);
			_square.graphics.drawRect(0, 0, 8, 8);
			_square.graphics.endFill();
			// and add the square
			_point.addChild(_square);
			
			_square.buttonMode = true;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			_dragTimer = new Timer(20);
			if ($startDragging)
			{
				redraw(false, false, 1, 0x000000);
				_dragMouseOffset = new Point(0, 0);
				_dragTimer.start();
			}
		}
		
		
		public function get square():Sprite
		{
			return _square;
		}
		
		
		public function redraw(isEnded:Boolean, isClosed:Boolean, thickness:Number, color:Number):void
		{
			_isEnded = isEnded;
			_isClosed = isClosed;
			_thickness = thickness;
			_color = color;
			
			// Get the position on the viewPort according to the latLng coordinates
			var position:Point = _polyLine.getPosition(_latLng.lat(),_latLng.lng());
			
			// Set the position
			x = Math.round(position.x);
			y = Math.round(position.y);
			
			redrawCircle();
			
			if (!previous)
			{
				_line.redraw(new Point(0, 0), new Point(0, 0), thickness, color);
			}
			else
			{
				previous.redraw(isEnded, isClosed, thickness, color);
				_line.redraw(new Point(0, 0), new Point(previous.x - x, previous.y - y), thickness, color);
			}
		}
		
		
		public function dispose():void
		{
			// TODO: Clear graphics and other stuff here
			dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_REMOVED));
		}
		
		
		internal function numPoints():int
		{
			if (_previous != null)
			{
				return _previous.numPoints() + 1;
			}
            return 0;
		}
		
		
		internal function getLatLngCoordinates(value:Array = null):Array
		{
			if (!value)
			{
				value = new Array();
			}
			
			if (_previous)
			{
				_previous.getLatLngCoordinates(value);
			}
			
			var point:Object = new Object();
			point.lat = _latLng.lat();
			point.lng = _latLng.lng();
			
			value.push(point);
			
			return value;
		}
		
		
		internal function getViewportCoordinates(value:Array = null):Array
		{
			if (!value)
			{
				value = new Array();
			}
			
			if (_previous)
			{
				_previous.getViewportCoordinates(value);
			}
			value.push(new Point(x, y));
			
			return value;
		}
		
		
		internal function set position(newPosition:Point):void
		{
			x = newPosition.x;
			y = newPosition.y;
		}
		
		
		internal function get latLng():LatLng
		{
			return _latLng;
		}
		
		internal function set latLng(value:LatLng):void
		{
			_latLng = value;
		}
		
		
		internal function get previous():BrightPoint
		{
			return _previous;
		}
		
		internal function set previous(value:BrightPoint):void
		{
			_previous = value;
		}
		
		
		internal function get next():BrightPoint
		{
			return _next;
		}
		
		internal function set next(value:BrightPoint):void
		{
			_next = value;
		}
		
		
		internal function getFirstPoint():BrightPoint
		{
			if (_previous)
			{
				return _previous.getFirstPoint();
			}
			return this;
		}
		
		
		internal function getLastPoint():BrightPoint
		{
			if (_next)
			{
				return _next.getLastPoint();
			}
			return this;
		}
		
		
		private function redrawCircle():void
		{
			_circle.graphics.clear();
			
			// If we're dragging, the radius must be bigger
			var radius:int = (_dragTimer.running) ? 30 : 10;
			
			// Draw the circle
			_circle.graphics.moveTo(0, 0);
			_circle.graphics.beginFill(0x333333, 0.5);
			_circle.graphics.drawCircle(0, 0, radius);
			_circle.graphics.endFill();
			
		}
		
		
		private function onAddedToStage(event:Event):void
		{
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
						
			_line.square.addEventListener(MouseEvent.MOUSE_DOWN, onLineSquareMouseDown);
			
			_point.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_point.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			_square.addEventListener(MouseEvent.CLICK, onClick);
			_square.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_square.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_dragTimer.addEventListener(TimerEvent.TIMER, onDragTimer);
		}
		
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_line.square.removeEventListener(MouseEvent.MOUSE_DOWN, onLineSquareMouseDown);
			
			_point.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_point.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			_square.removeEventListener(MouseEvent.CLICK, onClick);
			_square.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_square.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_dragTimer.removeEventListener(TimerEvent.TIMER, onDragTimer);
		}
		
		
		private function onClick(event:MouseEvent):void
		{
			//  If we're not dragging and it's not ended yet, so we're still drawing
			if ((!_dragOffset || _dragOffset.equals(new Point(x, y))) && !_isEnded)
			{
				// Check if this is the first one
				if (!_previous)
				{
					// If so, then tell the poly to close
					dispatchEvent(new BrightPointEvent(BrightPointEvent.CLOSE_POLYLINE));
				}
				// Else check if it's the last one
				else if (!_next)
				{
					// If so, then tell the poly to end
					dispatchEvent(new BrightPointEvent(BrightPointEvent.END_POLYLINE));
				}
			}
			/*
			else
			{
				dispose();
			}
			*/
		}
		
		
		private function onMouseOver(event:MouseEvent):void
		{
			if (!_dragTimer.running)
			{
				dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_MOUSE_OVER));
			}
		}
		
		
		private function onMouseOut(event:MouseEvent):void
		{
			dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_MOUSE_OUT));
		}
		
		
		private function onMouseDown(event:MouseEvent):void
		{
			event.stopPropagation();
			
			dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_MOUSE_OUT));
			
			_dragMouseOffset = new Point(mouseX, mouseY);
			_dragOffset = new Point(x, y);
			_dragTimer.start();
		}
		
		
		private function onMouseUp(event:MouseEvent):void
		{
			event.stopPropagation();
			
			if (_dragTimer.running)
			{
				_dragTimer.stop();
				
				redrawCircle();
				
				dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_MOVE_ENDED));
			}
		}
		
		
		private function onMouseLeave(event:Event):void
		{
			event.stopPropagation();
			
			_dragTimer.stop();
		}
		
		
		private function onDragTimer(event:TimerEvent):void
		{
			x = parent.mouseX - _dragMouseOffset.x;
			y = parent.mouseY - _dragMouseOffset.y;
			
			dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_MOVED));
		}
		
		
		private function onLineSquareMouseDown(event:MouseEvent):void
		{
			event.stopPropagation();
			
			dispatchEvent(new BrightPointEvent(BrightPointEvent.POINT_INSERTED));
		}
	}
}