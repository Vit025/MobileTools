package com.tessmann.gui 
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.textures.RectangleTexture;
	import flash.errors.IllegalOperationError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.GestureEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Vitaly Filinov @ TELEFISION TEAM
	 */
	public class BitmapList extends Sprite 
	{
		private var _renderer:IBitmapListRenderer;
		private var _data:Object;
		private var _viewBitmap:Bitmap;
		private var _viewPixels:Vector.<uint>;
		private var _rendererPixels:Vector.<uint>;
		private var _rendererBitmapData:BitmapData;
		
		private var _width:int = 0;
		private var _height:int = 0;
		
		private var position:int = 0;
		private var i:int;
		private var visibleCount:int = 0;
		
		private var itemHeight:int = 80; //TODO get device default icon size
		
		private var _countedY:int = 0;
		private var countedYTo:int = 0;
		private var startY:int = 0;
		
		public function BitmapList() 
		{
			_countedY = -itemHeight;
			
			if (Multitouch.supportsTouchEvents)
			{
				Multitouch.inputMode = MultitouchInputMode.GESTURE;
				addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
				addEventListener(TransformGestureEvent.GESTURE_PAN, onPan);
			}
			else
			{
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			
			_viewBitmap = new Bitmap();
			
			width = 480;
			height = 640;
			
			addChild(_viewBitmap);
			
			_data = [];
		}
		
		private function onPan(e:TransformGestureEvent):void 
		{
			
		}
		
		private function onTouchTap(e:TouchEvent):void 
		{
			dispatchEvent(new DataEvent("touch_tap_detected"));
		}
		
		private function onSwipe(e:TransformGestureEvent):void 
		{
			try {
				dispatchEvent(new DataEvent("swipe_detected", false, false, e.offsetX + "  " + e.offsetY + " " + e.phase));
				if (e.offsetY == 1)
				{
					countedYTo = countedY + (stage.stageHeight << 1);
				}
				else if (e.offsetY == -1)
				{
					countedYTo = countedY - (stage.stageHeight << 1);
				}
				
				TweenLite.killTweensOf(this);
				TweenLite.to(this, 60, { useFrames:true, countedY:countedYTo } );
			} catch (err:Error)
			{
				dispatchEvent(new DataEvent("error_detected", false, false, err.message));
			}

		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			startY = e.localY; // TODO detect move or click
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			countedYTo = countedY + e.localY - startY;
			if (countedYTo + _data.length * itemHeight < _height + itemHeight)
			{
				countedYTo = _height + itemHeight - _data.length * itemHeight;
			}
			
			if (countedYTo > -itemHeight)
			{
				countedYTo = -itemHeight;
			}
			
			TweenLite.killTweensOf(this);
			TweenLite.to(this, 20, { useFrames:true, countedY:countedYTo } );
		}
		
		public function set countedY(value:Number):void
		{
			_countedY = value;
			var c:Number = ( -itemHeight - countedY) / itemHeight;
			c = (c > 0)? (c + .5) >> 0 : (c - .5) >> 0;
			
			//trace("VF >>", this,":: countedY:", c, countedY);
			position = c + 1;
			
			c = _countedY + itemHeight * c;
			_viewBitmap.y = c;
			
			redraw();
		}
		
		public function get countedY():Number
		{
			return _countedY;
		}
		
		public function setRenderer(renderer:IBitmapListRenderer):void
		{
			_renderer = renderer;
		}
		
		public function setData(data:Object):void
		{
			if (!("length" in data))
			{
				throw new IllegalOperationError("Data has to be Array, Vector or IList!");
				return;
			}
			
			_data = data;
			redraw();
		}
		
		private function updateSize():void
		{
			_viewBitmap.bitmapData = new BitmapData(_width, _height + (itemHeight << 1), false, 0x222120);
			_viewBitmap.smoothing = true;
			_viewBitmap.bitmapData.lock();
			_rendererBitmapData = new BitmapData(_width, itemHeight, true, 0);
			_rendererBitmapData.lock();
			_rendererPixels = _rendererBitmapData.getVector(new Rectangle(0, 0, _width, itemHeight));
			
			visibleCount = _height / itemHeight + 2;
			visibleCount = ((visibleCount << 0) == visibleCount)? visibleCount:(visibleCount > 0)? (visibleCount + 1) >> 0 : visibleCount >> 0;
			
			redraw();
		}
		
		private function redraw():void
		{
			
			if (!_data) {
				return;
			}
			
			//var t1:int = getTimer();
			
			var imax:int = position - 1 + visibleCount + 2;
			_viewPixels = Vector.<uint>([]);
			
			var r0:Rectangle = new Rectangle(0, 0, _width, itemHeight - 1);
			var r1:Rectangle = new Rectangle(0, 0, _width, itemHeight);
			var r2:Rectangle = new Rectangle(0, 0, _width, itemHeight);
			var _y:int = 0;
				
			for (i = position; i < imax; i++)
			{
				_rendererBitmapData.fillRect(r0, 0xFFCCCCCC);
				_renderer.draw(_data[position + i], _rendererBitmapData);
				r2.y = _y;
				_viewBitmap.bitmapData.setVector(r2, _rendererBitmapData.getVector(r1));
				_y += itemHeight;
			}
				//var t2:int = getTimer();
				//trace(t2 - t1);
		}
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = (value > 0)? (value + .5) >> 0 : 0;
			updateSize();
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = (value > 0)? (value + .5) >> 0 : 0;
			updateSize();
		}
		
	}

}