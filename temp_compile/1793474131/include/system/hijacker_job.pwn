//Автор данной системы https://t.me/welsistudio (Welsi Studio)

new sphere_npc_hijacker;
//player
new player_order_hijacker[MAX_PLAYERS];
new player_hijacker_countdown[MAX_PLAYERS]; //кд снимается перезаходом (на бд не стал делать)
new player_timer_hijacker[MAX_PLAYERS][2];
new player_gang_zone_hijacker[MAX_PLAYERS];

enum STRUCT_HIJACKER
{
    HJ_PLAYER,
    HJ_VEHICLE, //Автор данной системы https://t.me/welsistudio (Welsi Studio)
    HJ_NET_ID, 
    HJ_AREA_SEARCH, 
    HJ_AREA_VEHICLE, //Автор данной системы https://t.me/welsistudio (Welsi Studio)

    Float:HJ_V_X,
    Float:HJ_V_Y,
    Float:HJ_V_Z,
    Float:HJ_V_A,

    Float:HJ_MIN_X, 
    Float:HJ_MIN_Y, 
    Float:HJ_MAX_X, 
    Float:HJ_MAX_Y, 
}
//Автор данной системы https://t.me/welsistudio (Welsi Studio)


new orders_hijacker[10][STRUCT_HIJACKER] = 
{
    {-1, 426, -1, -1, -1,   1811.319458,2149.302978,15.158486,1.360892 ,     1713.771240,2027.524658,1959.103271,2346.62841}, 
    {-1, 490, -1, -1, -1,   490.803161,892.269592,11.254014,72.575027,       335.735992,780.646728,658.850952,1127.929077}, //Автор данной системы https://t.me/welsistudio (Welsi Studio)
    {-1, 466, -1, -1, -1,   21.750465,1070.200439,11.245204,169.182846,      -159.141586,950.674804,136.920562,1378.438232}, 
    {-1, 405, -1, -1, -1,   -2238.848144,-55.657539,25.997491,0.019704 ,     -2493.057617,-338.89932,-2160.443603,144.148910}, //Автор данной системы https://t.me/welsistudio (Welsi Studio)
    {-1, 529, -1, -1, -1,   95.806594,612.750000,11.308088,249.468963,       -65.915565,583.433044,444.726623,731.883850}, 
    {-1, 458, -1, -1, -1,   299.042877,689.258911,11.236943,339.11621,       17.148643,575.865417,462.426330,735.316650}, 
    {-1, 541, -1, -1, -1,   -441.778656,1329.811523,19.939584,181.514572,    -534.722717,1253.143920,-216.096328,1576.76611}, 
    {-1, 542, -1, -1, -1,   2423.073486,-2626.398925,21.372909,181.049209,   2131.563476,-2677.256103,2546.755371,-2137.126708}, //Автор данной системы https://t.me/welsistudio (Welsi Studio)
    {-1, 527, -1, -1, -1,   1761.047607,2329.895263,14.911863,269.820495,    1662.459106,2209.247802,1963.043457,2576.826660},
    {-1, 522, -1, -1, -1,   98.758666,916.508544,11.214806,338.377685,      -197.066696,953.113159,296.312744,1156.070312}
};

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 2645)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    Dialog
                    (//Автор данной системы https://t.me/welsistudio (Welsi Studio)
                        playerid, -1, DIALOG_STYLE_MSGBOX, 
                        "{FFFF00}"SERVER_NAME"{FFFFFF} | Основная информация",
                        "{FFFF00}Угон транспортных средств{FFFFFF} — это одна из интереснейших работ сервера, которая\n"\
                        "предоставляет возможность полностью погрузиться в мир криминальных организаций,\n"\
                        "пережить некоторые моменты от их глаз, а также в итоге заработать неплохие денежки.\n\n"\
                        "Кажется, что делать особо ничего не надо, воруй машины — получай деньги. Но, на самом\n"\
                        "деле все не так просто, ведь очень важно понимать, что данная работа напрямую связана с\n"\
                        "криминальной деятельностью, за счет чего сотрудникам правоохранительных органов явно\n"\
                        "может не понравится направление совершаемых действий при попытке угона транспортного средства.\n\n"\
                        "Не стоит забывать про момент со взламыванием замков от транспортных средств — это тоже\n"\
                        "весьма непростой процесс, который требует внимательности, осторожности и конечно же,\n"\
                        "опыта, который обязательно придет со временем.",
                        "Назад", ""
                    );
                }
                case 1:
                {
                    if(GetPlayerLevel(playerid) < 3) return SendClientMessage(playerid, -1, ""USC" Сначало достинги 3 уровня.");

                    if(player_hijacker_countdown[playerid])
                    {
                        if(player_hijacker_countdown[playerid] >= gettime())
                        {
                            new countdown = player_hijacker_countdown[playerid] - gettime(), text[184];         
                            format(text, sizeof text, ""SC" Опять ты? Заданий сейчас нет, проваливай. (Осталось {FFFF00}%d:%d {FFFFFF}минут)", ConvertUnixTime(countdown, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(countdown, CONVERT_TIME_TO_SECONDS));
                            SendClientMessage(playerid, -1, text);
                            return 1;
                        }
                        else player_hijacker_countdown[playerid] = 0;
                    }

                    for(new h, count = -1, random_orders[sizeof orders_hijacker];h < sizeof orders_hijacker;h++)
                    {
                        if(orders_hijacker[h][HJ_PLAYER] != -1) continue;
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
                        count++;

                        random_orders[count] = h;

                        if(h == sizeof orders_hijacker - 1)
                        {
                            orders_hijacker[random_orders[random(count)]][HJ_PLAYER] = playerid;
                            player_order_hijacker[playerid] = random_orders[random(count)];
                        }
                    }

                    if(player_order_hijacker[playerid] == -1) return SendClientMessage(playerid, -1, ""SC" Заданий сейчас нет.");

                    new orders = player_order_hijacker[playerid];

                    SendClientMessage(playerid, -1, ""SC" На карте отмечена большая красная зона в котором последний раз видели транспортное средство.");
                    SendClientMessage(playerid, -1, ""SC" Когда вы заедете в зону где последний раз видели автомобиль, мы передадим Вам больше информации.");
                    SendClientMessage(playerid, -1, ""SC" На все вышеперечисленное дается {FFFF00}25 минут{FFFFFF}, надеемся этого хватит, поторопитесь, иначе задание будет провалено");
                    SendClientMessage(playerid, -1, ""SC" Воспользуйтесь командой — {FFFF00}/carjack{FFFFFF} чтобы запустить процесс взлома замка автомобиля.");

                    player_timer_hijacker[playerid][1] = 1500;
                    player_timer_hijacker[playerid][0] = SetTimerEx("GameTextHijacker", 1000, true, "i", playerid);

                    player_gang_zone_hijacker[playerid] = GangZoneCreate(orders_hijacker[orders][HJ_MIN_X], orders_hijacker[orders][HJ_MIN_Y], orders_hijacker[orders][HJ_MAX_X], orders_hijacker[orders][HJ_MAX_Y]);
                    GangZoneShowForPlayer(playerid, player_gang_zone_hijacker[playerid], 0xFF0000D8A);

                    orders_hijacker[orders][HJ_NET_ID] = CreateVehicle(orders_hijacker[orders][HJ_VEHICLE], orders_hijacker[orders][HJ_V_X], orders_hijacker[orders][HJ_V_Y], orders_hijacker[orders][HJ_V_Z], orders_hijacker[orders][HJ_V_A],\
                    random(128), random(128), 0);
                }
                case 2:OrdinaryNewHijacker(playerid);  
            }   
        }
    }
    if(dialogid == 2646)
    {//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        if(!response) return 1;

        new subsequence[5], subsequence_select[5], stage;
        
        GetPVarString(playerid, "subsequence_player", subsequence, 5);
        GetPVarString(playerid, "subsequence_select", subsequence_select, 5);

        if(GetPVarInt(playerid, "stage_dialog")) stage = GetPVarInt(playerid, "stage_dialog");

        subsequence_select[stage] = listitem + 1;

        if(subsequence[stage] == subsequence_select[stage]) stage++;
        else//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        {
            stage = 0;
            subsequence_select = {0, 0, 0, 0, 0};
            SendClientMessage(playerid, -1, ""SC" Была совершена ошибка, все штифты возвращены на исходное положение.");
            SendClientMessage(playerid, -1, ""SC" Не пережижайте, количество допустимых ошибок — неограниченно.");
        }

        if(stage == 5)
        {
            EnablePlayerGPS(playerid, 55, 2181.646484,-1838.352783,18.81676, "");
            SendClientMessage(playerid, -1, ""SC" Отвезите данное транспортное средство на место сбыта и подойдите к боту {FFFF00}(место на карте)");
            SendClientMessage(playerid, -1, ""SC" Будьте максимально аккуратнее. Сотрудники правоохранительных органов не дремлют.");
            SetPVarInt(playerid, "complete_jacker_veh", 1);
            return 1;
        }//Автор данной системы https://t.me/welsistudio (Welsi Studio)//Автор данной системы https://t.me/welsistudio (Welsi Studio)

        new text[128] = "", select_text[5][24] = {"Один\n",  "Два\n", "Три\n", "Четыре\n", "Пять"};

        for(new t; t < stage;t++)
        {
            switch(subsequence_select[t])
            {
                case 1:select_text[0] = "{FFFF00} Один\n";
                case 2:select_text[1] = "{FFFF00} Два\n";
                case 3:select_text[2] = "{FFFF00} Три\n";
                case 4:select_text[3] = "{FFFF00} Четыре\n";
                case 5:select_text[4] = "{FFFF00} Пять";
            }
        }//Автор данной системы https://t.me/welsistudio (Welsi Studio)//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        
        for(new p;p < 5;p++) strcat(text, select_text[p]);

        Dialog
        (
            playerid, 2646, DIALOG_STYLE_LIST, 
            "Угадайте последовательность",
            text, 
            "Нажать", "Отмена"
        );//Автор данной системы https://t.me/welsistudio (Welsi Studio)//Автор данной системы https://t.me/welsistudio (Welsi Studio)

        SetPVarString(playerid, "subsequence_select", subsequence_select);
        SetPVarInt(playerid, "stage_dialog", stage);

        
        //format(text, sizeof text, "%d %d %d %d %d | %d %d %d %d %d", subsequence[0], subsequence[1], subsequence[2], subsequence[3], subsequence[4], subsequence_select[0],  subsequence_select[1],  subsequence_select[2],  subsequence_select[3],  subsequence_select[4]);
        //SCM(playerid, -1, text);

    }//Автор данной системы https://t.me/welsistudio (Welsi Studio)//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    #if defined hj_OnDialogResponse
return hj_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse hj_OnDialogResponse
#if defined hj_OnDialogResponse
forward hj_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

/*public OnPlayerEnterCheckpoint(playerid)
{
    #if defined hj_OnPlayerEnterCheckpoint//Автор данной системы https://t.me/welsistudio (Welsi Studio)//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        return hj_OnPlayerEnterCheckpoint(playerid);
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnPlayerEnterCheckpoint
    #undef OnPlayerEnterCheckpoint
#else
    #define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint hj_OnPlayerEnterCheckpoint
#if defined hj_OnPlayerEnterCheckpoint
    forward hj_OnPlayerEnterCheckpoint(playerid);
#endif*/
//Автор данной системы https://t.me/welsistudio (Welsi Studio)

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    for(new v;v<sizeof orders_hijacker;v++)
    {
        if(orders_hijacker[v][HJ_NET_ID] == vehicleid)
        {
            if(!GetPVarInt(playerid, "complete_jacker_veh")) ClearAnimations(playerid);
            break;
        }
    }
    #if defined hj_OnPlayerEnterVehicle
        return hj_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
    #else
        return 1;//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    #endif
}
   #if defined _ALS_OnPlayerEnterVehicle
    #undef OnPlayerEnterVehicle
#else
    #define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle hj_OnPlayerEnterVehicle
#if defined hj_OnPlayerEnterVehicle
    forward hj_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#endif
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == sphere_npc_hijacker)
    {
        if(player_order_hijacker[playerid] != -1)
        {
            if(GetPVarInt(playerid, "complete_jacker_veh"))
            {
                new txt_salary[84], salary = 600000 + random(100000);

                SendClientMessage(playerid, -1, ""SC" Вы успешно доставили необходимое транспортное средство на место сбыта.");
                format(txt_salary, sizeof txt_salary, ""SC" Ваша заработная плата составила %d рублей", salary);
                SendClientMessage(playerid, -1, txt_salary);

                format(txt_salary, sizeof txt_salary, ""SC" Вы получили %d рублей", salary);
                ShowNotification(playerid, 2, txt_salary, 2, "", "");
                
                GivePlayerMoneyEx(playerid, salary);

                OrdinaryNewHijacker(playerid);

                player_hijacker_countdown[playerid] = gettime() + 420;
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
                return 1;
            }
        }

        DialogHijacker
        (
            playerid, 2645, DIALOG_STYLE_TABLIST_HEADERS, 
            "{FFFF00}"SERVER_NAME" {FFFFFF}| Угонщик автомобилей",
            "{7E7E7E}##\t{7E7E7E}Наименование\t{7E7E7E}Взаимодействие\n"\
            "{FF4F43}#1\t{FFFFFF}Основная информация\t{FFFFFF}Нажмите для взаимодействия\n"\
            "{FF4F43}#2\t{FFFFFF}Взять задание\t{FFFFFF}Нажмите для взаимодействия\n"\
            "{FF4F43}#3\t{FFFFFF}Отменить задание\t{FFFFFF}Нажмите для взаимодействия",
            "Выбрать", "Отмена"
        );
        //else SendClientMessage(playerid, -1, "{FFFF00}Вова:{FFFFFF} Братан, это работенка с третьего уровня!");
    }
    if(orders_hijacker[0][HJ_AREA_SEARCH] <= areaid <= orders_hijacker[sizeof orders_hijacker - 1][HJ_AREA_SEARCH])
    {
        if(player_order_hijacker[playerid] != -1)
        {
        new text[194  + 99], veh = orders_hijacker[player_order_hijacker[playerid]][HJ_VEHICLE] - 400;
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        format(text, sizeof text, "Ваша задача взломать и пригнать на место сбыта автомобиль — {FFFF00}%s.", g_vehicle_info[veh][VI_NAME]);
        SendClientMessage(playerid, -1, text);
        }
    }
    #if defined hj_OnPlayerEnterDynamicArea
        return hj_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea hj_OnPlayerEnterDynamicArea
#if defined hj_OnPlayerEnterDynamicArea
    forward hj_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif
//Автор данной системы https://t.me/welsistudio (Welsi Studio)

public OnGameModeInit()
{
    CreateHijacker();
    print("[LAIRD_SYSTEM] Работа автоугонщика загружена.");
    #if defined hj_OnGameModeInit
        return hj_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit hj_OnGameModeInit
#if defined hj_OnGameModeInit
    forward hj_OnGameModeInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    OrdinaryNewHijacker(playerid);
    #if defined hj_OnPlayerDisconnect
        return hj_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}//Автор данной системы https://t.me/welsistudio (Welsi Studio)
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect hj_OnPlayerDisconnect
#if defined hj_OnPlayerDisconnect
    forward hj_OnPlayerDisconnect(playerid, reason);
#endif
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
public OnPlayerConnect(playerid)
{
    OrdinaryNewHijacker(playerid);
    #if defined hj_OnPlayerConnect
        return hj_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect hj_OnPlayerConnect
#if defined hj_OnPlayerConnect
    forward hj_OnPlayerConnect(playerid);
#endif
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
public OnPlayerSpawn(playerid)
{
    OrdinaryNewHijacker(playerid);
    #if defined hj_OnPlayerSpawn
        return hj_OnPlayerSpawn(playerid);
    #else//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn hj_OnPlayerSpawn
#if defined hj_OnPlayerSpawn
    forward hj_OnPlayerSpawn(playerid);
#endif
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
stock CreateHijacker()//Автор данной системы https://t.me/welsistudio (Welsi Studio)
{
    for(new h;h < sizeof orders_hijacker;h++)
    {
        orders_hijacker[h][HJ_AREA_SEARCH] = CreateDynamicRectangle(orders_hijacker[h][HJ_MIN_X], orders_hijacker[h][HJ_MIN_Y], orders_hijacker[h][HJ_MAX_X], orders_hijacker[h][HJ_MAX_Y], 0, 0);
    }//Автор данной системы https://t.me/welsistudio (Welsi Studio)

    CreateActorEx("{FFFFFF}Угонщик автомобилей\n{FFFF00}Артем\n", "{FFFFFF}Подойдите для {FFFF00}взаимодействия", 103, 2165.000488,-1859.087280,18.814174,50.157138);
    CreateDynamicPickup(1239, 23, 2164.181396,-1858.483032,18.814174, 0, 0);
    sphere_npc_hijacker = CreateDynamicSphere(2164.181396,-1858.483032,18.814174, 2.0);//Автор данной системы https://t.me/welsistudio (Welsi Studio)

}

stock OrdinaryNewHijacker(playerid)
{
    if(player_timer_hijacker[playerid][0] != -1) KillTimer(player_timer_hijacker[playerid][0]);

    player_timer_hijacker[playerid][0] = -1;

    player_timer_hijacker[playerid][1] = 0;

    player_hijacker_countdown[playerid] = 0;

    if(player_gang_zone_hijacker[playerid] != -1)
    {//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        GangZoneHideForPlayer(playerid, player_gang_zone_hijacker[playerid]);
        GangZoneDestroy(player_gang_zone_hijacker[playerid]);
    } 

    player_gang_zone_hijacker[playerid] = -1;

    if(player_order_hijacker[playerid] != -1)
    {
        if(IsPlayerLogged(playerid))
        {
            DestroyVehicle(orders_hijacker[player_order_hijacker[playerid]][HJ_NET_ID]);

            orders_hijacker[player_order_hijacker[playerid]][HJ_PLAYER] = -1; 
        }

    }//Автор данной системы https://t.me/welsistudio (Welsi Studio)

    player_order_hijacker[playerid] = -1;

    if(GetPVarInt(playerid, "complete_jacker_veh")) DeletePVar(playerid, "complete_jacker_veh");
}

stock DialogHijacker(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}//Автор данной системы https://t.me/welsistudio (Welsi Studio)

public: GameTextHijacker(playerid)
{
    if(player_timer_hijacker[playerid][1] != 0)
    {
        player_timer_hijacker[playerid][1]--;

        new text[56];

        format(text, sizeof text, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~b~%d ~g~сек.", player_timer_hijacker[playerid][1]);
        GameTextForPlayer(playerid, text, 900, 3);
    }
    else
    {
        SendClientMessage(playerid, -1, ""SC" Вы не успели за данное время угнать транспортное средство. Задание провалено.");
        OrdinaryNewHijacker(playerid);
    }
}

CMD:carjack(playerid)
{//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    if(player_order_hijacker[playerid] != -1)
    {
        new Float:x, Float:y, Float:z;

        foreach(new i : Vehicle)
        {
            if(orders_hijacker[player_order_hijacker[playerid]][HJ_NET_ID] != i) continue;

            GetVehiclePos(i, x, y, z);
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
            if(GetPlayerDistanceFromPoint(playerid, x, y, z) <= 3.5)//Автор данной системы https://t.me/welsistudio (Welsi Studio)
            {
                new array[5], number[] = {1, 2, 3, 4, 5}, none[5];//Автор данной системы https://t.me/welsistudio (Welsi Studio)

                RandomArrayHijacker(number, array);

                SetPVarString(playerid, "subsequence_player", array);
                SetPVarString(playerid, "subsequence_select", none);

                //format(text, sizeof text, "%d %d %d %d %d", array[0], array[1], array[2], array[3], array[4]);
                //SCM(playerid, -1, text);

                Dialog
                (
                    playerid, 2646, DIALOG_STYLE_LIST, 
                    "Угадайте последовательность",
                    "Один\n"\
                    "Два\n"\
                    "Три\n"\
                    "Четыре\n"\
                    "Пять",
                    "Нажать", "Отмена"
                );
            }
            else SendClientMessage(playerid, -1, ""SC" Вы слишком далеко от транспортного средства.");
        }
    }
    else SendClientMessage(playerid, -1, ""SC" Сначало возьмите заказ у Артема.");
//Автор данной системы https://t.me/welsistudio (Welsi Studio)
}

stock RandomArrayHijacker(numbers[], array[], size_numbers = sizeof(numbers), const size_array = sizeof(array))
{//Автор данной системы https://t.me/welsistudio (Welsi Studio)
    new index;
    
    for (new i; i < size_array; i++)
    {
        index = random(size_numbers);
        
        array[i] = numbers[index];
        
        numbers[index] = numbers[-- size_numbers];
    }
}
//Автор данной системы https://t.me/welsistudio (Welsi Studio)