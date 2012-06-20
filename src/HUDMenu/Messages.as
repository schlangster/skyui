class Messages extends MovieClip
{
	static var MAX_SHOWN: Number = 4;
	static var Y_SPACING: Number = 15;
	static var END_ANIM_FRAME: Number = 80;
	static var InstanceCounter: Number = 0;
	var MessageArray: Array;
	var ShownCount: Number;
	var ShownMessageArray: Array;
	var bAnimating: Boolean;
	var ySpacing: Number;

	function Messages()
	{
		super();
		MessageArray = new Array();
		ShownMessageArray = new Array();
		ShownCount = 0;
		bAnimating = false;
	}

	function Update(): Void
	{
		var bqueuedMessage: Boolean = MessageArray.length > 0;
		if (bqueuedMessage && !bAnimating && ShownCount < Messages.MAX_SHOWN) {
			ShownMessageArray.push(attachMovie("MessageText", "Text" + Messages.InstanceCounter++, getNextHighestDepth(), {_x: 0, _y: 0}));
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.html = true;
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.textAutoSize = "shrink";
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.htmlText = MessageArray.shift();
			bAnimating = true;
			ySpacing = 0;
			onEnterFrame = function (): Void
			{
				if (ySpacing < Messages.Y_SPACING) {
					for (var i: Number = 0; i < ShownMessageArray.length - 1; i++) {
						ShownMessageArray[i]._y = ShownMessageArray[i]._y + 2;
					}
					++ySpacing;
					return;
				}
				bAnimating = false;
				if (!bqueuedMessage || ShownCount == Messages.MAX_SHOWN) 
					ShownMessageArray[0].gotoAndPlay("FadeOut");
				delete onEnterFrame;
			};
			++ShownCount;
		}
		for (var i: Number = 0; i < ShownMessageArray.length; i++) {
			if (ShownMessageArray[i]._currentFrame >= Messages.END_ANIM_FRAME) {
				var aShownMessageArray: Array = ShownMessageArray.splice(i, 1);
				aShownMessageArray[0].removeMovieClip();
				--ShownCount;
				bAnimating = false;
			}
		}
		if (!bqueuedMessage && !bAnimating && ShownMessageArray.length > 0) {
			bAnimating = true;
			ShownMessageArray[0].gotoAndPlay("FadeOut");
		}
	}

}
