package Game
{
	import Game.Engine;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class TextLabel extends TextField
	{
		private var _backGround:Bitmap;
		private var textX:Number;
		private var textY:Number;		
		
		public function TextLabel( engine:Engine, x:Number, y:Number, textX:Number, textY:Number, img:String, font:String="Arial", color:uint=0x000000, size:uint=18, just:String=TextFieldAutoSize.LEFT  )
		{
			var me:TextLabel = this;
			
			var format:TextFormat = new TextFormat();
			format.font = font;
			format.color = color;
			format.size = size;
			
			autoSize = just;//TextFieldAutoSize.CENTER;
			this.x = x+textX;
			this.y = y+textY;
			this.textX = textX;
			this.textY = textY;
			this.type = TextFieldType.DYNAMIC;
			this.wordWrap = false;
			z = 0;
			text = "text label";
			selectable = false;
			defaultTextFormat = format; 
			
			// load background image
			var ldr:Loader = new Loader();	
			ldr.load(new URLRequest(img) );			
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function( e:Event ):void 
			{
				var bmp:Bitmap = ldr.content as Bitmap;
				_backGround = new Bitmap( bmp.bitmapData );
				_backGround.x = x;
				_backGround.y = y;
				_backGround.z = 0;
				engine.GetStage().addChild( me._backGround);
				engine.GetStage().addChild( me );	
				setTextFormat( format );
			});
		}
		
		public function SetPosition( x:Number, y:Number ):void
		{
			this.x = x+textX;
			this.y = y+textY;
			_backGround.x = x;
			_backGround.y = y;
		}
		
		public function Hide():void
		{
			visible = false;
			_backGround.visible = false;
		}
		
		public function Show():void
		{
			visible = true;
			_backGround.visible = true;
		}
	}
}