### This section is for development versions only. Please use [addon manager](https://github.com/Excrulon/Tree-of-Savior-Addon-Manager) to install.

[![Addon Safe](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-safe.svg)](https://github.com/lubien/awesome-tos#addons-badges)  [![Addon Status Unknown](https://cdn.rawgit.com/lubien/awesome-tos/master/badges/addon-unknown.svg)](https://github.com/lubien/awesome-tos#addons-badges) 

These addons have not been officially approved but are not intrusive and can almost certainly be considered safe. See [here](https://treeofsavior.com/news/?n=467) about IMC's stance on addons.

```
5. Could you let us know which add-ons are allowed and which aren’t? 

We have no plans on restricting add-ons that conveniently display information which can be obtained from external communities or between users.

However, we are sternly against add-ons that allow abnormal gameplay such as being able to use NPC stores on a field or an auto-play program. Those are prohibited and its user is liable to be banned. 
```

#### Cabinet Commas
Format the silver values for the item listings in the market "sell" and "retrieve" tabs with thousands separators (commas) for readability. 

[preview](https://i.imgur.com/0jnNGxx.png)

#### Classic Chat
Changes the chat to be more similar to a classic MMO chat frame. [preview](https://i.imgur.com/Z3GgKT7.png)

Features:

- Gold spammer detection and automatic block/report
- Different text colors for each chat channel.
- Colored item and recipe links based on rarity.
- Whisper notification sounds. (Disabled by default)
- Optional time stamps.
- Open links from chat in your browser.
- More

Hex Color codes are used.

Available slash commands: /chat, /classicchat

This addon will conflict with LKChat, they cannot be used together.

#### Context Menu Additions
Add features to the context menu, such as "Report & Block", "Clear Sender Messages"

#### Fix Font Size Slider
Fix the font size slider in the chat options to dynamically update the font size in the chat frame.

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

#### Remove FPS Counter
Hide the FPS counter.

Available slash commands:
- /fps - toggles the fps counter

#### Remove Map Background
Remove the grey dimming background when the full map is opened. [preview](https://i.imgur.com/IfcOlo9.jpg)

#### Remove Pet Info
Hide pet names and/or HP bars.

Available slash commands, accessed with /companion or /comp:

- /comp -- Information about the addon.
- /comp name [on/off] - Show/hide your pet name. (Default: on)
- /comp hp [on/off] - Show/hide your pet HP. (Default: off)
- /comp other [on/off] - Show/hide other pet names. (Default: off)

#### Remove TP Button
Hides the TP button next to the minimap and replaces it with the slash command "/tp".

#### Remove Whisper Switch
Stop incoming whispers from automatically switching you to the whisper chat.

#### Toggle Duels
Allows you to toggle whether or not you will receive duel requests.

Available slash commands:

- /duels -- Quick toggle duels on/off.
- /duels [on/off] -- Set duel requests on/off. "On" means that you will be able to receive duel requests. (Default: on)
- /duels notify -- Toggle whether you will be notified in chat when a duel request is blocked, e.g. "Blocked duel request from Mie" (Default: on)
- /duels help -- Information about the addon.

By default, duels are set to "on", meaning you will recieve duel requests. It is set this way to prevent inconvenience in the case that somebody unwittingly installs the addon.
