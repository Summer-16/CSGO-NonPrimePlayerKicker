# NonPrimePlayerKicker
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/Shivam169)

Plugin for kikar players who are Nom Prime or CSGO Level required.

***[SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556) is required if you want to recompile it.***

## Cvars
- `sm_npmk_kicklevel "2"` -  Define Minimum level for non primes to allow join in;
- `sm_npmk_msg "You need a CSGO licensed account to play on this server. Free account players must have CSGO Level 2 or higher. If you think this message is an error, please contact us"` - Message to print when non prime's kicked;
- `sm_npmk_tag "[Non-Prime]"` - Tag for non prime who are allowed in the server;
- `sm_npmk_tag_enabled "1"` - Should plugin set the tag for non-prime players or not;

## Changelog
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
- Also you can add 'BypassPremiumCheck' admin group to bypass the checkUpdate;
- Updated to add a non prime tag to the player who has csgo level higher then 2;
