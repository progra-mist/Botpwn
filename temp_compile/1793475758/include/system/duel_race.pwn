
new Text:race_time_TD[3];
new PlayerText:race_time_PTD[MAX_PLAYERS][1];
new Float:old_player_pos[MAX_PLAYERS][3];
new bool:player_active_race[MAX_PLAYERS];
new player_opponent[MAX_PLAYERS];
new player_type_race[MAX_PLAYERS];
new vehicle_get_race[3] = {415, 466, 2582};
new race_countdown[MAX_PLAYERS];
new race_timer[MAX_PLAYERS];
new count_cp_race_duel[MAX_PLAYERS];
new player_vehicle_race[MAX_PLAYERS];


new Float:plant_race[3][2][4] =
{
    {
        {-2661.888671,288.090179,10.231406,0.772217}, //drag
        {-2656.990478,286.872589,10.240604,2.267567}
    },
    {
        {-1062.957397,420.127868,19.687501,126.699462},
        {-1057.834228,416.046295,19.333488,127.455589}
    },
    {
        {-1564.057983,1620.004760,35.569328,179.444671},
        {-1573.792968,1620.631469,35.569332,181.884414}
    }
};

new Float:duel_race_checkpoint[3][10][3] =
{
    {
        {-2659.530517,313.169677,10.132984},
        {-2660.022705,366.742614,10.133008},
        {-2660.388916,408.077209,10.125883},
        {-2660.784179,449.550079,10.133122},
        {-2660.817138,507.941284,10.133131},
        {-2661.602050,557.281921,10.133122},
        {-2662.288085,620.113708,10.128241},
        {-2662.301269,691.310180,10.184211},
        {-2661.525634,776.649963,10.184211},
        {-2661.085693,1089.281982,10.16306}
    },
    {
        {-1101.545654,382.158874,22.436738},
        {-1197.839843,298.251495,29.505628},
        {-1293.060058,324.063201,31.535488},
        {-1370.412841,434.071868,30.148563},
        {-1458.486206,583.771545,30.210426},
        {-1592.789550,754.759399,30.182073},
        {-1782.680908,803.804077,34.745792},
        {-1941.929565,733.077697,28.717844},
        {-1936.335937,541.530334,28.273136},
        {-1995.000366,483.752105,28.660846}
    },
    {
        {-1568.330200,1502.173461,35.569343},
        {-1646.631225,1448.845581,32.294979},
        {-1701.495971,1389.389770,35.276367},
        {-1847.851806,1398.194091,34.359714},
        {-1905.618164,1492.300292,34.787559},
        {-1789.434326,1555.246582,34.701751},
        {-1702.395751,1566.478393,35.402069},
        {-1777.328125,1639.807250,35.900726},
        {-1822.116333,1719.536254,34.631591},
        {-1569.709228,1745.971557,36.422080}
    }
};

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 1877)
    {
        if(response)
        {
            new to_player = GetPVarInt(playerid, "select_opponent");

            if(!GetPVarInt(playerid, "selection_listitem"))
            {
                SetPVarInt(playerid, "selection_listitem", listitem + 1);

                Dialog
                (
                    playerid, 1877, DIALOG_STYLE_INPUT, 
                    "Гоночные дуэли | Вознаграждениe",
                    "Напишите какое вознаграждение получит {FFFF00}победитель\n"\
                    "{FFFFFF}Если вы хотите без вознаграждения напишите {FFFF00}0\n"\
                    "{FFFFFF}Число не должно быть больше 10.000.000 рублей",
                    "Далее", "Назад"
                );
            }
            else
            {
                new Float: x, Float: y, Float: z;
	            GetPlayerPos(to_player, x, y, z);
            
	            new Float: dist = GetPlayerDistanceFromPoint(playerid, x, y, z);
            
                if(dist > 7.0)
                {
                    SendClientMessage(playerid, -1, ""USC" Игрок слишком далеко.");
                    SendClientMessage(to_player, -1, ""USC" Вы отошли слишком далеко.");
                    return 1;
                } 

                new money = strval(inputtext);

                if(money > 10_000_000)
                {
                    DeletePVar(playerid, "selection_listitem");

                    SendClientMessage(playerid, -1, ""SC" Сумма превышает 10.000.000 рублей");
                    OnDialogResponse(playerid, 1877, 1, -1, "");
                    return 1;
                }

                if(!(GetPlayerMoneyEx(playerid) >= money) || !(GetPlayerMoneyEx(to_player) >= money))   
                    return SendClientMessage(playerid, -1, ""SC" У одного из игроков не хватает денег.");


                SetPVarInt(playerid, "money_race", money);
                SetPVarInt(to_player, "money_race", money);

                player_opponent[playerid] = to_player;
                player_opponent[to_player] = playerid;
                
                LoadDuelRace(GetPVarInt(playerid, "selection_listitem") - 1, playerid, to_player);
                DeletePVar(playerid, "selection_listitem");
            }
        }
    }
    #if defined race_OnDialogResponse
return race_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse race_OnDialogResponse
#if defined race_OnDialogResponse
forward race_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(player_active_race[playerid])
    {
        if(!GetPlayerAdminEx(playerid)) return SendClientMessage(playerid, -1, ""USC" Вы участвуете в гонке с игроком. В данный момент команды не работают");
    } 
    
    #if defined race_OnPlayerCommandText
        return race_OnPlayerCommandText(playerid, cmdtext);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerCommandText
    #undef OnPlayerCommandText
#else
    #define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText race_OnPlayerCommandText
#if defined race_OnPlayerCommandText
    forward race_OnPlayerCommandText(playerid, cmdtext[]);
#endif

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(player_active_race[playerid])
    {
        DisablePlayerRaceCheckpoint(playerid);

        new count_cp = count_cp_race_duel[playerid], type = player_type_race[playerid], finish_check_point, text[59];

        //format(text, sizeof text, "Count CheckPoint: %d", count_cp);
        //SendClientMessage(playerid, -1, text);

        switch(player_type_race[playerid])
        {
            case 0:
            {
                switch(count_cp)
                {
                    case 9:
                    {
                             SetPlayerRaceCheckpoint(playerid, 1, duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], \
                        duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], 10.0);
                    }
                    case 10: finish_check_point++;
                    default:
                    {
                            SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], \
                        duel_race_checkpoint[type][count_cp + 1][0], duel_race_checkpoint[type][count_cp + 1][1], duel_race_checkpoint[type][count_cp + 1][2], 10.0);   
                    }
                }              
            }
            case 1:
            {
                switch(count_cp)
                {
                    case 9:
                    {
                             SetPlayerRaceCheckpoint(playerid, 1, duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], \
                        duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], 10.0);
                    }
                    case 10: finish_check_point++;
                    default:
                    {
                            SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], \
                        duel_race_checkpoint[type][count_cp + 1][0], duel_race_checkpoint[type][count_cp + 1][1], duel_race_checkpoint[type][count_cp + 1][2], 10.0);   
                    }
                } 
            }
            case 2:
            {
                switch(count_cp)
                {
                    case 9:
                    {
                        SendClientMessage(playerid, -1, "{FFF000}Вы проехали первый круг");
                        SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2], \
                        duel_race_checkpoint[type][1][0], duel_race_checkpoint[type][1][1], duel_race_checkpoint[type][1][2], 10.0);
                    }
                    case 19:
                    {
                        SendClientMessage(playerid, -1, "{FFF000}Вы проехали второй круг");
                        SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2], \
                        duel_race_checkpoint[type][1][0], duel_race_checkpoint[type][1][1], duel_race_checkpoint[type][1][2], 10.0);
                    }
                    case 29:
                    {
                         SetPlayerRaceCheckpoint(playerid, 1, duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2], \
                         duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2], 10.0);
                    }
                    case 30:finish_check_point++;
                    case 1..8:
                    {
                        SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][count_cp][0], duel_race_checkpoint[type][count_cp][1], duel_race_checkpoint[type][count_cp][2], \
                        duel_race_checkpoint[type][count_cp + 1][0], duel_race_checkpoint[type][count_cp + 1][1], duel_race_checkpoint[type][count_cp + 1][2], 10.0);
                    }
                    case 10..18:
                    {
                        new count =  count_cp - 10;
                        SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][count][0], duel_race_checkpoint[type][count][1], duel_race_checkpoint[type][count][2], \
                        duel_race_checkpoint[type][count + 1][0], duel_race_checkpoint[type][count + 1][1], duel_race_checkpoint[type][count + 1][2], 10.0);
                    }
                    case 20..28:
                    {
                        new count =  count_cp - 20;
                        SetPlayerRaceCheckpoint(playerid, 0, duel_race_checkpoint[type][count][0], duel_race_checkpoint[type][count][1], duel_race_checkpoint[type][count][2], \
                        duel_race_checkpoint[type][count + 1][0], duel_race_checkpoint[type][count + 1][1], duel_race_checkpoint[type][count + 1][2], 10.0);
                    }
                }
            }
        }
        if(finish_check_point) return ResultDuelRace(playerid, player_opponent[playerid]);
        
        count_cp_race_duel[playerid]++;       
    }
	#if defined re_OnPlayerEnterRaceCP
		return re_OnPlayerEnterRaceCP(playerid);
	#else
	    return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterRaceCP
    #undef OnPlayerEnterRaceCheckpoint
#else
    #define _ALS_OnPlayerEnterRaceCP
#endif
#if defined re_OnPlayerEnterRaceCP
	forward re_OnPlayerEnterRaceCP(playerid);
#endif
#define	OnPlayerEnterRaceCheckpoint re_OnPlayerEnterRaceCP

public OnPlayerEnterDynamicArea(playerid, areaid)
{

    #if defined race_OnPlayerEnterDynamicArea
        return race_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea race_OnPlayerEnterDynamicArea
#if defined race_OnPlayerEnterDynamicArea
    forward race_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif


public OnGameModeInit()
{
    print("[LAIRD_SYSTEM] Гоночные дуэли загружены\н");
    TextDrawRace();
    #if defined race_OnGameModeInit
        return race_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit race_OnGameModeInit
#if defined race_OnGameModeInit
    forward race_OnGameModeInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    if(player_active_race[playerid])
    {
        ResultDuelRace(player_opponent[playerid], playerid);
        SendClientMessage(player_opponent[playerid], -1, ""SC" Ваш соперник вышел из игры. Вы автомотически выйгрываете");
    }

    #if defined race_OnPlayerDisconnect
        return race_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect race_OnPlayerDisconnect
#if defined race_OnPlayerDisconnect
    forward race_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerConnect(playerid)
{
    player_vehicle_race[playerid] = -1;
    RemovePlayerNew(playerid);

    #if defined race_OnPlayerConnect
        return race_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect race_OnPlayerConnect
#if defined race_OnPlayerConnect
    forward race_OnPlayerConnect(playerid);
#endif

public OnPlayerSpawn(playerid)
{
    if(player_active_race[playerid]) RemoveDuelRace(playerid, player_opponent[playerid]);
    #if defined race_OnPlayerSpawn
        return race_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn race_OnPlayerSpawn
#if defined race_OnPlayerSpawn
    forward race_OnPlayerSpawn(playerid);
#endif


stock TextDrawRace()
{
    race_time_TD[0] = TextDrawCreate(294.6666, 39.4222, "_"); // пусто
    TextDrawLetterSize(race_time_TD[0], 0.0767, 2.8069);
    TextDrawTextSize(race_time_TD[0], 346.0000, 0.0000);
    TextDrawAlignment(race_time_TD[0], 1);
    TextDrawColor(race_time_TD[0], 41215);
    TextDrawUseBox(race_time_TD[0], 1);
    TextDrawBoxColor(race_time_TD[0], 255);
    TextDrawBackgroundColor(race_time_TD[0], -1);
    TextDrawFont(race_time_TD[0], 0);
    TextDrawSetProportional(race_time_TD[0], 0);
    TextDrawSetShadow(race_time_TD[0], 0);
    TextDrawSetSelectable(race_time_TD[0], true);

    race_time_TD[2] = TextDrawCreate(298.9998, 40.2518, "OCЏA‡OC’_‹PEMEH…:"); // пусто
    TextDrawLetterSize(race_time_TD[2], 0.1298, 0.9527);
    TextDrawTextSize(race_time_TD[2], 20.0000, 0.0000);
    TextDrawAlignment(race_time_TD[2], 1);
    TextDrawColor(race_time_TD[2], -1);
    TextDrawBackgroundColor(race_time_TD[2], 255);
    TextDrawFont(race_time_TD[2], 1);
    TextDrawSetProportional(race_time_TD[2], 1);
    TextDrawSetShadow(race_time_TD[2], 0);

    race_time_TD[1] = TextDrawCreate(295.6667, 40.2519, "_"); // пусто
    TextDrawLetterSize(race_time_TD[1], -0.0279, 2.4709);
    TextDrawTextSize(race_time_TD[1], 345.0000, 0.0000);
    TextDrawAlignment(race_time_TD[1], 1);
    TextDrawColor(race_time_TD[1], 41215);
    TextDrawUseBox(race_time_TD[1], 1);
    TextDrawBoxColor(race_time_TD[1], -16776961);
    TextDrawBackgroundColor(race_time_TD[1], -1);
    TextDrawFont(race_time_TD[1], 0);
    TextDrawSetProportional(race_time_TD[1], 0);
    TextDrawSetShadow(race_time_TD[1], 0);
    TextDrawSetSelectable(race_time_TD[1], true);

    return 1;
}

stock TextDrawPlayerRace(playerid)
{
    race_time_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 320.6665, 49.7925, "LOAD..."); // пусто
    PlayerTextDrawLetterSize(playerid, race_time_PTD[playerid][0], 0.2124, 1.3178);
    PlayerTextDrawTextSize(playerid, race_time_PTD[playerid][0], 0.0000, -4.0000);
    PlayerTextDrawAlignment(playerid, race_time_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, race_time_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, race_time_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, race_time_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, race_time_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, race_time_PTD[playerid][0], 0);
    
    return 1;
}


CMD:gonki(playerid, params[])
{
    if(GetPVarInt(playerid, "player_time_opponent"))
        DeletePVar(playerid, "player_time_opponent");

    if(player_active_race[playerid])
        return SendClientMessage(playerid, -1, ""USC" Вы уже в гонке");

    if(!strlen(params))
        return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /rduel [id игрока]");

    if(GetPlayerSuspect(playerid))
        return SendClientMessage(playerid, 0x999999FF, "Участвовать в гонках нельзя с розыском");

    extract params -> new playerr_opponent;

    if(GetPlayerSuspect(playerr_opponent))
        return SendClientMessage(playerid, 0x999999FF, "Игрок имеет уровень розыска");

    if(!IsPlayerConnected(playerr_opponent) || !IsPlayerLogged(playerr_opponent) || playerr_opponent == playerid)
        return SendClientMessage(playerid, 0x999999FF, "Такого игрока нет");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerr_opponent, x, y, z);

    new Float:dist = GetPlayerDistanceFromPoint(playerid, x, y, z);
    if(dist > 7.0)
        return SendClientMessage(playerid, -1, ""USC" Игрок слишком далеко.");

    // ?? Списание денег за вызов на дуэль
    new duel_cost = 1000;
    if(GetPlayerMoney(playerid) < duel_cost)
        return SendClientMessage(playerid, 0xFF0000FF, "Недостаточно средств для вызова на гонку (нужно 1000 руб)");

    new fmt_text[100];
    format(fmt_text, sizeof fmt_text, "Вызов на гонку игроку %s", GetPlayerNameEx(playerr_opponent));
    GivePlayerMoneyEx(playerid, -duel_cost, fmt_text, true, true);

    // ?? Пузырь и сообщение отправителю
    format(fmt_text, sizeof fmt_text, "-%d руб (вызов на гонку)", duel_cost);
    SetPlayerChatBubble(playerid, fmt_text, 0xFF6600FF, 10.0, 5000);
    SendClientMessage(playerid, 0xFFA500FF, fmt_text);

    // ? Чат-сообщение отправителю, что предложение отправлено
    format(fmt_text, sizeof fmt_text, "Вы предложили игроку %s гоночную дуэль. Ожидайте ответа.", GetPlayerNameEx(playerr_opponent));
    SendClientMessage(playerid, 0x3399FFFF, fmt_text);

    // ?? Уведомление оппоненту
    format(fmt_text, sizeof fmt_text, "Игрок %s предложил гоночную дуэль", GetPlayerNameEx(playerid));
    ShowNotification(playerr_opponent, 4, fmt_text, 6, "/yesgonki", ">>");

    format(fmt_text, sizeof fmt_text, "%s предложил вам гоночную дуэль. Введите /yesgonki, чтобы принять.", GetPlayerNameEx(playerid));
    SendClientMessage(playerr_opponent, 0x00FF00FF, fmt_text);

    SetPVarInt(playerid, "player_time_opponent", playerr_opponent);

    return 1;
}


CMD:yesgonki(playerid)
{
    new player_invite = -1;

    foreach(new p : Player)
    {
        if(GetPVarInt(p, "player_time_opponent") == playerid)
            player_invite = p;
    }

    if(player_invite != -1)
    {
        SendClientMessage(playerid, -1, ""SC" Игрок выбирает режим гонок");
        new text[43];

        format(text, sizeof text, "Гоночные дуэли | {FFFF00}%s", GetPlayerNameEx(playerid));

        SetPVarInt(playerid, "select_opponent", player_invite);

        Dialog
        (
            player_invite, 1877, DIALOG_STYLE_LIST,
            text,
            "Драг-рейсинг\n"\
            "Уличные гонки\n"\
            "Кольцевые автогонки",
            "Начать", "Выйти"
        );
    }
    else
    {
        SendClientMessage(playerid, 0x999999FF, "У вас нет активных приглашений на гонку.");
    }

    return 1;
}


stock LoadDuelRace(type, p1, p2)
{
    new virtual = p1 + 777, plant_1 = -1, select_veh = vehicle_get_race[random(3)];

    GetPlayerPos(p1, old_player_pos[p1][0], old_player_pos[p1][1], old_player_pos[p1][2]);
    GetPlayerPos(p2, old_player_pos[p2][0], old_player_pos[p2][1], old_player_pos[p2][2]);

    if(!IsPlayerConnected(p1)) return SendClientMessage(p2, -1, ""SC" Игрок отключился. Начало гонки невозможно");
    if(!IsPlayerConnected(p2)) return SendClientMessage(p1, -1, ""SC" Игрок отключился. Начало гонки невозможно");

    foreach(new x : Player)
    {
        if(player_opponent[x] == p1 || player_opponent[x] == p2)
        {
            if(plant_1 == -1)
            {
                plant_1 = x;
                SetPlayerPosEx(x, plant_race[type][0][0], plant_race[type][0][1], plant_race[type][0][2], plant_race[type][0][3], 0, 0);
                new vehicle = CreateVehicle(select_veh,  plant_race[type][0][0], plant_race[type][0][1], plant_race[type][0][2], plant_race[type][0][3], 3, 3, 0);
                PutPlayerInVehicle(x, vehicle, 0);

                engine = (GetVehicleParam(vehicle, V_ENGINE) ^ VEHICLE_PARAM_ON);
                SetVehicleParam(vehicle, V_ENGINE, engine);

                for(new i;i < 3;i++)
                {
                    TextDrawShowForPlayer(x, race_time_TD[i]);
                }

                TextDrawPlayerRace(x);
                PlayerTextDrawShow(x, race_time_PTD[x][0]);


                player_type_race[x] = type;
                player_active_race[x] = true;
            }
            else
            {
                SetPlayerPosEx(x, plant_race[type][1][0], plant_race[type][1][1], plant_race[type][1][2], plant_race[type][1][3], 0, 0);
                new vehicle = CreateVehicle(select_veh,  plant_race[type][1][0], plant_race[type][1][1], plant_race[type][1][2], plant_race[type][1][3], 3, 3, 0); 
                PutPlayerInVehicle(x, vehicle, 0);

                engine = (GetVehicleParam(vehicle, V_ENGINE) ^ VEHICLE_PARAM_ON);
                SetVehicleParam(vehicle, V_ENGINE, engine);
                
                for(new i;i < 3;i++)
                {
                    TextDrawShowForPlayer(x, race_time_TD[i]);
                }


                TextDrawPlayerRace(x);
                PlayerTextDrawShow(x, race_time_PTD[x][0]);

                player_type_race[x] = type;
                player_active_race[x] = true;
            }
        }
        
    }
    new timer = SetTimerEx("CountDownRace", 1000, true, "ii", p1, p2);

    race_timer[p1] = timer;
    race_timer[p2] = timer;

    TogglePlayerControllable(p1, false);
    TogglePlayerControllable(p2, false);
    
    return 1;
}

public:CountDownRace(p1, p2)
{

    if(!race_countdown[p1])
    {
        GameTextForPlayer(p1, "~r~ 3", 700, 3);
        race_countdown[p1]++;
        GameTextForPlayer(p2, "~r~ 3", 700, 3);
        race_countdown[p2]++;
        TogglePlayerControllable(p1, false);
        TogglePlayerControllable(p2, false);
    }
    else if(race_countdown[p1] == 1)
    {
        GameTextForPlayer(p1, "~y~ 2", 700, 3);
        race_countdown[p1]++;
        GameTextForPlayer(p2, "~y~ 2", 700, 3);
        race_countdown[p2]++;
        TogglePlayerControllable(p1, false);
        TogglePlayerControllable(p2, false);
    }
    else if(race_countdown[p1] == 2)
    {
        GameTextForPlayer(p1, "~g~ 1", 700, 3);
        race_countdown[p1]++;
        GameTextForPlayer(p2, "~g~ 1", 700, 3);
        race_countdown[p2]++;
        TogglePlayerControllable(p1, false);
        TogglePlayerControllable(p2, false);
    }
    else
    {
        new type = player_type_race[p1];

        KillTimer(race_timer[p1]);
        KillTimer(race_timer[p2]);
        StartDuelRace(type, p1, p2);
    }
}

public:StartDuelRace(type, p1, p2)
{  
    switch(type)
    {
        case 0:
        {
            race_countdown[p1] = 50;
            race_countdown[p2] = 50;
        }
        case 1:
        {
            race_countdown[p1] = 100;
            race_countdown[p2] = 100;
        }
        case 2:
        {
            race_countdown[p1] = 200;
            race_countdown[p2] = 200;
        }
    }

    TogglePlayerControllable(p1, true);
    TogglePlayerControllable(p2, true);

    SendClientMessage(p1, -1, ""SC" Гонка началась");
    SendClientMessage(p2, -1, ""SC" Гонка началась");

    race_timer[p1] = SetTimerEx("ChangeTimerDuelRace", 1000, true, "i", p1);
    race_timer[p2] = SetTimerEx("ChangeTimerDuelRace", 1000, true, "i", p2);

    TextDrawShowForPlayer(p1, race_time_TD[2]);
    TextDrawShowForPlayer(p2, race_time_TD[2]);


    SetPlayerRaceCheckpoint(p1, 0, duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2],\
        duel_race_checkpoint[type][1][0], duel_race_checkpoint[type][1][1], duel_race_checkpoint[type][1][2], 10.0);

    SetPlayerRaceCheckpoint(p2, 0, duel_race_checkpoint[type][0][0], duel_race_checkpoint[type][0][1], duel_race_checkpoint[type][0][2],\
        duel_race_checkpoint[type][1][0], duel_race_checkpoint[type][1][1], duel_race_checkpoint[type][1][2], 10.0);

    count_cp_race_duel[p1] = 1;
    count_cp_race_duel[p2] = 1;

}

stock RemovePlayerNew(playerid)
{
    player_opponent[playerid] = -1;
    player_active_race[playerid] = false;
    player_type_race[playerid] = 0;
    count_cp_race_duel[playerid] = 0;

    if(player_vehicle_race[playerid] >= 0) DestroyVehicle(player_vehicle_race[playerid]);
    player_vehicle_race[playerid] = -1;

    old_player_pos[playerid][0] = 0.0;
    old_player_pos[playerid][1] = 0.0;
    old_player_pos[playerid][2] = 0.0;

    if(GetPVarInt(playerid, "money_race")) DeletePVar(playerid, "money_race");
    if(GetPVarInt(playerid, "second_to_player")) DeletePVar(playerid, "second_to_player");

    if(race_timer[playerid]) KillTimer(race_timer[playerid]);
    race_timer[playerid] = 0;
    race_countdown[playerid] = 0;
    return 1;
}

public:ChangeTimerDuelRace(playerid)
{
    if(race_countdown[playerid] != 0)
    {
        new	second = race_countdown[playerid] - 1;
        new fmt_str[20];

        format(fmt_str, sizeof fmt_str,"%d_ceky®љ", race_countdown[playerid]);

        PlayerTextDrawSetString(playerid, race_time_PTD[playerid][0], fmt_str);
        PlayerTextDrawShow(playerid, race_time_PTD[playerid][0]);

        SetPVarInt(playerid, "second_to_player", second);

        race_countdown[playerid]--;
    }
    else
    {
        KillTimer(race_timer[playerid]);
        RemoveDuelRace(playerid, player_opponent[playerid]);
    }
    return 1;
}

stock RemoveDuelRace(p1, p2, time = false)
{
    if(time)
    {
        SendClientMessage(p1, -1, ""SC" Игроки не доехали до финиша");
        SendClientMessage(p2, -1, ""SC" Игроки не доехали до финиша");
    }

    PlayerTextDrawHide(p1, race_time_PTD[p1][0]);
    
    for(new i;i < sizeof race_time_TD ;i++)
    {
        TextDrawHideForPlayer(p1, race_time_TD[i]);
    }

    PlayerTextDrawHide(p2, race_time_PTD[p2][0]);
    
    for(new i;i < sizeof race_time_TD ;i++)
    {
        TextDrawHideForPlayer(p2, race_time_TD[i]);
    }

    SetPlayerPosEx(p1, old_player_pos[p1][0], old_player_pos[p1][1], old_player_pos[p1][2], 0, 0);
    SetPlayerPosEx(p2, old_player_pos[p2][0], old_player_pos[p2][1], old_player_pos[p2][2], 0, 0);
    RemovePlayerNew(p1);
    RemovePlayerNew(p2);

    return 1;
}

stock ResultDuelRace(winner, loser)
{
    new money = GetPVarInt(winner, "money_race"), text[144];

    format(text, sizeof text, "Игрок {FFFF00}%s {FFFFFF}выйграл в этой гонке.", GetPlayerNameEx(winner));

    if(money != 0)
    {
        if(GetPlayerMoneyEx(loser) >= money)
        {
            new prize[27];
            format(prize, sizeof prize, " Приз:{FFFF00} %d", money);
            strcat(text, prize);
            GivePlayerMoneyEx(winner, money);
            GivePlayerMoneyEx(loser, -money);
        }
        else SendClientMessage(winner, -1, ""SC" У проигравшего игрока нехватает денег.");
    }
    SendClientMessage(winner, -1, text);
    SendClientMessage(loser, -1, text);
    RemoveDuelRace(winner, loser);

    return 1;
}

CMD:stoprace(playerid)
{
    ResultDuelRace(playerid, player_opponent[playerid]);
    return 1;
}
