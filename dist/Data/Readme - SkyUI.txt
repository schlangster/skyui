########################################################################################################################################
	_______ _     _ __   __ _     _ _____
	|______ |____/    \_/   |     |   |  
	______| |    \_    |    |_____| __|__

########################################################################################################################################

Team:			snakster, Mardoxx, T3T

Contributors:	ianpatt, behippo, Kratos, psychosteve, MisterPete, GreatClone, gibbed, PurpleLunchBox, Gopher, Indie

Version:		3.1

Download:		http://www.skyrimnexus.com/downloads/file.php?id=3863
				http://steamcommunity.com/sharedfiles/filedetails/?id=8122

Source code:	https://github.com/schlangster/skyui

########################################################################################################################################

The following mods/utilities are required for SkyUI:

* The Skyrim Script Extender (SKSE), version 1.6.6 or newer
	http://skse.silverlock.org/

########################################################################################################################################


	1. Introduction

	2. Changelog

	3. Installation

	4. Uninstallation

	5. Troubleshooting

	6. Mod Author Guide

	7. Credits & Acknowledgements
	
	8. Contact
	
	9. Permissions


########################################################################################################################################



========================================================================================================================================
 1. Introduction
========================================================================================================================================

SkyUI is a mod that aims to improve Skyrim's User Interface by making it easier to use with mouse and keyboard,
less wasteful of available screen space, and nicer to look at.

We do all that while keeping true to the style of the original UI, so new and old components are integrated seamlessly.
It is not our goal to re-create the complete interface from scratch.
Instead we try to identify and change areas that need improvement, while leaving the things that are already good alone.

Further general objectives and design concepts are:

* Finding a good balance between 'dumbed down' and 'information overkill'.

* Easy installation and setup by providing a user-friendly installer through the Nexus Mod Manager.

* Great customization support by using a separate configuration file.

* Blending features in as well as possible - players shouldn't feel reminded that they're using a mod.


Since improving the whole UI is a big undertaking, we only release single menus at a time as progress is made.
The first menu we addressed was the Inventory. In version 2.0, we included new Barter, Container and Magic menus.
Version 3.0 introduced an in-game configuration menu for mods.

For a more detailed description, please see our mod description on Skyrim Nexus.


========================================================================================================================================
 2. Changelog
========================================================================================================================================

------------------------------------------------------------
3.1:

TODO

------------------------------------------------------------
3.0:

NOTE: When upgrading from previous versions, make sure to uninstall them first!

[General]
- Added more columns to item lists and a drop-down menu to show/hide them.
- Added a new icon theme by Psychosteve (support for the old themes had to be dropped because they are no longer maintained).
- Added type column to group items of the same category into sub-types.
- Added dynamic icon coloring.
- Added option to configure the minimum stack size that triggers the quantity select dialog.
- Added dynamic icon art to bottom bar so it matches the current control mapping.
- Replaced NMM installer with an in-game configuration menu.
- Replaced old error messages with regular message boxes and added more safety checks for outdated SkyUI components.
- Fixed various minor issues and improved performance.
- Consolidated package format to BSA+ESP.

[ContainerMenu]
- Added support for GiftMenu.
- Improved input scheme for mouse and keyboard (no more R to Take All and Store, mouse click for Give/Take etc.).

[BarterMenu]
- Added carry weight display to bottom bar.

[MagicMenu]
- Fixed locked words being shown as unlocked if one word is known.
- Fixed an issue that could cause crashes for spells with missing effect data.

[ModConfigurationMenu]
- Initial release. Mod authors, see https://github.com/schlangster/skyui/wiki for documentation.

------------------------------------------------------------
2.1:

[General]
- Added compatiblity for the Skyrim version 1.4.21.
- Added multi-language support for Czech, English, French, German, Italian, Polish, Russian and Spanish.
- Added several options to the installer (font size, separate V/W column, special resolution).
- Added a BAIN Conversion File (BCF) including an installation wizard for better Wyre Bash support. Thanks to Lojack!
- Fixed a bug where selling/dropping/storing stacked items could cause the selected entry to jump to the bottom of the list.
- The last selected category, entry and scroll position are now saved and restored when re-opening the inventory/magic menu.
- Sorting parameters are now preserved if possible when switching through categories.
- Improved the SKSE version check so it will also display a warning when using outdated versions.
- Most features of our SKSE plugins have been reworked and are now integrated in SKSE itself.
- Various other tweaks and minor fixes.

[InventoryMenu]
- Fixed a rare bug that could cause crashes after recharging an item.

[MagicMenu]
- Fixed skill level sorting.
- Added 'Favorite' as a sort option.

[ContainerMenu]
- Fixed stealing text for Russian game version.
- Fixed overlapping of to steal/to place text for large itemcards.

------------------------------------------------------------
2.0:

[InventoryMenu]
- Fixed enchantment mini-icon so it's no longer displayed for enchanted weapons only.
- Fixed missing sort options for name field in the favorites category.
- Fixed backspace cancelling the search.
- Fixed searching for non-English languages (i.e. Russian).
- Improved sorting system. Null/invalid values are now always at the bottom.
- Empty categories are greyed out and no longer selectable by mouse or during keyboard/controller navigation.
- Included a bundled version of Gibbed's Container Categorization SKSE plugin. Thanks for giving us permission to use it!

[MagicMenu]
- Initial release

[BarterMenu]
- Initial release

[ContainerMenu]
- Initial release

------------------------------------------------------------
1.1:

[InventoryMenu]
- Updated Gibbed's interface extensions plugin to support the latest Skyrim version 1.3.10.0.
- Improved support for XBOX360 controller: LB/RB can now be used to change the active column; Left Stick changes the sorting order.
- Made SKSE warning message less intrusive; it's only shown once after each game restart now.
- Fixed LT/RT equip bug with XBOX360 controller.
- Fixed bug where 3D model/item card would not update in certain situations (dropping an item, charging an item, etc.).
- Removed custom fontconfig.txt to avoid font problems with other font mods, or with the Russian version of the game.
- Optimized column layout so it only shows states and information that make sense for the active category.
- Updated T3T's straight icon theme to include new inventory icons.
- Updated GreatClone's icon theme to the latest version. Now includes inventory icons as well, and category icons have been improved.
- Fixed wrong inventory icon for spell tomes.
- Various minor tweaks and fixes.

------------------------------------------------------------
1.0:

[InventoryMenu]
- Initial release


========================================================================================================================================
 3. Installation
========================================================================================================================================

------------------------------------------------------------
IMPORTANT:
If you were using older versions of SkyUI (this includes 3.0 alpha builds),
you MUST remove them before installing the new one.
See section 4 for instructions.
------------------------------------------------------------

There are several ways to install SkyUI:
- Subscribe to SkyUI on Steam Workshop.
- Let the Nexus Mod Manager (NMM) download and install the archive for you.
- Download the archive manually and install it with NMM.
- Download and install the archive manually.

Pick the method you prefer.

------------------------------------------------------------
 a) Subscribe on Steam Workshop
------------------------------------------------------------

1. Go to http://steamcommunity.com/sharedfiles/filedetails/?id=8122 and click subscribe.

2. The next time you start the Skyrim Launcher, SkyUI will be downloaded and installed automatically.

OR

------------------------------------------------------------
 b) Automated Download with NMM
------------------------------------------------------------

1.	Click the 'Download with manager' button on top of the file.

2.	SkyUI will appear in in NMM's Mods list once it's downloaded. Double-click the SkyUI entry to activate it.

OR

------------------------------------------------------------
 c) Manual Download with NMM
------------------------------------------------------------

1.	Start NMM and click on 'Mods'.

2.	In the left icon bar, click on 'Add Mod From File' and select the downloaded archive file.

3.	SkyUI will now appear in the list. Double-click the entry to activate it.

OR

------------------------------------------------------------
 d) Manual Installation
------------------------------------------------------------

1.	Locate the 'Data/' folder in your Skyrim installation directory.
	Typically it's found at 'Program Files/Steam/steamapps/common/skyrim/Data/'.

2.	Extract the contents of the downloaded archive file to the 'Data/' folder.

3.	In the Skyrim Launcher, select 'Data Files' and enable 'SkyUI.esp'.


========================================================================================================================================
 4. Uninstallation
========================================================================================================================================

Before removing any files, it is recommended to make a 'clean' save game with SkyUI deactivated.
(Note that when uninstalling versions 2.2 or older, this is NOT necessary)

1.	Start the Skyrim Launcher and select 'Data Files'.

2.	Search 'SkyUI.esp' and uncheck it.
	(If you don't have this file, there's no need for a clean save anyway and you can skip it)

3.	In-game, load your latest save, then save the game again.

4.	This new save game is now cleaned of SkyUI data.

------------------------------------------------------------

You can now proceed to uninstall the files.

The uninstallation method depends on which SkyUI version you were using before and how you installed it.
Any SkyUI version older than 3.0 (this includes alpha builds) has to be removed before upgrading.

For details, see the following instructions that match your current SkyUI version/installation method.

------------------------------------------------------------
 NMM installation / Any SkyUI version
------------------------------------------------------------

In NMM's mod list, search for the SkyUI entry and deactivate the mod.

------------------------------------------------------------
 Steam workshop / Any SkyUI version
------------------------------------------------------------

Unsubscribe from the mod and deactivate it in Skyrim Launcher (if you haven't already).
There, you can also completely remove it by highlighting it and pressing 'Delete Selected'.

------------------------------------------------------------
 Manual installation / SkyUI 2.2 or older
------------------------------------------------------------

If you installed the SkyUI files manually, then you also have to remove them manually.
So view the contents of the SkyUI archive you are using, locate each file at its install location and remove it.

To revert your interface folder to its original state, you can delete the 'Interface/' directory from Skyrim's 'Data/' folder
and then use Steam to restore any original files you removed in the process by following these steps:
(Backup your interface folder before deleting it in case anything goes wrong)
	1. Locate Skyrim in Steam's game library.
	2. Open the properties dialog and select the 'Local files' tab.
	3. Verify integrity of game cache.
Be aware, that this will break any other mods that installed files to the interface folder. You will have to re-install them.

------------------------------------------------------------
 Manual installation / SkyUI 3.0 alpha versions
------------------------------------------------------------

The 3.0 alpha packages contained loose script files required by mod authors to create configuration menus.
You have to remove these files because they will override any newer scripts in SkyUI.bsa.

1.	Locate the 'Scripts/' folder in your Skyrim data directory.
	It's typically found at 'Program Files/Steam/steamapps/common/skyrim/Data/Scripts/'.

2.	Delete any script files (.pex) that start with SKI_, for example
		SKI_ConfigBase.pex, SKI_Main.pex, etc.

3.	Delete 'SkyUI.esp' and 'SkyUI.bsa' from the data folder.

------------------------------------------------------------
 Manual installation / SkyUI 3.0 and newer
------------------------------------------------------------

1.	Locate the 'Data/' folder in your Skyrim installation directory.
	It's typically found at 'Program Files/Steam/steamapps/common/skyrim/Data/'.

2.	Delete 'SkyUI.esp' and 'SkyUI.bsa' from the data folder.


========================================================================================================================================
 5. Troubleshooting
========================================================================================================================================

------------------------------------------------------------
Problem: There's an error message telling me about a problem with the Skyrim Script Extender (SKSE).

Solution: There are two things that can cause this:
	1)	You didn't install the Skyrim Script Extender (or you installed it incorrectly).
		Get it from http://skse.silverlock.org/ and follow the included instructions.
		
	2)	Everything was fine before, then Skyrim was patched to a new version and the message started appearing.
		This is because each new patch also requires an update of SKSE. So just you'll just have to wait until that is released, then
		get the new version and everything should be back to normal.

	If you have problems installing or running SKSE, have a look at Gopher's video guide:
		http://www.youtube.com/watch?v=xTGnQIiNVqA

------------------------------------------------------------
Problem: There's an error message telling me about a problem with some outdated/incompatible menu (SWF) file.

Solution: There are several reasons this might happen.
	1)	You didn't uninstall an old version of SkyUI before upgrading to 3.0 or newer.
		See the Uninstallation section and make sure you really removed everything, and then install the new version again.

	2)	There's another mod that overrides a particular menu file SkyUI is using as well.
		If this is the case, you'll have to pick one of the two mods.

	If you want another mod to be able to override certain menu files of SkyUI while keeping the rest, you can disable these
	warning messages individually in the SkyUI configuration menu ('Advanced' page).

------------------------------------------------------------
Problem: There are dollar signs ($) in front of all words in the main menu (and in lots of other places, too)!

Solution: This happens if you accidently removed 'Data/Interface/Translate_<language>.txt'.
	To restore it, use Steam to verify the integrity of Skyrim's game-cache
	(Steam -> Library -> Properties of Skyrim -> Local files tab -> Verify integrity of game cache).

------------------------------------------------------------
Problem: My game crashes after I uninstalled SkyUI.

Solution: Try making a clean save with SkyUI.esp deactivated instead of removing it completely.
	The necessary steps are described at the beginning of section 4.

------------------------------------------------------------
Problem: Some gamepad buttons are not working in the menu.

Solution: There's a known problem when using a custom controlmap.
	The following functions must be mapped to only one key: Wait, Sprint, Shout, and Sneak.

	If that's not the case, uninstall whichever mod that changed it.
	Alternatively, delete the 'Data/Interface/controls/' folder and 'Data/Interface/controlmap_custom.txt' to reset your controlmap.


If your problem wasn't listed here, ask for help in the Nexus comments.


========================================================================================================================================
 6. Mod Author Guide
========================================================================================================================================

Since version 3.0, SkyUI provides a Mod Configuration Menu framework that can be utilized by other mods.
If you're a mod author interested in using it, have a look at the documentation:

	https://github.com/schlangster/skyui/wiki


========================================================================================================================================
 7. Credits & Acknowledgements
========================================================================================================================================

Besides the SkyUI team itself, there are other people as well who helped significantly to make this mod a reality.
In the following they are listed by name, including a list of their contributions.

Kratos:
	Was a core member of the SkyUI team until version 2.1 and as such contributed significantly to the project in various areas.

ianpatt:
	Added lots of new functions to the Skyrim Script Extender, that greatly helped us during development and enabled new features that
	would otherwise be impossible.

behippo:
	Helped improving/advancing the interface extensions plugin by decoding the game classes and giving us access to them through SKSE.

Gibbed:
	Created the 'gibbed interface extensions' SKSE plugin, which makes more game data available for display in the inventory.
	Also allowed us to bundle his container categorization plugin. As of version 2.1, both these plugins have been included in SKSE
	itself.

Indie:
	Created our trailer and helps with QA and user support.

GreatClone:
	Created an amazing set of alternative category icons.

Gopher:
	Did most of the work on the NMM installer, created an installation tutorial video and promoted SkyUI on his YouTube channel.

Lojack:
	Created a BCF (including an installation wizard) for SkyUI to improve the installation experience for Wyre Bash users.
	Also added an auto-conversion feature to Wyre Bash itself so this BCF is automatically applied.

Ismelda:
	Provided configs for very high resolutions used with multi-monitor setups.

Wakeupbrandon:
	His mock-up inspired the overall layout of the new inventory.

MisterPete:
	Implemented new column types for improved sorting.

Psychosteve:
	Created our new primary icon theme for version 3.0.

Pelinor:
	The creator of MCM for Fallout: New Vegas. Allowed us to use his original logo.


SkyUI is utilizing TweenLite, a high-performance tweening library (http://www.greensock.com/tweenlite/).
	Thanks to Jack Doyle and his team for creating it and allowing us to use it under their “No Charge” license.

Thanks to all the testers, who helped a great deal with improving the overall quality of this mod:
	ToJKa, HellKnight, xporc, MadCat221, Ismelda, Gribbles, freesta, Cartrodus, TheCastle (in random order)

Last but not least, thanks to the whole SKSE team, because without their Script Extender creating this mod wouldn't have been possible.


========================================================================================================================================
 8. Contact
========================================================================================================================================

For direct contact, send a PM to schlangster at

	http://www.skyrimnexus.com/
		or
	http://forums.bethsoft.com/

If you need help, please leave a comment on our Nexus page instead of contacting me directly.

	
========================================================================================================================================
 9. Permissions
========================================================================================================================================	

Some assets in SkyUI belong to other authors.
You will need to seek permission from these authors before you can use their assets.

You are not allowed to upload this file to other sites unless given permission by me to do so.
You are not allowed to convert this file to work on other games.
 
You must get permission from me before you are allowed to modify my files for bug fixes and improvements.
You must get permission from me before you are allowed to use any of the assets in this file.
