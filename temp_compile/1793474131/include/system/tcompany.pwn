#if defined _tcompany_system_included
    #endinput
#endif
#define _tcompany_system_included

#define TCOMPANY_START_PRICE        (100000000)
#define TCOMPANY_MAX_FLEET          (12)
#define TCOMPANY_DEFAULT_NAME       "Транспортная компания"

#define DIALOG_TCOMPANY_LIST        (8860)
#define DIALOG_TCOMPANY_JOIN        (8861)
#define DIALOG_TCOMPANY_MENU        (8862)
#define DIALOG_TCOMPANY_INFO        (8863)
#define DIALOG_TCOMPANY_STAFF       (8864)
#define DIALOG_TCOMPANY_DISMISS     (8865)
#define DIALOG_TCOMPANY_FLEET       (8866)
#define DIALOG_TCOMPANY_WITHDRAW    (8867)
#define DIALOG_TCOMPANY_RENAME      (8868)
#define DIALOG_TCOMPANY_SELL        (8869)
#define DIALOG_TCOMPANY_LEAVE       (8870)

new g_tcompany_enter_pickup = -1;
new g_tcompany_exit_pickup = -1;
new g_tcompany_select_pickup = -1;
new Text3D:g_tcompany_enter_label = Text3D:-1;
new Text3D:g_tcompany_exit_label = Text3D:-1;
new Text3D:g_tcompany_select_label = Text3D:-1;

new g_tcompany_list_biz[MAX_PLAYERS][32];
new g_tcompany_list_count[MAX_PLAYERS];
new g_tcompany_staff_accounts[MAX_PLAYERS][64];
new g_tcompany_staff_count[MAX_PLAYERS];

new g_tcompany_vehicle_company[MAX_VEHICLES]; // SQL id компании
new g_tcompany_vehicle_dbid[MAX_VEHICLES];

new const Float:g_tcompany_fleet_spawns[TCOMPANY_MAX_FLEET][4] =
{
    {2342.5000, 2058.2000, 15.9500, 180.0},
    {2337.5000, 2058.2000, 15.9500, 180.0},
    {2332.5000, 2058.2000, 15.9500, 180.0},
    {2327.5000, 2058.2000, 15.9500, 180.0},
    {2322.5000, 2058.2000, 15.9500, 180.0},
    {2317.5000, 2058.2000, 15.9500, 180.0},
    {2342.5000, 2070.0000, 15.9500, 0.0},
    {2337.5000, 2070.0000, 15.9500, 0.0},
    {2332.5000, 2070.0000, 15.9500, 0.0},
    {2327.5000, 2070.0000, 15.9500, 0.0},
    {2322.5000, 2070.0000, 15.9500, 0.0},
    {2317.5000, 2070.0000, 15.9500, 0.0}
};

stock TCompany_PreLoadInit()
{
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `tcompany_meta` ("\
        "`company_id` INT NOT NULL,"\
        "`points` INT NOT NULL DEFAULT 0,"\
        "PRIMARY KEY (`company_id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `tcompany_staff` ("\
        "`company_id` INT NOT NULL,"\
        "`account_id` INT NOT NULL,"\
        "`player_name` VARCHAR(24) NOT NULL DEFAULT '',"\
        "`joined_at` INT NOT NULL DEFAULT 0,"\
        "PRIMARY KEY (`company_id`,`account_id`),"\
        "UNIQUE KEY `uniq_tcompany_account` (`account_id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `tcompany_vehicles` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,"\
        "`company_id` INT NOT NULL,"\
        "`model_id` INT NOT NULL,"\
        "`color_1` INT NOT NULL DEFAULT 1,"\
        "`color_2` INT NOT NULL DEFAULT 1,"\
        "`spawn_slot` INT NOT NULL DEFAULT 0,"\
        "`purchased_at` INT NOT NULL DEFAULT 0,"\
        "PRIMARY KEY (`id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

    new query[768];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO business (type,owner_id,price,rent_price,x,y,z,interior,name,exit_x,exit_y,exit_z,exit_angle) "\
        "SELECT %d,0,%d,0,'2327.705566','2009.635742','16.620204',0,'%e','2327.417700','2013.001800','16.161800','357.826900' "\
        "FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM business WHERE type=%d LIMIT 1)",
        BUSINESS_TYPE_TRUCKING_COMPANY, TCOMPANY_START_PRICE, TCOMPANY_DEFAULT_NAME, BUSINESS_TYPE_TRUCKING_COMPANY);
    mysql_query(mysql, query, false);

    mysql_format(mysql, query, sizeof query,
        "UPDATE business SET price=%d WHERE type=%d", TCOMPANY_START_PRICE, BUSINESS_TYPE_TRUCKING_COMPANY);
    mysql_query(mysql, query, false);

    mysql_format(mysql, query, sizeof query,
        "INSERT IGNORE INTO tcompany_meta (company_id,points) SELECT id,0 FROM business WHERE type=%d",
        BUSINESS_TYPE_TRUCKING_COMPANY);
    mysql_query(mysql, query, false);

    // У свободной ТК не должно оставаться сотрудников от предыдущего владельца.
    mysql_format(mysql, query, sizeof query,
        "DELETE s FROM tcompany_staff s JOIN business b ON b.id=s.company_id WHERE b.type=%d AND b.owner_id=0",
        BUSINESS_TYPE_TRUCKING_COMPANY);
    mysql_query(mysql, query, false);
    return 1;
}

stock TCompany_InitWorld()
{
    g_tcompany_enter_pickup = CreatePickup(19132, 23, 2327.705566, 2009.635742, 16.620204, 0);
    g_tcompany_exit_pickup = CreatePickup(19132, 23, -0.259740, 2500.243896, 2011.005126, -1);
    g_tcompany_select_pickup = CreatePickup(1239, 23, -2.781285, 2503.862792, 2011.040039, -1);

    g_tcompany_enter_label = CreateDynamic3DTextLabel("{FFCC00}Офис транспортных компаний\n{FFFFFF}Вход", 0xFFFFFFFF, 2327.705566, 2009.635742, 17.620204, 20.0);
    g_tcompany_exit_label = CreateDynamic3DTextLabel("{FFCC00}Офис транспортных компаний\n{FFFFFF}Выход", 0xFFFFFFFF, -0.259740, 2500.243896, 2012.005126, 15.0);
    g_tcompany_select_label = CreateDynamic3DTextLabel("{FFCC00}Транспортные компании\n{FFFFFF}Выбор компании", 0xFFFFFFFF, -2.781285, 2503.862792, 2012.040039, 15.0);
    return 1;
}

stock TCompany_FindBusinessBySql(sql_id)
{
    for(new i; i < g_business_loaded; i++)
    {
        if(GetBusinessData(i, B_SQL_ID) == sql_id && GetBusinessData(i, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY)
            return i;
    }
    return -1;
}

stock TCompany_GetOwnedBusinessByAccount(account_id)
{
    if(account_id <= 0) return -1;
    for(new i; i < g_business_loaded; i++)
    {
        if(GetBusinessData(i, B_TYPE) != BUSINESS_TYPE_TRUCKING_COMPANY) continue;
        if(GetBusinessData(i, B_OWNER_ID) == account_id) return i;
    }
    return -1;
}

stock TCompany_GetOwnedBusiness(playerid)
{
    return TCompany_GetOwnedBusinessByAccount(GetPlayerAccountID(playerid));
}

stock TCompany_GetPlayerCompany(playerid)
{
    new owned = TCompany_GetOwnedBusiness(playerid);
    if(owned != -1) return owned;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return -1;

    new query[160];
    mysql_format(mysql, query, sizeof query, "SELECT company_id FROM tcompany_staff WHERE account_id=%d LIMIT 1", account_id);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() || cache_num_rows() <= 0)
    {
        cache_delete(result);
        return -1;
    }
    new sql_id = cache_get_field_content_int(0, "company_id");
    cache_delete(result);
    return TCompany_FindBusinessBySql(sql_id);
}

stock TCompany_GetPoints(businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    new query[128];
    mysql_format(mysql, query, sizeof query, "SELECT points FROM tcompany_meta WHERE company_id=%d LIMIT 1", GetBusinessData(businessid, B_SQL_ID));
    new Cache:result = mysql_query(mysql, query, true);
    new points = 0;
    if(!mysql_errno() && cache_num_rows() > 0) points = cache_get_field_content_int(0, "points");
    cache_delete(result);
    return points;
}

stock TCompany_GetStaffCount(businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    new query[144];
    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM tcompany_staff WHERE company_id=%d", GetBusinessData(businessid, B_SQL_ID));
    new Cache:result = mysql_query(mysql, query, true);
    new count = 0;
    if(!mysql_errno() && cache_num_rows() > 0) count = cache_get_field_content_int(0, "cnt");
    cache_delete(result);
    return count;
}

stock TCompany_ShowCompanyList(playerid)
{
    new text[4096] = "Название\tОчки\tСотрудники\n";
    g_tcompany_list_count[playerid] = 0;

    for(new i; i < g_business_loaded && g_tcompany_list_count[playerid] < 32; i++)
    {
        if(GetBusinessData(i, B_TYPE) != BUSINESS_TYPE_TRUCKING_COMPANY) continue;
        if(!IsBusinessOwned(i)) continue;

        new idx = g_tcompany_list_count[playerid]++;
        g_tcompany_list_biz[playerid][idx] = i;
        new text_pos = strlen(text);
        format(text[text_pos], sizeof(text) - text_pos, "%s\t%d\t%d\n", g_business[i][B_NAME], TCompany_GetPoints(i), TCompany_GetStaffCount(i));
    }

    if(!g_tcompany_list_count[playerid])
        return Dialog(playerid, DIALOG_TCOMPANY_INFO, DIALOG_STYLE_MSGBOX, "Транспортные компании", "{FFFFFF}Сейчас нет купленных транспортных компаний.\n{FFCC00}Свободные ТК продаются через /auction.", "Закрыть", "");

    return Dialog(playerid, DIALOG_TCOMPANY_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Транспортные компании", text, "Выбрать", "Закрыть");
}

stock TCompany_ShowInfo(playerid, businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    new text[512];
    format(text, sizeof text,
        "{FFFFFF}Компания: {FFCC00}%s\n"\
        "{FFFFFF}Владелец: {33CCFF}%s\n"\
        "{FFFFFF}Очки компании: {FFCC00}%d\n"\
        "{FFFFFF}Сотрудников: {FFCC00}%d\n"\
        "{FFFFFF}Баланс: {66CC00}%d руб.\n"\
        "{FFFFFF}Фур в автопарке: {FFCC00}%d/%d",
        GetBusinessData(businessid, B_NAME), GetBusinessData(businessid, B_OWNER_NAME),
        TCompany_GetPoints(businessid), TCompany_GetStaffCount(businessid),
        GetBusinessData(businessid, B_BALANCE), TCompany_GetFleetCount(businessid), TCOMPANY_MAX_FLEET);
    return Dialog(playerid, DIALOG_TCOMPANY_INFO, DIALOG_STYLE_MSGBOX, "Транспортная компания", text, "Закрыть", "");
}

stock TCompany_ShowMenu(playerid)
{
    new businessid = TCompany_GetPlayerCompany(playerid);
    if(businessid == -1)
        return SendClientMessage(playerid, 0xCECECEFF, "Вы не состоите в транспортной компании");

    SetPVarInt(playerid, "tcompany_menu_biz", businessid + 1);
    new bool:is_owner = (GetBusinessData(businessid, B_OWNER_ID) == GetPlayerAccountID(playerid));
    if(is_owner)
    {
        return Dialog(playerid, DIALOG_TCOMPANY_MENU, DIALOG_STYLE_LIST, "Управление транспортной компанией",
            "Информация\nСотрудники\nАвтопарк\nСнять прибыль\nИзменить название\nПродать ТК государству",
            "Выбрать", "Закрыть");
    }
    return Dialog(playerid, DIALOG_TCOMPANY_MENU, DIALOG_STYLE_LIST, "Транспортная компания",
        "Информация\nСотрудники\nАвтопарк\nПокинуть компанию",
        "Выбрать", "Закрыть");
}

CMD:tcompany(playerid, params[])
{
    #pragma unused params
    return TCompany_ShowMenu(playerid);
}

stock TCompany_ShowStaff(playerid, businessid)
{
    new query[256];
    mysql_format(mysql, query, sizeof query,
        "SELECT account_id,player_name FROM tcompany_staff WHERE company_id=%d ORDER BY (account_id=%d) DESC, joined_at ASC",
        GetBusinessData(businessid, B_SQL_ID), GetBusinessData(businessid, B_OWNER_ID));
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return SendClientMessage(playerid, 0xCECECEFF, "Ошибка загрузки сотрудников");
    }

    new rows = cache_num_rows();
    new text[4096] = "Имя\tСтатус\n", name[24];
    g_tcompany_staff_count[playerid] = 0;
    for(new i; i < rows && i < 64; i++)
    {
        new account_id = cache_get_field_content_int(i, "account_id");
        cache_get_field_content(i, "player_name", name, mysql, sizeof name);
        g_tcompany_staff_accounts[playerid][g_tcompany_staff_count[playerid]++] = account_id;
        new text_pos = strlen(text);
        if(account_id == GetBusinessData(businessid, B_OWNER_ID))
            format(text[text_pos], sizeof(text) - text_pos, "%s\t\xc2\xeb\xe0\xe4\xe5\xeb\xe5\xf6\n", name);
        else
            format(text[text_pos], sizeof(text) - text_pos, "%s\t\xc2\xee\xe4\xe8\xf2\xe5\xeb\xfc\n", name);
    }
    cache_delete(result);

    if(!rows) format(text[strlen(text)], sizeof(text) - strlen(text), "Нет сотрудников\t-\n");
    new staff_button[16];
    if(GetBusinessData(businessid, B_OWNER_ID) == GetPlayerAccountID(playerid))
        format(staff_button, sizeof staff_button, "\xd3\xe2\xee\xeb\xe8\xf2\xfc");
    else
        format(staff_button, sizeof staff_button, "\xc7\xe0\xea\xf0\xfb\xf2\xfc");
    return Dialog(playerid, DIALOG_TCOMPANY_STAFF, DIALOG_STYLE_TABLIST_HEADERS, "\xd1\xee\xf2\xf0\xf3\xe4\xed\xe8\xea\xe8 \xd2\xca", text, staff_button, "\xcd\xe0\xe7\xe0\xe4");
}

stock TCompany_ShowFleet(playerid, businessid)
{
    new query[192];
    mysql_format(mysql, query, sizeof query, "SELECT model_id FROM tcompany_vehicles WHERE company_id=%d ORDER BY id ASC", GetBusinessData(businessid, B_SQL_ID));
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return SendClientMessage(playerid, 0xCECECEFF, "Ошибка загрузки автопарка");
    }
    new rows = cache_num_rows();
    new text[3072] = "Модель\n", car_name[32];
    for(new i; i < rows; i++)
    {
        new modelid = cache_get_field_content_int(i, "model_id");
        GetVehicleModelName(modelid, car_name, sizeof car_name);
        new text_pos = strlen(text);
        format(text[text_pos], sizeof(text) - text_pos, "%s [%d]\n", car_name, modelid);
    }
    cache_delete(result);
    if(!rows) format(text[strlen(text)], sizeof(text) - strlen(text), "Автопарк пуст\n");
    return Dialog(playerid, DIALOG_TCOMPANY_FLEET, DIALOG_STYLE_TABLIST_HEADERS, "Автопарк ТК", text, "Закрыть", "Назад");
}

stock TCompany_HandlePickup(playerid, pickupid)
{
    if(pickupid == g_tcompany_enter_pickup)
    {
        SetPlayerPos(playerid, -0.043000, 2503.939600, 2011.045100);
        SetPlayerFacingAngle(playerid, 85.562324);
        SetPlayerInterior(playerid, 1);
        SetPlayerVirtualWorld(playerid, 0);
        return 1;
    }
    if(pickupid == g_tcompany_exit_pickup)
    {
        SetPlayerPos(playerid, 2327.417700, 2013.001800, 16.161800);
        SetPlayerFacingAngle(playerid, 357.826900);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        return 1;
    }
    if(pickupid == g_tcompany_select_pickup)
    {
        SetPlayerFacingAngle(playerid, 85.562324);
        TCompany_ShowCompanyList(playerid);
        return 1;
    }
    return 0;
}

stock TCompany_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_TCOMPANY_LIST:
        {
            if(!response) return 1;
            if(listitem < 0 || listitem >= g_tcompany_list_count[playerid]) return 1;
            new businessid = g_tcompany_list_biz[playerid][listitem];
            if(businessid < 0 || businessid >= g_business_loaded || !IsBusinessOwned(businessid))
                return SendClientMessage(playerid, 0xCECECEFF, "Компания больше недоступна");
            SetPVarInt(playerid, "tcompany_join_biz", businessid + 1);
            new text[384];
            format(text, sizeof text, "{FFFFFF}Компания: {FFCC00}%s\n{FFFFFF}Очки: {FFCC00}%d\n{FFFFFF}Сотрудников: {FFCC00}%d\n\n{FFFFFF}Вы хотите устроиться в эту транспортную компанию?",
                GetBusinessData(businessid, B_NAME), TCompany_GetPoints(businessid), TCompany_GetStaffCount(businessid));
            Dialog(playerid, DIALOG_TCOMPANY_JOIN, DIALOG_STYLE_MSGBOX, "Трудоустройство", text, "Устроиться", "Назад");
            return 1;
        }
        case DIALOG_TCOMPANY_JOIN:
        {
            if(!response) return TCompany_ShowCompanyList(playerid);
            new businessid = GetPVarInt(playerid, "tcompany_join_biz") - 1;
            if(businessid < 0 || businessid >= g_business_loaded || !IsBusinessOwned(businessid)) return 1;
            if(TCompany_GetPlayerCompany(playerid) != -1)
                return SendClientMessage(playerid, 0xCECECEFF, "Вы уже состоите в транспортной компании");

            new query[256];
            mysql_format(mysql, query, sizeof query,
                "INSERT INTO tcompany_staff (company_id,account_id,player_name,joined_at) VALUES (%d,%d,'%e',%d)",
                GetBusinessData(businessid, B_SQL_ID), GetPlayerAccountID(playerid), GetPlayerNameEx(playerid), gettime());
            mysql_query(mysql, query, false);
            if(mysql_errno()) return SendClientMessage(playerid, 0xCECECEFF, "Не удалось устроиться в компанию");

            SetPlayerData(playerid, P_JOB, JOB_TRUCKER);
            UpdatePlayerDatabaseInt(playerid, "job", JOB_TRUCKER);
            SendClientMessage(playerid, 0x66CC00FF, "Вы устроились водителем транспортной компании. Меню: /tcompany");
            return 1;
        }
        case DIALOG_TCOMPANY_MENU:
        {
            if(!response) return 1;
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            if(businessid < 0 || businessid >= g_business_loaded) return 1;
            new bool:is_owner = (GetBusinessData(businessid, B_OWNER_ID) == GetPlayerAccountID(playerid));
            if(is_owner)
            {
                switch(listitem)
                {
                    case 0: TCompany_ShowInfo(playerid, businessid);
                    case 1: TCompany_ShowStaff(playerid, businessid);
                    case 2: TCompany_ShowFleet(playerid, businessid);
                    case 3:
                    {
                        new text[256];
                        format(text, sizeof text, "{FFFFFF}Баланс ТК: {66CC00}%d руб.\n{FFFFFF}Введите сумму для снятия:", GetBusinessData(businessid, B_BALANCE));
                        Dialog(playerid, DIALOG_TCOMPANY_WITHDRAW, DIALOG_STYLE_INPUT, "Снятие прибыли", text, "Снять", "Назад");
                    }
                    case 4: Dialog(playerid, DIALOG_TCOMPANY_RENAME, DIALOG_STYLE_INPUT, "Название компании", "{FFFFFF}Введите новое название транспортной компании (3-23 символа):", "Изменить", "Назад");
                    case 5: Dialog(playerid, DIALOG_TCOMPANY_SELL, DIALOG_STYLE_MSGBOX, "Продажа ТК государству", "{FFFFFF}Продать транспортную компанию государству за {66CC00}70.000.000 руб.{FFFFFF}?\nСотрудники будут уволены, ТК снова попадёт на аукцион.", "Продать", "Отмена");
                }
            }
            else
            {
                switch(listitem)
                {
                    case 0: TCompany_ShowInfo(playerid, businessid);
                    case 1: TCompany_ShowStaff(playerid, businessid);
                    case 2: TCompany_ShowFleet(playerid, businessid);
                    case 3: Dialog(playerid, DIALOG_TCOMPANY_LEAVE, DIALOG_STYLE_MSGBOX, "Транспортная компания", "{FFFFFF}Вы действительно хотите покинуть транспортную компанию?", "Покинуть", "Отмена");
                }
            }
            return 1;
        }
        case DIALOG_TCOMPANY_STAFF:
        {
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            if(!response) return TCompany_ShowMenu(playerid);
            if(businessid < 0 || businessid >= g_business_loaded) return 1;
            if(GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid)) return 1;
            if(listitem < 0 || listitem >= g_tcompany_staff_count[playerid]) return 1;
            new account_id = g_tcompany_staff_accounts[playerid][listitem];
            if(account_id == GetPlayerAccountID(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "Владелец не может уволить самого себя");
            SetPVarInt(playerid, "tcompany_dismiss_account", account_id);
            Dialog(playerid, DIALOG_TCOMPANY_DISMISS, DIALOG_STYLE_MSGBOX, "Увольнение", "{FFFFFF}Уволить выбранного сотрудника из транспортной компании?", "Уволить", "Отмена");
            return 1;
        }
        case DIALOG_TCOMPANY_DISMISS:
        {
            if(!response) return TCompany_ShowMenu(playerid);
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            new account_id = GetPVarInt(playerid, "tcompany_dismiss_account");
            if(businessid < 0 || GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid)) return 1;
            new query[192];
            mysql_format(mysql, query, sizeof query, "DELETE FROM tcompany_staff WHERE company_id=%d AND account_id=%d LIMIT 1", GetBusinessData(businessid, B_SQL_ID), account_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET job=0 WHERE id=%d AND job=%d LIMIT 1", account_id, JOB_TRUCKER);
            mysql_query(mysql, query, false);
            foreach(new i : Player)
            {
                if(GetPlayerAccountID(i) != account_id) continue;
                if(GetPlayerJob(i) == JOB_TRUCKER) SetPlayerData(i, P_JOB, 0);
                SendClientMessage(i, 0xFF6666FF, "Владелец уволил Вас из транспортной компании");
            }
            SendClientMessage(playerid, 0x66CC00FF, "Сотрудник уволен");
            return 1;
        }
        case DIALOG_TCOMPANY_WITHDRAW:
        {
            if(!response) return TCompany_ShowMenu(playerid);
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            if(businessid < 0 || GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid)) return 1;
            new amount = strval(inputtext);
            if(amount <= 0 || amount > GetBusinessData(businessid, B_BALANCE)) return SendClientMessage(playerid, 0xCECECEFF, "Некорректная сумма");
            AddBusinessData(businessid, B_BALANCE, -, amount);
            GivePlayerMoneyEx(playerid, amount, "Снятие прибыли ТК", true, true);
            new query[144];
            mysql_format(mysql, query, sizeof query, "UPDATE business SET balance=%d WHERE id=%d LIMIT 1", GetBusinessData(businessid, B_BALANCE), GetBusinessData(businessid, B_SQL_ID));
            mysql_query(mysql, query, false);
            SendClientMessage(playerid, 0x66CC00FF, "Деньги сняты с баланса транспортной компании");
            return 1;
        }
        case DIALOG_TCOMPANY_RENAME:
        {
            if(!response) return TCompany_ShowMenu(playerid);
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            if(businessid < 0 || GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid)) return 1;
            new len = strlen(inputtext);
            if(len < 3 || len > 23) return SendClientMessage(playerid, 0xCECECEFF, "Название должно содержать от 3 до 23 символов");
            format(g_business[businessid][B_NAME], 24, "%s", inputtext);
            new query[160];
            mysql_format(mysql, query, sizeof query, "UPDATE business SET name='%e' WHERE id=%d LIMIT 1", inputtext, GetBusinessData(businessid, B_SQL_ID));
            mysql_query(mysql, query, false);
            SendClientMessage(playerid, 0x66CC00FF, "Название транспортной компании изменено");
            return 1;
        }
        case DIALOG_TCOMPANY_SELL:
        {
            if(!response) return 1;
            new businessid = GetPVarInt(playerid, "tcompany_menu_biz") - 1;
            if(businessid < 0 || GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid)) return 1;
            new sql_id = GetBusinessData(businessid, B_SQL_ID), query[320];

            // Перед удалением состава сбрасываем работу всем сотрудникам этой ТК.
            foreach(new i : Player)
            {
                if(TCompany_GetPlayerCompany(i) != businessid) continue;
                if(GetPlayerJob(i) == JOB_TRUCKER) SetPlayerData(i, P_JOB, 0);
                if(i != playerid) SendClientMessage(i, 0xFFCC66FF, "Транспортная компания продана государству. Вы больше не являетесь её сотрудником");
            }
            mysql_format(mysql, query, sizeof query, "UPDATE accounts a JOIN tcompany_staff s ON s.account_id=a.id SET a.job=0 WHERE s.company_id=%d AND a.job=%d", sql_id, JOB_TRUCKER);
            mysql_query(mysql, query, false);

            GivePlayerMoneyEx(playerid, 70000000, "Продажа ТК государству", true, true);
            mysql_format(mysql, query, sizeof query, "UPDATE business SET owner_id=0,balance=0,price=%d WHERE id=%d LIMIT 1", TCOMPANY_START_PRICE, sql_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "DELETE FROM tcompany_staff WHERE company_id=%d", sql_id);
            mysql_query(mysql, query, false);
            SetBusinessData(businessid, B_OWNER_ID, 0);
            SetBusinessData(businessid, B_BALANCE, 0);
            SetBusinessData(businessid, B_PRICE, TCOMPANY_START_PRICE);
            format(g_business[businessid][B_OWNER_NAME], 21, "None");
            SetPlayerData(playerid, P_JOB, 0);
            UpdatePlayerDatabaseInt(playerid, "job", 0);
            CallLocalFunction("LoadBusinessToAuction", "");
            SendClientMessage(playerid, 0x66CC00FF, "Вы продали транспортную компанию государству. Она снова выставлена на аукцион");
            return 1;
        }
        case DIALOG_TCOMPANY_LEAVE:
        {
            if(!response) return 1;
            new businessid = TCompany_GetPlayerCompany(playerid);
            if(businessid == -1) return 1;
            if(GetBusinessData(businessid, B_OWNER_ID) == GetPlayerAccountID(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "Владелец не может покинуть собственную ТК");
            new query[160];
            mysql_format(mysql, query, sizeof query, "DELETE FROM tcompany_staff WHERE account_id=%d LIMIT 1", GetPlayerAccountID(playerid));
            mysql_query(mysql, query, false);
            if(GetPlayerJob(playerid) == JOB_TRUCKER)
            {
                SetPlayerData(playerid, P_JOB, 0);
                UpdatePlayerDatabaseInt(playerid, "job", 0);
            }
            SendClientMessage(playerid, 0x66CC00FF, "Вы покинули транспортную компанию");
            return 1;
        }
        case DIALOG_TCOMPANY_FLEET, DIALOG_TCOMPANY_INFO:
        {
            if(!response) return 1;
            return 1;
        }
    }
    return 0;
}

stock TCompany_AuctionAssignOwner(account_id, businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    if(GetBusinessData(businessid, B_TYPE) != BUSINESS_TYPE_TRUCKING_COMPANY) return 0;
    if(TCompany_GetOwnedBusinessByAccount(account_id) != -1) return 0;

    new query[320], name[24];
    mysql_format(mysql, query, sizeof query, "SELECT name FROM accounts WHERE id=%d LIMIT 1", account_id);
    new Cache:result = mysql_query(mysql, query, true);
    if(!mysql_errno() && cache_num_rows() > 0) cache_get_field_content(0, "name", name, mysql, sizeof name);
    cache_delete(result);
    if(!name[0]) format(name, sizeof name, "Account_%d", account_id);

    mysql_format(mysql, query, sizeof query, "UPDATE business SET owner_id=%d,balance=0,price=%d,`lock`=0 WHERE id=%d LIMIT 1", account_id, TCOMPANY_START_PRICE, GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);
    if(mysql_errno()) return 0;

    // Новый владелец получает чистый состав компании; старые назначения не наследуются.
    mysql_format(mysql, query, sizeof query, "DELETE FROM tcompany_staff WHERE company_id=%d OR account_id=%d", GetBusinessData(businessid, B_SQL_ID), account_id);
    mysql_query(mysql, query, false);
    mysql_format(mysql, query, sizeof query, "INSERT IGNORE INTO tcompany_staff (company_id,account_id,player_name,joined_at) VALUES (%d,%d,'%e',%d)", GetBusinessData(businessid, B_SQL_ID), account_id, name, gettime());
    mysql_query(mysql, query, false);
    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET job=%d WHERE id=%d LIMIT 1", JOB_TRUCKER, account_id);
    mysql_query(mysql, query, false);

    SetBusinessData(businessid, B_OWNER_ID, account_id);
    SetBusinessData(businessid, B_BALANCE, 0);
    SetBusinessData(businessid, B_PRICE, TCOMPANY_START_PRICE);
    SetBusinessData(businessid, B_LOCK_STATUS, false);
    format(g_business[businessid][B_OWNER_NAME], 21, "%s", name);

    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != account_id) continue;
        SetPlayerData(i, P_JOB, JOB_TRUCKER);
        SendClientMessage(i, 0x66CC00FF, "Вы выиграли транспортную компанию на аукционе! Управление: /tcompany");
    }
    return 1;
}

stock TCompany_GetFleetCount(businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    new query[144];
    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM tcompany_vehicles WHERE company_id=%d", GetBusinessData(businessid, B_SQL_ID));
    new Cache:result = mysql_query(mysql, query, true);
    new count = 0;
    if(!mysql_errno() && cache_num_rows() > 0) count = cache_get_field_content_int(0, "cnt");
    cache_delete(result);
    return count;
}

stock TCompany_CreateFleetVehicle(dbid, company_sql_id, modelid, color_1, color_2, spawn_slot)
{
    if(spawn_slot < 0 || spawn_slot >= TCOMPANY_MAX_FLEET) spawn_slot = 0;
    new vehicleid = CreateVehicle(modelid,
        g_tcompany_fleet_spawns[spawn_slot][0], g_tcompany_fleet_spawns[spawn_slot][1], g_tcompany_fleet_spawns[spawn_slot][2], g_tcompany_fleet_spawns[spawn_slot][3],
        color_1, color_2, -1, 0, VEHICLE_ACTION_TYPE_TRUCKER, VEHICLE_ACTION_ID_NONE);
    if(vehicleid == INVALID_VEHICLE_ID) return INVALID_VEHICLE_ID;

    g_tcompany_vehicle_company[vehicleid] = company_sql_id;
    g_tcompany_vehicle_dbid[vehicleid] = dbid;
    SetVehicleData(vehicleid, V_FUEL, 100.0);
    SetVehicleParam(vehicleid, V_LOCK, false);

    new businessid = TCompany_FindBusinessBySql(company_sql_id);
    if(businessid != -1)
    {
        new label[96];
        format(label, sizeof label, "{FFCC00}Автопарк ТК\n{FFFFFF}%s", GetBusinessData(businessid, B_NAME));
        CreateVehicleLabel(vehicleid, label, 0xFFFFFFFF, 0.0, 0.0, 1.3, 20.0);
    }
    return vehicleid;
}

stock TCompany_LoadVehicles()
{
    for(new v; v < MAX_VEHICLES; v++)
    {
        g_tcompany_vehicle_company[v] = 0;
        g_tcompany_vehicle_dbid[v] = 0;
    }

    new Cache:result = mysql_query(mysql, "SELECT id,company_id,model_id,color_1,color_2,spawn_slot FROM tcompany_vehicles ORDER BY company_id,id ASC", true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }
    new rows = cache_num_rows();
    for(new i; i < rows; i++)
    {
        new dbid = cache_get_field_content_int(i, "id");
        new company_id = cache_get_field_content_int(i, "company_id");
        new modelid = cache_get_field_content_int(i, "model_id");
        new color_1 = cache_get_field_content_int(i, "color_1");
        new color_2 = cache_get_field_content_int(i, "color_2");
        new spawn_slot = cache_get_field_content_int(i, "spawn_slot");
        TCompany_CreateFleetVehicle(dbid, company_id, modelid, color_1, color_2, spawn_slot);
    }
    cache_delete(result);
    return rows;
}

stock bool:TCompany_IsVehicle(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return false;
    return g_tcompany_vehicle_company[vehicleid] > 0;
}

stock bool:TCompany_CanUseVehicle(playerid, vehicleid)
{
    if(!TCompany_IsVehicle(vehicleid)) return false;
    new businessid = TCompany_GetPlayerCompany(playerid);
    if(businessid == -1) return false;
    return GetBusinessData(businessid, B_SQL_ID) == g_tcompany_vehicle_company[vehicleid];
}

stock TCompany_BuyTruckFromSalon(playerid, marketid, ownablecar)
{
    if(marketid != TRUCK_SALON_MARKET_ID) return 0;
    if(GetPVarInt(playerid, "autosalon_buy_lock") > gettime()) return 1;
    SetPVarInt(playerid, "autosalon_buy_lock", gettime() + 2);

    new businessid = TCompany_GetOwnedBusiness(playerid);
    if(businessid == -1)
        return SendClientMessage(playerid, 0xCECECEFF, "Покупать фуры в грузовом салоне может только владелец транспортной компании");

    if(TCompany_GetFleetCount(businessid) >= TCOMPANY_MAX_FLEET)
        return SendClientMessage(playerid, 0xCECECEFF, "В автопарке транспортной компании нет свободных мест");

    SyncAutosalonSelectedColors(playerid);
    new color_1 = buy_car_select_color[playerid][0];
    new color_2 = buy_car_select_color[playerid][1];
    if(!(0 <= color_1 <= MAX_COLOR_ID)) color_1 = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
    if(!(0 <= color_2 <= MAX_COLOR_ID)) color_2 = GetPlayerData(playerid, P_AUTOSALON_COLOR2);

    new modelid, vehicle_price;
    if(ownablecar < 1000)
    {
        modelid = car_market_data[marketid][ownablecar][CM_MODELID];
        vehicle_price = car_market_data[marketid][ownablecar][CM_COST];
    }
    else modelid = ownablecar - 1000;
    if(!vehicle_price && modelid >= 400) vehicle_price = GetVehicleInfo(modelid - 400, VI_PRICE);
    if(modelid <= 0 || vehicle_price <= 0) return 1;

    if(!AutosalonHasVehicleSlots(marketid, modelid))
        return ShowNotificationLaird(playerid, 2, 6, 0, 0, "Данной фуры нет в наличии", " ");
    if(GetPlayerMoneyEx(playerid) < vehicle_price)
        return SendClientMessage(playerid, 0xCECECEFF, "У Вас недостаточно денег для покупки этой фуры");

    new autosalon_slot_modelid;
    if(!AutosalonTakeVehicleSlot(marketid, modelid, autosalon_slot_modelid))
        return ShowNotificationLaird(playerid, 2, 6, 0, 0, "Данной фуры нет в наличии", " ");

    new spawn_slot = TCompany_GetFleetCount(businessid) % TCOMPANY_MAX_FLEET;
    new query[320];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO tcompany_vehicles (company_id,model_id,color_1,color_2,spawn_slot,purchased_at) VALUES (%d,%d,%d,%d,%d,%d)",
        GetBusinessData(businessid, B_SQL_ID), modelid, color_1, color_2, spawn_slot, gettime());
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        AutosalonAddVehicleSlot(marketid, autosalon_slot_modelid, 1);
        return SendClientMessage(playerid, 0xCECECEFF, "Ошибка сохранения фуры. Деньги не списаны");
    }
    new dbid = cache_insert_id();
    cache_delete(result);

    HideAutosalonTextDraws(playerid);
    ExitPlayerBuyCarMarket(playerid);
    GivePlayerMoneyEx(playerid, -vehicle_price, "Покупка фуры для ТК", true, true);

    new salon_biz = GetBizIdByCarMarketId(marketid);
    if(salon_biz != -1)
    {
        new owner_income = vehicle_price * 75 / 100;
        AddBusinessData(salon_biz, B_BALANCE, +, owner_income);
        mysql_format(mysql, query, sizeof query, "UPDATE business SET balance=%d WHERE id=%d LIMIT 1", GetBusinessData(salon_biz, B_BALANCE), GetBusinessData(salon_biz, B_SQL_ID));
        mysql_query(mysql, query, false);
    }

    TCompany_CreateFleetVehicle(dbid, GetBusinessData(businessid, B_SQL_ID), modelid, color_1, color_2, spawn_slot);
    SendClientMessage(playerid, 0x66CC00FF, "Фура приобретена в автопарк транспортной компании");
    return 1;
}

stock TCompany_AddWorkPoints(playerid, wage)
{
    if(wage <= 0) return 0;
    new businessid = TCompany_GetPlayerCompany(playerid);
    if(businessid == -1) return 0;
    new points = wage / 10000;
    if(points < 1) points = 1;
    new company_income = wage / 10;
    AddBusinessData(businessid, B_BALANCE, +, company_income);
    new query[224];
    mysql_format(mysql, query, sizeof query, "UPDATE tcompany_meta SET points=points+%d WHERE company_id=%d LIMIT 1", points, GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);
    mysql_format(mysql, query, sizeof query, "UPDATE business SET balance=%d WHERE id=%d LIMIT 1", GetBusinessData(businessid, B_BALANCE), GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);
    return points;
}
