#if defined _sander_marketplace_reward_included
    #endinput
#endif
#define _sander_marketplace_reward_included

#define MARKETPLACE_REWARD_CASE_ID       (100)
#define MP_REWARD_GUI_ID                  (74)
#define MP_REWARD_PAGE_SIZE               (12)

#define REWARD_GUI_MODE_NONE                 (0)
#define REWARD_GUI_MODE_BPR                  (1)
#define REWARD_GUI_MODE_MARKETPLACE          (2)
#define REWARD_GUI_MODE_PVAR                 "reward_gui_mode"

forward MPReward_OnGuiListLoaded(playerid, packet_type, offset);

stock MPReward_ResetPlayer(playerid)
{
    SetPVarInt(playerid, "mpreward_offset", 0);
    SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_NONE);
    return 1;
}

stock MPReward_CreateTables()
{
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_reward_items` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `item_id` INT NOT NULL, `item_count` INT NOT NULL DEFAULT 1, `item_plate` VARCHAR(32) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `source_lot` INT NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `account_id` (`account_id`), KEY `source_lot` (`source_lot`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `rewards` (`id` INT NOT NULL AUTO_INCREMENT, `uid` INT NOT NULL, `award_id` INT NOT NULL, `case_id` INT NOT NULL, PRIMARY KEY (`id`), KEY `uid_idx` (`uid`), KEY `case_idx` (`case_id`,`award_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    return 1;
}

stock MPReward_QueueInvItem(account_id, item_id, item_count, const item_plate[], const item_name[], source_lot = 0)
{
    if(account_id <= 0 || item_id <= 0) return 0;
    if(item_count <= 0) item_count = 1;

    new query[768];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_reward_items` (`account_id`,`item_id`,`item_count`,`item_plate`,`item_name`,`source_lot`,`created_at`) VALUES (%d,%d,%d,'%e','%e',%d,%d)",
        account_id, item_id, item_count, item_plate, item_name, source_lot, gettime());

    new Cache:insert_cache = mysql_query(mysql, query, true);
    new reward_item_id = cache_insert_id();
    cache_delete(insert_cache);
    if(reward_item_id <= 0) return 0;

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `rewards` (`uid`,`award_id`,`case_id`) VALUES (%d,%d,%d)",
        account_id, reward_item_id, MARKETPLACE_REWARD_CASE_ID);

    new Cache:reward_cache = mysql_query(mysql, query, true);
    new reward_db_id = cache_insert_id();
    cache_delete(reward_cache);

    if(reward_db_id <= 0)
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1", reward_item_id);
        mysql_tquery(mysql, query);
        return 0;
    }
    return reward_item_id;
}

stock MPReward_GetInvItemData(reward_item_id, &item_id, &item_count, item_plate[], plate_len, item_name[], name_len)
{
    if(reward_item_id <= 0) return 0;

    new query[192];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `item_id`,`item_count`,`item_plate`,`item_name` FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1",
        reward_item_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    item_id = cache_get_field_content_int(0, "item_id", mysql);
    item_count = cache_get_field_content_int(0, "item_count", mysql);
    cache_get_field_content(0, "item_plate", item_plate, mysql, plate_len);
    cache_get_field_content(0, "item_name", item_name, mysql, name_len);
    cache_delete(result);

    if(item_count <= 0) item_count = 1;
    if(item_name[0] == EOS) GetItemName(item_id, item_name, name_len);
    return 1;
}

stock MPReward_DelInvItemData(reward_item_id)
{
    if(reward_item_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1", reward_item_id);
    new Cache:item_result = mysql_query(mysql, query, true);
    new removed = cache_affected_rows(mysql);
    cache_delete(item_result);
    if(!removed) return 0;

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `rewards` WHERE `award_id`=%d AND `case_id`=%d", reward_item_id, MARKETPLACE_REWARD_CASE_ID);
    mysql_tquery(mysql, query);
    return 1;
}

stock bool:MPReward_GetCaseAwardData(award_index, &award_type, &internal_id, &award_count, award_name[], name_size, &spray_price)
{
    new plate[32];
    if(!MPReward_GetInvItemData(award_index, internal_id, award_count, plate, sizeof(plate), award_name, name_size)) return false;

    award_type = 11;
    spray_price = 0;
    return true;
}

stock MPReward_GiveToPlayer(playerid, reward_item_id)
{
    if(!IsPlayerLogged(playerid) || reward_item_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `item_id`,`item_count`,`item_plate`,`item_name` FROM `marketplace_reward_items` WHERE `id`=%d AND `account_id`=%d LIMIT 1",
        reward_item_id, GetPlayerAccountID(playerid));

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new item_count = cache_get_field_content_int(0, "item_count", mysql);
    new item_plate[32], item_name[64];
    cache_get_field_content(0, "item_plate", item_plate, mysql, sizeof(item_plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_delete(result);

    if(item_count <= 0) item_count = 1;

    new free_slot = Inventory_GetDeliverySlot(playerid, item_id);
    if(free_slot == -1)
    {
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\xf2 \xf1\xe2\xee\xe1\xee\xe4\xed\xee\xe3\xee \xec\xe5\xf1\xf2\xe0 \xe2 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xe5. \xcd\xe0\xe3\xf0\xe0\xe4\xe0 \xee\xf1\xf2\xe0\xeb\xe0\xf1\xfc \xe2 /mpreward.", "");
        return 0;
    }

    new added_slot = Inventory_AddItem(playerid, item_id, free_slot, item_count, item_plate);
    if(!added_slot)
    {
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5 \xf3\xe4\xe0\xeb\xee\xf1\xfc \xe4\xee\xe1\xe0\xe2\xe8\xf2\xfc \xef\xf0\xe5\xe4\xec\xe5\xf2 \xe2 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc.", "");
        return 0;
    }

    if(!MPReward_DelInvItemData(reward_item_id))
    {
        // For stackable medkits AddItemToDatabase may merge into an old slot.
        // Remove only what was just added instead of deleting the whole stack.
        Inventory_RemoveItem(playerid, added_slot, item_count);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5 \xf3\xe4\xe0\xeb\xee\xf1\xfc \xef\xee\xe4\xf2\xe2\xe5\xf0\xe4\xe8\xf2\xfc \xef\xee\xeb\xf3\xf7\xe5\xed\xe8\xe5. \xcf\xee\xe2\xf2\xee\xf0\xe8\xf2\xe5 \xef\xee\xe7\xe6\xe5.", "");
        return 0;
    }

    new notify_text[144];
    format(notify_text, sizeof(notify_text), "Marketplace: \xef\xf0\xe5\xe4\xec\xe5\xf2 \xef\xee\xeb\xf3\xf7\xe5\xed: %s x%d.", item_name, Market_IsSingleInventoryEntity(item_id) ? 1 : item_count);
    ShowNotificationLaird(playerid, 1, 5, -1, -1, notify_text, "");
    return 1;
}

stock MPReward_SendPage(playerid, packet_type, offset)
{
    if(!IsPlayerLogged(playerid)) return 0;
    if(offset < 0) offset = 0;

    SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_MARKETPLACE);
    SetPVarInt(playerid, "mpreward_offset", offset);

    new query[640];
    mysql_format(mysql, query, sizeof(query),
        "SELECT r.`id` AS `reward_db_id`,m.`id` AS `reward_item_id`,m.`item_id`,m.`item_count`,m.`item_plate`,m.`item_name` FROM `rewards` r INNER JOIN `marketplace_reward_items` m ON m.`id`=r.`award_id` AND m.`account_id`=r.`uid` WHERE r.`uid`=%d AND r.`case_id`=%d ORDER BY r.`id` DESC LIMIT %d,%d",
        GetPlayerAccountID(playerid), MARKETPLACE_REWARD_CASE_ID, offset, MP_REWARD_PAGE_SIZE + 1);
    mysql_tquery(mysql, query, "MPReward_OnGuiListLoaded", "iii", playerid, packet_type, offset);
    return 1;
}

public MPReward_OnGuiListLoaded(playerid, packet_type, offset)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new rows = cache_num_rows();
    new display_rows = rows;
    if(display_rows > MP_REWARD_PAGE_SIZE) display_rows = MP_REWARD_PAGE_SIZE;

    new Node:reward_array = JSON_Array();
    new skin_count, item_count_total;

    for(new i = 0; i < display_rows; i++)
    {
        new reward_db_id = cache_get_field_content_int(i, "reward_db_id", mysql);
        new item_id = cache_get_field_content_int(i, "item_id", mysql);
        new stored_count = cache_get_field_content_int(i, "item_count", mysql);
        new item_name[64], item_plate[32];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "item_plate", item_plate, mysql, sizeof(item_plate));
        if(!strlen(item_name)) GetItemName(item_id, item_name, sizeof(item_name));

        new display_count = Market_IsSingleInventoryEntity(item_id) ? 1 : stored_count;
        if(display_count < 1) display_count = 1;

        new rarity = 1;
        if(item_id == 134) rarity = 3;
        else if(item_id == 58 || item_id == 59 || item_id == 81 || item_id == 82 || item_id == 83) rarity = 2;

        new Node:item = JSON_Object();
        JSON_SetInt(item, "id", reward_db_id);
        JSON_SetString(item, "n", item_name, sizeof(item_name));
        JSON_SetInt(item, "td", 11);
        JSON_SetInt(item, "st", 1);
        JSON_SetInt(item, "el", item_id);
        JSON_SetInt(item, "c", item_id == 134 ? stored_count : -1);
        JSON_SetInt(item, "ds", 0);
        JSON_SetInt(item, "sp", 0);
        JSON_SetInt(item, "r", rarity);
        JSON_SetInt(item, "ct", display_count);

        new Node:plates = JSON_Array();
        if(strlen(item_plate))
        {
            plates = JSON_Append(plates, JSON_Array(JSON_String(item_plate)));
        }
        JSON_SetArray(item, "els", plates);

        reward_array = JSON_Append(reward_array, JSON_Array(item));
        if(item_id == 134) skin_count++;
        else item_count_total++;
    }

    new Node:json = JSON_Object();
    if(packet_type == 0) JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "t", packet_type);
    JSON_SetInt(json, "tn", 0);
    JSON_SetArray(json, "pr", reward_array);

    new Node:alarms = JSON_Array(
        JSON_Int(display_rows),
        JSON_Int(skin_count),
        JSON_Int(0),
        JSON_Int(item_count_total),
        JSON_Int(0),
        JSON_Int(0),
        JSON_Int(0)
    );
    JSON_SetArray(json, "fl", alarms);

    if(rows <= MP_REWARD_PAGE_SIZE && packet_type == 2) JSON_SetInt(json, "s", -1);
    SendPacketToClient(playerid, MP_REWARD_GUI_ID, json);
    JSON_Cleanup(json);

    #pragma unused offset
    return 1;
}

stock MPReward_OpenGUI(playerid)
{
    if(!IsPlayerLogged(playerid))
        return ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xd1\xed\xe0\xf7\xe0\xeb\xe0 \xe0\xe2\xf2\xee\xf0\xe8\xe7\xf3\xe9\xf2\xe5\xf1\xfc.", "");

    SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_MARKETPLACE);
    SetPVarInt(playerid, "mpreward_open_pending", 1);
    SetPVarInt(playerid, "mpreward_offset", 0);
    return MPReward_SendPage(playerid, 0, 0);
}

stock MPReward_GiveByDatabaseId(playerid, reward_db_id)
{
    if(reward_db_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `award_id` FROM `rewards` WHERE `id`=%d AND `uid`=%d AND `case_id`=%d LIMIT 1",
        reward_db_id, GetPlayerAccountID(playerid), MARKETPLACE_REWARD_CASE_ID);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    new reward_item_id = cache_get_field_content_int(0, "award_id", mysql);
    cache_delete(result);
    return MPReward_GiveToPlayer(playerid, reward_item_id);
}

stock MPReward_OnPacket(playerid, Node:json)
{
    new close_gui;
    JSON_GetInt(json, "c", close_gui);
    if(close_gui == 1)
    {
        SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_NONE);
        HidePlayerGUI(playerid, MP_REWARD_GUI_ID);
        return 1;
    }

    new type;
    JSON_GetInt(json, "t", type);

    switch(type)
    {
        case 1:
        {
            SetPVarInt(playerid, "mpreward_offset", 0);
            MPReward_SendPage(playerid, 1, 0);
        }
        case 2:
        {
            new offset = GetPVarInt(playerid, "mpreward_offset") + MP_REWARD_PAGE_SIZE;
            MPReward_SendPage(playerid, 2, offset);
        }
        case 4:
        {
            new reward_db_id, reward_action;
            JSON_GetInt(json, "id", reward_db_id);
            JSON_GetInt(json, "s", reward_action);

            new success = 0;
            if(reward_action == 1) success = MPReward_GiveByDatabaseId(playerid, reward_db_id);

            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", 4);
            JSON_SetInt(response, "s", success ? 1 : 0);
            JSON_SetInt(response, "id", reward_db_id);
            SendPacketToClient(playerid, MP_REWARD_GUI_ID, response);
            JSON_Cleanup(response);
        }
        default:
        {
            MPReward_OpenGUI(playerid);
        }
    }
    return 1;
}


CMD:mpreward(playerid, params[])
{
    #pragma unused params
    MPReward_OpenGUI(playerid);
    return 1;
}
