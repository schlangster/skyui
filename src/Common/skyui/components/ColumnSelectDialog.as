import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ListLayout;
import skyui.util.DialogManager;
import skyui.util.ConfigManager;


class skyui.components.ColumnSelectDialog extends MovieClip
{	
  /* STAGE ELEMENTS */
  
	public var panelContainer: MovieClip;
	
	
  /* PRIVATE VARIABLES */
  
	private var _columnList: ButtonList;
	
	
  /* PROPERTIES */
	
	public var layout: ListLayout;
	
	
  /* CONSTRUCTORS */
  
	public function ColumnSelectDialog()
	{
		_columnList = panelContainer.list;
	}
	
	
  /* PUBLIC FUNCTIONS */
	
	// Constructor is too early to do anything with the embedded list if the Movie is created with attachMovie.
	public function onLoad(): Void
	{
		_columnList.listEnumeration = new BasicEnumeration(_columnList.entryList);
		_columnList.entryFormatter = new ButtonEntryFormatter(_columnList);
		
		_columnList.addEventListener("itemPress", this, "onColumnToggle");
		layout.addEventListener("layoutChange", this, "onLayoutChange");
		
		setColumnListData();
	}
	
	public function onDialogOpening(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		FocusHandler.instance.setFocus(_columnList, 0);
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
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;

		if (GlobalFunc.IsKeyPressed(details)) {
				
			if (details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.RIGHT) {
				DialogManager.closeDialog();
				bCaught = true;
			}

			if (!bCaught)
				bCaught = pathToFocus[0].handleInput(details, pathToFocus.slice(1));
		}
		
		return bCaught;
	}
	
	public function onMouseDown(): Void
	{
		for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
			if (e == this)
				return;
				
		DialogManager.closeDialog();
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function setColumnListData()
	{
		_columnList.clearList();
		
		var columnDescriptors = layout.columnDescriptors;
		
		for (var i=0; i<columnDescriptors.length; i++) {
			var col = columnDescriptors[i];
			if (col.type == ListLayout.COL_TYPE_TEXT)
				_columnList.entryList.push({enabled: true, text: col.longName, value: col.hidden, state: (col.hidden ? "off" : "on"), id: col.identifier});
		}
		
		_columnList.InvalidateData();
	}
}