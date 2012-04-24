import skyui.BSList;
import skyui.IEntryClipFactory;

class skyui.EntryClipManager
{ 
  /* PRIVATE VARIABLES */
  
	private var _entryClipFactory: IEntryClipFactory;
	
	private var _entryClips: Array;
	
	
  /* CONSTRUCTORS */
  
	public function EntryClipManager(a_entryClipFactory: IEntryClipFactory)
	{
		_entryClipFactory = a_entryClipFactory;
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
