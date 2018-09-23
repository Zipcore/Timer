#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <timer>
#include <timer-stocks>
#include <timer-mapzones>
#include <timer-physics>
#include <timer-config_loader.sp>

public Plugin:myinfo =
{
	name        = "[Timer] Start zone no jump",
	author      = "Zipcore, Rop",
	description = "Prevents prespeed jumping inside start zones.",
	version     = PL_VERSION,
	url         = "forums.alliedmods.net/showthread.php?p=2074699"
};

public OnPluginStart()
{
	LoadPhysics();
	LoadTimerSettings();
	HookEvent("player_jump", Event_PlayerJump);
}

public OnMapStart()
{
	LoadPhysics();
	LoadTimerSettings();
}

public Action:Event_PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!g_Physics[Timer_GetStyle(client)][StyleStartZoneAntiBhop])
		return Plugin_Continue;

	if(Timer_IsPlayerTouchingZoneType(client, ZtStart) || Timer_IsPlayerTouchingZoneType(client, ZtBonusStart) || Timer_IsPlayerTouchingZoneType(client, ZtBonus2Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus3Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus4Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus5Start))
	{
		CreateTimer(0.05, DelayedSlowDown, client);
	}

	return Plugin_Continue;
}

public Action:DelayedSlowDown(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		CheckVelocity(client, 1, 120.0);
	}
}

public OnClientEndTouchZoneType(client, MapZoneType:type)
{
	if(type == ZtStart || type == ZtBonusStart)
	{
		new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);

		if(!onground && g_Physics[Timer_GetStyle(client)][StyleStartZoneAntiBhop])
		{
			CheckVelocity(client, 1, 120.0);
		}
	}
}
