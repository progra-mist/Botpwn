/*јвтор системы: https://t.me/rcdDRIFTOVICH (Werton) 

Ћс автора: @Tinkoff_account
                     @HET_HOMEP */

new on_player_enter_pickup;
new player_state_pickup[MAX_PLAYERS];

public OnPlayerConnect(playerid)
{
player_state_pickup[playerid] = 0;

#if defined fixp_OnPlayerConnect
        return fixp_OnPlayerConnect(playerid);
    #else
        return 1;

    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect fixp_OnPlayerConnect
#if defined fixp_OnPlayerConnect
    forward fixp_OnPlayerConnect(playerid);
#endif

public OnPlayerSpawn(playerid)
{
player_state_pickup[playerid] = 0;

#if defined fixp_OnPlayerSpawn
        return fixp_OnPlayerSpawn(playerid);
    #else
        return 1;

    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn fixp_OnPlayerSpawn
#if defined fixp_OnPlayerSpawn
    forward fixp_OnPlayerSpawn(playerid);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
if(areaid == on_player_enter_pickup)
{
return 1;
}

#if defined fixp_OnPlayerEnterDynamicArea
        return fixp_OnPlayerEnterDynamicArea(playerid, areaid);
    #else
        return 1;

    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea fixp_OnPlayerEnterDynamicArea
#if defined fixp_OnPlayerEnterDynamicArea
    forward fixp_OnPlayerEnterDynamicArea(playerid, areaid);
#endif

public OnGameModeInit()
{
    print("\n");
    print("===============================\n");
    print(" Fix Pickup 2025 loaded.\n");
    print("      Version:  1.0.0\n");
    print(" (FixPickup) 2025 By LAIRD\n");
    print("===============================\n");

    #if defined fixp_OnGameModeInit
        return fixp_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit fixp_OnGameModeInit
#if defined fixp_OnGameModeInit
    forward fixp_OnGameModeInit();
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
if(areaid == on_player_enter_pickup)
{
player_state_pickup[playerid] = 0;
}

#if defined fixp_OnPlayerLeaveDynamicArea
        return fixp_OnPlayerLeaveDynamicArea(playerid, areaid);
    #else
        return 1;

    #endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea fixp_OnPlayerLeaveDynamicArea
#if defined fixp_OnPlayerLeaveDynamicArea
    forward fixp_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

/*јвтор системы: https://t.me/rcdDRIFTOVICH (Werton) 

Ћс автора: @Tinkoff_account
                     @HET_HOMEP */