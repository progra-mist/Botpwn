#if defined _death_gui_included
    #endinput
#endif
#define _death_gui_included

#define WOUND_SYSTEM_KMONARCH_LOADED (1)
#define WOUNDGID (40)

#define WOUND_HOSPITAL_X (1471.672729)
#define WOUND_HOSPITAL_Y (2506.028076)
#define WOUND_HOSPITAL_Z (2501.040283)
#define WOUND_HOSPITAL_A (181.954757)
#define WOUND_HOSPITAL_INT (1)
#define WOUND_HOSPITAL_WORLD (1)

new bool:g_wound_active[MAX_PLAYERS];
new bool:g_wound_respawn[MAX_PLAYERS];
new g_wound_timer[MAX_PLAYERS];
new Float:g_wound_x[MAX_PLAYERS];
new Float:g_wound_y[MAX_PLAYERS];
new Float:g_wound_z[MAX_PLAYERS];
new Float:g_wound_a[MAX_PLAYERS];
new g_wound_int[MAX_PLAYERS];
new g_wound_vw[MAX_PLAYERS];
new g_wound_killer[MAX_PLAYERS];
new bool:g_wound_gui_opened[MAX_PLAYERS];

forward WoundRespawn(playerid);
forward WoundPostGuiApply(playerid);

stock bool:WoundIsActive(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return false;
    return g_wound_active[playerid];
}

stock WoundReset(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;

    g_wound_active[playerid] = false;
    g_wound_respawn[playerid] = false;
    g_wound_gui_opened[playerid] = false;
    g_wound_killer[playerid] = INVALID_PLAYER_ID;

    if(g_wound_timer[playerid])
    {
        KillTimer(g_wound_timer[playerid]);
        g_wound_timer[playerid] = 0;
    }
    return 1;
}

stock WoundClose(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", 2);
    JSON_SetInt(json, "c", 1);
    SendPacketToClient(playerid, WOUNDGID, json);
    JSON_Cleanup(json);

    g_wound_gui_opened[playerid] = false;
    return 1;
}

stock WoundOpen(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(g_wound_gui_opened[playerid]) return 1;

    new Node:json = JSON_Object();
    new killerid = g_wound_killer[playerid];
    new nick[MAX_PLAYER_NAME + 1];

    if(killerid != INVALID_PLAYER_ID && killerid >= 0 && killerid < MAX_PLAYERS && IsPlayerConnected(killerid))
    {
        format(nick, sizeof nick, "%s", GetPlayerNameEx(killerid));
        JSON_SetInt(json, "id", killerid);
    }
    else
    {
        nick[0] = EOS;
        JSON_SetInt(json, "id", 0);
    }

    JSON_SetString(json, "p", nick, strlen(nick));
    JSON_SetInt(json, "h", 1);

    // Set flag before sending GUI to avoid re-open loops if client immediately sends packet back.
    g_wound_gui_opened[playerid] = true;

    // Apply before GUI and again after GUI packet, because this mod/client may reset anim/HP on GUI open.
    WoundPostGuiApply(playerid);
    ShowPlayerGUI(playerid, WOUNDGID, json);
    SetTimerEx("WoundPostGuiApply", 250, false, "i", playerid);

    JSON_Cleanup(json);
    return 1;
}

stock WoundAnim(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, false);

    // /anim 65 in this mod = anim_list index 64:
    // GHANDS / gsign4. Apply it directly so it does not depend on dialog/list state.
 //   ApplyAnimationEx(playerid, "GHANDS", "gsign4", 4.0, 0, 0, 0, 0, 0, 1, USE_ANIM_TYPE_NONE);
//    SetPlayerAnimation(playerid, 64);
    return 1;
}

public WoundPostGuiApply(playerid)
{
    if(!IsPlayerConnected(playerid) || !g_wound_active[playerid]) return 0;

    // 65% HP must SET health, not ADD health. Old version used inc_health=true and often became 100 HP.
    SetPlayerData(playerid, P_HEALTH, 65.0);
    SetPlayerHealth(playerid, 65.0);

    WoundAnim(playerid);
    return 1;
}

stock WoundSetSpawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    SetSpawnInfo
    (
        playerid,
        0,
        GetPlayerSkinEx(playerid),
        g_wound_x[playerid],
        g_wound_y[playerid],
        g_wound_z[playerid] + 0.20,
        g_wound_a[playerid],
        0, 0, 0, 0, 0, 0
    );
    return 1;
}

stock WoundApply(playerid)
{
    if(!IsPlayerConnected(playerid) || !g_wound_active[playerid]) return 0;

    g_wound_respawn[playerid] = false;
    SetPlayerData(playerid, P_HOSPITAL, false);

    SetPlayerInterior(playerid, g_wound_int[playerid]);
    SetPlayerVirtualWorld(playerid, g_wound_vw[playerid]);
    SetPlayerPos(playerid, g_wound_x[playerid], g_wound_y[playerid], g_wound_z[playerid] + 0.20);
    SetPlayerFacingAngle(playerid, g_wound_a[playerid]);
    SetCameraBehindPlayer(playerid);
    SetPlayerHealthEx(playerid, 65.0, false);
    ResetPlayerWeapons(playerid);
    WoundOpen(playerid);

    printf("[WOUND_SYSTEM] applied player=%d gui=40", playerid);
    return 1;
}

public WoundRespawn(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    g_wound_timer[playerid] = 0;

    if(!IsPlayerConnected(playerid) || !g_wound_active[playerid]) return 0;

    // No forced SpawnPlayer here. The old version used SpawnPlayer from a timer,
    // which conflicted with the mod's own death countdown and caused camera shaking / 14 sec freeze.
    g_wound_respawn[playerid] = true;
    WoundSetSpawn(playerid);
    return 1;
}

stock WoundStart(playerid, killerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    if(g_wound_timer[playerid])
    {
        KillTimer(g_wound_timer[playerid]);
        g_wound_timer[playerid] = 0;
    }

    GetPlayerPos(playerid, g_wound_x[playerid], g_wound_y[playerid], g_wound_z[playerid]);
    GetPlayerFacingAngle(playerid, g_wound_a[playerid]);

    g_wound_int[playerid] = GetPlayerInterior(playerid);
    g_wound_vw[playerid] = GetPlayerVirtualWorld(playerid);

    if(killerid != INVALID_PLAYER_ID && killerid >= 0 && killerid < MAX_PLAYERS && IsPlayerConnected(killerid))
    {
        g_wound_killer[playerid] = killerid;
    }
    else
    {
        g_wound_killer[playerid] = INVALID_PLAYER_ID;
    }

    g_wound_active[playerid] = true;
    g_wound_respawn[playerid] = true;
    g_wound_gui_opened[playerid] = false;

    // Не включаем больницу при смерти. Больница включается только после кнопки в GUI.
    SetPlayerData(playerid, P_HOSPITAL, false);
    UpdatePlayerDatabaseInt(playerid, "hospital", 0);

    WoundSetSpawn(playerid);

    printf("[WOUND_SYSTEM] start player=%d killer=%d pos=%.2f %.2f %.2f", playerid, g_wound_killer[playerid], g_wound_x[playerid], g_wound_y[playerid], g_wound_z[playerid]);
    return 1;
}

stock WoundOnSpawn(playerid)
{
    if(!IsPlayerConnected(playerid) || !g_wound_active[playerid]) return 0;
    if(!g_wound_respawn[playerid]) return 0;

    return WoundApply(playerid);
}

stock WoundHospital(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    if(g_wound_timer[playerid])
    {
        KillTimer(g_wound_timer[playerid]);
        g_wound_timer[playerid] = 0;
    }

    g_wound_active[playerid] = false;
    g_wound_respawn[playerid] = false;
    g_wound_gui_opened[playerid] = false;

    WoundClose(playerid);
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, true);

    SetPlayerData(playerid, P_HOSPITAL, true);
    UpdatePlayerDatabaseInt(playerid, "hospital", 1);
    SetPlayerHealthEx(playerid, 100.0, true);

    SetSpawnInfo
    (
        playerid,
        0,
        GetPlayerSkinEx(playerid),
        WOUND_HOSPITAL_X,
        WOUND_HOSPITAL_Y,
        WOUND_HOSPITAL_Z,
        WOUND_HOSPITAL_A,
        0, 0, 0, 0, 0, 0
    );

    SetPlayerPosEx(playerid, WOUND_HOSPITAL_X, WOUND_HOSPITAL_Y, WOUND_HOSPITAL_Z, WOUND_HOSPITAL_A, WOUND_HOSPITAL_INT, WOUND_HOSPITAL_WORLD, false);
    return 1;
}

stock WoundHandle(playerid, Node:json)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new action;
    JSON_GetInt(json, "t", action);

    printf("[WOUND_SYSTEM] handle player=%d action=%d gui_opened=%d active=%d respawn=%d",
        playerid, action, g_wound_gui_opened[playerid], g_wound_active[playerid], g_wound_respawn[playerid]);

    switch(action)
    {
        case 1:
        {
            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", 1);
            SendPacketToClient(playerid, WOUNDGID, response);
            JSON_Cleanup(response);
            return 1;
        }
        case 2:
        {
            printf("[WOUND_SYSTEM] hospital button pressed by player=%d", playerid);
            return WoundHospital(playerid);
        }
        case 4:
        {
            // Client close/heartbeat packet. Do NOT call WoundOpen() here,
            // otherwise ShowPlayerGUI -> packet t=4 -> WoundOpen loops forever.
            return 1;
        }
        default:
        {
            printf("[WOUND_SYSTEM] unhandled action=%d from player=%d", action, playerid);
        }
    }

    return 1;
}

CMD:death(playerid)
{
    WoundStart(playerid);
    return 1;
}