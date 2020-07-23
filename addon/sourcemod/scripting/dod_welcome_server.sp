#include <sourcemod>
#include <sdktools>

#define MAX_PLAYERS 32
#define MAX_FILE_LEN 80
#define PLUGIN_VERSION "2.0"

new Handle:g_CvarSoundName = INVALID_HANDLE
new Handle:Welcome_Timer[MAX_PLAYERS + 1]

new String:g_soundname[MAX_FILE_LEN]

public Plugin:myinfo = 
{
	name = "dod welcome server", 
	author = "vintage by dodsplugins.net Team", 
	description = "Play a sound on enter and display a welcome message with a timer", 
	version = PLUGIN_VERSION, 
	url = "http://www.dodsplugins.net"
}


public OnPluginStart()
{
	CreateConVar("dod_welcome_server_version", PLUGIN_VERSION, "DoDs Welcome Server Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD)
	g_CvarSoundName = CreateConVar("dod_welcome_server_sound", "dod_welcome_server/welcome_sound.mp3", "def: dod_welcome_server/welcome_sound.mp3. Change it ! The name of your sound related to the sound/dod_welcome_server/ folder", FCVAR_PLUGIN)
	HookConVarChange(g_CvarSoundName, OnSoundChanged)
	LoadTranslations("dod_welcome_server.phrases")
	AutoExecConfig(true, "dod_welcome_server", "dod_welcome_server")
}

public OnMapStart()
{
	GetConVarString(g_CvarSoundName, g_soundname, MAX_FILE_LEN)
	decl String:soundname[MAX_FILE_LEN]
	PrecacheSound(g_soundname, true)
	Format(soundname, sizeof(soundname), "sound/%s", g_soundname)
	AddFileToDownloadsTable(soundname)
}

public OnClientPutInServer(client)
{
	GetConVarString(g_CvarSoundName, g_soundname, MAX_FILE_LEN)
	if (IsClientConnected(client))
	{
	EmitSoundToClient(client, g_soundname)
	Welcome_Timer[client] = CreateTimer(15.0, Message_welcome, client)
	}
}

public Action:Message_welcome(Handle:timer, any:client)
{
	new String:name[32]
	GetClientName(client, name, sizeof(name))
	PrintHintText(client, "%t", "Message", name)
	Welcome_Timer[client] = INVALID_HANDLE
}

public OnSoundChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	decl String:soundname[MAX_FILE_LEN]
	strcopy(g_soundname, sizeof(g_soundname), newValue)
	PrecacheSound(g_soundname, true)
	Format(soundname, sizeof(soundname), "sound/%s", g_soundname)
	AddFileToDownloadsTable(soundname)
}

public OnClientDisconnect(client)
{
	if (Welcome_Timer[client] != INVALID_HANDLE)
	{
		KillTimer(Welcome_Timer[client])
		Welcome_Timer[client] = INVALID_HANDLE
	}
}
