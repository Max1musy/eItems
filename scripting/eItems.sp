#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <ripext>
#include <eItems>
#include <regex>
#pragma newdecls required
#pragma semicolon 1

#define TAG_NCLR "[Max]"
#define AUTHOR "ESK0 (Original author: SM9) & Max1mus"
#define VERSION "1.4"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/parse.sp"
#include "files/natives.sp"
#include "files/forwards.sp"
#include "files/func.sp"
#include "files/generate.sp"

public Plugin myinfo =
{
	name = "eItems",
	author = AUTHOR,
	version = VERSION,
};

public void OnPluginStart()
{
	//Skins
	g_smSkinInfo            = new StringMap();
	g_arSkinsNum            = new ArrayList();

	// Weapons
	g_smWeaponPaints        = new StringMap();
	g_smWeaponInfo          = new StringMap();
	g_arWeaponsNum          = new ArrayList();

	// Gloves
	g_smGlovePaints         = new StringMap();
	g_smGloveInfo           = new StringMap();
	g_arGlovesNum           = new ArrayList();

	// Music Kits
	g_arMusicKitsNum        = new ArrayList();
	g_smMusicKitInfo        = new StringMap();

	// Pins
	g_arPinsNum             = new ArrayList();
	g_smPinInfo             = new StringMap();

	// Patches
	g_arPatchNum            = new ArrayList();
	g_smPatchInfo           = new StringMap();

	// Sprayes
	g_arSprayNum            = new ArrayList();
	g_smSprayInfo           = new StringMap();

	// Crates
	g_arCratesNum            = new ArrayList();
	g_smCratesInfo           = new StringMap();

	// Coins
	g_arCoinsSetsNum        = new ArrayList();
	g_arCoinsNum            = new ArrayList();
	g_smCoinsSets           = new StringMap();
	g_smCoinsInfo           = new StringMap();

	// Stickers
	g_arStickersSetsNum     = new ArrayList();
	g_arStickersNum         = new ArrayList();
	g_smStickersSets        = new StringMap();
	g_smStickersInfo        = new StringMap();
	
	HookEvent("player_death",       Event_PlayerDeath);
	HookEvent("round_poststart",    Event_OnRoundStart);
	HookEvent("cs_pre_restart",     Event_OnRoundEnd);

	AddNormalSoundHook(OnNormalSoundPlayed);

	Handle hConfig = LoadGameConfigFile("sdkhooks.games");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

	g_hSwitchWeaponCall = EndPrepSDKCall();

	CreateTimer(3.0, ParseTimer);
}

public void OnPluginEnd()
{
	delete g_smSkinInfo;
	delete g_arSkinsNum;

	delete g_smWeaponPaints;
	delete g_smWeaponInfo;
	delete g_arWeaponsNum;

	delete g_smGlovePaints;
	delete g_smGloveInfo;  
	delete g_arGlovesNum;

	delete g_arMusicKitsNum;
	delete g_smMusicKitInfo;

	delete g_arPinsNum;
	delete g_smPinInfo;

	delete g_arCoinsSetsNum;
	delete g_arCoinsNum;
	delete g_smCoinsSets;
	delete g_smCoinsInfo;

	delete g_arStickersSetsNum;
	delete g_arStickersNum;
	delete g_smStickersSets;
	delete g_smStickersInfo;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("eItems");

	CreateNatives();
	CreateForwards();
	return APLRes_Success;
}

public Action Event_OnRoundStart(Handle hEvent, char[] szName, bool bDontBroadcast)
{
	g_bIsRoundEnd = false;
}
public Action Event_OnRoundEnd(Handle hEvent, char[] szName, bool bDontBroadcast) 
{
	g_bIsRoundEnd = true;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	ClientInfo[client].GivingWeapon = false;
	
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	ClientInfo[client].Reset();
}

public Action OnNormalSoundPlayed(int clients[64], int &iNumClients, char szSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &iVolume, int &iLevel, int &iPitch, int &iFlags)
{
	if(StrContains(szSample, "itempickup.wav", false) > -1 || StrContains(szSample, "ClipEmpty_Rifle.wav", false) > -1 || StrContains(szSample, "buttons/", false) > -1)
	{
		for(int client = 0; client <= MaxClients; client++)
		{
			if(!IsValidClient(client))
			{
				continue;
			}

			if(ClientInfo[client].GivingWeapon == true)
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action Command_Update(int client ,int args)
{
	GenerateJson();
}

public Action ParseTimer(Handle hdl, any data)
{
	JSONObject jRoot = new JSONObject();
	RegAdminCmd("sm_update",Command_Update, ADMFLAG_ROOT);
	if (!FileExists("addons/sourcemod/data/eItems/eItems.json"))
	{
		PrintToServer("%s 未发现eItems.json文件！", TAG_NCLR);
		GenerateJson();
	}
	else
	{
		jRoot = JSONObject.FromFile("addons/sourcemod/data/eItems/eItems.json");
		if (!jRoot.HasKey("Lastest"))
		{
			PrintToServer("%s 获取最新更新时间失败！", TAG_NCLR);
			GenerateJson();
		}
		else if (GetFileTime("scripts/items/items_game.txt", FileTime_LastChange) > jRoot.GetInt("Lastest"))
		{
			PrintToServer("%s 检测到游戏Items更新！", TAG_NCLR);
			GenerateJson();
		}
		else if (GetFileTime("resource/csgo_schinese.txt", FileTime_LastChange) > jRoot.GetInt("Lastest"))	
		{
			PrintToServer("%s 检测到汉化翻译更新！", TAG_NCLR);
			GenerateJson();
		}
		else
			ParseItems();
	}
	delete jRoot;
}
