class SkillMenu extends MovieClip
{
	public function SkillMenu()
	{
		super();
		
		var loader = new DataLoader();
		
		loader.addEventListener("dataLoaded", this, "onDataLoaded");
		
		loader.loadFile("SkillMenuData.txt");
	}
	
	public function onDataLoaded(event: Object)
	{
		trace("Loaded");
		
		var data = event.data;
		
		skyui.util.Debug.dump("Parsed data", data);
		
		var classNames: Array = data.skillMenu.classes;
		var columnCount = data.skillMenu.columnCount;
		var rowIndex = 0;
		
		for (var i=0; i<classNames.length; i++) {
			var classData = data.classes[classNames[i]];

			var t = this.attachMovie("ClassGridEntry", "entry" + i, this.getNextHighestDepth(), {_x: (i%columnCount)*200, _y: rowIndex*200});
			t.icon.gotoAndStop(classData.iconLabel);
			t.textField.text = classData.name;

			if (i % columnCount == (columnCount-1))
				++rowIndex
		}

	}
}