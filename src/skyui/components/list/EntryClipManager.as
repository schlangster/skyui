import skyui.components.list.BSList;
import skyui.components.list.IEntryClipBuilder;


class skyui.components.list.EntryClipManager
{ 
  /* PRIVATE VARIABLES */
  
	private var _entryClips: Array;
	
	
  /* PROPERTIES */

	private var _entryClipBuilder: IEntryClipBuilder;
	
	public function set entryClipBuilder(a_entryClipBuilder: IEntryClipBuilder)
	{
		_entryClipBuilder = a_entryClipBuilder;
	}
	
	
  /* CONSTRUCTORS */
  
	public function EntryClipManager()
	{
		_entryClips = [];
	}
  
  
  /* PUBLIC FUNCTIONS */
  
	public function getClipByIndex(a_index: Number): MovieClip
	{
		if (a_index < 0)
			return undefined;

		if (_entryClips[a_index] != undefined)
			return _entryClips[a_index];
		
		// Create on-demand
		_entryClips[a_index] = _entryClipBuilder.createEntryClip(a_index);
		_entryClips[a_index].clipIndex = a_index;
		return _entryClips[a_index];
	}
}
