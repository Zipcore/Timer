#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <timer>
#include <timer-stocks>
#include <timer-config_loader.sp>

#undef REQUIRE_PLUGIN
#include <timer-physics>
#include <timer-worldrecord>
#include <timer-strafes>

new bool:g_timerPhysics = false;
new bool:g_timerStrafes = false;
new bool:g_timerWorldRecord = false;

public Plugin:myinfo = 
{
	name = "[Timer] Finish Message",
	author = "Zipcore",
	description = "[Timer] Finish message for CS:GO",
	version = PL_VERSION,
	url = "forums.alliedmods.net/showthread.php?p=2074699"
};

public OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		Timer_LogError("Don't use this plugin for other games than CS:GO.");
		SetFailState("Check timer error logs.");
		return;
	}
	
	g_timerPhysics = LibraryExists("timer-physics");
	g_timerStrafes = LibraryExists("timer-strafes");
	g_timerWorldRecord = LibraryExists("timer-worldrecord");
	
	LoadPhysics();
	LoadTimerSettings();
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "timer-physics"))
	{
		g_timerPhysics = true;
	}	
	else if (StrEqual(name, "timer-strafes"))
	{
		g_timerStrafes = true;
	}
	else if (StrEqual(name, "timer-worldrecord"))
	{
		g_timerWorldRecord = true;
	}
}

public OnLibraryRemoved(const String:name[])
{	
	if (StrEqual(name, "timer-physics"))
	{
		g_timerPhysics = false;
	}	
	else if (StrEqual(name, "timer-strafes"))
	{
		g_timerStrafes = false;
	}
	else if (StrEqual(name, "timer-worldrecord"))
	{
		g_timerWorldRecord = false;
	}
}


public OnMapStart()
{
	LoadPhysics();
	LoadTimerSettings();
}

public OnTimerRecord(client, track, style, Float:time, Float:lasttime, currentrank, newrank)
{
	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));

	//General Info
	new Float:fWrTime;
	new iTotalRanks;

	//Record Info
	decl String:sTime[64];

	new Float:fTimeDiff;
	new iStrafeCount;
	new Float:fJumpAcc;
	new bool:bRankedStyle;

	new bool:bNewPersonalRecord;
	new bool:bNewWorldRecord;
	new bool:bFirstRecord;
	new bool:bOnlyTimeImproved;

	// Core
	new bool:enabled = false, jumps, fpsmax;
	Timer_SecondsToTime(time, sTime, sizeof(sTime), 2);
	new Float:fTimeOld;
	Timer_GetClientTimer(client, enabled, fTimeOld, jumps, fpsmax);

	// Physics
	if(g_timerPhysics)
	{
		bRankedStyle = bool:Timer_IsStyleRanked(style);
		Timer_GetJumpAccuracy(client, fJumpAcc);
	}

	// Strafes
	if(g_timerStrafes)
	{
		iStrafeCount = Timer_GetStrafeCount(client);
	}

	if(g_timerWorldRecord)
	{
		/* Get Personal Record */
		if(lasttime > 0.0)
		{
			fTimeDiff = lasttime-time;

			if(fTimeDiff < 0.0)
				fTimeDiff *= -1.0;
		}
		else
		{
			//No personal record, this is his first record
			bFirstRecord = true;
			fTimeDiff = 0.0;
			iTotalRanks++;
		}
	}

	new String:sBeatenName[32], String:sBeatenTime[32];
	new Float:fBeatenTime;

	if(g_timerWorldRecord)
	{
		Timer_GetRecordTimeInfo(style, track, newrank, fBeatenTime, sBeatenTime, 32);
		Timer_GetRecordHolderName(style, track, newrank, sBeatenName, 32);

		/* Get World Record */
		new RecordId;
		Timer_GetStyleRecordWRStats(style, track, RecordId, fWrTime, iTotalRanks);
	}
	
	new Float:fWRDiffTime;
	new String:sWrDiffTime[32];
	
	fWRDiffTime = time-fWrTime;
	Timer_SecondsToTime(fWRDiffTime, sWrDiffTime, sizeof(sWrDiffTime), 2);
	
	if(fWrTime <= 0.0)
		Format(sWrDiffTime, sizeof(sWrDiffTime), "-%s", sWrDiffTime);
	else if(fWrTime <= time)
		Format(sWrDiffTime, sizeof(sWrDiffTime), "+%s", sWrDiffTime);
	else Format(sWrDiffTime, sizeof(sWrDiffTime), "-%s", sWrDiffTime);
	
	//PrintToChat(client, "[DEBUG] %.2f - %.2f = %.2f", time, fWrTime, fWRDiffTime);
	//PrintToChat(client, "[DEBUG] %s", sWrDiffTime);

	/* Detect Record Type */
	if(fWrTime == 0.0 || time < fWrTime)
	{
		bNewWorldRecord = true;
	}

	if(lasttime == 0.0 || time < lasttime)
	{
		bNewPersonalRecord = true;
	}

	if(currentrank == newrank)
		bOnlyTimeImproved = true;

	if(bFirstRecord) iTotalRanks++;

	new Float:fBeatenTimeDiff = time-fBeatenTime;

	new String:BonusString[32];

	if(track == TRACK_BONUS)
	{
		FormatEx(BonusString, sizeof(BonusString), " {olive}bonus");
	}
	else if(track == TRACK_BONUS2)
	{
		FormatEx(BonusString, sizeof(BonusString), " {olive}bonus2");
	}
	else if(track == TRACK_BONUS3)
	{
		FormatEx(BonusString, sizeof(BonusString), " {olive}bonus3");
	}
	else if(track == TRACK_BONUS4)
	{
		FormatEx(BonusString, sizeof(BonusString), " {olive}bonus4");
	}
	else if(track == TRACK_BONUS5)
	{
		FormatEx(BonusString, sizeof(BonusString), " {olive}bonus5");
	}

	new String:RankString[128], String:RankPwndString[128];

	new String:sJumps[128];
	new bool:bAll = false;

	new String:StyleString[128];
	if(g_Settings[MultimodeEnable])
		FormatEx(StyleString, sizeof(StyleString), " on {olive}%s", g_Physics[style][StyleName]);

	if(bNewWorldRecord)
	{
		bAll = true;
		FormatEx(RankString, sizeof(RankString), "{purple} NEW MAP RECORD");

		if(fBeatenTime > 0.0)
		{
			if(bOnlyTimeImproved)
				FormatEx(RankPwndString, sizeof(RankPwndString), "{olive}Improved {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", "himself", fBeatenTimeDiff, sBeatenTime);
			else
				FormatEx(RankPwndString, sizeof(RankPwndString), "{olive}Beaten {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", sBeatenName, fBeatenTimeDiff, sBeatenTime);
		}
	}
	else if(bNewPersonalRecord || bFirstRecord)
	{
		bAll = true;
		FormatEx(RankString, sizeof(RankString), "{lightred}#%d / %d", newrank, iTotalRanks);

		if(newrank < currentrank)
			FormatEx(RankPwndString, sizeof(RankPwndString), "{olive}Beaten {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", sBeatenName, fBeatenTimeDiff, sBeatenTime);
	}
	else if(bNewPersonalRecord)
	{
		FormatEx(RankString, sizeof(RankString), "{orange}#%d / %d", newrank, iTotalRanks);

		Format(RankPwndString, sizeof(RankPwndString), "You have improved {lightred}yourself! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", fBeatenTimeDiff, sBeatenTime);
	}

	if(g_Settings[JumpsEnable])
	{
		FormatEx(sJumps, sizeof(sJumps), "{olive} and {lightred}%d jumps [%.2f ⁰⁄₀]", jumps, fJumpAcc);
	}

	if(g_Settings[StrafesEnable] && g_timerStrafes)
	{
		FormatEx(sJumps, sizeof(sJumps), "{olive} and {lightred}%d strafes", iStrafeCount);
	}

	if(bRankedStyle)
	{
		if(bFirstRecord || bNewPersonalRecord)
		{
			if(bAll)
			{
				CPrintToChatAll("%s {lightred}%s{olive} has finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, name, BonusString, StyleString);
				CPrintToChatAll("{olive}Time: {lightred}%ss (WR %s) %s %s", sTime, sWrDiffTime, sJumps, RankString);
				CPrintToChatAll("%s", RankPwndString);
			}
			else
			{
				CPrintToChat(client, "%s {lightred}You{olive} have finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, BonusString, StyleString);
				CPrintToChat(client, "{olive}Time: {lightred}%ss (WR %s) %s %s", sTime, sWrDiffTime, sJumps, RankString);
				CPrintToChat(client, "%s", RankPwndString);
			}
		}
		else
		{
			CPrintToChat(client, "%s {lightred}You{olive} have finished%s{olive}%s{olive}. Time: {lightred}%ss (WR %s) %s %s", PLUGIN_PREFIX2, BonusString, StyleString, sTime, sWrDiffTime, sJumps, RankString);
		}
	}
	else
	{
		CPrintToChat(client, "{lightred}You{olive} have finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, BonusString, StyleString);
		CPrintToChat(client, "{olive}Time: {lightred}[%ss] %s", sTime, sJumps);
	}
}
