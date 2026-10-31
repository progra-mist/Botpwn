// АВТОР СИСТЕМЫ BY JESUS 
// ЕДИНСТВЕННЫЙ МОЙ ТГК @JESUSCRMP
// КТО СИСТЕМУ СПИЗДИТ - ХУЕСОС МАТЬ ЕБАЛ


#if defined _garbage_job_included
    #endinput
#endif
#define _garbage_job_included

#include <a_samp>
#include "../include/streamer"
#include "../include/a_mysql"
#include "../include/sscanf2"


#define garbage_db_handle mysql

#if !defined garbage_db_handle
    new MySQL:garbage_db_handle;
#endif

const MAX_TRASH_CAPACITY = 20;
const EXP_PER_BAG        = 10;
const EXP_FOR_RANK_2     = 4000;
const EXP_FOR_RANK_3     = 10000;
const TRASH_BAG_MODEL    = 1264;
const TRUCK_MODEL_ID     = 408;
const WORK_SKIN_ID       = 228;
const CONTAINER_AREA_OFFSET = 20000;

enum {
    DIALOG_MIKHALYCH_MAIN = 19001,
    DIALOG_MIKHALYCH_INFO,
    DIALOG_MIKHALYCH_STATS,
    DIALOG_MIKHALYCH_REQ
}

enum {
    AREA_SIGN_MIKHALYCH = -1,
    AREA_DUMP_POINT = -2
}

static Float:MikhalychPos[4]  = {-1676.8697,-2137.6855,28.1793,205.0};
static Float:TruckSpawnPos[4] = {-1659.2662,-2161.3449,28.2221,335.5463};
static Float:DumpPos[3]       = {-1545.220092,-2168.071289,29.232570};

static Float:TrashContainers[87][3] = {
    {-1047.510009, -1684.058471, 41.016563}, {-957.518737, -1962.109863, 39.382808}, {-888.403259, -2210.199951, 40.823966}, {-731.111694, -1665.281860, 41.246772}, {-2667.590820, -244.614395, 27.552989},
    {-2668.330078, -238.516937, 27.549678}, {-2287.969726, 135.105316, 26.578014}, {-2429.678222, -27.073413, 26.530803}, {-2475.691406, -105.204032, 26.565101}, {602.319641, -1344.708374, 40.997024},
    {2804.808837, -2157.594970, 19.004158}, {2649.434082, -2408.456054, 21.995162}, {2531.068115, -2480.400390, 22.003311}, {2525.918457, -2495.533935, 22.006031}, {2421.027832, -2624.680664, 21.829063},
    {2400.393310, -2610.380371, 22.024375}, {1887.527099, -2584.898681, 10.400496}, {1832.096801, -2574.254150, 10.468558}, {1790.801513, -2494.739013, 10.471856}, {1725.495605, -2326.817626, 10.452935},
    {1776.054687, -2369.733642, 10.426809}, {2090.979980, -2349.885742, 21.407646}, {2138.147460, -2329.643310, 21.288011}, {2316.409912, -2277.024414, 21.297828}, {2328.725097, -2231.263427, 21.413496},
    {2424.767089, -2116.245849, 21.483322}, {2414.338623, -2124.834716, 21.323471}, {2334.614257, -2117.941894, 21.473094}, {2349.301757, -1974.785278, 21.353033}, {2436.443115, -1951.592041, 21.503236},
    {2195.428222, -2129.433349, 21.469997}, {2115.618164, -1847.283569, 19.021766}, {2496.707031, -244.756683, 1.305828}, {2180.487548, -218.381393, 2.187503}, {-979.774963, 240.902236, 24.319120},
    {-1415.501708, 523.475646, 30.354272}, {-2000.002807, 486.784973, 29.017967}, {-1849.924560, 360.044006, 27.791521}, {-2704.916503, 865.521972, 9.288830}, {-2640.208740, 1327.114379, 9.336064},
    {-2558.515869, 1154.126098, 9.358488}, {-2589.915771, 1121.280761, 9.354680}, {-2484.956054, 1168.686645, 9.345590}, {-2448.249267, 1341.406738, 9.348689}, {-2423.524414, 1377.633911, 9.360222},
    {-2504.231689, 1400.552734, 9.356599}, {-2540.861816, 1454.122680, 9.342287}, {-2423.920654, 1378.091308, 9.310263}, {-2381.879638, 1571.517211, 9.296039}, {-1962.853881, 2241.723632, 57.540863},
    {-2247.923095, 2544.358886, 57.351753}, {-2085.238281, 2718.087402, 57.262496}, {-1919.098754, 2674.408691, 57.357086}, {-1567.868774, 2311.744140, 56.437408}, {-1621.540893, 2292.001953, 57.678112},
    {-1764.216918, 2301.688232, 57.684333}, {279.335540, 620.135864, 11.509117}, {227.274246, 616.689331, 11.509187}, {207.097473, 634.394836, 11.509074}, {238.541137, 714.024536, 11.509190},
    {278.617675, 830.431030, 11.507355}, {290.903045, 827.089843, 11.509158}, {99.322296, 900.449829, 11.507783}, {109.968498, 1023.229675, 11.507676}, {175.348937, 1029.758178, 13.220129},
    {140.940597, 1079.665405, 11.508016}, {164.723846, 1110.217163, 11.515599}, {196.916732, 1080.704589, 11.710325}, {-32.994651, 1102.659545, 11.546483}, {-59.670314, 1090.002197, 11.516072},
    {-167.440750, 1172.454467, 11.508836}, {-104.933929, 1230.632812, 11.508949}, {31.681673, 1526.313354, 8.899815}, {12.847908, 1527.433837, 5.329137}, {1732.678588, 2533.907958, 14.661293},
    {1892.028320, 2319.504882, 15.201436}, {1766.675781, 2066.703857, 15.511064}, {1728.264526, 2222.197753, 15.361279}, {1699.395996, 2390.213867, 14.655433}, {1733.467529, 2399.994628, 15.166706},
    {1765.744995, 2407.046875, 14.872958}, {1815.402465, 2324.652099, 14.825111}, {1852.659179, 2195.323242, 15.558606}, {1842.838745, 2171.448730, 15.300410}, {1803.400512, 2190.107910, 15.404153},
    {1819.393310, 2133.784667, 15.332145}, {1937.021362, 2065.335693, 15.188584}
};

static bool:ContainerIsEmpty[87];
static ContainerTimer[87];
static Text3D:ContainerLabel[87] = {Text3D:INVALID_3DTEXT_ID, ...};

enum pInfor {
    pLevel, pJobExp, pJobRank,
    bool:pIsWorking, bool:pHasTrashBag,
    pVehicleID, PlayerText:pFadeTD, pOldSkin
}
static PlayerInfo[MAX_PLAYERS][pInfor];

static TruckLoad[MAX_VEHICLES];
static Text3D:TruckLabel[MAX_VEHICLES] = {Text3D:INVALID_3DTEXT_ID, ...};
static TruckArea[MAX_VEHICLES] = {INVALID_STREAMER_ID, ...};
static DumpAreaGlobal = INVALID_STREAMER_ID;
static MikhalychActor = -1;

forward OnPlayerFadeComplete(playerid);
forward UpdateTruckLabel(vehid);
forward CheckPlayerRank(playerid);
forward UpdateContainersTimer();
forward OnPlayerDataLoad(playerid);

stock SavePlayerGarbageData(playerid)
{
    new pName[MAX_PLAYER_NAME], query[170];
    GetPlayerName(playerid, pName, sizeof(pName));
    mysql_format(garbage_db_handle, query, sizeof(query),
        "INSERT INTO `garbage_job` (`name`, `exp`, `rank`) VALUES ('%e', %d, %d) \
         ON DUPLICATE KEY UPDATE `exp` = VALUES(`exp`), `rank` = VALUES(`rank`)",
        pName, PlayerInfo[playerid][pJobExp], PlayerInfo[playerid][pJobRank]);
    mysql_tquery(garbage_db_handle, query);
}

stock ResetPlayerJobData(playerid)
{
    DestroyPlayerTruck(playerid);
    if(PlayerInfo[playerid][pHasTrashBag]) {
        RemovePlayerAttachedObject(playerid, 1);
        ClearAnimations(playerid);
    }
    if(PlayerInfo[playerid][pIsWorking]) {
        SetPlayerSkin(playerid, PlayerInfo[playerid][pOldSkin]);
    }
    PlayerInfo[playerid][pIsWorking] = false;
    PlayerInfo[playerid][pHasTrashBag] = false;
}

stock DestroyPlayerTruck(playerid)
{
    new vehid = PlayerInfo[playerid][pVehicleID];
    if(vehid != 0)
    {
        if(TruckArea[vehid] != INVALID_STREAMER_ID) {
            DestroyDynamicArea(TruckArea[vehid]);
            TruckArea[vehid] = INVALID_STREAMER_ID;
        }
        if(TruckLabel[vehid] != Text3D:INVALID_3DTEXT_ID) {
            Delete3DTextLabel(TruckLabel[vehid]);
            TruckLabel[vehid] = Text3D:INVALID_3DTEXT_ID;
        }
        DestroyVehicle(vehid);
        PlayerInfo[playerid][pVehicleID] = 0;
    }
}

stock SpawnGarbageTruckForPlayer(playerid)
{
    DestroyPlayerTruck(playerid);

    new vehid = CreateVehicle(TRUCK_MODEL_ID, TruckSpawnPos[0], TruckSpawnPos[1], TruckSpawnPos[2], TruckSpawnPos[3], 1, 1, -1);
    PlayerInfo[playerid][pVehicleID] = vehid;
    TruckLoad[vehid] = 0;

    new string[96];
    format(string, sizeof(string), "{FF9900}« МУСОРОВОЗ »\n{FFFFFF}Заполненность: {33AA33}%d{FFFFFF} из {FF9900}%d", TruckLoad[vehid], MAX_TRASH_CAPACITY);

    TruckLabel[vehid] = Create3DTextLabel(string, 0xFFFFFFFF, 0.0, 0.0, 0.0, 30.0, 0, 1);
    Attach3DTextLabelToVehicle(TruckLabel[vehid], vehid, 0.0, 0.0, 1.2);

    TruckArea[vehid] = CreateDynamicSphere(0.0, 0.0, 0.0, 4.5, -1, -1, -1);
    AttachDynamicAreaToVehicle(TruckArea[vehid], vehid);
    Streamer_SetIntData(STREAMER_TYPE_AREA, TruckArea[vehid], E_STREAMER_EXTRA_ID, vehid);

    return vehid;
}

public UpdateContainersTimer()
{
    new lbl_str[128];
    for(new i = 0; i < sizeof(TrashContainers); i++)
    {
        if(ContainerIsEmpty[i])
        {
            ContainerTimer[i]--;
            if(ContainerTimer[i] <= 0)
            {
                ContainerIsEmpty[i] = false;
                ContainerTimer[i] = 0;
                format(lbl_str, sizeof(lbl_str), "{33AA33}Бак №%d\n{FFFFFF}Статус: {33AA33}Есть мусор!", i + 1);
                Update3DTextLabelText(ContainerLabel[i], 0xFFFFFFFF, lbl_str);
            }
            else
            {
                format(lbl_str, sizeof(lbl_str), "{FF4444}Бак №%d\n{FFFFFF}Статус: {FF4444}Пуст\n{FFFFFF}Накопится через: {FFFF00}%02d:%02d", i + 1, ContainerTimer[i] / 60, ContainerTimer[i] % 60);
                Update3DTextLabelText(ContainerLabel[i], 0xFFFFFFFF, lbl_str);
            }
        }
    }
    return 1;
}

public UpdateTruckLabel(vehid)
{
    if(TruckLabel[vehid] != Text3D:INVALID_3DTEXT_ID)
    {
        new string[96];
        format(string, sizeof(string), "{FF9900}« Мусоровоз »\n{FFFFFF}Заполненность: {33AA33}%d{FFFFFF} из {FF9900}%d", TruckLoad[vehid], MAX_TRASH_CAPACITY);
        Update3DTextLabelText(TruckLabel[vehid], 0xFFFFFFFF, string);
    }
}

public CheckPlayerRank(playerid)
{
    new exp = PlayerInfo[playerid][pJobExp];
    if(PlayerInfo[playerid][pJobRank] == 1 && exp >= EXP_FOR_RANK_2)
    {
        PlayerInfo[playerid][pJobRank] = 2;
        SendClientMessage(playerid, 0xFFFF00AA, "[МУСОРОВОЗ] Михалыч повысил тебя на должность Водитель. Бонус к зарплате активен");
    }
    else if(PlayerInfo[playerid][pJobRank] == 2 && exp >= EXP_FOR_RANK_3)
    {
        PlayerInfo[playerid][pJobRank] = 3;
        SendClientMessage(playerid, 0xFFFF00AA, "[МУСОРОВОЗ] Михалыч повысил тебя на должность Старший Водитель. Теперь у тебя максимальный доход");
    }
}

public OnPlayerDataLoad(playerid)
{
    if(cache_num_rows() > 0)
    {
        // Для MySQL R39 и ниже:
        PlayerInfo[playerid][pJobExp] = cache_get_row_int(0, 0);
        PlayerInfo[playerid][pJobRank] = cache_get_row_int(0, 1);

        /* 
        Если используешь MySQL R40+, раскомментируй эти две строки ниже, а верхние две удали:
        cache_get_value_name_int(0, "exp", PlayerInfo[playerid][pJobExp]);
        cache_get_value_name_int(0, "rank", PlayerInfo[playerid][pJobRank]);
        */
        
        // На всякий случай проверяем ранг сразу после загрузки
        CheckPlayerRank(playerid);
    }
    return 1;
}

public OnPlayerFadeComplete(playerid)
{
    if(PlayerInfo[playerid][pFadeTD] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawHide(playerid, PlayerInfo[playerid][pFadeTD]);
        PlayerTextDrawDestroy(playerid, PlayerInfo[playerid][pFadeTD]);
        PlayerInfo[playerid][pFadeTD] = PlayerText:INVALID_TEXT_DRAW;
    }

    if(PlayerInfo[playerid][pIsWorking])
    {
        new veh = SpawnGarbageTruckForPlayer(playerid);
        PutPlayerInVehicle(playerid, veh, 0);
        GameTextForPlayer(playerid, "~y~АВТО ПОЛУЧЕНО", 3000, 3);
        SendClientMessage(playerid, 0x33AA33AA, "[МУСОРОВОЗ] Михалыч дал тебе ключи от Мусоровоза.");
    }
    return 1;
}

public OnGameModeInit()
{
    MikhalychActor = CreateActor(WORK_SKIN_ID, MikhalychPos[0], MikhalychPos[1], MikhalychPos[2], MikhalychPos[3]);
    ApplyActorAnimation(MikhalychActor, "GANGS", "PRTIAL_GNGTLK_A", 4.1, 1, 1, 1, 1, 0);

    new m_area = CreateDynamicSphere(MikhalychPos[0], MikhalychPos[1], MikhalychPos[2], 2.5, -1, -1, -1);
    Streamer_SetIntData(STREAMER_TYPE_AREA, m_area, E_STREAMER_EXTRA_ID, AREA_SIGN_MIKHALYCH);
    Create3DTextLabel("{FF9900}[ МИХАЛЫЧ ]\n{FFFFFF}Подойди ближе для взаимодействия", 0xFFFFFFFF, MikhalychPos[0], MikhalychPos[1], MikhalychPos[2] + 1.0, 10.0, 0, 0);

    DumpAreaGlobal = CreateDynamicSphere(DumpPos[0], DumpPos[1], DumpPos[2], 6.0, -1, -1, -1);
    Streamer_SetIntData(STREAMER_TYPE_AREA, DumpAreaGlobal, E_STREAMER_EXTRA_ID, AREA_DUMP_POINT);

    Create3DTextLabel("{FF0000}[ ГОРОДСКАЯ СВАЛКА ]\n\n{FFFFFF}Загоняй сюда мусоровоз!\n{33AA33}Оплата: 250.000 руб. за 1 мешок\n{FFFFFF}(Можно сдавать от 1 до 20 штук за раз)",
        0xFFFFFFFF, DumpPos[0], DumpPos[1], DumpPos[2] + 1.0, 40.0, 0, 0);

    new lbl_str[64];
    for(new i = 0; i < sizeof(TrashContainers); i++)
    {
        ContainerIsEmpty[i] = false;
        ContainerTimer[i] = 0;

        new c_area = CreateDynamicSphere(TrashContainers[i][0], TrashContainers[i][1], TrashContainers[i][2], 2.0, -1, -1, -1);
        Streamer_SetIntData(STREAMER_TYPE_AREA, c_area, E_STREAMER_EXTRA_ID, CONTAINER_AREA_OFFSET + i);

        format(lbl_str, sizeof(lbl_str), "{33AA33}Мусорный бак №%d\n{FFFFFF}Статус: {33AA33}Полный", i + 1);
        ContainerLabel[i] = Create3DTextLabel(lbl_str, 0xFFFFFFFF, TrashContainers[i][0], TrashContainers[i][1], TrashContainers[i][2] + 1.5, 12.0, 0, 0);
    }

    SetTimer("UpdateContainersTimer", 1000, true);

    #if defined Garbage_OnGameModeInit
        return Garbage_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Garbage_OnGameModeInit
#if defined Garbage_OnGameModeInit
    forward Garbage_OnGameModeInit();
#endif

public OnGameModeExit()
{
    if(MikhalychActor != -1) DestroyActor(MikhalychActor);

    for(new i = 0; i < sizeof(TrashContainers); i++) {
        if(ContainerLabel[i] != Text3D:INVALID_3DTEXT_ID) {
            Delete3DTextLabel(ContainerLabel[i]);
            ContainerLabel[i] = Text3D:INVALID_3DTEXT_ID;
        }
    }

    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            SavePlayerGarbageData(i);
            ResetPlayerJobData(i);
        }
    }

    #if defined Garbage_OnGameModeExit
        return Garbage_OnGameModeExit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeExit
    #undef OnGameModeExit
#else
    #define _ALS_OnGameModeExit
#endif
#define OnGameModeExit Garbage_OnGameModeExit
#if defined Garbage_OnGameModeExit
    forward Garbage_OnGameModeExit();
#endif


public OnPlayerStateChange(playerid, newstate, oldstate)
{
    #if defined Garbage_OnPlayerStateChange
        return Garbage_OnPlayerStateChange(playerid, newstate, oldstate);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerStateChange
    #undef OnPlayerStateChange
#else
    #define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange Garbage_OnPlayerStateChange
#if defined Garbage_OnPlayerStateChange
    forward Garbage_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerConnect(playerid)
{
    PlayerInfo[playerid][pLevel] = 1;
    PlayerInfo[playerid][pJobExp] = 0;
    PlayerInfo[playerid][pJobRank] = 1;
    PlayerInfo[playerid][pIsWorking] = false;
    PlayerInfo[playerid][pHasTrashBag] = false;
    PlayerInfo[playerid][pVehicleID] = 0;
    PlayerInfo[playerid][pOldSkin] = 0;
    PlayerInfo[playerid][pFadeTD] = PlayerText:INVALID_TEXT_DRAW;

    PlayerInfo[playerid][pLevel] = GetPlayerScore(playerid);

    new pName[MAX_PLAYER_NAME], query[110];
    GetPlayerName(playerid, pName, sizeof(pName));
    mysql_format(garbage_db_handle, query, sizeof(query), "SELECT `exp`, `rank` FROM `garbage_job` WHERE `name` = '%e' LIMIT 1", pName);
    mysql_tquery(garbage_db_handle, query, "OnPlayerDataLoad", "i", playerid);

    #if defined Garbage_OnPlayerConnect
        return Garbage_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Garbage_OnPlayerConnect
#if defined Garbage_OnPlayerConnect
    forward Garbage_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerGarbageData(playerid);
    ResetPlayerJobData(playerid);

    #if defined Garbage_OnPlayerDisconnect
        return Garbage_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Garbage_OnPlayerDisconnect
#if defined Garbage_OnPlayerDisconnect
    forward Garbage_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    new extra_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID);

    if(extra_id == AREA_SIGN_MIKHALYCH)
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            PlayerInfo[playerid][pLevel] = GetPlayerScore(playerid);
            new menuStr[128];
            format(menuStr, sizeof(menuStr), "1. О работе\n2. Личная карточка\n3. %s", (PlayerInfo[playerid][pIsWorking]) ? ("{FF4444}Закончить работу{FFFFFF}") : ("{33AA33}Начать работу{FFFFFF}"));
            ShowPlayerDialog(playerid, DIALOG_MIKHALYCH_MAIN, DIALOG_STYLE_LIST, "{FF9900}Михалыч", menuStr, "Выбрать", "Отойти");
        }
    }
    else if(extra_id == AREA_DUMP_POINT)
    {
        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new veh = GetPlayerVehicleID(playerid);
            if(veh == PlayerInfo[playerid][pVehicleID] && PlayerInfo[playerid][pIsWorking])
            {
                new load = TruckLoad[veh];
                if(load > 0)
                {
                    new pricePerBag = 250000;
                    if(PlayerInfo[playerid][pJobRank] == 2) pricePerBag = 300000;
                    if(PlayerInfo[playerid][pJobRank] == 3) pricePerBag = 350000;

                    new salary = load * pricePerBag;
                    TruckLoad[veh] = 0;
                    UpdateTruckLabel(veh);
                    GivePlayerMoney(playerid, salary);

                    new str[144];
                    format(str, sizeof(str), "~g~+%d RUB", salary);
                    GameTextForPlayer(playerid, str, 4000, 1);

                    format(str, sizeof(str), "{33AA33}[СВАЛКА] {FFFFFF}Спасибо! Михалыч принял %d мешков. На карту зачислен платёж в размере {33AA33}%d руб.", load, salary);
                    SendClientMessage(playerid, -1, str);
                }
                else
                {
                    SendClientMessage(playerid, 0xFF4444AA, "[СВАЛКА] Кузов пустой. Отправляйтесь собирать мусор.");
                }
            }
        }
    }
    else if(extra_id >= CONTAINER_AREA_OFFSET && extra_id < CONTAINER_AREA_OFFSET + sizeof(TrashContainers))
    {
        new idx = extra_id - CONTAINER_AREA_OFFSET;
        if(PlayerInfo[playerid][pIsWorking] && !PlayerInfo[playerid][pHasTrashBag] && !IsPlayerInAnyVehicle(playerid))
        {
            if(ContainerIsEmpty[idx])
            {
                SendClientMessage(playerid, 0xFF4444AA, "[МУСОР] Бак пуст. Ожидай восстановления.");
                return 1;
            }

            ContainerIsEmpty[idx] = true;
            ContainerTimer[idx] = 300;

            new lbl_str[96];
            format(lbl_str, sizeof(lbl_str), "{FF4444}Бак №%d\n{FFFFFF}Статус: {FF4444}Пуст\n{FFFFFF}Накопится через: {FFFF00}05:00", idx + 1);
            Update3DTextLabelText(ContainerLabel[idx], 0xFFFFFFFF, lbl_str);

            PlayerInfo[playerid][pHasTrashBag] = true;
            SetPlayerAttachedObject(playerid, 1, TRASH_BAG_MODEL, 6, 0.1, 0.2, 0.0, 0.0, 90.0, 0.0);
            ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.1, 1, 1, 1, 1, 1, 1);

            GameTextForPlayer(playerid, "~y~МЕШОК ВЗЯТ", 2000, 3);
            SendClientMessage(playerid, 0xFFFF00AA, "[МУСОР] Ты достал мешок. Положи в кузов и поезжай дальше!");
        }
    }
    else if(extra_id >= 1 && extra_id < CONTAINER_AREA_OFFSET)
    {
        if(PlayerInfo[playerid][pIsWorking] && PlayerInfo[playerid][pHasTrashBag] && !IsPlayerInAnyVehicle(playerid))
        {
            if(extra_id == PlayerInfo[playerid][pVehicleID])
            {
                if(TruckLoad[extra_id] >= MAX_TRASH_CAPACITY)
                {
                    SendClientMessage(playerid, 0xFF0000AA, "[МУСОРОВОЗ] Кузов полон! Поезжай разгружаться на свалку!");
                    return 1;
                }

                PlayerInfo[playerid][pHasTrashBag] = false;
                RemovePlayerAttachedObject(playerid, 1);
                ClearAnimations(playerid);

                TruckLoad[extra_id]++;
                PlayerInfo[playerid][pJobExp] += EXP_PER_BAG;
                UpdateTruckLabel(extra_id);

                new strText[32];
                format(strText, sizeof(strText), "~g~+%d / %d", TruckLoad[extra_id], MAX_TRASH_CAPACITY);
                GameTextForPlayer(playerid, strText, 2000, 3);

                new str[144];
                format(str, sizeof(str), "{33AA33}[МУСОРОВОЗ] {FFFFFF}Мешок в кузове (%d/%d). Поезжай на свалку или заполняй кузов дальше.", TruckLoad[extra_id], MAX_TRASH_CAPACITY);
                SendClientMessage(playerid, -1, str);

                CheckPlayerRank(playerid);
                SavePlayerGarbageData(playerid);

                if(TruckLoad[extra_id] == MAX_TRASH_CAPACITY)
                {
                    SendClientMessage(playerid, 0xFFFF00AA, "[МУСОРОВОЗ] Машина полна! Поезжай на свалку выгружать мусор.");
                }
            }
        }
    }

    #if defined Garbage_OnPlayerEnterArea
        return Garbage_OnPlayerEnterArea(playerid, areaid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea Garbage_OnPlayerEnterArea
#if defined Garbage_OnPlayerEnterArea
    forward Garbage_OnPlayerEnterArea(playerid, areaid);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_MIKHALYCH_MAIN:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0:
                {
                    ShowPlayerDialog(playerid, DIALOG_MIKHALYCH_INFO, DIALOG_STYLE_MSGBOX,
                        "{FF9900}Михалыч: О работе",
                        "{FFFFFF}Привет. В городе скопилось очень много мусора.\n\
                        Мы должны собрать его весь.\n\n\n\n\
                        {FFFF00}Последовательность действий:{FFFFFF}\n\n\
                        1. Берешь у меня ключи и надеваешь спец.одежду.\n\
                        2. Катаешься по точкам, забираешь мешки из мусорок.\n\
                        3. Укладываешь мешки в кузов. Сдавать можно от 1 до 20 штук за раз!\n\
                        4. Привозишь на свалку — я плачу тебе {33AA33}250.000 рублей{FFFFFF} за каждый мешок!\n\n\
                        Будешь нормально работать — повышу и добавлю бонус к зарплате.",
                        "Понял", "");
                }
                case 1:
                {
                    new string[230], pName[MAX_PLAYER_NAME], rankName[24];
                    GetPlayerName(playerid, pName, sizeof(pName));

                    if(PlayerInfo[playerid][pJobRank] == 1) format(rankName, sizeof(rankName), "Стажер");
                    else if(PlayerInfo[playerid][pJobRank] == 2) format(rankName, sizeof(rankName), "Водитель");
                    else format(rankName, sizeof(rankName), "Старший водитель");

                    new nextExp = (PlayerInfo[playerid][pJobRank] == 1) ? EXP_FOR_RANK_2 : EXP_FOR_RANK_3;
                    if(PlayerInfo[playerid][pJobRank] == 3) nextExp = 0;

                    format(string, sizeof(string),
                        "{FFFFFF}• Имя: {FFFF00}%s\n\
                        {FFFFFF}• Должность: {FFFF00}%s\n\
                        {FFFFFF}• Кол-во опыта: {FFFF00}%d ед.\n\
                        {FFFFFF}• До повышения: {FFFF00}%d ед.\n\n\
                        {73B9EE}Текущий статус: %s",
                        pName, rankName, PlayerInfo[playerid][pJobExp], nextExp,
                        (PlayerInfo[playerid][pIsWorking]) ? ("{33AA33}Работает") : ("{FF4444}Отдыхает"));

                    ShowPlayerDialog(playerid, DIALOG_MIKHALYCH_STATS, DIALOG_STYLE_MSGBOX, "{FF9900}Личная карточка", string, "Назад", "");
                }
                case 2:
                {
                    if(!PlayerInfo[playerid][pIsWorking])
                    {
                        new string[220];
                        format(string, sizeof(string),
                            "{FFFFFF}Михалыч внимательно смотрит в твой паспорт...\n\n\
                            • Годы в области: от 3 лет {FFFF00}(У тебя: %d лет в области)\n\
                            • Проблемы с законом {FFFF00}(Проблем с законом: {33AA33}Нет{FFFF00})\n\n\
                            Готов начать работу",
                            PlayerInfo[playerid][pLevel]);

                        ShowPlayerDialog(playerid, DIALOG_MIKHALYCH_REQ, DIALOG_STYLE_MSGBOX, "{FF9900}Трудоустройство", string, "Устроиться", "Отмена");
                    }
                    else
                    {
                        SavePlayerGarbageData(playerid);
                        ResetPlayerJobData(playerid);
                        SendClientMessage(playerid, -1, "{FF4444}[МУСОРОВОЗ] Смена окончена. Ты сдал ключи Михалычу и переоделся в свою одежду.");
                    }
                }
            }
            return 1;
        }
        case DIALOG_MIKHALYCH_INFO, DIALOG_MIKHALYCH_STATS:
        {
            new menuStr[128];
            format(menuStr, sizeof(menuStr), "1. О работе\n2. Личная карточка\n3. %s", (PlayerInfo[playerid][pIsWorking]) ? ("{FF4444}Закончить работу{FFFFFF}") : ("{33AA33}Начать работу{FFFFFF}"));
            ShowPlayerDialog(playerid, DIALOG_MIKHALYCH_MAIN, DIALOG_STYLE_LIST, "{FF9900}Михалыч", menuStr, "Выбрать", "Отойти");
            return 1;
        }
        case DIALOG_MIKHALYCH_REQ:
        {
            if(!response) return 1;
            if(PlayerInfo[playerid][pLevel] < 3)
            {
                ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{FF0000}Отказ", "Михалыч: Недостаточно лет в области. Проживи в области хотя бы 3 года, потом приходи.", "Окей", "");
                return 1;
            }

            PlayerInfo[playerid][pOldSkin] = GetPlayerSkin(playerid);
            PlayerInfo[playerid][pIsWorking] = true;
            SetPlayerSkin(playerid, WORK_SKIN_ID);

            PlayerInfo[playerid][pFadeTD] = CreatePlayerTextDraw(playerid, 0.0, 0.0, " ");
            PlayerTextDrawLetterSize(playerid, PlayerInfo[playerid][pFadeTD], 0.0, 60.0);
            PlayerTextDrawTextSize(playerid, PlayerInfo[playerid][pFadeTD], 640.0, 0.0);
            PlayerTextDrawUseBox(playerid, PlayerInfo[playerid][pFadeTD], 1);
            PlayerTextDrawBoxColor(playerid, PlayerInfo[playerid][pFadeTD], 0x000000FF);
            PlayerTextDrawShow(playerid, PlayerInfo[playerid][pFadeTD]);

            SetTimerEx("OnPlayerFadeComplete", 1200, false, "i", playerid);
            return 1;
        }
    }

    #if defined Garbage_OnDialogResponse
        return Garbage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse Garbage_OnDialogResponse
#if defined Garbage_OnDialogResponse
    forward Garbage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif