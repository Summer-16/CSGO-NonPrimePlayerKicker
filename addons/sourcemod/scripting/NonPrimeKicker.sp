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

#define PLUGIN_VERSION "1.3"

ConVar g_cKickLevel;
ConVar g_cKickMsg;
ConVar g_cTagEnabled;
ConVar g_cTag;

public Plugin myinfo = {
    name        = "NonPrimeKicker",
    author      = "Summer_Soldier",
    description = "Kick Non Prime players",
    version     = PLUGIN_VERSION,
    url         = "summer@ganggaming.in"
};


public void OnPluginStart()
{
    g_cKickLevel = CreateConVar("sm_npmk_kicklevel", "2", "Define Minimum level for non primes to allow join in",0,true,1.0,true,40.0);
    g_cKickMsg = CreateConVar("sm_npmk_msg", "You Need a Licenced CSGO account to play on this server, Players with free account need to have CSGO level 3 (Private Rank 3) or higher. If you think this message is an error contact ADMIN", "Message to print when non prime's kicked");
    g_cTagEnabled = CreateConVar("sm_npmk_tag_enabled", "1", "Should plugin set the tag for non-prime players or not");
    g_cTag = CreateConVar("sm_npmk_tag", "[Non-Prime]", "Tag for non prime who are allowed in the server");

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
        PrintToServer("Reserverd/Admin client");
    } else if (playerlevel > minimumLevel) {
        PrintToServer("Here is client id %d and level=====>>>>>%d", client, playerlevel);
        PrintToServer("Level qualified client");
        if(k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)){
            if(tagEnabled){
            CS_SetClientClanTag(client, tag);
            }
        }
    } else if (k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)) {
        KickClient(client, message);
    } else {
        PrintToServer("Unable to verify client no action taken");
    }

}
