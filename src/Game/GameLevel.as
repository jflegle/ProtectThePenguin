package  Game
{
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.materials.Shader3D;
	
	import flash.events.Event;
	
	public class GameLevel extends Level
	{
		private var _penguin:Penguin;
		private var _board:Board;
		private var _score:uint = 0;
		private var _record:uint = 0;
		private var _level:uint = 0;
		private var _turns:uint = 0;
		private var _water:Water;
		private var _killer:KillerWhale;
		private var _fish:FishSchool;
		private var _HUD:HUD;
		
		public function GameLevel()
		{
			super();
		}
		
		public override function Initialize( engine:Engine ):void
		{
			super.Initialize( engine );
			
			_fsm = new FiniteStateMachine(
				{
					Init: // state
					{
						onStartUp: function():void // handler
						{
							// set camera
							engine.GetScene().camera = new Camera3D();
							//engine.GetScene().camera.setPosition( -50, 658, -350 );
							//engine.GetScene().camera.lookAt( -50, 0, -20 );
							engine.GetScene().camera.setPosition( -50, 658, -260 );
							engine.GetScene().camera.lookAt( -50, 0, 70 );
														
							// set light
							var light:Light3D = new Light3D();
							light.setPosition( 0, 300, 0 );
							engine.GetScene().defaultLight.color.setTo(0.3, 0.3, 0.3 );
							engine.GetScene().lights.maxPointLights = 1;
							engine.GetScene().addChild( light )
							
							// load models
							engine.LoadModel("Assets/Penguin_w_Shadow_02.f3d", "Penguin");
							engine.LoadModel("Assets/TilePiece01.f3d", "TileModel");
							engine.LoadModel("Assets/water_update02.f3d", "WaterTest");
							engine.LoadModel("Assets/KillerWhale(1).f3d", "Whale");
							engine.LoadModel("Assets/SchoolOfFish.f3d", "FishModel");
							
							// Load textures
							engine.LoadTexture("Assets/IcePiece.jpg", "Tile_Normal" );
							engine.LoadTexture("Assets/Tile_Select.jpg", "Tile_Select" );
							engine.LoadTexture("Assets/Tile_Block.jpg", "Tile_Blocked" );
							engine.LoadTexture("Assets/Tile_break_Lv1.jpg", "Tile_Break1" );
							engine.LoadNormalTexture("Assets/Tile_break_Lv2.jpg", "Assets/Tile_breakLv2_Norm.jpg", "Tile_Break2" );
							engine.LoadNormalTexture("Assets/Tile_break_Lv3.jpg", "Assets/Tile_breakLv3_Norm.jpg", "Tile_Break3" );
							engine.LoadNormalTexture("Assets/Tile_break_Lv4.jpg", "Assets/Tile_breakLv4_Norm.jpg", "Tile_Break4" );
							engine.LoadNormalTexture("Assets/Tile_break_Lv5.jpg", "Assets/Tile_breakLv5_Norm.jpg", "Tile_Break5" );
							
							engine.SetLoadedCallback( Loaded );
							engine.GetScene().pause();
						},
						onLoadDone: function():Object
						{
							//trace( "Success Loading" );
							
							// Board
							_board = new Board( engine, 11, 11 );							
							_board.ed.addEventListener("PlayerDone", function():void
							{
								_fsm.Fire("onPlayerDone");
							});
							
							// Ai
							_penguin = new Penguin( engine );
							_penguin.ed.addEventListener("AnimationDone", function():void
							{
								_fsm.Fire("onPenguinAnimDone");
							});
							
							// water
							_water = new Water( engine );
							
							// killer whale
							_killer = new KillerWhale( engine );
							
							// fish
							_fish = new FishSchool( engine );							
							
							// HUD
							_HUD = new HUD( engine );
							
							_DispatchMessage("DoneLoading");
							
							return _fsm.States.GameSetUp;
						}
						
					},
					GameSetUp:
					{
						onStartUp: function():Object // handler
						{
							_board.CommandAllTiles("onReset");
							_board.MakeRandomBoard( Math.max( 10, 35 - _level ) );
							_turns = 0;
							
							_penguin.currentTile = _board.GetTile( 5, 5 );
							_penguin.SetPosition( _penguin.currentTile.GetXPosition(), 0, _penguin.currentTile.GetZPosition() );
							_penguin.SetLookAt(0,0,0);
							_penguin.fsm.Fire("onRestart");
							
							_killer.fsm.Fire("onStart");
							_fish.fsm.Fire("onStart");
										
							return _fsm.States.GamePlayerTurn;
						}
					},
					GamePlayerTurn:
					{
						onStartUp: function():void // handler
						{
							_board.CommandAllTiles("onEnable");
							_board.CommandTile( _penguin.currentTile.GetData().x, _penguin.currentTile.GetData().y, "onDisable");							
						},
						onPlayerDone: function():Object
						{
							PlayerTurn( );
							return _fsm.States.GameAiTurn;
						}
					},
					GameAiTurn:
					{
						onStartUp: function():void
						{
							_board.CommandAllTiles("onDisable");
							AITurn( );								
						},
						onAiDone: function():Object
						{
							_turns++;
							_board.CommandAllTiles("onFade");
							return _fsm.States.GamePlayerTurn;
						},
						onWin: function():Object
						{
							return _fsm.States.Win;
						},
						onLose: function():Object
						{
							return _fsm.States.Lose;
						}
					},
					GameEnd:
					{						
						onStartUp: function():void // from ending dialog continue game
						{
													
						},
						onContinue: function():Object
						{
							_HUD.Show();
							return _fsm.States.GameSetUp;
						}
					},
					Win:
					{
						onPenguinAnimDone: function():Object // win dialog goes here
						{
							_DispatchMessage("Win");
							return _fsm.States.GameEnd;
						}
					},
					Lose:
					{
						onPenguinAnimDone: function():Object // lose dialog goes here
						{							
							_DispatchMessage("Lose");
							return _fsm.States.GameEnd;
						}
					}
				});
			
			_fsm.Start();			
		}
		
		private function PlayerTurn( ):void
		{
			
		}
		
		private function AITurn( ):Boolean
		{
			var tile:Tile = _penguin.currentTile;
			var direction:Array = [ tile.northWest, tile.northEast, tile.east, tile.southEast, tile.southWest, tile.west ];
			
			// check for freedom
			for( var i:int = 0; i < 6; i++ ) {
				if( direction[i] == null ) {
					Lose( );
					return true;
				}
			}
			
			// check for trapped
			for( i = 0; i < 6; i++ ) {
				if( direction[i].isOpen() ) {
					break;
				}
			}
			if( i == 6 ) {
				Win( );
				return true;
			}
			
			tile = _board.CalculatePath( tile, null );
			
			_penguin.currentTile = tile;
			_penguin.MoveTo( tile.GetXPosition(), 0, tile.GetZPosition(), function( e:Event ):void{
				_fsm.Fire("onAiDone"); 
			});		
			
			return false;
		}
		
		private function Win( ):void
		{
			//trace("win");
			_level++;
			_score += Math.max( 100, (1000 - _turns*10) );
			if( _score > _record )
			{
				_record = _score;
			}
			_HUD.score.text = _score.toString();
			_HUD.record.text = _record.toString();
			_HUD.level.text = (_level+1).toString();
			//trace("score: " + _score);
			_HUD.Hide();
			_fsm.Fire("onWin");
			_penguin.fsm.Fire("onLose");
		}
		
		private function Lose( ):void
		{
			//trace("lose");
			_HUD.Hide();
			_HUD.score.text = "0";
			_HUD.level.text = "1";
			_level = 0;
			_score = 0;
			_fsm.Fire("onLose");
			_penguin.fsm.Fire("onDive");
		}
		
		//Called when all evel assets are loaded
		public function Loaded(e:Event ):void
		{
			DoneLoading();
			_engine.GetScene().resume();
			
			_fsm.Fire("onLoadDone");
		}
		
		public override function Update( ):void
		{
			if( IsLoading() ) // do nothing till done loading
				return;
			
		}
		
		public function GetScore( ):uint
		{
			return _score;
		}
		
		public function GetLevel( ):uint
		{
			return _level;
		}
		
		public function GetRecord( ):uint
		{
			return _record;
		}
		
	}
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      