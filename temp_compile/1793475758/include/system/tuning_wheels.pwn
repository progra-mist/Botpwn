/*
Находите паблик LoadOwnableCar

после 	if(vehicleid != INVALID_VEHICLE_ID)
	{

ставьте
//Автор системы: Welsi. (t.me/welsistudio) 
SetVehicleWheels(GetOwnableCarData(idx, OC_SQL_ID), vehicleid); //(Это загрузка настройки шин)


next

В папке include которая находиться в папке pawno (Mod/pawno/include)

Измените файл customtune.inc на новый (новый находиться находиться в .zip) 
Если файл не измените - будут ерроры

НЕ ЗАБУДЬТЕ В КЕШ ДОБАВИТЬ ТЕКСТУРЫ
*/




new Text:welsi_tun_TD[5];
new PlayerText:welsi_tun_PTD[MAX_PLAYERS][11];

enum params_panel_tun 
{
    Float:tun_count_set,
    tun_sct_panel,
    tun_sct_param,
    tun_price,
}

new player_wheel_panel[MAX_PLAYERS][params_panel_tun];


new Float:stock_count_set[4] = 
{
    -0.1,
    0.5,
    0.75,
    0.0
};

new type_setting_wheel[4][2][] = 
{//Автор системы: Welsi. (t.me/welsistudio) 
    {"txd:brtuning3m11", "txd:brtuning3m14"},
    {"txd:brtuning3m12", "txd:brtuning3m15"},
    {"txd:brtuning3m13", "txd:brtuning3m16"},
    {"txd:brtuning3m19", "txd:brtuning3m20"}
};
//Автор системы: Welsi. (t.me/welsistudio) 
new type_panel_settings[4][] = 
{
    {"txd:brtuning3oklirens"},
    {"txd:brtuning3otklirens"},
    {"txd:brtuning3razval"},
    {"txd:brtuning3sizewheel"}
};

new dev_welsi[] = "t.me/welsistudio";

new type_info_settings[4][] = 
{
    {"txd:brtuning3noklirens"},
    {"txd:brtuning3notklirens"},
    {"txd:brtuning3nrazval"},
    {"txd:brtuning3nsizewheel"}
};

stock TextDrawWheels()
{
    welsi_tun_TD[1] = TextDrawCreate(484.6665, 150.4369, "txd:brtuning2service"); // пусто
    TextDrawTextSize(welsi_tun_TD[1], 146.0000, 172.0000);
    TextDrawAlignment(welsi_tun_TD[1], 1);
    TextDrawColor(welsi_tun_TD[1], -1);
    TextDrawBackgroundColor(welsi_tun_TD[1], 255);
    TextDrawFont(welsi_tun_TD[1], 4);
    TextDrawSetProportional(welsi_tun_TD[1], 0);
    TextDrawSetShadow(welsi_tun_TD[1], 0);

    welsi_tun_TD[2] = TextDrawCreate(186.3332, 389.7853, "txd:brtuning3cost"); // пусто
    TextDrawTextSize(welsi_tun_TD[2], 265.0000, 24.0000);
    TextDrawAlignment(welsi_tun_TD[2], 1);
    TextDrawColor(welsi_tun_TD[2], -1);
    TextDrawBackgroundColor(welsi_tun_TD[2], 255);
    TextDrawFont(welsi_tun_TD[2], 4);
    TextDrawSetProportional(welsi_tun_TD[2], 0);
    TextDrawSetShadow(welsi_tun_TD[2], 0);
    welsi_tun_TD[0] = TextDrawCreate(580.9998, 2.0888, "t.me/welsistudio"); // пусто
    welsi_tun_TD[3] = TextDrawCreate(186.9998, 419.6520, "txd:brtuning2buy"); // пусто
    TextDrawTextSize(welsi_tun_TD[3], 116.0000, 24.0000);
    TextDrawAlignment(welsi_tun_TD[3], 1);
    TextDrawColor(welsi_tun_TD[3], -1);
    TextDrawBackgroundColor(welsi_tun_TD[3], 255);
    TextDrawFont(welsi_tun_TD[3], 4);
    TextDrawSetProportional(welsi_tun_TD[3], 0);
    TextDrawSetShadow(welsi_tun_TD[3], 0);
    TextDrawSetSelectable(welsi_tun_TD[3], true);

    welsi_tun_TD[4] = TextDrawCreate(334.6665, 419.6520, "txd:brtuning2exit"); // пусто
    TextDrawTextSize(welsi_tun_TD[4], 116.0000, 24.0000);
    TextDrawAlignment(welsi_tun_TD[4], 1);
    TextDrawColor(welsi_tun_TD[4], -1);
    TextDrawBackgroundColor(welsi_tun_TD[4], 255);
    TextDrawFont(welsi_tun_TD[4], 4);
    TextDrawSetProportional(welsi_tun_TD[4], 0);
    TextDrawSetShadow(welsi_tun_TD[4], 0);
    TextDrawSetSelectable(welsi_tun_TD[4], true);

    TextDrawLetterSize(welsi_tun_TD[0], 0.1480, 0.8740);
    TextDrawTextSize(welsi_tun_TD[0], -101.0000, 0.0000);
    TextDrawAlignment(welsi_tun_TD[0], 1);
    TextDrawColor(welsi_tun_TD[0], -81);
    TextDrawBackgroundColor(welsi_tun_TD[0], 255);
    TextDrawFont(welsi_tun_TD[0], 1);
    TextDrawSetProportional(welsi_tun_TD[0], 1);
    TextDrawSetShadow(welsi_tun_TD[0], 0);
    return 1;
}
//Автор системы: Welsi. (t.me/welsistudio) 

stock TextDrawPlayerWheels(playerid)
{
    welsi_tun_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 503.0000, 165.1257, "txd:brtuning3m11"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][0], 116.0000, 28.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][0], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][0], true);

    welsi_tun_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 503.0000, 203.2888, "txd:brtuning3m12"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][1], 116.0000, 28.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][1], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][1], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][1], true);

    welsi_tun_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 503.0000, 241.0368, "txd:brtuning3m13"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][2], 116.0000, 28.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][2], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][2], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][2], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][2], true);

    welsi_tun_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 503.0000, 278.7850, "txd:brtuning3m19"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][3], 116.0000, 28.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][3], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][3], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][3], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][3], true);

    welsi_tun_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 186.3332, 357.8445, "txd:brtuning3noklirens"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][4], 265.0000, 24.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][4], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][4], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][4], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][4], false);

    welsi_tun_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 3.0000, 181.1333, "txd:brtuning3oklirens"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][5], 164.0000, 115.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][5], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][5], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][5], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][5], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][5], false);

    welsi_tun_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 80.0000, 241.1925, "0.5"); // пусто
    PlayerTextDrawLetterSize(playerid, welsi_tun_PTD[playerid][7], 0.1712, 0.9404);
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][7], -37.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][7], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][7], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][7], 2);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][7], 1);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][7], 0);

    welsi_tun_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 18.3332, 240.8666, "txd:brtuning2stage1"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][6], 131.0000, 9.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][6], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][6], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][6], 0);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][6], 0);

    welsi_tun_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 385.6666, 395.3333, "10000_PYЂ"); // пусто
    PlayerTextDrawLetterSize(playerid, welsi_tun_PTD[playerid][8], 0.2479, 1.1684);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][8], 3);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][8], 8388863);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][8], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][8], 1);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][8], 1);
    PlayerTextDrawSetShadow(playerid, welsi_tun_PTD[playerid][8], 0);

    welsi_tun_PTD[playerid][9] = CreatePlayerTextDraw(playerid,87.6666, 258.7034, "txd:brtuning2plus"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][9], 62.0000, 19.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][9], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][9], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][9], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][9], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][9], true);

    welsi_tun_PTD[playerid][10] = CreatePlayerTextDraw(playerid,18.3332, 259.1184, "txd:brtuning2minus"); // пусто
    PlayerTextDrawTextSize(playerid, welsi_tun_PTD[playerid][10], 62.0000, 19.0000);
    PlayerTextDrawAlignment(playerid, welsi_tun_PTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, welsi_tun_PTD[playerid][10], -1);
    PlayerTextDrawBackgroundColor(playerid, welsi_tun_PTD[playerid][10], 255);
    PlayerTextDrawFont(playerid, welsi_tun_PTD[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, welsi_tun_PTD[playerid][10], 0);
    PlayerTextDrawSetSelectable(playerid, welsi_tun_PTD[playerid][10], true);

    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == welsi_tun_TD[3])
    {
        if(!player_wheel_panel[playerid][tun_sct_panel]) return 1;

        new price = player_wheel_panel[playerid][tun_sct_param] * 1000;

        if(GetPlayerMoneyEx(playerid) >= price)
        {
            GivePlayerMoneyEx(playerid, -price);

            new spend_text[64];
            format(spend_text, sizeof spend_text, "Вы потратили %d рублей", price);
            ShowNotificationNew(playerid, 2, 6, 0, 0, spend_text, "OK");

            new index = GetVehicleData(GetPlayerOwnableCar(playerid), V_ACTION_ID);
            data_UpdateWheelsVehicle(GetOwnableCarData(index, OC_SQL_ID), GetPlayerOwnableCar(playerid));

            SetVehicleWheels(GetOwnableCarData(index, OC_SQL_ID), GetPlayerOwnableCar(playerid));

            if(strcmp(dev_welsi, "t.me/welsistudio", true) != 0) dev_welsi = "t.me/welsistudio";
            TextDrawSetString(welsi_tun_TD[0], dev_welsi);
            
            PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][8], "0000_РУБ");
            for(new i = 5; i < 11;i++) PlayerTextDrawHide(playerid, welsi_tun_PTD[playerid][i]);   

            new old = player_wheel_panel[playerid][tun_sct_panel]-1;
            PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][old], type_setting_wheel[old][0]);
            
            player_wheel_panel[playerid][tun_sct_panel] = 0;
            player_wheel_panel[playerid][tun_count_set] = 0.0;
            player_wheel_panel[playerid][tun_price] = 0;
        }
    }
    if(clickedid == welsi_tun_TD[4])
    {
        new vehicleid = GetPlayerOwnableCar(playerid);

        new index = GetVehicleData(vehicleid, V_ACTION_ID);

        SetPlayerVirtualWorld(playerid, 0);
        SetVehicleVirtualWorld(vehicleid, 0);
        SetVehiclePos(vehicleid, 262.851470,702.168884,11.074938);
        SetVehicleZAngle(vehicleid, 249.617706);
        LinkVehicleToInterior(vehicleid, 0);
        SetPlayerInterior(playerid, 0);

        ShowHud(playerid);
        TogglePlayerControllable(playerid, true);

        SetCameraBehindPlayer(playerid);
        HidePanelWheels(playerid);    

        SetVehicleWheels(GetOwnableCarData(index, OC_SQL_ID), vehicleid);
        PutPlayerInVehicle(playerid, vehicleid, 0);
        CancelSelectTextDraw(playerid);
    }
    #if defined tun_OnPlayerClickTextDraw
        return tun_OnPlayerClickTextDraw(playerid, clickedid);
    #else
        return 1;

    #endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw tun_OnPlayerClickTextDraw
#if defined tun_OnPlayerClickTextDraw
    forward tun_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    new string[24];

    if(playertextid == welsi_tun_PTD[playerid][9])
    {
        if(player_wheel_panel[playerid][tun_sct_param]+1 == 11) return 1;  

        player_wheel_panel[playerid][tun_sct_param]++;

        format(string, sizeof string, "txd:brtuning2stage%d", player_wheel_panel[playerid][tun_sct_param]);
        PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][6], string);

        new vehicleid = GetPlayerVehicleID(playerid);

        if(vehicleid != GetPlayerOwnableCar(playerid)) return SendClientMessage(playerid, -1, "У вас должен быть личный транспорт");
        
        switch(player_wheel_panel[playerid][tun_sct_panel])
        {
            case 1:
            {
                player_wheel_panel[playerid][tun_count_set] += 0.03;
                SetVehicleSuspensionLower(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 2:
            {
                player_wheel_panel[playerid][tun_count_set] += 0.07;
                SetVehicleSuspensionBias(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 3:
            {
                player_wheel_panel[playerid][tun_count_set] += 0.05;
                SetVehicleWheelSize(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 4:
            {
                player_wheel_panel[playerid][tun_count_set] += 2.0;
                SetVehicleWheelAngle(vehicleid, 0, floatround(player_wheel_panel[playerid][tun_count_set]));
                SetVehicleWheelAngle(vehicleid, 1, floatround(player_wheel_panel[playerid][tun_count_set]));
            }
        }

        if(player_wheel_panel[playerid][tun_sct_panel] == 4)
        {
            format(string, sizeof string, "%d", floatround(player_wheel_panel[playerid][tun_count_set]));
            PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][7], string);

        }
        else PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][7], floattostring(player_wheel_panel[playerid][tun_count_set]));

        format(string, sizeof string, "%d000_РУБ", player_wheel_panel[playerid][tun_sct_param]);
        PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][8], string);
        
    }
    if(playertextid == welsi_tun_PTD[playerid][10])
    {
        if(player_wheel_panel[playerid][tun_sct_param]+1 == 1) return 1; 

        player_wheel_panel[playerid][tun_sct_param]--;
                
        format(string, sizeof string, "txd:brtuning2stage%d", player_wheel_panel[playerid][tun_sct_param]);
        PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][6], string);
//Автор системы: Welsi. (t.me/welsistudio) 
        new vehicleid = GetPlayerVehicleID(playerid);

        if(vehicleid != GetPlayerOwnableCar(playerid)) return SendClientMessage(playerid, -1, "У вас должен быть личный транспорт");
        
        switch(player_wheel_panel[playerid][tun_sct_panel])
        {
            case 1:
            {
                player_wheel_panel[playerid][tun_count_set] -= 0.03;
                SetVehicleSuspensionLower(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 2:
            {
                player_wheel_panel[playerid][tun_count_set] -= 0.07;
                SetVehicleSuspensionBias(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 3:
            {
                player_wheel_panel[playerid][tun_count_set] -= 0.05;
                SetVehicleWheelSize(vehicleid, player_wheel_panel[playerid][tun_count_set]);
            }
            case 4:
            {
                player_wheel_panel[playerid][tun_count_set] -= 2.0;
                SetVehicleWheelAngle(vehicleid, 0, floatround(player_wheel_panel[playerid][tun_count_set]));
                SetVehicleWheelAngle(vehicleid, 1, floatround(player_wheel_panel[playerid][tun_count_set]));
            }
        }
        if(player_wheel_panel[playerid][tun_sct_panel] == 4)
        {
            format(string, sizeof string, "%d", floatround(player_wheel_panel[playerid][tun_count_set]));
            PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][7], string);
        }
        else PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][7], floattostring(player_wheel_panel[playerid][tun_count_set]));

        format(string, sizeof string, "%d000_РУБ", player_wheel_panel[playerid][tun_sct_param]);
        PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][8], string);
    }

    for(new i;i<4;i++) if(playertextid == welsi_tun_PTD[playerid][i])  ShowPanelWheels(playerid, i);
	#if defined tun_OnPlayerClickPlayerTextD
		return tun_OnPlayerClickPlayerTextD(playerid, playertextid);
	#else
	    return 0;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTextD
    #undef OnPlayerClickPlayerTextDraw
#else
    #define _ALS_OnPlayerClickPlayerTextD
#endif
#if defined tun_OnPlayerClickPlayerTextD
	forward tun_OnPlayerClickPlayerTextD(playerid, PlayerText:playertextid);
#endif
#define	OnPlayerClickPlayerTextDraw tun_OnPlayerClickPlayerTextD
//Автор системы: Welsi. (t.me/welsistudio) 
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
            new vehicleid = GetPlayerVehicleID(playerid);

            if(GetPlayerOwnableCar(playerid) == vehicleid)
            {
                if(PRESSED(KEY_CROUCH) && IsPlayerInRangeOfPoint(playerid, 5.0, 259.437408,703.648742,11.980160))
                {

                    new world = playerid + 1000;

                    SetPlayerVirtualWorld(playerid, world);
                    SetVehicleVirtualWorld(vehicleid, world);
                    SetVehiclePos(vehicleid, 995.735229,1001.658935,1500.155761);
                    SetVehicleZAngle(vehicleid, 177.443664);
                    LinkVehicleToInterior(vehicleid, 1);
                    SetPlayerInterior(playerid, 1);

                    SetPlayerCameraPos(playerid, 999.656250,998.227416,1501.000000);
                    SetPlayerCameraLookAt(playerid, 995.735229,1001.658935,1500.155761);

                    TextDrawPlayerWheels(playerid);
                    
                    ResetSctWheelsTextD(playerid);

                    TextDrawShowForPlayer(playerid, welsi_tun_TD[1]);
//Автор системы: Welsi. (t.me/welsistudio) 
                    for(new i;i < 4;i++) PlayerTextDrawShow(playerid, welsi_tun_PTD[playerid][i]);

                    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][8], "0000_РУБ");

                    for(new i;i < 5;i++) TextDrawShowForPlayer(playerid, welsi_tun_TD[i]);

                    PlayerTextDrawShow(playerid, welsi_tun_PTD[playerid][4]);
                    PlayerTextDrawShow(playerid, welsi_tun_PTD[playerid][8]);
                    HideHud(playerid);
                    TogglePlayerControllable(playerid, false);
                    SelectTextDraw(playerid, -1);

                    PutPlayerInVehicle(playerid, vehicleid, 0);
                    return 1;
                }//Автор системы: Welsi. (t.me/welsistudio) 
            }
        }
    }
    #if defined tun_OnPlayerKeyStateChange
        return tun_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 0;
    #endif
}//Автор системы: Welsi. (t.me/welsistudio) 
   #if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange tun_OnPlayerKeyStateChange
#if defined tun_OnPlayerKeyStateChange
    forward tun_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif//Автор системы: Welsi. (t.me/welsistudio) 

public OnGameModeInit()
{
    print("[LAIRD_SYSTEM]   Система шиномонтажа загружена.\n Автор: https://t.me/welsistudio");
    Create3DTextLabel("{FFFF00}Шиномонтаж{FFFFFF}\nЧтобы заехать нажмите на гудок", -1, 259.437408,703.648742, 13.980160, 12.0, 0);
    TextDrawWheels();
//Автор системы: Welsi. (t.me/welsistudio) 
    SetTimer("InsertDataBaseWheels", 1300, false);

    #if defined tun_OnGameModeInit
        return tun_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit tun_OnGameModeInit
#if defined tun_OnGameModeInit
    forward tun_OnGameModeInit();
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    //Автор системы: Welsi. (t.me/welsistudio) 
    #if defined tun_OnDialogResponse
return tun_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse tun_OnDialogResponse
#if defined tun_OnDialogResponse
forward tun_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public:InsertDataBaseWheels()
{
    new string[124];

    mysql_format(mysql, string, sizeof string, "SELECT * FROM ownable_cars WHERE wheels_kl AND wheels_otkl AND wheels_raz AND wheels_size");
    mysql_query(mysql, string, false);

    if(mysql_errno())
    {
        mysql_query(mysql, "ALTER TABLE `ownable_cars` ADD `wheels_kl` FLOAT NOT NULL AFTER `model_id`, ADD `wheels_size` FLOAT NOT NULL AFTER `wheels_kl`, ADD `wheels_raz` INT NOT NULL AFTER `wheels_size`, ADD `wheels_otkl` FLOAT NOT NULL AFTER `wheels_raz`", false);

        if(!mysql_errno()) printf("ALTER TABLE 'ownable_cars' complete");
    }

    return 1;
}

stock ResetSctWheelsTextD(playerid)
{
    player_wheel_panel[playerid][tun_sct_param] = 0;
    player_wheel_panel[playerid][tun_count_set] = 0.0;
    player_wheel_panel[playerid][tun_sct_panel] = 0;
    player_wheel_panel[playerid][tun_price] = 0;

    return 1;
}

stock HidePanelWheels(playerid)
{
    for(new i; i < 5;i++) TextDrawHideForPlayer(playerid, welsi_tun_TD[i]);

    for(new i; i < 11;i++) PlayerTextDrawHide(playerid, welsi_tun_PTD[playerid][i]);

    ResetSctWheelsTextD(playerid);

    return 1;
}

stock ShowPanelWheels(playerid, panel = -1)
{
    new old = player_wheel_panel[playerid][tun_sct_panel]-1;
    if(player_wheel_panel[playerid][tun_sct_panel] != 0) PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][old], type_setting_wheel[old][0]);

    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][panel], type_setting_wheel[panel][1]);
    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][5], type_panel_settings[panel]);
    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][4], type_info_settings[panel]);
    
    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][6], "txd:brtuning2stage5");
    PlayerTextDrawSetString(playerid, welsi_tun_PTD[playerid][7], floattostring(stock_count_set[panel]));

    if(strcmp(dev_welsi, "t.me/welsistudio", true) != 0) dev_welsi = "t.me/welsistudio";
    TextDrawSetString(welsi_tun_TD[0], dev_welsi);

    for(new i;i < 11;i++) PlayerTextDrawShow(playerid, welsi_tun_PTD[playerid][i]);
    player_wheel_panel[playerid][tun_count_set] = stock_count_set[panel];
    player_wheel_panel[playerid][tun_sct_panel] = panel+1;
    player_wheel_panel[playerid][tun_sct_param] = 5;
    
    new vehicleid = GetPlayerOwnableCar(playerid);

    new index = GetVehicleData(vehicleid, V_ACTION_ID);

    SetVehicleWheels(GetOwnableCarData(index, OC_SQL_ID), vehicleid);
    return 1;
}

stock floattostring(Float:float)
{
    new string[32];

    format(string, sizeof string, "%.2f", float);

    return string;
}//Автор системы: Welsi. (t.me/welsistudio) 

stock data_UpdateWheelsVehicle(sql, veh)
{
    new string[184];

    mysql_format(mysql, string, sizeof string, "UPDATE ownable_cars SET wheels_kl=%f,wheels_otkl=%f,wheels_size=%f,wheels_raz=%d WHERE id = %d LIMIT 1",
    g_VehHandlingInfo[veh][hpSuspensionLowerLimit], g_VehHandlingInfo[veh][hpSuspensionBias], g_VehHandlingInfo[veh][hpWheelSize],
     g_VehVisualsInfo[veh][vcWheelAlignment][0], sql);
    mysql_query(mysql, string, false);
    if(mysql_errno()) for(new i; i < 10; i++) printf("ERROR %s", string);
}
//Автор системы: Welsi. (t.me/welsistudio) 
stock SetVehicleWheels(sql, vehicle)
{
    new string[164];
    mysql_format(mysql, string, sizeof string, "SELECT * FROM ownable_cars WHERE id = %d", sql);
    new Cache:cache = mysql_query(mysql, string, true);

    if(mysql_errno()) for(new i; i < 10; i++) printf("ERROR %s", string);

    new Float:size = cache_get_field_content_float(0, "wheels_size"),
    Float:otkl = cache_get_field_content_float(0, "wheels_otkl"),
    Float:kl = cache_get_field_content_float(0, "wheels_kl"), razval = cache_get_field_content_int(0, "wheels_raz");

    if(size == 0.0) size = 0.75;
    if(otkl == 0.0) otkl = 0.5;
    if(kl == 0.0)   kl = -0.1;
//Автор системы: Welsi. (t.me/welsistudio) 
    g_VehUsesVisuals[vehicle] = true;
    g_VehVisualsInfo[vehicle][vcWheelAlignment][0] = razval;
    g_VehVisualsInfo[vehicle][vcWheelAlignment][1] = razval;

    foreach(new i : streamed_players_in_veh[vehicle])
	{
		UpdateVehVisuals(i, vehicle);
	}
//Автор системы: Welsi. (t.me/welsistudio) 
    g_VehUsesHandling[vehicle] = true;
    g_VehHandlingInfo[vehicle][hpWheelSize] = size;
    g_VehHandlingInfo[vehicle][hpSuspensionBias] = otkl;
    g_VehHandlingInfo[vehicle][hpSuspensionLowerLimit] = kl;

    foreach(new i : streamed_players_in_veh[vehicle])
    {
        UpdateVehHandling(i, vehicle);
    }


    cache_delete(cache);
    return 1;
}

stock wheel_DestroyVehicle(vehicleid)
{
    ResetHandlingAttributes(vehicleid);
	ResetVehileComponentsDefault(vehicleid);
	ResetVehVisuals(vehicleid);

    return DestroyVehicle(vehicleid);
}
#if defined _ALS_DestroyVehicle
    #undef DestroyVehicle
#else
    #define _ALS_DestroyVehicle
#endif
#define DestroyVehicle wheel_DestroyVehicle