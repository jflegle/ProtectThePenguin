package  Game
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Board
	{
		private var _grid:Array;
		private var _tileList:Array;
		private var _boardWidth:int;
		private var _boardHeight:int;
		private var _boardMax:int;
		
		public var ed:EventDispatcher = new EventDispatcher();
		

		public function Board( engine:Engine, h:int, w:int )
		{
			var radius:int = 53; // TODO find a way to get size from the model?
			
			_boardWidth = w;
			_boardHeight = h;
			_boardMax = w*h;
			
			var tileWidth:int = 0.866/*sin(60)*/*radius*2;
			var tileHeight:int = radius*2;
			var halfWidth:int = tileWidth/2;
			
			var startingX:int = -tileWidth*_boardWidth/2;
			var startingY:int = tileHeight*_boardHeight/2;
			
			var xOffset:int = startingX;
			var yOffset:int = startingY;
			var x:int;
			var y:int;
			
			// hexagon offset
			tileHeight -= radius - (0.5/*cos(60)*/*radius);
			
			tileHeight+=2; // boarder around tiles
			halfWidth+=1;
			tileWidth+=2;
			
			// make the grid
			_grid = new Array();			
			for( x = 0; x < _boardWidth; x++)
			{
				_grid[x] = new Array();
			}
			
			// create the tiles
			var tile:Tile;
			for( y = 0; y < _boardHeight; y++ )
			{
				xOffset = startingX;
				xOffset += (y%2)? halfWidth:0;
					
				for( x = 0; x < _boardWidth; x++ )
				{	
					_grid[x][y] = new Tile( engine, xOffset, yOffset, {x:x, y:y} );
					
					tile = _grid[x][y];
					tile.ed.addEventListener( "Touched", function( event:Event ):void {
						// tile was touched
						// message up
						ed.dispatchEvent(new Event( "PlayerDone", false) );
					
					});
					
					// set path links
					if( y%2 )
					{
						// odd rows
						tile.SetLink(	(y>0)? _grid[x][y-1]:null, // nw 
										(x<w-1 && y>0)? _grid[x+1][y-1]:null, // ne
										(x<w-1)? _grid[x+1][y]:null, // e
										(x<w-1 && y <h-1)? _grid[x+1][y+1]:null, // se
										(y<h-1)? _grid[x][y+1]:null, // sw
										(x>0)? _grid[x-1][y]:null); // w
					}
					else
					{
						// even rows
						tile.SetLink(	(x>0 && y>0)? _grid[x-1][y-1]:null, // nw 
										(y>0)? _grid[x][y-1]:null, // ne
										(x<w-1)? _grid[x+1][y]:null, // e
										(y<h-1)? _grid[x][y+1]:null, // se
										(x>0 && y<h-1)? _grid[x-1][y+1]:null, // sw
										(x>0)? _grid[x-1][y]:null); // w
					}
					
					xOffset += tileWidth;
				}
				yOffset -= tileHeight;
			}
		}
		public function CommandAllTiles( command:String ):void
		{
			
			for( var y:int = 0; y < _boardHeight; y++ )
			{
				for( var x:int = 0; x < _boardWidth; x++ )
				{	
					_grid[x][y].fsm.Fire( command );
				}
			}				
		}
		public function CommandTile( x:int, y:int, command:String ):void
		{
			_grid[x][y].fsm.Fire( command );							
		}
		public function GetTile( x:int, y:int ):Tile
		{
			if( x >= _boardWidth ) x = _boardWidth-1;
			if( y >= _boardHeight ) y = _boardHeight-1;
			return _grid[x][y];
		}
		public function MakeRandomBoard( blocked:int ):void
		{
			var x:int;
			var y:int;
			var tile:Tile;
			
			if( blocked >= _boardMax )
			{
				blocked = _boardMax-1;
			}
			
			while( blocked >= 0 )
			{
				x = Math.floor( Math.random() * _boardWidth );
				y = Math.floor( Math.random() * _boardHeight );
				
				if( x == y && x == 5 ) {
					continue;
				}
				tile = _grid[x][y];
				if( tile.isOpen() )
				{
					tile.fsm.Fire("onBlocked");
					blocked--;
				}
			}
		}
		// Path finding
		private function _AddNewTiles( newList:Array, tile:Tile, dist:int ):void
		{
			var tile:Tile;
			var dirs:Array = [ tile.northWest, tile.northEast, tile.east, tile.southEast, tile.southWest, tile.west ];
			var index:int = 0;
			for( var i:int = 0; i < 6; i++ ) {
				tile = dirs[i];
				if( tile != null && tile.isOpen() && tile.GetVisited() == -1 ) {
					newList[newList.length] = tile;
					dirs[i].SetVisited( dist );
				}
			}
		}
		public function CalculatePath( startTile:Tile, endTile:Tile=null ):Tile // returns next ideal tile to get to endTile
		{
			var dist:int = 1;
			var index:int = 0;
			var pathList:Array = new Array();
			var newList:Array = new Array();
			
			pathList[index] = startTile;
			startTile.SetVisited( 0 );
			
			// build path
			// if newList is empty we are done
			while( newList.length > 0 || index == 0 )
			{
				newList.splice( 0, newList.length );
				
				
				// add nearby nodes of pathList into newList
				while( index < pathList.length ) {
					
					startTile = pathList[index];
					if( pathList[index].CheckNeighbors( endTile ) ) // end found
					{
						newList.splice( 0, newList.length );
						break;
					}
					_AddNewTiles( newList, pathList[index], dist );
					index++;
				}
				
				dist++;
				// add newlist to end of pathlist and continue
				pathList = pathList.concat( newList );
				
			}
			dist = startTile.GetVisited();
			
			// find the next tile to move to
			while( --dist > 0 ){
				startTile = startTile.FindNextPath( dist );
				dist = startTile.GetVisited();      
			}
			return startTile;
		}
	}
}