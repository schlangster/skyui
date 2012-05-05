import skyui.BSList;
import skyui.IEntryClipFactory;

class skyui.EntryClipManager
{ 
  /* PRIVATE VARIABLES */
  
	private var _entryClips: Array;
	
	
  /* PROPERTIES */

	private var _entryClipFactory: IEntryClipFactory;
	
	public function set entryClipFactory(a_entryClipFactory: IEntryClipFactory)
	{
		_entryClipFactory = a_entryClipFactory;
	}
	
	
  /* CONSTRUCTORS */
  
	public function EntryClipManager()
	{
		_entryClips = [];
	}
  
  
  /* PUBLIC FUNCTIONS */
  
	public function getClipByIndex(a_index: Number)
	{
		if (a_index < 0)
			return undefined;

		if (_entryClips[a_index] != undefined)
			return _entryClips[a_index];
		
		// Create on-demand
		_entryClips[a_index] = _entryClipFactory.createEntryClip(a_index);
		_entryClips[a_index].clipIndex = a_index;
		return _entryClips[a_index];
	}
}
