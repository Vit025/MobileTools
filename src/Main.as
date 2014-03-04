package 
{
	import com.tessmann.gui.BitmapItemRenderer;
	import com.tessmann.gui.BitmapList;
	import flash.desktop.NativeApplication;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author Vitaly Filinov @ TELEFISION TEAM
	 */
	 
	 
	public class Main extends Sprite 
	{
		private var console:TextField;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			
			var list:BitmapList = new BitmapList();
			addChild(list);
			list.setRenderer(new BitmapItemRenderer);
			var data:Array = [];
			var i:int = 10000;
			while (i--)
			{
				data[data.length] = { label:"item " + i };
			}

			list.setData(data);
			list.width = stage.stageWidth;
			list.height = stage.stageHeight;
			
			list.addEventListener("touch_tap_detected", onTouchTap);
			list.addEventListener("swipe_detected", onSwipe);
			list.addEventListener("error_detected", onError);
			
			
			console = new TextField();
			console.background = true;
			console.backgroundColor = 0xFFFFFF;
			console.autoSize = TextFieldAutoSize.NONE;
			console.width = stage.stageWidth;
			console.height = 100;
			console.y = stage.stageHeight - 100;
			//addChild(console);
			
			trace(stage.stageHeight, console.height, console.y);
			
			addEventListener(Event.RESIZE, onResize);
		}
		
		private function onError(e:DataEvent):void 
		{
			console.text = "touch detected" + e.data + "\n" + console.text;
		}
		
		private function onResize(e:Event):void 
		{
			trace("RESIZE");
		}
		
		private function onTouchTap(e:DataEvent):void 
		{
			console.text = "touch detected:" + e.data + "\n" + console.text;
		}
		
		private function onSwipe(e:DataEvent):void 
		{
			console.text = "swipe detected" + e.data + "\n"  + console.text;
		}
		
		private function deactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}