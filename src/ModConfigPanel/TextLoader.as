import gfx.core.UIComponent;
import gfx.utils.Constraints;
import gfx.controls.ScrollBar;

import skyui.util.MarkupParser;
import skyui.components.MaskedTextArea;

import TextField.StyleSheet;

class TextLoader extends UIComponent
{
  /* PRIVATE VARIABLES */
	private var _constraints: Constraints;
	private var _markup: Object;

  /* STAGE ELEMENTS */
	public var titleText: TextField;
	public var maskedTextArea: MaskedTextArea;
	public var scrollBar: ScrollBar;

  /* INITIALIZATION */
	function TextLoader()
	{
		super();
	}

	public function configUI(): Void
	{
		super.configUI();

		MarkupParser.registerParseCallback(this, "onDataParsed");

		_constraints = new Constraints(this, false);
		_constraints.addElement(maskedTextArea, Constraints.ALL);
		_constraints.addElement(scrollBar, Constraints.TOP | Constraints.BOTTOM | Constraints.RIGHT);

		maskedTextArea.scrollBar = scrollBar;
		maskedTextArea.scrollBarAutoHide = false;
		maskedTextArea.styleSheet = MarkupParser.styleSheet;

		maskedTextArea.addEventListener("changeSection", this, "onChangeSection")
	}

  /* PRIVATE FUNCTIONS */
	private function draw(): Void
	{
		super.draw();

		if (_constraints != undefined)
			_constraints.update(_width, _height);

		load("demoText.txt");
	}

	private function onDataParsed(a_event: Object): Void
	{
		_markup = a_event.markup;
		maskedTextArea.htmlText = _markup["main"].htmlText;
	}

	private function onChangeSection(a_event: Object): Void
	{
		var newSection: Object = _markup[a_event.args[0].toLowerCase()];
		if (newSection != undefined)
			maskedTextArea.htmlText = newSection.htmlText;
	}

	/* PUBLIC FUNCTIONS */

	public function load(a_path): Boolean
	{
		return MarkupParser.load(a_path);
	}
}


