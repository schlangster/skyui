var srcDir = "file:///E:/skyui/src/"
var flaFiles = [
	"CraftingMenu/craftingmenu.fla",
	//"Enderal/SkillMenu.fla",
	"FavoritesMenu/favoritesmenu.fla",
	"HUDWidgets/activeeffects.fla",
	//"HUDWidgets/arrowcount.fla",
	//"HUDWidgets/meter.fla",
	//"HUDWidgets/minimap.fla",
	//"HUDWidgets/status.fla",
	//"HUDWidgets/statusicons.fla",
	"HUDWidgets/widgetloader.fla",
	"ItemMenus/bartermenu.fla",
	"ItemMenus/bottombar.fla",
	"ItemMenus/containermenu.fla",
	"ItemMenus/giftmenu.fla",
	"ItemMenus/inventorylists.fla",
	"ItemMenus/inventorymenu.fla",
	"ItemMenus/itemcard.fla",
	"ItemMenus/magicmenu.fla",
	"MapMenu/map.fla",
	//"MessageBox/messagebox.fla",
	"ModConfigPanel/configpanel.fla",
	"ModConfigPanel/mcm_splash.fla",
	"ModConfigPanel/skyui_splash.fla",
	//"ModConfigPanel/TextLoader.fla",
	"PauseMenu/quest_journal.fla",
	//"Resources/Assets/maskedtextarea.fla",
	//"Resources/Assets/meter.fla",
	//"Resources/Assets/scrollbar.fla",
	"Resources/buttonArt.fla",
	//"Resources/buttonArtSymbols.fla",
	//"Resources/fonts_en_snk.fla",
	//"Resources/gfxfontlib.fla",
	"Resources/icons_category_celtic.fla",
	"Resources/icons_category_curved.fla",
	"Resources/icons_category_psychosteve.fla",
	"Resources/icons_category_straight.fla",
	"Resources/icons_effect_psychosteve.fla",
	//"Resources/icons_item_celtic.fla",
	//"Resources/icons_item_curved.fla",
	"Resources/icons_item_psychosteve.fla",
	"Resources/mapMarkerArt.fla",
	//"Resources/skyui_icons.fla",
	//"Resources/skyui_icons_psychosteve.fla",
	//"Resources/skyui_icons_straight.fla",
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