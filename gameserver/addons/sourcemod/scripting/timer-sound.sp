#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <emitsoundany>

#include <timer>
#include <timer-logging>

#define MAX_FILE_LEN 128

new Handle:g_hTimerFinish = INVALID_HANDLE;
new String:g_sTimerFinish[MAX_FILE_LEN];
new bool:g_bTimerFinish = false;

new Handle:g_hTimerResume = INVALID_HANDLE;
new String:g_sTimerResume[MAX_FILE_LEN];
new bool:g_bTimerResume = false;

new Handle:g_hTimerPause = INVALID_HANDLE;
new String:g_sTimerPause[MAX_FILE_LEN];
new bool:g_bTimerPause = false;

new Handle:g_hTimerWorldRecord = INVALID_HANDLE;
new String:g_sTimerWorldRecord[MAX_FILE_LEN];
new bool:g_bTimerWorldRecord = false;

new Handle:g_hTimerWorldRecordAll = INVALID_HANDLE;
new String:g_sTimerWorldRecordAll[MAX_FILE_LEN];
new bool:g_bTimerWorldRecordAll = false;

new Handle:g_hTimerPersonalBest = INVALID_HANDLE;
new String:g_sTimerPersonalBest[MAX_FILE_LEN];
new bool:g_bTimerPersonalBest = false;

public Plugin:myinfo =
{
    name        = "[Timer] Sounds",
    author      = "Zipcore, Jason Bourne",
    description = "[Timer] Sounds for timer events",
    version     = PL_VERSION,
    url         = "forums.alliedmods.net/showthread.php?p=2074699"
};

public OnPluginStart()
{
  g_hTimerFinish = CreateConVar("timer_sound_finish", "ui/freeze_cam.wav", "");
  g_hTimerWorldRecord = CreateConVar("timer_sound_worldrecord", "ui/freeze_cam.wav", "");
  g_hTimerWorldRecordAll = CreateConVar("timer_sound_worldrecord_all", "ui/freeze_cam.wav", "");
  g_hTimerPause = CreateConVar("timer_sound_pause", "ui/freeze_cam.wav", "");
  g_hTimerResume = CreateConVar("timer_sound_resume", "ui/freeze_cam.wav", "");
  g_hTimerPersonalBest = CreateConVar("timer_sound_personalbest", "ui/freeze_cam.wav", "");

  AutoExecConfig(true, "timer/timer-sounds");
}

public OnConfigsExecuted()
{
  CacheSounds();
  Timer_LogTrace("[Sound] Sounds cached OnConfigsExecuted");
}

public CacheSounds()
{
  GetConVarString(g_hTimerFinish, g_sTimerFinish, sizeof(g_sTimerFinish));
  GetConVarString(g_hTimerPause, g_sTimerPause, sizeof(g_sTimerPause));
  GetConVarString(g_hTimerResume, g_sTimerResume, sizeof(g_sTimerResume));
  GetConVarString(g_hTimerWorldRecord, g_sTimerWorldRecord, sizeof(g_sTimerWorldRecord));
  GetConVarString(g_hTimerWorldRecordAll, g_sTimerWorldRecordAll, sizeof(g_sTimerWorldRecordAll));
  GetConVarString(g_hTimerPersonalBest, g_sTimerPersonalBest, sizeof(g_sTimerPersonalBest));

  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerFinish, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerFinish, ".mp3", false) || StrContains(g_sTimerFinish, ".wav", false))
  {
    g_bTimerFinish = PrepareSound(g_sTimerFinish);
  }
  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerPause, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerPause, ".mp3", false) || StrContains(g_sTimerPause, ".wav", false))
  {
    g_bTimerPause = PrepareSound(g_sTimerPause);
  }
  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerResume, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerResume, ".mp3", false) || StrContains(g_sTimerResume, ".wav", false))
  {
    g_bTimerResume = PrepareSound(g_sTimerResume);
  }
  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerWorldRecord, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerWorldRecord, ".mp3", false) || StrContains(g_sTimerWorldRecord, ".wav", false))
  {
    g_bTimerWorldRecord = PrepareSound(g_sTimerWorldRecord);
  }
  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerWorldRecordAll, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerWorldRecordAll, ".mp3", false) || StrContains(g_sTimerWorldRecordAll, ".wav", false))
  {
    g_bTimerWorldRecordAll = PrepareSound(g_sTimerWorldRecordAll);
  }
  if(GetEngineVersion() == Engine_CSGO && StrContains(g_sTimerPersonalBest, ".mp3", false) || GetEngineVersion() == Engine_CSS && StrContains(g_sTimerPersonalBest, ".mp3", false) || StrContains(g_sTimerPersonalBest, ".wav", false))
  {
    g_bTimerPersonalBest = PrepareSound(g_sTimerPersonalBest);
  }
}

public bool:PrepareSound(String: sound[MAX_FILE_LEN])
{
  decl String:fileSound[MAX_FILE_LEN];

  FormatEx(fileSound, MAX_FILE_LEN, "sound/%s", sound);

  if (FileExists(fileSound) && g_bTimerWorldRecord)
  {
    new bool:bReturn;
    bReturn = PrecacheSoundAny(sound, true);
    AddFileToDownloadsTable(fileSound);
    Timer_LogTrace("[Sound] File '%s' added to downloads table.", fileSound);

    return bReturn;
  }
  return false;
}

public OnTimerPaused(client)
{
  if(g_bTimerPause)
  {
    EmitSoundToClientAny(client, g_sTimerPause);
  }
}

public OnTimerResumed(client)
{
  if(g_bTimerResume)
  {
    EmitSoundToClientAny(client, g_sTimerResume);
  }
}

public OnTimerWorldRecord(client)
{
  if(g_bTimerWorldRecordAll)
  {
    //Stop the sound first
    EmitSoundToAllAny(g_sTimerWorldRecordAll, _, _, _, SND_STOPLOOPING);

    EmitSoundToAllAny(g_sTimerWorldRecordAll);
  }
}

public OnTimerPersonalRecord(client)
{
  if(g_bTimerPersonalBest)
  {
    EmitSoundToClientAny(client, g_sTimerPersonalBest);
  }
}

public OnTimerRecord(client)
{
  if(g_bTimerFinish)
  {
    EmitSoundToClientAny(client, g_sTimerFinish);
  }
}
