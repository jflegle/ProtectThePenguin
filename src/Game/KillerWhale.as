package  Game
{ 
	import flare.core.Lines3D;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	
	public class KillerWhale extends Entity
	{
		public var fsm:FiniteStateMachine;
		public var ed:EventDispatcher = new EventDispatcher();
		private var _currentAngle:Number = 0;
		
		public function KillerWhale( engine:Engine )
		{
			var me:KillerWhale = this;
			super(engine);
			
			SetModel("Whale", engine );
			SetScale(0.5,0.5,0.5);
			SetPosition(0,-30,860);
			SetLookAt(10,-30,860);
			
			AddAnimation("swim1", 1, 59 );
			AddAnimation("swim2", 100, 160);
			AddAnimation("jump1", 200, 260 );
			AddAnimation("jump2", 300, 360 );
			AddAnimation("turn", 400, 459 );
			
			_obj.setLayer(0);
			
			fsm = new FiniteStateMachine(
			{
				Init: // state
				{
					onStartUp: function():void // handler
					{
						_PlayAnimation("swim1", 10, false );
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
						var center:Vector3D = new Vector3D(0,0,110);
						
						_currentAngle += 10.0;
						_currentAngle = (_currentAngle >= 360)? 0:_currentAngle;
						Tween( GetNewHeading( _currentAngle, 750, center ),  500, function( e:Event ):void
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
		
		public function GetNewHeading( angle:Number, radius:Number, center:Vector3D):Object
		{
			angle*=Math.PI/180;
			var forward:Vector3D
			forward = _obj.getDir();
			forward.normalize();
			var x:Number = Math.sin( angle ) * radius;
			var z:Number = Math.cos( angle ) * radius;
			var right:Vector3D = new Vector3D( 0 - x, 0, 0 - z );
			right.normalize();			
			var up:Vector3D = new Vector3D( 0, 1, 0 );
			var newForward:Vector3D = right.crossProduct( up );
			var heading:Number = Math.acos( forward.dotProduct( newForward ) );
			heading *= 180/Math.PI;
			x+= center.x;			
			z+= center.z;
			return {h:heading, x:x, z:z}; // return tween object
		}
		
		protected override function _AnimationComplete( e:Event ):void
		{
			//trace("animation done");
			fsm.Fire("onAnimationDone");
			ed.dispatchEvent( new Event("AnimationDone") );
			
		}
		
		private function _MoveToComplete( e:Event ):void
		{
			//trace("moveto done");
			fsm.Fire("onMoveToDone");
			ed.dispatchEvent( new Event("MoveToDone") );
			
		}
	}
}