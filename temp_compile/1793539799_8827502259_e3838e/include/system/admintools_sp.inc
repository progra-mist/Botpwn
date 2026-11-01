#if defined _SIMPLE_RUSSIA_SPECTATE_FULL_INC
    #endinput
#endif
#define _SIMPLE_RUSSIA_SPECTATE_FULL_INC

// Full /sp GUI + templates ported from last5_marketplace_VIGSA_FULL.
// Adapted to the current g_spectate/StartSpectate implementation.

#define SP_GUI_ID                       (66)
#define SP_TEMPLATE_MAX                 (256)
#define SP_DIALOG_TEMPLATE_CATEGORY     (19870)
#define SP_DIALOG_TEMPLATE_TITLE        (19871)
#define SP_DIALOG_TEMPLATE_TIME         (19872)
#define SP_DIALOG_TEMPLATE_DESC         (19873)

enum E_SP_TEMPLATE
{
    spTplUsed,
    spTplId,
    spTplCategory,
    spTplTime,
    spTplTitle[64],
    spTplDesc[256]
}
new g_sp_templates[SP_TEMPLATE_MAX][E_SP_TEMPLATE];

forward SP_OnTemplatesTableReady();
forward SP_OnTemplatesLoaded(reopen_playerid);
forward SP_OnTemplateCreated(playerid);

stock SP_SpectateToolsInit()
{
    // The original mod expects admin_templates to exist. Create it safely when absent.
    new query[512];
    format(query, sizeof query, "CREATE TABLE IF NOT EXISTS `admin_templates` (`id` INT NOT NULL AUTO_INCREMENT,`category` INT NOT NULL DEFAULT 3,`title` VARCHAR(64) NOT NULL,`description` VARCHAR(255) NOT NULL,`time_value` INT NOT NULL DEFAULT 0,PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, query, "SP_OnTemplatesTableReady", "");
    return 1;
}

public SP_OnTemplatesTableReady()
{
    SP_LoadTemplates();
    return 1;
}

stock SP_LoadTemplates(reopen_playerid = INVALID_PLAYER_ID)
{
    for(new i = 0; i < SP_TEMPLATE_MAX; i++)
    {
        g_sp_templates[i][spTplUsed] = 0;
        g_sp_templates[i][spTplId] = 0;
        g_sp_templates[i][spTplCategory] = 0;
        g_sp_templates[i][spTplTime] = 0;
        g_sp_templates[i][spTplTitle][0] = EOS;
        g_sp_templates[i][spTplDesc][0] = EOS;
    }

    mysql_tquery(mysql,
        "SELECT `id`,`category`,`title`,`description`,`time_value` FROM `admin_templates` ORDER BY `id` ASC LIMIT 256",
        "SP_OnTemplatesLoaded", "i", reopen_playerid);
    return 1;
}

public SP_OnTemplatesLoaded(reopen_playerid)
{
    new rows = cache_num_rows();
    new count = 0;

    for(new i = 0; i < rows && count < SP_TEMPLATE_MAX; i++)
    {
        g_sp_templates[count][spTplUsed] = 1;
        g_sp_templates[count][spTplId] = cache_get_field_content_int(i, "id", mysql);
        g_sp_templates[count][spTplCategory] = cache_get_field_content_int(i, "category", mysql);
        g_sp_templates[count][spTplTime] = cache_get_field_content_int(i, "time_value", mysql);
        cache_get_field_content(i, "title", g_sp_templates[count][spTplTitle], mysql, 64);
        cache_get_field_content(i, "description", g_sp_templates[count][spTplDesc], mysql, 256);
        count++;
    }

    printf("[SP][TEMPLATES] loaded=%d", count);

    if(reopen_playerid != INVALID_PLAYER_ID && IsPlayerConnected(reopen_playerid))
        AT_SendMyTemplates(reopen_playerid);

    return 1;
}

stock SP_FindTemplateById(template_id)
{
    for(new i = 0; i < SP_TEMPLATE_MAX; i++)
    {
        if(g_sp_templates[i][spTplUsed] && g_sp_templates[i][spTplId] == template_id)
            return i;
    }
    return -1;
}

stock SP_CloseSpectateGUI(playerid)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "c", 1);
    OnPacketIncoming(playerid, SP_GUI_ID, json);
    JSON_Cleanup(json);
    return 1;
}

stock ShowControlPanelGUI(playerid)
{
    if(GetPlayerAdminEx(playerid) < 1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Панель доступна только администраторам", "");
    StopSpectateGUIRefresh(playerid);
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", 6);
    JSON_SetInt(json, "o", 1);

    new Node:btn0 = JSON_Object("bi", JSON_Int(0), "bn", JSON_String("Мои шаблоны"), "be", JSON_String("Просмотр шаблонов"));
    new Node:btn1 = JSON_Object("bi", JSON_Int(1), "bn", JSON_String("Создать шаблон"), "be", JSON_String("Новый шаблон"));
    new Node:btn7 = JSON_Object("bi", JSON_Int(7), "bn", JSON_String("Категории"), "be", JSON_String("Наказания"));
    new Node:arr = JSON_Array(btn0, btn1, btn7);
    JSON_SetArray(json, "bt", arr);

    OnPacketIncoming(playerid, SP_GUI_ID, json);
    JSON_Cleanup(json);
    return 1;
}

stock AT_SendPunishTemplates(playerid, category)
{
    if(GetPlayerAdminEx(playerid) < 1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Наказания доступны только администраторам", "");
    StopSpectateGUIRefresh(playerid);
    new Node:json_response = JSON_Object();
    JSON_SetInt(json_response, "t", 2);
    JSON_SetInt(json_response, "o", 1);

    switch(category)
    {
        case 3:
        {
            JSON_SetString(json_response, "bn", "Кик");
            JSON_SetInt(json_response, "tf", 0);
            new Node:t1 = JSON_Object("bi", JSON_Int(1), "bn", JSON_String("Afk no esc"), "be", JSON_String("Afk no esc"));
            new Node:t2 = JSON_Object("bi", JSON_Int(2), "bn", JSON_String("Помеха"), "be", JSON_String("Помеха"));
            new Node:t3 = JSON_Object("bi", JSON_Int(3), "bn", JSON_String("Баг"), "be", JSON_String("Баг"));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2, t3));
        }
        case 4:
        {
            JSON_SetString(json_response, "bn", "Мут");
            JSON_SetInt(json_response, "tf", 1);
            new Node:t1 = JSON_Object("bi", JSON_Int(4), "bn", JSON_String("Оскорбление"), "be", JSON_String("Оскорбление игроков"), "br", JSON_Int(15));
            new Node:t2 = JSON_Object("bi", JSON_Int(5), "bn", JSON_String("Упоминание родни"), "be", JSON_String("Упоминание родни"), "br", JSON_Int(30));
            new Node:t3 = JSON_Object("bi", JSON_Int(6), "bn", JSON_String("Неуважение к администрации"), "be", JSON_String("Неуважение к администрации"), "br", JSON_Int(60));
            new Node:t4 = JSON_Object("bi", JSON_Int(7), "bn", JSON_String("CAPS"), "be", JSON_String("Капс в чате"), "br", JSON_Int(10));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2, t3, t4));
        }
        case 5:
        {
            JSON_SetString(json_response, "bn", "Тюрьма");
            JSON_SetInt(json_response, "tf", 1);
            new Node:t1 = JSON_Object("bi", JSON_Int(8), "bn", JSON_String("DM"), "be", JSON_String("DM без причины"), "br", JSON_Int(10));
            new Node:t2 = JSON_Object("bi", JSON_Int(9), "bn", JSON_String("DB"), "be", JSON_String("DriveBy"), "br", JSON_Int(15));
            new Node:t3 = JSON_Object("bi", JSON_Int(10), "bn", JSON_String("TK"), "be", JSON_String("TeamKill"), "br", JSON_Int(20));
            new Node:t4 = JSON_Object("bi", JSON_Int(11), "bn", JSON_String("Провокация ГОС"), "be", JSON_String("Провокация гос. организаций"), "br", JSON_Int(25));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2, t3, t4));
        }
        case 6:
        {
            JSON_SetString(json_response, "bn", "Предупреждение");
            JSON_SetInt(json_response, "tf", 0);
            new Node:t1 = JSON_Object("bi", JSON_Int(12), "bn", JSON_String("НонРП COP"), "be", JSON_String("НонРП коп"));
            new Node:t2 = JSON_Object("bi", JSON_Int(13), "bn", JSON_String("НонРП В/Ч"), "be", JSON_String("НонРП в/ч"));
            new Node:t3 = JSON_Object("bi", JSON_Int(14), "bn", JSON_String("ОРП"), "be", JSON_String("ОРП"));
            new Node:t4 = JSON_Object("bi", JSON_Int(15), "bn", JSON_String("Снят ЛД"), "be", JSON_String("Снятие ЛД"));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2, t3, t4));
        }
        case 7:
        {
            JSON_SetString(json_response, "bn", "Шлепок");
            JSON_SetInt(json_response, "tf", 0);
            new Node:t1 = JSON_Object("bi", JSON_Int(16), "bn", JSON_String("Подбросить вверх"), "be", JSON_String("Подбросить вверх"));
            new Node:t2 = JSON_Object("bi", JSON_Int(17), "bn", JSON_String("Подбросить вниз"), "be", JSON_String("Подбросить вниз"));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2));
        }
        case 8:
        {
            JSON_SetString(json_response, "bn", "Бан");
            JSON_SetInt(json_response, "tf", 1);
            new Node:t1 = JSON_Object("bi", JSON_Int(18), "bn", JSON_String("Mass DM"), "be", JSON_String("Массовый DM"), "br", JSON_Int(7));
            new Node:t2 = JSON_Object("bi", JSON_Int(19), "bn", JSON_String("П/П/В"), "be", JSON_String("П/П/В"), "br", JSON_Int(30));
            new Node:t3 = JSON_Object("bi", JSON_Int(20), "bn", JSON_String("Оск. Родни"), "be", JSON_String("Оскорбление родни"), "br", JSON_Int(14));
            new Node:t4 = JSON_Object("bi", JSON_Int(21), "bn", JSON_String("Читы"), "be", JSON_String("Использование читов"), "br", JSON_Int(365));
            JSON_SetArray(json_response, "bt", JSON_Array(t1, t2, t3, t4));
        }
        default:
        {
            JSON_Cleanup(json_response);
            return 0;
        }
    }

    OnPacketIncoming(playerid, SP_GUI_ID, json_response);
    JSON_Cleanup(json_response);
    return 1;
}

stock AT_SendCategories(playerid)
{
    if(GetPlayerAdminEx(playerid) < 1) return 0;
    StopSpectateGUIRefresh(playerid);
    new Node:json_response = JSON_Object();
    JSON_SetInt(json_response, "t", 7);
    JSON_SetInt(json_response, "o", 1);

    new Node:cat1 = JSON_Object("bi", JSON_Int(3), "bn", JSON_String("Кик"), "be", JSON_String("Категория"));
    new Node:cat2 = JSON_Object("bi", JSON_Int(4), "bn", JSON_String("Мут"), "be", JSON_String("Категория"));
    new Node:cat3 = JSON_Object("bi", JSON_Int(5), "bn", JSON_String("Тюрьма"), "be", JSON_String("Категория"));
    new Node:cat4 = JSON_Object("bi", JSON_Int(6), "bn", JSON_String("Предупреждение"), "be", JSON_String("Категория"));
    new Node:cat5 = JSON_Object("bi", JSON_Int(7), "bn", JSON_String("Шлепок"), "be", JSON_String("Категория"));
    new Node:cat6 = JSON_Object("bi", JSON_Int(8), "bn", JSON_String("Бан"), "be", JSON_String("Категория"));
    JSON_SetArray(json_response, "bt", JSON_Array(cat1, cat2, cat3, cat4, cat5, cat6));

    OnPacketIncoming(playerid, SP_GUI_ID, json_response);
    JSON_Cleanup(json_response);
    return 1;
}

stock AT_SendMyTemplates(playerid)
{
    if(GetPlayerAdminEx(playerid) < 1) return 0;
    StopSpectateGUIRefresh(playerid);
    new Node:json_response = JSON_Object();
    JSON_SetInt(json_response, "t", 8);
    JSON_SetInt(json_response, "o", 1);
    JSON_SetString(json_response, "bn", "Мои шаблоны");

    new Node:arr = JSON_Array();
    new count = 0;

    for(new i = 0; i < SP_TEMPLATE_MAX; i++)
    {
        if(!g_sp_templates[i][spTplUsed]) continue;

        new Node:item = JSON_Object(
            "bi", JSON_Int(g_sp_templates[i][spTplId]),
            "bn", JSON_String(g_sp_templates[i][spTplTitle]),
            "be", JSON_String(g_sp_templates[i][spTplDesc])
        );

        if(g_sp_templates[i][spTplTime] > 0)
            JSON_SetInt(item, "br", g_sp_templates[i][spTplTime]);

        JSON_ArrayAppend(arr, "", item);
        count++;
    }

    JSON_SetArray(json_response, "bt", arr);
    OnPacketIncoming(playerid, SP_GUI_ID, json_response);
    JSON_Cleanup(json_response);

    if(count == 0)
        ShowNotificationNew(playerid, 0, 4, 0, 0, "Пользовательских шаблонов пока нет", "");

    return 1;
}

stock SP_KickTarget(playerid, targetid, const reason[])
{
    if(GetPlayerAdminEx(playerid) < 14)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Недостаточно прав для кика", "");
    if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) return 0;
    if(GetPlayerAdminEx(targetid) > GetPlayerAdminEx(playerid))
        return SendClientMessage(playerid, 0xCECECEFF, "Нельзя кикнуть администратора выше по рангу");
    if(AntiSliv(playerid, "/kick")) return 1;

    new msg[220];
    format(msg, sizeof msg, "Администратор %s кикнул игрока %s. Причина: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), reason);
    SendClientMessageToAll(0xFF5533FF, msg);

    format(msg, sizeof msg, "SP TEMPLATE KICK: %s[acc:%d]. Причина: %s", GetPlayerNameEx(targetid), GetPlayerAccountID(targetid), reason);
    SendLog(playerid, LOG_TYPE_ADMIN_ACTION, msg);

    Kick(targetid);
    return 1;
}

stock AT_ApplyPunishTemplate(playerid, targetid, template_id)
{
    if(GetPlayerAdminEx(playerid) < 1) return 0;
    if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) return 0;

    new params[192];

    switch(template_id)
    {
        case 1: return SP_KickTarget(playerid, targetid, "Afk no esc");
        case 2: return SP_KickTarget(playerid, targetid, "Помеха");
        case 3: return SP_KickTarget(playerid, targetid, "Баг");

        case 4: format(params, sizeof params, "%d 15 Оскорбление_игроков", targetid), callcmd::mute(playerid, params);
        case 5: format(params, sizeof params, "%d 30 Упоминание_родни", targetid), callcmd::mute(playerid, params);
        case 6: format(params, sizeof params, "%d 60 Неуважение_к_администрации", targetid), callcmd::mute(playerid, params);
        case 7: format(params, sizeof params, "%d 10 CAPS", targetid), callcmd::mute(playerid, params);

        case 8: format(params, sizeof params, "%d 10 DM_без_причины", targetid), callcmd::jail(playerid, params);
        case 9: format(params, sizeof params, "%d 15 DB", targetid), callcmd::jail(playerid, params);
        case 10: format(params, sizeof params, "%d 20 TeamKill", targetid), callcmd::jail(playerid, params);
        case 11: format(params, sizeof params, "%d 25 Провокация_ГОС", targetid), callcmd::jail(playerid, params);

        case 12: format(params, sizeof params, "%d НонРП_COP", targetid), callcmd::warndsdsf(playerid, params);
        case 13: format(params, sizeof params, "%d НонРП_ВЧ", targetid), callcmd::warndsdsf(playerid, params);
        case 14: format(params, sizeof params, "%d ОРП", targetid), callcmd::warndsdsf(playerid, params);
        case 15: format(params, sizeof params, "%d Снят_ЛД", targetid), callcmd::warndsdsf(playerid, params);

        case 16:
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            SetPlayerPos(targetid, x, y, z + 10.0);
        }
        case 17:
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            SetPlayerPos(targetid, x, y, z - 5.0);
        }

        case 18: format(params, sizeof params, "%d 7 Mass_DM", targetid), callcmd::ban(playerid, params);
        case 19: format(params, sizeof params, "%d 30 ППВ", targetid), callcmd::ban(playerid, params);
        case 20: format(params, sizeof params, "%d 14 Оскорбление_родни", targetid), callcmd::ban(playerid, params);
        case 21: format(params, sizeof params, "%d 365 Читы", targetid), callcmd::ban(playerid, params);
        default: return 0;
    }
    return 1;
}

stock SP_ApplyCustomTemplate(playerid, targetid, template_id)
{
    if(GetPlayerAdminEx(playerid) < 1) return 0;
    new idx = SP_FindTemplateById(template_id);
    if(idx == -1) return ShowNotificationNew(playerid, 2, 6, 0, 0, "Шаблон не найден", "");
    if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) return 0;

    new params[384];
    new time_value = g_sp_templates[idx][spTplTime];
    if(time_value < 1) time_value = 10;

    switch(g_sp_templates[idx][spTplCategory])
    {
        case 3: return SP_KickTarget(playerid, targetid, g_sp_templates[idx][spTplDesc]);
        case 4:
        {
            format(params, sizeof params, "%d %d %s", targetid, time_value, g_sp_templates[idx][spTplDesc]);
            callcmd::mute(playerid, params);
        }
        case 5:
        {
            format(params, sizeof params, "%d %d %s", targetid, time_value, g_sp_templates[idx][spTplDesc]);
            callcmd::jail(playerid, params);
        }
        case 6:
        {
            format(params, sizeof params, "%d %s", targetid, g_sp_templates[idx][spTplDesc]);
            callcmd::warndsdsf(playerid, params);
        }
        case 7:
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(strfind(g_sp_templates[idx][spTplDesc], "вниз", true) != -1)
                SetPlayerPos(targetid, x, y, z - 5.0);
            else
                SetPlayerPos(targetid, x, y, z + 10.0);
        }
        case 8:
        {
            format(params, sizeof params, "%d %d %s", targetid, time_value, g_sp_templates[idx][spTplDesc]);
            callcmd::ban(playerid, params);
        }
        default: return 0;
    }

    return 1;
}

stock SP_ShowCreateTemplateCategory(playerid)
{
    if(GetPlayerAdminEx(playerid) < 1) return 0;
    StopSpectateGUIRefresh(playerid);
    ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_CATEGORY, DIALOG_STYLE_LIST,
        "Шаблоны /sp | Категория",
        "Кик\nМут\nТюрьма\nПредупреждение\nШлепок\nБан",
        "Далее", "Назад");
    return 1;
}

stock bool:SP_HandleTemplateDialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid >= SP_DIALOG_TEMPLATE_CATEGORY && dialogid <= SP_DIALOG_TEMPLATE_DESC && GetPlayerAdminEx(playerid) < 1)
        return true;
    if(dialogid == SP_DIALOG_TEMPLATE_CATEGORY)
    {
        if(!response)
        {
            ShowControlPanelGUI(playerid);
            return true;
        }

        SetPVarInt(playerid, "SPTemplateCategory", listitem + 3);
        ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_TITLE, DIALOG_STYLE_INPUT,
            "Шаблоны /sp | Название", "Введите название шаблона:", "Далее", "Назад");
        return true;
    }

    if(dialogid == SP_DIALOG_TEMPLATE_TITLE)
    {
        if(!response)
        {
            SP_ShowCreateTemplateCategory(playerid);
            return true;
        }
        if(strlen(inputtext) < 2 || strlen(inputtext) >= 64)
        {
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_TITLE, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Название", "Название должно содержать от 2 до 63 символов.", "Далее", "Назад");
            return true;
        }

        SetPVarString(playerid, "SPTemplateTitle", inputtext);
        new category = GetPVarInt(playerid, "SPTemplateCategory");
        if(category == 4 || category == 5 || category == 8)
        {
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_TIME, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Срок", "Введите срок наказания (для мута/тюрьмы — минуты, для бана — дни):", "Далее", "Назад");
        }
        else
        {
            SetPVarInt(playerid, "SPTemplateTime", 0);
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_DESC, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Причина", "Введите причину/описание шаблона:", "Сохранить", "Назад");
        }
        return true;
    }

    if(dialogid == SP_DIALOG_TEMPLATE_TIME)
    {
        if(!response)
        {
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_TITLE, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Название", "Введите название шаблона:", "Далее", "Назад");
            return true;
        }

        new value = strval(inputtext);
        if(value < 1 || value > 3650)
        {
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_TIME, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Срок", "Введите число от 1 до 3650:", "Далее", "Назад");
            return true;
        }

        SetPVarInt(playerid, "SPTemplateTime", value);
        ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_DESC, DIALOG_STYLE_INPUT,
            "Шаблоны /sp | Причина", "Введите причину/описание шаблона:", "Сохранить", "Назад");
        return true;
    }

    if(dialogid == SP_DIALOG_TEMPLATE_DESC)
    {
        if(!response)
        {
            SP_ShowCreateTemplateCategory(playerid);
            return true;
        }
        if(strlen(inputtext) < 2 || strlen(inputtext) >= 256)
        {
            ShowPlayerDialog(playerid, SP_DIALOG_TEMPLATE_DESC, DIALOG_STYLE_INPUT,
                "Шаблоны /sp | Причина", "Описание должно содержать от 2 до 255 символов.", "Сохранить", "Назад");
            return true;
        }

        new title[64], query[768];
        GetPVarString(playerid, "SPTemplateTitle", title, sizeof title);
        new category = GetPVarInt(playerid, "SPTemplateCategory");
        new time_value = GetPVarInt(playerid, "SPTemplateTime");

        mysql_format(mysql, query, sizeof query,
            "INSERT INTO `admin_templates` (`category`,`title`,`description`,`time_value`) VALUES (%d,'%e','%e',%d)",
            category, title, inputtext, time_value);
        mysql_tquery(mysql, query, "SP_OnTemplateCreated", "i", playerid);

        DeletePVar(playerid, "SPTemplateCategory");
        DeletePVar(playerid, "SPTemplateTitle");
        DeletePVar(playerid, "SPTemplateTime");
        return true;
    }

    return false;
}

public SP_OnTemplateCreated(playerid)
{
    if(IsPlayerConnected(playerid))
        ShowNotificationNew(playerid, 1, 6, 0, 0, "Шаблон сохранен", "");

    // Reload first, then reopen the list from SP_OnTemplatesLoaded.
    // This avoids a race where the GUI could reopen before the INSERT is visible in memory.
    SP_LoadTemplates(playerid);
    return 1;
}

stock SP_GetGuiButton(Node:json, &button_id)
{
    button_id = -1;
    if(JSON_GetType(json, "b") == JSON_NODE_NUMBER)
    {
        JSON_GetInt(json, "b", button_id);
        return 1;
    }
    if(JSON_GetType(json, "bi") == JSON_NODE_NUMBER)
    {
        JSON_GetInt(json, "bi", button_id);
        return 1;
    }
    return 0;
}

stock SP_SwitchSpectateTarget(playerid, targetid)
{
    if(!Spectate_CanWatchPlayer(playerid, targetid)) return 0;

    StartSpectate(playerid, targetid);
    StartSpectateGUIRefresh(playerid);
    ShowSpectateGUI(playerid, targetid);

    SetPVarInt(playerid, "IsSpectating", 1);
    SetPVarInt(playerid, "SpectatingID", targetid);
    return 1;
}

stock SP_HandleSpectateGUI(playerid, Node:json)
{
    new close_flag = 0;
    if(JSON_GetType(json, "c") == JSON_NODE_NUMBER)
    {
        JSON_GetInt(json, "c", close_flag);
        if(close_flag == 1)
        {
            new ignore_close_until = GetPVarInt(playerid, "sp_gui_ignore_close_until");
            if(ignore_close_until > GetTickCount()) return 1;

            DeletePVar(playerid, "sp_gui_ignore_close_until");
            if(GetPlayerSpectateData(playerid, S_PLAYER) != -1)
            {
                StopSpectate(playerid);
            }
            else
            {
                // Do not echo another GUI close packet back to the client here.
                // Some clients acknowledge server-side close with c=1; echoing it can loop.
                StopSpectateGUIRefresh(playerid);
                DeletePVar(playerid, "IsSpectating");
                DeletePVar(playerid, "SpectatingID");
            }
            return 1;
        }
    }

    new screen_type = 0;
    if(JSON_GetType(json, "t") == JSON_NODE_NUMBER)
        JSON_GetInt(json, "t", screen_type);

    new button_id;
    new has_button = SP_GetGuiButton(json, button_id);
    if(!has_button) return 1;

    new targetid = GetPlayerSpectateData(playerid, S_PLAYER);
    if(targetid == -1 && !GetPVarInt(playerid, "IsSpectating"))
        return 1;
    if(targetid == -1)
        targetid = GetPVarInt(playerid, "SpectatingID");

    switch(screen_type)
    {
        case 1:
        {
            if(targetid == -1 || !IsPlayerConnected(targetid))
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Слежение не активно", "");

            switch(button_id)
            {
                case 1:
                {
                    new players[MAX_PLAYERS], count = 0;
                    for(new i = 0; i < MAX_PLAYERS; i++)
                    {
                        if(!Spectate_CanWatchPlayer(playerid, i) || i == targetid) continue;
                        players[count++] = i;
                    }
                    if(count == 0)
                        return ShowNotificationNew(playerid, 0, 3, 0, 0, "Других игроков не найдено", "");
                    SP_SwitchSpectateTarget(playerid, players[random(count)]);
                }
                case 2:
                {
                    new prev_player = GetNextPlayer(playerid, targetid, -1);
                    if(prev_player == INVALID_PLAYER_ID || prev_player == targetid)
                        return ShowNotificationNew(playerid, 0, 3, 0, 0, "Других игроков не найдено", "");
                    SP_SwitchSpectateTarget(playerid, prev_player);
                }
                case 3, 4, 5, 6, 7, 8: AT_SendPunishTemplates(playerid, button_id);
                case 9:
                {
                    new next_player = GetNextPlayer(playerid, targetid, 1);
                    if(next_player == INVALID_PLAYER_ID || next_player == targetid)
                        return ShowNotificationNew(playerid, 0, 3, 0, 0, "Других игроков не найдено", "");
                    SP_SwitchSpectateTarget(playerid, next_player);
                }
                case 10: ShowPlayerStats(playerid, targetid);
                case 11: ShowControlPanelGUI(playerid);
            }
        }
        case 2:
        {
            if(targetid == -1 || !IsPlayerConnected(targetid))
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок больше не в сети", "");
            AT_ApplyPunishTemplate(playerid, targetid, button_id);
            if(IsPlayerConnected(playerid) && IsPlayerConnected(targetid) && GetPlayerSpectateData(playerid, S_PLAYER) == targetid)
            {
                StartSpectateGUIRefresh(playerid);
                ShowSpectateGUI(playerid, targetid);
            }
        }
        case 6:
        {
            switch(button_id)
            {
                case 0: AT_SendMyTemplates(playerid);
                case 1: SP_ShowCreateTemplateCategory(playerid);
                case 7: AT_SendCategories(playerid);
            }
        }
        case 7:
        {
            if(button_id >= 3 && button_id <= 8)
                AT_SendPunishTemplates(playerid, button_id);
        }
        case 8:
        {
            if(targetid == -1 || !IsPlayerConnected(targetid))
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок больше не в сети", "");
            SP_ApplyCustomTemplate(playerid, targetid, button_id);
            if(IsPlayerConnected(playerid) && IsPlayerConnected(targetid) && GetPlayerSpectateData(playerid, S_PLAYER) == targetid)
            {
                StartSpectateGUIRefresh(playerid);
                ShowSpectateGUI(playerid, targetid);
            }
        }
    }

    return 1;
}
