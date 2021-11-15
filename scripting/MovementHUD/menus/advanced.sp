// =========================================================== //

static int _AdvancedOptions[] =
{
	Pref_Speed_Position,
	Pref_Speed_Normal_Color,
	Pref_Speed_Perf_Color,
	Pref_Keys_Position,
	Pref_Keys_Normal_Color,
	Pref_Keys_Overlap_Color
};

// =========================================================== //

void DisplayAdvancedPreferenceMenu(int client, int atItem = 0)
{
	Menu menu = new Menu(AdvancedPreferenceMenu_Handler);

	menu.SetTitle(MHUD_TAG_RAW ... " %T", "AdvPrefsMenuTitle", client);

	for (int i = 0; i < sizeof(_AdvancedOptions); i++)
	{
		int pref = _AdvancedOptions[i];

		char menuInfo[12];
		IntToString(pref, menuInfo, sizeof(menuInfo));

		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		Pref(pref).GetDisplay(display, sizeof(display));

		char value[MAX_PREFERENCE_VALUE_LENGTH];
		Pref(pref).GetStringVal(client, value, sizeof(value));

		char menuItem[sizeof(display) + sizeof(value) + 3];
		Format(menuItem, sizeof(menuItem), "%s: %s", display, value);

		menu.AddItem(menuInfo, menuItem);
	}

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.DisplayAt(client, atItem, MENU_TIME_FOREVER);
}

public int AdvancedPreferenceMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char itemInfo[12];
		menu.GetItem(param2, itemInfo, sizeof(itemInfo));

		Preference pref = Pref(StringToInt(itemInfo));
		ExpectInputForClient(param1, pref.Pref, menu.Selection);

		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		pref.GetDisplay(display, sizeof(display));

		char sMessage[128];
		FormatEx(sMessage, 128, "%T", "AdvPrefsInputValue", param1, display);
		MHud_Print(param1, true, sMessage);

		switch (pref.Type)
		{
			case PrefType_XY:
			{
				FormatEx(sMessage, 128, "%T", "AdvPrefsInputFormatXY", param1);
				MHud_Print(param1, false, sMessage);
			}
			case PrefType_RGBA:
			{
				FormatEx(sMessage, 128, "%T", "AdvPrefsInputFormatRGB", param1);
				MHud_Print(param1, false, sMessage);
			}
		}

		FormatEx(sMessage, 128, "%T", "AdvPrefsInputCancel", param1);
		MHud_Print(param1, false, sMessage);

		FormatEx(sMessage, 128, "%T", "AdvPrefsInputReset", param1);
		MHud_Print(param1, false, sMessage);

		FormatEx(sMessage, 128, "%T", "AdvPrefsInputCancelDelay", param1, INPUT_TIMEOUT);
		MHud_Print(param1, false, sMessage);

		Call_OnExpectingInput(param1, pref);
	}
	else if (action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		DisplayPreferenceMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

// =========================================================== //