package  Game
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class FishSchool extends Entity
	{
		public var fsm:FiniteStateMachine;
		private var _tweenList:Array = new Array(	
			{x:-400, z:-400, time:2000},
			{time:2000},
			{h:180, time:10},
			{x:300, z:-400, time:2000},
			{time:2000},
			{h:180, time:10});
		
		public function FishSchool(engine:Engine)
		{
			super(engine);
			
			SetModel("FishModel", engine );
			SetPosition(700,15,-400);
			
			AddAnimation("swim1", 0, 349 );
			
			_PlayAnimation("swim1", 10, false );
			
			_obj.setLayer(0);	
			
			fsm = new FiniteStateMachine(
			{
				Init: // state
				{
					onStartUp: function():void // handler
					{
						_PlayAnimation("swim1", 3, false );
					},
					onStart:function():Object
					{
						return fsm.States.Move;						
					}
				},
				Move:
				{
					onStartUp: function():void // handler
					{
						var tween:Object = _tweenList.shift();
						_tweenList.push( tween );
						
						Tween( tween,  tween.time, function( e:Event ):void
						{
							_MoveToComplete( e );
							
						});	
					},
					onMoveToDone:function():Object
					{			
						return fsm.States.Move;
					}
				}
			});
			
			fsm.Start();
			
		}
		
		private function _MoveToComplete( e:Event ):void
		{
			fsm.Fire("onMoveToDone");
			
		}
	}
}