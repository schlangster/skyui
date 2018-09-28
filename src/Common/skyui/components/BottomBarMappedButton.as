import skyui.components.MappedButton;

// Specialized version of a MappedButton for the BottomBar
// We vertically center the button after the button is updated.
// Note that we're assuming information regarding the bottombar
// layout and where mapped buttons would be.
//
// This is not suitable for general use in other layouts.
class skyui.components.BottomBarMappedButton extends MappedButton
{
	public function update(): Void
	{
		super.update();

		// Position this button so it's centered in the bottombar
		// We're assuming the following display tree:
		// bottom bar
		//  |- bg
		//  |- button panel
		//      |- Mapped Button
		//
		// Note that the bg provides a stable/static dimension for the bottombar.
		// Since we're tweaking the layout of the bottombar programmatically, it's not a good
		// idea to perform the calculation with respect to the dynamic size of the bottombar since
		// might change if the button or text size were to ever exceed the static height of the
		// bottombar, then the layout calculation would be thrown off from that point on.
		//
		// To center the ourselves to the bottom bar, we need to:
		//   ( center self with respect to the bottombar  ) - (_y offset introduced by button panel)
		var targetHeight = textField._height;
		_y = ((_parent._parent.bg._height - targetHeight) / 2) - _parent._y;
	}
}
