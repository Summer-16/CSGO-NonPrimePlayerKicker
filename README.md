# NonPrimePlayerKicker
[![Donate](https://cdn2.iconfinder.com/data/icons/social-icons-circular-color/512/paypal-64.png)](https://www.paypal.me/Shivam169)  [![Donate](https://cdn2.iconfinder.com/data/icons/social-icons-circular-color/512/paytm-64.png)](https://drive.google.com/file/d/1ks_B3s9dNk_RPkDVf1DL1ITKe0mnrTRk/view)  [![Donate](https://cdn1.iconfinder.com/data/icons/logos-brands-in-colors/436/Google_Pay_GPay_Logo-128.png)](https://drive.google.com/file/d/1c5V8j0W9o23HBCgUiO1SWltR4ADvQTQW/view)  [![Discord](https://cdn3.iconfinder.com/data/icons/logos-and-brands-adobe/512/91_Discord-64.png)](https://discord.gg/HcCFa8q)  

## Note: This plugin checks for CSGO licence, not the prime status (that is whether player has bought the game or not)
Here is what this plugin does
- It checks if the player has bought csgo or not 
- Player will be allowed in server directly in three cases (if player has bought the csgo, if player is an admin and if player has the bypass flag)
- Now player does not bought the csgo and he is not admin nor has the bypass flag , in this situation plugin checks if player has the minimum csgo hours defined in cfg and if player has the minimum hous he is allowed inside the server and kicked in other case.

***[SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556) is required if you want to recompile it.***

## Cvars
- `sm_npmk_level_enabled "1"` - 0-> Disable, 1->plugin check for minimun csgo hours for non licenced user, 2-> plugin check for minimun csgo level for non licenced user
- `sm_npmk_kicklevel "200"` - Minimum amount of playtime a user has to have on CS:GO (Default: 200) (for sm_npmk_level_enabled 1)
- `sm_npmk_kicklevel "2"` - Define Minimum level for non primes to allow join in (for sm_npmk_level_enabled 2)
- `sm_npmk_msg "You need a CSGO licensed account to play on this server. Free account players must have CSGO Level 2 or higher. If you think this message is an error, please contact us"` - Message to print when non prime's kicked;
- `sm_npmk_tag "[Non-Prime]"` - Tag for non prime who are allowed in the server;
- `sm_npmk_tag_enabled "1"` - Should plugin set the tag for non-prime players or not;

## Changelog
### Version - 2
- Version bumped
- Replaced CSGO level check with CSGO play hours check as levels get reset after getting medal

### Version - 1.3.1
- Added Cvar to enable disable level check incase of non prime.

### Version - 1.3.1
- Add log for players who are unable to connect;
- Fix minors;

### Version - 1.3
- Config Update - Added option for Tag enable/disable;

### Version - 1.2
- Added config file for minimun level define, message define and tag define;

### Version - 1.1
- Only Non Prime Players with level less then 2 will be kicked;
- Vip will pass through Clean so does admins;
- Also you can add `BypassPremiumCheck` admin group to bypass the checkUpdate;
- Updated to add a non prime tag to the player who has csgo level higher then 2;
