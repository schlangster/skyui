class skyui.ScrollBar extends MovieClip
{
	private var _contentHeight:Number;
	private var _maxIndex:Number;
	private var _currentIndex:Number;	
	private var _entryCount:Number;
	private var _entrySize:Number;
	
	// Children
	var topCap:MovieClip;
	var bottomCap:MovieClip;
	var back:MovieClip;
	var fill:MovieClip;
	
	function ScrollBar()
	{
		
	}
	
	function setParameters(a_height:Number, a_entryCount:Number, a_currentIndex:Number, a_maxIndex:Number)
	{
		if (a_maxIndex <= 0 || a_height <= 0 || a_maxIndex <= 0) {
			return;
		}
		
		if (a_height != _contentHeight || a_maxIndex != _maxIndex) {
			bottomCap._y = a_height;
			back._height = (a_height - topCap._height * 2);
			_entrySize = back._height / a_maxIndex;
			fill._height = (a_entryCount / a_maxIndex) * back._height;
		}
		
		if (a_currentIndex != _currentIndex) {
			fill._y = topCap._height + (a_currentIndex / a_maxIndex) * back._height;
		}
		
		_contentHeight = a_height;
		_entryCount = a_entryCount;
		_maxIndex = a_maxIndex;
		_currentIndex = a_currentIndex;
	}
}