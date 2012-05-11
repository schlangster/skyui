import skyui.components.list.BasicList;
import skyui.components.list.IEntryClipBuilder;


class skyui.components.list.EntryClipManager
{ 
  /* PRIVATE VARIABLES */
  
	private var _entryClips: Array;
	
	private var _list: BasicList;
	
	private var _entryRenderer: String;
	
	
  /* PROPERTIES */

	private var _entryClipBuilder: IEntryClipBuilder;
	
	public function set entryClipBuilder(a_entryClipBuilder: IEntryClipBuilder)
	{
		_entryClipBuilder = a_entryClipBuilder;
	}
	
	private var _maxIndex: Number = -1;
	
	public function get maxIndex(): Number
	{
		return _maxIndex;
	}
	
	
  /* CONSTRUCTORS */
  
	public function EntryClipManager(a_list: BasicList)
	{
		_list = a_list;
		_entryClips = [];
	}
  
  
  /* PUBLIC FUNCTIONS */
  
	public function getClipByIndex(a_index: Number): MovieClip
	{
		if (a_index < 0)
			return undefined;
			
		if (a_index > _maxIndex)
			_maxIndex = a_index;

		if (_entryClips[a_index] != undefined)
			return _entryClips[a_index];
			
		var entryRenderer = _list.entryRenderer;
		
		// Create on-demand
		skse.Log("Creating " + entryRenderer);
		var entryClip = _list.attachMovie(entryRenderer, entryRenderer + a_index, _list.getNextHighestDepth());
		entryClip.initialize(a_index, _list);
		_entryClips[a_index] = entryClip;

		entryClip.clipIndex = a_index;
		return entryClip;
	}
}
