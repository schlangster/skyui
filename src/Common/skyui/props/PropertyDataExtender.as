import gfx.io.GameDelegate;

import skyui.components.list.BasicList;
import skyui.components.list.IListProcessor;
import skyui.props.PropertyLookup;
import skyui.props.CompoundProperty;
import skyui.util.ConfigManager;
import skyui.util.Translator;

class skyui.props.PropertyDataExtender implements IListProcessor
{
  /* PRIVATE VARIABLES */
	
	// Config information
	private var _propertyList;
	private var _iconList;
	private var _compoundPropertyList;
	private var _translateProperties;
	
	
  /* PROPERTIES */
  
	public var propertiesVar: String;
	public var iconsVar: String;
	public var compoundPropVar: String;
	public var translatePropVar: String;
	
  /* CONSTRUCTORS */
	
	public function PropertyDataExtender(a_list: BasicList, a_propertiesVar: String, a_iconsVar: String, a_compoundPropVar: String, a_translatePropVar: String)
	{
		propertiesVar = a_propertiesVar;
		iconsVar = a_iconsVar;
		compoundPropVar = a_compoundPropVar;
		translatePropVar = a_translatePropVar;
		
		_propertyList = new Array();
		_iconList = new Array();
		_compoundPropertyList = new Array();
		_translateProperties = new Array();
		
		ConfigManager.registerLoadCallback(this, "onConfigLoad");
	}
	
	
  /* PUBLIC FUNCTIONS */
  
	public function onConfigLoad(event)
	{
		var sectionData = event.config["Properties"];
		var propertyLevel = "props";
		var compoundLevel = "compoundProps";

		// Set up our arrays with information from the config for use in ProcessConfigVars()
		
		if (propertiesVar) {
			var configProperties = sectionData[propertiesVar];
			if (configProperties instanceof Array) {
				for (var i=0; i<configProperties.length; i++) {
					var propName = configProperties[i];
					var propertyData = sectionData[propertyLevel][propName];
					var propLookup = new PropertyLookup(propertyData);
					_propertyList.push(propLookup);
				}
			}
		}
		
		if (iconsVar) {
			var configIcons = sectionData[iconsVar];
			if (configIcons instanceof Array) {
				for (var i=0; i<configIcons.length; i++) {
					var propName = configIcons[i];
					var propertyData = sectionData[propertyLevel][propName];
					var propLookup = new PropertyLookup(propertyData);
					_iconList.push(propLookup);
				}
			}
		}

		if (compoundPropVar) {
			var configCompoundList = sectionData[compoundPropVar];
			if (configCompoundList instanceof Array) {
				for (var i=0; i<configCompoundList.length; i++) {
					var propName = configCompoundList[i];
					var propertyData = sectionData[compoundLevel][propName];
					var compoundProperty = new CompoundProperty(propertyData);
					_compoundPropertyList.push(compoundProperty);
				}
			}
		}
		
		if (translatePropVar)
			if (sectionData[translatePropVar] instanceof Array)
				_translateProperties = sectionData[translatePropVar];
	}
	
  	// @override IListProcessor
	public function processList(a_list: BasicList): Void
	{
		var entryList = a_list.entryList;
		
		for (var i=0; i<entryList.length; i++) {
			if (entryList[i].skyui_propertyDataExtended)
				continue;
			entryList[i].skyui_propertyDataExtended = true;
			processEntry(entryList[i]);
		}
	}
	
	public function processEntry(a_entryObject: Object): Void
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
		
		// Translate any properties that require it
		for (var i=0; i<_translateProperties.length; i++) {
			var prop = _translateProperties[i];
			if (a_entryObject[prop] != undefined && a_entryObject[prop].constructor == String)
				a_entryObject[prop] = Translator.translate(a_entryObject[prop]);
		}		
	}
}