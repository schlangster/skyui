#!/usr/bin/perl -w

use File::Copy;

$skyrim_dir = "F:\\Spiele\\Steam\\steamapps\\common\\skyrim\\Data\\Interface";

@menus = (
	"bartermenu.swf",
	"containermenu.swf",
	"inventorymenu.swf",
	"magicmenu.swf",
	#"favoritesmenu.swf",
	"quest_journal.swf",
	"hudmenu.swf",
	"skyui\\inventorylists.swf",
	"skyui\\configpanel.swf",
	"skyui_slpash.swf",
	"widgets\\status.swf"
);

foreach (@menus) {
	print("Copying $_ to $skyrim_dir\\$_\n");
	copy($_, "$skyrim_dir\\$_");
}

getc(STDIN);