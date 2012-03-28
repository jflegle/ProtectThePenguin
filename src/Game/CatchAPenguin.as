package Game
{
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	
	import flash.display.*;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import spark.components.Application;

	public class CatchAPenguin extends Sprite

	{
		public var level:GameLevel;
		
		private var _engine:Engine;
		private var _gameBoard:Board;
		
		
		public function CatchAPenguin( )
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init( e:Event ):void
		{
			var me:CatchAPenguin = this;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var fsm:FiniteStateMachine = new FiniteStateMachine( {
				Init: // state
				{
					onStartUp: function():Object // handler
					{
						//Create a new engine
						_engine = new Engine();
						_engine.Initialize(me, stage.width/2, stage.height/2);
						
						return fsm.States.Loading;
					}
				},
				Loading:
				{
					onStartUp: function():void // handler
					{
						//Create a new scene pass in the engine
						level = new GameLevel( );
						//_level = new KillerLevel( );
						level.Initialize(_engine);
					}
				}
			});
			
			fsm.Start();
			
			// Initialise Event loop
			this.addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(event:Event):void
		{
			level.Update( );
			// Render the 3D scene
			_engine.Render();
			
		}
	}
}