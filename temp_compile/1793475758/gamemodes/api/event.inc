/*
    в айпакет:
    case 30:
    {
        EventDacha_HandlePacket(playerid, json);
    }

    файл закидовать по пути инклуд/системс/...

    автор меллисс
*/

#define EVENT_DACHA_LEVEL_EXP       1000    
#define EVENT_DACHA_LEVEL_PRICE     239     
#define EVENT_DACHA_MAX_LEVEL       45

enum E_EVENT_DACHA_DATA
{
    bool:EVENT_DACHA_LOADED,
    EVENT_DACHA_LEVEL,
    EVENT_DACHA_EXPERIENCE
};

new g_event_dacha[MAX_PLAYERS][E_EVENT_DACHA_DATA];

stock EventDacha_CreateTables()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `event_dacha_players` (`account_id` INT NOT NULL, `level` INT NOT NULL DEFAULT 0, `experience` INT NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno()) printf("[EVENT_DACHA][DB][ERROR] create event_dacha_players errno=%d", mysql_errno());
    return 1;
}

stock EventDacha_ResetPlayer(playerid)
{
    g_event_dacha[playerid][EVENT_DACHA_LOADED] = false;
    g_event_dacha[playerid][EVENT_DACHA_LEVEL] = 0;
    g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] = 0;
    return 1;
}

forward EventDacha_OnLoadCallback(playerid);
public EventDacha_OnLoadCallback(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new rows;
    cache_get_row_count(rows);

    if(rows > 0)
    {
        g_event_dacha[playerid][EVENT_DACHA_LEVEL] = cache_get_field_content_int(0, "level");
        g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] = cache_get_field_content_int(0, "experience");
    }
    else
    {
        new query[128];
        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO event_dacha_players (account_id, level, experience, created_at, updated_at) VALUES (%d, 0, 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())",
            GetPlayerAccountID(playerid));
        mysql_query(mysql, query, false);

        g_event_dacha[playerid][EVENT_DACHA_LEVEL] = 0;
        g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] = 0;
    }

    g_event_dacha[playerid][EVENT_DACHA_LOADED] = true;
    return 1;
}

stock EventDacha_LoadPlayer(playerid)
{
    if(g_event_dacha[playerid][EVENT_DACHA_LOADED]) return 1;
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new query[128];
    mysql_format(mysql, query, sizeof(query),
        "SELECT level, experience FROM event_dacha_players WHERE account_id=%d LIMIT 1",
        GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query, "EventDacha_OnLoadCallback", "d", playerid);
    return 1;
}

stock EventDacha_SavePlayer(playerid)
{
    if(!g_event_dacha[playerid][EVENT_DACHA_LOADED]) return 0;

    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE event_dacha_players SET level=%d, experience=%d, updated_at=UNIX_TIMESTAMP() WHERE account_id=%d LIMIT 1",
        g_event_dacha[playerid][EVENT_DACHA_LEVEL],
        g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE],
        GetPlayerAccountID(playerid));
    mysql_query(mysql, query, false);
    return 1;
}

stock EventDacha_GetLevel(playerid)
{
    return g_event_dacha[playerid][EVENT_DACHA_LEVEL];
}

stock EventDacha_GetProgress(playerid)
{
    return g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE];
}

stock EventDacha_GrantExperience(playerid, amount)
{
    if(!g_event_dacha[playerid][EVENT_DACHA_LOADED])
    {
        if(!EventDacha_LoadPlayer(playerid)) return 0;
    }

    if(amount <= 0) return 0;
    if(g_event_dacha[playerid][EVENT_DACHA_LEVEL] >= EVENT_DACHA_MAX_LEVEL) return 0;

    g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] += amount;

    while(g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] >= EVENT_DACHA_LEVEL_EXP && g_event_dacha[playerid][EVENT_DACHA_LEVEL] < EVENT_DACHA_MAX_LEVEL)
    {
        g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] -= EVENT_DACHA_LEVEL_EXP;
        g_event_dacha[playerid][EVENT_DACHA_LEVEL]++;
    }

    if(g_event_dacha[playerid][EVENT_DACHA_LEVEL] >= EVENT_DACHA_MAX_LEVEL)
    {
        g_event_dacha[playerid][EVENT_DACHA_EXPERIENCE] = 0;
    }

    EventDacha_SavePlayer(playerid);
    return 1;
}

stock EventDacha_SendMainPacket(playerid)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "page", 1);

    ShowPlayerGUI(playerid, 30, json);
    JSON_Cleanup(json);
    return 1;
}

stock EventDacha_HandleUpgrade(playerid, Node:response)
{
    JSON_SetInt(response, "page", 1);

    if(EventDacha_GetLevel(playerid) >= EVENT_DACHA_MAX_LEVEL)
    {
        SendClientMessage(playerid, -1, "Дача уже максимального уровня.");
        return 1;
    }

    if(GetPlayerData(playerid, P_MONEY) < EVENT_DACHA_LEVEL_PRICE)
    {
        SendClientMessage(playerid, -1, "Недостаточно средств для прокачки дачи.");
        return 1;
    }

    SetPlayerData(playerid, P_MONEY, GetPlayerData(playerid, P_MONEY) - EVENT_DACHA_LEVEL_PRICE);
    EventDacha_GrantExperience(playerid, EVENT_DACHA_LEVEL_EXP);
    return 1;
}

stock EventDacha_HandlePacket(playerid, Node:json)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(!EventDacha_LoadPlayer(playerid)) return 0;

    new current_page, button_id;
    JSON_GetInt(json, "page", current_page);
    JSON_GetInt(json, "button", button_id);

    new Node:response = JSON_Object();

    switch(button_id)
    {
        case 1: // кнопка "+"
        {
            EventDacha_HandleUpgrade(playerid, response);
        }

        default:
        {
            JSON_SetInt(response, "page", 1);
        }
    }

    OnPacketIncoming(playerid, 30, response);
    JSON_Cleanup(response);
    return 1;
}

CMD:eventt(playerid, params[])
{
    if(!EventDacha_LoadPlayer(playerid)) return 1;
    return EventDacha_SendMainPacket(playerid);
}

CMD:givexpevent(playerid, params[])
{
    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
        return SendClientMessage(playerid, -1, "Использование: /givexpevent [id] [количество]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Игрок не в сети.");

    if(!EventDacha_LoadPlayer(targetid))
        return SendClientMessage(playerid, -1, "Данные игрока по событию ещё не загружены.");

    EventDacha_GrantExperience(targetid, amount);

    SendClientMessage(playerid, -1, "Опыт события выдан.");
    SendClientMessage(targetid, -1, "Вам выдан опыт летнего события.");
    return 1;
}
