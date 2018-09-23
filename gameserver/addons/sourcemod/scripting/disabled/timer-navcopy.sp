#pragma semicolon 1

#include <sourcemod>

public OnPluginStart()
{
	CreateNavFiles();
}

public CreateNavFiles()
{
	new String:DestFile[256];
	new String:SourceFile[256];
	Format(SourceFile, sizeof(SourceFile), "maps/replay_bot.nav");
	if (!FileExists(SourceFile))
	{
		LogError("Failed to create .nav files. Reason: %s doesn't exist!", SourceFile);
		return;
	}
	
	new Handle:hDir = OpenDirectory("maps");
	if(hDir == INVALID_HANDLE)
		return;
	
	new String:sFile[64], FileType:fileType;
	while(ReadDirEntry(hDir, sFile, sizeof(sFile), fileType))
	{
		switch(fileType)
		{
			case FileType_File:
			{
				if(StrContains(sFile, ".bsp") != -1)
				{
					ReplaceString(sFile, sizeof(sFile), ".bsp", "");
					Format(DestFile, sizeof(DestFile), "maps/%s.nav", sFile);
					if (!FileExists(DestFile))
						File_Copy(SourceFile, DestFile);
				}
			}
		}
		
	}
	CloseHandle(hDir);
}

stock bool:File_Copy(const String:source[], const String:destination[])
{
	new Handle:file_source = OpenFile(source, "rb");
	if (file_source == INVALID_HANDLE)
	{
		return false;
	}
	
	new Handle:file_destination = OpenFile(destination, "wb");
	if (file_destination == INVALID_HANDLE)
	{
		CloseHandle(file_source);
		return false;
	}
	
	new buffer[32];
	new cache;
	
	while (!IsEndOfFile(file_source))
	{
		cache = ReadFile(file_source, buffer, 32, 1);
		WriteFile(file_destination, buffer, cache, 1);
	}
	
	CloseHandle(file_source);
	CloseHandle(file_destination);
	return true;
}