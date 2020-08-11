#include <sourcemod>
#include <sdktools>

#define PLUGIN_AUTHOR "bryson"
#define PLUGIN_VERSION "1.0.1"

#pragma semicolon 1
#pragma newdecls required

Handle g_hEnabled = INVALID_HANDLE;
bool g_bEnabled = false;

public Plugin myinfo = 
{
	name = "Open Fortress Melee Only", 
	author = PLUGIN_AUTHOR, 
	description = "Enables/Disables melee only mode for Open Fortress", 
	version = PLUGIN_VERSION, 
	url = "https://cantfraglike.me"
};

public void OnPluginStart()
{
	CreateConVar("sm_ofmelee_version", PLUGIN_VERSION, "Open Fortress melee only version.");
	g_hEnabled = CreateConVar("sm_ofmelee_enabled", "0", "Enable/Disable melee only mode.");
	RegAdminCmd("sm_ofmelee", cmd_active, ADMFLAG_KICK, "Start/Stop melee only!");
	HookConVarChange(g_hEnabled, Cvar_enabled);
	PrintToServer("(!)Open Fortress melee only by %s loaded...", PLUGIN_AUTHOR);
}

public void OnMapStart()
{
	ServerCommand("sm_ofmelee 0");
	CreateTimer(1, meleeOn);
}

public void OnConfigsExecuted()
{
	g_bEnabled = GetConVarBool(g_hEnabled);
}

public void Cvar_enabled(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bEnabled = GetConVarBool(g_hEnabled);
	if (g_bEnabled)
	{
		meleeOn(INVALID_HANDLE);
		ServerCommand("say ---------------------");
		ServerCommand("say Melee Mode Activated!");
		ServerCommand("say ---------------------");
		ServerCommand("of_weaponspawners 0");
		ServerCommand("of_spawn_with_weapon tf_weapon_crowbar");
		ServerCommand("of_multiweapons 0");
		ServerCommand("mp_fraglimit 15");
		ServerCommand("mp_restartgame 1");
	}
	else
	{
		ServerCommand("say -----------------------");
		ServerCommand("say Melee Mode Deactivated!");
		ServerCommand("say -----------------------");
		ServerCommand("exec config_dm.cfg"); //Executes dm config.
	}
}

// The actual annoying bit if weapons still exist for some reason
public Action meleeOn(Handle timer)
{
	int ent;
	char wpn[128];
	int x = 1;
	while (x <= MaxClients)
	{
		if (IsClientConnected(x) && IsClientInGame(x) && IsPlayerAlive(x))
		{
			int y = 0;
			while (y < 9)
			{
				if ((ent = GetPlayerWeaponSlot(x, y)) != -1)
				{
					GetEdictClassname(ent, wpn, 64);
					if (!(StrEqual(wpn, "tf_weapon_crowbar", true)))
					{
						int weaponIndex;
						while ((weaponIndex = GetPlayerWeaponSlot(x, y)) != -1)
						{
							RemovePlayerItem(x, weaponIndex);
						}
					}
				}
				y++;
			}
		}
		x++;
	}
	if (g_bEnabled)
	{
		CreateTimer(1, meleeOn);
	}
}

public Action cmd_active(int client, int args)
{
	if (!(args == 1))
	{
		ReplyToCommand(client, "[SM] Usage: sm_ofmelee 1/0 (1 = Start, 0 = Stop)");
		return Plugin_Handled;
	}
	
	char input[32];
	GetCmdArg(1, input, sizeof(input));
	
	int val = StringToInt(input);
	
	switch (val)
	{
		case 0:
		{
			ServerCommand("sm_ofmelee_enabled 0");
		}
		case 1:
		{
			ServerCommand("sm_ofmelee_enabled 1");
		}
		default:
		{
			ReplyToCommand(client, "[SM] Usage: sm_ofmelee 1/0 (1 = Start, 0 = Stop)");
		}
	}
	return Plugin_Handled;
} 