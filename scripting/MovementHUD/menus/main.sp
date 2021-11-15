// =========================================================== //

void DisplayPreferenceMenu(int client)
{
	Menu menu = new Menu(PreferenceMenu_Handler);

	menu.SetTitle("%T", "PrefsMenuTitle", client,
				MHUD_TAG_RAW,
				MHUD_VERSION,
				MHUD_AUTHOR,
				MHUD_PREFERENCES_REVISION);

	char sDisplay[64];
	FormatEx(sDisplay, 64, "%T", "PrefsMenu-SimplePrefs", client);
	menu.AddItem("S", sDisplay);

	FormatEx(sDisplay, 64, "%T", "PrefsMenu-AdvPrefs", client);
	menu.AddItem("A", sDisplay);

	FormatEx(sDisplay, 64, "%T", "PrefsMenu-PrefsHelper", client);
	menu.AddItem("T", sDisplay);

	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int PreferenceMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char itemInfo[2];
		menu.GetItem(param2, itemInfo, sizeof(itemInfo));

		switch (itemInfo[0])
		{
			case 'S': DisplaySimplePreferenceMenu(param1);
			case 'A': DisplayAdvancedPreferenceMenu(param1);
			case 'T': DisplayPreferenceToolsMenu(param1);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

// =========================================================== //