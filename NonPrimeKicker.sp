#pragma semicolon 1
#include <sourcemod>
#include <SteamWorks>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

#define PLUGIN_VERSION "1.2"

ConVar g_cKickLevel;
ConVar g_cKickMsg;
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
    g_cKickMsg = CreateConVar("sm_npmk_msg", "You need a Prime CS:GO account to play on this server, If you think this message is an error contact ADMIN", "Message to print when non prime's kicked");
    g_cTag = CreateConVar("sm_npmk_tag", "[Non-Prime]", "Tag for non prime who are allowed in the server");

    // Execute the config file, create if not present
	AutoExecConfig(true, "NonPrimeKicker");

    HookEvent("player_team", EventPlayerTeam);

}

public Action EventPlayerTeam(Event event,const char[] name, bool dontBroadcast) {

    int minimumLevel = g_cKickLevel.IntValue;
    char message[512];
    char tag[128];
    g_cKickMsg.GetString(message, 512);
    g_cTag.GetString(tag, 128);


    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    int playerlevel = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_nPersonaDataPublicLevel", _, client);

    if (CheckCommandAccess(client, "BypassPremiumCheck", ADMFLAG_RESERVATION, true)) {
        PrintToServer("Here is client id %d and level=====>>>>>%d", client, playerlevel);
        PrintToServer("Reserverd/Admin client");
    } else if (playerlevel > minimumLevel) {
        PrintToServer("Here is client id %d and level=====>>>>>%d", client, playerlevel);
        PrintToServer("Level qualified client");
        if(k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)){
            PrintToServer("Eligible Non Prime Setting tag");
            CS_SetClientClanTag(client, tag);
        }
    } else if (k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)) {
        PrintToServer("Non Prime Client kicked");
        KickClient(client, message);
    } else {
        PrintToServer("Unable to verify client no action taken");
    }

}
