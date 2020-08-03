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

#define PLUGIN_VERSION "2"

ConVar g_cLevelEnabled;
ConVar g_cKickMsg;
ConVar g_cTagEnabled;
ConVar g_cTag;
ConVar g_cSteamAPI;
ConVar g_cMinimumHours;
ConVar g_cMinimumCSLevel;

public Plugin myinfo = {
    name = "NonPrime Kicker",
    author = "Summer_Soldier",
    description = "Kick NonPrime Players",
    version = PLUGIN_VERSION,
    url = "https://github.com/Summer-16/CSGO-NonPrimePlayerKicker"
};

public void OnPluginStart() {
    g_cLevelEnabled = CreateConVar("sm_npmk_level_enabled", "1", "0-> Disable, 1->plugin check for minimun csgo hours for non licenced user, 2-> plugin check for minimun csgo level for non licenced user");
    g_cKickMsg = CreateConVar("sm_npmk_msg", "You need a CSGO licensed account to play on this server. Free account players must have 200 CSGO Play Hours.", "Message to print when non prime's kicked");
    g_cTagEnabled = CreateConVar("sm_npmk_tag_enabled", "1", "Should plugin set the tag for non-prime players or not");
    g_cTag = CreateConVar("sm_npmk_tag", "[Non-Prime]", "Tag for non prime who are allowed in the server");
    g_cMinimumHours = CreateConVar("sm_npmk_minimumhour_value", "200", "Minimum amount of playtime a user has to have on CS:GO (Default: 200)");
    g_cMinimumCSLevel = CreateConVar("sm_npmk_kicklevel", "2", "Define Minimum level for non primes to allow join in", 0, true, 1.0, true, 40.0);
    g_cSteamAPI = CreateConVar("sm_npmk_steamapi_key", "xxxxxxxxxxxxxxxxxxxxxxxxxxxx", "Need to fetch client's playhour from steam. (https://steamcommunity.com/dev/apikey)", FCVAR_NOTIFY);

    // Log of players who were unable to connect
    BuildPath(Path_SM, g_sLogs, sizeof(g_sLogs), "logs/nonprimekicker.log");

    // Execute the config file, create if not present
    AutoExecConfig(true, "NonPrimeKicker");

}

public void OnClientPutInServer(int client) {

    PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> OnClientPutInServer Event called for newly connected client");

    if (!IsFakeClient(client)) {
        int levelEnabled = g_cLevelEnabled.IntValue;
        char message[512];
        g_cKickMsg.GetString(message, 512);

        if (CheckCommandAccess(client, "BypassPremiumCheck", ADMFLAG_RESERVATION, true)) {
            PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Allowed into the server, Reserverd/Admin Client");
        } else {

            if (k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)) {
                if (levelEnabled > 0) {
                    if(levelEnabled == 1){
                        char steamid[64];
                        GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
                        RequestHours(client, steamid);
                        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client, Plugin's hours check is enabled, checking hours now");
                    }else if(levelEnabled == 2){
                        CreateTimer(30.0, RequestCSGOLevel, client);
                    }
                } else {
                    PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client and Plugin's hour check is disabled, Kicking the client");
                    KickClient(client, message);
                    LogToFile(g_sLogs, "[SUMMER-SOLDIER, NonPrimeKicker]==> %L does not have the CSGO Licence.", client);
                }

            } else {
                PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Allowed in Server, Licenced Client");
            }

        }

    }else{
        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Fake/Bot Client");
    }
}

public Action RequestCSGOLevel(Handle timer, int client) {

    int minimumLevel = g_cMinimumCSLevel.IntValue;
    int playerlevel = 0;
    playerlevel = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_nPersonaDataPublicLevel", _, client);

    char message[512];
    g_cKickMsg.GetString(message, 512);

    if (playerlevel >= minimumLevel) {
        int tagEnabled = g_cTagEnabled.IntValue;
        char tag[128];
        g_cTag.GetString(tag, 128);

        if (tagEnabled) {
            PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client but has enough CSGO Level, Allowed in server with non prime tag");
            CS_SetClientClanTag(client, tag);
        }

    } else{
        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client and Also not have enough CSGO level, Kicked");
        KickClient(client, "%s, You do not have enough CSGO Level to enter this server", message);
        LogToFile(g_sLogs, "[SUMMER-SOLDIER, NonPrimeKicker]==> %L does not have the CSGO Licence and Not enough CSGO Level.", client);
    }
    
}

void RequestHours(int client, char[] auth) {
    Handle request = CreateRequest_RequestHours(client, auth);
    SteamWorks_SendHTTPRequest(request);
}

Handle CreateRequest_RequestHours(int client, char[] auth) {

    char request_url[512];
    char s_Steamapi[256];
    g_cSteamAPI.GetString(s_Steamapi, sizeof(s_Steamapi));

    Format(request_url, sizeof(request_url), "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=%s&include_played_free_games=1&appids_filter[0]=730i&steamid=%s&format=json", s_Steamapi, auth);
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, request_url);

    SteamWorks_SetHTTPRequestContextValue(request, GetClientUserId(client));
    SteamWorks_SetHTTPCallbacks(request, RequestHours_OnHTTPResponse);
    return request;
}

public int RequestHours_OnHTTPResponse(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int userid) {

    if (!bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK) {
        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==>  HTTP Request to fetch Client's Profile data failed!");
        delete request;
        return;
    }

    int client = GetClientOfUserId(userid);

    if (!client) {
        delete request;
        return;
    }

    int bufferSize;

    SteamWorks_GetHTTPResponseBodySize(request, bufferSize);

    char[] responseBody = new char[bufferSize];
    SteamWorks_GetHTTPResponseBodyData(request, responseBody, bufferSize);
    delete request;

    int playedTime = GetPlayerHours(responseBody);
    int totalPlayedTime = playedTime / 60;

    PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Total CSGO play hours of the user %d", totalPlayedTime);

    int minimumhours = g_cMinimumHours.IntValue;
    char message[512];
    g_cKickMsg.GetString(message, 512);

    if (!totalPlayedTime) {
        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Play hours of the user are Invisible");
        KickClient(client, "%s, You have Invisible Play hours, Try making your profile public and then retry",message);
        LogToFile(g_sLogs, "%L does not have the CSGO Licence and Unable to fetch CSGO play hours.", client);
        return;
    }

    if (minimumhours != 0) {
        if (totalPlayedTime < minimumhours) {
            PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client and Also not have enough CSGO play hours, Kicked");
            KickClient(client, "%s, You do not have enough CSGO Play hours to enter this server", message);
            LogToFile(g_sLogs, "[SUMMER-SOLDIER, NonPrimeKicker]==> %L does not have the CSGO Licence and Not enough CSGO play hours.", client);
            return;
        }
    }

    int tagEnabled = g_cTagEnabled.IntValue;
    char tag[128];
    g_cTag.GetString(tag, 128);

    if (tagEnabled) {
        PrintToServer("[SUMMER-SOLDIER, NonPrimeKicker]==> Unlicenced Client but has enough play hours, Allowed in server with non prime tag");
        CS_SetClientClanTag(client, tag);
    }
}



stock int GetPlayerHours(const char[] responseBody) {

    char str[8][64];
    ExplodeString(responseBody, ",", str, sizeof(str), sizeof(str[]));
    for (int i = 0; i < 8; i++) {
        if (StrContains(str[i], "playtime_forever") != -1) {
            char str2[2][32];
            ExplodeString(str[i], ":", str2, sizeof(str2), sizeof(str2[]));
            return StringToInt((str2[1]));
        }
    }
    return -1;
}