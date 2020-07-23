#include <sourcemod>
#include <sdktools>

#define DOD_PARACHUTES_VERSION 	"3.0"

#define ALLIES 2
#define AXIS 3

//Parachutes Models
#define AL_PARACHUTE_MODEL		"parachute_allies"
#define AX_PARACHUTE_MODEL		"parachute_axes"

//Parachute Textures
#define AL_PARACHUTE_PACK		"pack_allies"
#define AL_PARACHUTE_TEXTURE	"parachute_allies"
#define AX_PARACHUTE_PACK		"pack_axes"
#define AX_PARACHUTE_TEXTURE	"parachute_axes"

new g_iVelocity = -1;
new g_maxplayers = -1;

new String:g_game[30];
new String:al_path_model[256];
new String:al_path_pack[256];
new String:al_path_texture[256];
new String:ax_path_model[256];
new String:ax_path_pack[256];
new String:ax_path_texture[256];

new Handle:g_fallspeed = INVALID_HANDLE;
new Handle:g_enabled = INVALID_HANDLE;
new Handle:g_linear = INVALID_HANDLE;
new Handle:g_welcome = INVALID_HANDLE;
new Handle:g_version = INVALID_HANDLE;
new Handle:g_decrease = INVALID_HANDLE;
new Handle:g_button = INVALID_HANDLE;

new x;
new cl_flags;
new cl_buttons;
new Float:speed[3];
new bool:isfallspeed;

new USE_BUTTON;
new String:ButtonText[265];

new bool:inUse[MAXPLAYERS+1];
new bool:hasModel[MAXPLAYERS+1];
new Parachute_Ent[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "DOD:S Parachutes",
	author = "orig. Script from SWAT_88, Vintage, Darkranger",
	description = "Different Models for Allies & Axis. To use your parachute press and hold your E(+use) button while falling.",
	version = DOD_PARACHUTES_VERSION,
	url = "http://dodsplugins.com/"
};

public OnPluginStart()
{
	LoadTranslations ("dod_parachutes.phrases");

	g_enabled = CreateConVar("dod_parachutes_enabled","1");
	g_fallspeed = CreateConVar("dod_parachutes_fallspeed","100");
	g_linear = CreateConVar("dod_parachutes_linear","1");
	g_welcome = CreateConVar("dod_parachutes_welcome","1");
	g_version = CreateConVar("dod_parachutes_version", DOD_PARACHUTES_VERSION,	"DoDs Parachute Version", FCVAR_NOTIFY);
	g_decrease = CreateConVar("dod_parachutes_decrease","50");
	g_button = CreateConVar("dod_parachutes_button","1");
	g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");
	g_maxplayers = GetMaxClients();
	SetConVarString(g_version, DOD_PARACHUTES_VERSION);

	InitModels();
	InitGameMode();

	HookEvent("player_death",PlayerDeath);
	HookConVarChange(g_linear, CvarChange_Linear);
}

public OnPluginEnd()
{
	CloseHandle(g_fallspeed);
	CloseHandle(g_enabled);
	CloseHandle(g_linear);
	CloseHandle(g_welcome);
	CloseHandle(g_version);
	CloseHandle(g_decrease);
}

public InitModels()
{
	Format(al_path_model,255,"models/dod_parachutes/Allies/%s",AL_PARACHUTE_MODEL);
	Format(al_path_pack,255,"materials/models/dod_parachutes/Allies/%s",AL_PARACHUTE_PACK);
	Format(al_path_texture,255,"materials/models/dod_parachutes/Allies/%s",AL_PARACHUTE_TEXTURE);
	Format(ax_path_model,255,"models/dod_parachutes/Axes/%s",AX_PARACHUTE_MODEL);
	Format(ax_path_pack,255,"materials/models/dod_parachutes/Axes/%s",AX_PARACHUTE_PACK);
	Format(ax_path_texture,255,"materials/models/dod_parachutes/Axes/%s",AX_PARACHUTE_TEXTURE);
}

public OnMapStart()
{
	new String:path[256];

	strcopy(path,255,al_path_model);
	StrCat(path,255,".mdl")
	PrecacheModel(path,true);

	strcopy(path,255,al_path_model);
	StrCat(path,255,".dx80.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_model);
	StrCat(path,255,".dx90.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_model);
	StrCat(path,255,".mdl")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_model);
	StrCat(path,255,".sw.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_model);
	StrCat(path,255,".vvd")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_pack);
	StrCat(path,255,".vmt")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_pack);
	StrCat(path,255,".vtf")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_texture);
	StrCat(path,255,".vmt")
	AddFileToDownloadsTable(path);

	strcopy(path,255,al_path_texture);
	StrCat(path,255,".vtf")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".mdl")
	PrecacheModel(path,true);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".dx80.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".dx90.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".mdl")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".sw.vtx")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_model);
	StrCat(path,255,".vvd")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_pack);
	StrCat(path,255,".vmt")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_pack);
	StrCat(path,255,".vtf")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_texture);
	StrCat(path,255,".vmt")
	AddFileToDownloadsTable(path);

	strcopy(path,255,ax_path_texture);
	StrCat(path,255,".vtf")
	AddFileToDownloadsTable(path);
}

public InitGameMode()
{
	GetGameFolderName(g_game, 29);
	if(StrEqual(g_game,"dod",false))
	{
		SetConVarInt(g_button,1);
		SetButton(1);
	}
	else
	{
		SetFailState("[dod_parachutes] This plugin is made for DOD:S! Disabled.");
	}
}

public OnEventShutdown()
{
	UnhookEvent("player_death",PlayerDeath);
}

public OnClientPutInServer(client)
{
	inUse[client] = false;
	hasModel[client] = false;
	g_maxplayers = GetMaxClients();
	CreateTimer (20.0, WelcomeMsg, client);
}

public OnClientDisconnect(client)
{
	g_maxplayers = GetMaxClients();
	CloseParachute(client);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client;
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	EndPara(client);
	return Plugin_Continue;
}

public StartPara(client,bool:open)
{
	decl Float:velocity[3];
	decl Float:fallspeed;
	if (g_iVelocity == -1) return;
	if(GetConVarInt(g_enabled)== 1)
	{
		fallspeed = GetConVarFloat(g_fallspeed)*(-1.0);
		GetEntDataVector(client, g_iVelocity, velocity);
		if(velocity[2] >= fallspeed)
		{
			isfallspeed = true;
		}
		if(velocity[2] < 0.0)
		{
			if(isfallspeed && GetConVarInt(g_linear) == 0)
			{
			}
			else if((isfallspeed && GetConVarInt(g_linear) == 1) || GetConVarFloat(g_decrease) == 0.0)
			{
				velocity[2] = fallspeed;
			}
			else
			{
				velocity[2] = velocity[2] + GetConVarFloat(g_decrease);
			}
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			SetEntDataVector(client, g_iVelocity, velocity);
			SetEntityGravity(client,0.1);
			if(open) OpenParachute(client);
		}
	}
}

public EndPara(client)
{
	if(GetConVarInt(g_enabled)== 1 )
	{
		SetEntityGravity(client,1.0);
		inUse[client]=false;
		CloseParachute(client);
	}
}

public OpenParachute(client)
{
	if (GetClientTeam(client)== 2)
	{
		decl String:path[256];
		strcopy(path,255,al_path_model);
		StrCat(path,255,".mdl")
		Parachute_Ent[client] = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(Parachute_Ent[client],"model",path);
		SetEntityMoveType(Parachute_Ent[client], MOVETYPE_NOCLIP);
		DispatchSpawn(Parachute_Ent[client]);
		hasModel[client]=true;
		TeleportParachute(client);
	}
	if (GetClientTeam(client)== 3)
	{
		decl String:path[256];
		strcopy(path,255,ax_path_model);
		StrCat(path,255,".mdl")
		Parachute_Ent[client] = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(Parachute_Ent[client],"model",path);
		SetEntityMoveType(Parachute_Ent[client], MOVETYPE_NOCLIP);
		DispatchSpawn(Parachute_Ent[client]);
		hasModel[client]=true;
		TeleportParachute(client);
	}
}

public TeleportParachute(client)
{
	if(hasModel[client] && IsValidEntity(Parachute_Ent[client]))
	{
		decl Float:Client_Origin[3];
		decl Float:Client_Angles[3];
		decl Float:Parachute_Angles[3] = {0.0, 0.0, 0.0};
		GetClientAbsOrigin(client,Client_Origin);
		GetClientAbsAngles(client,Client_Angles);
		Parachute_Angles[1] = Client_Angles[1];
		TeleportEntity(Parachute_Ent[client], Client_Origin, Parachute_Angles, NULL_VECTOR);
	}
}

public CloseParachute(client)
{
	if(hasModel[client] && IsValidEntity(Parachute_Ent[client]))
	{
		RemoveEdict(Parachute_Ent[client]);
		hasModel[client]=false;
	}
}

public Check(client)
{
	if(GetConVarInt(g_enabled)== 1 )
	{
		GetEntDataVector(client,g_iVelocity,speed);
		cl_flags = GetEntityFlags(client);
		if(speed[2] >= 0 || (cl_flags & FL_ONGROUND)) EndPara(client);
	}
}

public OnGameFrame()
{
	if(GetConVarInt(g_enabled) == 0) return;
	for (x = 1; x <= g_maxplayers; x++)
	{
		if (IsClientInGame(x) && IsPlayerAlive(x))
		{
			cl_buttons = GetClientButtons(x);
			if (cl_buttons & USE_BUTTON)
			{
				if (!inUse[x])
				{
					inUse[x] = true;
					isfallspeed = false;
					StartPara(x,true);
				}
				StartPara(x,false);
				TeleportParachute(x);
			}
			else
			{
				if (inUse[x])
				{
					inUse[x] = false;
					EndPara(x);
				}
			}
			Check(x);
		}
	}
}

stock GetNextSpaceCount(String:text[],CurIndex)
{
    new Count=0;
    new len = strlen(text);
    for(new i=CurIndex;i<len;i++)
    {
        if(text[i] == ' ') return Count;
        else Count++;
    }
    return Count;
}

public Action:WelcomeMsg (Handle:timer, any:client)
{
	if(GetConVarInt(g_enabled) == 0) return Plugin_Continue;

	if (GetConVarInt (g_welcome) == 1 && IsClientConnected (client) && IsClientInGame (client))
	{
		PrintToChat(client,"\x01\x04[DoD:S Parachutes]\x01 %T", "Welcome", LANG_SERVER);
	}
	return Plugin_Continue;
}



public CvarChange_Linear(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	if (StringToInt(newvalue) == 0)
	{
		for (new client = 1; client <= g_maxplayers; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				SetEntityMoveType(client,MOVETYPE_WALK);
			}
		}
	}
}

public CvarChange_Model(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	if (StringToInt(newvalue) == 0)
	{
		for (new client = 1; client <= g_maxplayers; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				CloseParachute(client);
			}
		}
	}
}

public SetButton(button)
{
	if (button == 1)
	{
		USE_BUTTON = IN_USE;
		ButtonText = "E";
	}
}