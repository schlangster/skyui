import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ListLayout;
import skyui.components.dialog.BasicDialog;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;


class skyui.components.dialog.ColumnSelectDialog extends BasicDialog
{	
  /* STAGE ELEMENTS */
  
	public var list: ButtonList;
	
	
  /* PROPERTIES */
	
	public var layout: ListLayout;
	
	
  /* CONSTRUCTORS */
  
	public function ColumnSelectDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// Constructor is too early to do anything with the embedded list if the Movie is created with attachMovie.
	public function onLoad(): Void
	{
		list.listEnumeration = new BasicEnumeration(list.entryList);
		
		list.addEventListener("itemPress", this, "onColumnToggle");
		layout.addEventListener("layoutChange", this, "onLayoutChange");
		
		setColumnListData();
	}
	
	public function onDialogOpening(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		FocusHandler.instance.setFocus(list, 0);
	}
	
	public function onDialogClosing(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		layout.removeEventListener("layoutChange", this, "onLayoutChange");
	}
	
	public function onColumnToggle(event: Object): Void
	{
		var entry = event.entry;
		ConfigManager.setOverride("ListLayout", "columns." + entry.id + ".hidden", !entry.value, entry.value ? "false" : "true");
	}
	
	public function onLayoutChange(event: Object): Void
	{
		setColumnListData();
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{	
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.TAB || details.navEquivalent == NavigationCode.ESCAPE ||
					details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT) {
				DialogManager.close();
				return true;
			}
		}
			
		var nextClip = pathToFocus.shift();
		return nextClip.handleInput(details, pathToFocus);
	}
	
	public function onMouseDown(): Void
	{
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e == this)
				return;
		DialogManager.close();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setColumnListData()
	{
		list.clearList();
		
		var columnDescriptors = layout.columnDescriptors;
		
		for (var i=0; i<columnDescriptors.length; i++) {
			var col = columnDescriptors[i];
			
			if (col.type == ListLayout.COL_TYPE_TEXT)
				list.entryList.push({enabled: true, text: col.longName, value: col.hidden, state: (col.hidden ? "off" : "on"), id: col.identifier});
		}
		
		list.InvalidateData();
	}
}