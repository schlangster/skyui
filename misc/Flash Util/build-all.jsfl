var srcDir = "file:///E:/dev/skyui/src/"
var flaFiles = [
	"CraftingMenu/craftingmenu.fla",
	//"FavoritesMenu/favoritesmenu.fla",
	//"HUDWidgets/activeeffects.fla",
	//"HUDWidgets/widgetloader.fla",
	"ItemMenus/bartermenu.fla",
	"ItemMenus/bottombar.fla",
	"ItemMenus/containermenu.fla",
	"ItemMenus/giftmenu.fla",
	"ItemMenus/inventorylists.fla",
	"ItemMenus/inventorymenu.fla",
	"ItemMenus/itemcard.fla",
	"ItemMenus/magicmenu.fla",
	//"MapMenu/map.fla",
	"ModConfigPanel/configpanel.fla",
	//"ModConfigPanel/mcm_splash.fla",
	//"ModConfigPanel/skyui_splash.fla",
	"PauseMenu/quest_journal.fla",
	"Resources/buttonArt.fla",
	//"Resources/icons_category_celtic.fla",
	//"Resources/icons_category_curved.fla",
	//"Resources/icons_category_psychosteve.fla",
	//"Resources/icons_category_straight.fla",
	//"Resources/icons_effect_psychosteve.fla",
	//"Resources/icons_item_psychosteve.fla",
	//"Resources/mapMarkerArt.fla",
];

for(var i = 0; i < flaFiles.length; i++) {
	flaFiles[i] = srcDir + flaFiles[i];
}

// Starting a new compile session
// Clear out all errors
fl.compilerErrors.clear();
var logfile = "file:///E:/skyui/compile-error.txt";

function build(documentUri) {
	FLfile.remove(logfile);
	var doc = fl.openDocument(documentUri);
	doc.publish();
	fl.compilerErrors.save(logfile, true);
	if( FLfile.getSize(logfile) > 27 )
		throw "Compile error encountered!";
}

for(idx in flaFiles) {
	build(flaFiles[idx]);
}

FLfile.remove(logfile);
