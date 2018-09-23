#if defined _timer_mapzones_included
 #endinput
#endif
#define _timer_mapzones_included

//Levels
#define LEVEL_START					1
#define LEVEL_END					999
#define LEVEL_BONUS_START			1001
#define LEVEL_BONUS_END				1999
#define LEVEL_BONUS2_START			2001
#define LEVEL_BONUS2_END			2999
#define LEVEL_BONUS3_START			3001
#define LEVEL_BONUS3_END			3999
#define LEVEL_BONUS4_START			4001
#define LEVEL_BONUS4_END			4999
#define LEVEL_BONUS5_START			5001
#define LEVEL_BONUS5_END			5999

// 60 zones types
enum MapZoneType
{
    ZtStart, //0
    ZtEnd, //1
    ZtStop, //2
    ZtRestart, //3
    ZtLast, //4
    ZtNext, //5
	ZtLevel, //6
    ZtBonusStart, //7
    ZtBonusEnd, //8
    ZtBonusLevel, //9
    ZtNPC_Next, //10
	ZtBlock, //11 - Not working
	ZtLimitSpeed, //12
	ZtPlayerClip, //13 - Not working
	ZtLongjump, //14
	ZtBooster, //15
	ZtFullBooster, //16
	ZtArena, //17
	ZtBounceBack, //18
	ZtJail, //19
	ZtPushUp, //20
	ZtBulletTime, //21
	ZtNoGravityOverwrite, //22
	ZtNPC_Next_Double, //23
	ZtNoBoost, //24
	ZtRestartNormalTimer, //25
	ZtRestartBonusTimer, //26
	ZtShortEnd, //27 - Removed
	ZtPushNorth, //28
	ZtPushSouth, //29
	ZtPushWest, //30
	ZtPushEast, //31
	ZtPushDown, //32
	ZtAuto, //33
	ZtNoAuto, //34
	ZtHover, //35
	ZtReset, //36
	ZtFreeStyle, //37
	ZtBlockUse, //38
	ZtBlockDuck, //39
	ZtBlockAttack, //40
	ZtCheckpoint, //41
	ZtBonusCheckpoint, //42
	ZtAntiNoclip, //43
    ZtBonus2Start, //44
    ZtBonus2End, //45
    ZtBonus2Level, //46
	ZtBonus2Checkpoint, //47
    ZtBonus3Start, //48
    ZtBonus3End, //49
    ZtBonus3Level, //50
	ZtBonus3Checkpoint, //51
    ZtBonus4Start, //52
    ZtBonus4End, //53
    ZtBonus4Level, //54
	ZtBonus4Checkpoint, //55
    ZtBonus5Start, //56
    ZtBonus5End, //57
    ZtBonus5Level, //58
	ZtBonus5Checkpoint, //59
	ZtBhop, //60
	ZtAntiCp //61
}

/* Forwards */

/**
 * Called when all zones are loaded from the database.
 *
 * @noreturn
 */
forward OnMapZonesLoaded();

/**
 * Called when a client enters a zone.
 *
 * @param client The client who enters the zone.
 * @param type MapZoneType
 * @noreturn
 */
forward OnClientStartTouchZoneType(client, MapZoneType:type);

/**
 * Called when a client leaves a zone.
 *
 * @param client The client who leaves the zone.
 * @param type MapZoneType
 * @noreturn
 */
forward OnClientEndTouchZoneType(client, MapZoneType:type);


/**
 * Called when a client enters a level zone.
 *
 * @param client The client who enters the level zone.
 * @param level The level id
 * @param lastlevel The clients last known level id
 * @noreturn
 */
forward OnClientStartTouchLevel(client, level, lastlevel);

/**
 * Called when a client enters a bonus level zone.
 *
 * @param client The client who leaves the bonus level zone.
 * @param level The level id
 * @param lastlevel The clients last known bonus level id
 * @noreturn
 */
forward OnClientStartTouchBonusLevel(client, level, lastlevel);

/* Natives */

/**
 * Returns true if the client touches a zone of given type.
 *
 * @param client The target client.
 * @param type MapZoneType to check for.
 * 
 * @return Bool touches or not.
 */
native Timer_IsPlayerTouchingZoneType(client, MapZoneType:type);

/**
 * Returns a level name for a given level ID
 *
 * @param level ID
 * @param name A reference to the level name.
 * @param length Level name reference string length (max 32)
 *
 * @return True if success
 */
native Timer_GetLevelName(id, String:name[], length);

/**
 * Returns clients current level
 *
 * @param client The target client
 * 
 * @return The level.
 */
native Timer_GetClientLevel(client);

/**
 * Overwrites the current client level
 *
 * @param client The target client
 * @param client The new level
 * 
 * @noreturn
 */
native Timer_SetClientLevel(client, level);

/**
 * Returns clients current level ID
 *
 * @param client The target client
 * 
 * @return The level ID.
 */
native Timer_GetClientLevelID(client);

/**
 * Teleports a client to the center of a level zone
 *
 * @param client The target client
 * @param level
 *
 * @return True if success
 */
native Timer_ClientTeleportLevel(client, level);

/**
 * Ignore the next ent touch of start or bonus start zone
 *
 * @param client The target client
 * @param ignore Ignore the next output or not
 * 
 * @noreturn
 */
native Timer_SetIgnoreEndTouchStart(client, ignore);

/**
 * Returns the count of a given map zone type
 *
 * @param type MapZoneType
 * 
 * @return The mapzone count.
 */
native Timer_GetMapzoneCount(MapZoneType:type);

/**
 * Add a new mapzone to timers database
 *
 * @param client The target client
 * @param ignore Ignore the next output or not
 * 
 * @noreturn
 */
native Timer_AddMapZone(String:map[], MapZoneType:type, String:name[], Float:point1[3], Float:point2[3]);
	
public SharedPlugin:__pl_timer_mapzones = 
{
	name = "timer-mapzones",
	file = "timer-mapzones.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public __pl_timer_mapzones_SetNTVOptional() {
	MarkNativeAsOptional("Timer_GetClientLevel");
	MarkNativeAsOptional("Timer_SetClientLevel");
	MarkNativeAsOptional("Timer_GetClientLevelID");
	MarkNativeAsOptional("Timer_GetLevelName");
	MarkNativeAsOptional("Timer_ClientTeleportLevel");

	MarkNativeAsOptional("Timer_SetIgnoreEndTouchStart");
	MarkNativeAsOptional("Timer_IsPlayerTouchingZoneType");
	MarkNativeAsOptional("Timer_GetMapzoneCount");
}

stock bool:Timer_IsPlayerTouchingStartZone(client)
{
	if(Timer_IsPlayerTouchingZoneType(client, ZtStart) || Timer_IsPlayerTouchingZoneType(client, ZtBonusStart) || Timer_IsPlayerTouchingZoneType(client, ZtBonus2Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus3Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus4Start) || Timer_IsPlayerTouchingZoneType(client, ZtBonus5Start))
		return true;
	return false;
}