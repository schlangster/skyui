import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import skyui.components.dialog.BasicDialog;
import skyui.components.ButtonPanel;


// @abstract
class OptionDialog extends BasicDialog
{	
  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var leftButtonPanel: ButtonPanel;
	public var rightButtonPanel: ButtonPanel;
	
	public var titleTextField: TextField;

	
  /* PROPERTIES */
  
	public var platform: Number;
	
	public var titleText: String;
	
	
  /* INITIALIZATION */
  
	public function OptionDialog()
	{
		super();
	}
	
	// @override MovieClip
	private function onLoad(): Void
	{
		leftButtonPanel.setPlatform(platform, false);
		rightButtonPanel.setPlatform(platform, false);
		
		initButtons();

		titleTextField.textAutoSize = "shrink";
		titleTextField.SetText(titleText.toUpperCase());
		
		initContent();
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @abstract
	public function initButtons(): Void {}
	
	// @abstract
	public function initContent(): Void {}
}