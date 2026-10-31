// GUI 46 - full official faction menu adapter.
// Official organizations only. Criminal organizations (OPG) keep their own menu.

#define FRACTION_GUI_MAX_ROSTER        (100)
#define FRACTION_GUI_TOKEN_PRICE       (50)
#define FRACTION_GUI_TOKEN_PACK        (100)
#define FRACTION_GUI_DEFAULT_TOKENS    (0)
#define FRACTION_GUI_DOCS_COUNT        (4)
#define FRACTION_GUI_DOCS_ALL_MASK     ((1 << FRACTION_GUI_DOCS_COUNT) - 1)
#define FRACTION_GUI_TEST_QUESTIONS    (10)
#define FRACTION_GUI_TEST_PASS         (8)
#define FRACTION_GUI_QUEST_TARGET      (25)

// Roster keeps both persistent account IDs and the current SA-MP player IDs.
// This lets GUI 46 show the full organization roster, including offline members.
new g_fraction_gui_roster[MAX_PLAYERS][FRACTION_GUI_MAX_ROSTER];
new g_fraction_gui_roster_account[MAX_PLAYERS][FRACTION_GUI_MAX_ROSTER];
new g_fraction_gui_roster_count[MAX_PLAYERS];
new g_fraction_gui_selected[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_fraction_gui_selected_account[MAX_PLAYERS];

new bool:g_fraction_gui_loaded[MAX_PLAYERS];
new bool:g_fraction_gui_loading[MAX_PLAYERS];
new bool:g_fraction_gui_open_after_load[MAX_PLAYERS];
new g_fraction_gui_pending_progress[MAX_PLAYERS];
new g_fraction_gui_tokens[MAX_PLAYERS];
new g_fraction_gui_docs_mask[MAX_PLAYERS];
new bool:g_fraction_gui_test_passed[MAX_PLAYERS];
new bool:g_fraction_gui_test_active[MAX_PLAYERS];
new g_fraction_gui_test_question[MAX_PLAYERS];
new g_fraction_gui_test_correct[MAX_PLAYERS];
new g_fraction_gui_quest_rank[MAX_PLAYERS];
new g_fraction_gui_quest_progress[MAX_PLAYERS];
new g_fraction_gui_completed_tasks[MAX_PLAYERS];

forward FractionGui_OnDataLoaded(playerid);
forward FractionGui_MinuteTick();

stock bool:FractionGui_IsOfficialTeam(teamid)
{
    switch(teamid)
    {
        case TEAM_GOVERNMENT, TEAM_ARMY, TEAM_HOSPITAL, TEAM_RADIO, TEAM_DPS, TEAM_PPS, TEAM_FBI: return true;
    }
    return false;
}

stock FractionGui_Init()
{
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `fraction_gui_progress` (`account_id` INT NOT NULL,`docs_mask` INT NOT NULL DEFAULT 0,`test_passed` TINYINT NOT NULL DEFAULT 0,`quest_rank` INT NOT NULL DEFAULT 0,`quest_progress` INT NOT NULL DEFAULT 0,PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");

    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `fraction_gui_tokens` (`account_id` INT NOT NULL,`tokens` INT NOT NULL DEFAULT 0,PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `fraction_gui_stats` (`account_id` INT NOT NULL,`completed_tasks` INT NOT NULL DEFAULT 0,PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    SetTimer("FractionGui_MinuteTick", 60000, true);
    return 1;
}

stock FractionGui_ResetRuntime(playerid)
{
    g_fraction_gui_loaded[playerid] = false;
    g_fraction_gui_loading[playerid] = false;
    g_fraction_gui_open_after_load[playerid] = false;
    g_fraction_gui_pending_progress[playerid] = 0;
    g_fraction_gui_tokens[playerid] = FRACTION_GUI_DEFAULT_TOKENS;
    g_fraction_gui_docs_mask[playerid] = 0;
    g_fraction_gui_test_passed[playerid] = false;
    g_fraction_gui_test_active[playerid] = false;
    g_fraction_gui_test_question[playerid] = 0;
    g_fraction_gui_test_correct[playerid] = 0;
    g_fraction_gui_quest_rank[playerid] = 0;
    g_fraction_gui_quest_progress[playerid] = 0;
    g_fraction_gui_completed_tasks[playerid] = 0;
    g_fraction_gui_roster_count[playerid] = 0;
    g_fraction_gui_selected[playerid] = INVALID_PLAYER_ID;
    g_fraction_gui_selected_account[playerid] = 0;
    return 1;
}

stock FractionGui_LoadData(playerid, bool:open_after = false)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    if(g_fraction_gui_loaded[playerid])
    {
        if(open_after) FractionGui_OpenInternal(playerid);
        return 1;
    }

    if(open_after) g_fraction_gui_open_after_load[playerid] = true;
    if(g_fraction_gui_loading[playerid]) return 1;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    g_fraction_gui_loading[playerid] = true;

    new query[768];
    mysql_format(mysql, query, sizeof(query), "SELECT COALESCE(p.docs_mask,0) AS docs_mask,COALESCE(p.test_passed,0) AS test_passed,COALESCE(p.quest_rank,0) AS quest_rank,COALESCE(p.quest_progress,0) AS quest_progress,COALESCE(t.tokens,%d) AS tokens,COALESCE(s.completed_tasks,0) AS completed_tasks FROM (SELECT %d AS account_id) a LEFT JOIN fraction_gui_progress p ON p.account_id=a.account_id LEFT JOIN fraction_gui_tokens t ON t.account_id=a.account_id LEFT JOIN fraction_gui_stats s ON s.account_id=a.account_id LIMIT 1", FRACTION_GUI_DEFAULT_TOKENS, account_id);
    mysql_tquery(mysql, query, "FractionGui_OnDataLoaded", "d", playerid);
    return 1;
}

public FractionGui_OnDataLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    g_fraction_gui_loading[playerid] = false;
    g_fraction_gui_loaded[playerid] = true;

    if(cache_num_rows() > 0)
    {
        g_fraction_gui_docs_mask[playerid] = cache_get_field_content_int(0, "docs_mask");
        g_fraction_gui_test_passed[playerid] = bool:cache_get_field_content_int(0, "test_passed");
        g_fraction_gui_quest_rank[playerid] = cache_get_field_content_int(0, "quest_rank");
        g_fraction_gui_quest_progress[playerid] = cache_get_field_content_int(0, "quest_progress");
        g_fraction_gui_tokens[playerid] = cache_get_field_content_int(0, "tokens");
        g_fraction_gui_completed_tasks[playerid] = cache_get_field_content_int(0, "completed_tasks");
    }
    else
    {
        g_fraction_gui_tokens[playerid] = FRACTION_GUI_DEFAULT_TOKENS;
    }

    if(g_fraction_gui_tokens[playerid] < 0) g_fraction_gui_tokens[playerid] = 0;
    if(g_fraction_gui_completed_tasks[playerid] < 0) g_fraction_gui_completed_tasks[playerid] = 0;
    if(g_fraction_gui_quest_progress[playerid] < 0) g_fraction_gui_quest_progress[playerid] = 0;
    if(g_fraction_gui_quest_progress[playerid] > FRACTION_GUI_QUEST_TARGET) g_fraction_gui_quest_progress[playerid] = FRACTION_GUI_QUEST_TARGET;

    new rank = GetPlayerJob(playerid);
    if(rank >= 2 && rank <= 9 && g_fraction_gui_quest_rank[playerid] != rank)
    {
        g_fraction_gui_quest_rank[playerid] = rank;
        g_fraction_gui_quest_progress[playerid] = 0;
    }

    if(g_fraction_gui_pending_progress[playerid] > 0)
    {
        new add = g_fraction_gui_pending_progress[playerid];
        g_fraction_gui_pending_progress[playerid] = 0;
        FractionGui_AddQuestProgress(playerid, add);
    }

    FractionGui_SaveData(playerid);

    if(g_fraction_gui_open_after_load[playerid])
    {
        g_fraction_gui_open_after_load[playerid] = false;
        FractionGui_OpenInternal(playerid);
    }
    return 1;
}

stock FractionGui_SaveData(playerid)
{
    if(!g_fraction_gui_loaded[playerid]) return 0;
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    new query[512];
    mysql_format(mysql, query, sizeof(query), "INSERT INTO fraction_gui_progress (account_id,docs_mask,test_passed,quest_rank,quest_progress) VALUES (%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE docs_mask=VALUES(docs_mask),test_passed=VALUES(test_passed),quest_rank=VALUES(quest_rank),quest_progress=VALUES(quest_progress)", account_id, g_fraction_gui_docs_mask[playerid], g_fraction_gui_test_passed[playerid] ? 1 : 0, g_fraction_gui_quest_rank[playerid], g_fraction_gui_quest_progress[playerid]);
    mysql_tquery(mysql, query);

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO fraction_gui_tokens (account_id,tokens) VALUES (%d,%d) ON DUPLICATE KEY UPDATE tokens=VALUES(tokens)",
        account_id, g_fraction_gui_tokens[playerid]
    );
    mysql_tquery(mysql, query);

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO fraction_gui_stats (account_id,completed_tasks) VALUES (%d,%d) ON DUPLICATE KEY UPDATE completed_tasks=VALUES(completed_tasks)",
        account_id, g_fraction_gui_completed_tasks[playerid]
    );
    mysql_tquery(mysql, query);
    return 1;
}

stock FractionGui_GetTokens(playerid)
{
    if(!g_fraction_gui_loaded[playerid]) return FRACTION_GUI_DEFAULT_TOKENS;
    return g_fraction_gui_tokens[playerid];
}

stock FractionGui_SetTokens(playerid, tokens)
{
    if(tokens < 0) tokens = 0;
    if(!g_fraction_gui_loaded[playerid])
    {
        g_fraction_gui_tokens[playerid] = tokens;
        return 1;
    }
    g_fraction_gui_tokens[playerid] = tokens;
    FractionGui_SaveData(playerid);
    return 1;
}

stock FractionGui_GetDocsReadCount(playerid)
{
    new count = 0;
    for(new i = 0; i < FRACTION_GUI_DOCS_COUNT; i++)
        if(g_fraction_gui_docs_mask[playerid] & (1 << i)) count++;
    return count;
}

stock bool:FractionGui_AllDocsRead(playerid)
{
    return ((g_fraction_gui_docs_mask[playerid] & FRACTION_GUI_DOCS_ALL_MASK) == FRACTION_GUI_DOCS_ALL_MASK);
}

stock FractionGui_GetActivityProgress(playerid)
{
    new rank = GetPlayerJob(playerid);
    if(rank <= 0) return 0;
    if(rank == 1)
    {
        if(g_fraction_gui_test_passed[playerid]) return 25;
        return (FractionGui_GetDocsReadCount(playerid) * 15) / FRACTION_GUI_DOCS_COUNT;
    }
    if(rank >= 10) return 25;

    if(g_fraction_gui_quest_rank[playerid] != rank) return 0;
    return g_fraction_gui_quest_progress[playerid];
}

stock FractionGui_GetQuestDescription(teamid, dest[], size = sizeof(dest))
{
    switch(teamid)
    {
        case TEAM_GOVERNMENT: format(dest, size, "Проведите 25 минут на рабочем дне Правительства.");
        case TEAM_ARMY:       format(dest, size, "Проведите 25 минут на рабочем дне Воинской части.");
        case TEAM_HOSPITAL:   format(dest, size, "Вылечите 25 пациентов на рабочем дне.");
        case TEAM_RADIO:      format(dest, size, "Отредактируйте 25 объявлений на рабочем дне.");
        case TEAM_DPS:        format(dest, size, "Выполните 25 служебных действий: штрафы или задержания.");
        case TEAM_PPS:        format(dest, size, "Задержите 25 нарушителей на рабочем дне.");
        case TEAM_FBI:        format(dest, size, "Задержите 25 нарушителей на рабочем дне.");
        default:              format(dest, size, "Выполните 25 служебных действий.");
    }
    return 1;
}

stock FractionGui_AddQuestProgress(playerid, amount = 1)
{
    if(amount <= 0 || !IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(!FractionGui_IsOfficialTeam(GetPlayerTeamEx(playerid))) return 0;

    new rank = GetPlayerJob(playerid);
    if(rank < 2 || rank >= 10) return 0;
    if(GetPVarInt(playerid, "Form") != 1) return 0;

    if(!g_fraction_gui_loaded[playerid])
    {
        g_fraction_gui_pending_progress[playerid] += amount;
        FractionGui_LoadData(playerid, false);
        return 1;
    }

    if(g_fraction_gui_quest_rank[playerid] != rank)
    {
        g_fraction_gui_quest_rank[playerid] = rank;
        g_fraction_gui_quest_progress[playerid] = 0;
    }

    if(g_fraction_gui_quest_progress[playerid] >= FRACTION_GUI_QUEST_TARGET) return 1;

    g_fraction_gui_quest_progress[playerid] += amount;
    if(g_fraction_gui_quest_progress[playerid] > FRACTION_GUI_QUEST_TARGET)
        g_fraction_gui_quest_progress[playerid] = FRACTION_GUI_QUEST_TARGET;

    if(g_fraction_gui_quest_progress[playerid] == FRACTION_GUI_QUEST_TARGET)
    {
        ShowNotificationLaird(playerid, 3, 6, 0, 0, "Задание организации выполнено", "Откройте /fraction для повышения");
    }

    FractionGui_SaveData(playerid);
    return 1;
}

public FractionGui_MinuteTick()
{
    foreach(new playerid : Player)
    {
        if(!IsPlayerLogged(playerid)) continue;
        new teamid = GetPlayerTeamEx(playerid);
        if(teamid != TEAM_GOVERNMENT && teamid != TEAM_ARMY) continue;
        FractionGui_AddQuestProgress(playerid, 1);
    }
    return 1;
}

stock FractionGui_FillCommon(playerid, Node:json)
{
    new teamid = GetPlayerTeamEx(playerid);
    new tokens = FractionGui_GetTokens(playerid);

    JSON_SetInt(json, "fraction_id", teamid);

    // GUI 46 token counter compatibility. The canonical value is repeated under
    // aliases used by nearby client revisions; unknown keys are simply ignored.
    JSON_SetInt(json, "fraction_tokens", tokens);
    JSON_SetInt(json, "fraction_token", tokens);
    JSON_SetInt(json, "fraction_tokens_value", tokens);
    JSON_SetInt(json, "fraction_token_value", tokens);
    JSON_SetInt(json, "fraction_token_count", tokens);
    JSON_SetInt(json, "fraction_tokens_count", tokens);
    JSON_SetInt(json, "fraction_token_balance", tokens);
    JSON_SetInt(json, "fraction_tokens_balance", tokens);
    JSON_SetInt(json, "fraction_current_tokens", tokens);
    JSON_SetInt(json, "fraction_token_amount", tokens);
    JSON_SetInt(json, "fraction_tokens_amount", tokens);
    JSON_SetInt(json, "fraction_coins", tokens);
    JSON_SetInt(json, "fraction_money", tokens);
    JSON_SetInt(json, "tokens", tokens);
    JSON_SetInt(json, "token", tokens);

    // The tablet shell uses compact currency fields in the neighbouring GUI systems.
    // Keep these alongside the descriptive aliases so the token counter is populated
    // on both old and newer GUI 46 client revisions.
    JSON_SetInt(json, "m", tokens);
    JSON_SetInt(json, "bc", GetPlayerDonateRub(playerid));

    JSON_SetInt(json, "fraction_add_tokens_price", FRACTION_GUI_TOKEN_PRICE);
    JSON_SetInt(json, "fraction_add_tokens_bc_price", FRACTION_GUI_TOKEN_PRICE);
    JSON_SetInt(json, "fraction_add_tokens_count", FRACTION_GUI_TOKEN_PACK);

    new rank = GetPlayerJob(playerid);
    if(rank < 1 || rank > 10) rank = 1;
    JSON_SetInt(json, "fraction_rank", rank);
    JSON_SetInt(json, "fraction_current_rank", rank);
    JSON_SetString(json, "fraction_rank_name", GetTeamRankName(teamid, rank));
    JSON_SetInt(json, "fraction_can_control", (GetPlayerJob(playerid) >= 9) ? 1 : 0);
    return 1;
}

stock FractionGui_FillRanks(playerid, Node:json)
{
    new playerRank = GetPlayerJob(playerid);
    if(playerRank < 1 || playerRank > 10) playerRank = 1;

    JSON_SetInt(json, "fraction_id", GetPlayerTeamEx(playerid));

    new st[10], pr[10];
    new current_progress = FractionGui_GetActivityProgress(playerid);

    for(new i = 0; i < 10; i++)
    {
        new rank = i + 1;
        if(rank < playerRank)
        {
            st[i] = 4;
            pr[i] = 25;
        }
        else if(rank == playerRank)
        {
            st[i] = 1;
            pr[i] = current_progress;
        }
        else if(rank == playerRank + 1)
        {
            st[i] = 2;
            pr[i] = 0;
        }
        else
        {
            st[i] = 0;
            pr[i] = 0;
        }
    }

    new Node:s1 = JSON_Int(st[0]), Node:s2 = JSON_Int(st[1]), Node:s3 = JSON_Int(st[2]), Node:s4 = JSON_Int(st[3]), Node:s5 = JSON_Int(st[4]);
    new Node:s6 = JSON_Int(st[5]), Node:s7 = JSON_Int(st[6]), Node:s8 = JSON_Int(st[7]), Node:s9 = JSON_Int(st[8]), Node:s10 = JSON_Int(st[9]);
    new Node:status_array = JSON_Array(s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);

    new Node:p1 = JSON_Int(pr[0]), Node:p2 = JSON_Int(pr[1]), Node:p3 = JSON_Int(pr[2]), Node:p4 = JSON_Int(pr[3]), Node:p5 = JSON_Int(pr[4]);
    new Node:p6 = JSON_Int(pr[5]), Node:p7 = JSON_Int(pr[6]), Node:p8 = JSON_Int(pr[7]), Node:p9 = JSON_Int(pr[8]), Node:p10 = JSON_Int(pr[9]);
    new Node:progress_array = JSON_Array(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10);

    JSON_SetArray(json, "rank_status", status_array);
    JSON_SetArray(json, "rank_progress", progress_array);
    JSON_SetInt(json, "current_rank", playerRank);
    JSON_SetInt(json, "fraction_progress", current_progress);
    JSON_SetInt(json, "fraction_progress_max", FRACTION_GUI_QUEST_TARGET);

    new Node:rank_names_json = JSON_Array();
    for(new r = 1; r <= 10; r++)
        rank_names_json = JSON_Append(rank_names_json, JSON_Array(JSON_String(GetTeamRankName(GetPlayerTeamEx(playerid), r))));
    JSON_SetArray(json, "fraction_rank_names", rank_names_json);
    JSON_SetArray(json, "rank_names", rank_names_json);

    JSON_Cleanup(rank_names_json);
    JSON_Cleanup(s1); JSON_Cleanup(s2); JSON_Cleanup(s3); JSON_Cleanup(s4); JSON_Cleanup(s5);
    JSON_Cleanup(s6); JSON_Cleanup(s7); JSON_Cleanup(s8); JSON_Cleanup(s9); JSON_Cleanup(s10);
    JSON_Cleanup(p1); JSON_Cleanup(p2); JSON_Cleanup(p3); JSON_Cleanup(p4); JSON_Cleanup(p5);
    JSON_Cleanup(p6); JSON_Cleanup(p7); JSON_Cleanup(p8); JSON_Cleanup(p9); JSON_Cleanup(p10);
    JSON_Cleanup(status_array); JSON_Cleanup(progress_array);
    return 1;
}

stock FractionGui_OpenInternal(playerid)
{
    new teamid = GetPlayerTeamEx(playerid);
    if(!FractionGui_IsOfficialTeam(teamid)) return 0;

    new rank = GetPlayerJob(playerid);
    if(rank < 1 || rank > 10) rank = 1;

    if(rank >= 2 && rank <= 9 && g_fraction_gui_quest_rank[playerid] != rank)
    {
        g_fraction_gui_quest_rank[playerid] = rank;
        g_fraction_gui_quest_progress[playerid] = 0;
        FractionGui_SaveData(playerid);
    }

    new Node:json = JSON_Object();
    JSON_ToggleGC(json, false);
    JSON_SetInt(json, "page", 1);
    FractionGui_FillRanks(playerid, json);
    FractionGui_FillCommon(playerid, json);
    ShowPlayerGUI(playerid, 46, json);
    JSON_Cleanup(json);
    return 1;
}

stock FractionGui_Open(playerid)
{
    new teamid = GetPlayerTeamEx(playerid);
    if(!FractionGui_IsOfficialTeam(teamid))
    {
        if(teamid == TEAM_OPG_ARZAMASKAYA || teamid == TEAM_OPG_BATYREVSKAYA || teamid == TEAM_OPG_LYTKARINSKAYA)
            SendClientMessage(playerid, 0xCECECEFF, "Для криминальных организаций используется отдельное меню.");
        else
            SendClientMessage(playerid, 0xCECECEFF, "Вы не состоите в государственной организации.");
        return 1;
    }

    if(!g_fraction_gui_loaded[playerid])
        return FractionGui_LoadData(playerid, true);

    return FractionGui_OpenInternal(playerid);
}

stock FractionGui_FindOnlineByAccount(account_id)
{
    if(account_id <= 0) return INVALID_PLAYER_ID;
    foreach(new targetid : Player)
    {
        if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) continue;
        if(GetPlayerAccountID(targetid) == account_id) return targetid;
    }
    return INVALID_PLAYER_ID;
}

stock FractionGui_BuildRoster(playerid, Node:response, const search[] = "")
{
    new search_value[64];
    format(search_value, sizeof(search_value), "%s", search);

    new teamid = GetPlayerTeamEx(playerid);
    g_fraction_gui_roster_count[playerid] = 0;
    g_fraction_gui_selected[playerid] = INVALID_PLAYER_ID;
    g_fraction_gui_selected_account[playerid] = 0;

    new Node:names = JSON_Array();
    new Node:rank_status = JSON_Array();
    new Node:ranks_only = JSON_Array();
    new Node:levels = JSON_Array();
    new Node:warns = JSON_Array();
    new Node:online_list = JSON_Array();
    new Node:tasks = JSON_Array();

    new query[512];
    // Do not make the core membership list depend on the optional stats table.
    // If that table is missing/not ready, the old LEFT JOIN made the whole list empty.
    mysql_format(mysql, query, sizeof(query),
        "SELECT id,name,level,job,owarn FROM accounts WHERE team=%d AND job BETWEEN 1 AND 10 ORDER BY job DESC,name ASC LIMIT %d",
        teamid, FRACTION_GUI_MAX_ROSTER);

    new Cache:result = mysql_query(mysql, query, true);
    new rows = cache_num_rows();
    new online_count = 0;

    for(new row = 0; row < rows && g_fraction_gui_roster_count[playerid] < FRACTION_GUI_MAX_ROSTER; row++)
    {
        new account_id = cache_get_field_content_int(row, "id");
        new rank = cache_get_field_content_int(row, "job");
        new level = cache_get_field_content_int(row, "level");
        new warn_count = cache_get_field_content_int(row, "owarn");
        new completed_tasks = 0;
        new nickname[MAX_PLAYER_NAME + 1];
        cache_get_field_content(row, "name", nickname, mysql, sizeof(nickname));

        if(account_id <= 0 || rank < 1 || rank > 10 || !strlen(nickname)) continue;
        if(strlen(search_value) && strfind(nickname, search_value, true) == -1) continue;

        new targetid = FractionGui_FindOnlineByAccount(account_id);
        new online = (targetid != INVALID_PLAYER_ID) ? 1 : 0;
        if(online)
        {
            rank = GetPlayerJob(targetid);
            level = GetPlayerLevel(targetid);
            warn_count = GetPlayerData(targetid, P_OWARN);
            online_count++;
        }

        new index = g_fraction_gui_roster_count[playerid];
        g_fraction_gui_roster_account[playerid][index] = account_id;
        g_fraction_gui_roster[playerid][index] = targetid;
        g_fraction_gui_roster_count[playerid]++;

        names = JSON_Append(names, JSON_Array(JSON_String(nickname)));

        // Important: GUI 46 reads rs as repeating rank/online pairs.
        rank_status = JSON_Append(rank_status, JSON_Array(JSON_Int(rank)));
        rank_status = JSON_Append(rank_status, JSON_Array(JSON_Int(online)));
        ranks_only = JSON_Append(ranks_only, JSON_Array(JSON_Int(rank)));

        levels = JSON_Append(levels, JSON_Array(JSON_Int(level)));
        warns = JSON_Append(warns, JSON_Array(JSON_Int(warn_count)));
        online_list = JSON_Append(online_list, JSON_Array(JSON_Int(online)));
        tasks = JSON_Append(tasks, JSON_Array(JSON_Int(completed_tasks)));
    }
    cache_delete(result);

    // Always merge currently online faction members into the SQL result.
    // This guarantees that at least the player himself is visible even if the
    // account query is temporarily unavailable or an account row is stale.
    foreach(new targetid : Player)
    {
        if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) continue;
        if(GetPlayerTeamEx(targetid) != teamid) continue;
        if(strlen(search_value) && strfind(GetPlayerNameEx(targetid), search_value, true) == -1) continue;

        new target_account = GetPlayerAccountID(targetid);
        new bool:already_added = false;
        for(new ri = 0; ri < g_fraction_gui_roster_count[playerid]; ri++)
        {
            if(g_fraction_gui_roster_account[playerid][ri] == target_account)
            {
                already_added = true;
                break;
            }
        }
        if(already_added) continue;
        if(g_fraction_gui_roster_count[playerid] >= FRACTION_GUI_MAX_ROSTER) break;

        new index = g_fraction_gui_roster_count[playerid];
        g_fraction_gui_roster_account[playerid][index] = target_account;
        g_fraction_gui_roster[playerid][index] = targetid;
        g_fraction_gui_roster_count[playerid]++;
        online_count++;

        names = JSON_Append(names, JSON_Array(JSON_String(GetPlayerNameEx(targetid))));
        rank_status = JSON_Append(rank_status, JSON_Array(JSON_Int(GetPlayerJob(targetid))));
        rank_status = JSON_Append(rank_status, JSON_Array(JSON_Int(1)));
        ranks_only = JSON_Append(ranks_only, JSON_Array(JSON_Int(GetPlayerJob(targetid))));
        levels = JSON_Append(levels, JSON_Array(JSON_Int(GetPlayerLevel(targetid))));
        warns = JSON_Append(warns, JSON_Array(JSON_Int(GetPlayerData(targetid, P_OWARN))));
        online_list = JSON_Append(online_list, JSON_Array(JSON_Int(1)));
        tasks = JSON_Append(tasks, JSON_Array(JSON_Int(0)));
    }

    printf("[FRACTION][ROSTER] player=%d team=%d sql_rows=%d sent=%d online=%d", playerid, teamid, rows, g_fraction_gui_roster_count[playerid], online_count);

    // GUI 46 has its own page/button protocol. Do not mix it with GUI 45
    // family t/id/s packets: the live client silently drops the mixed payload.
    // Keep the exact roster shape the original GUI 46 expects: N names and N ranks.
    JSON_SetInt(response, "page", 9);
    JSON_SetInt(response, "type", 1);
    JSON_SetInt(response, "fraction_control_t_count", g_fraction_gui_roster_count[playerid]);
    JSON_SetInt(response, "fraction_control_members_count", g_fraction_gui_roster_count[playerid]);
    JSON_SetInt(response, "fraction_control_online_count", online_count);
    JSON_SetString(response, "fraction_control_t_search", search_value);
    JSON_SetString(response, "fraction_control_search", search_value);
    JSON_SetArray(response, "fraction_control_t_list_of_nicknames", names);
    JSON_SetArray(response, "rs", ranks_only);
    JSON_SetArray(response, "fraction_control_t_list_of_levels", levels);
    JSON_SetArray(response, "fraction_control_t_list_of_reprimands", warns);
    JSON_SetArray(response, "fraction_control_t_list_of_online", online_list);
    JSON_SetArray(response, "fraction_control_t_list_of_tasks", tasks);

    if(g_fraction_gui_roster_count[playerid] > 0)
        printf("[FRACTION][ROSTER_PAYLOAD] player=%d first_account=%d first_target=%d count=%d", playerid, g_fraction_gui_roster_account[playerid][0], g_fraction_gui_roster[playerid][0], g_fraction_gui_roster_count[playerid]);

    new roster_debug[2048];
    JSON_Stringify(response, roster_debug, sizeof(roster_debug));
    printf("[FRACTION][ROSTER_JSON] %s", roster_debug);

    // rank_status belongs to the old GUI45 experiment and is no longer attached.
    JSON_Cleanup(rank_status);

    // Do NOT JSON_Cleanup() these child arrays here. The response object owns
    // them until OnPacketIncoming() is called. Cleaning them here produced an
    // apparently valid membership page with an empty left list.
    return 1;
}

stock bool:FractionGui_GetRosterSearch(Node:json, dest[], size = sizeof(dest))
{
    dest[0] = EOS;
    if(JSON_GetString(json, "fraction_control_t_search", dest, size)) return true;
    if(JSON_GetString(json, "fraction_control_search", dest, size)) return true;
    if(JSON_GetString(json, "search", dest, size)) return true;
    if(JSON_GetString(json, "search_text", dest, size)) return true;
    if(JSON_GetString(json, "query", dest, size)) return true;
    return false;
}

stock bool:FractionGui_HasExplicitRosterSelection(Node:json)
{
    new value;
    new tmp[MAX_PLAYER_NAME + 1];
    if(JSON_GetInt(json, "fraction_control_player_account_id", value)) return true;
    if(JSON_GetInt(json, "account_id", value)) return true;
    if(JSON_GetInt(json, "uid", value)) return true;
    if(JSON_GetInt(json, "fraction_control_player_id", value)) return true;
    if(JSON_GetInt(json, "player_id", value)) return true;
    if(JSON_GetInt(json, "pid", value)) return true;
    if(JSON_GetInt(json, "id", value)) return true;
    if(JSON_GetInt(json, "fraction_control_t_selected", value)) return true;
    if(JSON_GetInt(json, "fraction_control_t_list_selected", value)) return true;
    if(JSON_GetInt(json, "fraction_control_t_selected_index", value)) return true;
    if(JSON_GetInt(json, "fraction_control_t_selected_player", value)) return true;
    if(JSON_GetInt(json, "fraction_control_t_player_index", value)) return true;
    if(JSON_GetInt(json, "selected", value)) return true;
    if(JSON_GetInt(json, "index", value)) return true;
    if(JSON_GetInt(json, "listitem", value)) return true;
    if(JSON_GetInt(json, "item", value)) return true;
    if(JSON_GetString(json, "fraction_control_player_nickname", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "fraction_control_t_nickname", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "fraction_control_t_selected_nickname", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "fraction_control_t_player_nickname", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "n", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "nickname", tmp, sizeof(tmp))) return true;
    if(JSON_GetString(json, "name", tmp, sizeof(tmp))) return true;
    return false;
}

stock FractionGui_FindRosterAccount(playerid, Node:json, bool:allow_saved = false)
{
    new value;
    new teamid = GetPlayerTeamEx(playerid);

    if(JSON_GetInt(json, "fraction_control_player_account_id", value) ||
       JSON_GetInt(json, "account_id", value) ||
       JSON_GetInt(json, "uid", value))
    {
        for(new i = 0; i < g_fraction_gui_roster_count[playerid]; i++)
            if(g_fraction_gui_roster_account[playerid][i] == value) return value;
    }

    if(JSON_GetInt(json, "fraction_control_player_id", value) ||
       JSON_GetInt(json, "player_id", value) ||
       JSON_GetInt(json, "pid", value) ||
       JSON_GetInt(json, "id", value))
    {
        for(new i = 0; i < g_fraction_gui_roster_count[playerid]; i++)
            if(g_fraction_gui_roster_account[playerid][i] == value) return value;

        if(IsPlayerConnected(value) && GetPlayerTeamEx(value) == teamid)
            return GetPlayerAccountID(value);
    }

    if(JSON_GetInt(json, "fraction_control_t_selected", value) ||
       JSON_GetInt(json, "fraction_control_t_list_selected", value) ||
       JSON_GetInt(json, "fraction_control_t_selected_index", value) ||
       JSON_GetInt(json, "fraction_control_t_selected_player", value) ||
       JSON_GetInt(json, "fraction_control_t_player_index", value) ||
       JSON_GetInt(json, "selected", value) ||
       JSON_GetInt(json, "index", value) ||
       JSON_GetInt(json, "listitem", value) ||
       JSON_GetInt(json, "item", value))
    {
        if(value >= 0 && value < g_fraction_gui_roster_count[playerid])
            return g_fraction_gui_roster_account[playerid][value];
        if(value >= 1 && value <= g_fraction_gui_roster_count[playerid])
            return g_fraction_gui_roster_account[playerid][value - 1];
    }

    new nickname[MAX_PLAYER_NAME + 1];
    if(JSON_GetString(json, "fraction_control_player_nickname", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "fraction_control_t_nickname", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "fraction_control_t_selected_nickname", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "fraction_control_t_player_nickname", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "n", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "nickname", nickname, sizeof(nickname)) ||
       JSON_GetString(json, "name", nickname, sizeof(nickname)))
    {
        new query[192];
        mysql_format(mysql, query, sizeof(query), "SELECT id FROM accounts WHERE team=%d AND name='%e' LIMIT 1", teamid, nickname);
        new Cache:cache = mysql_query(mysql, query, true);
        if(cache_num_rows()) value = cache_get_field_content_int(0, "id");
        else value = 0;
        cache_delete(cache);
        if(value > 0) return value;
    }

    if(allow_saved && g_fraction_gui_selected_account[playerid] > 0)
        return g_fraction_gui_selected_account[playerid];

    return 0;
}

stock bool:FractionGui_GetAccountFactionData(account_id, &teamid, &rank, &warn_count, &sex)
{
    if(account_id <= 0) return false;
    new query[192];
    mysql_format(mysql, query, sizeof(query), "SELECT team,job,owarn,sex FROM accounts WHERE id=%d LIMIT 1", account_id);
    new Cache:cache = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(cache);
        return false;
    }

    teamid = cache_get_field_content_int(0, "team");
    rank = cache_get_field_content_int(0, "job");
    warn_count = cache_get_field_content_int(0, "owarn");
    sex = cache_get_field_content_int(0, "sex");
    cache_delete(cache);
    return true;
}

stock bool:FractionGui_CanManageAccount(playerid, account_id, target_team, target_rank)
{
    if(account_id <= 0 || target_team != GetPlayerTeamEx(playerid)) return false;
    if(GetPlayerJob(playerid) < 9) return false;
    if(account_id == GetPlayerAccountID(playerid)) return false;
    if(target_rank >= GetPlayerJob(playerid)) return false;
    return true;
}

stock FractionGui_FillPlayerCard(playerid, account_id, Node:response)
{
    if(account_id <= 0) return 0;

    new query[512];
    mysql_format(mysql, query, sizeof(query),
        "SELECT id,name,level,team,job,owarn,phone,skin,org_skin FROM accounts WHERE id=%d AND team=%d LIMIT 1",
        account_id, GetPlayerTeamEx(playerid));
    new Cache:cache = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(cache);
        return 0;
    }

    new nickname[MAX_PLAYER_NAME + 1];
    cache_get_field_content(0, "name", nickname, mysql, sizeof(nickname));
    new teamid = cache_get_field_content_int(0, "team");
    new rank = cache_get_field_content_int(0, "job");
    new level = cache_get_field_content_int(0, "level");
    new warn_count = cache_get_field_content_int(0, "owarn");
    new phone_value = cache_get_field_content_int(0, "phone");
    new skin = cache_get_field_content_int(0, "org_skin");
    if(skin <= 0) skin = cache_get_field_content_int(0, "skin");
    new completed_tasks = 0;
    cache_delete(cache);

    if(rank < 1 || rank > 10) rank = 1;
    new targetid = FractionGui_FindOnlineByAccount(account_id);
    new online = (targetid != INVALID_PLAYER_ID) ? 1 : 0;
    if(online)
    {
        teamid = GetPlayerTeamEx(targetid);
        rank = GetPlayerJob(targetid);
        level = GetPlayerLevel(targetid);
        warn_count = GetPlayerData(targetid, P_OWARN);
        phone_value = GetPlayerPhone(targetid);
        skin = GetPlayerSkin(targetid);
        if(g_fraction_gui_loaded[targetid]) completed_tasks = g_fraction_gui_completed_tasks[targetid];
    }

    g_fraction_gui_selected_account[playerid] = account_id;
    g_fraction_gui_selected[playerid] = targetid;

    new phone[24];
    if(phone_value > 0) format(phone, sizeof(phone), "%d", phone_value);
    else format(phone, sizeof(phone), "\xcd\xe5\xf2");

    new can_manage = FractionGui_CanManageAccount(playerid, account_id, teamid, rank) ? 1 : 0;

    JSON_SetInt(response, "page", 9);
    JSON_SetInt(response, "type", 2);
    JSON_SetInt(response, "fraction_control_player_id", online ? targetid : -1);
    JSON_SetInt(response, "fraction_control_player_account_id", account_id);
    JSON_SetInt(response, "fraction_control_player_server_id", online ? targetid : -1);
    JSON_SetInt(response, "account_id", account_id);
    JSON_SetInt(response, "pi", online ? targetid : -1);
    JSON_SetString(response, "fraction_control_player_nickname", nickname);
    JSON_SetInt(response, "fraction_control_player_skin_id", skin);
    JSON_SetInt(response, "fraction_control_player_level", level);
    JSON_SetInt(response, "level", level);
    JSON_SetString(response, "fraction_control_player_rank_name", GetTeamRankName(teamid, rank));
    JSON_SetString(response, "fraction_control_player_position", GetTeamRankName(teamid, rank));
    JSON_SetInt(response, "fraction_control_player_rank", rank);
    JSON_SetInt(response, "fraction_control_player_reprimand", warn_count);
    JSON_SetInt(response, "fraction_control_player_online", online);
    JSON_SetInt(response, "fraction_control_player_tasks", completed_tasks);
    JSON_SetInt(response, "fraction_control_player_completed_tasks", completed_tasks);
    JSON_SetInt(response, "fraction_control_player_phone", phone_value);
    JSON_SetInt(response, "fraction_control_player_reprimand_max", 3);
    JSON_SetInt(response, "fraction_control_can_manage", can_manage);
    JSON_SetInt(response, "fraction_control_can_leave", account_id == GetPlayerAccountID(playerid) ? 1 : 0);
    JSON_SetString(response, "phone", phone);

    JSON_SetString(response, "nickname", nickname);
    JSON_SetString(response, "name", nickname);
    JSON_SetInt(response, "skin", skin);
    JSON_SetInt(response, "rank", rank);
    JSON_SetInt(response, "reprimand", warn_count);
    JSON_SetInt(response, "tasks", completed_tasks);
    JSON_SetInt(response, "online", online);

    JSON_SetInt(response, "sk", skin);
    JSON_SetInt(response, "rb", level);
    JSON_SetInt(response, "rv", warn_count);
    JSON_SetInt(response, "rp", phone_value);
    // GUI 46 membership card shares the compact dossier layout with GUI 45;
    // that layout expects the numeric `m` field to exist as well.
    JSON_SetInt(response, "m", 0);
    JSON_SetInt(response, "on", online);
    JSON_SetString(response, "rn", GetTeamRankName(teamid, rank));
    new card_debug[2048];
    JSON_Stringify(response, card_debug, sizeof(card_debug));
    printf("[FRACTION][CARD] viewer=%d account=%d name=%s rank=%d level=%d skin=%d warn=%d phone=%d online=%d", playerid, account_id, nickname, rank, level, skin, warn_count, phone_value, online);
    printf("[FRACTION][CARD_JSON] %s", card_debug);
    return 1;
}

stock FractionGui_ChangeRank(playerid, account_id, new_rank, Node:response)
{
    new teamid, target_rank, warn_count, sex;
    if(!FractionGui_GetAccountFactionData(account_id, teamid, target_rank, warn_count, sex) ||
       !FractionGui_CanManageAccount(playerid, account_id, teamid, target_rank))
    {
        SendClientMessage(playerid, 0xCECECEFF, "\xcd\xe5\xe4\xee\xf1\xf2\xe0\xf2\xee\xf7\xed\xee \xef\xf0\xe0\xe2 \xe4\xeb\xff \xf3\xef\xf0\xe0\xe2\xeb\xe5\xed\xe8\xff \xfd\xf2\xe8\xec \xf1\xee\xf2\xf0\xf3\xe4\xed\xe8\xea\xee\xec.");
        return 0;
    }
    if(new_rank < 1 || new_rank > 10) return 0;
    if(new_rank >= GetPlayerJob(playerid))
    {
        SendClientMessage(playerid, 0xCECECEFF, "\xcd\xe5\xeb\xfc\xe7\xff \xed\xe0\xe7\xed\xe0\xf7\xe8\xf2\xfc \xf0\xe0\xed\xe3 \xed\xe5 \xed\xe8\xe6\xe5 \xf1\xe2\xee\xe5\xe3\xee.");
        return 0;
    }

    new org_skin;
    if(sex) org_skin = g_organization[teamid][O_WOMEN_SKIN];
    else org_skin = g_organization[teamid][O_SKINS][new_rank - 1];

    new query[256];
    mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET job=%d,org_skin=%d WHERE id=%d AND team=%d LIMIT 1", new_rank, org_skin, account_id, teamid);
    mysql_tquery(mysql, query);

    new targetid = FractionGui_FindOnlineByAccount(account_id);
    if(targetid != INVALID_PLAYER_ID)
    {
        SetPlayerData(targetid, P_JOB, new_rank);
        SetPlayerData(targetid, P_OSKIN, org_skin);
        if(GetPVarInt(targetid, "Form") == 1 && org_skin > 0) SetPlayerSkin(targetid, org_skin);

        new msg[160];
        format(msg, sizeof(msg), "\xc2\xe0\xf8 \xf0\xe0\xed\xe3 \xe2 \xee\xf0\xe3\xe0\xed\xe8\xe7\xe0\xf6\xe8\xe8 \xe8\xe7\xec\xe5\xed\xb8\xed \xed\xe0 %d (%s).", new_rank, GetTeamRankName(teamid, new_rank));
        SendClientMessage(targetid, 0x3399FFFF, msg);
    }

    JSON_SetInt(response, "page", 9);
    JSON_SetInt(response, "type", 3);
    JSON_SetInt(response, "new_rank", new_rank);
    JSON_SetInt(response, "fraction_control_player_rank", new_rank);
    JSON_SetString(response, "fraction_control_player_new_position", GetTeamRankName(teamid, new_rank));
    JSON_SetString(response, "fraction_control_player_rank_name", GetTeamRankName(teamid, new_rank));
    return 1;
}

stock FractionGui_ChangeWarn(playerid, account_id, new_warn, Node:response)
{
    new teamid, target_rank, current_warn, sex;
    if(!FractionGui_GetAccountFactionData(account_id, teamid, target_rank, current_warn, sex) ||
       !FractionGui_CanManageAccount(playerid, account_id, teamid, target_rank))
    {
        SendClientMessage(playerid, 0xCECECEFF, "\xcd\xe5\xe4\xee\xf1\xf2\xe0\xf2\xee\xf7\xed\xee \xef\xf0\xe0\xe2 \xe4\xeb\xff \xf3\xef\xf0\xe0\xe2\xeb\xe5\xed\xe8\xff \xfd\xf2\xe8\xec \xf1\xee\xf2\xf0\xf3\xe4\xed\xe8\xea\xee\xec.");
        return 0;
    }

    if(new_warn < 0) new_warn = 0;
    if(new_warn > 3) new_warn = 3;

    new targetid = FractionGui_FindOnlineByAccount(account_id);
    new query[256];
    if(new_warn >= 3)
    {
        mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET owarn=0,team=0,job=0,org_skin=0 WHERE id=%d AND team=%d LIMIT 1", account_id, teamid);
        mysql_tquery(mysql, query);

        if(targetid != INVALID_PLAYER_ID)
        {
            SetPlayerData(targetid, P_OWARN, 0);
            SetPlayerData(targetid, P_OSKIN, 0);
            SetPlayerData(targetid, P_TEAM, TEAM_NONE);
            SetPlayerData(targetid, P_JOB, 0);
            SetPVarInt(targetid, "Form", 0);
            ResetSkin(targetid);
            SendClientMessage(targetid, 0xFF5533FF, "\xc2\xfb \xe8\xf1\xea\xeb\xfe\xf7\xe5\xed\xfb \xe8\xe7 \xee\xf0\xe3\xe0\xed\xe8\xe7\xe0\xf6\xe8\xe8: \xef\xee\xeb\xf3\xf7\xe5\xed\xee 3 \xe2\xfb\xe3\xee\xe2\xee\xf0\xe0.");
        }

        g_fraction_gui_selected_account[playerid] = 0;
        g_fraction_gui_selected[playerid] = INVALID_PLAYER_ID;
        return FractionGui_BuildRoster(playerid, response);
    }

    mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET owarn=%d WHERE id=%d AND team=%d LIMIT 1", new_warn, account_id, teamid);
    mysql_tquery(mysql, query);
    if(targetid != INVALID_PLAYER_ID) SetPlayerData(targetid, P_OWARN, new_warn);

    JSON_SetInt(response, "page", 9);
    JSON_SetInt(response, "type", 4);
    JSON_SetInt(response, "fraction_control_player_reprimand", new_warn);
    JSON_SetInt(response, "fraction_control_player_new_reprimand", new_warn);
    return 1;
}

stock FractionGui_FireMember(playerid, account_id, Node:response)
{
    if(account_id <= 0) return 0;

    new teamid, target_rank, warn_count, sex;
    if(!FractionGui_GetAccountFactionData(account_id, teamid, target_rank, warn_count, sex)) return 0;

    new bool:self_leave = (account_id == GetPlayerAccountID(playerid));
    if(!self_leave && !FractionGui_CanManageAccount(playerid, account_id, teamid, target_rank))
    {
        SendClientMessage(playerid, 0xCECECEFF, "\xcd\xe5\xe4\xee\xf1\xf2\xe0\xf2\xee\xf7\xed\xee \xef\xf0\xe0\xe2 \xe4\xeb\xff \xf3\xe2\xee\xeb\xfc\xed\xe5\xed\xe8\xff \xfd\xf2\xee\xe3\xee \xf1\xee\xf2\xf0\xf3\xe4\xed\xe8\xea\xe0.");
        return 0;
    }

    new targetid = FractionGui_FindOnlineByAccount(account_id);
    if(targetid != INVALID_PLAYER_ID)
    {
        if(self_leave) UnInvite(targetid, targetid);
        else UnInvite(playerid, targetid);
        SetPlayerData(targetid, P_OWARN, 0);
    }
    else
    {
        new query[224];
        mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET team=0,job=0,org_skin=0,owarn=0 WHERE id=%d AND team=%d LIMIT 1", account_id, teamid);
        mysql_tquery(mysql, query);
    }

    g_fraction_gui_selected_account[playerid] = 0;
    g_fraction_gui_selected[playerid] = INVALID_PLAYER_ID;

    if(self_leave)
    {
        HidePlayerGUI(playerid, 46);
        return 1;
    }
    return FractionGui_BuildRoster(playerid, response);
}

stock FractionGui_FillDocuments(playerid, Node:response)
{
    JSON_SetInt(response, "page", 4);

    new st[FRACTION_GUI_DOCS_COUNT];
    for(new i = 0; i < FRACTION_GUI_DOCS_COUNT; i++)
        st[i] = (g_fraction_gui_docs_mask[playerid] & (1 << i)) ? 1 : 0;

    new Node:d1 = JSON_Int(st[0]);
    new Node:d2 = JSON_Int(st[1]);
    new Node:d3 = JSON_Int(st[2]);
    new Node:d4 = JSON_Int(st[3]);
    new Node:docs = JSON_Array(d1, d2, d3, d4);
    JSON_SetArray(response, "fraction_documents_button_acquainted", docs);

    JSON_Cleanup(d1); JSON_Cleanup(d2); JSON_Cleanup(d3); JSON_Cleanup(d4); JSON_Cleanup(docs);
    return 1;
}

stock FractionGui_GetDocumentIndex(playerid, Node:json)
{
    new idx;
    if(JSON_GetInt(json, "fraction_documents_selected", idx) ||
       JSON_GetInt(json, "fraction_documents_index", idx) ||
       JSON_GetInt(json, "document", idx) ||
       JSON_GetInt(json, "doc", idx) ||
       JSON_GetInt(json, "selected", idx) ||
       JSON_GetInt(json, "index", idx) ||
       JSON_GetInt(json, "listitem", idx))
    {
        if(idx >= 0 && idx < FRACTION_GUI_DOCS_COUNT) return idx;
        if(idx >= 1 && idx <= FRACTION_GUI_DOCS_COUNT) return idx - 1;
    }

    for(new i = 0; i < FRACTION_GUI_DOCS_COUNT; i++)
        if(!(g_fraction_gui_docs_mask[playerid] & (1 << i))) return i;
    return FRACTION_GUI_DOCS_COUNT - 1;
}

stock FractionGui_StartTest(playerid, Node:response)
{
    if(GetPlayerJob(playerid) != 1)
    {
        JSON_SetInt(response, "page", 1);
        FractionGui_FillRanks(playerid, response);
        return 1;
    }

    if(!FractionGui_AllDocsRead(playerid))
    {
        ShowNotificationLaird(playerid, 2, 6, 0, 0, "Сначала ознакомьтесь со всеми документами", " ");
        return FractionGui_FillDocuments(playerid, response);
    }

    g_fraction_gui_test_active[playerid] = true;
    g_fraction_gui_test_question[playerid] = 0;
    g_fraction_gui_test_correct[playerid] = 0;

    JSON_SetInt(response, "page", 5);
    JSON_SetInt(response, "fraction_testing_question", 1);
    JSON_SetInt(response, "fraction_testing_current_question", 1);
    JSON_SetInt(response, "fraction_testing_questions_total", FRACTION_GUI_TEST_QUESTIONS);
    return 1;
}

stock FractionGui_HandleTestAnswer(playerid, Node:json, Node:response)
{
    if(GetPlayerJob(playerid) != 1)
    {
        JSON_SetInt(response, "page", 1);
        FractionGui_FillRanks(playerid, response);
        return 1;
    }

    if(!g_fraction_gui_test_active[playerid])
    {
        return FractionGui_StartTest(playerid, response);
    }

    new chosen_answer = -1;
    if(!JSON_GetInt(json, "fraction_testing_chosen_answer", chosen_answer))
    {
        // Navigation/no-answer packets must not finish the test with 0/0.
        new q = g_fraction_gui_test_question[playerid] + 1;
        JSON_SetInt(response, "page", 5);
        JSON_SetInt(response, "fraction_testing_question", q);
        JSON_SetInt(response, "fraction_testing_current_question", q);
        JSON_SetInt(response, "fraction_testing_questions_total", FRACTION_GUI_TEST_QUESTIONS);
        JSON_SetInt(response, "fraction_testing_result", g_fraction_gui_test_correct[playerid]);
        return 1;
    }

    // This client keeps the actual question/answer texts on the client side and sends
    // only the selected option. Count a submitted answer as a completed question so the
    // complete 10-question flow works instead of producing an instant 0/0 result.
    if(chosen_answer >= 0) g_fraction_gui_test_correct[playerid]++;

    g_fraction_gui_test_question[playerid]++;

    if(g_fraction_gui_test_question[playerid] < FRACTION_GUI_TEST_QUESTIONS)
    {
        new q = g_fraction_gui_test_question[playerid] + 1;
        JSON_SetInt(response, "page", 5);
        JSON_SetInt(response, "fraction_testing_question", q);
        JSON_SetInt(response, "fraction_testing_current_question", q);
        JSON_SetInt(response, "fraction_testing_questions_total", FRACTION_GUI_TEST_QUESTIONS);
        JSON_SetInt(response, "fraction_testing_result", g_fraction_gui_test_correct[playerid]);
        return 1;
    }

    g_fraction_gui_test_active[playerid] = false;
    new bool:passed = (g_fraction_gui_test_correct[playerid] >= FRACTION_GUI_TEST_PASS);
    g_fraction_gui_test_passed[playerid] = passed;
    FractionGui_SaveData(playerid);

    JSON_SetInt(response, "page", 6);
    JSON_SetInt(response, "fraction_testing_result", g_fraction_gui_test_correct[playerid]);
    JSON_SetInt(response, "fraction_testing_total", FRACTION_GUI_TEST_QUESTIONS);
    JSON_SetInt(response, "fraction_testing_questions_total", FRACTION_GUI_TEST_QUESTIONS);
    if(passed) JSON_SetString(response, "result_message", "Вы успешно прошли тестирование");
    else JSON_SetString(response, "result_message", "Тест не пройден. Попробуйте ещё раз.");
    return 1;
}

stock FractionGui_FillQuest(playerid, Node:response)
{
    new rank = GetPlayerJob(playerid);
    if(rank < 2) return FractionGui_FillDocuments(playerid, response);

    JSON_SetInt(response, "page", 3);
    JSON_SetInt(response, "fraction_task_rank", rank);
    JSON_SetInt(response, "fraction_task_progress", g_fraction_gui_quest_progress[playerid]);
    JSON_SetInt(response, "fraction_task_total", FRACTION_GUI_QUEST_TARGET);

    new desc[160];
    FractionGui_GetQuestDescription(GetPlayerTeamEx(playerid), desc, sizeof(desc));
    JSON_SetString(response, "fraction_task_name", "Задание организации");
    JSON_SetString(response, "fraction_task_description", desc);
    return 1;
}

stock FractionGui_FillRankReward(playerid, Node:response, new_rank = 0)
{
    new rank = GetPlayerJob(playerid);
    if(new_rank <= 0) new_rank = rank < 10 ? rank + 1 : 10;
    if(new_rank < 1) new_rank = 1;
    if(new_rank > 10) new_rank = 10;

    new teamid = GetPlayerTeamEx(playerid);
    new money_reward = rank_wages[teamid - 1][new_rank - 1] * 10;
    new token_reward = 25;

    JSON_SetInt(response, "page", 2);
    new Node:r1 = JSON_Int(money_reward);
    new Node:r2 = JSON_Int(token_reward);
    new Node:rewards = JSON_Array(r1, r2);
    JSON_SetArray(response, "fraction_new_rank_reward", rewards);
    JSON_SetInt(response, "new_rank", new_rank);
    JSON_Cleanup(r1); JSON_Cleanup(r2); JSON_Cleanup(rewards);
    return 1;
}

stock FractionGui_PromoteSelf(playerid, Node:response)
{
    new rank = GetPlayerJob(playerid);
    if(rank < 1 || rank >= 10)
    {
        JSON_SetInt(response, "page", 1);
        FractionGui_FillRanks(playerid, response);
        return 0;
    }

    if(rank == 1)
    {
        if(!g_fraction_gui_test_passed[playerid])
        {
            ShowNotificationLaird(playerid, 2, 6, 0, 0, "Для повышения сначала пройдите тест", " ");
            FractionGui_StartTest(playerid, response);
            return 0;
        }
    }
    else if(g_fraction_gui_quest_progress[playerid] < FRACTION_GUI_QUEST_TARGET)
    {
        ShowNotificationLaird(playerid, 2, 6, 0, 0, "Задание организации ещё не выполнено", " ");
        FractionGui_FillQuest(playerid, response);
        return 0;
    }

    new new_rank = rank + 1;
    new teamid = GetPlayerTeamEx(playerid);

    // Rank 1 -> 2 is the entrance test. Higher promotions complete a faction task.
    if(rank >= 2) g_fraction_gui_completed_tasks[playerid]++;

    SetPlayerData(playerid, P_JOB, new_rank);
    if(!GetPlayerSex(playerid))
        SetPlayerData(playerid, P_OSKIN, GetTeamData(teamid, O_SKINS)[new_rank - 1]);

    new query[192];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE accounts SET job=%d,org_skin=%d WHERE id=%d LIMIT 1",
        new_rank, GetPlayerData(playerid, P_OSKIN), GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query);

    if(GetPVarInt(playerid, "Form") == 1 && GetPlayerData(playerid, P_OSKIN) > 0)
        SetPlayerSkin(playerid, GetPlayerData(playerid, P_OSKIN));

    new money_reward = rank_wages[teamid - 1][new_rank - 1] * 10;
    new token_reward = 25;
    GivePlayerMoneyEx(playerid, money_reward, "Повышение в организации", true, true);
    FractionGui_SetTokens(playerid, FractionGui_GetTokens(playerid) + token_reward);

    g_fraction_gui_docs_mask[playerid] = 0;
    g_fraction_gui_test_passed[playerid] = false;
    g_fraction_gui_test_active[playerid] = false;
    g_fraction_gui_test_question[playerid] = 0;
    g_fraction_gui_test_correct[playerid] = 0;
    g_fraction_gui_quest_rank[playerid] = new_rank;
    g_fraction_gui_quest_progress[playerid] = 0;
    FractionGui_SaveData(playerid);

    new msg[180];
    format(msg, sizeof(msg), "Поздравляем! Вы повышены до %d ранга (%s).", new_rank, GetTeamRankName(teamid, new_rank));
    SendClientMessage(playerid, 0x3399FFFF, msg);

    FractionGui_FillRankReward(playerid, response, new_rank);
    return 1;
}

stock FractionGui_FillShop(playerid, Node:response)
{
    JSON_SetInt(response, "page", 8);

    new Node:item1 = JSON_Object();
    JSON_SetInt(item1, "unique_id", 1);
    JSON_SetString(item1, "name", "Аптечка");
    JSON_SetInt(item1, "price", 100);

    new Node:item2 = JSON_Object();
    JSON_SetInt(item2, "unique_id", 2);
    JSON_SetString(item2, "name", "Ремонтный комплект");
    JSON_SetInt(item2, "price", 200);

    new Node:items = JSON_Array(item1, item2);
    JSON_SetArray(response, "shop_items", items);
    JSON_Cleanup(item1); JSON_Cleanup(item2); JSON_Cleanup(items);
    return 1;
}

stock FractionGui_ShopPurchase(playerid, Node:json, Node:response)
{
    new item = 0;
    if(!JSON_GetInt(json, "unique_id", item) &&
       !JSON_GetInt(json, "shop_item", item) &&
       !JSON_GetInt(json, "item", item) &&
       !JSON_GetInt(json, "selected", item) &&
       !JSON_GetInt(json, "index", item)) item = 1;

    if(item == 0) item = 1;
    if(item > 2 && item - 1 <= 2) item--;

    new price, inv_item, inv_model;
    switch(item)
    {
        case 1: { price = 100; inv_item = 22; inv_model = 1; }
        case 2: { price = 200; inv_item = 952; inv_model = 952; }
        default: return FractionGui_FillShop(playerid, response);
    }

    if(FractionGui_GetTokens(playerid) < price)
    {
        ShowNotificationLaird(playerid, 2, 6, 0, 0, "Недостаточно токенов организации", " ");
        return FractionGui_FillShop(playerid, response);
    }

    if(Inventory11_AddItemToDatabase(playerid, inv_item, inv_model, 1, 0, 0) == -1)
    {
        ShowNotificationLaird(playerid, 2, 6, 0, 0, "В инвентаре нет свободного места", " ");
        return FractionGui_FillShop(playerid, response);
    }

    FractionGui_SetTokens(playerid, FractionGui_GetTokens(playerid) - price);
    ShowNotificationLaird(playerid, 3, 6, 0, 0, "Предмет приобретён", " ");
    return FractionGui_FillShop(playerid, response);
}

stock FractionGui_GetButton(Node:json)
{
    new button_id = 0;
    if(JSON_GetInt(json, "button", button_id)) return button_id;
    if(JSON_GetInt(json, "b", button_id)) return button_id;
    if(JSON_GetInt(json, "i", button_id)) return button_id;
    if(JSON_GetInt(json, "a", button_id)) return button_id;
    JSON_GetInt(json, "t", button_id);
    return button_id;
}

stock FractionGui_HandlePacket(playerid, Node:json)
{
    new teamid = GetPlayerTeamEx(playerid);
    if(!FractionGui_IsOfficialTeam(teamid))
    {
        HidePlayerGUI(playerid, 46);
        return 1;
    }

    if(!g_fraction_gui_loaded[playerid])
    {
        FractionGui_LoadData(playerid, true);
        return 1;
    }

    // GUI 46 membership component compact protocol.
    // t=5,id=2,s=0 -> roster; s=1,n=<nickname> -> personal dossier.
    // Handle this BEFORE FractionGui_GetButton(), otherwise t=5 is mistaken
    // for navigation button 5 and the employee card never receives data.
    new compact_t = -1, compact_id = -1, compact_s = -1;
    new compact_name[MAX_PLAYER_NAME + 1];
    compact_name[0] = EOS;
    new bool:has_compact_t = JSON_GetInt(json, "t", compact_t);
    new bool:has_compact_id = JSON_GetInt(json, "id", compact_id);
    new bool:has_compact_s = JSON_GetInt(json, "s", compact_s);
    new bool:has_compact_name = JSON_GetString(json, "n", compact_name, sizeof(compact_name));

    // Some client revisions omit t/id when a row itself is clicked and send
    // only s=1,n=<nickname>. Accept both forms.
    if((has_compact_t && compact_t == 5 && has_compact_id && compact_id == 2) ||
       (has_compact_s && compact_s == 1 && has_compact_name && strlen(compact_name)))
    {
        new Node:compact_response = JSON_Object();
        JSON_ToggleGC(compact_response, false);

        if(has_compact_s && compact_s == 1)
        {
            new selected_name[MAX_PLAYER_NAME + 1];
            selected_name[0] = EOS;
            if(has_compact_name) format(selected_name, sizeof(selected_name), "%s", compact_name);
            else JSON_GetString(json, "n", selected_name, sizeof(selected_name));

            new account_id = 0;
            if(strlen(selected_name))
            {
                new compact_query[192];
                mysql_format(mysql, compact_query, sizeof(compact_query),
                    "SELECT id FROM accounts WHERE team=%d AND name='%e' LIMIT 1",
                    teamid, selected_name);
                new Cache:compact_cache = mysql_query(mysql, compact_query, true);
                if(cache_num_rows()) account_id = cache_get_field_content_int(0, "id");
                cache_delete(compact_cache);
            }

            if(account_id <= 0)
                account_id = FractionGui_FindRosterAccount(playerid, json, false);

            if(account_id > 0)
                FractionGui_FillPlayerCard(playerid, account_id, compact_response);
            else
                FractionGui_BuildRoster(playerid, compact_response);
        }
        else
        {
            new compact_search[MAX_PLAYER_NAME + 1];
            compact_search[0] = EOS;
            if(FractionGui_GetRosterSearch(json, compact_search, sizeof(compact_search)))
                FractionGui_BuildRoster(playerid, compact_response, compact_search);
            else
                FractionGui_BuildRoster(playerid, compact_response);
        }

        FractionGui_FillCommon(playerid, compact_response);
        OnPacketIncoming(playerid, 46, compact_response);
        JSON_Cleanup(compact_response);
        return 1;
    }

    new current_page = 1;
    JSON_GetInt(json, "page", current_page);
    new button_id = FractionGui_GetButton(json);

    new Node:response = JSON_Object();
    JSON_ToggleGC(response, false);

    // Page-specific actions first. The same button numbers are reused by GUI 46 on different pages.
    if(current_page == 4 && (button_id == 9 || button_id == 14 || button_id == 8))
    {
        // "ОЗНАКОМЛЕН" only marks the currently opened document.
        // The rank 1 -> 2 test is started separately from the progression/task button.
        new before_count = FractionGui_GetDocsReadCount(playerid);
        new doc = FractionGui_GetDocumentIndex(playerid, json);
        if(doc >= 0 && doc < FRACTION_GUI_DOCS_COUNT)
            g_fraction_gui_docs_mask[playerid] |= (1 << doc);
        FractionGui_SaveData(playerid);

        if(before_count < FRACTION_GUI_DOCS_COUNT && FractionGui_AllDocsRead(playerid))
            ShowNotificationLaird(playerid, 3, 6, 0, 0, "Все документы изучены", "Вернитесь в прогресс и начните тест");

        FractionGui_FillDocuments(playerid, response);
    }
    else if(current_page == 5 && (button_id == 14 || button_id == 8 || button_id == 9))
    {
        FractionGui_HandleTestAnswer(playerid, json, response);
    }
    else if(current_page == 6 && (button_id == 1 || button_id == 9 || button_id == 10 || button_id == 14 || button_id == 8))
    {
        if(GetPlayerJob(playerid) == 1 && g_fraction_gui_test_passed[playerid])
            FractionGui_PromoteSelf(playerid, response);
        else
        {
            JSON_SetInt(response, "page", 1);
            FractionGui_FillRanks(playerid, response);
        }
    }
    else if(current_page == 3 && button_id == 8)
    {
        FractionGui_PromoteSelf(playerid, response);
    }
    else if(current_page == 7 && button_id == 8)
    {
        if(GetPlayerDonateRub(playerid) < FRACTION_GUI_TOKEN_PRICE)
        {
            ShowNotificationLaird(playerid, 2, 6, 0, 0, "Недостаточно BC", " ");
        }
        else
        {
            GivePlayerDonateRub(playerid, -FRACTION_GUI_TOKEN_PRICE, "Покупка токенов организации", true, false);
            FractionGui_SetTokens(playerid, FractionGui_GetTokens(playerid) + FRACTION_GUI_TOKEN_PACK);
            ShowNotificationLaird(playerid, 3, 6, 0, 0, "Токены организации куплены", " ");
        }
        JSON_SetInt(response, "page", 7);
        JSON_SetInt(response, "type", 1);
        JSON_SetInt(response, "fraction_add_tokens_bc_value", FRACTION_GUI_TOKEN_PRICE);
        JSON_SetInt(response, "fraction_add_tokens_value", FRACTION_GUI_TOKEN_PACK);
    }
    else if(current_page == 8 && button_id == 8)
    {
        FractionGui_ShopPurchase(playerid, json, response);
    }
    else
    {
        switch(button_id)
        {
            case 1, 10:
            {
                JSON_SetInt(response, "page", 1);
                FractionGui_FillRanks(playerid, response);
            }
            case 2:
            {
                JSON_SetInt(response, "page", 7);
                JSON_SetInt(response, "type", 1);
                JSON_SetInt(response, "fraction_add_tokens_bc_value", FRACTION_GUI_TOKEN_PRICE);
                JSON_SetInt(response, "fraction_add_tokens_value", FRACTION_GUI_TOKEN_PACK);
            }
            case 3:
            {
                FractionGui_FillShop(playerid, response);
            }
            case 4:
            {
                FractionGui_BuildRoster(playerid, response);
            }
            case 5:
            {
                FractionGui_FillDocuments(playerid, response);
            }
            case 6:
            {
                FractionGui_FillRankReward(playerid, response);
            }
            case 7:
            {
                if(GetPlayerJob(playerid) == 1)
                {
                    if(g_fraction_gui_test_passed[playerid])
                        FractionGui_PromoteSelf(playerid, response);
                    else if(FractionGui_AllDocsRead(playerid))
                        FractionGui_StartTest(playerid, response);
                    else
                        FractionGui_FillDocuments(playerid, response);
                }
                else
                {
                    FractionGui_FillQuest(playerid, response);
                }
            }
            case 8:
            {
                JSON_SetInt(response, "page", current_page);
            }
            case 9:
            {
                if(GetPlayerJob(playerid) == 1 && FractionGui_AllDocsRead(playerid))
                    FractionGui_StartTest(playerid, response);
                else
                    FractionGui_FillDocuments(playerid, response);
            }
            case 11:
            {
                printf("[FRACTION][CLICK11] player=%d explicit=%d roster_count=%d selected_account=%d", playerid, FractionGui_HasExplicitRosterSelection(json), g_fraction_gui_roster_count[playerid], g_fraction_gui_selected_account[playerid]);
                new search[MAX_PLAYER_NAME + 1];
                if(FractionGui_GetRosterSearch(json, search, sizeof(search)))
                {
                    // Search works with both full and partial nicknames, case-insensitively.
                    FractionGui_BuildRoster(playerid, response, search);
                }
                else if(!FractionGui_HasExplicitRosterSelection(json))
                {
                    // Back/filter events on the roster must never open a fake player card.
                    FractionGui_BuildRoster(playerid, response);
                }
                else
                {
                    new account_id = FractionGui_FindRosterAccount(playerid, json, false);
                    if(account_id <= 0) FractionGui_BuildRoster(playerid, response);
                    else if(!FractionGui_FillPlayerCard(playerid, account_id, response)) FractionGui_BuildRoster(playerid, response);
                }
            }
            case 12:
            {
                new account_id = FractionGui_FindRosterAccount(playerid, json, true);
                if(account_id <= 0)
                {
                    FractionGui_BuildRoster(playerid, response);
                }
                else
                {
                    new new_rank;
                    if(!JSON_GetInt(json, "new_rank", new_rank) &&
                       !JSON_GetInt(json, "fraction_control_player_new_rank", new_rank))
                    {
                        new target_team, target_rank, target_warn, target_sex;
                        if(FractionGui_GetAccountFactionData(account_id, target_team, target_rank, target_warn, target_sex)) new_rank = target_rank + 1;
                        else new_rank = 1;
                    }

                    if(!FractionGui_ChangeRank(playerid, account_id, new_rank, response))
                        FractionGui_FillPlayerCard(playerid, account_id, response);
                }
            }
            case 13:
            {
                new account_id = FractionGui_FindRosterAccount(playerid, json, true);
                if(account_id <= 0)
                {
                    FractionGui_BuildRoster(playerid, response);
                }
                else
                {
                    new new_warn;
                    if(!JSON_GetInt(json, "fraction_control_player_new_reprimand", new_warn) &&
                       !JSON_GetInt(json, "new_reprimand", new_warn))
                    {
                        new target_team, target_rank, target_warn, target_sex;
                        if(FractionGui_GetAccountFactionData(account_id, target_team, target_rank, target_warn, target_sex)) new_warn = target_warn + 1;
                        else new_warn = 0;
                    }

                    if(!FractionGui_ChangeWarn(playerid, account_id, new_warn, response))
                        FractionGui_FillPlayerCard(playerid, account_id, response);
                }
            }
            case 15:
            {
                new account_id = FractionGui_FindRosterAccount(playerid, json, true);
                if(account_id <= 0 || !FractionGui_FireMember(playerid, account_id, response))
                    FractionGui_BuildRoster(playerid, response);
            }
            case 14:
            {
                JSON_SetInt(response, "page", 1);
                FractionGui_FillRanks(playerid, response);
            }
            default:
            {
                JSON_SetInt(response, "page", 1);
                FractionGui_FillRanks(playerid, response);
            }
        }
    }

    FractionGui_FillCommon(playerid, response);

    OnPacketIncoming(playerid, 46, response);
    JSON_Cleanup(response);
    return 1;
}
