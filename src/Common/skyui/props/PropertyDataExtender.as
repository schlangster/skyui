import gfx.io.GameDelegate;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;
import skyui.props.PropertyLookup;
import skyui.props.CompoundProperty;

class skyui.props.PropertyDataExtender implements IListProcessor
{
  /* PRIVATE VARIABLES */
	
	private var _propertyList;
	private var _iconList;
	private var _compoundPropertyList;

	private var _noIconColors: Boolean;
	
	
  /* PROPERTIES */
  
	public var propertiesVar: String;
	public var iconsVar: String;
	public var compoundPropVar: String;
	
  /* CONSTRUCTORS */
	
	public function PropertyDataExtender(a_configAppearance: Object, a_dataSource: Object, a_propertiesVar: String, a_iconsVar: String, a_compoundPropVar: String)
	{
		propertiesVar = a_propertiesVar;
		iconsVar = a_iconsVar;
		compoundPropVar = a_compoundPropVar;
		
		_propertyList = new Array();
		_iconList = new Array();
		_compoundPropertyList = new Array();

		_noIconColors = a_configAppearance.icons.item.noColor;
		
		var propertyLevel = "props";
		var compoundLevel = "compoundProps";
		
		// Set up our arrays with information from the config for use in ProcessConfigVars()
		if (propertiesVar) {
			var configProperties = a_dataSource[propertiesVar];
			if (configProperties instanceof Array) {
				for (var i=0; i<configProperties.length; i++) {
					var propName = configProperties[i];
					var propertyData = a_dataSource[propertyLevel][propName];
					var propLookup = new PropertyLookup(propertyData);
					_propertyList.push(propLookup);
				}
			}
		}
		
		if (iconsVar) {
			var configIcons = a_dataSource[iconsVar];
			if (configIcons instanceof Array) {
				for (var i=0; i<configIcons.length; i++) {
					var propName = configIcons[i];
					var propertyData = a_dataSource[propertyLevel][propName];
					var propLookup = new PropertyLookup(propertyData);
					_iconList.push(propLookup);
				}
			}
		}

		if (compoundPropVar) {
			var configCompoundList = a_dataSource[compoundPropVar];
			if (configCompoundList instanceof Array) {
				for (var i=0; i<configCompoundList.length; i++) {
					var propName = configCompoundList[i];
					var propertyData = a_dataSource[compoundLevel][propName];
					var compoundProperty = new CompoundProperty(propertyData);
					_compoundPropertyList.push(compoundProperty);
				}
			}
		}
	}
	
	
  /* PUBLIC FUNCTIONS */
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i=0; i<entryList.length; i++)
			processEntry(entryList[i]);
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function processEntry(a_entryObject: Object): Void
	{
		// Use the information from the arrays from the config to fill in additional info
		
		// Set properties based on other dataMembers and keywords
		// as defined in the config
		for (var i=0; i<_propertyList.length; i++)
			_propertyList[i].processProperty(a_entryObject);

		// Set iconLabel, iconColor etc (run this even if skse not used)
		for (var i=0; i<_iconList.length; i++)
			_iconList[i].processProperty(a_entryObject);
			
		// Process compound properties 
		// (concatenate several properties together, used for sorting)
		for (var i=0; i<_compoundPropertyList.length; i++)
			_compoundPropertyList[i].processCompoundProperty(a_entryObject);	

		if (_noIconColors && a_entryObject.iconColor != undefined)
			delete(a_entryObject.iconColor)
	}
}