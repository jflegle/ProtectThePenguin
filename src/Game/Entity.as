package  Game
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	public class Entity extends AnimatedModel
	{
		// tween values
		private var moveToCallBack:Function; // TODO roll this into a tween class
		private var tic:Timer;
		private var step:Object = { x:0, y:0, z:0, h:0, p:0, r:0 };		// position( x,y,z ), heading pitch roll
		
		public function Entity( engine:Engine )
		{
			super();
			tic = new Timer(10);	
			
			tic.addEventListener(TimerEvent.TIMER, _Update);
			tic.addEventListener(TimerEvent.TIMER_COMPLETE, _End);			
		}		
		
		// supports x, y, z translation
		public function Tween( info:Object, ms:Number=1000, callback:Function=null ):void
		{
			if(tic.running)
			{
				tic.reset();
			}
			moveToCallBack = callback;
			var percent:Number = 10.0/ms;
			
			step.x = (info.hasOwnProperty("x"))? (info.x-GetXPosition())*percent:0;			
			step.y = (info.hasOwnProperty("y"))? (info.y-GetYPosition())*percent:0;		
			step.z = (info.hasOwnProperty("z"))? (info.z-GetZPosition())*percent:0;
			step.h = (info.hasOwnProperty("h"))? (info.h)*percent:0;
			step.p = (info.hasOwnProperty("p"))? (info.p)*percent:0;
			step.r = (info.hasOwnProperty("r"))? (info.r)*percent:0;
			
			tic.repeatCount = ms/10.0;	
			tic.start();			
		}
		private function _Update( event:TimerEvent ):void
		{
			this.SetPosition(	GetXPosition()+step.x,
								GetYPosition()+step.y,
								GetZPosition()+step.z );
			
			this.SetRotation(	step.p,
								step.h,
								step.r );
			
		}
		private function _End( event:TimerEvent ):void
		{
			tic.reset();
			if(moveToCallBack!=null) moveToCallBack( event );
		}
		public function SetLookAt( x:Number, y:Number, z:Number ):void
		{
			_obj.lookAt( x, y, z, _obj.getUp(), 1 );
		}	
		
	}
}