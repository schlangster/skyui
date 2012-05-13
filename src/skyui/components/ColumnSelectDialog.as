import gfx.io.GameDelegate;

import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;


class skyui.components.ColumnSelectDialog extends MovieClip
{	
  /* STAGE ELEMENTS */
  
	public var panelContainer: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
	private var _columnList: ButtonList;
	
	
  /* CONSTRUCTORS */
  
	public function ColumnSelectDialog()
	{
		_columnList = panelContainer.list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	public function onLoad(): Void
	{
		_columnList.listEnumeration = new BasicEnumeration(_columnList.entryList);
		_columnList.entryFormatter = new ButtonEntryFormatter(_columnList);
			
		_columnList.entryList.push({text: "ARMOR", enabled: true, state: "on"});
		_columnList.entryList.push({text: "WEIGHT", enabled: true, state: "on"});
		_columnList.entryList.push({text: "VALUE/WEIGHT", enabled: true, state: "off"});
		_columnList.entryList.push({text: "VALUE", enabled: true, state: "on"});
		
		_columnList.InvalidateData();
	}
	
	public function onDialogOpening(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
	}
	
	public function onDialogClosing(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
	}
	

}