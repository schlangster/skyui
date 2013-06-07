import gfx.controls.ScrollBar;

class MultiColumnScrollBar extends ScrollBar
{
	private var _scrollDelta = 1;
	private var _trackScrollPageSize = 1;

	public function MultiColumnScrollBar()
	{
		super();
	}

	public function get trackScrollPageSize(): Number { return _trackScrollPageSize; }
	public function set trackScrollPageSize(a_val: Number): Void
	{
		_trackScrollPageSize = Math.ceil(a_val / _scrollDelta) * _scrollDelta;
	}

	public function get scrollDelta(): Number { return _scrollDelta; }
	public function set scrollDelta(a_val: Number): Void
	{
		_scrollDelta = a_val;
		_trackScrollPageSize = Math.ceil(_trackScrollPageSize / a_val) * a_val;
	}

	public function get position(): Number	{ return _position; }
	public function set position(a_val: Number): Void
	{
		a_val -= (a_val % _scrollDelta);
		super.position = a_val;
	}

	private function scrollWheel(a_delta: Number): Void
	{
		position -= (a_delta * _trackScrollPageSize);
	}

	private function scrollUp(): Void
	{
		position -= _scrollDelta;
	}
	
	private function scrollDown(): Void
	{
		position += _scrollDelta;
	}

}