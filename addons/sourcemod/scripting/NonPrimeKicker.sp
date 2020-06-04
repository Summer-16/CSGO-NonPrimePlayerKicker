/*  CSGO-NonPrimePlayerKicker
 *
 *  Copyright (C) 2020 SUMMER SOLDIER
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
#pragma semicolon 1

#include <sourcemod>
#include <SteamWorks>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

char g_sLogs[PLATFORM_MAX_PATH + 1];

#define PLUGIN_VERSION "1.3.1"

ConVar g_cKickLevel;
ConVar g_cKickMsg;
ConVar g_cTagEnabled;
ConVar g_cTag;

public Plugin myinfo = {
    name        = "NonPrime Kicker",
    author      = "Summer_Soldier",
    description = "Kick NonPrime Players",
    version     = PLUGIN_VERSION,
    url         = "https://github.com/Summer-16/CSGO-NonPrimePlayerKicker"
};

public void OnPluginStart()
{
    g_cKickLevel = CreateConVar("sm_npmk_kicklevel", "2", "Define Minimum level for non primes to allow join in",0,true,1.0,true,40.0);
    g_cKickMsg = CreateConVar("sm_npmk_msg", "You need a CSGO licensed account to play on this server. Free account players must have CSGO Level 2 or higher. If you think this message is an error, please contact us", "Message to print when non prime's kicked");
    g_cTagEnabled = CreateConVar("sm_npmk_tag_enabled", "1", "Should plugin set the tag for non-prime players or not");
    g_cTag = CreateConVar("sm_npmk_tag", "[Non-Prime]", "Tag for non prime who are allowed in the server");
	
	// Log of players who were unable to connect
	BuildPath(Path_SM, g_sLogs, sizeof(g_sLogs), "logs/nonprimekicker.log");

    // Execute the config file, create if not present
	AutoExecConfig(true, "NonPrimeKicker");

    HookEvent("player_team", EventPlayerTeam);
}

public Action EventPlayerTeam(Event event,const char[] name, bool dontBroadcast) {

    int minimumLevel = g_cKickLevel.IntValue;
    int tagEnabled = g_cTagEnabled.IntValue;
    char message[512];
    char tag[128];
    g_cKickMsg.GetString(message, 512);
    g_cTag.GetString(tag, 128);

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    int playerlevel = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_nPersonaDataPublicLevel", _, client);

    if (CheckCommandAccess(client, "BypassPremiumCheck", ADMFLAG_RESERVATION, true)) {
        PrintToServer("Reserverd/Admin Client");
    } else if (playerlevel >= minimumLevel) {
        if(k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)){
            if(tagEnabled){
            CS_SetClientClanTag(client, tag);
            }
        }
    } else if (k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)) {
        KickClient(client, message);
		LogToFile(g_sLogs, "%L does not have the Status Prime or Level required in CSGO.", client);
    } else {
        PrintToServer("Unable to verify client no action taken");
    }
}
