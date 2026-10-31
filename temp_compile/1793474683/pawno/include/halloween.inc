#if defined _HALLOWEEN_INC_
    #endinput
#endif
#define _HALLOWEEN_INC_

#include <a_samp>

// ================== Константы ==================
#define DIALOG_HAL_NPC   3000
#define HAL_TIMER_SPAWN  (60000) // 60 сек
#define HAL_MAX_PUMPKINS (100)

// ================== Переменные ==================
new gHalloweenActor;
new bool:gHalloweenStarted = false;
new gPumpkins[HAL_MAX_PUMPKINS];
new gPumpkinCount;

// ================== Координаты NPC ==================
#define HAL_NPC_X 832.286987
#define HAL_NPC_Y 803.324096
#define HAL_NPC_Z 13.158416
#define HAL_NPC_A 245.110855

// ================== Точки спавна тыкв ==================
new Float:gPumpkinSpawns[][3] =
{
    {840.25, 810.42, 13.15},
    {820.55, 790.31, 13.15},
    {850.12, 800.10, 13.15},
    {810.32, 820.88, 13.15}
};

// ================== Инициализация ==================
forward CreateHalloweenNPC();
public CreateHalloweenNPC()
{
    gHalloweenActor = CreateActor(29, HAL_NPC_X, HAL_NPC_Y, HAL_NPC_Z, HAL_NPC_A);

    Create3DTextLabel("{FF6600}[Halloween NPC]\n{FFFFFF}Подойди ближе", 
        0xFFFFFFFF, HAL_NPC_X, HAL_NPC_Y, HAL_NPC_Z + 1.0, 20.0, 0, 1);

    return 1;
}

// ================== Запуск и стоп ивента ==================
forward StartHalloween();
public StartHalloween()
{
    if(gHalloweenStarted) return 0;
    gHalloweenStarted = true;

    SendClientMessageToAll(-1, "{FF6600}[Halloween]{FFFFFF} Тьма опустилась... Ивент начался!");
    SetTimer("SpawnHalloweenPumpkin", HAL_TIMER_SPAWN, true);
    return 1;
}

forward StopHalloween();
public StopHalloween()
{
    if(!gHalloweenStarted) return 0;
    gHalloweenStarted = false;

    for(new i; i<gPumpkinCount; i++)
    {
        if(IsValidPickup(gPumpkins[i])) DestroyPickup(gPumpkins[i]);
    }
    gPumpkinCount = 0;

    SendClientMessageToAll(-1, "{FF6600}[Halloween]{FFFFFF} Свет развеял тьму. Ивент окончен!");
    return 1;
}

// ================== Спавн тыкв ==================
forward SpawnHalloweenPumpkin();
public SpawnHalloweenPumpkin()
{
    if(!gHalloweenStarted) return 0;
    if(gPumpkinCount >= HAL_MAX_PUMPKINS) return 1;

    new rand = random(sizeof(gPumpkinSpawns));
    gPumpkins[gPumpkinCount] = CreatePickup(19130, 2, gPumpkinSpawns[rand][0], gPumpkinSpawns[rand][1], gPumpkinSpawns[rand][2], -1);
    gPumpkinCount++;

    return 1;
}

// ================== Логика NPC ==================
public OnPlayerUpdate(playerid)
{
    if(!gHalloweenStarted) return 1;

    if(IsPlayerInRangeOfPoint(playerid, 2.5, HAL_NPC_X, HAL_NPC_Y, HAL_NPC_Z))
    {
        ShowPlayerDialog(playerid, DIALOG_HAL_NPC, DIALOG_STYLE_MSGBOX, 
            "Таинственный незнакомец", 
            "Добро пожаловать в ночь ужаса...\n\nСобери для меня хотя бы одну тыкву.\nТогда я дам тебе награду.", 
            "Согласиться", "Отказаться");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_HAL_NPC)
    {
        if(response)
        {
            SendClientMessage(playerid, -1, "{FF6600}[Halloween]{FFFFFF} Ты согласился помочь незнакомцу. Найди тыкву!");
        }
        else
        {
            SendClientMessage(playerid, -1, "{FF6600}[Halloween]{FFFFFF} Ты отказался и ушёл прочь.");
        }
    }
    return 1;
}

// ================== Подбор тыкв ==================
public OnPlayerPickUpPickup(playerid, pickupid)
{
    for(new i; i<gPumpkinCount; i++)
    {
        if(pickupid == gPumpkins[i])
        {
            GivePlayerMoney(playerid, 5000 + random(5000));
            SendClientMessage(playerid, -1, "{FF6600}[Halloween]{FFFFFF} Ты подобрал тыкву и получил награду!");
            DestroyPickup(gPumpkins[i]);
            gPumpkins[i] = INVALID_PICKUP_ID;
            break;
        }
    }
    return 1;
}
