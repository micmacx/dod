#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PL_VERSION "1.1"

new Handle:g_Enabled;
new Handle:g_Sounds = INVALID_HANDLE;
new Handle:g_ratio1 = INVALID_HANDLE;
new Handle:g_ratio2 = INVALID_HANDLE;

new flagcaps[MAXPLAYERS+1];

public Plugin:myinfo = {
	name        = "Dod:Source GoFlag",
	author      = "BenSib",
	description = "Plugin watches your kill/flag-ratio",
	version     = PL_VERSION,
	url         = "http://www.dodsplugins.com"
}

public OnPluginStart()
{
	CreateConVar("dod_goflag_version", PL_VERSION, "DoD:S GoFlag", FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_Enabled  = CreateConVar("dod_goflag_enabled", "1",  "Enable/disable GoFlag.",FCVAR_PLUGIN);
	g_Sounds = CreateConVar("dod_goflag_enablesounds", "1", "<0/1> = enable/disable Sounds <default: 1>", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_ratio1 = CreateConVar("dod_goflag_warn", "10", "<1/100> = maximum number of kills allowed per flag/objective until warning <default: 10>", FCVAR_PLUGIN, true, 1.0, true, 100.0);
	g_ratio2 = CreateConVar("dod_goflag_kick", "12", "<2/100> = maximum number of kills allowed per flag/objective until kick <default: 12>", FCVAR_PLUGIN, true, 2.0, true, 100.0);
	HookEventEx("dod_point_captured", OnDoDPointCaptured, EventHookMode_Post);
	HookEventEx("dod_capture_blocked", OnDoDCaptureBlocked, EventHookMode_Post);
	HookEventEx("dod_bomb_planted", OnDoDBombPlanted, EventHookMode_Post);
	HookEventEx("dod_bomb_exploded", OnDoDBombExploded, EventHookMode_Post);
	HookEventEx("dod_bomb_defused", OnDoDBombDefused, EventHookMode_Post);
	HookEventEx("player_death",OnPlayerDeath,EventHookMode_Pre);
}

public OnMapStart()
{	
	PrecacheSound("player/german/startround/ger_flags.wav", true);
	PrecacheSound("player/american/startround/us_flags6.wav", true);
}

public OnClientPutInServer(client)
{
	flagcaps[client] = 0;
}

public Action:OnDoDPointCaptured(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetConVarBool(g_Enabled))
	{
		new String:cappers[256];
		GetEventString(event,"cappers",cappers,sizeof(cappers));
		for(new i=0; i < strlen(cappers); i++) 
		{
			new client = cappers[i];
			flagcaps[client]++;
		}
	}
}

public Action:OnDoDCaptureBlocked(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"blocker"));
	flagcaps[client]++;
	return Plugin_Continue;
}

public Action:OnDoDBombPlanted(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	flagcaps[client]++;
	return Plugin_Continue;
}

public Action:OnDoDBombExploded(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	flagcaps[client] += 3;
	return Plugin_Continue;
}

public Action:OnDoDBombDefused(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	flagcaps[client]++;
	return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetConVarBool(g_Enabled))
	{
		new client = GetClientOfUserId(GetEventInt(event,"attacker"));
		if(ValidPlayer(client))
		{
			new kills = GetEntProp(client, Prop_Data, "m_iFrags");
			new ratio1 = GetConVarInt(g_ratio1);
			new ratio2 = GetConVarInt(g_ratio2);
			new caps = flagcaps[client];
			
			//PrintToChatAll("DEBUG: %N captured %d flag and has %d kills", client, flagcaps[client], kills);
			
			if (caps == 0)
				caps++;
			if (kills/caps >= ratio2)
			{
				PrintToChatAll("\x01\x04%N \x01kicked for taking \x05not enough flags/objectives", client);
				KickClient(client, "take more flags/objectives next time!");
			}
			else if (kills/caps >= ratio1)
			{
				if(GetConVarBool(g_Sounds))
				{
					new team = GetClientTeam(client);
					if(team == 2)
						EmitSoundToClient(client, "player/american/startround/us_flags6.wav", _, _, _, _, 0.6);
					else if(team == 3)
						EmitSoundToClient(client, "player/german/startround/ger_flags.wav", _, _, _, _, 0.6);
				}
				PrintHintText(client, "take more flags/objectives!");
			}
		}
	}
	return Plugin_Continue;
}

stock bool:ValidPlayer(client,bool:check_alive=false)
{
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(check_alive && !IsPlayerAlive(client))
		{
			return false;
		}
		return true;
	}
	return false;
}

