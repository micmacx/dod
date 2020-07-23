#include <sourcemod>
#include <sdktools>
#define VERSION "1.5DODS"

new Handle:g_CvarEnable = INVALID_HANDLE;
new g_sprite;
new g_glow;
new m_iFOV;
new Handle:g_CvarRed = INVALID_HANDLE;
new Handle:g_CvarBlue = INVALID_HANDLE;
new Handle:g_CvarGreen = INVALID_HANDLE;
new Handle:g_CvarTrans = INVALID_HANDLE;
new Handle:g_CvarLife = INVALID_HANDLE;
new Handle:g_CvarWidth = INVALID_HANDLE;
new Handle:g_CvarDotWidth = INVALID_HANDLE;

public OnMapStart()
{
	g_sprite = PrecacheModel("materials/sprites/laser.vmt");
	g_glow = PrecacheModel("sprites/redglow1.vmt");
}

public Plugin:myinfo = 
{
	name = "DOD Laser Aim", 
	author = "Darkranger(for DODS), original fom Leonardo(for CSS)", 
	description = "Creates A Beam when player holds a scoped Sniper Rifle", 
	version = VERSION, 
	url = "www.dodsplugins.net"
};

public OnPluginStart()
{
	CreateConVar("dod_laser_aim", VERSION, "DODS LASER AIM", FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_CvarEnable = CreateConVar("dod_laser_aim_on", "1", "1 turns the plugin on 0 is off", FCVAR_NOTIFY);
	g_CvarRed = CreateConVar("dod_laser_aim_red", "200", "Amount OF Red In The Beam");
	g_CvarGreen = CreateConVar("dod_laser_aim_green", "0", "Amount Of Green In The Beam");
	g_CvarBlue = CreateConVar("dod_laser_aim_blue", "0", "Amount OF Blue In The Beams");
	g_CvarTrans = CreateConVar("dod_laser_aim_alpha", "10", "Amount OF Transparency In Beam");
	g_CvarLife = CreateConVar("dod_laser_aim_life", "0.1", "Life of the Beam");
	g_CvarWidth = CreateConVar("dod_laser_aim_width", "0.15", "Width of the Beam");
	g_CvarDotWidth = CreateConVar("dod_laser_aim_dot_width", "0.25", "Width of the Dot");
	m_iFOV = FindSendPropOffs("CDODPlayer", "m_iFOV");
	AutoExecConfig(true, "dod_laser_aim", "dod_laser_aim");
}

public OnGameFrame()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsClientConnected(i) && IsPlayerAlive(i))
		{
			new String:s_playerWeapon[32];
			GetClientWeapon(i, s_playerWeapon, sizeof(s_playerWeapon));
			new i_playerFOV;
			i_playerFOV = GetEntData(i, m_iFOV);
			if (GetConVarBool(g_CvarEnable))
				if (StrEqual("weapon_k98_scoped", s_playerWeapon) || StrEqual("weapon_spring", s_playerWeapon))
				if ((i_playerFOV <= 80) && (i_playerFOV >= 1))
				CreateBeam(i);
		}
	}
}

public Action:CreateBeam(any:client)
{
	new Float:f_playerViewOrigin[3];
	GetClientAbsOrigin(client, f_playerViewOrigin);
	if (GetClientButtons(client) & IN_DUCK)
		f_playerViewOrigin[2] += 40;
	else
		f_playerViewOrigin[2] += 60;
	new Float:f_playerViewDestination[3];
	GetPlayerEye(client, f_playerViewDestination);
	new Float:distance = GetVectorDistance(f_playerViewOrigin, f_playerViewDestination);
	new Float:percentage = 0.4 / (distance / 100);
	new Float:f_newPlayerViewOrigin[3];
	f_newPlayerViewOrigin[0] = f_playerViewOrigin[0] + ((f_playerViewDestination[0] - f_playerViewOrigin[0]) * percentage);
	f_newPlayerViewOrigin[1] = f_playerViewOrigin[1] + ((f_playerViewDestination[1] - f_playerViewOrigin[1]) * percentage) - 0.08;
	f_newPlayerViewOrigin[2] = f_playerViewOrigin[2] + ((f_playerViewDestination[2] - f_playerViewOrigin[2]) * percentage);
	new color[4];
	color[0] = GetConVarInt(g_CvarRed);
	color[1] = GetConVarInt(g_CvarGreen);
	color[2] = GetConVarInt(g_CvarBlue);
	color[3] = GetConVarInt(g_CvarTrans);
	new Float:life;
	life = GetConVarFloat(g_CvarLife);
	new Float:width;
	width = GetConVarFloat(g_CvarWidth);
	new Float:dotWidth;
	dotWidth = GetConVarFloat(g_CvarDotWidth);
	TE_SetupBeamPoints(f_newPlayerViewOrigin, f_playerViewDestination, g_sprite, 0, 0, 0, life, width, 0.0, 1, 0.0, color, 0);
	TE_SendToAll();
	TE_SetupGlowSprite(f_playerViewDestination, g_glow, life, dotWidth, color[3]);
	TE_SendToAll();
	return Plugin_Continue;
}

bool:GetPlayerEye(client, Float:pos[3])
{
	new Float:vAngles[3], Float:vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > GetMaxClients();
} 