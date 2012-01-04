import gfx.events.EventDispatcher;
import skyui.ItemSortingFilter;
import skyui.Defines;
import skyui.Config;
import gfx.io.GameDelegate;

import skyui.IColumnFormatter;
import skyui.IDataFetcher;


class skyui.FormattedItemList extends skyui.ConfigurableList
{
	private var _dataFetcher:IDataFetcher;
	private var _columnFormatter:IColumnFormatter;
	private var _itemInfo:Object;
	
	
	function set columnFormatter(a_columnFormatter:IColumnFormatter)
	{
		_columnFormatter = a_columnFormatter;
	}
	
	function get columnFormatter():IColumnFormatter
	{
		return _columnFormatter;
	}
	
	function set dataFetcher(a_dataFetcher:IDataFetcher)
	{
		_dataFetcher = a_dataFetcher;
	}
	
	function get dataFetcher():IDataFetcher
	{
		return _dataFetcher;
	}

	function InvalidateData()
	{
		if (_dataFetcher != undefined) {
			for (var i = 0; i < _entryList.length; i++) {
				requestItemInfo(i);
				_dataFetcher.processEntry(_entryList[i], _itemInfo);
			}
		}

		super.InvalidateData();
	}

	function updateItemInfo(a_updateObj:Object)
	{
		_itemInfo = a_updateObj;
	}

	function requestItemInfo(a_index:Number)
	{
		var oldIndex = _selectedIndex;
		_selectedIndex = a_index;
		GameDelegate.call("RequestItemCardInfo", [], this, "updateItemInfo");
		_selectedIndex = oldIndex;
	}

	function setEntryText(a_entryClip:MovieClip, a_entryObject:Object)
	{
		if (_columnFormatter == undefined) {
			return;
		}
		
		var columns = currentView.columns;

		for (var i = 0; i < columns.length; i++) {
			var e = a_entryClip[_columnNames[i]];

			// Substitute @variables by entryObject properties
			if (_columnEntryValues[i] != undefined) {
				if (_columnEntryValues[i].charAt(0) == "@") {
					e.SetText(a_entryObject[_columnEntryValues[i].slice(1)]);
				}
			}
			
			// Process based on column type 
			switch (columns[i].type) {
				case Config.COL_TYPE_EQUIP_ICON :
					_columnFormatter.formatEquipIcon(e, a_entryObject);
					break;

				case Config.COL_TYPE_ITEM_ICON :
					_columnFormatter.formatItemIcon(e, a_entryObject);
					break;

				case Config.COL_TYPE_NAME :
					_columnFormatter.formatName(e, a_entryObject, a_entryClip);
					break;

				case Config.COL_TYPE_TEXT :
				default :
					_columnFormatter.formatText(e, a_entryObject);
			}
		}
	}
}