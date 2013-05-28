import skyui.components.dialog.BasicDialog;
import skyui.components.ButtonPanel;
import skyui.util.DialogManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.defines.Input;

import gfx.ui.NavigationCode;

import Shared.GlobalFunc;


class MessageDialog extends OptionDialog
{	
  /* PRIVATE VARIABLES */
  
	private var _updateButtonID: Number;

  	private var _acceptControls: Object;
  	private var _cancelControls: Object;
	
	private var _bWithCancel: Boolean = true;
	

  /* STAGE ELEMENTS */

	public var background: MovieClip;
	public var buttonPanel: ButtonPanel;
	
	public var textField: TextField;
	
	public var seperator: MovieClip;

	
  /* PROPERTIES */
  
	public var platform: Number;
	
	public var messageText: String;
	public var acceptLabel: String;
	public var cancelLabel: String;
	
	
  /* INITIALIZATION */
  
	public function MessageDialog()
	{
		super();
	}
	
	// @override MovieClip
	private function onLoad(): Void
	{
		buttonPanel.setPlatform(platform, false);
		
		_bWithCancel = (cancelLabel != "");
		
		initButtons();

		textField.wordWrap = true;
		messageText = Translator.translateNested(messageText);
		textField.SetText(GlobalFunctions.unescape(messageText));
		textField.verticalAutoSize = "top";
		
		positionElements();
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function initButtons(): Void
	{
		if (platform == 0) {
			_acceptControls = Input.Enter;
			_cancelControls = Input.Tab;
		} else {
			_acceptControls = Input.Accept;
			_cancelControls = Input.Cancel;
		}
		
		buttonPanel.clearButtons();
		
		if (_bWithCancel) {
			var cancelButton = buttonPanel.addButton({text: cancelLabel, controls: _cancelControls});
			cancelButton.addEventListener("press", this, "onCancelPress");
		}
		
		var acceptButton = buttonPanel.addButton({text: acceptLabel, controls: _acceptControls});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		buttonPanel.updateButtons();
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				if (_bWithCancel)
					onCancelPress();
				else
					onAcceptPress();					
				return true;
				
			} else if (details.navEquivalent == NavigationCode.ENTER) {
				onAcceptPress();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function onAcceptPress(): Void
	{
		skse.SendModEvent("SKICP_messageDialogClosed", null, 1);
		DialogManager.close();
	}
	
	private function onCancelPress(): Void
	{
		skse.SendModEvent("SKICP_messageDialogClosed", null, 0);
		DialogManager.close();
	}
	
	private function positionElements(): Void
	{
		var contentHeight = Math.max(75, textField.textHeight);
		background._height = contentHeight + 78;
		
		var yOffset = -(background._height / 2);
		seperator._y = yOffset + background._height - 50;
		buttonPanel._y = yOffset + background._height - 42;
		textField._y = yOffset + 14 + (contentHeight - textField.textHeight) / 2 ;
	}
}