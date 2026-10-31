//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio

#define tc_msg "{FFAE00}[Транспортная компания] {FFFFFF}"

#define LEVEL_START_TC  10 //Поменяйте на уровень с которого будет доступен дальнобойщик

enum PLAYER_COMPANY
{
    p_TC_Owner,
    p_TC_Copmany,
    bool:p_TC_Active,

    p_TC_Order,
    p_TC_Progress_Order,
    Text3D:p_TC_Text,
    p_TC_Sphere_Finish,

    p_TC_Truck,
    p_TC_Trailer,
    p_TC_Level,
    p_TC_Exp
};

new player_tc[MAX_PLAYERS][PLAYER_COMPANY];

#define GetPlayerIncreaseTC(%0)   (player_tc[%0][p_TC_Level]-10) * 5


#define TC_LOCALITY_BUSAEVO    2
#define TC_LOCALITY_BATUREVO  1

#define TC_ORDER_NLOAD 0
#define TC_ORDER_NTAKE 1
#define TC_ORDER_TAKE 2

#define TC_TYPE_ORDER_COAL 1
#define TC_TYPE_ORDER_METAL 2
#define TC_TYPE_ORDER_OZON 3
#define TC_TYPE_ORDER_PETROL 4
#define TC_TYPE_ORDER_PRODUCTS 5
#define TC_TYPE_ORDER_TECHNOLOGY 6
#define TC_TYPE_ORDER_GLASS 7
#define TC_TYPE_ORDER_BANANS 8
#define TC_TYPE_ORDER_WATERMELON 9

new name_order_TC[9][24] =
{
    {"Уголь"},
    {"Металл"},
    {"Заказы Озон"},
    {"Бензин"},
    {"Продукты"},
    {"Электроприборы"},
    {"Стекло"},
    {"Бананы"},
    {"Арбузы"}
};

new salary_order_TC[9][2] =
{
    {40000, 10000}, // salary_orderот 40000 до 50000
    {35000, 10000}, // ПОЛУЧАЕТСЯ от 35000 до 45000 (10000 рандом типо пон?) 
    {50000, 5000},

    {65000, 35000},
    {50000, 50000},
    {90000, 30000},

    {95000, 15000},
    {120000, 120000},
    {200000, 10000}
};

new type_trailer[9] = {450,435,-1,584,-1,435,591,-1,-1};
new type_truck[9] = {403,403,498,403,498,403,403,413,413};

//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio

new open_order_lvl[3][3] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};

enum ORDER_TC
{
    o_TC_Type,
    o_TC_Locality,
    Float:o_TC_FinishPos[3],
    o_TC_Status,
    o_TC_Salary,
    o_TC_Finish[54]
};


new orders_tc[40][ORDER_TC] = 
{
    {TC_TYPE_ORDER_COAL, TC_LOCALITY_BUSAEVO, {-2435.133789,2712.665527,39.636734}, TC_ORDER_NLOAD, 0, "Склад \"г.Эдово\""},//0
    {TC_TYPE_ORDER_COAL, TC_LOCALITY_BUSAEVO, {598.226501,1757.621826,11.861831}, TC_ORDER_NLOAD, 0, "Контейнерная площадка"},//1
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BUSAEVO, {-2210.867187,-415.374481,29.209861}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Арзамас\""},//2
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BUSAEVO, {2058.106445,-2604.110351,10.619886}, TC_ORDER_NLOAD, 0, "Депо \"г.Южный\""},//3
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BUSAEVO, {2738.700439,-2316.699707,17.697065}, TC_ORDER_NLOAD, 0, "Склад \"г.Южный\""},//4
    {TC_TYPE_ORDER_OZON, TC_LOCALITY_BUSAEVO, {-2401.122314,10.525905,25.986291}, TC_ORDER_NLOAD, 0, "Пункт выдачи №1"},//5
    {TC_TYPE_ORDER_OZON, TC_LOCALITY_BUSAEVO, {144.481414,383.239746,15.635400}, TC_ORDER_NLOAD, 0, "Пункт выдачи №4"},//6
    {TC_TYPE_ORDER_PETROL, TC_LOCALITY_BUSAEVO, {2273.441162,-704.361145,13.17}, TC_ORDER_NLOAD, 0, "АЗС №1"},//7
    {TC_TYPE_ORDER_PETROL, TC_LOCALITY_BUSAEVO, {2746.985351,730.965515,30.781}, TC_ORDER_NLOAD, 0, "АЗС №2"},//8
    {TC_TYPE_ORDER_PRODUCTS, TC_LOCALITY_BUSAEVO, {2329.867675,-1923.195190,21.90}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №1"},//9
    {TC_TYPE_ORDER_PRODUCTS, TC_LOCALITY_BUSAEVO, {-508.971923,-1560.070434,41.18}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №2"},//10
    {TC_TYPE_ORDER_PRODUCTS, TC_LOCALITY_BUSAEVO, {100.912979,816.841613,12.01930}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №3"},//11
    {TC_TYPE_ORDER_TECHNOLOGY, TC_LOCALITY_BUSAEVO, {-2437.050781,-172.995223,27.44}, TC_ORDER_NLOAD, 0, "Супермаркет \"г.Лыткарино\""},//12
    {TC_TYPE_ORDER_TECHNOLOGY, TC_LOCALITY_BUSAEVO, {-2476.282226,2772.179199,37.43}, TC_ORDER_NLOAD, 0, "Торговый центр \"г.Эдово\""},//13
    {TC_TYPE_ORDER_GLASS, TC_LOCALITY_BUSAEVO, {-2210.867187,-415.374481,29.209861}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Арзамас\""},//14
    {TC_TYPE_ORDER_GLASS, TC_LOCALITY_BUSAEVO, {-24.590059,1805.262939,9.197439}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Лыткарино\""},//15
    {TC_TYPE_ORDER_GLASS, TC_LOCALITY_BUSAEVO, {598.226501,1757.621826,11.861831}, TC_ORDER_NLOAD, 0, "Контейнерная площадка"},//16
    {TC_TYPE_ORDER_BANANS, TC_LOCALITY_BUSAEVO, {-2420.096923,-263.920196,26.99}, TC_ORDER_NLOAD, 0, "Супермаркет \"г.Лыткарино\""},//17
    {TC_TYPE_ORDER_BANANS, TC_LOCALITY_BUSAEVO, {568.488647,947.387084,11.64748}, TC_ORDER_NLOAD, 0, "Азбука Вкуса \"г.Арзамас\""},//18
    {TC_TYPE_ORDER_WATERMELON, TC_LOCALITY_BUSAEVO, {-2639.756835,2879.549072,37.632}, TC_ORDER_NLOAD, 0, "Неизвестный заказчик"},//19
    {TC_TYPE_ORDER_COAL,  TC_LOCALITY_BATUREVO, {-995.730895,2151.722656,44.348934}, TC_ORDER_NLOAD, 0, "Завод \"г.Арзамас\""},//20
    {TC_TYPE_ORDER_COAL,  TC_LOCALITY_BATUREVO, {598.226501,1757.621826,11.861831}, TC_ORDER_NLOAD, 0, "Контейнерная площадка"},//21
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BATUREVO, {-24.590059,1805.262939,9.197439}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Лыткарино\""},//22
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BATUREVO, {2058.106445,-2604.110351,10.619886}, TC_ORDER_NLOAD, 0, "Депо \"г.Южный\""},//23
    {TC_TYPE_ORDER_METAL, TC_LOCALITY_BATUREVO, {-2435.133789,2712.665527,39.636734}, TC_ORDER_NLOAD, 0, "Склад \"г.Эдово\""},//24
    {TC_TYPE_ORDER_OZON,  TC_LOCALITY_BATUREVO, {-2399.693603,-0.686437,25.999822}, TC_ORDER_NLOAD, 0, "Пункт выдачи №2"},//25
    {TC_TYPE_ORDER_OZON,  TC_LOCALITY_BATUREVO, {676.783447,273.557373,12.856797}, TC_ORDER_NLOAD, 0, "Пункт выдачи №3"},//26
    {TC_TYPE_ORDER_PETROL,  TC_LOCALITY_BATUREVO, {2606.705078,2578.849121,16.18}, TC_ORDER_NLOAD, 0, "АЗС №3"},//27
    {TC_TYPE_ORDER_PETROL,  TC_LOCALITY_BATUREVO, {-2503.146972,-693.505493,29.3}, TC_ORDER_NLOAD, 0, "АЗС №4"},//28
    {TC_TYPE_ORDER_PRODUCTS,  TC_LOCALITY_BATUREVO, {-15.615036,954.794677,11.682}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №5"},//29
    {TC_TYPE_ORDER_PRODUCTS,  TC_LOCALITY_BATUREVO, {409.448211,1940.463623,8.148}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №4"},//30
    {TC_TYPE_ORDER_PRODUCTS,  TC_LOCALITY_BATUREVO, {-1738.667602,764.833312,35.3}, TC_ORDER_NLOAD, 0, "Продуктовый магазин №6"},//31
    {TC_TYPE_ORDER_TECHNOLOGY, TC_LOCALITY_BATUREVO, {2721.642089,-1630.229980,23.10}, TC_ORDER_NLOAD, 0, "Огранизация \"Лучшие сливы Welsi Studio\""},//32
    {TC_TYPE_ORDER_TECHNOLOGY, TC_LOCALITY_BATUREVO, {225.049224,375.714019,15.59920}, TC_ORDER_NLOAD, 0, "Склад магазинов \"г.Арзамас\""},//33
    {TC_TYPE_ORDER_GLASS,  TC_LOCALITY_BATUREVO, {-2210.867187,-415.374481,29.209861}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Арзамас\""},//34
    {TC_TYPE_ORDER_GLASS,  TC_LOCALITY_BATUREVO, {-24.590059,1805.262939,9.197439}, TC_ORDER_NLOAD, 0, "Городское строительство \"г.Лыткарино\""},//35
    {TC_TYPE_ORDER_GLASS,  TC_LOCALITY_BATUREVO, {598.226501,1757.621826,11.861831}, TC_ORDER_NLOAD, 0, "Контейнерная площадка"},//36
    {TC_TYPE_ORDER_BANANS,  TC_LOCALITY_BATUREVO, {134.547683,610.323303,11.58130}, TC_ORDER_NLOAD, 0, "Пятёрочка \"г.Арзамас\""},//37
    {TC_TYPE_ORDER_BANANS,  TC_LOCALITY_BATUREVO, {-2420.196289,-238.634353,26.99}, TC_ORDER_NLOAD, 0, "Супермаркет \"г.Лыткарино\""},//38
    {TC_TYPE_ORDER_WATERMELON, TC_LOCALITY_BATUREVO, {-2534.645263,1749.024536,53.025}, TC_ORDER_NLOAD, 0, "Неизвестный заказчик"}//39
};

new enter_tcompany[2], exit_tcompany, pickup_orderd_tc;

new Float:loading_order_TC[9][2][3] =
{
    {{2369.750000,1726.099243,13.457622},   {2369.750000,1726.099243,13.457622}},
    {{2058.106445,-2604.110351,10.619886},  {-2435.133056,2719.154785,39.636734}},
    {{598.226501,1757.621826,11.861831},    {-1311.768554,-1559.364135,60.801376}},
    {{1774.182983,2297.474853,15.664278},   {1774.182983,2297.474853,15.664278} },
    {{2738.700439,-2316.699707,17.697065},  {2738.700439,-2316.699707,17.697065}},
    {{-995.730895,2151.722656,44.348934},   {-995.730895,2151.722656,44.348934} },
    {{-995.730895,2151.722656,44.348934},   {-995.730895,2151.722656,44.348934} },
    {{598.226501,1757.621826,11.861831},    {-1311.768554,-1559.364135,60.801376}},
    {{598.226501,1757.621826,11.861831},    {-1311.768554,-1559.364135,60.801376}}
};

new Float:coord_tcompany[2][3] =
{
    {2327.637207,2009.636962,16.620204}, // Батырево
    {-426.065887,-1687.605712,41.526901} //Бусаево
};

new Float:coord_tcompany_exit[3] = {-0.251249,2500.500000,2011.005126}; //Выход из интерьера
new Float:coord_tcompany_order[3] = {2.028566,2503.603271,2011.005126}; //Пикап с заказами


new Float:spawn_trailer_tc[2][7][4] =
{
    {
       {2287.05,2057.90,15.66,182.79},
       {2296.59,2058.41,15.67,182.79},
       {2307.05,2059.09,15.67,182.79},
       {2316.68,2059.64,15.66,182.79},
       {2342.84,2058.12,15.67,182.79},
       {2348.80,2058.29,15.67,182.79},
       {2355.14,2058.69,15.66,182.79}
    },
    {
       {-386.51,-1738.53,40.6,329.76},
       {-392.66,-1737.33,40.6,329.76},
       {-397.25,-1733.01,40.6,329.76},
       {-402.83,-1731.03,40.6,329.76},
       {-408.05,-1728.22,40.6,329.76},
       {-412.63,-1723.96,40.6,329.76},
       {-417.88,-1720.82,40.6,329.76}
    }
};
new Float:spawn_truck_tc[2][7][4] = 
{
    {
       {2313.00,1992.95,15.66,2.06},
       {2306.60,1992.98,15.67,2.06},
       {2300.28,1992.31,15.66,2.06},
       {2293.74,1992.36,15.67,2.06},
       {2287.03,1993.11,15.66,2.06},
       {2280.16,1992.92,15.67,2.06},
       {2272.57,1992.89,15.67,2.06}
    },
    {
       {-406.06,-1689.130,40.6,149.76},
       {-401.08,-1692.530,40.6,149.76},
       {-395.73,-1695.842,40.6,149.76},
       {-389.30,-1699.543,40.6,149.76},
       {-384.53,-1702.104,40.6,149.76},
       {-379.12,-1705.562,40.6,149.76},
       {-374.09,-1709.198,40.6,149.76}
    }
};

public:CREATE_TABLE_COMPANY()
{
    mysql_query(mysql, "SELECT * FROM accounts WHERE progress_company AND t_company AND tc_owner", false);

    if(mysql_errno()) mysql_query(mysql, "ALTER TABLE `accounts` ADD `progress_company` FLOAT NOT NULL DEFAULT '1.0' AFTER `job`, ADD `t_company` INT NOT NULL DEFAULT\
     '-1' AFTER `progress_company`, ADD `tc_owner` INT NOT NULL DEFAULT '-1' AFTER `t_company`", false);

    return 1;
}

public:LoadPlayerProgressTC(playerid)
{
    new string[124], Cache:cache;
    mysql_format(mysql, string, sizeof string, "SELECT progress_company FROM accounts WHERE id=%d", GetPlayerAccountID(playerid));
    cache = mysql_query(mysql, string);

    new Float:float_progress = cache_get_row_float(0, 0);

    sscanf(floatttostring(float_progress), "P<.>dd", player_tc[playerid][p_TC_Level],player_tc[playerid][p_TC_Exp]);

    printf("[LAIRD_SYSTEM] Player:%d | Level_TC: %d | Exp_TC: %d", playerid, player_tc[playerid][p_TC_Level],player_tc[playerid][p_TC_Exp]);

    cache_delete(cache);
    return 1;
}

stock GivePlayerExpTC(playerid, count)
{
    new exp_player = player_tc[playerid][p_TC_Exp], level_up;

    exp_player += count;

    if(exp_player >= 100)
    {
        level_up = exp_player / 100; 
        new exp_WELSI_AUTHOR = exp_player % 100;

        player_tc[playerid][p_TC_Level] += level_up;
        player_tc[playerid][p_TC_Exp] = exp_WELSI_AUTHOR;
    }
    else {
        player_tc[playerid][p_TC_Exp] += count;
    }

    new string[12], query[84];

    format(string, sizeof string, "%d.%d", player_tc[playerid][p_TC_Level], player_tc[playerid][p_TC_Exp]);

    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET progress_company=%2f WHERE id=%d", floatstr(string), GetPlayerAccountID(playerid));
    mysql_query(mysql, query, false);

    if(!mysql_errno())
    {
        new message[144];
        format(message, sizeof message, ""tc_msg"Вы получили {FFAE00}%d{FFFFFF} опыт(a) дальнобойщика.", count);
        SendClientMessage(playerid, -1, message);

        if(level_up) {
            format(message, sizeof message, ""tc_msg"Поздравляем! Вы получили {FFAE00}%d{FFFFFF} уровень дальнобойщика. Ваш заработок увеличен",
            player_tc[playerid][p_TC_Level]);
            SendClientMessage(playerid, -1, message);
        }

        format(message, sizeof message, ""tc_msg"На данный момент у вас {FFAE00}%d{FFFFFF} уровень и {FFAE00}%d{FFFFFF} опыта дальнобойщика.",
        player_tc[playerid][p_TC_Level], player_tc[playerid][p_TC_Exp]);
        SendClientMessage(playerid, -1, message);
    }

    return 1;
}
stock floatttostring(Float:float)
{
    new string[32];

    format(string, sizeof string, "%.2f", float);

    return string;
}

public OnPlayerConnect(playerid)
{
    SetTimerEx("LoadPlayerProgressTC", 3000, false, "i", playerid);
    #if defined tc_OnPlayerConnect
        return tc_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect tc_OnPlayerConnect
#if defined tc_OnPlayerConnect
    forward tc_OnPlayerConnect(playerid);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == enter_tcompany[0] || areaid == enter_tcompany[1])
    {
        if(areaid == enter_tcompany[0]) SetPlayerVirtualWorld(playerid, 1);
        else SetPlayerVirtualWorld(playerid, 2);

        SetPlayerInterior(playerid, 1);
        SetPlayerPos(playerid, -0.251249,2501.8,2011.005126);
        SetPlayerFacingAngle(playerid, 0.857749);
    }
    if(areaid == exit_tcompany)
    {
        if(GetPlayerVirtualWorld(playerid) == 2) SetPlayerPosEx(playerid, -426.906463,-1688.774536,41.029911,151.296875, 0, 0);
        else SetPlayerPosEx(playerid, 2327.662353,2011.768310,16.121875,354.957916, 0, 0);
    }
    if(areaid == pickup_orderd_tc)
    {
        new Locality;
        if(GetPlayerVirtualWorld(playerid) == 2) Locality = TC_LOCALITY_BUSAEVO;
        else Locality = TC_LOCALITY_BATUREVO;

        ShowDialogOrders(playerid, Locality);
    }

    if(areaid == player_tc[playerid][p_TC_Sphere_Finish])
    {
        if(player_tc[playerid][p_TC_Progress_Order] && player_tc[playerid][p_TC_Order] != -1)
        {
            new vehicle = GetPlayerVehicleID(playerid);

            if(vehicle != player_tc[playerid][p_TC_Truck])
                return SendClientMessage(playerid, -1, ""tc_msg"Вы должны находится в своём рабочем транспорте.");

            new id = player_tc[playerid][p_TC_Order], type = orders_tc[id][o_TC_Type], locality = orders_tc[id][o_TC_Locality];

            if(GetVehicleModel(vehicle) == 403)
            {
                new trailer = GetVehicleTrailer(vehicle);

                if(!trailer) 
                    return SendClientMessage(playerid, -1, ""tc_msg"У вас отсуствует прицеп.");

                if(player_tc[playerid][p_TC_Trailer] != trailer)
                    return SendClientMessage(playerid, -1, ""tc_msg"Это не ваш прицеп.");
            }
            switch(player_tc[playerid][p_TC_Progress_Order])
            {
                case 2:
                {       
                    GameTextForPlayer(playerid, "~y~ПОДОЖДИТЕ...~n~ПРИЦЕП ЗАГРУЖАЕТСЯ", 4000, 3);
                    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
                    SetVehicleSpeed(vehicle, 0);
                    SetVehicleParam(vehicle, V_ENGINE, false);

                    SetTimerEx("LoadTrailerTC", 5000, false, "i", playerid);
                    DisablePlayerCheckpoint(playerid);

                    TogglePlayerControllable(playerid, false);
                }
                case 3:
                {
                    GameTextForPlayer(playerid, "~y~ПОДОЖДИТЕ...~n~ПРИЦЕП РАЗГРУЖАЕТСЯ", 4000, 3);
        
                    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
                    SetVehicleSpeed(vehicle, 0);
                    SetVehicleParam(vehicle, V_ENGINE, false);
                    SetTimerEx("LoadTrailerTC", 5000, false, "i", playerid);
                    DisablePlayerCheckpoint(playerid);
                    TogglePlayerControllable(playerid, false);
                }
            }
        }
    }
    #if defined tc_OnPlayerEnterDynamicArea
        return tc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea tc_OnPlayerEnterDynamicArea
#if defined tc_OnPlayerEnterDynamicArea
    forward tc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio
public OnGameModeInit()
{
    print("[LAIRD_SYSTEM] Система работы дальнобойщика загружена.");
    SetTimer("CREATE_TABLE_COMPANY", 2900, false);
    for(new i, string[114];i < 2;i++)
    {
        CreateDynamicPickup(19135, 23, coord_tcompany[i][0], coord_tcompany[i][1], coord_tcompany[i][2], 0, 0);
        enter_tcompany[i] = CreateDynamicSphere(coord_tcompany[i][0], coord_tcompany[i][1], coord_tcompany[i][2], 2.0, 0, 0);
        Create3DTextLabel(""tc_msg"\nВход в здание", -1, coord_tcompany[i][0], coord_tcompany[i][1], coord_tcompany[i][2], 10.0, 0);

        CreateDynamicPickup(19135, 23, coord_tcompany_exit[0], coord_tcompany_exit[1], coord_tcompany_exit[2], i+1, 1);
        exit_tcompany = CreateDynamicSphere(coord_tcompany_exit[0], coord_tcompany_exit[1], coord_tcompany_exit[2], 1.0, -1, 1);
        Create3DTextLabel(""tc_msg"\nВыход из здания", -1, coord_tcompany_exit[0], coord_tcompany_exit[1], coord_tcompany_exit[2], 10.0, i+1);

        CreateDynamicPickup(1274, 23, coord_tcompany_order[0], coord_tcompany_order[1], coord_tcompany_order[2], i, 1);
        pickup_orderd_tc = CreateDynamicSphere(coord_tcompany_order[0], coord_tcompany_order[1], coord_tcompany_order[2], 2.0, -1, 1);
        if(!i) format(string, sizeof string, ""tc_msg"\nЗаказы для дальнобойщиков\n{FFFFFF}Населённый пункт:{FFAE00} Батырево");
        else format(string, sizeof string, ""tc_msg"\nЗаказы для дальнобойщиков\n{FFFFFF}Населённый пункт:{FFAE00} Бусаево");
        Create3DTextLabel(string, -1, coord_tcompany_order[0], coord_tcompany_order[1], coord_tcompany_order[2], 4.0, i+1);
    }

    CreateActorEx("Уставший строитель", "{828282}очень хочет арбузы..", 228, -2639.756835,2879.549072,37.632812,177.616, 0, 0);
    CreateActorEx("Дима", "{828282}бормочет:\nкогда мне привезут мои арбузы? (он их не заказывал)", 89, -2534.645263,1749.024536,53.025150,299.114, 0, 0);

    for(new i;i < 2;i++) //
    {
        for(new e,order_lvl[3];e < 3;e ++)
        {
            if(order_lvl[e] >= 5) continue;

            for(new o, type, salary;o < sizeof orders_tc;o ++)
            {
                if(orders_tc[o][o_TC_Locality] != i+1) continue;
                else if(!(open_order_lvl[e][0] <= orders_tc[o][o_TC_Type] <= open_order_lvl[e][2])) continue;       
                else if(orders_tc[o][o_TC_Status] != TC_ORDER_NLOAD) continue; 

                orders_tc[o][o_TC_Status] = TC_ORDER_NTAKE;
                type = orders_tc[o][o_TC_Type]-1;
                orders_tc[o][o_TC_Salary] = random(salary_order_TC[type][1]) + salary_order_TC[type][0];
                order_lvl[e]++; 
            } 
        } 
    }

    SetTimer("UpdateOrderTC", 2000*60, true); // Каждые 2 минут (поменяйте 2000 на 3000 чтобы было на 3 минуты)

    #if defined tc_OnGameModeInit
        return tc_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit tc_OnGameModeInit
#if defined tc_OnGameModeInit
    forward tc_OnGameModeInit();
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 2902)
    {
        new id = GetPlayerListitemValue(playerid, listitem), string[484], salary_txt[114] = "", salary = orders_tc[id][o_TC_Salary], level_txt[78], 
        level, player_level = player_tc[playerid][p_TC_Level];

        switch(orders_tc[id][o_TC_Type])
        {
            case 1..3:level = 1;
            case 4..6:level = 5;
            case 7..9:level = 10;
        }
        
        if(player_level >= level) { format(level_txt, sizeof level_txt, "Ваш уровень дальнобойщика {FFAE00}позволяет{FFFFFF} принять этот заказ"); SetPVarInt(playerid, "dostup_order", 0); }
        else { format(level_txt, sizeof level_txt, "Ваш уровень дальнобойщика {FFAE00}не позволяет{FFFFFF} принять этот заказ"); SetPVarInt(playerid, "dostup_order", 1); }

    
        if(player_level > 10){
            format(salary_txt, sizeof salary_txt, "\n{FFFFFF}Оплата увеличена на {FFAE00}%d{FFFFFF} процентов (уровень больше {FFAE00}десятого{FFFFFF})", GetPlayerIncreaseTC(playerid));

            new procent = orders_tc[id][o_TC_Salary] / 100 * GetPlayerIncreaseTC(playerid);
            salary = orders_tc[id][o_TC_Salary]+procent;
        }
        
        format(
            string, sizeof string, 
            "{FFFFFF}Содержимое прицепа: {FFAE00}%s\n\
            {FFFFFF}Точка загрузки прицепа: {FFAE00}Склад\n\
            {FFFFFF}Точка разгрузки прицепа: {FFAE00}%s\n\
            {FFFFFF}Требуемый уровень дальнобойщика: {FFAE00}%d\n\n\
            {FFFFFF}%s\n\n\
            {FFFFFF}Оплата за заказ: {FFAE00}%d руб%s", name_order_TC[orders_tc[id][o_TC_Type]-1],
            orders_tc[id][o_TC_Finish], level, level_txt, salary, salary_txt
        );

        Dialog
        (
            playerid, 2903, DIALOG_STYLE_MSGBOX,
            "{FFAE00}Информация о заказ",
            string,
            "Взять", "Назад"
        );
        DefaultPlayerOrder(playerid);
        player_tc[playerid][p_TC_Order] = id;
    }
    if(dialogid == 2903)
    {
        if(!response)
        {
            player_tc[playerid][p_TC_Order] = -1;
            if(GetPlayerVirtualWorld(playerid) == 2) ShowDialogOrders(playerid, TC_LOCALITY_BUSAEVO-1);
            else ShowDialogOrders(playerid, TC_LOCALITY_BATUREVO-1);
            
        }else{
            if(GetPVarInt(playerid, "dostup_order")) return
                SendClientMessage(playerid, -1, ""tc_msg"Ваш уровень дальнобойщика не позволяет взять этот заказ.");

            new plant = GetPlayerVirtualWorld(playerid)-1, r = random(7),
            id = player_tc[playerid][p_TC_Order], type = orders_tc[id][o_TC_Type]-1,
            Float:x = loading_order_TC[type][plant][0],
            Float:y = loading_order_TC[type][plant][1],
            Float:z = loading_order_TC[type][plant][2];

            SetPlayerPosEx(playerid, spawn_truck_tc[plant][r][0], spawn_truck_tc[plant][r][1], spawn_truck_tc[plant][r][2], 0.0, 0, 0);

            player_tc[playerid][p_TC_Truck] = CreateVehicle(type_truck[type], spawn_truck_tc[plant][r][0], spawn_truck_tc[plant][r][1], spawn_truck_tc[plant][r][2], 
            spawn_truck_tc[plant][r][3], random(225), 0, 0);
            PutPlayerInVehicle(playerid, player_tc[playerid][p_TC_Truck], 0);

            if(type_trailer[type] != -1)
            {
                SetPlayerCheckpoint(playerid, spawn_trailer_tc[plant][r][0], spawn_trailer_tc[plant][r][1], 
                spawn_trailer_tc[plant][r][2], 7.0);
                player_tc[playerid][p_TC_Progress_Order] = 1;

                player_tc[playerid][p_TC_Trailer] = CreateVehicle(type_trailer[type], spawn_trailer_tc[plant][r][0], spawn_trailer_tc[plant][r][1], 
                spawn_trailer_tc[plant][r][2], spawn_trailer_tc[plant][r][3],
                random(225), 0, 0);
            } else {
                SetPlayerCheckpoint(playerid, x,y,z, 10.0);

                SendClientMessage(playerid, -1, ""tc_msg"Отправляйтесь к точке загрузки.");
                player_tc[playerid][p_TC_Progress_Order] = 2;
            }

            player_tc[playerid][p_TC_Text] = CreateDynamic3DTextLabel("{FFAE00}ТОЧКА ЗАГРУЗКИ\n{FFFFFF}Подъедьте ближе чтобы загрузиться", -1,
            x,y,z, 18.0, _, _, _, 0, 0, playerid);
            player_tc[playerid][p_TC_Sphere_Finish] = CreateDynamicSphere(x,y,z, 5.0, 0, 0, playerid);
        }
    }
    #if defined tc_OnDialogResponse
    return tc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse tc_OnDialogResponse
#if defined tc_OnDialogResponse
forward tc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif
//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio
stock DefaultPlayerOrder(playerid)
{
    player_tc[playerid][p_TC_Order] = -1;
    player_tc[playerid][p_TC_Progress_Order] = -1;
    if(IsValidVehicle(player_tc[playerid][p_TC_Truck])) DestroyVehicle(player_tc[playerid][p_TC_Truck]);
    player_tc[playerid][p_TC_Truck] = -1;
    if(IsValidVehicle(player_tc[playerid][p_TC_Trailer])) DestroyVehicle(player_tc[playerid][p_TC_Trailer]);
    player_tc[playerid][p_TC_Trailer] = -1;
    if(IsValidDynamic3DTextLabel(player_tc[playerid][p_TC_Text])) DestroyDynamic3DTextLabel(player_tc[playerid][p_TC_Text]);
    player_tc[playerid][p_TC_Text] = Text3D:-1;
    if(IsValidDynamicArea(player_tc[playerid][p_TC_Sphere_Finish])) DestroyDynamicArea(player_tc[playerid][p_TC_Sphere_Finish]);
    player_tc[playerid][p_TC_Sphere_Finish] = -1;
    return 1;
}
public OnPlayerSpawn(playerid)
{
    DefaultPlayerOrder(playerid);

    #if defined tc_OnPlayerSpawn
        return tc_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn tc_OnPlayerSpawn
#if defined tc_OnPlayerSpawn
    forward tc_OnPlayerSpawn(playerid);
#endif

public:LoadTrailerTC(playerid)
{
    new id = player_tc[playerid][p_TC_Order], type = orders_tc[id][o_TC_Type], locality = orders_tc[id][o_TC_Locality];

    switch(player_tc[playerid][p_TC_Progress_Order])
    {
        case 2:
        {
            new Float:x = orders_tc[id][o_TC_FinishPos][0],
            Float:y = orders_tc[id][o_TC_FinishPos][1],
            Float:z = orders_tc[id][o_TC_FinishPos][2];
            SetPlayerCheckpoint(playerid, x,y,z, 10.0);

            if(IsValidDynamic3DTextLabel(player_tc[playerid][p_TC_Text])) DestroyDynamic3DTextLabel(player_tc[playerid][p_TC_Text]);
            if(IsValidDynamicArea(player_tc[playerid][p_TC_Sphere_Finish])) DestroyDynamicArea(player_tc[playerid][p_TC_Sphere_Finish]);

            player_tc[playerid][p_TC_Text] = CreateDynamic3DTextLabel("{FFAE00}ТОЧКА РАЗГРУЗКИ\n{FFFFFF}Подъедьте ближе чтобы загрузиться", -1,
            x,y,z, 10.0, _, _, _, 0, 0, playerid);
            player_tc[playerid][p_TC_Sphere_Finish] = CreateDynamicSphere(x,y,z, 8.0, 0, 0, playerid);
            SendClientMessage(playerid, -1, ""tc_msg"Точка разгрузки отмечена на карте. Удачной дороги!");
            SetVehicleParam(GetPlayerVehicleID(playerid), V_ENGINE, true);
            player_tc[playerid][p_TC_Progress_Order]++;
        }
        case 3:{
            new vehicle = player_tc[playerid][p_TC_Truck];

            if(IsValidVehicle(player_tc[playerid][p_TC_Trailer])) {
                DetachTrailerFromVehicle(player_tc[playerid][p_TC_Trailer]);
                DestroyVehicle(player_tc[playerid][p_TC_Trailer]);
            }

            player_tc[playerid][p_TC_Trailer] = -1;
            SendClientMessage(playerid, -1, ""tc_msg"Вы успешно выполнили заказ");
            
            new salary = orders_tc[id][o_TC_Salary],string[144];

            if(player_tc[playerid][p_TC_Level] > 10)
            {
                new procent = orders_tc[id][o_TC_Salary] / 100 * GetPlayerIncreaseTC(playerid);
                salary = orders_tc[id][o_TC_Salary]+procent;
            }

            GivePlayerMoneyEx(playerid, salary);
            format(string, sizeof string, ""tc_msg"Вы получили {FFAE00}%d {FFFFFF}руб. за заказ дальнобойщика.", salary);
            SendClientMessage(playerid, -1, string);
            GivePlayerExpTC(playerid, random(10)+1);
            SetVehicleParam(vehicle, V_ENGINE, true);
            player_tc[playerid][p_TC_Order] = -1;
            player_tc[playerid][p_TC_Progress_Order] = 0;

            if(IsValidDynamic3DTextLabel(player_tc[playerid][p_TC_Text])) DestroyDynamic3DTextLabel(player_tc[playerid][p_TC_Text]);
            if(IsValidDynamicArea(player_tc[playerid][p_TC_Sphere_Finish])) DestroyDynamicArea(player_tc[playerid][p_TC_Sphere_Finish]);
            
        }
    }

    TogglePlayerControllable(playerid, true);
    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_SHOW);

    return 1;
}

public OnTrailerUpdate(playerid, vehicleid)
{
    if(player_tc[playerid][p_TC_Progress_Order] == 1 && player_tc[playerid][p_TC_Order] != -1)
    {
        new id = player_tc[playerid][p_TC_Order], type = orders_tc[id][o_TC_Type]-1, locality = orders_tc[id][o_TC_Locality]-1;

        SetPlayerCheckpoint(playerid, loading_order_TC[type][locality][0], loading_order_TC[type][locality][1], 
        loading_order_TC[type][locality][2], 10.0);

        SendClientMessage(playerid, -1, ""tc_msg"Отправляйтесь к точке загрузки.");
        player_tc[playerid][p_TC_Progress_Order] = 2;
    }
    #if defined tc_OnTrailerUpdate
        return tc_OnTrailerUpdate(playerid, vehicleid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnTrailerUpdate
    #undef OnTrailerUpdate
#else
    #define _ALS_OnTrailerUpdate
#endif
#define OnTrailerUpdate tc_OnTrailerUpdate
#if defined tc_OnTrailerUpdate
    forward tc_OnTrailerUpdate(playerid, vehicleid);
#endif
//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio
public OnPlayerEnterCheckpoint(playerid)
{ 
    if(player_tc[playerid][p_TC_Progress_Order] && player_tc[playerid][p_TC_Order] != -1) DisablePlayerCheckpoint(playerid);
	#if defined tc_OnPlayerEnterCheckpoint
		return tc_OnPlayerEnterCheckpoint(playerid);
	#else
	    return 1;
	#endif
}
   #if defined _ALS_OnPlayerEnterCheckpoint
    #undef OnPlayerEnterCheckpoint
#else
    #define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint tc_OnPlayerEnterCheckpoint
#if defined tc_OnPlayerEnterCheckpoint
    forward tc_OnPlayerEnterCheckpoint(playerid);
#endif

public:UpdateOrderTC()
{
    new order_lvl[3], order[2];

    for(new i;i < 2;i++) //
    {
        for(new o;o < sizeof orders_tc;o ++)
        {
            if(orders_tc[o][o_TC_Locality] != i) continue;
            else if(orders_tc[o][o_TC_Status] != TC_ORDER_NTAKE) continue;

            switch(orders_tc[o][o_TC_Type])
            {
                case TC_TYPE_ORDER_COAL..TC_TYPE_ORDER_OZON:order_lvl[0]++;
                case TC_TYPE_ORDER_PETROL..TC_TYPE_ORDER_TECHNOLOGY:order_lvl[1]++;
                case TC_TYPE_ORDER_GLASS..TC_TYPE_ORDER_WATERMELON:order_lvl[2]++;
            }
        } 

        for(new e;e < 3;e ++)
        {
            if(order_lvl[e] >= 5) continue;

            for(new o, type, salary;o < sizeof orders_tc;o ++)
            {
                if(orders_tc[o][o_TC_Locality] != i+1) continue;
                else if(!(open_order_lvl[e][0] <= orders_tc[o][o_TC_Type] <= open_order_lvl[e][2])) continue;       
                else if(orders_tc[o][o_TC_Status] != TC_ORDER_NLOAD) continue; 

                orders_tc[o][o_TC_Status] = TC_ORDER_NTAKE;
                type = orders_tc[o][o_TC_Type]-1;
                orders_tc[o][o_TC_Salary] = random(salary_order_TC[type][1]) + salary_order_TC[type][0]; 
                order[i]++;
                break;
            } 
        } 
    }
    
    if(order[0] || order[1])
    {
        print("[LAIRD_SYSTEM] В список заказов дальнобойщиков добавлено:");
        printf("[LAIRD_SYSTEM] %d в бусаево и %d в батырево", order[0], order[1]);
    }

    return 1;
}

stock DialogTruck(playerid, dialogid, style, title[], text[], button[], button2[])
{//Сколько ещё я буду вставлять этот диалог в свои системы?
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}


CMD:tcstats(playerid)
{
    new string[468], lvl_text[284] = "";

    if(player_tc[playerid][p_TC_Level] > 10)
    {
        new procent = 500000 / 100 * GetPlayerIncreaseTC(playerid),
        salary = 500000+procent;

        format(lvl_text, sizeof lvl_text, "\nУ вас {FFAE00}высокий уровень {FFFFFF}(больше десятого).\n\
        Вы можете получать {FFAE00}прибавку к оплате {FFFFFF}за заказ ввиде {FFAE00}%d {FFFFFF}процентов\n\
        Например: за заказ оплатой 500.000 руб. вы получите {FFAE00}%d {FFFFFF}руб.", GetPlayerIncreaseTC(playerid), salary);

    }

    format(string, sizeof string, 
    "Ваш уровень дальнобойщика:{FFAE00}%d {FFFFFF}\n\
    Количество опыта дальнобойщика:{FFAE00}%d{FFFFFF}/{FFAE00}100 {FFFFFF}\n\
    Для следующего уровня нужно {FFAE00}%d {FFFFFF}опыта.\n%s", player_tc[playerid][p_TC_Level], 
    player_tc[playerid][p_TC_Exp], 100-player_tc[playerid][p_TC_Exp], lvl_text);

    Dialog(playerid,-1, DIALOG_STYLE_MSGBOX, "{FFAE00}Статистика дальнобойщика", string, "Закрыть", "");
    return 1;
}

stock ShowDialogOrders(playerid, Locality)
{
    if(player_tc[playerid][p_TC_Order] != -1) return SendClientMessage(playerid, -1, ""tc_msg"Сначала выполните прошлый заказ");
        if(GetPlayerLevel(playerid) < LEVEL_START_TC){
        new string[124];
        format(string, sizeof string, ""tc_msg"Выполнять заказы для дальнобойщиков можно с {FFAE00}%d {FFFFFF}уровня", LEVEL_START_TC);
        SendClientMessage(playerid, -1, string);
    }

    new stroka[56], dialog[sizeof stroka * 20 + 56] = {"{FFFFFF}Название\t{FFFFFF}Оплата за выполнение\n"}, order_open;

    switch(player_tc[playerid][p_TC_Level])
    {
        case 0..4:order_open = 0;
        case 5..9:order_open = 1;
        default:{
            if(player_tc[playerid][p_TC_Level] >= 10) order_open = 2;
        }
    }

    for(new i, listitem = 1;i < sizeof orders_tc;i++)
    {
        if(orders_tc[i][o_TC_Status] != TC_ORDER_NTAKE) continue;
        else if(orders_tc[i][o_TC_Locality] != Locality) continue;
        

        format(stroka, sizeof stroka, "{FFFFFF}%s\t{FFAE00}%d{FFFFFF} руб\n", name_order_TC[orders_tc[i][o_TC_Type]-1], orders_tc[i][o_TC_Salary]);
        strcat(dialog, stroka);
        SetPlayerListitemValue(playerid, listitem, i);
        listitem++;
    } 

    DialogTruck(playerid, 2902, DIALOG_STYLE_LIST, "{FFAE00}Список актуальных заказов", dialog, "Далее", "Выйти");
    return 1;
}

CMD:setlvltc(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) >= 4) // 6 - начиная с какого уровня администратора это доступно?
	{
		if(!strlen(params))
		return SendClientMessage(playerid, 0x999999FF, "Используйте: /setlvltc [id игрока] [уровень дальнобойщика]");

		extract params -> new to_player, lvl;

		new text[144];

		if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player))
			return SendClientMessage(playerid, 0x999999FF, ""USC"Такого игрока нет");

        player_tc[to_player][p_TC_Level] = lvl;

        format(text, sizeof text, "%d.%d", player_tc[playerid][p_TC_Level], player_tc[playerid][p_TC_Exp]);
		UpdatePlayerDatabaseFloat(playerid, "progress_company", floatstr(text));

		format(text, sizeof text, ""tc_msg" Вы изменили уровень игроку %s дальнобойщика. Теперь у него %d уровень дальнобойщика", GetPlayerNameEx(to_player), lvl);
		SendClientMessage(playerid, -1, text);
		format(text, sizeof text, ""tc_msg" Администратор %s изменил ваш уровень на %d", GetPlayerNameEx(playerid), lvl);
		SendClientMessage(to_player, -1, text);
	}

	return 1;
}
//AВТОР СИСТЕМЫ : https://t.me/welsistudio
//БОЛЬШЕ КАЧЕСТВЕННЫХ СЛИВОВ: https://t.me/welsistudio