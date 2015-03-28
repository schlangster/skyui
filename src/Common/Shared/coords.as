	class Shared.coords {
		private var playerPosition: Array;
		
		public function coords() {
			// constructor code
			playerPosition [0]= Math.round (playerPosition [0]);
			playerPosition [1]= Math.round (playerPosition [1]);
		}


		

    public static function GetplayerPosition()
    {
		var coordsInstance = new coords;
        var i = coordsInstance.playerPosition;    
		return i;
    }
    public static function SetplayerPosition (x: Array)
    {
		var coordsInstance = new coords;
        var i = coordsInstance.playerPosition;    
		i = x;
    }
	}
