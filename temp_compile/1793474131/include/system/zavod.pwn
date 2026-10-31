// автор слива: @timemorantezz x @def_black
// Инклуд работы завода с исправленными параметрами OnPlayerPickUpPickupEx
#if defined _factory_job_included
    #endinput
#endif
#define _factory_job_included

#include <a_samp>

// --- Настройки ---
#define FACTORY_SKIN 8
#define FACTORY_INT 1
#define MAX_MACHINE_POINTS 4
#define FACTORY_ATTACH_SLOT 1 

static f_enter_pickup, f_exit_pickup, f_job_pickup;
static bool:F_IsWorking[MAX_PLAYERS], bool:F_HasMaterial[MAX_PLAYERS], bool:F_HasProduct[MAX_PLAYERS];
static bool:F_IsProcessing[MAX_PLAYERS], F_TargetMachine[MAX_PLAYERS] = { -1, ... };
static Float:F_Salary[MAX_PLAYERS];

static Float:F_MachinePos[MAX_MACHINE_POINTS][3] = {
    {-5.9090, -6.0739, 1381.0601},
    {-5.9169, -0.8683, 1381.0601},
    {-5.9155, 4.3760, 1381.0601},
    {-5.9155, 9.7351, 1381.0601}
};

// --- Логика ---

forward OnF_CraftingFinished(playerid);
public OnF_CraftingFinished(playerid) {
    if(!F_IsWorking[playerid]) return 0;
    F_IsProcessing[playerid] = false;
    F_HasMaterial[playerid] = false;
    TogglePlayerControllable(playerid, 1);
    ClearAnimations(playerid);

    if(random(100) < 10) {
        SendClientMessage(playerid, 0xFF0000FF, "Ошибка! Деталь оказалась бракованной. Начните заново.");
        SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0); 
        return 1;
    }

    F_HasProduct[playerid] = true;
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    
    /* 
       НАСТРОЙКИ ОБЪЕКТА:
       6 - правая рука (кость)
       fX: 0.15 (чуть вперед от руки)
       fY: 0.11 (корректировка центра)
       fZ: 0.0
       fRotX: 0.0, fRotY: 90.0, fRotZ: 0.0 (поворот, чтобы коробка стояла ровно)
       fScale: 0.6, 0.6, 0.6 (размер уменьшен до 60% от оригинала)
    */
    SetPlayerAttachedObject(playerid, FACTORY_ATTACH_SLOT, 1221, 6, 0.15, 0.11, 0.0, 0.0, 90.0, 0.0, 0.6, 0.6, 0.6); 

    SetPlayerCheckpoint(playerid, -10.9001, 22.8166, 1381.0601, 2.0);
    SendClientMessage(playerid, -1, "{00FF00}Готово! {FFFFFF}Отнесите деталь на конвеер завода.");
    return 1;
}


stock F_TakeMaterial(playerid) {
    F_HasMaterial[playerid] = true;
    F_TargetMachine[playerid] = random(MAX_MACHINE_POINTS);
    new m = F_TargetMachine[playerid];
    SetPlayerCheckpoint(playerid, F_MachinePos[m][0], F_MachinePos[m][1], F_MachinePos[m][2], 2.0);
    
    new str[128];
    format(str, sizeof(str), "{FFFF00}Вы взяли материалы. {FFFFFF}Идите к станку №%d.", m + 1);
    SendClientMessage(playerid, -1, str);
}

stock F_StartCrafting(playerid) {
    F_IsProcessing[playerid] = true;
    DisablePlayerCheckpoint(playerid);
    TogglePlayerControllable(playerid, 0);
    ApplyAnimation(playerid, "CAR", "Fixn_Car_Loop", 4.1, 1, 1, 1, 1, 1, 1);
    SendClientMessage(playerid, -1, "{FFFF00}Сборка детали... {FFFFFF}Подождите 8 секунд.");
    SetTimerEx("OnF_CraftingFinished", 8000, false, "i", playerid);
}

stock F_FinishProduct(playerid) {
    F_HasProduct[playerid] = false;
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    if(IsPlayerAttachedObjectSlotUsed(playerid, FACTORY_ATTACH_SLOT)) RemovePlayerAttachedObject(playerid, FACTORY_ATTACH_SLOT);
    
    new money = 500000 + random(100000);
    F_Salary[playerid] += float(money);
    
    SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0);
    ApplyAnimation(playerid, "CARRY", "putdwn", 4.0, 0, 0, 0, 0, 0, 1);
    
    new str[128];
    format(str, sizeof(str), "{00FF00}Изделие сдано! {FFFFFF}+%d руб. (Всего: %d руб.). Отправляйтесь на склад за новым материалом!", money, floatround(F_Salary[playerid]));
    SendClientMessage(playerid, -1, str);
}

// --- Перехваты (Hooks) ---

public OnGameModeInit() {
    f_enter_pickup = CreatePickup(19130, 23, -978.7820, 2070.2219, 45.3795, -1);
    f_exit_pickup = CreatePickup(19130, 23, -31.8808, -3.9729, 1381.0601, -1);
    Create3DTextLabel("{FFFFFF}Вход на Завод", -1, -978.7820, 2070.2219, 45.3795 + 0.5, 15.0, 0);
    Create3DTextLabel("{FFFFFF}Выход на улицу", -1, -31.8808, -3.9729, 1381.0601 + 0.5, 10.0, 0);
    
    CreateActor(FACTORY_SKIN, -25.2997, -10.0753, 1381.0596, 182.0);
    f_job_pickup = CreatePickup(1275, 23, -25.1597, -10.9273, 1381.0596, -1);
    Create3DTextLabel("{FFFFFF}РАЗДЕВАЛКА ЗАВОДА\n{FFFF00}Наступите для начала работы", -1, -25.1597, -10.9273, 1381.0596 + 0.5, 10.0, 0);
    
    Create3DTextLabel("{00FFFF}СКЛАД МАТЕРИАЛОВ\n{FFFFFF}Взять заготовку", -1, -2.1210, -14.0634, 1381.0601 + 0.5, 10.0, 0);
    Create3DTextLabel("{00FF00}СКЛАД ПРОДУКЦИИ\n{FFFFFF}Сдать изделие", -1, -10.9001, 22.8166, 1381.0601 + 0.5, 10.0, 0);

    for(new i = 0; i < MAX_MACHINE_POINTS; i++) {
        new str[32];
        format(str, sizeof(str), "{FFFF00}Станок №%d", i + 1);
        Create3DTextLabel(str, -1, F_MachinePos[i][0], F_MachinePos[i][1], F_MachinePos[i][2] + 0.5, 10.0, 0);
    }

    #if defined F_OnGameModeInit
        return F_OnGameModeInit();
    #else
        return 1;
    #endif
}

// ИСПРАВЛЕНО: Добавлены action_type и action_id (4 параметра)
public OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id) {
    if(pickupid == f_enter_pickup) {
        SetPlayerPos(playerid, -29.9151, -5.4584, 1381.0601);
        SetPlayerInterior(playerid, FACTORY_INT);
        return 1;
    }
    if(pickupid == f_exit_pickup) {
        SetPlayerPos(playerid, -973.2694, 2070.3044, 44.5868);
        SetPlayerInterior(playerid, 0);
        return 1;
    }
    if(pickupid == f_job_pickup) {
        if(F_IsWorking[playerid]) {
            // --- ЗАВЕРШЕНИЕ РАБОТЫ ---
            if(F_Salary[playerid] > 0.0) {
                new total_money = floatround(F_Salary[playerid]);
                GivePlayerMoneyEx(playerid, total_money, "Зарплата на заводе", true, true);

                new str[128];
                format(str, sizeof(str), "{00FF00}Вы закончили смену. {FFFFFF}Заработано: %d руб. Деньги выданы на руки.", total_money);
                SendClientMessage(playerid, -1, str);
            } else {
                SendClientMessage(playerid, -1, "Вы закончили работу, но ничего не заработали.");
            }

            // Возвращаем скин из вашей системы данных
            SetPlayerSkin(playerid, GetPlayerData(playerid, P_SKIN));
            
            // Сброс всех переменных
            F_IsWorking[playerid] = false;
            F_HasMaterial[playerid] = false;
            F_HasProduct[playerid] = false;
            F_IsProcessing[playerid] = false;
            F_Salary[playerid] = 0.0;
            
            DisablePlayerCheckpoint(playerid);
            if(IsPlayerAttachedObjectSlotUsed(playerid, FACTORY_ATTACH_SLOT)) RemovePlayerAttachedObject(playerid, FACTORY_ATTACH_SLOT);
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        } else {
            // --- НАЧАЛО РАБОТЫ ---
            F_IsWorking[playerid] = true;
            F_Salary[playerid] = 0.0;
            SetPlayerSkin(playerid, 188); // Рабочая форма
            SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0);
            SendClientMessage(playerid, -1, "Вы начали работу, отправляйтесь за материалами на склад!");
        }
        return 1;
    }

    #if defined F_OnPlayerPickUpPickupEx
        return F_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id);
    #else
        return 1;
    #endif
}


public OnPlayerUpdate(playerid) {
    if(F_IsWorking[playerid] && !F_IsProcessing[playerid]) {
        if(!F_HasMaterial[playerid] && !F_HasProduct[playerid]) {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, -2.1210, -14.0634, 1381.0601)) F_TakeMaterial(playerid);
        }
        else if(F_HasMaterial[playerid]) {
            new m = F_TargetMachine[playerid];
            if(IsPlayerInRangeOfPoint(playerid, 1.5, F_MachinePos[m][0], F_MachinePos[m][1], F_MachinePos[m][2])) F_StartCrafting(playerid);
        }
        else if(F_HasProduct[playerid]) {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, -10.9001, 22.8166, 1381.0601)) F_FinishProduct(playerid);
        }
    }
    #if defined F_OnPlayerUpdate
        return F_OnPlayerUpdate(playerid);
    #else
        return 1;
    #endif
}

// --- ALS Системные макросы ---

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit F_OnGameModeInit
#if defined F_OnGameModeInit
    forward F_OnGameModeInit();
#endif

#if defined _ALS_OnPlayerPickUpPickupEx
    #undef OnPlayerPickUpPickupEx
#else
    #define _ALS_OnPlayerPickUpPickupEx
#endif
#define OnPlayerPickUpPickupEx F_OnPlayerPickUpPickupEx
#if defined F_OnPlayerPickUpPickupEx

    forward F_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id);
#endif

#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate F_OnPlayerUpdate
#if defined F_OnPlayerUpdate
    forward F_OnPlayerUpdate(playerid);
#endif
