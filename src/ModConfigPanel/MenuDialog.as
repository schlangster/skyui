import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.util.DialogManager;


class MenuDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
	

  /* STAGE ELEMENTS */
	
	public var menuList: ScrollingList;

	
  /* PROPERTIES */
	
	public var menuOptions: Array;
	public var menuStartIndex: Number;
	public var menuDefaultIndex: Number;
	
	
  /* INITIALIZATION */
  
	public function MenuDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// @override OptionDialog
	public function onDefaultPress(): Void
	{
		setActiveMenuIndex(menuDefaultIndex);
	}
	
	// @override OptionDialog
	public function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}

	// @override OptionDialog
	public function onConfirmPress(): Void
	{
		skse.SendModEvent("SKICP_menuAccepted", null, getActiveMenuIndex());
		DialogManager.close();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;
		
		return bCaught;
	}
	
	public function onMenuListPress(a_event: Object): Void
	{
		var e = a_event.entry;
		if (e == undefined)
			return;
		
		menuList.listState.activeEntry = e;
		menuList.UpdateList();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setActiveMenuIndex(a_index: Number): Void
	{
		var e = menuList.entryList[a_index];
		menuList.listState.activeEntry = e;
		menuList.UpdateList();
	}
	
	private function getActiveMenuIndex(): Number
	{
		var index = menuList.listState.activeEntry.itemIndex
		return (index ? index : -1);
	}
}