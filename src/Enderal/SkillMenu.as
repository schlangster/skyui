import skyui.components.list.ButtonList;
import skyui.components.list.BasicEnumeration;

class SkillMenu extends MovieClip
{
  /* PROPERTIES */
	
	public var classList: ButtonList;
	public var skillTree: SkillTreeView;
	public var infoHolder: MovieClip;
	
	
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
  
  	private function onLoad()
	{
		super.onLoad();
		
		classList.listEnumeration = new BasicEnumeration(classList.entryList);
		
		classList.addEventListener("itemPress", this, "onClassListPress");
		classList.addEventListener("selectionChange", this, "onClassListChange");
		
		skillTree.addEventListener("itemPress", this, "onSkillTreePress");
		skillTree.addEventListener("selectionChange", this, "onSkillTreeChange");
	}
	
	private function onDataLoaded(event: Object)
	{
		trace("Loaded");
		
		var data = event.data;
		
		skyui.util.Debug.dump("Parsed data", data);
		
		// It's useful when data entries know their own names
		for (var t in data.classes)
			data.classes[t].__name = t;
		for (var t in data.skills)
			data.skills[t].__name = t;
		
		var classNames: Array = data.skillMenu.classes;
		
		for (var i=0; i<classNames.length; i++) {
			var classData = data.classes[classNames[i]];
			classList.entryList.push(classData);
		}
		
		classList.InvalidateData();
		
		skillTree.skillData = data.skills;
		//skillTree.setRootSkill("mySkill1");
	}
	
	private function onClassListPress(a_event: Object): Void
	{
		selectClass(a_event.entry);
	}
	
	private function selectClass(a_classData): Void
	{
		skillTree.setRootSkill(a_classData.rootSkill);
	}
	
	private function onClassListChange(a_event: Object): Void
	{
		if (a_event.index != -1) {
			var classData = classList.selectedEntry;
			infoHolder.textField.SetText(classData.description);
			infoHolder.icon.gotoAndStop(classData.iconLabel);
		}
	}
	
	private function onSkillTreePress(a_event: Object): Void
	{
	}
	
	private function onSkillTreeChange(a_event: Object): Void
	{
		var skillData = a_event.data;
		infoHolder.textField.SetText(skillData.description);
		infoHolder.icon.gotoAndStop(skillData.iconLabel);
	}
}