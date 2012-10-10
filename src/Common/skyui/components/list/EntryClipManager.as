import skyui.components.list.BasicList;
import skyui.components.list.IEntryClipBuilder;


class skyui.components.list.EntryClipManager
{ 
  /* PRIVATE VARIABLES */
  
	private var _clipPool: Array;
	
	private var _list: BasicList;
	
	private var _entryRenderer: String;
	
	private var _nextIndex: Number = 0;
	
	
  /* PROPERTIES */
	
	private var _clipCount: Number = -1;
	
	public function get clipCount(): Number
	{
		return _clipCount;
	}
	
	// Allocates the necessary number of clips in the pool, clears any existing clips for reuse.
	public function set clipCount(a_clipCount: Number)
	{
		_clipCount = a_clipCount;
		
		var d = a_clipCount - _clipPool.length;
		if (d > 0)
			growPool(d);
			
		for (var i=0; i<_clipPool.length; i++) {
			_clipPool[i]._visible = false;
			_clipPool[i].itemIndex = undefined;
		}
	}
	
	
  /* INITIALIZATION */
  
	public function EntryClipManager(a_list: BasicList)
	{
		_list = a_list;
		_clipPool = [];
	}
  
  
  /* PUBLIC FUNCTIONS */
	
	public function getClip(a_index: Number): MovieClip
	{
		if (a_index >= _clipCount)
			return undefined;

		return _clipPool[a_index];
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function growPool(a_size: Number): Void
	{
		var entryRenderer = _list.entryRenderer;
		
		for (var i=0; i<a_size; i++) {
			var entryClip = _list.attachMovie(entryRenderer, entryRenderer + _nextIndex, _list.getNextHighestDepth());
			entryClip.initialize(_nextIndex, _list.listState);

			_clipPool[_nextIndex] = entryClip;
			_nextIndex++;
		}
	}
}
