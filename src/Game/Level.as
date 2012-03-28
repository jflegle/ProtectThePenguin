package Game
{
	import Game.Engine;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Level
	{
		private var _running:Boolean = false;
		private var _ed:EventDispatcher = new EventDispatcher();
		protected var _engine:Engine;
		protected var _fsm:FiniteStateMachine;
		
		public function Level()
		{
		}
		
		public function Initialize( engine:Engine ):void
		{
			_engine = engine;
			_running = true;
		}
		
		public function IsLoading( ):Boolean
		{
			return _running;
		}
		
		public function DoneLoading( ):void
		{
			_running = false;
		}
		
		public function Update( ):void
		{
			
		}
		
		protected function _DispatchMessage( msg:String ):void
		{
			var e:Event = new Event( msg );
			
			_ed.dispatchEvent( e );
		}
		
		public function DispatchMessage( msg:String ):void
		{
			_fsm.Fire(msg);
		}
		
		public function AddMessageListener( msg:String, fun:Function=null ):void
		{
			_ed.addEventListener( msg, function( event:Event ):void {
				if( fun != null )
					fun();
			});
		}
	}
}