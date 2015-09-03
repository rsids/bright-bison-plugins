package nl.bs10.gmaps.components
{
	import com.google.maps.LatLng;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.PaneId;
	import com.google.maps.interfaces.IMap;
	import com.google.maps.interfaces.IPane;
	import com.google.maps.overlays.OverlayBase;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import nl.bs10.brightlib.objects.PolyPage;
	import nl.bs10.gmaps.events.BrightPointEvent;
	import nl.bs10.gmaps.events.BrightPolyLineEvent;


	public class BrightPolyLine extends OverlayBase
	{
		private static const THICKNESS:Number = 2;
		
		private var _polyPage:PolyPage;
		
		private var _lastPoint:BrightPoint;
		private var _fill:BrightFill;
		private var _dottedLine:BrightDottedLine;
		private var _isClosed:Boolean = false;
		private var _isEnded:Boolean = false;
		private var _drawingMode:String;
		
		public function BrightPolyLine(polyPage:PolyPage)
		{
			super();
			
			_polyPage = polyPage;
			
			_fill = new BrightFill(polyPage.color);
			addChild(_fill);
			
			_dottedLine = new BrightDottedLine(polyPage.color);
			addChild(_dottedLine);
			
			// Start listening for mapEvents
			addEventListener(MapEvent.OVERLAY_ADDED, handleOverlayAdded, false, 0, true);
    		addEventListener(MapEvent.OVERLAY_REMOVED, handleOverlayRemoved, false, 0, true);
		}
		
		
		public function set color(value:Number):void
		{
			_polyPage.color = value;
			redraw();
			
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_CHANGED, _polyPage));
		}
		
		
		public function get polyPage():PolyPage
		{
			return _polyPage;
		}
		
		
		override public function getDefaultPane(map:IMap):IPane
		{
    		return map.getPaneManager().getPaneById(PaneId.PANE_OVERLAYS);
		}
		
		
		override public function positionOverlay(zoom:Boolean):void
		{
    		redraw();
		}
		
		
		public function endPolyLine(isClosed:Boolean):void
		{
			_isEnded = true;
			pane.map.removeEventListener(MapMouseEvent.CLICK, onMapClick);
			
			if (isClosed || _polyPage.isShape)
			{
				_isClosed = true;
				if (firstPoint)
				{
					addPoint(firstPoint.latLng);
				}
			}
			
			_dottedLine.dispose();
			redraw();
			
			_polyPage.points = latLngCoordinates;
			
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_ENDED, _polyPage));
		}
		
		
		public function numPoints():int
		{
			if (_lastPoint)
			{
				return _lastPoint.numPoints();
			}
			return 0;
		}
		
		
		public function dispose():void
		{
			pane.map.removeOverlay(this);
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_DELETED, _polyPage));
		}
		
		
		internal function populate():void
		{
			for each (var latLngObject:Object in _polyPage.points)
			{
				var latLng:LatLng = new LatLng(latLngObject.lat, latLngObject.lng);
				addPoint(latLng);
			}
			endPolyLine(_polyPage.isShape);
			
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_POPULATE_COMPLETED, _polyPage));
		}
		
		
		internal function get latLngCoordinates():Array
		{
			if (!_lastPoint)
			{
				return new Array();
			}
			var latLngArray:Array = _lastPoint.getLatLngCoordinates();
			if (_isClosed)
				latLngArray.shift();
			return latLngArray;
		}
		
		
		internal function get isClosed():Boolean
		{
			return _isClosed;
		}
		
		
		internal function get isEnded():Boolean
		{
			return _isClosed;
		}
		
		
		internal function addPoint(latLng:LatLng):BrightPoint
		{
			var newPoint:BrightPoint = new BrightPoint(latLng, this);
			newPoint.addEventListener(BrightPointEvent.POINT_MOVED, onPointMoved);
			newPoint.addEventListener(BrightPointEvent.POINT_MOVE_ENDED, onPointMoveEnded);
			newPoint.addEventListener(BrightPointEvent.POINT_REMOVED, onPointRemoved);
			newPoint.addEventListener(BrightPointEvent.POINT_INSERTED, onPointInserted);
			newPoint.addEventListener(BrightPointEvent.POINT_MOUSE_OVER, onPointMouseOver);
			newPoint.addEventListener(BrightPointEvent.POINT_MOUSE_OUT, onPointMouseOut);
			newPoint.addEventListener(BrightPointEvent.END_POLYLINE, onEndPolyLine);
			
			addChildAt(newPoint, 2);
			
			// This is the first point that's added to the polyLine
			if (_lastPoint == null)
			{
				_lastPoint = newPoint;
				
				newPoint.addEventListener(BrightPointEvent.CLOSE_POLYLINE, onClosePolyLine);
			}
			else
			{
				_lastPoint.next = newPoint;
				newPoint.previous = _lastPoint;
				_lastPoint = newPoint;
			}
			
			_dottedLine.target = _lastPoint;
			
			redraw();
			
			return newPoint;
		}
		
		
		internal function addPointBefore(latLng:LatLng, beforePoint:BrightPoint):BrightPoint
		{
			var newPoint:BrightPoint = new BrightPoint(latLng, this, true);
			
			newPoint.addEventListener(BrightPointEvent.POINT_MOVED, onPointMoved);
			newPoint.addEventListener(BrightPointEvent.POINT_MOVE_ENDED, onPointMoveEnded);
			newPoint.addEventListener(BrightPointEvent.POINT_REMOVED, onPointRemoved);
			newPoint.addEventListener(BrightPointEvent.POINT_INSERTED, onPointInserted);
			newPoint.addEventListener(BrightPointEvent.POINT_MOUSE_OVER, onPointMouseOver);
			newPoint.addEventListener(BrightPointEvent.POINT_MOUSE_OUT, onPointMouseOut);
			newPoint.addEventListener(BrightPointEvent.END_POLYLINE, onEndPolyLine);
			
			addChildAt(newPoint, getChildIndex(beforePoint.previous));
			
			newPoint.previous = beforePoint.previous.next = newPoint;
			newPoint.previous = beforePoint.previous;
			
			beforePoint.previous = newPoint;
			newPoint.next = beforePoint;
			
			redraw();
			
			return newPoint;
		}
		
		
		internal function redraw():void
		{
			if (_lastPoint)
			{
				_lastPoint.redraw(_isEnded, _isClosed, THICKNESS, _polyPage.color);
				
				if (_polyPage.isShape)
				{
					_fill.redraw(_lastPoint.getViewportCoordinates(), _polyPage.color);
				}
			}
		}
		
		
		private function get firstPoint():BrightPoint
		{
			if (!_lastPoint)
			{
				return null;
			}
			return _lastPoint.getFirstPoint();
		}
		/**
		 * 
		 * @param event
		 * 
		 */		
		
		private function onPointMoved(event:BrightPointEvent):void
		{
			// Get the moved point
			var theMovedPoint:BrightPoint = event.target as BrightPoint;
			
			theMovedPoint.latLng = pane.map.fromViewportToLatLng(new Point(theMovedPoint.x, theMovedPoint.y));
			
			// If this poly is closed and the first point was moved
			if (_isClosed && theMovedPoint == firstPoint)
			{
				// then move the last point to the same position as the first point
				// so the poly stays closed
				_lastPoint.latLng = theMovedPoint.latLng;
			}
			
			redraw();
		}
		
		
		private function onPointRemoved(event:BrightPointEvent):void
		{
			if (numPoints() <= 3)
			{
				
				dispose();
				return;
			}
			
			var point:BrightPoint = event.target as BrightPoint;
			
			// Check if it's the first one
			if (!point.previous && point.next)
			{
				point.next.previous = null;
				
				// If it's closed
				if (_isClosed)
				{
					// Move the last one to the position of the fist one
					_lastPoint.latLng = _lastPoint.getFirstPoint().latLng;
				}
			}
			// Check if it's the last one
			else if (!point.next && point.previous)
			{
				point.previous.next = null;
				_lastPoint = point.previous;
			}
			else if (point.previous && point.next)
			{
				point.previous.next = point.next;
				point.next.previous = point.previous;
			}
			
			point.previous = null;
			point.next = null;
			
			point.removeEventListener(BrightPointEvent.POINT_MOVED, onPointMoved);
			point.removeEventListener(BrightPointEvent.POINT_MOVE_ENDED, onPointMoveEnded);
			point.removeEventListener(BrightPointEvent.POINT_REMOVED, onPointRemoved);
			point.removeEventListener(BrightPointEvent.POINT_INSERTED, onPointInserted);
			point.removeEventListener(BrightPointEvent.POINT_MOUSE_OVER, onPointMouseOver);
			point.removeEventListener(BrightPointEvent.POINT_MOUSE_OUT, onPointMouseOut);
			point.removeEventListener(BrightPointEvent.END_POLYLINE, onEndPolyLine);
			point.removeEventListener(BrightPointEvent.CLOSE_POLYLINE, onClosePolyLine);
			removeChild(point);
			
			redraw();
			
			_polyPage.points = latLngCoordinates;
			
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_CHANGED, _polyPage));
		}
		
		
		private function onPointMoveEnded(event:BrightPointEvent):void
		{
			_polyPage.points = latLngCoordinates;
			
			trace("point move ended");
			
			dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_CHANGED, _polyPage));
		}
		
		
		private function onPointInserted(event:BrightPointEvent):void
		{
			var latLng:LatLng = pane.map.fromViewportToLatLng(new Point(mouseX, mouseY));
			
			addPointBefore(latLng, event.target as BrightPoint);
		}
		
		
		private function onPointMouseOver(event:BrightPointEvent):void
		{
			if (_isEnded)
			{
				dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OVER, _polyPage, event.target as BrightPoint));
			}
		}
		
		
		private function onPointMouseOut(event:BrightPointEvent):void
		{
			if (_isEnded)
			{
				dispatchEvent(new BrightPolyLineEvent(BrightPolyLineEvent.POLYLINE_POINT_MOUSE_OUT, _polyPage, event.target as BrightPoint));
			}
		}
		
		
		private function onClosePolyLine(event:BrightPointEvent):void
		{
			endPolyLine(true);
		}
		
		
		private function onEndPolyLine(event:BrightPointEvent):void
		{
			endPolyLine(false);
		}
		
		
		private function handleOverlayAdded(event:Event):void
		{
    		if (_polyPage.points.length > 0)
    		{
    			populate();
    		}
    		else
    		{
    			pane.map.addEventListener(MapMouseEvent.CLICK, onMapClick);
    		}
    	}
  		
		
		private function handleOverlayRemoved(event:Event):void
		{
    		//pane.map.removeEventListener(MapMouseEvent.CLICK, onMapClick);
		}
		
		
		private function onMapClick(event:MapMouseEvent):void
		{
			event.stopPropagation();
			addPoint(event.latLng);
		}
		
	}
}