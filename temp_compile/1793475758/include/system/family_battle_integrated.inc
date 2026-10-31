
#if defined _FAMILY_BATTLE_INCLUDED
    #endinput
#endif
#define _FAMILY_BATTLE_INCLUDED

#define FB_MAX_FAMILIES        (199)
#define FB_EVENT_DURATION      (900)
#define FB_POINTS_PER_KILL     (10)
#define FB_POINTS_PER_CONTROL  (5)
#define FB_CONTROL_TICK        (30000)
#define FB_CONTROL_RADIUS      (25.0)
#define FB_NPC_INTERACT_DIST   (3.0)
#define FB_REWARD_PLACES       (5)

#define FB_DIALOG_INFO         (29001)
#define FB_DIALOG_TOP          (29002)
#define FB_DIALOG_RESULT       (29003)

#define FB_COLOR_EVENT         (0xFFD700FF)
#define FB_COLOR_GREEN         (0x33AA33FF)
#define FB_COLOR_RED           (0xCC3333FF)
#define FB_COLOR_WHITE         (0xFFFFFFFF)

enum E_FB_STATION
{
    fbName[48],
    Float:fbX,
    Float:fbY,
    Float:fbZ,
    Float:fbA,
    fbSkin,
    fbWorld
};

static const g_FamilyBattleStations[][E_FB_STATION] =
{
    {"Вокзал №1 (Невский)",     1480.0000, -1750.0000, 13.5000,  90.0, 164, 0},
    {"Вокзал №2 (Центральный)", 2100.0000, -1800.0000, 13.5000, 180.0, 164, 0},
    {"Вокзал №3 (Южный)",      -1980.0000,   130.0000, 27.6000, 270.0, 164, 0},
    {"Вокзал №4 (Северный)",     820.0000, -1350.0000, 13.5000,   0.0, 164, 0},
    {"Вокзал №5 (Западный)",   -2400.0000,  1000.0000, 45.3000,  45.0, 164, 0}
};

#define FB_STATION_COUNT (sizeof(g_FamilyBattleStations))

static const g_FamilyBattleRewardMoney[FB_REWARD_PLACES] =
{
    5000000,
    3000000,
    1500000,
    750000,
    300000
};

static const g_FamilyBattleRewardText[FB_REWARD_PLACES][] =
{
    "5.000.000$",
    "3.000.000$",
    "1.500.000$",
    "750.000$",
    "300.000$"
};

new g_FamilyBattleActor[FB_STATION_COUNT];
new Text3D:g_FamilyBattleLabel[FB_STATION_COUNT];
new g_FamilyBattleScore[FB_MAX_FAMILIES + 1];
new g_FamilyBattleKills[FB_MAX_FAMILIES + 1];
new bool:g_FamilyBattleActive = false;
new g_FamilyBattleTimeLeft = 0;
new g_FamilyBattleTimer = -1;
new g_FamilyBattleControlTimer = -1;

stock FB_GetPlayerFamily(playerid)
{
    if(!IsPlayerConnected(playerid)) return -1;

    new familyid = GetPlayerIdFamily(playerid);
    if(familyid < 1 || familyid > FB_MAX_FAMILIES) return -1;
    return familyid;
}

stock FB_GetFamilyName(familyid, dest[], len = sizeof(dest))
{
    if(familyid < 1 || familyid > FB_MAX_FAMILIES)
    {
        format(dest, len, "Без семьи");
        return 0;
    }

    format(dest, len, "%s", GetFamilyData(familyid, F_NAME));
    return 1;
}

stock FB_ResetScores()
{
    for(new i = 0; i <= FB_MAX_FAMILIES; i++)
    {
        g_FamilyBattleScore[i] = 0;
        g_FamilyBattleKills[i] = 0;
    }
    return 1;
}

stock FB_GetFamilyCount()
{
    new count = g_family_loaded;
    if(count < 0) count = 0;
    if(count > FB_MAX_FAMILIES) count = FB_MAX_FAMILIES;
    return count;
}

stock FB_CreateStations()
{
    new label[180];

    for(new i = 0; i < FB_STATION_COUNT; i++)
    {
        g_FamilyBattleActor[i] = CreateActor(
            g_FamilyBattleStations[i][fbSkin],
            g_FamilyBattleStations[i][fbX],
            g_FamilyBattleStations[i][fbY],
            g_FamilyBattleStations[i][fbZ],
            g_FamilyBattleStations[i][fbA]
        );

        if(g_FamilyBattleActor[i] != -1)
        {
            SetActorInvulnerable(g_FamilyBattleActor[i], true);
            SetActorVirtualWorld(g_FamilyBattleActor[i], g_FamilyBattleStations[i][fbWorld]);
            ApplyActorAnimation(g_FamilyBattleActor[i], "PED", "IDLE_CHAT", 4.0, 1, 0, 0, 0, 0);
        }

        format(label, sizeof(label),
            "{FFD700}[ БИТВА СЕМЕЙ ]\n{FFFFFF}%s\n{00FF00}Нажмите Y для информации",
            g_FamilyBattleStations[i][fbName]);

        g_FamilyBattleLabel[i] = Create3DTextLabel(
            label,
            FB_COLOR_EVENT,
            g_FamilyBattleStations[i][fbX],
            g_FamilyBattleStations[i][fbY],
            g_FamilyBattleStations[i][fbZ] + 0.9,
            15.0,
            g_FamilyBattleStations[i][fbWorld],
            0
        );
    }
    return 1;
}

stock FB_DestroyStations()
{
    for(new i = 0; i < FB_STATION_COUNT; i++)
    {
        if(g_FamilyBattleActor[i] != -1)
        {
            DestroyActor(g_FamilyBattleActor[i]);
            g_FamilyBattleActor[i] = -1;
        }

        Delete3DTextLabel(g_FamilyBattleLabel[i]);
    }
    return 1;
}

stock FB_GetNearestStation(playerid)
{
    for(new i = 0; i < FB_STATION_COUNT; i++)
    {
        if(IsPlayerInRangeOfPoint(
            playerid,
            FB_NPC_INTERACT_DIST,
            g_FamilyBattleStations[i][fbX],
            g_FamilyBattleStations[i][fbY],
            g_FamilyBattleStations[i][fbZ]))
        {
            return i;
        }
    }
    return -1;
}

stock FB_ShowInfo(playerid, stationid)
{
    if(stationid < 0 || stationid >= FB_STATION_COUNT)
        stationid = 0;

    new str[1400], tmp[256], fname[64];
    new top = FB_GetTopFamily();

    format(str, sizeof(str), "{FFD700}»» БИТВА СЕМЕЙ ««{FFFFFF}\n\n");

    format(tmp, sizeof(tmp), "Локация: {FFD700}%s{FFFFFF}\n\n",
        g_FamilyBattleStations[stationid][fbName]);
    strcat(str, tmp);

    strcat(str, "{FFFFFF}Суть ивента:\n");
    format(tmp, sizeof(tmp),
        " • За фраг игрока другой семьи: {00FF00}+%d{FFFFFF} очков\n",
        FB_POINTS_PER_KILL);
    strcat(str, tmp);

    format(tmp, sizeof(tmp),
        " • За контроль вокзала: {00FF00}+%d{FFFFFF} очков каждые %d сек.\n",
        FB_POINTS_PER_CONTROL, FB_CONTROL_TICK / 1000);
    strcat(str, tmp);

    format(tmp, sizeof(tmp),
        " • Длительность: {FFD700}%d минут{FFFFFF}\n\n",
        FB_EVENT_DURATION / 60);
    strcat(str, tmp);

    if(g_FamilyBattleActive)
    {
        format(tmp, sizeof(tmp),
            "Статус: {00FF00}ИВЕНТ ИДЁТ{FFFFFF}\nДо конца: {FFD700}%02d:%02d{FFFFFF}\n\n",
            g_FamilyBattleTimeLeft / 60,
            g_FamilyBattleTimeLeft % 60);
        strcat(str, tmp);
    }
    else
    {
        strcat(str, "Статус: {FF4444}ИВЕНТ НЕ АКТИВЕН{FFFFFF}\nОжидайте запуска администрации.\n\n");
    }

    if(top != -1)
    {
        FB_GetFamilyName(top, fname);
        format(tmp, sizeof(tmp),
            "{FFD700}ЛИДЕР: %s{FFFFFF}\nОчков: {00FF00}%d{FFFFFF} | Фрагов: {00FF00}%d{FFFFFF}\n\n",
            fname, g_FamilyBattleScore[top], g_FamilyBattleKills[top]);
    }
    else
    {
        format(tmp, sizeof(tmp),
            "{FFD700}ЛИДЕР: не определён{FFFFFF}\n\n");
    }
    strcat(str, tmp);

    strcat(str, "{FFD700}Награды:{FFFFFF}\n");
    for(new i = 0; i < FB_REWARD_PLACES; i++)
    {
        format(tmp, sizeof(tmp),
            " %d место — %s\n",
            i + 1, g_FamilyBattleRewardText[i]);
        strcat(str, tmp);
    }

    ShowPlayerDialog(
        playerid,
        FB_DIALOG_INFO,
        DIALOG_STYLE_MSGBOX,
        "Битва семей — информация",
        str,
        "Топ семей",
        "Закрыть"
    );
    return 1;
}

stock FB_SortFamilies(order[])
{
    new count = 0;
    new familyCount = FB_GetFamilyCount();

    for(new f = 1; f <= familyCount; f++)
    {
        if(g_FamilyBattleScore[f] > 0)
            order[count++] = f;
    }

    for(new i = 0; i < count - 1; i++)
    {
        new best = i;

        for(new j = i + 1; j < count; j++)
        {
            if(g_FamilyBattleScore[order[j]] > g_FamilyBattleScore[order[best]] ||
              (g_FamilyBattleScore[order[j]] == g_FamilyBattleScore[order[best]] &&
               g_FamilyBattleKills[order[j]] > g_FamilyBattleKills[order[best]]))
            {
                best = j;
            }
        }

        if(best != i)
        {
            new tmp = order[i];
            order[i] = order[best];
            order[best] = tmp;
        }
    }
    return count;
}

stock FB_GetTopFamily()
{
    new best = -1;
    new familyCount = FB_GetFamilyCount();

    for(new f = 1; f <= familyCount; f++)
    {
        if(g_FamilyBattleScore[f] <= 0) continue;

        if(best == -1 ||
           g_FamilyBattleScore[f] > g_FamilyBattleScore[best] ||
          (g_FamilyBattleScore[f] == g_FamilyBattleScore[best] &&
           g_FamilyBattleKills[f] > g_FamilyBattleKills[best]))
        {
            best = f;
        }
    }
    return best;
}

stock FB_ShowTop(playerid)
{
    new order[FB_MAX_FAMILIES + 1];
    new count = FB_SortFamilies(order);
    new str[1400], tmp[180], fname[64];

    format(str, sizeof(str), "Место\tСемья\tОчки\tФраги\n");

    if(count == 0)
    {
        strcat(str, "-\tОчков пока нет\t-\t-\n");
    }
    else
    {
        for(new i = 0; i < count && i < 10; i++)
        {
            FB_GetFamilyName(order[i], fname);

            format(tmp, sizeof(tmp),
                "%d\t%s\t%d\t%d\n",
                i + 1,
                fname,
                g_FamilyBattleScore[order[i]],
                g_FamilyBattleKills[order[i]]);

            strcat(str, tmp);
        }
    }

    ShowPlayerDialog(
        playerid,
        FB_DIALOG_TOP,
        DIALOG_STYLE_TABLIST_HEADERS,
        "Битва семей — ТОП",
        str,
        "Закрыть",
        ""
    );
    return 1;
}

stock FB_GivePrize(familyid, place)
{
    if(familyid < 1 || familyid > FB_MAX_FAMILIES) return 0;
    if(place < 1 || place > FB_REWARD_PLACES) return 0;

    new fname[64], msg[220];
    FB_GetFamilyName(familyid, fname);

    for(new i = 0, mp = GetMaxPlayers(); i < mp; i++)
    {
        if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
        if(FB_GetPlayerFamily(i) != familyid) continue;

        GivePlayerMoneyEx(i, g_FamilyBattleRewardMoney[place - 1], "Битва семей");

        format(msg, sizeof(msg),
            "{FFD700}[БИТВА СЕМЕЙ] {FFFFFF}Ваша семья заняла {FFD700}%d место{FFFFFF}! Награда: {00FF00}%s",
            place,
            g_FamilyBattleRewardText[place - 1]);

        SendClientMessage(i, FB_COLOR_WHITE, msg);
    }
    return 1;
}

stock FB_ShowResults()
{
    new order[FB_MAX_FAMILIES + 1];
    new count = FB_SortFamilies(order);
    new str[1800], tmp[220], fname[64];

    strcat(str, "{FFD700}»» ИТОГИ БИТВЫ СЕМЕЙ ««{FFFFFF}\n\n");

    if(count == 0)
    {
        strcat(str, "{FF4444}Очков не набрала ни одна семья.{FFFFFF}");
    }
    else
    {
        for(new i = 0; i < count && i < FB_REWARD_PLACES; i++)
        {
            FB_GetFamilyName(order[i], fname);

            format(tmp, sizeof(tmp),
                "{FFD700}%d место{FFFFFF} — %s\nОчки: {00FF00}%d{FFFFFF} | Фраги: {00FF00}%d{FFFFFF}\nНаграда: {FFD700}%s{FFFFFF}\n\n",
                i + 1,
                fname,
                g_FamilyBattleScore[order[i]],
                g_FamilyBattleKills[order[i]],
                g_FamilyBattleRewardText[i]);

            strcat(str, tmp);
        }
    }

    for(new i = 0, mp = GetMaxPlayers(); i < mp; i++)
    {
        if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;

        ShowPlayerDialog(
            i,
            FB_DIALOG_RESULT,
            DIALOG_STYLE_MSGBOX,
            "Битва семей — результаты",
            str,
            "Закрыть",
            ""
        );
    }
    return 1;
}

stock FB_Start()
{
    if(g_FamilyBattleActive) return 0;

    FB_ResetScores();

    g_FamilyBattleActive = true;
    g_FamilyBattleTimeLeft = FB_EVENT_DURATION;

    if(g_FamilyBattleTimer != -1)
        KillTimer(g_FamilyBattleTimer);

    if(g_FamilyBattleControlTimer != -1)
        KillTimer(g_FamilyBattleControlTimer);

    g_FamilyBattleTimer =
        SetTimer("FB_EventSecondTick", 1000, true);

    g_FamilyBattleControlTimer =
        SetTimer("FB_ControlPointTick", FB_CONTROL_TICK, true);

    SendClientMessageToAll(
        FB_COLOR_EVENT,
        "==============================================");
    SendClientMessageToAll(
        FB_COLOR_EVENT,
        "[БИТВА СЕМЕЙ] Ивент начался! Захватывайте вокзалы!");

    new msg[144];
    format(msg, sizeof(msg),
        "Длительность: %d минут. Команды: /familybattle и /fbtop",
        FB_EVENT_DURATION / 60);
    SendClientMessageToAll(FB_COLOR_WHITE, msg);

    SendClientMessageToAll(
        FB_COLOR_EVENT,
        "==============================================");

    return 1;
}

stock FB_Stop()
{
    if(!g_FamilyBattleActive) return 0;

    g_FamilyBattleActive = false;

    if(g_FamilyBattleTimer != -1)
    {
        KillTimer(g_FamilyBattleTimer);
        g_FamilyBattleTimer = -1;
    }

    if(g_FamilyBattleControlTimer != -1)
    {
        KillTimer(g_FamilyBattleControlTimer);
        g_FamilyBattleControlTimer = -1;
    }

    new order[FB_MAX_FAMILIES + 1];
    new count = FB_SortFamilies(order);

    for(new i = 0; i < count && i < FB_REWARD_PLACES; i++)
        FB_GivePrize(order[i], i + 1);

    FB_ShowResults();

    SendClientMessageToAll(
        FB_COLOR_EVENT,
        "[БИТВА СЕМЕЙ] Ивент завершён!");

    return 1;
}

forward FB_EventSecondTick();
public FB_EventSecondTick()
{
    if(!g_FamilyBattleActive) return 0;

    g_FamilyBattleTimeLeft--;

    if(g_FamilyBattleTimeLeft == 600 ||
       g_FamilyBattleTimeLeft == 300 ||
       g_FamilyBattleTimeLeft == 120 ||
       g_FamilyBattleTimeLeft == 60 ||
       g_FamilyBattleTimeLeft == 30 ||
       g_FamilyBattleTimeLeft == 10)
    {
        new msg[128];

        format(msg, sizeof(msg),
            "[БИТВА СЕМЕЙ] До конца: %02d:%02d",
            g_FamilyBattleTimeLeft / 60,
            g_FamilyBattleTimeLeft % 60);

        SendClientMessageToAll(FB_COLOR_EVENT, msg);
    }

    if(g_FamilyBattleTimeLeft <= 0)
        FB_Stop();

    return 1;
}

forward FB_ControlPointTick();
public FB_ControlPointTick()
{
    if(!g_FamilyBattleActive) return 0;

    new counts[FB_MAX_FAMILIES + 1];
    new familyCount = FB_GetFamilyCount();
    new str[180], fname[64];

    for(new s = 0; s < FB_STATION_COUNT; s++)
    {
        for(new f = 0; f <= familyCount; f++)
            counts[f] = 0;

        for(new i = 0, mp = GetMaxPlayers(); i < mp; i++)
        {
            if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
            if(GetPlayerState(i) == PLAYER_STATE_WASTED) continue;

            new familyid = FB_GetPlayerFamily(i);
            if(familyid == -1) continue;

            if(IsPlayerInRangeOfPoint(
                i,
                FB_CONTROL_RADIUS,
                g_FamilyBattleStations[s][fbX],
                g_FamilyBattleStations[s][fbY],
                g_FamilyBattleStations[s][fbZ]))
            {
                counts[familyid]++;
            }
        }

        new best = -1;
        new bestCount = 0;
        new tie = 0;

        for(new f = 1; f <= familyCount; f++)
        {
            if(counts[f] > bestCount)
            {
                bestCount = counts[f];
                best = f;
                tie = 0;
            }
            else if(counts[f] == bestCount && bestCount > 0)
            {
                tie++;
            }
        }

        if(best != -1 && bestCount > 0 && tie == 0)
        {
            g_FamilyBattleScore[best] += FB_POINTS_PER_CONTROL;

            FB_GetFamilyName(best, fname);

            format(str, sizeof(str),
                "[БИТВА СЕМЕЙ] '%s' удерживает %s (+%d очков)",
                fname,
                g_FamilyBattleStations[s][fbName],
                FB_POINTS_PER_CONTROL);

            SendClientMessageToAll(FB_COLOR_GREEN, str);
        }
    }
    return 1;
}

/*
 * Call these three functions from the existing callbacks in the main gamemode:
 *   OnGameModeInit       -> FB_CreateStations();
 *   OnPlayerKeyStateChange -> FB_HandleKeyStateChange(playerid, newkeys, oldkeys);
 *   OnPlayerDeath        -> FB_HandleDeath(playerid, killerid);
 *   OnDialogResponse     -> FB_HandleDialog(playerid, dialogid, response);
 */

stock FB_HandleKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        new stationid = FB_GetNearestStation(playerid);
        if(stationid != -1)
        {
            FB_ShowInfo(playerid, stationid);
            return 1;
        }
    }
    return 0;
}

stock FB_HandleDeath(playerid, killerid)
{
    if(!g_FamilyBattleActive) return 0;
    if(killerid == INVALID_PLAYER_ID || !IsPlayerConnected(killerid)) return 0;

    new killerFamily = FB_GetPlayerFamily(killerid);
    new victimFamily = FB_GetPlayerFamily(playerid);

    if(killerFamily == -1 || victimFamily == -1) return 0;
    if(killerFamily == victimFamily) return 0;

    g_FamilyBattleScore[killerFamily] += FB_POINTS_PER_KILL;
    g_FamilyBattleKills[killerFamily]++;

    new fname[64], msg[160];
    FB_GetFamilyName(killerFamily, fname);

    format(msg, sizeof(msg),
        "{FFD700}[БИТВА СЕМЕЙ] {FFFFFF}+%d очков для '%s'. Всего: %d",
        FB_POINTS_PER_KILL,
        fname,
        g_FamilyBattleScore[killerFamily]);

    SendClientMessage(killerid, FB_COLOR_WHITE, msg);
    return 1;
}

stock FB_HandleDialog(playerid, dialogid, response)
{
    if(dialogid == FB_DIALOG_INFO)
    {
        if(response)
            FB_ShowTop(playerid);

        return 1;
    }

    if(dialogid == FB_DIALOG_TOP ||
       dialogid == FB_DIALOG_RESULT)
    {
        return 1;
    }

    return 0;
}

stock FB_OnGameModeInit()
{
    for(new i = 0; i < FB_STATION_COUNT; i++)
        g_FamilyBattleActor[i] = -1;

    FB_ResetScores();
    FB_CreateStations();

    print("[FamilyBattle] Integrated family battle system loaded.");
    return 1;
}

stock FB_OnGameModeExit()
{
    FB_DestroyStations();

    if(g_FamilyBattleTimer != -1)
    {
        KillTimer(g_FamilyBattleTimer);
        g_FamilyBattleTimer = -1;
    }

    if(g_FamilyBattleControlTimer != -1)
    {
        KillTimer(g_FamilyBattleControlTimer);
        g_FamilyBattleControlTimer = -1;
    }
    return 1;
}

/* Admin/player commands. */
CMD:familybattle(playerid)
{
    if(!GetPlayerAdminEx(playerid))
        return SendClientMessage(playerid, FB_COLOR_RED, "У вас нет доступа к этой команде.");

    if(g_FamilyBattleActive)
        return SendClientMessage(playerid, FB_COLOR_RED, "Битва семей уже идёт.");

    FB_Start();
    return 1;
}

CMD:familybattle_stop(playerid)
{
    if(!GetPlayerAdminEx(playerid))
        return SendClientMessage(playerid, FB_COLOR_RED, "У вас нет доступа к этой команде.");

    if(!g_FamilyBattleActive)
        return SendClientMessage(playerid, FB_COLOR_RED, "Битва семей сейчас не идёт.");

    FB_Stop();
    return 1;
}

CMD:fbtop(playerid)
{
    FB_ShowTop(playerid);
    return 1;
}

CMD:fbinfo(playerid)
{
    new stationid = FB_GetNearestStation(playerid);
    if(stationid == -1) stationid = 0;

    FB_ShowInfo(playerid, stationid);
    return 1;
}

