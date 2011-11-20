class InvertedInventoryLists extends InventoryLists
{
    var strHideItemsCode, strShowItemsCode;
    function InvertedInventoryLists()
    {
        super();
        strHideItemsCode = gfx.ui.NavigationCode.RIGHT;
        strShowItemsCode = gfx.ui.NavigationCode.LEFT;
    } // End of the function
} // End of Class
