new player_type_dragy[MAX_PLAYERS];
new player_timer_dragy[MAX_PLAYERS];
new Float:player_speed[MAX_PLAYERS][2];
new player_second_dragy[MAX_PLAYERS];

#define SPEED_VEHICLE_100   56.9
#define SPEED_VEHICLE_200   SPEED_VEHICLE_100*2
#define SPEED_VEHICLE_300   SPEED_VEHICLE_100*3
#define SPEED_VEHICLE_400   SPEED_VEHICLE_100*4

enum struct_dragy
{
    bool:DR_ACTIVE,
    DR_ID, 
    DR_DATE,
    DR_VEHICLE,
    DR_VEHICLE_ID,
    Float:DR_SPEED_100,
    Float:DR_SPEED_200,
    Float:DR_SPEED_300,
    Float:DR_SPEED_400,
    Float:DR_SPEED_100_200,
    Float:DR_SPEED_200_300,
    Float:DR_SPEED_300_400,
    DR_TYPE,
    DR_SECOND
}

new player_info_dragy[MAX_PLAYERS][struct_dragy];

cmd:dragy(playerid)
{
    //if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""SC" Вы должна сначало сесть в транспорт.");

    new text[124], active[22];

    /*if(player_info_dragy[playerid][DR_ACTIVE]) active ="{00FF00} Включен";
    else active="{FF0000} Выключен";*/

    format(text, sizeof text,
        "Статус %s\n"\
        "Последний заезд\n"\
        "Мои результаты\n"\
        "Лучшие результаты\n"\
        "Поиск результатов\n"\
        "Настройка",
        player_info_dragy[playerid][DR_ACTIVE] ? ("{00FF00} Включен") : ("{FF0000} Выключен")
    );

    Dialog
    (
        playerid, 4523, DIALOG_STYLE_LIST,
        "{FF0000}Dragy",
        text,
        "Далее", "Выйти"
    );
    
    return 1;
}

new error_dragy[142] = "Ошибка! В базу данных не загружена таблица с статистикой Dragy (telegram: @welsistudio)";

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 4523)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(player_info_dragy[playerid][DR_ACTIVE]) 
                    {
                        player_info_dragy[playerid][DR_ACTIVE] = false;
                        return callcmd::dragy(playerid);
                    }

                    Dialog
                    (
                        playerid, 4524, DIALOG_STYLE_LIST,
                        "{FF0000}Dragy",
                        "1. Замер до 100 км/ч\n"\
                        "2. Замер до 200 км/ч\n"\
                        "3. Замер до 300 км/ч\n"\
                        "4. Замер до 400 км/ч",
                        "Далее", "Выйти"
                    );           
                }
                case 1:
                {
                    if(!player_info_dragy[playerid][DR_DATE]) return callcmd::dragy(playerid);

                    new text[284];
                    format(text, sizeof text, 
                    "Заезд: №%d\n\
                    Владелец: %s\n\
                    Автомобиль:%s\n\
                    Дата: %d-%02d-%02d %02d:%02d:%02d\n\
                    Замер 0-100: %.2f сек.\n\
                    Замер 0-200: %.2f сек.\n\
                    Замер 0-300: %.2f сек.\n\
                    Замер 0-400: %.2f сек.\n\
                    Замер 100-200: %.2f сек.\n\
                    Замер 200-300: %.2f сек.\n\
                    Замер 300-400: %.2f сек.",
                    player_info_dragy[playerid][DR_ID], GetPlayerNameEx(playerid), GetVehicleInfo(player_info_dragy[playerid][DR_VEHICLE]-400, VI_NAME),\
                    ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_YEARS), ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_MONTHS),\
                    ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_DAYS), ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_HOURS), ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_MINUTES), \
                    ConvertUnixTime(player_info_dragy[playerid][DR_DATE], CONVERT_TIME_TO_SECONDS), player_info_dragy[playerid][DR_SPEED_100], player_info_dragy[playerid][DR_SPEED_200], player_info_dragy[playerid][DR_SPEED_300],\
                    player_info_dragy[playerid][DR_SPEED_400], player_info_dragy[playerid][DR_SPEED_100_200], player_info_dragy[playerid][DR_SPEED_200_300], player_info_dragy[playerid][DR_SPEED_300_400]\
                    );

                    Dialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{FF0000}Dragy", text, "Назад", "");                    
                }
                case 2:
                {
                    new text[56], dialog[584], rows, Cache:result;
                    mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d", GetPlayerAccountID(playerid));
                    result = mysql_query(mysql, text);
                    if(mysql_errno()) return SendErrorSqlDragy(playerid);

                    rows = cache_num_rows();

                    if(!rows) return SendClientMessage(playerid, -1, "У вас нет результатов");

                    format(text, sizeof text, "");

                    new model, vehicle_model[10];

                    for(new i, count = -1, bool:return_model = false; i < rows;i++)
                    {
                        return_model = false;
                        model = cache_get_field_content_int(i, "veh_id");

                        for(new v;v < sizeof vehicle_model;v++) if(vehicle_model[v] == model) return_model = true;
                        
                        if(return_model) continue;

                        if(count >= 9) break;
                        
                        count++;

                        vehicle_model[count] = model;

                        format(text, sizeof text, "{FFFFFF}%s\n", g_vehicle_info[model-400][VI_NAME]);
                        strcat(dialog, text);
                        SetPlayerListitemValue(playerid, count, model);
                    }

                    Dialog(playerid, 4528, DIALOG_STYLE_LIST, "{FF0000}Dragy", dialog, "Далее", "Выйти");
                }
                case 3:
                {   
                    Dialog
                    (
                        playerid, 4526, DIALOG_STYLE_LIST,
                        "{FF0000}Dragy",
                        "1. Мои результаты\n"\
                        "2. Общие результаты",
                        "Далее", "Выйти"
                    );
                }  
                case 4:
                {
                    Dialog
                    (
                        playerid, 4529, DIALOG_STYLE_LIST,
                        "{FF0000}Dragy",
                        "1. Поиск заезда по номеру\n"\
                        "2. Поиск заезда по автомобилю",
                        "Далее", "Назад"
                    );
                }
                case 5:
                {
                    Dialog
                    (
                        playerid, 4527, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Dragy",
                        "Версия приложения: {FFFF00}1.3\n"\
                        "{FFFFFF}Последние изменения: {FFFF00}удалены результаты всех заездов\n"\
                        "{FFFFFF}Дата окончания подписки: {FFFF00}навсегда\n\n"\
                        "{FFFFFF}Вы можете написать разработчикам\n"\
                        "для улучшения и устранения ошибок сервиса,\n"\
                        "для этого используйте кнопку {FFFF00}'Написать'",
                        "Написать", "Назад"
                    );
                }
            }
        }
    }
    if(dialogid == 4527)
    {
        if(response)
        {
            if(!GetPVarInt(playerid, "inputtext_dragy"))
            {
                Dialog
                (
                    playerid, 4527, DIALOG_STYLE_INPUT,
                    "{FF0000}Dragy",
                    "Если Вы нашли недоработку или хотите улучшить сервис\n"\
                    "Опишите нам",
                    "Далее", "Выйти"
                );

                SetPVarInt(playerid, "inputtext_dragy", 1);
            }
            else
            {
                new text[184];
                format(text, sizeof text, "{FFFF00}[ПРЕДЛОЖЕНИЯ ДЛЯ DRAGY]: {FFFFFF}%s", inputtext);
                SendMessageToAdmins(text, -1);
                DeletePVar(playerid, "inputtext_dragy");
            }
        }
        else DeletePVar(playerid, "inputtext_dragy");
    }
    if(dialogid == 4526)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    Dialog
                    (
                        playerid, 4530, DIALOG_STYLE_LIST,
                        "{FF0000}Dragy",
                        "1. Замер до 100 км/ч\n"\
                        "2. Замер до 200 км/ч\n"\
                        "3. Замер до 300 км/ч\n"\
                        "4. Замер до 400 км/ч",
                        "Далее", "Выйти"
                    );
                }
                case 1:
                {
                    Dialog
                    (
                        playerid, 4531, DIALOG_STYLE_LIST,
                        "{FF0000}Dragy",
                        "1. Замер до 100 км/ч\n"\
                        "2. Замер до 200 км/ч\n"\
                        "3. Замер до 300 км/ч\n"\
                        "4. Замер до 400 км/ч",
                        "Далее", "Выйти"
                    );
                }
            }
        } 
    } 
    if(dialogid == 4530) ShowDialogStaticDragy(playerid, listitem+1, true, _, _, _, true);
    if(dialogid == 4531) ShowDialogStaticDragy(playerid, listitem+1, true, _, _, _, false);
    if(dialogid == 4528)
    {
        if(response)
        {
            new model = GetPlayerListitemValue(playerid, listitem);

            ShowDialogStaticDragy(playerid, 0, false, -1, _, model, true);
        }
    }
    if(dialogid == 4529)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    Dialog
                    (
                        playerid, 4532, DIALOG_STYLE_INPUT,
                        "{FF0000}Dragy",
                        "Введите номер заезда который хотите найти",
                        "Далее","Выйти"
                    );
                }
                case 1:
                {
                    Dialog
                    (
                        playerid, 4533, DIALOG_STYLE_INPUT,
                        "{FF0000}Dragy",
                        "Введите название авто которого хотите найти (По паспорту)",
                        "Далее","Выйти"
                    );
                }
            }
        }
    }
    if(dialogid == 4532) 
    {
        if(response)
        {
            new id = strval(inputtext);

            ShowDialogStaticDragy(playerid, 0, false, id);
        } 
    }
    if(dialogid == 4533) 
    {
        if(response)
        {
            new name[99];
            sscanf(inputtext, "s[99]", name);

            ShowDialogStaticDragy(playerid, 0, false, _, name);
        } 
    }
    if(dialogid == 4524) if(response) LoadSystemDragy(playerid, listitem+1);
    if(dialogid == 4525)
    {
        if(!response) return 1;

        new id = GetPlayerListitemValue(playerid, listitem), text[258], Cache:result;

        mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE id = %d LIMIT 1", id);
        result = mysql_query(mysql, text, true);
        if(mysql_errno()) return SendErrorSqlDragy(playerid);
        
        new id_state, owner, owner_name[24], vehicle_model,datee,
        Float:speed_100, Float:speed_200, Float:speed_300, Float:speed_400,
        Float:speed_100_200, Float:speed_200_300, Float:speed_300_400;

        id_state = cache_get_field_content_int(0, "id");
        vehicle_model = cache_get_field_content_int(0, "veh_id");
        datee = cache_get_field_content_int(0, "date");
        speed_100 = cache_get_field_content_float(0, "s100");
        speed_200 = cache_get_field_content_float(0, "s200");
        speed_300 = cache_get_field_content_float(0, "s300");
        speed_400 = cache_get_field_content_float(0, "s400");
        speed_100_200 = cache_get_field_content_float(0, "s100_200");
        speed_200_300 = cache_get_field_content_float(0, "s200_300");
        speed_300_400 = cache_get_field_content_float(0, "s300_400");
        owner = cache_get_field_content_int(0, "owner");

        cache_delete(result);

        mysql_format(mysql, text, sizeof text, "SELECT * FROM accounts WHERE id = %d LIMIT 1", owner);
        result = mysql_query(mysql, text, true);
        if(mysql_errno()) return SendClientMessage(playerid, -1, ""SC" error dragy select player sql");

        cache_get_field_content(0, "name", owner_name, mysql, 24);


        format(text, sizeof text, 
        "Заезд: №%d\n\
        Владелец: %s\n\
        Автомобиль:%s\n\
        Дата:%d-%02d-%02d %02d:%02d:%02d\n\
        Замер 0-100: %.2f сек.\n\
        Замер 0-200: %.2f сек.\n\
        Замер 0-300: %.2f сек.\n\
        Замер 0-400: %.2f сек.\n\
        Замер 100-200: %.2f сек.\n\
        Замер 200-300: %.2f сек.\n\
        Замер 300-400: %.2f сек.",
        id_state, owner_name, GetVehicleInfo(vehicle_model-400, VI_NAME),
        ConvertUnixTime(datee, CONVERT_TIME_TO_YEARS), ConvertUnixTime(datee, CONVERT_TIME_TO_MONTHS),\
        ConvertUnixTime(datee, CONVERT_TIME_TO_DAYS), ConvertUnixTime(datee, CONVERT_TIME_TO_HOURS), ConvertUnixTime(datee, CONVERT_TIME_TO_MINUTES), \
        ConvertUnixTime(datee, CONVERT_TIME_TO_SECONDS), speed_100, speed_200, speed_300, speed_400,
        speed_100_200, speed_200_300, speed_300_400
        );

        Dialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{FF0000}Dragy", text, "Назад", "");
    }

    #if defined dr_OnDialogResponse
return dr_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse dr_OnDialogResponse
#if defined dr_OnDialogResponse
forward dr_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif


stock LoadSystemDragy(playerid, type)
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""SC" Вы должны быть в транспорте");

    StockDragy(playerid);

    player_type_dragy[playerid] = type;
    player_info_dragy[playerid][DR_ACTIVE] = true;

    SendClientMessage(playerid, -1, ""SC" Dragy успешно запущен");

    player_info_dragy[playerid][DR_VEHICLE] = GetVehicleModel(GetPlayerVehicleID(playerid)); 
    player_info_dragy[playerid][DR_VEHICLE_ID] = GetPlayerVehicleID(playerid);

    if(player_timer_dragy[playerid])
    {
        KillTimer(player_timer_dragy[playerid]);
        player_timer_dragy[playerid] = 0;
    }
    player_timer_dragy[playerid] = SetTimerEx("SystemDragy", 20, true, "i", playerid);
    return 1;
}

public:SystemDragy(playerid)
{
    if(!IsPlayerConnected(playerid) || !player_info_dragy[playerid][DR_ACTIVE] || GetPlayerVehicleID(playerid) != player_info_dragy[playerid][DR_VEHICLE_ID])
    {
        if(player_timer_dragy[playerid]) KillTimer(player_timer_dragy[playerid]);
        player_timer_dragy[playerid] = 0;
        return 1;
    }

    // DR_SECOND is stored in centiseconds. 20 ms per tick = +2 centiseconds.
    player_info_dragy[playerid][DR_SECOND] += 2;
    
    new type = player_type_dragy[playerid];

    player_speed[playerid][0] = player_speed[playerid][1];
    player_speed[playerid][1] = GetVehicleSpeed(player_info_dragy[playerid][DR_VEHICLE_ID]);

    if(player_speed[playerid][0] == 0.0 && player_speed[playerid][1] >= 0.1)
    {
        SendClientMessage(playerid, -1, ""SC" Dragy: тест запущен!");
        player_info_dragy[playerid][DR_SECOND] = 0;  
        player_info_dragy[playerid][DR_SPEED_100] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_200] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_300] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_400] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_100_200] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_200_300] = 0.0;  
        player_info_dragy[playerid][DR_SPEED_300_400] = 0.0;  
        return 1;
    }

    new Float:speed_old = player_speed[playerid][0], Float:speed_new = player_speed[playerid][1], sec = player_info_dragy[playerid][DR_SECOND];

    if(
        (speed_old < SPEED_VEHICLE_100 && speed_new >= SPEED_VEHICLE_100) ||
        (speed_old < SPEED_VEHICLE_200 && speed_new >= SPEED_VEHICLE_200) ||
        (speed_old < SPEED_VEHICLE_300 && speed_new >= SPEED_VEHICLE_300) ||
        (speed_old < SPEED_VEHICLE_400 && speed_new >= SPEED_VEHICLE_400))
    {
        /*printf
        (
            "ID_veh | ID_veh_1:%d | %d\n\
            Speed Old:%f\n\
            Speed New:%f\n\
            Speed_100: %f\n\
            Speed_200: %f\n\
            Speed_300: %f\n\
            Speed_400: %f\n\
            100+9: %f\n\
            200+9: %f\n\
            300+9: %f",
            player_info_dragy[playerid][DR_VEHICLE_ID], GetPlayerVehicleID(playerid),
            player_speed[playerid][0],player_speed[playerid][1],
            SPEED_VEHICLE_100, SPEED_VEHICLE_200, SPEED_VEHICLE_300, SPEED_VEHICLE_400,
            SPEED_VEHICLE_100+0.9, SPEED_VEHICLE_200+0.9, SPEED_VEHICLE_300+0.9
        );*/

        new speed[6], text[84];

        valstr(speed, sec);

        if(0 <= sec <= 999) strins(speed, ".", 1);
        else if(1000 <= sec <= 9999) strins(speed, ".", 2);
        else if(10000 <= sec <= 99999) strins(speed, ".", 3);
        new Float:second = floatstr(speed);
        

        if(speed_old < SPEED_VEHICLE_100 && speed_new >= SPEED_VEHICLE_100)
        {
            if(player_info_dragy[playerid][DR_SPEED_100] != 0.0) return 1;

            format(text, sizeof text,  ""SC" Dragy: Вы достигли 100 км/ч за %s секунды", speed);
            SendClientMessage(playerid, -1, text);

            player_info_dragy[playerid][DR_SPEED_100] = second;

            if(type == 1) return CreateDragyStatic(playerid);

            player_info_dragy[playerid][DR_SPEED_100_200] = sec;
            
        }
        else if(speed_old < SPEED_VEHICLE_200 && speed_new >= SPEED_VEHICLE_200)
        {
            if(player_info_dragy[playerid][DR_SPEED_200] != 0.0) return 1;

            format(text, sizeof text,  ""SC" Dragy: Вы достигли 200 км/ч за %s секунды", speed);
            SendClientMessage(playerid, -1, text);

            player_info_dragy[playerid][DR_SPEED_100_200] = sec - player_info_dragy[playerid][DR_SPEED_100_200];
            player_info_dragy[playerid][DR_SPEED_200] = second;

            if(type == 2) return CreateDragyStatic(playerid);

            player_info_dragy[playerid][DR_SPEED_200_300] = sec;
        }
        else if(speed_old < SPEED_VEHICLE_300 && speed_new >= SPEED_VEHICLE_300)
        {
            if(player_info_dragy[playerid][DR_SPEED_300] != 0.0) return 1;

            format(text, sizeof text,  ""SC" Dragy: Вы достигли 300 км/ч за %s секунды", speed);
            SendClientMessage(playerid, -1, text);

            player_info_dragy[playerid][DR_SPEED_200_300] = sec - player_info_dragy[playerid][DR_SPEED_200_300];
            player_info_dragy[playerid][DR_SPEED_300] = second;

            if(type == 3) return CreateDragyStatic(playerid);

            player_info_dragy[playerid][DR_SPEED_300_400] = sec;
        }
        else if(speed_old < SPEED_VEHICLE_400 && speed_new >= SPEED_VEHICLE_400)
        {
            if(player_info_dragy[playerid][DR_SPEED_400] != 0.0) return 1;

            format(text, sizeof text,  ""SC" Dragy: Вы достигли 400 км/ч за %s секунды", speed);
            SendClientMessage(playerid, -1, text);
            player_info_dragy[playerid][DR_SPEED_400] = second;

            player_info_dragy[playerid][DR_SPEED_300_400] = sec - player_info_dragy[playerid][DR_SPEED_300_400];

            if(type == 4) return CreateDragyStatic(playerid);
        }
    }
    return 1;
}

stock StockDragy(playerid)
{
    player_info_dragy[playerid][DR_ACTIVE] = true;
    player_info_dragy[playerid][DR_ID] = -1;
    player_info_dragy[playerid][DR_VEHICLE] = -1;
    player_info_dragy[playerid][DR_VEHICLE_ID] = -1;
    player_info_dragy[playerid][DR_DATE] = 0;
    player_info_dragy[playerid][DR_SECOND] = 0;  
    player_info_dragy[playerid][DR_SPEED_100] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_200] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_300] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_400] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_100_200] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_200_300] = 0.0;  
    player_info_dragy[playerid][DR_SPEED_300_400] = 0.0;    

    return 1;  
}

stock CreateDragyStatic(playerid)
{
    KillTimer(player_timer_dragy[playerid]);
    player_timer_dragy[playerid] = 0;

    if(GetPlayerVehicleID(playerid) != player_info_dragy[playerid][DR_VEHICLE_ID])
    {
        player_info_dragy[playerid][DR_ACTIVE] = false;

        SendClientMessage(playerid, -1, ""USC" Вы пересели в другой автомобиль");
        return 1;
    }

    new date_dragy = gettime();

    player_info_dragy[playerid][DR_ACTIVE] = false;

    new text[194], vehicle, Float:speed_100, Float:speed_200, Float:speed_300, Float:speed_400,
    Float:speed_100_200, Float:speed_200_300, Float:speed_300_400;

    vehicle = GetPlayerVehicleID(playerid);

    new model = GetVehicleModel(vehicle);

    speed_100 = player_info_dragy[playerid][DR_SPEED_100];
    speed_200 = player_info_dragy[playerid][DR_SPEED_200];
    speed_300 = player_info_dragy[playerid][DR_SPEED_300];
    speed_400 = player_info_dragy[playerid][DR_SPEED_400];

    new speed_float_100 = floatround(player_info_dragy[playerid][DR_SPEED_100_200]);
    new speed_float_200 = floatround(player_info_dragy[playerid][DR_SPEED_200_300]);
    new speed_float_300 = floatround(player_info_dragy[playerid][DR_SPEED_300_400]);

    for(new i, sec, Float:second, speed[6];i<3;i++)
    {
        switch(i)
        {
            case 0:{
                valstr(speed, speed_float_100);
                sec = speed_float_100;
            }
            case 1:{
                valstr(speed, speed_float_200);
                sec = speed_float_200;
            }
            case 2:{
                valstr(speed, speed_float_300);
                sec = speed_float_300;
            }
        }

        if(0 <= sec <= 999) strins(speed, ".", 1);
        else if(1000 <= sec <= 9999) strins(speed, ".", 2);
        else if(10000 <= sec <= 99999) strins(speed, ".", 3);
        second = floatstr(speed);

        switch(i)
        {
            case 0:speed_100_200 = second;
            case 1:speed_200_300 = second;
            case 2:speed_300_400 = second;
        }
    }

    player_info_dragy[playerid][DR_SPEED_100_200] = speed_100_200;
    player_info_dragy[playerid][DR_SPEED_200_300] = speed_200_300;
    player_info_dragy[playerid][DR_SPEED_300_400] = speed_300_400;

    new Cache:result;

    mysql_format(mysql, text, sizeof text,
    "INSERT INTO dragy \
    (owner, veh_id, s100, s200, s300, s400, s100_200, s200_300, s300_400, date) \
    VALUES \
    (%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d)",
    GetPlayerAccountID(playerid), model,
    speed_100, speed_200, speed_300, speed_400,
    speed_100_200, speed_200_300, speed_300_400, date_dragy
    );
    result = mysql_query(mysql, text);
    player_info_dragy[playerid][DR_DATE] = date_dragy;
    player_info_dragy[playerid][DR_ID] = cache_insert_id();

    cache_delete(result);

    if(mysql_errno()) return printf("[LAIRD_SYSTEM] SYSTEM_DRAGY: Error for mysql query");
    return 1;
}

stock SendErrorSqlDragy(playerid)
{
    new text[142] = "Ошибка! В базу данных не загружена таблица с статистикой Dragy (telegram: @welsistudio)";

    if(strcmp(text, error_dragy, false)) SendClientMessage(playerid, -1, error_dragy);
    else SendClientMessage(playerid, -1, text);

    return 1;
}

stock ShowDialogStaticDragy(playerid, type, bool:top = false, id = -1, show_pass_vehicle[99]= "None", vehicle = -1, bool:player = false)
{
    new rows, text[184], Cache:result;

    if(top)
    {  
        if(!player)
        {
            switch(type)
            {
                case 1:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE s100 > 0.0 ORDER BY s100 ASC LIMIT 10");
                case 2:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE s200 > 0.0 ORDER BY s200 ASC LIMIT 10");
                case 3:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE s300 > 0.0 ORDER BY s300 ASC LIMIT 10");
                case 4:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE s400 > 0.0 ORDER BY s400 ASC LIMIT 10");
            }
        }
        else
        {
            switch(type)
            {
                case 1:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d AND s100 > 0.0 ORDER BY s100 ASC LIMIT 10", GetPlayerAccountID(playerid));
                case 2:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d AND s200 > 0.0 ORDER BY s200 ASC LIMIT 10", GetPlayerAccountID(playerid));
                case 3:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d AND s300 > 0.0 ORDER BY s300 ASC LIMIT 10", GetPlayerAccountID(playerid));
                case 4:mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d AND s400 > 0.0 ORDER BY s400 ASC LIMIT 10", GetPlayerAccountID(playerid));
            }            
        }
    }
    else if(id != -1) mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE id = '%d'", id);
    else if(strfind(show_pass_vehicle, "None", true) == -1)
    {
        printf("%s", show_pass_vehicle);
        printf("%s", show_pass_vehicle);
        printf("%s", show_pass_vehicle);
        printf("%s", show_pass_vehicle);
        new model_id;

        for(new v;v < sizeof g_vehicle_info;v++)
        {
            if(strfind(show_pass_vehicle, g_vehicle_info[v][VI_NAME], true) == -1) continue;

            model_id = v+400;

            printf("%s | %d", show_pass_vehicle, model_id);
            printf("%s | %d", show_pass_vehicle, model_id);
            printf("%s | %d", show_pass_vehicle, model_id);
            printf("%s | %d", show_pass_vehicle, model_id);
        }

        if(!model_id) return SendClientMessage(playerid, -1, ""USC"Вы не правильно ввели название транспорта.");

        mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE veh_id = '%d'", model_id);
    } 
    else if(player)
    {
        if(vehicle != -1) mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d AND veh_id = %d LIMIT 10", GetPlayerAccountID(playerid), vehicle);
        else mysql_format(mysql, text, sizeof text, "SELECT * FROM dragy WHERE owner = %d LIMIT 10", GetPlayerAccountID(playerid));
    }
    result = mysql_query(mysql, text, true);
    if(mysql_errno()) return SendErrorSqlDragy(playerid);

    rows = cache_num_rows();

    if(!rows) return SendClientMessage(playerid, -1, ""USC"По Вашему запросу ничего не найдено");

    new list[112], dialog[624] = "{FFFFFF}Заезд\t{FFFFFF}Авто\t{FFFFFF}Дата\t{FFFFFF}Время\n";

    new Float:second, model, id_dragy, dragy_date, bool:dialog_1;



    for(new i;i < rows;i++)
    {
        id_dragy = cache_get_field_content_int(i, "id");
        model = cache_get_field_content_int(i, "veh_id");
        dragy_date = cache_get_field_content_int(i, "date");

        switch(type)
        {
            case 1:second = cache_get_field_content_float(i, "s100");
            case 2:second = cache_get_field_content_float(i, "s200");
            case 3:second = cache_get_field_content_float(i, "s300");
            case 4:second = cache_get_field_content_float(i, "s400");
            default:second = cache_get_field_content_float(i, "s100");
        }

        format(list, sizeof list, "{FFFFFF}№ %d\t{FFFFFF}%s\t{FFFFFF}%d-%02d-%02d %02d:%02d:%02d\t{F7F7F7}%.2f \n", id_dragy, GetVehicleInfo(model-400, VI_NAME), ConvertUnixTime(dragy_date, CONVERT_TIME_TO_YEARS), ConvertUnixTime(dragy_date, CONVERT_TIME_TO_MONTHS),\
        ConvertUnixTime(dragy_date, CONVERT_TIME_TO_DAYS), ConvertUnixTime(dragy_date, CONVERT_TIME_TO_HOURS), ConvertUnixTime(dragy_date, CONVERT_TIME_TO_MINUTES), \
        ConvertUnixTime(dragy_date, CONVERT_TIME_TO_SECONDS), second);

        strcat(dialog, list);
        SetPlayerListitemValue(playerid, i, id_dragy);
    }
    DialogDragy(playerid, 4525, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}Результат", dialog, "Далее", "Назад");

    return 1;
}

stock DialogDragy(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}