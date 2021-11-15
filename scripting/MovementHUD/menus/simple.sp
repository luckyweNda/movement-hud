// =========================================================== //

static char _Colors[][][] =
{
	{ "255 0 0", "Red" },
	{ "0 255 0", "Green" },
	{ "75 100 0", "Lime" },
	{ "0 0 255", "Blue" },
	{ "0 255 255", "Cyan" },
	{ "255 215 0", "Yellow" },
	{ "255 165 0", "Orange" },
	{ "128 0 128", "Purple" },
	{ "255 255 255", "White" },
	{ "0 0 0", "Black" },
	{ "128 128 128", "Gray" }
};

static char _Positions[][][] =
{
	{ "-1.00 0.85", "Bottom" },
	{ "0.10 0.90", "Bottom left" },
	{ "0.66 0.90", "Bottom right" },
	{ "-1.00 0.70", "Middle" },
	{ "0.10 0.70", "Middle left" },
	{ "0.66 0.70", "Middle right" },
	{ "-1.00 0.10", "Top" },
	{ "0.10 0.10", "Top left" },
	{ "0.66 0.10", "Top right" }
};

static char _SpeedDisplays[][][] =
{
	{ "0", "Disabled" },
	{ "1", "Float" },
	{ "2", "Integer" }
};

static char _KeysDisplays[][][] =
{
	{ "0", "Disabled" },
	{ "1", "Blanks as underscores" },
	{ "2", "Blanks invisible" }
};

static char _KeysMouseDirection[][][] =
{
	{ "0", "Disabled" },
	{ "1", "Style 1" },
	{ "2", "Style 2" }
};

// =========================================================== //

static void SetNextPresetVal(int client, Preference pref, char[][][] values, int maxItems)
{
	char value[MAX_PREFERENCE_VALUE_LENGTH];
	pref.GetStringVal(client, value, sizeof(value));

	int oldPreset = GetPresetOrDefault(value, values, maxItems);
	int newPreset = ClampInt(++oldPreset, maxItems - 1);

	pref.SetVal(client, values[newPreset][0]);
	Call_OnPreferenceSet(client, pref, false);
}

static int GetPresetOrDefault(char[] value, char[][][] values, int maxItems, int maxlength = -1)
{
	bool shouldCopy = maxlength != -1;
	for (int i = 0; i < maxItems; i++)
	{
		if (StrEqual(value, values[i][0]))
		{
			if (shouldCopy)
				strcopy(value, maxlength, values[i][1]);

			return i;
		}
	}

	if (shouldCopy)
		strcopy(value, maxlength, "Custom");

	return -1;
}

void DisplaySimplePreferenceMenu(int client, int atItem = 0)
{
	Menu menu = new Menu(SimplePreferenceMenu_Handler);
	menu.SetTitle(MHUD_TAG_RAW ... " %T", "SimplePrefsMenuTitle", client);

	char sDisplay[64];
	FormatEx(sDisplay, 64, "%T", "SimplePrefsMenuItem-Reserved", client);

	for (int i = 0; i < PREF_COUNT; i++)
	{
		if (i == Pref_Speed_Display + 1)
		{
			menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);
			menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);
		}
		
		if (i == Pref_Keys_Display + 1)
		{
			menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);
		}

		Preference pref = Pref(i);

		char menuInfo[12];
		IntToString(i, menuInfo, sizeof(menuInfo));

		char display[MAX_PREFERENCE_DISPLAY_LENGTH];
		pref.GetDisplay(display, sizeof(display));

		char value[MAX_PREFERENCE_VALUE_LENGTH];
		pref.GetStringVal(client, value, sizeof(value));

		if (pref.Type == PrefType_RGBA)
		{
			GetPresetOrDefault(value, _Colors, sizeof(_Colors), sizeof(value));
		}
		else if (pref.Type == PrefType_XY)
		{
			GetPresetOrDefault(value, _Positions, sizeof(_Positions), sizeof(value));
		}
		else if (pref.Type == PrefType_Numeric)
		{
			switch (pref.Pref)
			{
				case Pref_Keys_Display:
				{
					GetPresetOrDefault(value, _KeysDisplays, sizeof(_KeysDisplays), sizeof(value));
				}
				case Pref_Keys_Mouse_Direction:
				{
					GetPresetOrDefault(value, _KeysMouseDirection, sizeof(_KeysMouseDirection), sizeof(value));
				}
				case Pref_Speed_Display:
				{
					GetPresetOrDefault(value, _SpeedDisplays, sizeof(_SpeedDisplays), sizeof(value));
				}
			}
		}

		char menuItem[sizeof(display) + sizeof(value) + 3];
		Format(menuItem, sizeof(menuItem), "%s: %s", display, value);

		menu.AddItem(menuInfo, menuItem);
	}

	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.DisplayAt(client, atItem, MENU_TIME_FOREVER);
}

public int SimplePreferenceMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char itemInfo[12];
		menu.GetItem(param2, itemInfo, sizeof(itemInfo));

		Preference pref = Pref(StringToInt(itemInfo));

		if (pref.Type == PrefType_RGBA)
		{
			SetNextPresetVal(param1, pref, _Colors, sizeof(_Colors));
		}
		else if (pref.Type == PrefType_XY)
		{
			SetNextPresetVal(param1, pref, _Positions, sizeof(_Positions));
		}
		else if (pref.Type == PrefType_Numeric)
		{
			switch (pref.Pref)
			{
				case Pref_Keys_Display:
				{
					SetNextPresetVal(param1, pref, _KeysDisplays, sizeof(_KeysDisplays));
				}
				case Pref_Keys_Mouse_Direction:
				{
					SetNextPresetVal(param1, pref, _KeysMouseDirection, sizeof(_KeysMouseDirection));
				}
				case Pref_Speed_Display:
				{
					SetNextPresetVal(param1, pref, _SpeedDisplays, sizeof(_SpeedDisplays));
				}
			}
		}

		DisplaySimplePreferenceMenu(param1, menu.Selection);
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