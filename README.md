SkyUI - VR
----------

This repository hosts the source and the packaged releases for a working
version of SkyUI (and MCM) for SkyrimVR.

### Getting SkyUI

To get the mod, head on over to 
[the release page](https://github.com/Odie/skyui-vr/releases/) and grab the
lastest version. All you need is the .7z file. (Ignore the source code download
links.)

### Prerequsite
Make sure [SKSE VR](http://skse.silverlock.org/) is installed. (Don't forget
the .pex files!)

### Installation

For MO2 users, use the "Install from file" icon in the toolbar.

For Vortex users, drop the .7z file over the vortex window.


VR specific controls
--------------------

Currently, there are certain limitations to how the UIs in the game can process
inputs from the VR controllers. At the moment, the UI seems to mostly receive
up/down/right/left signals from the game. This makes operating a more complex
UI like SkyUI a little difficult, but not impossible.

Here's what you need to know.

### Toggle trade direction
In the barter menu or the gift menu, keep hitting "left" until you've reached
the first item on the category list (titled "All"). Hit "left" again and the 
trade direction should toggle.

### Sorting items
This applies to any screen where you can see an inventory list. With the first 
item in the list selected (or nothing selected), hit "up" once to move the 
sorted column to the next one. Hit "up" twice in quick succession to change the 
sort direction.

For trackpad users, trying using "slow swipe" and "fast swipe" to differentiate 
between these two actions. The number of controller vibrations indicates how many 
"up" events the game has registered.
