import skyui.BasicList;


class skyui.BasicEntryBuilder implements skyui.IEntryClipBuilder
{
  /* PRIVATE VARIABLES */
  
	private var _list: BasicList;
	
	
  /* PROPERTIES */
  
	private var _entryClassName: String;
	
	public function get entryClassName(): String
	{
		return _entryClassName;
	}
	
	public function set entryClassName(a_name: String)
	{
		_entryClassName = a_name;
	}
	
	private var _iconThemeName: String;
	
	public function get iconThemeName(): String
	{
		return _iconThemeName;
	}
	
	public function set iconThemeName(a_name: String)
	{
		_iconThemeName = a_name;
	}
	
	
  /* CONSTRUCTORS */
	
	public function BasicEntryBuilder(a_list: BasicList, a_entryClassName: String, a_iconThemeName: String)
	{
		_list = a_list;
		_entryClassName = a_entryClassName;
		_iconThemeName = a_iconThemeName;
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// @override skyui.IEntryClipFactory
	public function createEntryClip(a_index: Number): MovieClip
	{
		var entryClip = _list.attachMovie(_entryClassName, _entryClassName + a_index, _list.getNextHighestDepth());
		
		entryClip.onRollOver = function()
		{
			var list = this._parent;
			
			if (this.itemIndex != undefined && this.enabled)
				list.onItemRollOver(this.itemIndex);
		};
		
		entryClip.onRollOut = function()
		{
			var list = this._parent;
			
			if (this.itemIndex != undefined && this.enabled)
				list.onItemRollOut(this.itemIndex);
		};
		
		entryClip.onPress = function(a_mouseIndex: Number, a_keyboardOrMouse: Number)
		{
			var list = this._parent;
			
			if (this.itemIndex != undefined && this.enabled)
				list.onItemPress(this.itemIndex, a_keyboardOrMouse);
		};
		
		entryClip.onPressAux = function(a_mouseIndex: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number)
		{
			var list = this._parent;
			
			if (this.itemIndex != undefined && this.enabled)
				list.onItemPressAux(this.itemIndex, a_keyboardOrMouse, a_buttonIndex);
		};
		
		return entryClip;
	}
}