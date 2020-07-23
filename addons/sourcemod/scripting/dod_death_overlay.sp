/*
// Fully inspired by FeurSturm dod_nostalgic_death
// and dataviruset for round end overlay donwloading and precache snippet
// Thanks to them !
// :)
// vintage
// V 1.0:
// original plugin (request by LeTaz)
// Overlay too long (stay from death to respawn)
// V 1.1:
// added auto cfg config for overlay model and a timer duration to display the overlay
*/
// Includes
#include <sourcemod>
#include <sdktools>

// Constantes
#define PLUGIN_NAME    "DoD Death Overlay"
#define PLUGIN_VERSION	 "1.1"
#define DOD_MAXPLAYERS 33

new Handle:DeathOverlay = INVALID_HANDLE,
	Handle:g_TimeDeathOverlay = INVALID_HANDLE,
	Handle:DeathOverlayTimer[DOD_MAXPLAYERS + 1] = INVALID_HANDLE;
//Infos
public Plugin:myinfo = 
{
	name = PLUGIN_NAME, 
	author = "vintage", 
	description = "Display an overlay on death", 
	version = PLUGIN_VERSION,
	url = "http://www.dodsplugins.net"
}

public OnPluginStart()
{
	DeathOverlay = CreateConVar("sm_dod_deathoverlay", "decals/death_overlay/deathoverlay", "overlay to display, relative to materials folder without file extension (set download and precache in sourcemod/configs/dod_death_overlay_download.ini)", FCVAR_PLUGIN)
	g_TimeDeathOverlay = CreateConVar("sm_dod_deathoverlaytime", "2.0", "How many seconds to display overlay", FCVAR_PLUGIN, true, 1.0, true, 5.0)

	HookEventEx("player_death", OnPlayerDeath, EventHookMode_Post)
	HookEventEx("player_spawn", OnPlayerSpawn, EventHookMode_Post)
	
	AutoExecConfig(true, "sm_dod_deathoverlay", "sm_dod_deathoverlay")
}

public OnMapStart()
{
	decl String:file[256];
	BuildPath(Path_SM, file, 255, "configs/dod_death_overlay_download.ini");
	new Handle:fileh = OpenFile(file, "r");
	if (fileh != INVALID_HANDLE)
	{
		decl String:buffer[256];
		decl String:buffer_full[PLATFORM_MAX_PATH];
		
		while (ReadFileLine(fileh, buffer, sizeof(buffer)))
		{
			TrimString(buffer);
			if ((StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")))
			{
				PrintToServer("Reading overlay_downloads line :: %s", buffer);
				Format(buffer_full, sizeof(buffer_full), "materials/%s", buffer);
				if (FileExists(buffer_full))
				{
					PrintToServer("Precaching %s", buffer);
					PrecacheDecal(buffer, true);
					AddFileToDownloadsTable(buffer_full);
					PrintToServer("Adding %s to downloads table", buffer_full);
				}
				else
				{
					PrintToServer("File does not exist! %s", buffer_full);
				}
			}
		}
		
	}
}

public OnClientDisconnect(client)
{
	if (IsClientInGame(client))
	{
		ClientCommand(client, "r_screenoverlay 0")
	}
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"))
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		ClientCommand(client, "r_screenoverlay 0")
	}
	return Plugin_Continue
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:overlaypath[PLATFORM_MAX_PATH]
	new client = GetClientOfUserId(GetEventInt(event, "userid"))
	if(IsClientInGame(client))
	{
	GetConVarString(DeathOverlay, overlaypath, sizeof(overlaypath))
	ShowOverlayToClient(client, overlaypath)	
	GetConVarInt(g_TimeDeathOverlay)
	DeathOverlayTimer[client] = CreateTimer(GetConVarFloat(g_TimeDeathOverlay), DontShowOverlayToClient, client, TIMER_FLAG_NO_MAPCHANGE)
}
	return Plugin_Continue
}


public Action:ShowOverlayToClient(client, const String:overlaypath[])
{
	ClientCommand(client, "r_screenoverlay \"%s\"", overlaypath)
	return Plugin_Continue
}

public Action:DontShowOverlayToClient(Handle:timer, any:client)
{
	ClientCommand(client, "r_screenoverlay 0")
	DeathOverlayTimer[client] = INVALID_HANDLE
	return Plugin_Continue
}
