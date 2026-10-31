new small_veh_to_market, medium_veh_to_market, high_veh_to_market, bike_veh_to_market, pickup_used_market, pickup_exit_used_market[2];

new sphere_veh_enter_used_market[8], shpr_exit_veh_us_mrkt_to_int[8];

enum STRUCT_USED_MARKET
{
    bool:MARKET_SMALL,    
    bool:MARKET_MEDIUM,
    bool:MARKET_HIGH,
    bool:MARKET_BIKE,
}

enum STRUCT_VEH_MARKET
{
    ID_MARKET,
    TYPE_MARKET,
}

#define VEH_HIGH        3
#define VEH_MEDIUM      2    
#define VEH_SMALL       1    
#define VEH_BIKE        0          

new car_market_type[88][STRUCT_VEH_MARKET] = // Обновляем до 88 записей
{
    // Мотосалон (без изменений)
    {462, VEH_BIKE},
    {468, VEH_BIKE},
    {523, VEH_BIKE},
    {463, VEH_BIKE},
    {461, VEH_BIKE},
    {521, VEH_BIKE},
    {581, VEH_BIKE},
    {586, VEH_BIKE},
    {522, VEH_BIKE},
    // Низкий Класс (без изменений)
    {555, VEH_SMALL},
    {549, VEH_SMALL},
    {401, VEH_SMALL},
    {404, VEH_SMALL},
    {479, VEH_SMALL},
    {412, VEH_SMALL},
    {439, VEH_SMALL},
    {458, VEH_SMALL},
    {491, VEH_SMALL},
    {492, VEH_SMALL},
    {585, VEH_SMALL},
    {496, VEH_SMALL},
    {536, VEH_SMALL},
    {529, VEH_SMALL},
    {534, VEH_SMALL},
    {540, VEH_SMALL},
    {542, VEH_SMALL},
    {547, VEH_SMALL},
    {419, VEH_SMALL},
    // Высокий Класс (добавляем все ID из car_market_data)
    {489, VEH_HIGH}, // Volvo XC90
    {480, VEH_HIGH}, // BMW Z4 M40I
    {543, VEH_HIGH}, // Chevrolet Camaro ZL1
    {558, VEH_HIGH}, // BMW M4 F84
    {503, VEH_HIGH}, // Dodge Demon SRT
    {505, VEH_HIGH}, // Cadillac Escalade IV
    {400, VEH_HIGH}, // BMW X6M F16
    {495, VEH_HIGH}, // Ford Raptor F-150
    {502, VEH_HIGH}, // Nissan GT-R R35
    {405, VEH_HIGH}, // Audi RS6
    {402, VEH_HIGH}, // Mercedes-Benz GT63s
    {410, VEH_HIGH}, // Mercedes-Benz C63s AMG
    {475, VEH_HIGH}, // Audi Q8
    {506, VEH_HIGH}, // Porsche 911 Carrera S
    {604, VEH_HIGH}, // Porsche Panamera S
    {490, VEH_HIGH}, // Range Rover SVR
    {533, VEH_HIGH}, // Audi R8 V10
    {429, VEH_HIGH}, // Mercedes-Benz GT-R
    {494, VEH_HIGH}, // BMW I 8 Roadster
    {466, VEH_HIGH}, // BMW M5 F90
    {451, VEH_HIGH}, // McLaren 600LT
    {579, VEH_HIGH}, // Mercedes-Benz G65 AMG
    {411, VEH_HIGH}, // Aston Martin DB11
    {541, VEH_HIGH}, // Ferrari 488 GTB
    {415, VEH_HIGH}, // Lamborghini Aventador S
    {2386, VEH_HIGH}, // BMW 3-Series G20
    {2394, VEH_HIGH}, // Dodge Charger SRT
    {2388, VEH_HIGH}, // BMW M5 F10
    {2622, VEH_HIGH}, // Ford Mustang Mach E
    {2608, VEH_HIGH}, // Jeep Wrangler JL
    {2392, VEH_HIGH}, // Toyota Supra A90
    {2553, VEH_HIGH}, // Audi Q7
    {2603, VEH_HIGH}, // Mercedes-Benz E63 W212
    {2598, VEH_HIGH}, // BMW M4 G82
    {2547, VEH_HIGH}, // Toyota Land Cruiser 200
    {420, VEH_HIGH}, // Audi RS6 C7 Рестайлинг
    {2582, VEH_HIGH}, // Mercedes-Benz CLS63 AMG
    {2574, VEH_HIGH}, // BMW X7 M50I
    {2559, VEH_HIGH}, // Cadillac Escalade
    {2546, VEH_HIGH}, // Mercedes-Benz E63S
    {2391, VEH_HIGH}, // BMW X5M G05
    {2599, VEH_HIGH}, // BMW 7-Series 750LI
    {2626, VEH_HIGH}, // Porsche Cayenne S
    {2544, VEH_HIGH}, // Tesla Model S
    {680, VEH_HIGH}, // Range Rover Velar
    {2551, VEH_HIGH}, // Lamborghini Urus
    {2549, VEH_HIGH}, // Lamborghini Huracan
    {2393, VEH_HIGH}, // Chevrolet Corvette C8
    {679, VEH_HIGH}, // Audi A8 2022
    {2578, VEH_HIGH}, // BMW M8 F92
    {2581, VEH_HIGH}, // Porsche Taycan Turbo S
    {2579, VEH_HIGH}, // BMW M8 F93 Gran Coupe
    {2543, VEH_HIGH}, // Tesla Model X
    {2573, VEH_HIGH}, // Mercedes-Benz G63 AMG
    {2590, VEH_HIGH}, // Mercedes-Benz EQS580
    {2558, VEH_HIGH}, // Mercedes-Benz MB S650
    {2619, VEH_HIGH}, // Ferrari 488 Pista
    {2597, VEH_HIGH}, // Aurus Senat
    {2583, VEH_HIGH}, // Rolls-Royce Wraith
    {2564, VEH_HIGH}, // Rolls-Royce Cullinan
    {2563, VEH_HIGH}, // Rolls-Royce Phantom
    {2591, VEH_HIGH}, // Bentley Continental GT
    {2607, VEH_HIGH}, // BMW M1
    {2600, VEH_HIGH}, // Bentley Mulliner Bacalar
    {2601, VEH_HIGH}, // Bugatti Chiron
    {2570, VEH_HIGH}, // Bugatti Divo
    {2569, VEH_HIGH}, // Bugatti La Noire
    // Средний Класс (без изменений)
    {562, VEH_MEDIUM}, // Nissan Skyline R34
    {507, VEH_MEDIUM}, // Audi A4
    {546, VEH_MEDIUM}, // Hyundai Solaris 2021
    {426, VEH_MEDIUM}, // BMW M5 E39
    {516, VEH_MEDIUM}, // Volkswagen Polo
    {467, VEH_MEDIUM}, // Mercedes-Benz S600 W140
    {527, VEH_MEDIUM}, // BMW M3 E46
    {445, VEH_MEDIUM}, // Acura TSX
    {477, VEH_MEDIUM}, // Mazda RX-7
    {589, VEH_MEDIUM}, // Volkswagen Golf GTI
    {587, VEH_MEDIUM}, // Ford Focus RS
    {436, VEH_MEDIUM}, // Mitsubishi Lancer Evo X
    {560, VEH_MEDIUM}, // Subaru WRX STI
    {565, VEH_MEDIUM}, // Mercedes-Benz A45 AMG
    {550, VEH_MEDIUM}, // Toyota Camry 3.5
    {603, VEH_MEDIUM}, // Ford Mustang GT
    {526, VEH_MEDIUM}, // Infiniti Q60S
    {551, VEH_MEDIUM}, // Alfa Romeo Giulia
    {442, VEH_MEDIUM}  // Volvo V60
};

new Float:coord_veh_enter_used_market[8][3] = 
{
    {1970.957031,-546.201171,12.448518}, 
    {1963.993408,-546.201843,12.448415}, 
    {1956.899414,-546.201110,12.448528}, 
    {1949.680175,-546.201416,12.448480}, 
    {1942.985107,-546.201049,12.448537}, 
    {1935.941406,-546.203613,12.448143},
    {1992.953613,-546.202819,12.448265},
    {1985.818847,-546.201354,12.448490}
};

new Float:coord_veh_exit_used_market[8][3] = 
{
    {1984.905273,-510.499938,12.452824}, 
    {1977.895263,-510.500549,12.452918}, 
    {1971.000244,-510.500732,12.452945}, 
    {1963.805786,-510.500793,12.452955}, 
    {1956.793334,-510.500793,12.452955}, 
    {1950.178466,-510.500305,12.452880},
    {1942.700317,-510.500671,12.452937},
    {1935.951416,-510.499328,12.452730}
};

new Float:coord_spawn_veh_used_market[2][4] =
{
    {441.655792,1000.270690,1001.0,268.121917}, 
    {441.001007,962.392883,1001.0,272.226806}
};

new Float:coord_spawn_player_used_market[2][4] =
{
    {439.188537,982.508117,1001.0,262.025390}, 
    {561.245300,1001.142578,1001.0,1.617309}
};

new Float:coord_pickup_player_used_market[2][4] =
{
    {437.272247,982.686950,1001.0}, 
    {562.727172,1001.014343,1001.0}
};

new Float:pos_exit_veh_us_mrkt_to_int[8][3] = 
{
    {554.048034,1082.757690,1001.0}, 
    {562.782226,1018.124511,1001.0}, 
    {562.781677,962.899597,1001.0}, 
    {554.004638,917.241455,1001.0}, 
    {499.953247,917.398071,1001.0}, 
    {481.996002,953.842346,1001.0}, 
    {473.102172,1018.351440,1001.0}, 
    {481.970123,1082.759277,1001.0} 
};

new player_to_market[MAX_PLAYERS][STRUCT_USED_MARKET];

public OnPlayerSpawn(playerid)
{
    player_exit_from_used_market(playerid);
    #if defined by_OnPlayerSpawn
        return by_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn by_OnPlayerSpawn
#if defined by_OnPlayerSpawn
    forward by_OnPlayerSpawn(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    player_exit_from_used_market(playerid);
    #if defined by_OnPlayerDisconnect
        return by_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect by_OnPlayerDisconnect
#if defined by_OnPlayerDisconnect
    forward by_OnPlayerDisconnect(playerid, reason);
#endif

public OnGameModeInit()
{
    print("[LAIRD_SYSTEM] Авторынок успешно загружен\nАвтор: Welsi Studio");
    CreateUsedMarket();
    #if defined by_OnGameModeInit
        return by_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit by_OnGameModeInit
#if defined by_OnGameModeInit
    forward by_OnGameModeInit();
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == pickup_used_market)
    {
        new text[512];

        format
        (
            text, sizeof text, 
            "№ Название\tКол-во авто\tДействие\n"\
            "{FF6347}1. {FFFFFF}Низкий класс\t{FF6347}%d\t{7A7A7A}Нажмите для входа\n"\
            "{FF6347}2. {FFFFFF}Средний класс\t{FF6347}%d\t{7A7A7A}Нажмите для входа\n"\
            "{FF6347}3. {FFFFFF}Высокий класс\t{FF6347}%d\t{7A7A7A}Нажмите для входа\n"\
            "{FF6347}4. {FFFFFF}Мотоциклы\t{FF6347}%d\t{7A7A7A}Нажмите для входа",
            small_veh_to_market,
            medium_veh_to_market,
            high_veh_to_market,
            bike_veh_to_market
        );

        DialogUsed
        (
            playerid, 3456, DIALOG_STYLE_TABLIST_HEADERS,
            "{FF6347}Авторынок | Выбор класса",
            text,
            "Далее", "Закрыть"
        );
    }
    if(pickup_exit_used_market[0] <= areaid <= pickup_exit_used_market[1])
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            SetPlayerPos(playerid, 1980.827392,-550.358337,11.974724);
            SetPlayerFacingAngle(playerid, 188.714859);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
    }
    #if defined by_OnPlayerEnterDynamicArea
        return by_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea by_OnPlayerEnterDynamicArea
#if defined by_OnPlayerEnterDynamicArea
    forward by_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_CROUCH))
    {
        new r; 

        if(is_player_in_area_used_market(playerid, true) != -1)
        {

            if(IsPlayerInAnyVehicle(playerid))
            {

                if(GetPlayerOwnableCar(playerid) != GetPlayerVehicleID(playerid))
                    return SendClientMessage(playerid, -1, ""SC" Зайти в авторынок можно только на своем транспорте");

                new vehicle_market = GetPlayerVehicleMarket(GetVehicleModel(GetPlayerOwnableCar(playerid))), veh = GetPlayerOwnableCar(playerid);

                switch(vehicle_market)
                {
                    case 0:{
                        player_to_market[playerid][MARKET_BIKE] = true;
                        bike_veh_to_market++;
                    }
                    case 1:{
                        player_to_market[playerid][MARKET_SMALL] = true;
                        small_veh_to_market++;
                    }
                    case 2:{
                        player_to_market[playerid][MARKET_MEDIUM] = true;
                        medium_veh_to_market++;
                    }
                    case 3:{
                        player_to_market[playerid][MARKET_HIGH] = true;
                        high_veh_to_market++;
                    }
                }

                r = random(2);

                SetPlayerPos(playerid, coord_spawn_veh_used_market[r][0], coord_spawn_veh_used_market[r][1], coord_spawn_veh_used_market[r][2]);
                SetVehiclePos(veh, coord_spawn_veh_used_market[r][0], coord_spawn_veh_used_market[r][1], coord_spawn_veh_used_market[r][2]);
                SetPlayerInterior(playerid, 1);
                LinkVehicleToInterior(veh, 1);
                SetVehicleVirtualWorld(veh, vehicle_market + 1);
                SetPlayerVirtualWorld(playerid, vehicle_market + 1);
                PutPlayerInVehicle(playerid, veh, 0);
                SetVehicleZAngle(veh, coord_spawn_veh_used_market[r][3]);
            }
        }
        else if(is_player_in_area_used_market(playerid, false) != -1)
        {
            if(IsPlayerInAnyVehicle(playerid))
            {
                r = random(8);

                new veh = GetPlayerOwnableCar(playerid);

                SetPlayerPos(playerid, coord_veh_exit_used_market[r][0], coord_veh_exit_used_market[r][1], coord_veh_exit_used_market[r][2]);
                SetVehiclePos(veh, coord_veh_exit_used_market[r][0], coord_veh_exit_used_market[r][1], coord_veh_exit_used_market[r][2]);
                SetPlayerInterior(playerid, 0);
                LinkVehicleToInterior(veh, 0);
                SetVehicleVirtualWorld(veh, 0);
                SetPlayerVirtualWorld(playerid, 0);
                PutPlayerInVehicle(playerid, veh, 0);
                SetVehicleZAngle(veh, 10.0);

                player_exit_from_used_market(playerid);
            }
        }
    }
    #if defined by_OnPlayerKeyStateChange
        return by_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange by_OnPlayerKeyStateChange
#if defined by_OnPlayerKeyStateChange
    forward by_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 3456)
    {
        if(response)
        {
            new market, r = random(2);

            switch(listitem)
            {
                case 0:market = 1;
                case 1:market = 2;
                case 2:market = 3;
                case 3:market = 0;
            }

            SetPlayerPos(playerid, coord_spawn_player_used_market[r][0], coord_spawn_player_used_market[r][1], coord_spawn_player_used_market[r][2]);
            SetPlayerFacingAngle(playerid, coord_spawn_player_used_market[r][3]);
            SetPlayerInterior(playerid, 1);
            SetPlayerVirtualWorld(playerid, market+1);
        }
    }
    #if defined by_OnDialogResponse
return by_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse by_OnDialogResponse
#if defined by_OnDialogResponse
forward by_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

stock player_exit_from_used_market(playerid)
{
    if(player_to_market[playerid][MARKET_SMALL])
    {
        small_veh_to_market--;
        player_to_market[playerid][MARKET_SMALL] = false;
    }
    if(player_to_market[playerid][MARKET_MEDIUM])
    {
        medium_veh_to_market--;
        player_to_market[playerid][MARKET_MEDIUM] = false;
    }

    if(player_to_market[playerid][MARKET_HIGH])
    {
        high_veh_to_market--;
        player_to_market[playerid][MARKET_HIGH] = false;
    }
    if(player_to_market[playerid][MARKET_BIKE])
    {
        bike_veh_to_market--;
        player_to_market[playerid][MARKET_BIKE] = false;
    }

    return 1;
}

stock player_to_used_market(playerid)
{
    new used_market;

    if(player_to_market[playerid][MARKET_SMALL]) used_market = 1;
    if(player_to_market[playerid][MARKET_MEDIUM]) used_market = 2;
    if(player_to_market[playerid][MARKET_HIGH]) used_market = 3;
    if(player_to_market[playerid][MARKET_BIKE]) used_market = 4;

    return used_market;
}

stock CreateUsedMarket()
{
    for(new c;c < 8;c++)
    {
        sphere_veh_enter_used_market[c] = CreateDynamicSphere(coord_veh_enter_used_market[c][0], coord_veh_enter_used_market[c][1], coord_veh_enter_used_market[c][2] + 0.5, 6.0, 0);
        Create3DTextLabel("{FFFF00}Авторынок\n\n{FFFFFF}Нажмите {FF0000}'гудок'{FFFFFF} находясь в машине", -1, coord_veh_enter_used_market[c][0], coord_veh_enter_used_market[c][1], coord_veh_enter_used_market[c][2] + 1.7, 20.0, 0);
    }

    for(new c;c < 8;c++)
    {
        CreateDynamicPickup(19134, 23, pos_exit_veh_us_mrkt_to_int[c][0], pos_exit_veh_us_mrkt_to_int[c][1], pos_exit_veh_us_mrkt_to_int[c][2]);
        shpr_exit_veh_us_mrkt_to_int[c] = CreateDynamicSphere(pos_exit_veh_us_mrkt_to_int[c][0], pos_exit_veh_us_mrkt_to_int[c][1], pos_exit_veh_us_mrkt_to_int[c][2], 4.0, -1, 1);
        CreateDynamic3DTextLabel("{FFFF00}Выезд\n\n{FFFFFF}Нажмите {FF0000}'гудок'{FFFFFF} находясь в машине", -1, pos_exit_veh_us_mrkt_to_int[c][0], pos_exit_veh_us_mrkt_to_int[c][1], pos_exit_veh_us_mrkt_to_int[c][2] + 1.7, 20.0);
    }
    for(new c;c < 2;c++)
    {
        CreateDynamicPickup(19134, 23, coord_pickup_player_used_market[c][0], coord_pickup_player_used_market[c][1], coord_pickup_player_used_market[c][2]);
        pickup_exit_used_market[c] = CreateDynamicSphere(coord_pickup_player_used_market[c][0], coord_pickup_player_used_market[c][1], coord_pickup_player_used_market[c][2], 1.0);
    }

    CreateDynamicPickup(19134, 23, 1980.876953,-545.951843,12.500099, 0);
    Create3DTextLabel("{FFFF00}Вход\n\n{FFFFFF}Подойдите ближе чтобы войти", -1, 1980.876953,-545.951843,12.500099 + 0.5, 10.0, 0);
    pickup_used_market = CreateDynamicSphere(1980.876953,-545.951843,12.500099, 2.0, 0, 0);
    return 1;
}

stock is_player_in_area_used_market(playerid, bool:type)
{
    new id = -1;
    if(type)
    {
        for(new idx; idx < 8; idx ++)
	    {
	    	if(IsPlayerInDynamicArea(playerid, sphere_veh_enter_used_market[idx])) id = idx;
	    }
    }
    else
    {
        for(new idx; idx < 8; idx ++)
	    {
	    	if(IsPlayerInDynamicArea(playerid, shpr_exit_veh_us_mrkt_to_int[idx])) id = idx;
	    }
    }

    return id;
}

stock GetPlayerVehicleMarket(veh)
{
    new market = -1;

    for(new v; v < sizeof car_market_type;v++)
    {
        if(car_market_type[v][ID_MARKET] != veh) continue;

        market = car_market_type[v][TYPE_MARKET];
        return market;
    }
    //printf("market = %d, id = %d", market, veh);
    if(market == -1) market = 1;

    return market;
}

stock DialogUsed(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}