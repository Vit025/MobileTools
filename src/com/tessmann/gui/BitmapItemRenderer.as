package com.tessmann.gui 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Vitaly Filinov @ TELEFISION TEAM
	 */
	public class BitmapItemRenderer implements IBitmapListRenderer
	{
		private var container:Sprite;
		private var textField:TextField;
		private var a:Number;
		
		public function BitmapItemRenderer() 
		{
			
		}
		
		public function draw(data:Object, bitmapData:BitmapData):void
		{
			//var t1:int = getTimer();
			if (!textField)
			{
				createElements();
			}
			
			textField.width = bitmapData.width - 20;
			textField.x = 10;
			
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = data.label;
			
			a = textField.textHeight + 4;
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.height = (a > 0)? (a + .5) >> 0 : 0;
			
			a = (bitmapData.height - textField.height) >> 1;
			textField.y = (a > 0)? (a + .5) >> 0 : (a - .5) >> 0;
			
			bitmapData.draw(container, null, null, null, null, true);
			//var t2:int = getTimer();
			//trace("----", t2 - t1);
		}
		
		private function createElements():void 
		{
			textField = new TextField();
			
			var format:TextFormat = new TextFormat("SegoeUI", 24, 0xFFFFFF);
			textField.defaultTextFormat = format;
			
			container = new Sprite();
			container.addChild(textField);
		}
		
	}

}