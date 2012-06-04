dynamic class StatsPage extends MovieClip
{
	var CategoryList;
	var CategoryList_mc;
	var StatsList_mc;
	var _StatsList;
	var bUpdated;

	function StatsPage()
	{
		super();
		this.CategoryList = this.CategoryList_mc.List_mc;
		this._StatsList = this.StatsList_mc;
		this.bUpdated = false;
	}

	function onLoad()
	{
		this.CategoryList.entryList.push({text: "$GENERAL", stats: new Array(), savedHighlight: 0});
		this.CategoryList.entryList.push({text: "$QUEST", stats: new Array(), savedHighlight: 0});
		this.CategoryList.entryList.push({text: "$COMBAT", stats: new Array(), savedHighlight: 0});
		this.CategoryList.entryList.push({text: "$MAGIC", stats: new Array(), savedHighlight: 0});
		this.CategoryList.entryList.push({text: "$CRAFTING", stats: new Array(), savedHighlight: 0});
		this.CategoryList.entryList.push({text: "$CRIME", stats: new Array(), savedHighlight: 0});
		this.CategoryList.InvalidateData();
		this.CategoryList.addEventListener("listMovedUp", this, "onCategoryListMoveUp");
		this.CategoryList.addEventListener("listMovedDown", this, "onCategoryListMoveDown");
		this.CategoryList.addEventListener("selectionChange", this, "onCategoryListMouseSelectionChange");
		this._StatsList.disableSelection = true;
	}

	function startPage()
	{
		gfx.managers.FocusHandler.instance.setFocus(this.CategoryList, 0);
		if (this.bUpdated) 
		{
			return;
		}
		gfx.io.GameDelegate.call("updateStats", [], this, "PopulateStatsList");
		this.bUpdated = true;
	}

	function endPage()
	{
	}

	function PopulateStatsList()
	{
		var __reg10 = 0;
		var __reg8 = 1;
		var __reg9 = 2;
		var __reg11 = 3;
		var __reg7 = 4;
		var __reg3 = 0;
		while (__reg3 < arguments.length) 
		{
			var __reg4 = {text: "$" + arguments[__reg3 + __reg10], value: arguments[__reg3 + __reg8]};
			this.CategoryList.entryList[arguments[__reg3 + __reg9]].stats.push(__reg4);
			__reg3 = __reg3 + __reg7;
		}
		this.onCategoryHighlight();
	}

	function onCategoryHighlight()
	{
		var __reg3 = this.CategoryList.selectedEntry.stats;
		this._StatsList.ClearList();
		this._StatsList.scrollPosition = 0;
		var __reg2 = 0;
		while (__reg2 < __reg3.length) 
		{
			this._StatsList.entryList.push(__reg3[__reg2]);
			++__reg2;
		}
		this._StatsList.InvalidateData();
	}

	function onCategoryListMoveUp(event)
	{
		this.onCategoryHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.CategoryList._parent.gotoAndPlay("moveUp");
		}
	}

	function onCategoryListMoveDown(event)
	{
		this.onCategoryHighlight();
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
		{
			this.CategoryList._parent.gotoAndPlay("moveDown");
		}
	}

	function onCategoryListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1) 
		{
			this.onCategoryHighlight();
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function onRightStickInput(afX, afY)
	{
		if (afY < 0) 
		{
			this._StatsList.moveSelectionDown();
			return;
		}
		this._StatsList.moveSelectionUp();
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		this.CategoryList.SetPlatform(aiPlatform, abPS3Switch);
		this._StatsList.SetPlatform(aiPlatform, abPS3Switch);
	}

}
