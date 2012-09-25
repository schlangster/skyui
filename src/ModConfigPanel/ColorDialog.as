import skyui.components.colorswatch.ColorSwatch;
import skyui.util.DialogManager;



class ColorDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
	

  /* STAGE ELEMENTS */
	
	public var colorSwatch: ColorSwatch;

	
  /* PROPERTIES */
	
	public var currentColor: Number;
	public var defaultColor: Number;
	
	
  /* INITIALIZATION */
  
	public function ColorDialog()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @override OptionDialog
	public function initContent(): Void {
		colorSwatch._x = -colorSwatch._width/2;
		colorSwatch._y = -colorSwatch._height/2;

		colorSwatch.selectedColor = currentColor;
  	}
	
	// @override OptionDialog
	public function onDefaultPress(): Void
	{
		colorSwatch.selectedColor = defaultColor;
	}
	
	// @override OptionDialog
	public function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_dialogCanceled");
		DialogManager.close();
	}

	// @override OptionDialog
	public function onConfirmPress(): Void
	{
		skse.SendModEvent("SKICP_colorAccepted", null, colorSwatch.selectedColor);
		DialogManager.close();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var bCaught = false;
		
		return bCaught;
	}
}