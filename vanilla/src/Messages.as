class Messages extends MovieClip
{
	static var MAX_SHOWN = 4;
	static var Y_SPACING = 15;
	static var END_ANIM_FRAME = 80;
	static var InstanceCounter = 0;
	
	var MessageArray:Array;
	var ShownMessageArray:Array;
	var ShownCount;
	var bAnimating;
	var getNextHighestDepth;
	var ySpacing;
	
	function Messages()
	{
		super();
		MessageArray = new Array();
		ShownMessageArray = new Array();
		ShownCount = 0;
		bAnimating = false;
	}
	
	function Update()
	{
		var bqueuedMessage = MessageArray.length > 0;
		if (bqueuedMessage && !bAnimating && ShownCount < Messages.MAX_SHOWN)
		{
			InstanceCounter = ++Messages.InstanceCounter;
			ShownMessageArray.push(attachMovie("MessageText", "Text" + Messages.InstanceCounter, getNextHighestDepth(), {_x: 0, _y: 0}));
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.html = true;
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.textAutoSize = "shrink";
			ShownMessageArray[ShownMessageArray.length - 1].TextFieldClip.tf1.htmlText = MessageArray.shift();
			bAnimating = true;
			ySpacing = 0;
			
			this.onEnterFrame = function()
			{
				if (ySpacing < Messages.Y_SPACING)
				{
					for (var _loc2 = 0; _loc2 < ShownMessageArray.length - 1; ++_loc2)
					{
						ShownMessageArray[_loc2]._y = ShownMessageArray[_loc2]._y + 2;
					}
					++ySpacing;
				}
				else
				{
					bAnimating = false;
					if (!bqueuedMessage || ShownCount == Messages.MAX_SHOWN)
					{
						ShownMessageArray[0].gotoAndPlay("FadeOut");
					}
					delete onEnterFrame;
				}
			}
			++ShownCount;
		}
		
		for (var _loc2 = 0; _loc2 < ShownMessageArray.length; ++_loc2)
		{
			if (ShownMessageArray[_loc2]._currentFrame >= Messages.END_ANIM_FRAME)
			{
				var _loc3 = ShownMessageArray.splice(_loc2, 1);
				_loc3[0].removeMovieClip();
				--ShownCount;
				bAnimating = false;
			}
		}
		
		if (!bqueuedMessage && !bAnimating && ShownMessageArray.length > 0)
		{
			bAnimating = true;
			ShownMessageArray[0].gotoAndPlay("FadeOut");
		}
	}
}
