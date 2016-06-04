### This section is for development versions only. Please use [addon manager](https://github.com/Excrulon/Tree-of-Savior-Addon-Manager) to install.


[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)  [![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges) 

These addons have not been officially approved but are not intrusive and can almost certainly be considered safe. See [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/3) and [here](https://forum.treeofsavior.com/t/stance-on-addons/141262/24) about IMC's stance on addons.

#### Cabinet Commas
Format the silver values for the item listings in the market "sell" and "retrieve" tabs with thousands separators (commas) for readability. 

[preview](https://i.imgur.com/0jnNGxx.png)

#### Classic Chat
Changes the chat to be more similar to a classic MMO chat frame. [preview](https://i.imgur.com/Z3GgKT7.png)

This addon requires Miei Utility to function.

Features:

- Different text colors for each chat channel.
- Colored item and recipe links based on rarity.
- Whisper notification sounds. (Disabled by default)
- Optional time stamps.
- Open links from chat in your browser.
- More

These settings can and should be customized in the following file after first launch:

`addons\miei\classicchat-settings.lua`

Hex Color codes are used.

Upon installing this addon, I would recommend that you readjust your [chat's transparency setting](https://i.imgur.com/WCevi1v.png) as the default background skin for the text frame will be replaced with a darker one to allow a greater range of transparency.

This addon will conflict with LKChat, they cannot be used together.

#### Fix Font Size Slider
Fix the font size slider in the chat options to dynamically update the font size in the chat frame.

#### Miei Utility
A utility file for common functions used in my other addons. 

This is a dependency for most of my other addons and should be installed along with them.

#### Now Playing
Add text above the chat window to show the currently playing BGM. [preview](https://i.imgur.com/tJGwNUr.png)

You can optionally enable this all of the time, enable it as a notification for a set duration once the BGM changes, or disable it altogether. See the top of the file to change these settings. The default setting is notification style with a 15 second duration.

Available slash commands:

- /np - Shows a chat message with the current bgm.
- /np [on/off] - Allows you to show or hide the text above the chat window
- /np chat [show/hide] - Enable/disable chat messages upon track change
- /np notify [on/off] - Enable/disable notification mode. Notification mode will show the text above the chat frame for a set duration when a new BGM plays, instead of showing this text constantly.
- /np help - Displays a help dialogue
 
/np can also be used as /music or /nowplaying.

These settings can and should be customized in the following file after first launch:

`addons\miei\nowplaying-settings.lua`

This addon requires Miei Utility. 

#### Remove FPS Counter
Hide the FPS counter.

Available slash commands:
- /fps - toggles the fps counter

This addon requires Miei Utility.

#### Remove Map Background
Remove the grey dimming background when the full map is opened. [preview](https://i.imgur.com/IfcOlo9.jpg)

#### Remove Pet Info
Hide pet names and/or HP bars.

Available slash commands, accessed with /companion or /comp:

- /comp -- Information about the addon.
- /comp name [on/off] - Show/hide your pet name. (Default: on)
- /comp hp [on/off] - Show/hide your pet HP. (Default: off)
- /comp other [on/off] - Show/hide other pet names. (Default: off)

These settings can and should be customized in the following file after first launch:

`addons\miei\removepetinfo-settings.lua`

This addon requires Miei Utility.

#### Remove TP Button
Hides the TP button next to the minimap and replaces it with the slash command "/tp".

This addon requires Miei Utility.

#### Toggle Duels
Allows you to toggle whether or not you will receive duel requests.

Available slash commands:

- /duels -- Quick toggle duels on/off.
- /duels [on/off] -- Set duel requests on/off. "On" means that you will be able to receive duel requests. (Default: on)
- /duels notify -- Toggle whether you will be notified in chat when a duel request is blocked, e.g. "Blocked duel request from Mie" (Default: on)
- /duels help -- Information about the addon.

By default, duels are set to "on", meaning you will recieve duel requests. It is set this way to prevent inconvenience in the case that somebody unwittingly installs the addon.

These settings can and should be customized in the following file after first launch:

`addons\miei\toggleduels-settings.lua`

This addon requires Miei Utility.
