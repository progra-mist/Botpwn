#include <a_samp>
#include "../include/streamer.inc"
#include <brnotification>

#define		MAX_FIRE	81

new String128m[128];

new mString512[512];

#define SCM SendClientMessage
#define SC              "{ffff00}| {ffffff}"
#define USC             "{ff2400}| {ffffff}"
#define		DSI		DIALOG_STYLE_INPUT
#define 	DSM		DIALOG_STYLE_MSGBOX
#define 	DSL		DIALOG_STYLE_LIST
#define 	DSP		DIALOG_STYLE_PASSWORD
#define 	DSTH    DIALOG_STYLE_TABLIST_HEADERS

#define STATE_ORDER_NLOAD        0
#define STATE_ORDER_NO_TAKE     1
#define STATE_ORDER_TAKE        2
#define STATE_ORDER_COMPLETED   3
#define STATE_ORDER_N_COMPLETED   4

new exit_mchs, enter_mchs, npc_mchs_1, invent_mchs, veh_mchs;

new player_order[MAX_PLAYERS], player_veh_mchs[MAX_PLAYERS];
new bool:player_mchs_active[MAX_PLAYERS char];
new bool:press_fire[MAX_PLAYERS char];

enum FIRE_STRUCT
{
	F_ID, 			//ID FIRE
	Float:F_X,		//Coord X
	Float:F_Y, 		//Coord Y
	Float:F_Z, 		//Coord Z
    F_ID_Z,         //заказ
	F_SCORE			//Score Fire
}
enum STRUCT_ORDER_MCHS
{
    MS_IDp,
    MS_State
}
new order_mchs[10][STRUCT_ORDER_MCHS];

new Float:coord_order[10][3] = 
{
    {296.527496,1898.282714,12.099133},
    {-2258.646484,-1115.430419,47.816703},
    {-2365.940917,2569.989990,41.919464},
    {387.455474,1877.942138,10.335917},
    {2543.734375,397.923248,30.621963},
    {1824.506835,705.062805,14.910859},
    {2224.401123,-223.295562,2.491437},
    {2417.199218,-2104.353515,21.976562},
    {2770.004638,-2489.099121,21.671724},
    {1701.338012,2535.687744,15.661165}

};

new Float:all_fire[MAX_FIRE][FIRE_STRUCT] =
{
	{0, 0.0, 0.0, 0.0, 0, 10},
	{1, 296.527496,1898.282714,12.099133,   1, 0},
	{2, 287.150451,1897.891967,12.107488,   1, 0},
	{3, 299.703460,1889.404785,12.161455,   1, 0},
	{4, 308.130676,1901.933959,12.074846,   1, 0},
	{5, 308.673797,1894.766845,12.146845,   1, 0},
	{6, 305.295654,1884.358154,12.203125,   1, 0},
	{7, 287.741882,1885.584350,12.189496,   1, 0},
	{8, 281.275207,1895.371826,12.131278,   1, 0},
	{9, -2264.829833,-1110.535156,47.711894,   2, 0},
	{10, -2264.829833,-1110.535156,47.711894,   2, 0},
	{11, -2260.946777,-1104.783569,48.124774,   2, 0},
	{12, -2260.316406,-1099.853271,48.168872,   2, 0},
	{13, -2255.228271,-1101.148925,48.203521,   2, 0},
	{14, -2252.199462,-1106.071411,48.194992,   2, 0},//END
	{15, -2246.708251,-1110.401000,48.216037,   2, 0},
	{16, -2247.292724,-1114.759277,48.069347,   2, 0},
	{17, -2362.677001,2565.405029,41.897556,   3, 0},
	{18, -2359.813964,2566.807617,41.919990,   3, 0},
	{19, -2357.175781,2572.038085,41.647781,   3, 0},
	{20, -2353.051025,2568.935791,41.650463,   3, 0},
	{21, -2351.055664,2563.098388,41.876743,   3, 0},
	{22, -2353.513916,2558.136718,41.939636,   3, 0},
	{23, -2346.276123,2553.455078,41.567752,   3, 0},
	{24, -2353.776123,2547.344726,41.889331,   3, 0},
	{25, 385.210235,1876.408325,10.591158,   4, 0},
	{26, 382.728881,1879.659790,10.969162,   4, 0},
	{27, 386.901367,1885.191284,10.522723,   4, 0},
	{28, 378.082336,1887.075195,11.700300,   4, 0},
	{29, 376.377197,1869.499633,11.552527,   4, 0},
	{30, 380.473419,1866.827514,11.024223,   4, 0},
	{31, 379.309631,1861.054809,11.102409,   4, 0},
	{32, 374.755371,1861.072631,11.636733,   4, 0},
	{33, 2550.495605,403.438140,28.995994,   5, 0},
	{34, 2552.929687,409.582885,26.708543,   5, 0},
	{35, 2550.058105,414.792572,25.602706,   5, 0},
	{36, 2544.914794,416.106872,25.553398,   5, 0},
	{37, 2539.236328,412.607543,26.534297,   5, 0},
	{38, 2529.128906,409.210479,28.130754,   5, 0},
	{39, 2533.128662,420.413909,25.777967,   5, 0},
	{40, 2543.224121,420.316284,25.090774,   5, 0},
	{41, 1819.207275,706.325195,14.928386,   6, 0},
	{42, 1812.996215,704.661621,15.077613,   6, 0},
	{43, 1811.236938,699.815551,15.048868,   6, 0},
	{44, 1804.111450,695.152648,14.817768,   6, 0},
	{45, 1808.579833,688.292419,14.395690,   6, 0},
	{46, 1820.534301,690.473571,14.331215,   6, 0},
	{47, 1824.118896,694.789855,14.511970,   6, 0},
	{48, 1821.996582,685.015502,14.166062,   6, 0},
	{49, 2222.886230,-226.391784,2.484841,   7, 0},
	{50, 2226.503906,-228.676376,2.491437,   7, 0},
	{51, 2230.528076,-233.092758,2.972958,   7, 0},
	{52, 2231.772705,-237.435180,3.326279,   7, 0},
	{53, 2224.223876,-238.367065,2.475771,   7, 0},
	{54, 2219.859863,-236.204055,2.441738,   7, 0},
	{55, 2221.118652,-244.523620,2.396505,   7, 0},
	{56, 2238.254150,-235.821960,2.513052,   7, 0},
	{57, 2431.572265,-2115.169921,21.778125,   8, 0},
	{58, 2428.911132,-2116.033691,21.976043,   8, 0},
	{59, 2420.474609,-2099.238281,21.984371,   8, 0},
	{60, 2424.272216,-2098.486083,21.968750,   8, 0},
	{61, 2424.424072,-2101.433837,21.976562,   8, 0},
	{62, 2419.159912,-2113.688964,21.977762,   8, 0},
	{63, 2421.660888,-2118.918212,21.968750,   8, 0},
	{64, 2418.361572,-2119.936035,21.968750,   8, 0},
	{65, 2772.707763,-2492.270019,21.790222,   9, 0},
	{66, 2768.835449,-2494.677978,21.821174,   9, 0},
	{67, 2773.885253,-2499.070312,21.871408,   9, 0},
	{68, 2776.607666,-2495.907714,21.831602,   9, 0},
	{69, 2766.460205,-2502.332763,21.875295,   9, 0},
	{70, 2763.528564,-2498.260498,21.864973,   9, 0},
	{71, 2771.390380,-2503.564208,21.873313,   9, 0},
	{72, 2767.151611,-2509.623046,21.874898,   9, 0},
	{73, 1700.797241,2531.345703,15.571876,   10, 0},
	{74, 1702.867431,2527.150634,15.442232,   10, 0},
	{75, 1706.938476,2525.129638,15.423177,   10, 0},
	{76, 1712.064697,2526.882568,15.429267,   10, 0},
	{77, 1713.981445,2532.720214,15.460651,   10, 0},
	{78, 1706.634643,2529.126464,15.445849,   10, 0},
	{79, 1699.315429,2528.131835,15.539705,   10, 0},
	{80, 1697.395019,2530.831787,15.645612,   10, 0}
};

new fire_sphere[MAX_FIRE];
new fire_object[MAX_FIRE];

public OnGameModeInit()
{
    exit_mchs = CreateDynamicSphere(-2600.141113,-283.324401,1246.680419, 0.5);
    enter_mchs = CreateDynamicSphere(-2558.123535,-284.654937,27.354429, 1.0);

    CreateActorEx("Начальник МЧС", "Подойдите для взаимодействия", 261, -2615.917724,-282.265045,1252.043823,265.929382, 1, 1);
    npc_mchs_1 = CreateDynamicSphere(-2615.917724,-282.265045,1252.043823, 2.5);

    invent_mchs = CreateDynamicSphere(-2608.042480,-282.297698,1252.043823, 2.7);
    veh_mchs = CreateDynamicSphere(-2555.758544,-277.883331,27.260526, 2.7);
    CreateDynamic3DTextLabel("Подойдите чтобы взять огнетушитель", 0xFFEE00FF3, -2608.042480,-282.297698,1252.043823, 15.0);
    CreateDynamic3DTextLabel("Подойдите чтобы взять рабочий транспорт", 0xFFEE00FF3, -2555.758544,-277.883331,27.260526, 15.0);
    CreateDynamic3DTextLabel("Вход в МЧС\n[Работа пожарника]", 0xFFBB00FF3, -2558.123535,-284.654937,27.354429, 5.0);
    CreateDynamic3DTextLabel("Выход из МЧС\n[Работа пожарника]", 0xFFBB00FF3, -2600.141113,-283.324401,1246.680419, 5.0);
    SetTimer("LoadOrdersMchs", 5000, false);
    SetTimer("TimerMchs", 60000*5, true);

    #if defined mchs_OnGameModeInit
        return mchs_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit mchs_OnGameModeInit
#if defined mchs_OnGameModeInit
    forward mchs_OnGameModeInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    if(player_order[playerid])
    {
        new id = player_order[playerid];
        mysql_format(mysql, String128m, sizeof String128m, "DELETE FROM order_mchs WHERE id = %d AND id_player = %d", id - 1, GetPlayerAccountID(playerid));
	    mysql_query(mysql, String128m, false);
        order_mchs[id - 1][MS_State] = STATE_ORDER_N_COMPLETED;
        endOrders(id);
        player_order[playerid] = 0;
        DestroyVehicle(player_veh_mchs[playerid]);
        if(mysql_errno()) return print("Ошибка в запросе 6");
        player_mchs_active{playerid} = false;
    }
    #if defined mchs_OnPlayerDisconnect
        return mchs_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect mchs_OnPlayerDisconnect
#if defined mchs_OnPlayerDisconnect
    forward mchs_OnPlayerDisconnect(playerid, reason);
#endif


public OnPlayerConnect(playerid)
{
    player_order[playerid] = 0;
    player_veh_mchs[playerid] = -1;
    #if defined mchs_OnPlayerConnect
        return mchs_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect mchs_OnPlayerConnect
#if defined mchs_OnPlayerConnect
    forward mchs_OnPlayerConnect(playerid);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == exit_mchs)
    {
        SetPlayerPosEx(playerid, -2556.406005,-284.757751,27.354429,275.161071,  0, 0);
    }
    if(areaid == enter_mchs)
    {
        SetPlayerPosEx(playerid, -2600.153564,-281.323333,1246.680419,5.701898,  1, 1);
    }
    if(areaid == npc_mchs_1)
    {
        Dialog
        (
            playerid, 3501, DSL, 
            "Начальник МЧС",
            "Начать/закончить смену\n"\
            "Информация", 
            "Далее", "Назад"
        );
    }
    if(areaid == invent_mchs)
    {
        if(!player_mchs_active{playerid}) return SCM(playerid, -1,""USC" Сначало начните смену");
        Dialog(playerid, 3502, DSM, "Инвентарная МЧС", "Вы хотите взять огнетушитель", "Взять", "Назад");
    }
    if(areaid == veh_mchs)
    {
        if(!player_mchs_active{playerid}) return SCM(playerid, -1,""USC" Сначало начните смену");
        Dialog(playerid, 3503, DSM, "Рабочий транспорт МЧС", "Вы хотите взять рабочий транспорт", "Взять", "Назад");
    }
    #if defined mchs_OnPlayerEnterDynamicArea
        return mchs_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 1;
    #endif
}

#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea mchs_OnPlayerEnterDynamicArea
#if defined mchs_OnPlayerEnterDynamicArea
    forward mchs_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 3500)
    {
        if(response)
        {
            new id = GetPlayerListitemValue(playerid, listitem);

            EnablePlayerGPS(playerid, 55, coord_order[id][0],  coord_order[id][1], coord_order[id][2], "Местоположение заказа отмечено на карте!");

            player_order[playerid] = id + 1;

            order_mchs[id][MS_IDp] = playerid;

            mysql_format(mysql, String128m, sizeof String128m, "UPDATE order_mchs SET id_player = %d, state = %d WHERE id = %d", GetPlayerAccountID(playerid), STATE_ORDER_TAKE, id);
	        mysql_query(mysql, String128m, false);

            if(mysql_errno()) return SCM(playerid, -1, "Ошибка в запросе 1");

            LoadFireOrder(id + 1);
        }
    }
    if(dialogid == 3501)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(player_mchs_active{playerid})
                    {
                        //SetPlayerSkinInit(playerid);
                        player_mchs_active{playerid} = false;
                        if(player_order[playerid])
                        {
                            endOrders(player_order[playerid]);
                            order_mchs[player_order[playerid]][MS_State] = STATE_ORDER_N_COMPLETED;
                            player_order[playerid] = 0;
                        }
                        if(player_veh_mchs[playerid])
                        {
                            DestroyVehicle(player_veh_mchs[playerid]);
                            player_veh_mchs[playerid] = -1;
                        }
                    }
                    else
                    {
                        SetPlayerSkin(playerid, 800);
                        player_mchs_active{playerid} = true;
                        SCM(playerid, -1, ""SC" Вы начали смену в МЧС");
                    }
                }
                case 1:
                {
                    if(!player_mchs_active{playerid}) return SCM(playerid, -1, ""USC" Сначало начните смену");

                    Dialog
                    (
                        playerid, -1, DSM, 
                        "Информация о работе в МЧС",
                        "Чтобы взять заказ сначало возьмите огнетушитель и арендуйте транспорт \n"\
                        "Аренда транспорта находится на территории МЧС \n"\
                        "Далее возьмите заказ с помощью /meslist",
                        "Хорошо", "Выйти"
                    );

                }
            }
        }
    }
    if(dialogid == 3502)
    {
        if(response)
        {
            GivePlayerWeapon(playerid, 42, 10000);
            SCM(playerid, -1, ""SC" Вы взяли огнетушитель");
        }
    }
    if(dialogid == 3503)
    {
        if(response)
        {
            new veh_id;

            veh_id = CreateVehicle(407,-2554.483398,-301.090240,27.252866,270.0, 3, 3, false);
            PutPlayerInVehicle(playerid, veh_id, 0);

            player_veh_mchs[playerid] = veh_id;

            SCM(playerid, -1, ""SC" Вы взяли рабочий транспорт МЧС");
            SCM(playerid, -1, ""SC" Используйте /meslist чтобы взять заказ");
        }
    }
    #if defined mchs_OnDialogResponse
return mchs_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse mchs_OnDialogResponse
#if defined mchs_OnDialogResponse
forward mchs_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_FIRE))
	{
        if(press_fire{playerid}) return SCM(playerid, -1, ""USC" Подождите немного...");

		if(GetPlayerWeapon(playerid) == 42)
		{
			if(IsPlayerInRangeOfAnyFire(playerid) >= 1)
			{
                press_fire{playerid} = true;
                SetTimerEx("CountDownFire", 500, false, "i", playerid);

                if(all_fire[IsPlayerInRangeOfAnyFire(playerid)][F_ID_Z] == player_order[playerid])
                {
                    new id_fire = IsPlayerInRangeOfAnyFire(playerid), id = player_order[playerid];
                    new text[34];

                    SetTimerEx("PressedFire", 1000, false, "i", playerid);

                    if(all_fire[id_fire][F_SCORE] == -1) return 1;

                    if(all_fire[id_fire][F_SCORE] == 10)
                    { 
                        all_fire[id_fire][F_SCORE] = -1;
                        DestroyObject(fire_object[id_fire]);
                        DestroyDynamicArea(fire_sphere[id_fire]);

                        SCM(playerid, -1, ""SC" Вы потушили огонь");

                        if(Order(id))
                        {
                            SCM(playerid, -1, ""SC" Вы выполнили заказ");
                            order_mchs[id - 1][MS_State] = STATE_ORDER_COMPLETED;
                            GivePlayerMoneyEx(playerid, 10000); //ВМЕСТО 10000 ПОСТАВЬ ЦИФРЫ ЗП
                            endOrders(id);
                            player_order[playerid] = 0;
                            mysql_format(mysql, String128m, sizeof String128m, "DELETE FROM order_mchs WHERE id = %d", id -1);
	                        mysql_query(mysql, String128m, false);

                            if(mysql_errno()) return SCM(playerid, -1, "Ошибка в запросе 2");
                        }
                        return 1;
                    }
                    
                    all_fire[id_fire][F_SCORE] ++;
                    format(text, sizeof text, "~y~Прогресс: ~w~%d/10", all_fire[id_fire][F_SCORE]);

                    GameTextForPlayer(playerid, text, 3000, 5);

                    return 0;
                }
                else SCM(playerid, -1, ""USC" Эти очаги не с вашего заказа");
			}
			else SCM(playerid, -1, ""USC" Вы не у очага огня");
		}
	}
        #if defined mchs_OnPlayerKeyStateChange
        return mchs_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange mchs_OnPlayerKeyStateChange
#if defined mchs_OnPlayerKeyStateChange
    forward mchs_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif
stock LoadFireOrder(id)
{
    order_mchs[id][MS_State] = STATE_ORDER_TAKE;

    for(new i; i < sizeof all_fire; i++)
	{
        if(all_fire[i][F_ID_Z] != id) continue;

		fire_object[i] = CreateObject(18691, all_fire[i][F_X], all_fire[i][F_Y], all_fire[i][F_Z] - 2.0, 0.0, 0.0, 0.0, 10.0);
		fire_sphere[i] = CreateDynamicSphere(all_fire[i][F_X], all_fire[i][F_Y], all_fire[i][F_Z], 0.8);
	}
	return printf("Заказ:%d загружен", id);
}
public: LoadOrdersMchs()
{
    mysql_format(mysql, String128m, sizeof String128m, "DELETE FROM order_mchs");
	mysql_query(mysql, String128m, false);
    if(mysql_errno()) return print("Ошибка в запросе 5");

    switch(random(2))
    {
        case 0:
        {
            for(new o; o < 5;o++)
            {
              LoadOrderInMesList(o);  
            }
        }
        case 1:
        {
            for(new o = 5;o < 10;o++)
            {
              LoadOrderInMesList(o);  
            }
        }
    }
    return 1;
}
stock LoadOrderInMesList(id)
{
    order_mchs[id][MS_State] = STATE_ORDER_NO_TAKE;
	mysql_format(mysql, String128m, sizeof String128m, "INSERT INTO order_mchs (id,id_player,state) VALUES (%d,0,1)", id);
	mysql_query(mysql, String128m, false);
    if(mysql_errno()) return print("Ошибка в запросе 3");
    return 1;
}

stock IsPlayerInRangeOfAnyFire(playerid)
{
	for(new idx; idx < sizeof all_fire; idx ++)
	{
		if(IsPlayerInDynamicArea(playerid, fire_sphere[idx])) return idx;
	}
	return 0;
}

public: PressedFire(playerid)
{
    OnPlayerKeyStateChange(playerid, KEY_FIRE, KEY_FIRE);
    return 1;
}

stock Order(id)
{
    new fire_c;

    for(new i; i < MAX_FIRE;i++)
    {
        if(all_fire[i][F_ID_Z] != id) continue;

        if(all_fire[i][F_SCORE] == -1) fire_c++;
    }

    if(fire_c == 8) return 1;
    else return 0;
}
stock endOrders(id)
{
    for(new i; i < MAX_FIRE;i++)
    {
        if(all_fire[i][F_ID_Z] != id) continue;

        if(all_fire[i][F_SCORE] != -1)
        {
            DestroyObject(fire_object[i]);
            DestroyDynamicArea(fire_sphere[i]);
        }
    }
    return 1;

}
public: TimerMchs()
{
    for(new z;z < sizeof (order_mchs);z++)
    {
        if(order_mchs[z][MS_State] == STATE_ORDER_TAKE) continue;
        if(order_mchs[z][MS_State] == STATE_ORDER_NO_TAKE) continue;

        order_mchs[z][MS_State] = STATE_ORDER_NO_TAKE;
	    mysql_format(mysql, String128m, sizeof String128m, "INSERT INTO order_mchs (id,id_player,state) VALUES (%d,0,1)", z);
	    mysql_query(mysql, String128m, false);
        printf("new order mchs: %d", z);
        if(mysql_errno()) return print("Ошибка в запросе 4");
        break;
    }
    return 1;
}

stock DialogMhsc(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;//егор ссбонус
}

CMD:meslist(playerid)
{
    if(!player_mchs_active{playerid}) return SCM(playerid, -1, ""USC" Сначало устройтесь в МЧС");
    new Cache:result;
    mysql_format(mysql, mString512, sizeof mString512, "SELECT * FROM order_mchs WHERE `state` = 1");
	result = mysql_query(mysql, mString512, true);

    new rows = cache_num_rows();
    if(mysql_errno()) return print("Ошибка в запросе 4");

    if(!rows) return SCM(playerid, 0xFFFFFFFF3, "На данный момент заказов нет. Ждите пейдей");

    if(player_order[playerid]) return SCM(playerid, -1, ""USC" У вас уже есть заказ");

    new id, text[185], list[sizeof text * 10 + 50] = "{FFFFFF}Номер Заказа\tРасстояние\n";
    new Float:dista;

    if(rows)
    {
        for(new r; r< rows; r++)
        {
            id = cache_get_field_content_int(r, "id");
            dista = GetPlayerDistanceFromPoint(playerid, coord_order[id][0], coord_order[id][1], coord_order[id][2]);

            if(order_mchs[id][MS_State] != STATE_ORDER_NO_TAKE) continue;

            format(text, sizeof text, "{FFFFFF}Заказ [%d]\t{B3B3B3}%.2f\n", id, dista);
            strcat(list, text);
            SetPlayerListitemValue(playerid, r, id);
        }

        DialogMhsc(playerid, 3500, DSTH, "Доступные заказы", list, "Взять", "Назад");

    }
    return 1;

}

public:CountDownFire(playerid)  press_fire{playerid} = false;