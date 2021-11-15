// ======================= LISTENERS ========================= //

void CreateCommands()
{
	RegConsoleCmd("sm_mhud", Command_MHud, "Opens main MovementHUD preference menu");
	RegConsoleCmd("sm_mhud_adv", Command_MHud_Adv, "Opens advanced MovementHUD preference menu");
	RegConsoleCmd("sm_mhud_tools", Command_MHud_Tools, "Opens tools MovementHUD preference menu");
	RegConsoleCmd("sm_mhud_simple", Command_MHud_Simple, "Opens simple MovementHUD preference menu");
	RegConsoleCmd("sm_mhud_preferences_import", Command_MHud_Preferences_Import, "Import MovementHUD preferences from a code");
	RegConsoleCmd("sm_mhud_preferences_export", Command_MHud_Preferences_Export, "Export MovementHUD preferences into a code");

	CreateCommandAliases();
}

void CreatePreferenceCommands()
{
	for (int i = 0; i < gH_Prefs.Length; i++)
	{
		char name[MAX_PREFERENCE_NAME_LENGTH];
		Pref(i).GetName(name, sizeof(name));

		char command[sizeof(name) + 4];
		Format(command, sizeof(command), "sm_%s", name);

		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		Pref(i).GetDisplay(display, sizeof(display));

		RegConsoleCmd(command, Command_Preference, display);
	}
}

static void CreateCommandAliases()
{
	RegConsoleCmd("sm_mhud_settings_import", Command_MHud_Preferences_Import, "Import MovementHUD preferences from a code");
	RegConsoleCmd("sm_mhud_settings_export", Command_MHud_Preferences_Export, "Export MovementHUD preferences into a code");
}

// ========================= PUBLIC ========================== //

public Action Command_MHud(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	DisplayPreferenceMenu(client);
	return Plugin_Handled;
}

public Action Command_MHud_Adv(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	DisplayAdvancedPreferenceMenu(client);
	return Plugin_Handled;
}

public Action Command_MHud_Tools(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	DisplayPreferenceToolsMenu(client);
	return Plugin_Handled;
}

public Action Command_MHud_Simple(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	DisplaySimplePreferenceMenu(client);
	return Plugin_Handled;
}

public Action Command_MHud_Preferences_Import(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	char sMessage[128];

	if (args < 1)
	{
		char cmdName[64];
		GetCmdArg(0, cmdName, sizeof(cmdName));

		FormatEx(sMessage, 128, "%T", "Import-InputPrefsCode", client);
		MHud_Print(client, true, sMessage);

		FormatEx(sMessage, 128, "%T", "Import-InputPrefsCodeFormat", client, cmdName);
		MHud_Print(client, false, sMessage);

		return Plugin_Handled;
	}

	char buffer[256];
	GetCmdArgString(buffer, sizeof(buffer));

	PreferencesCode code = ImportPreferencesFromCode(client, buffer);
	if (!code.Failure)
	{
		char steamId2[32] = "Unknown";
		code.GetSteamId2(steamId2, sizeof(steamId2));
		
		if (code.Revision != MHUD_PREFERENCES_REVISION)
		{
			FormatEx(sMessage, 128, "%T", "Import-PrefsMismatch", client);
			MHud_Print(client, true, sMessage);
		}

		FormatEx(sMessage, 128, "%T", "Import-PrefsFromSteamid", client, steamId2);
		MHud_Print(client, true, sMessage);

		FormatEx(sMessage, 128, "%T", "Import-PrefsFromRevision", client, code.Revision);
		MHud_Print(client, true, sMessage);
	}
	else
	{
		FormatEx(sMessage, 128, "%T", "Import-PrefsFailed", client);
		MHud_Print(client, true, sMessage);
	}

	Call_OnPreferencesImported(client, code);

	delete code;
	return Plugin_Handled;
}

public Action Command_MHud_Preferences_Export(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	char code[256];
	ExportPreferencesToCode(client, code, sizeof(code));

	char sMessage[128];
	FormatEx(sMessage, 128, "%T", "Export-SeeConsoleCode_Pre", client);
	MHud_Print(client, true, sMessage);

	FormatEx(sMessage, 128, "%T", "Export-SeeConsoleCode_Post", client, code);
	PrintToConsole(client, sMessage);

	Call_OnPreferencesExported(client, code);
	return Plugin_Handled;
}

public Action Command_Preference(int client, int args)
{
	if (!MHud_IsValidClient(client))
	{
		return Plugin_Handled;
	}

	char command[MAX_PREFERENCE_NAME_LENGTH + 4];
	GetCmdArg(0, command, sizeof(command));

	Preference pref = gH_Prefs.GetPreferenceByName(command[3]);

	char sMessage[128];

	if (args <= 0)
	{
		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		pref.GetDisplay(display, sizeof(display));

		char value[MAX_PREFERENCE_VALUE_LENGTH];
		pref.GetStringVal(client, value, sizeof(value));

		FormatEx(sMessage, 128, "%T", "Main-SetValue", client, display, value);
		MHud_Print(client, true, sMessage);
	}
	else
	{
		char prefValue[MAX_PREFERENCE_VALUE_LENGTH];
		GetCmdArgString(prefValue, sizeof(prefValue));

		pref.SetVal(client, prefValue);
		
		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		pref.GetDisplay(display, sizeof(display));

		char value[MAX_PREFERENCE_VALUE_LENGTH];
		pref.GetStringVal(client, value, sizeof(value));

		Call_OnPreferenceSet(client, pref, true);

		FormatEx(sMessage, 128, "%T", "Main-SetValue", client, display, value);
		MHud_Print(client, true, sMessage);
	}

	Call_OnPreferenceCommand(client, pref, (args > 0));
	return Plugin_Handled;
}

// =========================================================== //