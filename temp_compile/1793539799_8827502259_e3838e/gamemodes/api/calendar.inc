/*
    OnPlayerConnect
    
    EventCalendar_LoadPlayer(playerid)
    
    database
    
    CREATE TABLE IF NOT EXISTS `event_calendar_players` (
  `account_id` INT NOT NULL,
  `day` INT NOT NULL DEFAULT 0,
  `created_at` INT NOT NULL DEFAULT 0,
  `updated_at` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

by melliss 
*/

#define EVENT_CALENDAR_MAX_DAY      49   // TODO: уточнить реальный максимум (на скрине "0/49")

enum E_EVENT_CALENDAR_DATA
{
    bool:EVENT_CALENDAR_LOADED,
    EVENT_CALENDAR_DAY
};

new g_event_calendar[MAX_PLAYERS][E_EVENT_CALENDAR_DATA];

stock EventCalendar_CreateTables()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `event_calendar_players` (`account_id` INT NOT NULL, `day` INT NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno()) printf("[EVENT_CALENDAR][DB][ERROR] create event_calendar_players errno=%d", mysql_errno());
    return 1;
}

stock EventCalendar_ResetPlayer(playerid)
{
    g_event_calendar[playerid][EVENT_CALENDAR_LOADED] = false;
    g_event_calendar[playerid][EVENT_CALENDAR_DAY] = 0;
    return 1;
}

forward EventCalendar_OnLoadCallback(playerid);
public EventCalendar_OnLoadCallback(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new rows;
    cache_get_row_count(rows);

    if(rows > 0)
    {
        g_event_calendar[playerid][EVENT_CALENDAR_DAY] = cache_get_field_content_int(0, "day");
    }
    else
    {
        new query[128];
        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO event_calendar_players (account_id, day, created_at, updated_at) VALUES (%d, 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())",
            GetPlayerAccountID(playerid));
        mysql_query(mysql, query, false);

        g_event_calendar[playerid][EVENT_CALENDAR_DAY] = 0;
    }

    g_event_calendar[playerid][EVENT_CALENDAR_LOADED] = true;
    return 1;
}

stock EventCalendar_LoadPlayer(playerid)
{
    if(g_event_calendar[playerid][EVENT_CALENDAR_LOADED]) return 1;
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new query[128];
    mysql_format(mysql, query, sizeof(query),
        "SELECT day FROM event_calendar_players WHERE account_id=%d LIMIT 1",
        GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query, "EventCalendar_OnLoadCallback", "d", playerid);
    return 1;
}

stock EventCalendar_SavePlayer(playerid)
{
    if(!g_event_calendar[playerid][EVENT_CALENDAR_LOADED]) return 0;

    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE event_calendar_players SET day=%d, updated_at=UNIX_TIMESTAMP() WHERE account_id=%d LIMIT 1",
        g_event_calendar[playerid][EVENT_CALENDAR_DAY],
        GetPlayerAccountID(playerid));
    mysql_query(mysql, query, false);
    return 1;
}

stock EventCalendar_GetDay(playerid)
{
    return g_event_calendar[playerid][EVENT_CALENDAR_DAY];
}

stock EventCalendar_AddDay(playerid, amount = 1)
{
    if(!g_event_calendar[playerid][EVENT_CALENDAR_LOADED])
    {
        EventCalendar_LoadPlayer(playerid); // запускаем загрузку, если ещё не запущена
        return -1; // данные ещё не готовы — сохранять/изменять сейчас нельзя (гонка с асинхронной загрузкой)
    }

    g_event_calendar[playerid][EVENT_CALENDAR_DAY] += amount;

    if(g_event_calendar[playerid][EVENT_CALENDAR_DAY] > EVENT_CALENDAR_MAX_DAY)
        g_event_calendar[playerid][EVENT_CALENDAR_DAY] = EVENT_CALENDAR_MAX_DAY;

    if(g_event_calendar[playerid][EVENT_CALENDAR_DAY] < 0)
        g_event_calendar[playerid][EVENT_CALENDAR_DAY] = 0;

    EventCalendar_SavePlayer(playerid);
    return g_event_calendar[playerid][EVENT_CALENDAR_DAY];
}

#define EVENT_CALENDAR_VISIBLE_DAYS  7

stock ShowCalendar(playerid)
{
    new Node:root = JSON_Object();

    JSON_SetInt(root, "o", 1);
    JSON_SetInt(root, "t", 1);
    JSON_SetString(root, "n", GetPlayerNameEx(playerid));

    new currentDay = EventCalendar_GetDay(playerid);

    new Node:d1 = JSON_Int(1 <= currentDay ? 3 : 0);
    new Node:d2 = JSON_Int(2 <= currentDay ? 3 : 0);
    new Node:d3 = JSON_Int(3 <= currentDay ? 3 : 0);
    new Node:d4 = JSON_Int(4 <= currentDay ? 3 : 0);
    new Node:d5 = JSON_Int(5 <= currentDay ? 3 : 0);
    new Node:d6 = JSON_Int(6 <= currentDay ? 3 : 0);
    new Node:d7 = JSON_Int(7 <= currentDay ? 3 : 0);
    new Node:days_status = JSON_Array(d1, d2, d3, d4, d5, d6, d7);
    JSON_SetArray(root, "s", days_status);

    JSON_Cleanup(d1); JSON_Cleanup(d2); JSON_Cleanup(d3); JSON_Cleanup(d4);
    JSON_Cleanup(d5); JSON_Cleanup(d6); JSON_Cleanup(d7);
    JSON_Cleanup(days_status);

    ShowPlayerGUI(playerid, 71, root);
    JSON_Cleanup(root);

    return 1;
}

CMD:calendar(playerid, params[])
{
    if(!EventCalendar_LoadPlayer(playerid)) return 1;
    ShowCalendar(playerid);
    return 1;
}

CMD:addcalendarday(playerid, params[])
{
    printf("[EVENT_CALENDAR] CMD:addcalendarday called by %d, raw params=\"%s\"", playerid, params);

    new amount;
    if(sscanf(params, "d", amount))
        amount = 1; // если количество не указано — выдаём 1 день

    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid))
    {
        SendClientMessage(playerid, -1, "Вы должны авторизоваться, чтобы использовать эту команду.");
        printf("[EVENT_CALENDAR] addcalendarday BLOCKED: not logged in (playerid=%d)", playerid);
        return 1;
    }

    new newDay = EventCalendar_AddDay(playerid, amount);
    printf("[EVENT_CALENDAR] addcalendarday result: newDay=%d (amount=%d)", newDay, amount);

    if(newDay == -1)
    {
        SendClientMessage(playerid, -1, "Данные календаря ещё не загружены, попробуйте через пару секунд.");
        return 1;
    }

    new msg[96];
    format(msg, sizeof(msg), "Календарь: выдано %d дн., текущий прогресс %d/%d.", amount, newDay, EVENT_CALENDAR_MAX_DAY);
    SendClientMessage(playerid, -1, msg);

    ShowCalendar(playerid); // обновляем окно, если оно сейчас открыто у игрока

    return 1;
}