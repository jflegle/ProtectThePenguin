package
{
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.materials.Shader3D;
	
	import flash.events.Event;
	
	public class KillerLevel extends Level
	{
		private var _killer:KillerWhale;
		private var _fish:FishSchool;
		private var _fsm:FiniteStateMachine;
		
		public function KillerLevel()
		{
			super();
		}
		
		public override function Initialize( engine:Engine ):void
		{
			super.Initialize( engine );
			
			_fsm = new FiniteStateMachine( 
				{
					Init:
					{
						onStartUp: function():void
						{
							// set camera
							engine.GetScene().camera = new Camera3D();
							// set camera
							engine.GetScene().camera = new Camera3D();
							engine.GetScene().camera.setPosition( -50, 658, -350 );
							engine.GetScene().camera.lookAt( -50, 0, -20 );
							
							// set light
							var light:Light3D = new Light3D();
							light.setPosition( 0, 300, 0 );
							engine.GetScene().defaultLight.color.setTo(0.3, 0.3, 0.3 );
							engine.GetScene().lights.maxPointLights = 1;
							engine.GetScene().addChild( light )
							
							engine.SetLoadedCallback( Loaded );
							
							engine.LoadModel("Assets/KillerWhale(1).f3d", "Whale");
							engine.LoadModel("Assets/SchoolOfFish.f3d", "FishModel");
						},
						onLoadDone: function():Object
						{
							_killer = new KillerWhale( engine );
							_killer.fsm.Fire("onStart");
							
							_fish = new FishSchool( engine );
							_fish.fsm.Fire("onStart");
							
							return _fsm.States.Game;
						}
					},
					Game:
					{
						onStartUp: function():void
						{
							// stuff
						}
					}					
				});
			
			
			_fsm.Start();			
			
		}
		
		//Called when all evel assets are loaded
		public function Loaded(e:Event ):void
		{
			
			_fsm.Fire("onLoadDone");
			
			DoneLoading();
		}
		
		public override function Update( ):void
		{
			if( IsLoading() ) // do nothing till done loading
				return;
			
			//_killer.SetRotation(0, 0, 1);
			
			
		}
	}
}

