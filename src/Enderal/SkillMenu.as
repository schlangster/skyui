import skyui.components.list.BasicEnumeration;

class SkillMenu extends MovieClip
{
  /* PROPERTIES */
	
	public var classGridList: ButtonGrid;
	public var skillTree: SkillTreeView;
	
	
  /* PRIVATE VARIABLES */
	
	private var _skillData: Object;
	
	
  /* INITIALIZATION */
	
	public function SkillMenu()
	{
		super();
		
		var loader = new DataLoader();
		
		loader.addEventListener("dataLoaded", this, "onDataLoaded");
		
		loader.loadFile("SkillMenuData.txt");
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function onDataLoaded(event: Object)
	{
		trace("Loaded");
		
		var data = event.data;
		
		skyui.util.Debug.dump("Parsed data", data);
		
		var classNames: Array = data.skillMenu.classes;
		var columnCount = data.skillMenu.columnCount;

		classGridList.listEnumeration = new BasicEnumeration(classGridList.entryList);
		classGridList.columnCount = data.skillMenu.columnCount;
		
		for (var i=0; i<classNames.length; i++) {
			var classData = data.classes[classNames[i]];
			classGridList.entryList.push(classData);
		}
		
		classGridList.InvalidateData();
		
		skillTree.skillData = data.skills;
		skillTree.setRootSkill("mySkill1");
	}
}