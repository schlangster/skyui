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
	private function initContent(): Void
	{
		menuList.addEventListener("itemPress", this, "onMenuListPress");

		menuList.listEnumeration = new BasicEnumeration(menuList.entryList);

		for (var i=0; i<menuOptions.length; i++) {
			var entry = {text: menuOptions[i], align: "center", enabled: true, state: "normal"};
			menuList.entryList.push(entry);
			if (i == menuStartIndex)
				menuList.listState.activeEntry = entry
		}

		menuList.InvalidateData();	  	
	}
	
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
		var index = menuList.listState.activeEntry.itemIndex;
		return (index != undefined ? index : -1);
	}
}