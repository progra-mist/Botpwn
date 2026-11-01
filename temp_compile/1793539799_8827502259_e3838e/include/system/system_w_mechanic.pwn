
#include <a_samp>
#include "../include/streamer.inc"
#include <brnotification>
//ДАННАЯ СИСТЕМА РАБОТАЕТ ИСКЛЮЧИТЕЛЬНО НА МОДАХ БЛЕК РАШИ 

#define SCM 											SendClientMessage
#define SC              "{ffff00}| {ffffff}"
#define USC             "{ff2400}| {ffffff}"
#define 	DSM		DIALOG_STYLE_MSGBOX
#define 	DSL		DIALOG_STYLE_LIST


new vihod_mex, vhod_mex, mex_sphere, sphere_item_mex;
new bool:player_job_active[MAX_PLAYERS char];
new bool:p_load_active[MAX_PLAYERS char];
new item_auto[MAX_PLAYERS char];
new player_veh_id[MAX_PLAYERS char];
new actor_player[MAX_PLAYERS char];
#define MAX_MEX_VEH 200

enum STRUCT_MEX_VEH
{
    ST_PLAYER, //игро 
    ST_ID_SRV, //серверный idк
    ST_ID_VEH, //айди машины
    bool:ST_OIL,
    bool:ST_SP,
    bool:ST_BP,
    bool:ST_SS,
    bool:ST_BAT
};


new model_veh_mex[5] = {412, 492, 500, 503, 516};
new name_item_auto[5][23] = {"Машинное масло", "Свеча зажигания", "Тормозная колодка", "Ремень безопасности", "Аккумулятор"};
new vehicle_mex[MAX_MEX_VEH][STRUCT_MEX_VEH];

stock GetMexAuto(veh_id)
{
    new like = 0;

    if(!vehicle_mex[veh_id][ST_OIL]) like++;
    if(!vehicle_mex[veh_id][ST_SS]) like++;
    if(!vehicle_mex[veh_id][ST_SP]) like++;
    if(!vehicle_mex[veh_id][ST_BP]) like++;
    if(!vehicle_mex[veh_id][ST_BAT]) like++;

    return like;
}

stock DeleteVehicleMex(playerid, actor = 0)
{
    new id_veh = player_veh_id{playerid};

    DestroyVehicle(vehicle_mex[id_veh][ST_ID_SRV]);

    if(actor) DestroyActor(actor_player{playerid});

    vehicle_mex[id_veh][ST_PLAYER] = -1;
    vehicle_mex[id_veh][ST_ID_VEH] = 0;
    vehicle_mex[id_veh][ST_ID_SRV] = -1;
    vehicle_mex[id_veh][ST_OIL] = false;
    vehicle_mex[id_veh][ST_SS]  = false;
    vehicle_mex[id_veh][ST_SP]  = false;
    vehicle_mex[id_veh][ST_BP]  = false;
    vehicle_mex[id_veh][ST_BAT] = false;
    player_veh_id{playerid} = -1;

    return 1;

}

stock NewIdVehMex()
{
    new car;
    for(new i; i < sizeof vehicle_mex; i++)
    {
        if(vehicle_mex[i][ST_PLAYER] != -1) continue;
        car = i;
    }
    return car;
}


public OnGameModeInit()
{
    print("[LAIRD_SYSTEM] Работа автомеханика загружена\nАвтор: Welsi Studio");
    vihod_mex = CreateDynamicSphere(993.221069, 1000.334350, 1501.000000, 0.5);
    vhod_mex = CreateDynamicSphere(1873.612792, -127.811904, 15.695312, 1.0);

    CreateActorEx("Мехалыч", "Подойдите для взаимодействия", 206, 994.231079,1004.094543,1501.000000,222.366333, 1, 1);
    mex_sphere = CreateDynamicSphere(994.231079,1004.094543,1501.000000, 2.5);

    sphere_item_mex = CreateDynamicSphere(1004.897766,1000.668457,1501.0, 2.7);
    CreateDynamic3DTextLabel("Подойдите чтобы взять предмет", 0xFFEE00FF3, 1004.897766,1000.668457,1501.0, 5.0);
    CreateDynamic3DTextLabel("Вход в автосервис\n[Работа автомеханика]", 0xFFBB00FF3, 1873.612792, -127.811904, 15.695312, 5.0);
    CreateDynamic3DTextLabel("Выход из автосервиса\n[Работа автомеханика]", 0xFFBB00FF3, 993.221069, 1000.334350, 1501.000000, 5.0);
    #if defined m_OnGameModeInit
        return m_OnGameModeInit();
    #else
        return 0;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit m_OnGameModeInit
#if defined m_OnGameModeInit
    forward m_OnGameModeInit();
#endif


public OnPlayerDisconnect(playerid, reason)
{
    if(p_load_active{playerid}) DeleteVehicleMex(playerid, 1);
	player_job_active{playerid} = false;
    p_load_active{playerid} = false;
    #if defined m_OnPlayerDisconnect
        return m_OnPlayerDisconnect(playerid, reason);
    #else
        return 0;
    #endif
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect m_OnPlayerDisconnect
#if defined m_OnPlayerDisconnect
    forward m_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == vhod_mex)
    {
        SetPlayerPosEx(playerid, 994.787597,1000.367431,1501.000000,270.871093, 1, 1);
        SCM(playerid, -1, ""SC" Вы зашли в автосервис");
    }
    if(areaid == vihod_mex)
    {
        SetPlayerPosEx(playerid, 1872.091186,-128.175704,15.695312,116.325195, 0, 0);

        if(player_job_active{playerid})
        {
            player_job_active{playerid} = false;
            p_load_active{playerid} = false;
            if(item_auto{playerid}) DeleteVehicleMex(playerid, 1);
            item_auto{playerid} = -1;
            SetPlayerSkinInit(playerid);
            SCM(playerid, -1,""USC" Вы закончили смену");
        }
    }
    if(areaid == mex_sphere)
    {
        ShowNotification(playerid, 4, "Взаимодействие", 7, "/yes_mex", ">>");
    }
    if(areaid == sphere_item_mex)
    {
        //Автор: Welsi Тг канал:t.me/welsistudio
        if(item_auto{playerid}) return SCM(playerid, -1, ""USC" У вас уже есть предмет");
        
        ShowNotification(playerid, 4, "Взаимодействие", 7, "/menu_mex", ">>");
    }
    #if defined m_OnPlayerEnterDynamicArea
        return m_OnPlayerEnterDynamicArea(playerid, areaid);
    #else
        return 0;
    #endif
}

#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea m_OnPlayerEnterDynamicArea
#if defined m_OnPlayerEnterDynamicArea
    forward m_OnPlayerEnterDynamicArea(playerid, areaid);
#endif
//Автор: Welsi Тг канал:t.me/welsistudio

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 1299)
    {
        if(response)
        {
            new text[286];

            switch(listitem)
            {
                case 0:
                {
                    if(p_load_active{playerid}) return SCM(playerid, -1, ""USC" Сначала закончите обслуживать транспорт");

					if(player_job_active{playerid})
					{
						SCM(playerid, -1, ""SC" Вы закончили смену");
						player_job_active{playerid} = false;
                        SetPlayerSkinInit(playerid);
						SetPlayerVirtualWorld(playerid, 1);
						if(actor_player{playerid} || player_veh_id{playerid}) DeleteVehicleMex(playerid, 1);
					}
                    else
                    {
                        player_job_active{playerid} = true;
                        SCM(playerid, -1, ""SC" Вы начали смену в автосервисе");
                        SCM(playerid, -1, ""SC" Подсказка: Теперь выберите \"Принять транспорт\"");
                        SetPlayerSkin(playerid, 206);
                        
                        SetPlayerVirtualWorld(playerid, playerid+2);
                        actor_player{playerid} = CreateActorEx("Мехалыч", "Подойдите для взаимодействия", 206, 994.231079,1004.094543,1501.000000,222.366333, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
                    }

                    callcmd::yes_mex(playerid);
                }
                case 1:
                {
		    	   if(!player_job_active{playerid}) return SCM(playerid, -1, ""USC" Сначала начните смену!");
                   else if(p_load_active{playerid}) return SCM(playerid, -1, ""USC" Сначала закончите обслуживать транспорт");

                   new id = NewIdVehMex(), veh_id = model_veh_mex[random(5)], R = random(3) + 1, RR = random(5);
                   if(id >= MAX_MEX_VEH) return SCM(playerid, -1, ""USC" Максимальное количество авто в автосервесе");

                   new veh = CreateVehicle(veh_id, 996.179199,1000.484130,1501.000000,270.0, random(250), random(250), -1);

    
                    Welsi(playerid, id, veh, veh_id);

		    	    printf("IDm = %d | IDp:%d | Vm:%d | Vs:%d | sO:%d | sSP:%d | sBP:%d | sSS:%d | sBA:%d",\
                    id,
		    	    vehicle_mex[id][ST_PLAYER],
		    	    vehicle_mex[id][ST_ID_VEH],
		    	    vehicle_mex[id][ST_ID_SRV],
		    	    vehicle_mex[id][ST_OIL],
		    	    vehicle_mex[id][ST_SP],
		    	    vehicle_mex[id][ST_BP],
		    	    vehicle_mex[id][ST_SS],
		    	    vehicle_mex[id][ST_BAT]
		    	    ); //Автор: Welsi Тг канал:t.me/welsistudio

                    format(text, sizeof (text), "Транспорт:{FFFB00}\"%s\" {FFFFFF}ожидает технического обслуживания", g_vehicle_info[veh_id - 400][VI_NAME]);
                    SCM(playerid, -1, text);

                    player_veh_id{playerid} = id;
		    	    p_load_active{playerid} = true;
		    	    SetVehicleVirtualWorld(vehicle_mex[id][ST_ID_SRV], GetPlayerVirtualWorld(playerid));
		    	    LinkVehicleToInterior(vehicle_mex[id][ST_ID_SRV], 1);

                    callcmd::yes_mex(playerid);
                }
                case 2:
                {
                    if(!p_load_active{playerid}) return SCM(playerid, -1, ""USC" Сначала начните обслуживать транспорт!");

                    new id_veh = player_veh_id{playerid};

                    format
                    (
                        text, sizeof text, 
                        "Информация о транспорте\n\
                        {FFFFFF}Замена масло: %s\n\
                        {FFFFFF}Замена ремней безопастностей: %s\n\
                        {FFFFFF}Замена свечей зажигания: %s\n\
                        {FFFFFF}Замена тормозных колодок: %s\n\
                        {FFFFFF}Замена аккумулятора: %s",
                        vehicle_mex[id_veh][ST_OIL]  ? ("{FF0000}Замена") : ("{00FF15}Не требуется"),
                        vehicle_mex[id_veh][ST_SS]  ? ("{FF0000}Замена") : ("{00FF15}Не требуется"),
                        vehicle_mex[id_veh][ST_SP]  ? ("{FF0000}Замена") : ("{00FF15}Не требуется"),
                        vehicle_mex[id_veh][ST_BP]  ? ("{FF0000}Замена") : ("{00FF15}Не требуется"),
                        vehicle_mex[id_veh][ST_BAT]  ? ("{FF0000}Замена") : ("{00FF15}Не требуется")
                    );

                    Dialog
                    (
                        playerid, -1, DSM,
                        "СТО | Информация о т/с",
                        text, 
                        "Выйти", ""
                    );
                }
                case 3:
                {
                    //Автор: Welsi Тг канал:t.me/welsistudio
                    new id_veh = player_veh_id{playerid}, bool:c_work = false;

					if(GetMexAuto(id_veh) != 5) c_work = true;
					
                    if(c_work)
					{
						SCM(playerid, -1, ""USC" Вы полностью не обслужили авто из-за этого оплата консфиксована");
						DeleteVehicleMex(playerid);	
					}
					else
					{
						new money = (random(5000)*2) + 2500 * GetMexAuto(id_veh);

						GivePlayerMoneyEx(playerid, money);
						SCM(playerid, -1, ""SC" Вы успешно обслужили транспорт. Вы молодец");
						DeleteVehicleMex(playerid);	
					}
                    player_veh_id{playerid} = -1;
                    p_load_active{playerid} = false;

                    callcmd::yes_mex(playerid);
                }

            }
        }
    }
    if(dialogid == 1298)
    {
        if(response)
        {
            //Автор: Welsi Тг канал:t.me/welsistudio
            switch(listitem)
            {
                case 0:MexCheckPoint(playerid, 1);
                case 1:MexCheckPoint(playerid, 2);
                case 2:MexCheckPoint(playerid, 3);
                case 3:MexCheckPoint(playerid, 4);
                case 4:MexCheckPoint(playerid, 5);
            }
        }
    }  
    
#if defined spd_OnDialogResponse
return spd_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse spd_OnDialogResponse
#if defined spd_OnDialogResponse
forward spd_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

stock MexCheckPoint(playerid, item)
{
    new text[45];

    if(item_auto{playerid}) return SCM(playerid, -1, ""USC" У вас уже есть предмет");
        
    item_auto{playerid} = item;
    format(text, sizeof text, "Вы взяли {FFFF00}%s", name_item_auto[item - 1]);
    SCM(playerid, -1, text);
    
    switch(item)
    {
        case 1: SetPlayerCheckpoint(playerid, 999.391723,1000.550903,1501.000000, 1.4);
        case 2: SetPlayerCheckpoint(playerid, 999.391723,1000.550903,1501.000000, 1.4);
        case 3: SetPlayerCheckpoint(playerid, 995.221984,998.613891,1501.000000, 1.0);
        case 4: SetPlayerCheckpoint(playerid, 996.590942,998.667053,1501.000000, 1.4);
        case 5: SetPlayerCheckpoint(playerid, 999.391723,1000.550903,1501.000000, 1.4);
    }
    //Автор: Welsi Тг канал:t.me/welsistudio
    SetPVarInt(playerid, "CheckPMex", 1);

    return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
    if(GetPVarInt(playerid, "CheckPMex"))
    {
        new item = item_auto{playerid}, veh_id = player_veh_id{playerid};

        DisablePlayerCheckpoint(playerid);
        ApplyAnimationEx(playerid, "OTB", "betslp_loop", 4.1, 1, 0, 0, 1, 4_000, 0);
        SetTimerEx("UnfreezePlayer", 4010, false, "i", playerid);

        switch(item)
        {
            case 0: SCM(playerid, -1, ""SC" ERROR");
            case 1:
            {
                if(!vehicle_mex[veh_id][ST_OIL]) 
                {
                    SCM(playerid, -1, ""USC" Замена масла не требуется. Информацию можно найти у \"Михалыча\"");
                    item_auto{playerid} = 0;
                }
                else
                {
                    item_auto{playerid} = 0;
                    SCM(playerid, -1, ""SC" Вы {09FF00}успешно{FFFFFF} залили масло.");
                    vehicle_mex[veh_id][ST_OIL] = false;
                }
            }
            case 2:
            {
                if(!vehicle_mex[veh_id][ST_SP]) 
                {
                    SCM(playerid, -1, ""USC" Свеча зажигания не требуется. Информацию можно найти у \"Михалыча\"");
                    item_auto{playerid} = 0;
                }
                else
                {
                    item_auto{playerid} = 0;
                    SCM(playerid, -1, ""SC" Вы {09FF00}успешно{FFFFFF} вставили свечу зажигания.");
                    vehicle_mex[veh_id][ST_SP] = false;
                }
            }
            case 3:
            {
                if(!vehicle_mex[veh_id][ST_BP]) 
                {
                    SCM(playerid, -1, ""USC" Тормозная колодка не требуется. Информацию можно найти у \"Михалыча\"");
                    item_auto{playerid} = 0;
                }
                else
                {
                    item_auto{playerid} = 0;
                    SCM(playerid, -1, ""SC" Вы {09FF00}успешно{FFFFFF} поменяли тормозную колодку.");
                    vehicle_mex[veh_id][ST_BP] = false;
                }
            }
            case 4:
            {
                if(!vehicle_mex[veh_id][ST_SS]) 
                {
                    SCM(playerid, -1, ""USC" Ремень безопасности не требуется. Информацию можно найти у \"Михалыча\"");
                    item_auto{playerid} = 0;
                }
                else
                {
                    item_auto{playerid} = 0;
                    SCM(playerid, -1, ""SC" Вы {09FF00}успешно{FFFFFF} поменяли ремень безопасности.");
                    vehicle_mex[veh_id][ST_SS] = false;
                }
                //Автор: Welsi Тг канал:t.me/welsistudio
            }
            case 5:
            {
                if(!vehicle_mex[veh_id][ST_BAT]) 
                {
                    SCM(playerid, -1, ""USC" Аккумулятор не требуется. Информацию можно найти у \"Михалыча\"");
                    item_auto{playerid} = 0;
                }
                else
                {
                    item_auto{playerid} = 0;
                    SCM(playerid, -1, ""SC" Вы {09FF00}успешно{FFFFFF} поменяли аккумулятор.");
                    vehicle_mex[veh_id][ST_BAT] = false;
                }
            }
            
        }
    }
    #if defined m_OnPlayerEnterCheckpoint
        return m_OnPlayerEnterCheckpoint(playerid);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnPlayerEnterCheckpoint
    #undef OnPlayerEnterCheckpoint
#else
    #define _ALS_OnPlayerEnterCheckpoint
#endif
#define OnPlayerEnterCheckpoint m_OnPlayerEnterCheckpoint
#if defined m_OnPlayerEnterCheckpoint
    forward m_OnPlayerEnterCheckpoint(playerid);
#endif

CMD:yes_mex(playerid)
{
    if(!IsPlayerInDynamicArea(playerid, mex_sphere)) return SCM(playerid, -1, ""SC" Вы слишком далеко");

    Dialog
    (
        playerid, 1299, DSL, 
        "СТО| Меню автосервиса",
        "1. Начать/закончить смену\n"\
        "2. Начать обслуживание т/с\n"\
        "3. Изучить информацию о т/с\n"\
        "4. Закончить тех. обслуживание",
        "Далее", "Назад"
    );
    return 1;
    //Автор: Welsi Тг канал:t.me/welsistudio
}
CMD:menu_mex(playerid)
{
    if(item_auto{playerid}) return SCM(playerid, -1, ""USC" У вас уже есть предмет");
    else if(!player_job_active{playerid}) return SCM(playerid, -1, ""USC" Начните смену");
    else if(!p_load_active{playerid}) return SCM(playerid, -1, ""USC" Сначало начните обслуживать транспорт!");

    Dialog
    (
        playerid, 1298, DSL,
        "СТО | Вещи для ТО",
        ""SC" Машинное масло\n"\
        ""SC" Свеча зажигания\n"\
        ""SC" Тормозная колодка\n"\
        ""SC" Ремень безопасности\n"\
        ""SC" Аккумулятор",
        "Взять", "Выйти"
    );

    return 1;
}
stock Welsi(playerid, id, srv_id, veh_id)
{
    for(new i = -1; i < random(3); i++)
    {
        switch(random(5))
        {
            case 0:vehicle_mex[id][ST_OIL] = true;
            case 1:vehicle_mex[id][ST_BAT] = true;
            case 2:vehicle_mex[id][ST_SS] = true;
            case 3:vehicle_mex[id][ST_SP] = true;
            case 4:vehicle_mex[id][ST_BP] = true;
        }
    }

    vehicle_mex[id][ST_PLAYER] = playerid;
    vehicle_mex[id][ST_ID_VEH] = veh_id;
    vehicle_mex[id][ST_ID_SRV] = srv_id;

    return 1;
}
//Автор: Welsi Тг канал:t.me/welsistudio