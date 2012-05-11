class skyui.components.list.ColumnLayoutData
{
	public var type: Number = -1;

	// Entry  ---------------------------------
	
	// Position relative to the entry.
	public var x: Number = 0;
	public var y: Number = 0;
	
	public var width: Number = 0;
	public var height: Number = 0;
	
	// These are the names like textField0, equipIcon etc 
	public var stageName: String;
	
	// Only defined for text fields
	public var entryValue: String;
	public var textFormat: TextFormat;
	
	// Label ---------------------------------
	
	public var labelX: Number = 0;
	
	public var labelWidth: Number = 0;

	public var labelArrowDown: Boolean = false;

	public var labelValue: String;

	public var labelTextFormat: TextFormat;
	

	
	public function clear(): Void
	{
		type = -1;
		x = y = width = height = labelX = labelWidth = 0;
		stageName = entryValue = labelValue = null;
		textFormat = labelTextFormat = null;
		labelArrowDown = false;
	}
	
	public function dump()
	{
		skse.Log("x: " + x);
		skse.Log("y: " + y);
		skse.Log("width: " + width);
		skse.Log("height: " + height);
		skse.Log("stageName: " + stageName);
		skse.Log("entryValue: " + entryValue);
		
		skse.Log("labelX: " + labelX);
		skse.Log("labelWidth: " + labelWidth);
		skse.Log("labelValue: " + labelValue);
		skse.Log("labelArrowDown: " + labelArrowDown);
	}
}