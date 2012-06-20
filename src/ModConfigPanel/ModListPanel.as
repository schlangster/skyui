

class ModListPanel extends MovieClip
{
  /* CONSTANTS */
	
	private var SHOW_MODLIST = 1;
	private var SHOW_SUBMODLIST = 2;
	private var FADE_TO_MODLIST = 3;
	private var FADE_TO_SUBMODLIST = 4;
	
	
  /* STAGE ELEMENTS */
	
	public var decorTop: MovieClip;
	public var decorTitle: MovieClip;
	public var decorBottom: MovieClip;
	
	public var modList: ModList;
	

  /* PUBLIC FUNCTIONS */
  
	public function showModList(): Void
	{
		
	}
	
	public function showSubList(): Void
	{
		
	}


  /* PRIVATE FUNCTIONS */
  
	public function setState(a_mode: Number)
	{
		
	}
  
	/*private function updateSelector(): Void
	{
		var selectedClip; // = _entryClipManager.getClip(_selectedIndex);
		
		if (selectedClip == undefined) {
			selectorTop._visible = true;
			selectorTop._y = background._y;
			selectorTop._height = background._height;

			selectorEntry._visible = false;
			selectorBottom._visible = false;
			
		} else {
			selectorTop._visible = true;
			selectorTop._y = background._y;
			selectorTop._height = selectedClip._y - selectorTop._y ;
			
			selectorEntry._visible = true;
			selectorEntry._y = selectedClip._y;
			selectorEntry._height = selectedClip._height;

			selectorBottom._visible = true;
			selectorBottom._y = selectedClip._y + selectedClip._height;
			selectorBottom._height = selectorBottom._y - background._height;
		}
	}*/
}