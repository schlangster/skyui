########################################################################################################################################
	_______ _     _ __   __ _     _ _____
	|______ |____/    \_/   |     |   |  
	______| |    \_    |    |_____| __|__

########################################################################################################################################

Team:			snakster, Mardoxx, T3T

Contributors:	ianpatt, behippo, Kratos, psychosteve, MisterPete, GreatClone, gibbed, PurpleLunchBox, Gopher, Indie

Version:		3.0-alpha4

Download:		http://www.skyrimnexus.com/downloads/file.php?id=3863
				http://steamcommunity.com/sharedfiles/filedetails/?id=8122

Source code:	https://github.com/schlangster/skyui

########################################################################################################################################

The following mods/utilities are required for SkyUI:

* The Skyrim Script Extender (SKSE), version 1.6.5 or newer
	http://skse.silverlock.org/

########################################################################################################################################


	1. Introduction

	2. Changelog

	3. Installation

	4. Troubleshooting

	5. Modders Guide

	6. Credits & Acknowledgements
	
	7. Contact
	
	8. Permissions


########################################################################################################################################



========================================================================================================================================
 1. Introduction
========================================================================================================================================

SkyUI is mod that aims to improve Skyrim's User Interface by making it easier to use with mouse and keyboard,
less wasteful of available screen space and nicer to look at.

We do all that while keeping true to the style of the original UI, so new and old components are integrated seamlessly.
It is not our goal to re-create the complete interface from scratch.
Instead we try to identify and change areas that need improvement, while leaving the things that are already good alone.

Further general objectives and design concepts are:

* Finding a good balance between 'dumbed down' and 'information overkill'.

* Easy installation and setup by providing a user-friendly installer through the Nexus Mod Manager.

* Great customization support by using a seperate configuration file.

* Blending features in as good as possible - players shouldn't feel reminded that they're using a mod.


Since improving the whole UI is a big undertaking, we release only single menus at a time as we make progress.
The first menu we addressed was the Inventory. In version 2.0, we included new Barter, Container and Magic menus.

For a more detailed description, please see our mod description on Skyrim Nexus.


========================================================================================================================================
 2. Changelog
========================================================================================================================================

------------------------------------------------------------
3.0:
- TODO

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
- Fixed backspace canceling the search.
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
- Updated gibbed's interface extensions plugin to support the latest Skyrim version 1.3.10.0.
- Improved support for XBOX360 controller: LB/RB can now be used to change the active column, Left Stick changes the sorting order.
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

There are four ways to install SkyUI:
- Let the Nexus Mod Manager (NMM) download and install the archive for you.
- Download the archive manually and install it with NMM.
- Download and install the archive manually.
- Subscribe to SkyUI on Steam Workshop.

Pick whichever method you prefer.

------------------------------------------------------------
 a) Subscribe on Steam Workshop
------------------------------------------------------------

1. Go to http://steamcommunity.com/sharedfiles/filedetails/?id=8122 and click subscribe.

2. The next you start the Skyrim Launcher, SkyUI will be downloaded and installed automatically.

3. Done!

OR

------------------------------------------------------------
 b) Automatic Download with NMM
------------------------------------------------------------

1.	Click the 'Download with manager' button on top of the file.

2.	SkyUI will appear in in NMM's Mods list once it's downloaded. Double-click the SkyUI entry to activate it.

3.	Done!

OR

------------------------------------------------------------
 c) Manual Download with NMM
------------------------------------------------------------

1.	Start NMM and click on 'Mods'.

2.	In the left icon bar, click on 'Add Mod From File' and select the downloaded archive file.

3.	SkyUI will now appear in the list. Double-click the entry to activate it.

4.	Done!

OR

------------------------------------------------------------
 d) Manual Installation
------------------------------------------------------------

1.	Locate the 'Data/' folder in your Skyrim installation directory.
	Typically it's found at 'Program Files/Steam/steamapps/common/skyrim/Data/'.

2.	Extract the contents of the downloaded archive file to the 'Data/' folder.

3.	Done!


========================================================================================================================================
 4. Troubleshooting
========================================================================================================================================

------------------------------------------------------------
Problem: There's a message on my screen, telling me that I'm missing the Skyrim Script Extender (SKSE). What do I have to do?

Solution: There are two things that can cause this:
	1)	You didn't install the Skyrim Script Extender (or you installed it incorrectly).
		Get it from http://skse.silverlock.org/ and follow the included instructions.
		
	2)	Everything was fine before, then Skyrim was patched to a new version and the message started appearing.
		This is because each new patch also requires an update of SKSE. So just you'll just have to wait until that is released, then
		get the new version and everything should be back to normal.

------------------------------------------------------------
Problem: There are dollar signs ($) in front of all words in the main menu (and in lots of other places, too)!

Solution: This happens if you accidently removed 'Data/Interface/Translate_<language>.txt'. The downloaded SkyUI archive contains the
	original versions of these files in 'SkyUI Extras/Original Translates/'.
	So just copy the file matching your language from there back to 'Data/Interface/'.
		
------------------------------------------------------------
Problem: I changed something in skyui.cfg, now it's not working anymore.

Solution: If you made a mistake in the config, SkyUI may stop working. In this case, just revert back to the original config from the
	downloaded SkyUI archive.


========================================================================================================================================
 5. Modder's Guide
========================================================================================================================================

Since version 3.0 SkyUI provides several frameworks that can be utilized by other mods.

Currently those frameworks are
* the Mod Configuration Menu; and
* the HUD Widget Framework.

If you're interested in using them for you mod, have a look at the documentation:

	https://github.com/schlangster/skyui/wiki


========================================================================================================================================
 6. Credits & Acknowledgements
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
	Implemented many additional column types for improved sorting.

Psychosteve:
	Created our new primary icon theme for version 3.0.


SkyUI is utilizing TweenLite, a high-performance tweening library (http://www.greensock.com/tweenlite/).
	Thanks to Jack Doyle and his team for creating it and allowing us to use it under their “No Charge” license.

Thanks to all the testers, who helped a great deal with improving the overall quality of this mod:
	ToJKa, HellKnight, xporc, MadCat221, Ismelda, Gribbles, freesta, Cartrodus, TheCastle (in random order)

Last but not least, thanks to the whole SKSE team, because without their Script Extender creating this mod wouldn't have been possible.


========================================================================================================================================
 7. Contact
========================================================================================================================================

For direct contact, send a PM to schlangster at

	http://www.skyrimnexus.com/
		or
	http://forums.bethsoft.com/

If you need help, please leave a comment on our Nexus page instead of contacting me directly.

	
========================================================================================================================================
 8. Permissions
========================================================================================================================================	

Some assets in SkyUI belong to other authors.
You will need to seek permission from these authors before you can use their assets.

You are not allowed to upload this file to other sites unless given permission by me to do so.
You are not allowed to convert this file to work on other games.
 
You must get permission from me before you are allowed to modify my files for bug fixes and improvements.
You must get permission from me before you are allowed to use any of the assets in this file.
