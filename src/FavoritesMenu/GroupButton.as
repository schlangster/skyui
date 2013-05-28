import gfx.controls.Button;
import skyui.util.Translator;

class GroupButton extends gfx.controls.Button
{
  /* STAGE ELEMENTS */
  
	public var groupNum: MovieClip;
	public var itemIcon: MovieClip;
	
	
  /* PROPERTIES */
  
  	public var text: String;
	
	public var iconLabel: String;
	
	private var _groupIndex: Number = 0;
	
	public function get groupIndex(): Number
	{
		return _groupIndex;
	}
	
	public function set groupIndex(a_index: Number)
	{
		_groupIndex = a_index;
		_filterFlag = (FilterDataExtender.FILTERFLAG_GROUP_0 << groupIndex) | FilterDataExtender.FILTERFLAG_GROUP_ADD;
		groupNum.gotoAndStop(groupIndex+1);
	}
	
	private var _filterFlag: Number = 0;
	
	public function get filterFlag(): Number
	{
		return _filterFlag;
	}
	
	
  /* INITIALIZATION */
  
	public function GroupButton()
	{
		super();
		text = Translator.translate("$GROUP") + " " + (groupIndex + 1);
	}
}
