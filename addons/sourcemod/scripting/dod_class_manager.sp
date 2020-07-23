#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0"

new Handle:g_Cvar_RifleClass[5];
new Handle:g_Cvar_AssaultClass[5];
new Handle:g_Cvar_HeavyClass[5];
new Handle:g_Cvar_SniperClass[5];
new Handle:g_Cvar_MgClass[5];
new Handle:g_Cvar_BazookaClass[5];

new Handle:g_Cvar_Enable = INVALID_HANDLE;

new Handle:g_Cvar_RifleEnable = INVALID_HANDLE;
new Handle:g_Cvar_AssaultEnable = INVALID_HANDLE;
new Handle:g_Cvar_HeavyEnable = INVALID_HANDLE;
new Handle:g_Cvar_SniperEnable = INVALID_HANDLE;
new Handle:g_Cvar_MgEnable = INVALID_HANDLE;
new Handle:g_Cvar_BazookaEnable = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "DoD:S Class Manager",
	author = "Ben",
	description = "Change class restrictions according to connected players",
	version = PLUGIN_VERSION,
	url = "http://www.dodsplugins.com"
};

public OnPluginStart()
{
	CreateConVar("dod_class_manager_ver", PLUGIN_VERSION, "Version of DoDS Class Manager", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	g_Cvar_RifleClass[0]  = CreateConVar("dod_class_unlock_1_rifle", "1", "- number of players on server needed to unlock one rifle (locked = 0 / default = 1)");
	g_Cvar_RifleClass[1]  = CreateConVar("dod_class_unlock_2_rifle", "1", "- number of players on server needed to unlock two rifles (locked = 0 / default = 1)");
	g_Cvar_RifleClass[2]  = CreateConVar("dod_class_unlock_3_rifle", "1", "- number of players on server needed to unlock three rifles (locked = 0 / default = 1)");
	g_Cvar_RifleClass[3]  = CreateConVar("dod_class_unlock_x_rifle", "1", "- number of players on server needed to unlock unlimited rifles (locked = 0 / default = 1)");
	g_Cvar_AssaultClass[0]  = CreateConVar("dod_class_unlock_1_assault", "1", "- number of players on server needed to unlock one assault (locked = 0 / default = 1)");
	g_Cvar_AssaultClass[1]  = CreateConVar("dod_class_unlock_2_assault", "1", "- number of players on server needed to unlock two assaults (locked = 0 / default = 1)");
	g_Cvar_AssaultClass[2]  = CreateConVar("dod_class_unlock_3_assault", "1", "- number of players on server needed to unlock three assaults (locked = 0 / default = 1)");
	g_Cvar_AssaultClass[3]  = CreateConVar("dod_class_unlock_x_assault", "1", "- number of players on server needed to unlock unlimited assaults (locked = 0 / default = 1)");
	g_Cvar_HeavyClass[0]  = CreateConVar("dod_class_unlock_1_support", "1", "- number of players on server needed to unlock one heavy (locked = 0 / default = 1)");
	g_Cvar_HeavyClass[1]  = CreateConVar("dod_class_unlock_2_support", "1", "- number of players on server needed to unlock two heavys (locked = 0 / default = 1)");
	g_Cvar_HeavyClass[2]  = CreateConVar("dod_class_unlock_3_support", "1", "- number of players on server needed to unlock three heavys (locked = 0 / default = 1)");
	g_Cvar_HeavyClass[3]  = CreateConVar("dod_class_unlock_x_support", "1", "- number of players on server needed to unlock unlimited heavys (locked = 0 / default = 1)");
	
	g_Cvar_SniperClass[0]  = CreateConVar("dod_class_unlock_1_sniper", "8", "- number of players on server needed to unlock one Sniper (locked = 0 / default = 8)");
	g_Cvar_SniperClass[1]  = CreateConVar("dod_class_unlock_2_sniper", "18", "- number of players on server needed to unlock two Snipers (locked = 0 / default = 18)");
	g_Cvar_SniperClass[2]  = CreateConVar("dod_class_unlock_3_sniper", "26", "- number of players on server needed to unlock three Snipers (locked = 0 / default = 26)");
	g_Cvar_SniperClass[3]  = CreateConVar("dod_class_unlock_x_sniper", "0", "- number of players on server needed to unlock unlimited Snipers (locked = 0 / default = 0)");
	g_Cvar_MgClass[0]  = CreateConVar("dod_class_unlock_1_mg", "12", "- number of players on server needed to unlock one MG (locked = 0 / default = 12)");
	g_Cvar_MgClass[1]  = CreateConVar("dod_class_unlock_2_mg", "26", "- number of players on server needed to unlock two MGs (locked = 0 / default = 26)");
	g_Cvar_MgClass[2]  = CreateConVar("dod_class_unlock_3_mg", "0", "- number of players on server needed to unlock three MGs (locked = 0 / default = 0)");
	g_Cvar_MgClass[3]  = CreateConVar("dod_class_unlock_x_mg", "0", "- number of players on server needed to unlock unlimited MGs (locked = 0 / default = 0)");
	g_Cvar_BazookaClass[0]  = CreateConVar("dod_class_unlock_1_rocket", "1", "- number of players on server needed to unlock one rocket (locked = 0 / default = 1)");
	g_Cvar_BazookaClass[1]  = CreateConVar("dod_class_unlock_2_rocket", "1", "- number of players on server needed to unlock two rockets (locked = 0 / default = 1)");
	g_Cvar_BazookaClass[2]  = CreateConVar("dod_class_unlock_3_rocket", "1", "- number of players on server needed to unlock three rockets (locked = 0 / default = 1)");
	g_Cvar_BazookaClass[3]  = CreateConVar("dod_class_unlock_x_rocket", "1", "- number of players on server needed to unlock unlimited rockets (locked = 0 / default = 1)");

	g_Cvar_Enable        = CreateConVar("dod_class_manager_enable", "1", "- Enables/Disables class manager plugin (disabled = 0 / default = 1)");
	
	g_Cvar_RifleEnable        = CreateConVar("dod_class_manager_rifle_enable", "0", "- Enables/Disables class manager plugin for rifle class (disabled = 0 / default = 0)");
	g_Cvar_AssaultEnable        = CreateConVar("dod_class_manager_assault_enable", "0", "- Enables/Disables class manager plugin for assault class (disabled = 0 / default = 0)");
	g_Cvar_HeavyEnable        = CreateConVar("dod_class_manager_support_enable", "0", "- Enables/Disables class manager plugin for support class (disabled = 0 / default = 0)");
	g_Cvar_SniperEnable        = CreateConVar("dod_class_manager_sniper_enable", "1", "- Enables/Disables class manager plugin for sniper class (disabled = 0 / default = 1)");
	g_Cvar_MgEnable        = CreateConVar("dod_class_manager_mg_enable", "1", "- Enables/Disables class manager plugin for mg class (disabled = 0 / default = 1)");
	g_Cvar_BazookaEnable        = CreateConVar("dod_class_manager_rocket_enable", "0", "- Enables/Disables class manager plugin for rocket class (disabled = 0 / default = 1)");

	HookEvent("player_changeclass", ChangeClassEvent, EventHookMode_Pre);
}

public OnEventShutdown()
{
	UnhookEvent("player_changeclass", ChangeClassEvent);
}

public Action:ChangeClassEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	ManageClass();
	return Plugin_Continue;
}

ManageClass()
{
	new CurrentPlayers = GetClientCount();
	
	if (GetConVarInt(g_Cvar_Enable))
	{
		if (GetConVarInt(g_Cvar_RifleEnable))
		{
			new RifleLimit0 = GetConVarInt(g_Cvar_RifleClass[0]);
			new RifleLimit1 = GetConVarInt(g_Cvar_RifleClass[1]);
			new RifleLimit2 = GetConVarInt(g_Cvar_RifleClass[2]);
			new RifleLimit3 = GetConVarInt(g_Cvar_RifleClass[3]);
			
			if (RifleLimit3 != 0 && RifleLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rifleman -1; mp_limit_axis_rifleman -1");
			else if (RifleLimit2 != 0 && RifleLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rifleman 3; mp_limit_axis_rifleman 3");
			else if (RifleLimit1 != 0 && RifleLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rifleman 2; mp_limit_axis_rifleman 2");
			else if (RifleLimit0 != 0 && RifleLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rifleman 1; mp_limit_axis_rifleman 1");
			else
				ServerCommand("mp_limit_allies_rifleman 0; mp_limit_axis_rifleman 0");
		}
	
		if (GetConVarInt(g_Cvar_AssaultEnable))
		{
			new AssaultLimit0 = GetConVarInt(g_Cvar_AssaultClass[0]);
			new AssaultLimit1 = GetConVarInt(g_Cvar_AssaultClass[1]);
			new AssaultLimit2 = GetConVarInt(g_Cvar_AssaultClass[2]);
			new AssaultLimit3 = GetConVarInt(g_Cvar_AssaultClass[3]);
			
			if (AssaultLimit3 != 0 && AssaultLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_assault -1; mp_limit_axis_assault -1");
			else if (AssaultLimit2 != 0 && AssaultLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_assault 3; mp_limit_axis_assault 3");
			else if (AssaultLimit1 != 0 && AssaultLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_assault 2; mp_limit_axis_assault 2");
			else if (AssaultLimit0 != 0 && AssaultLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_assault 1; mp_limit_axis_assault 1");
			else
				ServerCommand("mp_limit_allies_assault 0; mp_limit_axis_assault 0");
		}
		
		if (GetConVarInt(g_Cvar_HeavyEnable))
		{
			new HeavyLimit0 = GetConVarInt(g_Cvar_HeavyClass[0]);
			new HeavyLimit1 = GetConVarInt(g_Cvar_HeavyClass[1]);
			new HeavyLimit2 = GetConVarInt(g_Cvar_HeavyClass[2]);
			new HeavyLimit3 = GetConVarInt(g_Cvar_HeavyClass[3]);
			
			if (HeavyLimit3 != 0 && HeavyLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_support -1; mp_limit_axis_support -1");
			else if (HeavyLimit2 != 0 && HeavyLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_support 3; mp_limit_axis_support 3");
			else if (HeavyLimit1 != 0 && HeavyLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_support 2; mp_limit_axis_support 2");
			else if (HeavyLimit0 != 0 && HeavyLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_support 1; mp_limit_axis_support 1");
			else
				ServerCommand("mp_limit_allies_support 0; mp_limit_axis_support 0");
		}
		
		if (GetConVarInt(g_Cvar_SniperEnable))
		{
			new SniperLimit0 = GetConVarInt(g_Cvar_SniperClass[0]);
			new SniperLimit1 = GetConVarInt(g_Cvar_SniperClass[1]);
			new SniperLimit2 = GetConVarInt(g_Cvar_SniperClass[2]);
			new SniperLimit3 = GetConVarInt(g_Cvar_SniperClass[3]);
			
			if (SniperLimit3 != 0 && SniperLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_sniper -1; mp_limit_axis_sniper -1");
			else if (SniperLimit2 != 0 && SniperLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_sniper 3; mp_limit_axis_sniper 3");
			else if (SniperLimit1 != 0 && SniperLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_sniper 2; mp_limit_axis_sniper 2");
			else if (SniperLimit0 != 0 && SniperLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_sniper 1; mp_limit_axis_sniper 1");
			else
				ServerCommand("mp_limit_allies_sniper  0; mp_limit_axis_sniper 0");
		}
		
		if (GetConVarInt(g_Cvar_MgEnable))
		{
			new MgLimit0 = GetConVarInt(g_Cvar_MgClass[0]);
			new MgLimit1 = GetConVarInt(g_Cvar_MgClass[1]);
			new MgLimit2 = GetConVarInt(g_Cvar_MgClass[2]);
			new MgLimit3 = GetConVarInt(g_Cvar_MgClass[3]);
			
			if (MgLimit3 != 0 && MgLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_mg -1; mp_limit_axis_mg -1");
			else if (MgLimit2 != 0 && MgLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_mg 3; mp_limit_axis_mg 3");
			else if (MgLimit1 != 0 && MgLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_mg 2; mp_limit_axis_mg 2");
			else if (MgLimit0 != 0 && MgLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_mg 1; mp_limit_axis_mg 1");
			else
				ServerCommand("mp_limit_allies_mg  0; mp_limit_axis_mg 0");
		}
		
		if (GetConVarInt(g_Cvar_BazookaEnable))
		{
			new BazookaLimit0 = GetConVarInt(g_Cvar_BazookaClass[0]);
			new BazookaLimit1 = GetConVarInt(g_Cvar_BazookaClass[1]);
			new BazookaLimit2 = GetConVarInt(g_Cvar_BazookaClass[2]);
			new BazookaLimit3 = GetConVarInt(g_Cvar_BazookaClass[3]);
			
			if (BazookaLimit3 != 0 && BazookaLimit3 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rocket -1; mp_limit_axis_rocket -1");
			else if (BazookaLimit2 != 0 && BazookaLimit2 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rocket 3; mp_limit_axis_rocket 3");
			else if (BazookaLimit1 != 0 && BazookaLimit1 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rocket 2; mp_limit_axis_rocket 2");
			else if (BazookaLimit0 != 0 && BazookaLimit0 <= CurrentPlayers)
				ServerCommand("mp_limit_allies_rocket 1; mp_limit_axis_rocket 1");
			else
				ServerCommand("mp_limit_allies_rocket 0; mp_limit_axis_rocket 0");
		}
	}
}

