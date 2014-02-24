package com.tessmann.gui 
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.textures.RectangleTexture;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
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
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_viewBitmap = new Bitmap();
			
			width = 480;
			height = 640;
			
			addChild(_viewBitmap);
			
			_data = [];
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
			TweenLite.to(this, 10, { useFrames:true, countedY:countedYTo } );
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
			_rendererBitmapData = new BitmapData(_width, itemHeight, true, 0);
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
			
			var imax:int = position - 1 + visibleCount + 2;
			_viewPixels = Vector.<uint>([]);
			
			_renderer ||= new BitmapItemRenderer();
			for (i = 0; i < imax; i++)
			{
				_rendererBitmapData.setVector(new Rectangle(0, 0, _width, _height), _rendererPixels);
				_renderer.draw(_data[position + i], _rendererBitmapData);
				var pix:Vector.<uint> = _rendererBitmapData.getVector(new Rectangle(0, 0, _width, itemHeight));
				//_viewPixels.splice(0, 0, pix);
				_viewPixels = _viewPixels.concat(pix);
			}
			_viewBitmap.bitmapData.setVector(new Rectangle(0, 0, _width, _height), _viewPixels);
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