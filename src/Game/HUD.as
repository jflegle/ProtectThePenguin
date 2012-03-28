package Game
{
	import flash.text.TextFieldAutoSize;
	
	public class HUD
	{
		public var level:TextLabel;
		public var score:TextLabel;
		public var record:TextLabel;
		
		public function HUD( engine:Engine )
		{
			score = new TextLabel( engine, 5, 5, 62, 19, "Assets/Images/PenguinMenus CONVERTED/imgScoreBkg.png", "Heavy Heap", 0x36FFD7, 24, TextFieldAutoSize.CENTER );
			score.text = "0";
			level = new TextLabel( engine, 5, 110, 36, 19, "Assets/Images/PenguinMenus CONVERTED/imgLevelBkg.png", "Heavy Heap", 0x36FFD7, 24, TextFieldAutoSize.CENTER );
			level.text = "1";
			record = new TextLabel( engine, 509, 5, 63, 19, "Assets/Images/PenguinMenus CONVERTED/imgRecordBkg.png", "Heavy Heap", 0x36FFD7, 24, TextFieldAutoSize.CENTER );
			record.text = "0";
		}
		
		public function Hide( ):void
		{
			score.Hide( );
			level.Hide( );
			record.Hide( );
		}
		public function Show( ):void
		{
			score.Show( );
			level.Show( );
			record.Show( );
		}
	}
}