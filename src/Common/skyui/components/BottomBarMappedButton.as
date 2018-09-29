import skyui.components.MappedButton;
import skyui.util.GlobalFunctions;
import skyui.defines.Screen;

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
		//   ( center self with respect to the bottombar ) - (_y offset introduced by button panel)
		//
		// Also note that, sometimes, the bottombar may fall outside of the rendering area. Having
		// an oversized element like this makes design time tweaking a bit more straigtforward.
		// If we want to tweak the position at runtime, it means we can't just use the `bg` object
		// as a sizing reference directly. We need to figure out how much of the element is actually
		// visible and use that as the height of the bottombar.
		var targetHeight = textField._height;
		var bottombar = _parent._parent;
		var reference = bottombar.centerReference != undefined ? bottombar.centerReference : bottombar.bg;

		var referenceOrigin:Object = {x: 0, y:0};
		reference.localToGlobal(referenceOrigin);

		var visibleHeight = GlobalFunctions.clamp(referenceOrigin.y + reference._height, 0, Screen.height) - referenceOrigin.y;
		_y = ((visibleHeight - targetHeight) / 2) - _parent._y + reference._y;
	}
}
