// Family notifications are stored in familynew.notif as rows:
// id<TAB>text<TAB>author<LF>
#define FAMILY_GUI_NOTIF_LIMIT (5)
#define FAMILY_GUI_NOTIF_TEXT_LEN (128)
#define FAMILY_GUI_NOTIF_AUTHOR_LEN (32)
#define FAMILY_GUI_NOTIF_RAW_LEN (1024)
#define FAMILY_GUI_TOKEN_BC_PRICE (10)

enum E_FAMILY_GUI_SHOP_ITEM
{
    FAMILY_GUI_SHOP_ID,
    FAMILY_GUI_SHOP_OBJECT_ID,
    FAMILY_GUI_SHOP_PRICE,
    FAMILY_GUI_SHOP_SERVER_ID,
    FAMILY_GUI_SHOP_TYPE,
    FAMILY_GUI_SHOP_TYPE_ID
};

new const FamilyGuiShopItems[][E_FAMILY_GUI_SHOP_ITEM] =
{
    {0, 18526, 80, 389, 0, 3},
    {1, 7378, 100, 442, 0, 0},
    {2, 7344, 60, 408, 0, 0},
    {3, 7374, 100, 438, 0, 0},
    {4, 7387, 100, 451, 0, 0},
    {5, 7385, 100, 449, 0, 0},
    {6, 7397, 50, 461, 0, 0},
    {7, 7390, 60, 454, 0, 0},
    {8, 2641, 100, 0, 1, 4}
};

stock FamilyGuiClampLevel(level)
{
    if(level < 1) return 1;
    if(level > 7) return 7;
    return level;
}

stock FamilyGuiGetVehicleName(model_id, dest[], size = sizeof dest)
{
    GetVehicleModelName(model_id, dest, size);
    return 0;
}

stock FamilyGuiGetSqlFamilyId(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return -1;

    return GetFamily(GetPlayerIdFamily(playerid), family_database);
}

stock FamilyGuiGetNotificationMaxId(ids[FAMILY_GUI_NOTIF_LIMIT], count)
{
    new max_id = 0;

    for(new i; i < count; i++)
    {
        if(ids[i] > max_id)
            max_id = ids[i];
    }

    return max_id;
}

stock FamilyGuiSetNotificationReadState(playerid, family_sql_id, seen_id)
{
    if(family_sql_id == -1)
        return 0;

    SetPlayerData(playerid, P_FAMILY_NOTIF_SEEN, seen_id);
    SetPlayerData(playerid, P_FAMILY_NOTIF_SEEN_FAMILY, family_sql_id);
    UpdatePlayerDatabaseInt(playerid, "family_notif_seen", seen_id);
    UpdatePlayerDatabaseInt(playerid, "family_notif_seen_family", family_sql_id);
    return 1;
}

stock FamilyGuiReserveNotificationId(playerid, current_max_id)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[144];
    new seq_id = 0;

    if(family_sql_id == -1)
        return current_max_id + 1;

    mysql_format(mysql, query, sizeof query, "SELECT notif_seq FROM familynew WHERE id = %d LIMIT 1", family_sql_id);
    new Cache:cache = mysql_query(mysql, query, true);

    if(cache_num_rows())
        seq_id = cache_get_field_content_int(0, "notif_seq");

    cache_delete(cache);

    if(seq_id < current_max_id)
        seq_id = current_max_id;

    seq_id++;

    mysql_format(mysql, query, sizeof query, "UPDATE familynew SET notif_seq = %d WHERE id = %d LIMIT 1", seq_id, family_sql_id);
    mysql_query(mysql, query, false);
    return seq_id;
}

stock FamilyGuiIsNumericString(const value[])
{
    if(!strlen(value))
        return 0;

    for(new i; value[i] != '\0'; i++)
    {
        if(value[i] < '0' || value[i] > '9')
            return 0;
    }

    return 1;
}

stock FamilyGuiTrimString(const source[], dest[], size = sizeof dest)
{
    new start = 0;
    new finish = strlen(source);
    new pos = 0;

    while(source[start] == ' ' || source[start] == '\t')
        start++;

    while(finish > start && (source[finish - 1] == ' ' || source[finish - 1] == '\t'))
        finish--;

    for(new i = start; i < finish && pos < (size - 1); i++)
        dest[pos++] = source[i];

    dest[pos] = '\0';
    return 1;
}

stock FamilyGuiFormatDateTime(timestamp, dest[], size = sizeof dest)
{
    format(dest, size, "%d", timestamp);
    return 1;
}
stock FamilyGuiGetActualMemberCount(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[96];
    new count = 0;

    if(family_id == -1 || family_sql_id == -1)
        return 0;

    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM accounts WHERE family_id = %d", family_sql_id);
    new Cache:cache = mysql_query(mysql, query, true);

    if(cache_num_rows())
        count = cache_get_field_content_int(0, "cnt");

    cache_delete(cache);
    SetFamily(family_id, family_count_people, count);
    return count;
}

stock FamilyGuiFindOnlinePlayerByAccount(account_id)
{
    foreach(new targetid : Player)
    {
        if(GetPlayerAccountID(targetid) != account_id) continue;
        return targetid;
    }

    return INVALID_PLAYER_ID;
}

stock FamilyGuiFindShopItemIndex(shop_id)
{
    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(FamilyGuiShopItems[i][FAMILY_GUI_SHOP_ID] == shop_id)
            return i;
    }

    return -1;
}

stock FamilyGuiResolveRewardShopItemIndex(item_index)
{
    if(item_index < 0 || item_index >= sizeof(FamilyGuiShopItems))
        return -1;

    if(FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_ID] != 0)
        return item_index;

    new reward_indexes[sizeof(FamilyGuiShopItems)];
    new reward_count = 0;

    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(i == item_index)
            continue;

        reward_indexes[reward_count++] = i;
    }

    if(!reward_count)
        return -1;

    return reward_indexes[random(reward_count)];
}

stock FamilyGuiSendShopPurchaseResult(playerid, success, currency_type = 1, new_amount = 0)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 3);
    JSON_SetInt(response, "s", success ? 1 : 0);

    if(success)
    {
        JSON_SetInt(response, "tp", currency_type);
        JSON_SetInt(response, "na", new_amount);
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendTokenPreview(playerid, preview_cost)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 9);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "m", preview_cost);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendTokenPurchaseResult(playerid, success, money_value)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 9);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "r", success ? 1 : 0);
    JSON_SetInt(response, "m", money_value);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleShopPurchase(playerid, shop_id)
{
    new family_id = GetPlayerIdFamily(playerid);
    new item_index = FamilyGuiFindShopItemIndex(shop_id);
    new reward_item_index = -1;
    new item_price = 0;

    if(family_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(item_index == -1)
        return FamilyGuiSendShopPurchaseResult(playerid, 0);

    item_price = FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_PRICE];
    if(GetPlayerMoneti(playerid) < item_price)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "У Вас недостаточно монет.", " ");
        return FamilyGuiSendShopPurchaseResult(playerid, 0);
    }

    reward_item_index = FamilyGuiResolveRewardShopItemIndex(item_index);
    if(reward_item_index == -1)
    {
        printf("[FAMILY_SHOP][ERROR] cannot resolve reward item player=%d shop_id=%d item_index=%d",
            playerid,
            shop_id,
            item_index);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Предмет временно недоступен.", " ");
        return FamilyGuiSendShopPurchaseResult(playerid, 0);
    }

    switch(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_TYPE])
    {
        case 0:
        {
            new modelid = FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_OBJECT_ID];
            new inv_item_id = AccessoryShop_GetInventoryItemByModel(modelid);

            if(inv_item_id <= 0)
            {
                new resolved_item_id = -1;
                new resolved_modelid = -1;

                if(Inv11_ResolveAccessoryReward(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_SERVER_ID], resolved_item_id, resolved_modelid))
                {
                    inv_item_id = resolved_item_id;
                    modelid = resolved_modelid;
                }
            }

            if(inv_item_id <= 0 || modelid <= 0)
            {
                printf("[FAMILY_SHOP][ERROR] cannot resolve item player=%d shop_id=%d object=%d server_id=%d",
                    playerid,
                    shop_id,
                    FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_OBJECT_ID],
                    FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_SERVER_ID]);
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Предмет временно недоступен.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            new inv_slot = Inventory11_AddItemToDatabase(playerid, inv_item_id, modelid, 1, modelid, 0);

            if(inv_slot == -1)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "В инвентаре недостаточно места.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            new db_item_id = 0;
            new db_model_id = 0;
            new db_amount = 0;
            new db_extra_1 = 0;
            new db_extra_2 = 0;
            new db_old_skin = 0;
            new db_sim = 0;
            new db_oldsim = 0;
            new resolved_acc_model = 0;
            new bool:db_loaded = Inv11Trade_GetInventorySlotData(playerid, inv_slot, db_item_id, db_model_id, db_amount, db_extra_1, db_extra_2, db_old_skin, db_sim, db_oldsim);
            new bool:model_loaded = Inv11_GetAccModelBySlot(playerid, inv_slot, inv_item_id, resolved_acc_model);

            printf("[FAMILY_SHOP] player=%d shop_id=%d reward_shop_id=%d item=%d model=%d slot=%d moneti_before=%d",
                playerid,
                shop_id,
                FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_ID],
                inv_item_id,
                modelid,
                inv_slot,
                GetPlayerMoneti(playerid));
            printf("[FAMILY_SHOP][VERIFY] player=%d slot=%d db_loaded=%d item=%d model=%d amount=%d extra_1=%d extra_2=%d old_skin=%d sim=%d oldsim=%d model_loaded=%d resolved_model=%d",
                playerid,
                inv_slot,
                db_loaded,
                db_item_id,
                db_model_id,
                db_amount,
                db_extra_1,
                db_extra_2,
                db_old_skin,
                db_sim,
                db_oldsim,
                model_loaded,
                resolved_acc_model);
        }
        case 1:
        {
            if(GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Данная покупка доступна только лидеру семьи.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            if(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_TYPE_ID] == 4)
            {
                if(GetFamily(family_id, family_syndicate))
                {
                    ShowNotificationNew(playerid, 2, 6, 0, 0, "Данное улучшение уже приобретено.", " ");
                    return FamilyGuiSendShopPurchaseResult(playerid, 0);
                }

                SetFamily(family_id, family_syndicate, 1);
                UpdateColumnFamilyInt(GetFamily(family_id, family_database), "syndicate", 1);
            }
        }
    }

    AddPlayerData(playerid, P_MONETI, -, item_price);
    UpdatePlayerDatabaseInt(playerid, "moneti", GetPlayerMoneti(playerid));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Товар был успешно приобретен.", " ");
    return FamilyGuiSendShopPurchaseResult(playerid, 1, 0, GetPlayerMoneti(playerid));
}

stock FamilyGuiHandleTokenAction(playerid, status, value)
{
    new family_id = GetPlayerIdFamily(playerid);
    new bc_price = 0;

    if(status == 1)
    {
        if(value < 0)
            value = 0;

        return FamilyGuiSendTokenPreview(playerid, value * FAMILY_GUI_TOKEN_BC_PRICE);
    }

    if(status != 2)
        return 1;

    if(family_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(value <= 0)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество монет.", " ");
        return FamilyGuiSendTokenPurchaseResult(playerid, 0, GetPlayerMoneti(playerid));
    }

    bc_price = value * FAMILY_GUI_TOKEN_BC_PRICE;

    if(GetPlayerDonateRub(playerid) < bc_price)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно BC.", " ");
        return FamilyGuiSendTokenPurchaseResult(playerid, 0, GetPlayerMoneti(playerid));
    }

    SetPlayerData(playerid, P_DONATE_RUB, GetPlayerDonateRub(playerid) - bc_price);
    UpdatePlayerDatabaseInt(playerid, "rub", GetPlayerDonateRub(playerid));
    AddPlayerData(playerid, P_MONETI, +, value);
    UpdatePlayerDatabaseInt(playerid, "moneti", GetPlayerMoneti(playerid));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Семейные монеты были успешно приобретены.", " ");
    FamilyGuiSendTokenPurchaseResult(playerid, 1, GetPlayerMoneti(playerid));
    return FamilyGuiSendShopPurchaseResult(playerid, 1, 1, GetFamily(family_id, family_zaxvati));
}

stock FamilyGuiSanitizeNotificationText(const source[], dest[], size = sizeof dest)
{
    new pos = 0;

    for(new i; source[i] != '\0'; i++)
    {
        new ch = source[i];

        if(ch == '\r' || ch == '\n' || ch == '\t')
            ch = ' ';

        if(pos < (size - 1))
            dest[pos++] = ch;
    }

    while(pos > 0 && dest[pos - 1] == ' ')
        pos--;

    dest[pos] = '\0';
    return 1;
}

stock FamilyGuiNotificationReadField(const source[], &offset, delimiter, dest[], size = sizeof dest)
{
    new pos = 0;

    while(source[offset] != '\0' && source[offset] != delimiter)
    {
        if(pos < (size - 1))
            dest[pos++] = source[offset];
        offset++;
    }

    dest[pos] = '\0';

    if(source[offset] == delimiter)
        offset++;

    return 1;
}

stock FamilyGuiCopySlice(const source[], start, length, dest[], size = sizeof dest)
{
    new pos = 0;

    while(pos < length && pos < (size - 1) && source[start + pos] != EOS)
    {
        dest[pos] = source[start + pos];
        pos++;
    }

    dest[pos] = EOS;
    return 1;
}

stock FamilyGuiParseNotifications(const raw[], family_sql_id, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], &count, &rewritten)
{
    new offset = 0;
    new notif_line[256];
    new token_index[4];
    new token_length[4];
    new id_buffer[16];
    new text_buffer[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author_buffer[FAMILY_GUI_NOTIF_AUTHOR_LEN];

    count = 0;
    rewritten = 0;

    while(raw[offset] != EOS && count < FAMILY_GUI_NOTIF_LIMIT)
    {
        new line_len = 0;
        new token_count = 0;
        new current_family_sql_id = family_sql_id;

        while(raw[offset] != EOS && raw[offset] != 10 && line_len < (sizeof(notif_line) - 1))
            notif_line[line_len++] = raw[offset++];

        if(raw[offset] == 10)
            offset++;

        notif_line[line_len] = EOS;

        if(!line_len)
            continue;

        token_index[0] = 0;
        for(new i; ; i++)
        {
            if(notif_line[i] == 9 || notif_line[i] == EOS)
            {
                token_length[token_count] = i - token_index[token_count];
                token_count++;

                if(notif_line[i] == EOS || token_count >= 4)
                    break;

                token_index[token_count] = i + 1;
            }
        }

        if(token_count < 3)
        {
            rewritten = 1;
            continue;
        }

        if(token_count >= 4)
        {
            new family_buffer[16];
            FamilyGuiCopySlice(notif_line, token_index[0], token_length[0], family_buffer, sizeof family_buffer);
            current_family_sql_id = strval(family_buffer);
            FamilyGuiCopySlice(notif_line, token_index[1], token_length[1], id_buffer, sizeof id_buffer);
            FamilyGuiCopySlice(notif_line, token_index[2], token_length[2], text_buffer, sizeof text_buffer);
            FamilyGuiCopySlice(notif_line, token_index[3], token_length[3], author_buffer, sizeof author_buffer);
        }
        else
        {
            FamilyGuiCopySlice(notif_line, token_index[0], token_length[0], id_buffer, sizeof id_buffer);
            FamilyGuiCopySlice(notif_line, token_index[1], token_length[1], text_buffer, sizeof text_buffer);
            FamilyGuiCopySlice(notif_line, token_index[2], token_length[2], author_buffer, sizeof author_buffer);
            rewritten = 1;
        }

        if(!strlen(id_buffer) || !strlen(text_buffer))
        {
            rewritten = 1;
            continue;
        }

        if(current_family_sql_id != family_sql_id)
        {
            rewritten = 1;
            continue;
        }

        ids[count] = strval(id_buffer);
        format(values[count], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", text_buffer);
        format(authors[count], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", author_buffer);
        count++;
    }

    return 1;
}

stock FamilyGuiBuildNotificationsRaw(family_sql_id, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], count, dest[], size = sizeof dest)
{
    new family_text[16];
    new id_text[16];
    new value_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author_text[FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new dest_len = 0;

    dest[0] = EOS;
    format(family_text, sizeof family_text, "%d", family_sql_id);

    for(new i; i < count && i < FAMILY_GUI_NOTIF_LIMIT; i++)
    {
        new value_len = 0;
        new author_len = 0;

        while(value_len < (FAMILY_GUI_NOTIF_TEXT_LEN - 1) && values[i][value_len] != EOS)
        {
            value_text[value_len] = values[i][value_len];
            value_len++;
        }
        value_text[value_len] = EOS;

        while(author_len < (FAMILY_GUI_NOTIF_AUTHOR_LEN - 1) && authors[i][author_len] != EOS)
        {
            author_text[author_len] = authors[i][author_len];
            author_len++;
        }
        author_text[author_len] = EOS;

        format(id_text, sizeof id_text, "%d", ids[i]);

        if((dest_len + strlen(family_text) + strlen(id_text) + strlen(value_text) + strlen(author_text) + 4) >= size)
            break;

        for(new j; family_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = family_text[j];
        dest[dest_len++] = 9;

        for(new j; id_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = id_text[j];
        dest[dest_len++] = 9;

        for(new j; value_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = value_text[j];
        dest[dest_len++] = 9;

        for(new j; author_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = author_text[j];
        dest[dest_len++] = 10;

        dest[dest_len] = EOS;
    }

    return 1;
}

stock FamilyGuiLoadNotifications(playerid, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], &count)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw[FAMILY_GUI_NOTIF_RAW_LEN];
    new rewritten = 0;

    count = 0;
    raw[0] = EOS;

    if(family_sql_id == -1)
        return 0;

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT notif FROM familynew WHERE id = %d LIMIT 1", family_sql_id);
    new Cache:cache = mysql_query(mysql, f_string144, true);

    if(cache_num_rows())
        cache_get_field_content(0, "notif", raw, mysql, sizeof raw);

    cache_delete(cache);
    FamilyGuiParseNotifications(raw, family_sql_id, ids, values, authors, count, rewritten);

    if(rewritten)
        FamilyGuiSaveNotifications(playerid, ids, values, authors, count);

    return 1;
}

stock FamilyGuiSaveNotifications(playerid, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], count)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw[FAMILY_GUI_NOTIF_RAW_LEN];

    if(family_sql_id == -1)
        return 0;

    FamilyGuiBuildNotificationsRaw(family_sql_id, ids, values, authors, count, raw, sizeof raw);

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE familynew SET notif = '%e' WHERE id = %d LIMIT 1", raw, family_sql_id);
    mysql_query(mysql, f_string184, false);
    return !mysql_errno();
}

stock FamilyGuiGetNotificationCount(playerid)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new seen_id = 0;
    new seen_family_sql_id = 0;
    new unread_count = 0;

    if(family_sql_id == -1)
        return 0;

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);
    seen_id = GetPlayerData(playerid, P_FAMILY_NOTIF_SEEN);
    seen_family_sql_id = GetPlayerData(playerid, P_FAMILY_NOTIF_SEEN_FAMILY);

    if(seen_family_sql_id != family_sql_id)
        return count;

    for(new i; i < count; i++)
    {
        if(ids[i] > seen_id)
            unread_count++;
    }

    return unread_count;
}

stock ShowFamilyGui(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    new Node:response = JSON_Object();
    new family_id = GetPlayerIdFamily(playerid);
    new family_name_text[96];
    new player_name[MAX_PLAYER_NAME + 1];

    format(player_name, sizeof player_name, "%s", GetPlayerNameEx(playerid));
    format(family_name_text, sizeof family_name_text, "%s", family[family_id][family_name]);

    JSON_SetString(response, "n", family_name_text);
    JSON_SetInt(response, "k", GetPlayerRangFamily(playerid) == 5 ? 1 : 0);
    JSON_SetInt(response, "m", GetPlayerMoneti(playerid));
    JSON_SetInt(response, "j", GetFamily(family_id, family_zaxvati));
    JSON_SetInt(response, "y", FamilyGuiGetNotificationCount(playerid));
    JSON_SetInt(response, "b", 0);
    JSON_SetString(response, "pn", player_name);
    JSON_SetInt(response, "pi", playerid);
    JSON_SetInt(response, "is", GetFamily(family_id, family_syndicate));

    ShowPlayerGUI(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarActionResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "d", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendLeaveResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 10);
    JSON_SetInt(response, "s", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotificationAdded(playerid, text[], author[], notif_id)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 6);
    JSON_SetInt(response, "b", 1);
    JSON_SetString(response, "k", text, strlen(text) + 1);
    JSON_SetString(response, "n", author, strlen(author) + 1);
    JSON_SetInt(response, "x", notif_id);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotificationDeleted(playerid, deleted_id)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 6);
    JSON_SetInt(response, "b", 2);
    JSON_SetInt(response, "d", deleted_id);
    JSON_SetString(response, "k", "");
    JSON_SetString(response, "n", "");
    JSON_SetInt(response, "x", -1);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarList(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:id_list = JSON_Array();
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "g", 0);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string144, sizeof f_string144, "SELECT id, model_id FROM family_cars WHERE family_owner = %d", family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string144, true);
        new rows = cache_num_rows();

        if(!rows)
        {
            cache_delete(cache);
            JSON_Cleanup(response);
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "В семье нет машин.", " ");
        }

        for(new i; i < rows; i++)
        {
            new sql_id = cache_get_field_content_int(i, "id");
            new model_id = cache_get_field_content_int(i, "model_id");
            new model_name[32];

            FamilyGuiGetVehicleName(model_id, model_name, sizeof model_name);

            name_list = JSON_Append(name_list, JSON_Array(JSON_String(model_name)));
            id_list = JSON_Append(id_list, JSON_Array(JSON_Int(sql_id)));
        }

        cache_delete(cache);
    }

    JSON_SetArray(response, "n", name_list);
    JSON_SetArray(response, "id", id_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarInfo(playerid, sql_id)
{
    new Node:response = JSON_Object();
    new car_rank = 1;
    new car_status = 0;
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string144, sizeof f_string144, "SELECT rang FROM family_cars WHERE id = %d AND family_owner = %d LIMIT 1", sql_id, family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string144, true);

        if(cache_num_rows())
        {
            car_rank = cache_get_field_content_int(0, "rang");
            car_status = GetStatusFamilyCar(sql_id);
        }

        cache_delete(cache);
    }

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "r", car_rank);
    JSON_SetInt(response, "d", car_status);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleCarAction(playerid, Node:request)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return FamilyGuiSendCarActionResult(playerid, 0);

    new sql_id;
    new action_id;

    if(JSON_GetType(request, "m") != JSON_NODE_NUMBER || JSON_GetType(request, "id") != JSON_NODE_NUMBER)
        return FamilyGuiSendCarActionResult(playerid, 0);

    JSON_GetInt(request, "m", sql_id);
    JSON_GetInt(request, "id", action_id);

    new family_id = GetPlayerIdFamily(playerid);
    new bool:is_family_owner = GetFamily(family_id, family_owner) == GetPlayerAccountID(playerid);

    if(action_id == 0 && GetStatusFamilyCar(sql_id))
    {
        new vehicleid = GetVehicleFamilyCar(sql_id);
        if(vehicleid != INVALID_VEHICLE_ID)
        {
            new Float:x, Float:y, Float:z;
            GetVehiclePos(vehicleid, x, y, z);
            EnablePlayerGPS(playerid, 55, x, y, z, "");
            ShowNotificationNew(playerid, 3, 6, 0, 0, "Местоположение семейного транспорта отмечено на GPS", " ");
            return FamilyGuiSendCarActionResult(playerid, 1);
        }
    }

    mysql_format(mysql, f_string184, sizeof f_string184, "SELECT model_id, rang, pos_x, pos_y, pos_z, angle FROM family_cars WHERE id = %d AND family_owner = %d LIMIT 1", sql_id, FamilyGuiGetSqlFamilyId(playerid));
    new Cache:cache = mysql_query(mysql, f_string184, true);

    if(!cache_num_rows())
    {
        cache_delete(cache);
        return FamilyGuiSendCarActionResult(playerid, 0);
    }

    new model_id = cache_get_field_content_int(0, "model_id");
    new car_rank = cache_get_field_content_int(0, "rang");
    new success = 0;
    new player_rank = GetPlayerRangFamily(playerid);
    new rank_name[24];
    new vehicle_name[32];
    new family_text[200];

    if(player_rank >= 1 && player_rank <= 5)
        format(rank_name, sizeof rank_name, "%s", family_rang_name[family_id][player_rank - 1]);
    else
        format(rank_name, sizeof rank_name, "%d ранг", player_rank);

    FamilyGuiGetVehicleName(model_id, vehicle_name, sizeof vehicle_name);

    switch(action_id)
    {
        case 0:
        {
            new Float:x = cache_get_field_content_float(0, "pos_x");
            new Float:y = cache_get_field_content_float(0, "pos_y");
            new Float:z = cache_get_field_content_float(0, "pos_z");

            if(GetStatusFamilyCar(sql_id))
            {
                new vehicleid = GetVehicleFamilyCar(sql_id);
                if(vehicleid != INVALID_VEHICLE_ID) GetVehiclePos(vehicleid, x, y, z);
            }

            EnablePlayerGPS(playerid, 55, x, y, z, "");
            ShowNotificationNew(playerid, 3, 6, 0, 0, "Местоположение семейного транспорта отмечено на GPS", " ");
            success = 1;
        }
        case 1, 6:
        {
            if(GetPlayerRangFamily(playerid) < car_rank)
            {
                ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не можете загрузить данное ТС", " ");
            }
            else if(!GetStatusFamilyCar(sql_id))
            {
                success = LoadFamilyCar(sql_id);
                if(success)
                {
                    ShowNotificationNew(playerid, 3, 5, 0, 0, "Автомобиль успешно загружен.", " ");
                    format(family_text, sizeof family_text, "%s %s[%d] загрузил автомобиль %s", rank_name, GetPlayerNameEx(playerid), playerid, vehicle_name);
                    SendFamilyMessage(family_id, family_text);
                    SendFamilyLog(type_log_car, playerid, -1, family_text);
                }
            }
        }
        case 5:
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Система гаражей временно недоступна.", " ");
        }
        case 2:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 5, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else if((GetPlayerOwnableCars(playerid) + 1) <= GetPlayerCarSlots(playerid))
            {
                success = MoveFamilyCar(sql_id, playerid);
            }
        }
        case 3:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else
            {
                new access_action = -1;
                new new_rank = car_rank;

                JSON_GetInt(request, "r", access_action);

                if(access_action == 0 && new_rank > 1) new_rank--;
                else if(access_action == 1 && new_rank < 5) new_rank++;

                if(new_rank != car_rank)
                {
                    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE family_cars SET rang = %d WHERE id = %d LIMIT 1", new_rank, sql_id);
                    mysql_query(mysql, f_string144, false);

                    if(!mysql_errno())
                    {
                        new vehicleid = GetVehicleFamilyCar(sql_id);
                        if(vehicleid != INVALID_VEHICLE_ID)
                        {
                            SetCarFamily(GetVehicleData(vehicleid, V_ACTION_ID), V_F_RANG, new_rank);
                        }
                        ShowNotificationNew(playerid, 3, 6, 0, 0, "Ранг использования автомобиля был успешно изменен", " ");
                        success = 1;
                    }
                }
            }
        }
        case 4:
        {
            if(GetStatusFamilyCar(sql_id))
            {
                new vehicleid = GetVehicleFamilyCar(sql_id);
                if(vehicleid == INVALID_VEHICLE_ID)
                {
                    success = 0;
                }
                else if(GetVehicleDriver(vehicleid) != playerid && GetPlayerRangFamily(playerid) != 5)
                {
                    ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы должны быть за рулем данного автомобиля.", " ");
                }
                else
                {
                    success = UnLoadFamilyCar(sql_id) == 1;
                    if(success)
                    {
                        ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы успешно выгрузили транспорт", " ");
                        format(family_text, sizeof family_text, "%s %s[%d] выгрузил транспорт \"%s\"", rank_name, GetPlayerNameEx(playerid), playerid, vehicle_name);
                        SendFamilyMessage(family_id, family_text);
                        SendFamilyLog(type_log_car, playerid, -1, family_text);
                    }
                }
            }
        }
        case 7:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else
            {
                if(GetStatusFamilyCar(sql_id))
                {
                    new vehicleid = GetVehicleFamilyCar(sql_id);
                    if(vehicleid != INVALID_VEHICLE_ID)
                    {
                        new Float:x, Float:y, Float:z, Float:a;
                        GetVehiclePos(vehicleid, x, y, z);
                        GetVehicleZAngle(vehicleid, a);

                        mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE family_cars SET pos_x = %f, pos_y = %f, pos_z = %f, angle = %f WHERE id = %d LIMIT 1", x, y, z, a, sql_id);
                        mysql_query(mysql, f_string184, false);
                        success = !mysql_errno();
                    }
                }
                else
                {
                    success = 1;
                }

                if(success)
                    ShowNotificationNew(playerid, 3, 6, 0, 0, "Парковка была успешно сброшена", " ");
            }
        }
    }

    cache_delete(cache);
    return FamilyGuiSendCarActionResult(playerid, success);
}
stock FamilyGuiGetSettingAccessMinRank(family_id, access_idx)
{
    for(new rank = 1; rank <= 5; rank++)
    {
        if(family_rang_dostup[family_id][rank - 1][access_idx])
            return rank;
    }

    return 5;
}

stock FamilyGuiSetSettingAccessMinRank(family_id, access_idx, min_rank)
{
    if(min_rank < 1) min_rank = 1;
    if(min_rank > 5) min_rank = 5;

    for(new rank = 1; rank <= 5; rank++)
    {
        family_rang_dostup[family_id][rank - 1][access_idx] = rank >= min_rank;
        UpdateDostupFamily(family_id, rank - 1);
    }

    return 1;
}

stock FamilyGuiGetChatColorUiId(color_idx)
{
    if(color_idx < 0 || color_idx >= sizeof(family_type_color))
        return 0;

    return color_idx;
}

stock FamilyGuiSendFamilySettings(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new Node:response = JSON_Object();
    new Node:rank_name_list = JSON_Array();
    new Node:rank_access_list = JSON_Array();

    if(family_id == -1)
    {
        JSON_Cleanup(response);
        return 0;
    }

    for(new i; i < 5; i++)
    {
        rank_name_list = JSON_Append(rank_name_list, JSON_Array(JSON_String(family_rang_name[family_id][i])));
        rank_access_list = JSON_Append(rank_access_list, JSON_Array(JSON_Int(FamilyGuiGetSettingAccessMinRank(family_id, i))));
    }

    rank_access_list = JSON_Append(rank_access_list, JSON_Array(JSON_Int(5)));

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "st", 1);
    JSON_SetInt(response, "l", FamilyGuiGetChatColorUiId(GetFamily(family_id, family_color)));
    JSON_SetInt(response, "cl", FamilyGuiGetChatColorUiId(GetFamily(family_id, family_color)));
    JSON_SetArray(response, "r", rank_name_list);
    JSON_SetArray(response, "rp", rank_access_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingRankUpdate(playerid, rank_pos)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "n", 1);
    JSON_SetInt(response, "r", rank_pos);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, bool:success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "n", success ? 1 : 0);
    JSON_SetInt(response, "k", access_pos);

    if(success)
    {
        JSON_SetInt(response, "r", rank_pos);
        JSON_SetInt(response, "b", access_state);
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingColorUpdate(playerid, color_pos)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 3);
    JSON_SetInt(response, "n", 1);
    JSON_SetInt(response, "r", color_pos);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleFamilySettingRank(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_pos = 0;
    new new_name[24];

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER || JSON_GetType(request, "n") != JSON_NODE_STRING)
        return 0;

    JSON_GetInt(request, "r", rank_pos);
    JSON_GetString(request, "n", new_name, sizeof new_name);

    if(rank_pos < 1 || rank_pos > 5)
        return 0;

    if(strlen(new_name) < 3 || strlen(new_name) > 23 || strfind(new_name, ",") != -1)
        return 0;

    format(family_rang_name[family_id][rank_pos - 1], 24, "%s", new_name);
    UpdateDostupFamily(family_id, rank_pos - 1);
    return FamilyGuiSendFamilySettingRankUpdate(playerid, rank_pos);
}

stock FamilyGuiHandleFamilySettingAccess(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_pos = 0;
    new access_pos = -1;
    new access_state = 0;

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER || JSON_GetType(request, "k") != JSON_NODE_NUMBER || JSON_GetType(request, "n") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "r", rank_pos);
    JSON_GetInt(request, "k", access_pos);
    JSON_GetInt(request, "n", access_state);

    if(rank_pos < 1 || rank_pos > 5 || access_pos < 0 || access_pos > 5)
        return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, false);

    if(access_pos == 5)
        return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, false);

    FamilyGuiSetSettingAccessMinRank(family_id, access_pos, access_state ? rank_pos : 5);
    return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state ? 1 : 0, true);
}

stock FamilyGuiHandleFamilySettingColor(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new color_pos = 0;

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "r", color_pos);

    if(color_pos < 0 || color_pos >= sizeof(family_type_color))
        return 0;

    SetFamily(family_id, family_color, color_pos);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "chatcolor", GetFamily(family_id, family_color));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Цвет семьи успешно был изменен.", " ");
    return FamilyGuiSendFamilySettingColorUpdate(playerid, color_pos);
}
stock FamilyGuiSendPlayerActionResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "r", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiResetPlayerState(playerid)
{
    DeletePVar(playerid, "family_gui_target_accid");
    return 1;
}

stock FamilyGuiSendPlayerList(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:rank_status_list = JSON_Array();
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new self_account_id = GetPlayerAccountID(playerid);
    new bool:self_added = false;

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 0);
    FamilyGuiResetPlayerState(playerid);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT id, name, family_rang FROM accounts WHERE family_id = %d ORDER BY family_rang DESC, name ASC", family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string184, true);

        for(new i, rows = cache_num_rows(); i < rows; i++)
        {
            new account_id = cache_get_field_content_int(i, "id");
            new name[24];
            new rank = cache_get_field_content_int(i, "family_rang");
            new online = 0;

            cache_get_field_content(i, "name", name, mysql, sizeof name);

            foreach(new targetid : Player)
            {
                if(GetPlayerAccountID(targetid) != account_id) continue;
                online = 1;
                break;
            }

            if(account_id == self_account_id)
                self_added = true;

            name_list = JSON_Append(name_list, JSON_Array(JSON_String(name)));
            rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(rank)));
            rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(online)));
        }

        cache_delete(cache);
    }

    if(!self_added && GetPlayerIdFamily(playerid) != -1)
    {
        name_list = JSON_Append(name_list, JSON_Array(JSON_String(GetPlayerNameEx(playerid))));
        rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(GetPlayerRangFamily(playerid))));
        rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(1)));
    }

    JSON_SetArray(response, "np", name_list);
    JSON_SetArray(response, "rs", rank_status_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendPlayerInfo(playerid, const selected_name[])
{
    new Node:response = JSON_Object();
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new rank = 1;
    new mute_time = 0;
    new vig_count = 0;
    new level = 1;
    new phone = 0;
    new skin = 0;
    new account_id = -1;

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT id, family_rang, family_mute, family_vig, level, phone, skin FROM accounts WHERE family_id = %d AND name = '%e' LIMIT 1", family_sql_id, selected_name);
        new Cache:cache = mysql_query(mysql, f_string184, true);

        if(cache_num_rows())
        {
            account_id = cache_get_field_content_int(0, "id");
            rank = cache_get_field_content_int(0, "family_rang");
            mute_time = cache_get_field_content_int(0, "family_mute");
            vig_count = cache_get_field_content_int(0, "family_vig");
            level = cache_get_field_content_int(0, "level");
            phone = cache_get_field_content_int(0, "phone");
            skin = cache_get_field_content_int(0, "skin");
        }

        cache_delete(cache);
    }

    if(account_id != -1)
    {
        SetPVarInt(playerid, "family_gui_target_accid", account_id);

        foreach(new targetid : Player)
        {
            if(GetPlayerAccountID(targetid) != account_id) continue;

            rank = GetPlayerRangFamily(targetid);
            mute_time = GetPlayerFamily(targetid, MUTE_FAMILY);
            vig_count = GetPlayerFamily(targetid, VIG_FAMILY);
            level = GetPlayerLevel(targetid);
            phone = GetPlayerPhone(targetid);
            skin = GetPlayerSkin(targetid);
            break;
        }
    }
    else
    {
        FamilyGuiResetPlayerState(playerid);
    }

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "sk", skin);
    JSON_SetInt(response, "rb", level);
    JSON_SetInt(response, "rv", vig_count);
    JSON_SetInt(response, "rp", phone);
    JSON_SetInt(response, "m", mute_time);
    if(family_id != -1 && rank >= 1 && rank <= 5)
        JSON_SetString(response, "rn", family_rang_name[family_id][rank - 1]);
    else
        JSON_SetString(response, "rn", "Участник");

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiRemoveMemberFromFamily(targetid, target_account_id)
{
    SetPlayerFamily(targetid, ID_FAMILY, -1);
    SetPlayerFamily(targetid, ID_SQL_FAMILY, -1);

    DestroyDynamic3DTextLabel(GetPlayerFamily(targetid, TEXT_FAMILY));
    SetPlayerFamily(targetid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(targetid, RANG_FAMILY, 0);
    SetPlayerFamily(targetid, MUTE_FAMILY, 0);
    SetPlayerFamily(targetid, VIG_FAMILY, 0);

    SetPlayerFamily(targetid, ACCESS_GIVE, 0);
    SetPlayerFamily(targetid, ACCESS_MONEY, 0);
    SetPlayerFamily(targetid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(targetid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(targetid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(targetid, ACCESS_PATRON, 0);
    SetPlayerFamily(targetid, ACCESS_MASK, 0);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=-1, family_rang=0, family_mute=0, family_vig=0, family_access='0,0,0,0,0,0,0' WHERE id = %d LIMIT 1", target_account_id);
    mysql_query(mysql, f_string144, false);
    return !mysql_errno();
}

stock FamilyGuiHandlePlayerAction(playerid, Node:request)
{
    new f = GetPlayerIdFamily(playerid);
    new target_account_id = GetPVarInt(playerid, "family_gui_target_accid");
    new action_type = -1;
    new action_value = -1;
    new targetid;
    new success = 0;
    new new_rank;
    new mute_time;
    new new_mute;
    new vig_count;
    new new_vig;
    new player_name[MAX_PLAYER_NAME + 1];
    new target_name[MAX_PLAYER_NAME + 1];
    new notify_text[144];
    new family_text[200];
    new target_text[144];

    if(f == -1 || target_account_id <= 0)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    JSON_GetInt(request, "r", action_type);
    JSON_GetInt(request, "k", action_value);

    if(target_account_id == GetPlayerAccountID(playerid))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы не можете взаимодействовать с собой.", " ");
        return FamilyGuiSendPlayerActionResult(playerid, 0);
    }

    targetid = FamilyGuiFindOnlinePlayerByAccount(target_account_id);
    if(targetid == INVALID_PLAYER_ID)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetPlayerIdFamily(targetid) != f)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetFamily(f, family_owner) == target_account_id)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetPlayerRangFamily(targetid) >= GetPlayerRangFamily(playerid))
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    format(player_name, sizeof player_name, "%s", GetPlayerNameEx(playerid));
    format(target_name, sizeof target_name, "%s", GetPlayerNameEx(targetid));

    switch(action_type)
    {
        case 0:
        {
            if((!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2]) && GetPlayerRangFamily(playerid) != 5)
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            new_rank = GetPlayerRangFamily(targetid);

            if(action_value == 0 && new_rank > 1)
                new_rank--;
            else if(action_value == 1 && (new_rank + 1) < GetPlayerRangFamily(playerid))
                new_rank++;

            if(new_rank != GetPlayerRangFamily(targetid))
            {
                SetPlayerFamily(targetid, RANG_FAMILY, new_rank);
                UpdatePlayerDatabaseInt(targetid, "family_rang", new_rank);

                format(notify_text, sizeof notify_text, "Вы установили %d ранг игроку %s", new_rank, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам семейный ранг на %d", player_name, new_rank);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил ранг на %d игроку %s", player_name, playerid, new_rank, target_name);
                SendFamilyMessage(f, family_text);
                SendFamilyLog(type_log_rang, playerid, targetid, family_text);
                success = 1;
            }
        }
        case 1:
        {
            if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            vig_count = GetPlayerFamily(targetid, VIG_FAMILY);
            new_vig = vig_count;

            if(action_value == 0 && new_vig > 0)
                new_vig--;
            else if(action_value == 1 && new_vig < 3)
                new_vig++;

            if(new_vig != vig_count)
            {
                SetPlayerFamily(targetid, VIG_FAMILY, new_vig);
                UpdatePlayerDatabaseInt(targetid, "family_vig", new_vig);

                if(action_value == 1)
                    format(notify_text, sizeof notify_text, "Вы увеличили выговоры %d/3 игроку %s", new_vig, target_name);
                else
                    format(notify_text, sizeof notify_text, "Вы уменьшили выговоры %d/3 игроку %s", new_vig, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                if(action_value == 1)
                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выдал Вам семейный выговор, теперь у Вас %d/3", player_name, new_vig);
                else
                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам семейные выговоры, теперь у Вас %d/3", player_name, new_vig);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил кол-во выговоров %s теперь %d/3", player_name, playerid, target_name, new_vig);
                SendFamilyMessage(f, family_text);

                if(new_vig >= 3)
                {
                    FamilyGuiRemoveMemberFromFamily(targetid, target_account_id);
                    AddFamily(f, family_count_people, -, 1);

                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выгнал вас из семьи.", player_name);
                    SendClientMessage(targetid, -1, target_text);
                    format(notify_text, sizeof notify_text, "%s выгнал вас из семьи.", player_name);
                    ShowNotificationNew(targetid, 3, 6, 0, 0, notify_text, " ");

                    format(family_text, sizeof family_text, "%s[%d] выгнал игрока %s", player_name, playerid, target_name);
                    SendFamilyMessage(f, family_text);
                    SendFamilyLog(type_log_kick, playerid, targetid, family_text);
                    FamilyGuiResetPlayerState(playerid);
                }

                success = 1;
            }
        }
        case 2:
        {
            if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            mute_time = GetPlayerFamily(targetid, MUTE_FAMILY);
            new_mute = mute_time;

            if(action_value == 0)
            {
                if(mute_time > 0)
                {
                    if(mute_time < 600) new_mute = 0;
                    else new_mute = mute_time - 600;
                }
            }
            else if(action_value == 1)
            {
                if(mute_time > 3000) new_mute = 3600;
                else new_mute = mute_time + 600;
            }

            if(new_mute != mute_time)
            {
                SetPlayerFamily(targetid, MUTE_FAMILY, new_mute);
                UpdatePlayerDatabaseInt(targetid, "family_mute", new_mute);

                format(notify_text, sizeof notify_text, "Вы изменили время семейного мута на %d минут игроку %s", new_mute / 60, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам время семейного мута на %d минут", player_name, new_mute / 60);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил время мута игроку %s, осталось %d минут", player_name, playerid, target_name, new_mute / 60);
                SendFamilyMessage(f, family_text);
                success = 1;
            }
        }
        case 3:
        {
            if((!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1]) && GetPlayerRangFamily(playerid) != 5)
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            if(FamilyGuiRemoveMemberFromFamily(targetid, target_account_id))
            {
                AddFamily(f, family_count_people, -, 1);

                format(notify_text, sizeof notify_text, "Вы уволили игрока %s", target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выгнал вас из семьи.", player_name);
                SendClientMessage(targetid, -1, target_text);
                format(notify_text, sizeof notify_text, "%s выгнал вас из семьи.", player_name);
                ShowNotificationNew(targetid, 3, 6, 0, 0, notify_text, " ");

                format(family_text, sizeof family_text, "%s[%d] выгнал игрока %s", player_name, playerid, target_name);
                SendFamilyMessage(f, family_text);
                SendFamilyLog(type_log_kick, playerid, targetid, family_text);

                FamilyGuiResetPlayerState(playerid);
                success = 1;
            }
        }
    }

    return FamilyGuiSendPlayerActionResult(playerid, success);
}

stock FamilyGuiResolveBlacklistTarget(const target_input[], &account_id, player_name[], name_size = sizeof player_name, &target_family_sql_id)
{
    new query[144];
    new Cache:cache;

    account_id = -1;
    target_family_sql_id = -1;
    player_name[0] = '\0';

    if(!strlen(target_input))
        return 0;

    if(FamilyGuiIsNumericString(target_input))
    {
        new numeric_value = strval(target_input);

        if(numeric_value < 0)
            return 0;

        if(numeric_value < MAX_PLAYERS && IsPlayerConnected(numeric_value) && IsPlayerLogged(numeric_value))
        {
            account_id = GetPlayerAccountID(numeric_value);
            format(player_name, name_size, "%s", GetPlayerNameEx(numeric_value));
            target_family_sql_id = GetPlayerFamily(numeric_value, ID_SQL_FAMILY);
            return 1;
        }

        account_id = numeric_value;
        if(account_id <= 0)
            return 0;

        mysql_format(mysql, query, sizeof query, "SELECT id, name, family_id FROM accounts WHERE id = %d LIMIT 1", account_id);
        cache = mysql_query(mysql, query, true);

        if(cache_num_rows())
        {
            cache_get_field_content(0, "name", player_name, mysql, name_size);
            target_family_sql_id = cache_get_field_content_int(0, "family_id");
            cache_delete(cache);
            return 1;
        }

        cache_delete(cache);
        return 0;
    }

    foreach(new targetid : Player)
    {
        if(strcmp(target_input, GetPlayerNameEx(targetid), true))
            continue;

        account_id = GetPlayerAccountID(targetid);
        format(player_name, name_size, "%s", GetPlayerNameEx(targetid));
        target_family_sql_id = GetPlayerFamily(targetid, ID_SQL_FAMILY);
        return 1;
    }

    mysql_format(mysql, query, sizeof query, "SELECT id, name, family_id FROM accounts WHERE name = '%e' LIMIT 1", target_input);
    cache = mysql_query(mysql, query, true);

    if(!cache_num_rows())
    {
        cache_delete(cache);
        return 0;
    }

    account_id = cache_get_field_content_int(0, "id");
    target_family_sql_id = cache_get_field_content_int(0, "family_id");
    cache_get_field_content(0, "name", player_name, mysql, name_size);
    cache_delete(cache);
    return 1;
}

stock FamilyGuiIsBlacklisted(family_sql_id, account_id)
{
    new query[128];
    new Cache:cache;
    new found = 0;

    if(family_sql_id <= 0 || account_id <= 0)
        return 0;

    mysql_format(mysql, query, sizeof query, "SELECT account_id FROM familyblack WHERE family_id = %d AND account_id = %d LIMIT 1", family_sql_id, account_id);
    cache = mysql_query(mysql, query, true);
    found = cache_num_rows() > 0;
    cache_delete(cache);
    return found;
}

stock FamilyGuiShowBlacklistMenu(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    Dialog(
        playerid, 2368, DIALOG_STYLE_LIST,
        "{FF0000}Черный список",
        "{FFFFFF}1. Добавить в черный список\n"\
        "{FFFFFF}2. Удалить из черного списка\n"\
        "{FFFFFF}3. Просмотреть черный список",
        "Далее", "Назад"
    );
    return 1;
}

stock FamilyGuiShowBlacklistList(playerid, page, notify_if_empty = 0)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[256];
    new dialog[4096];
    new entry_text[160];
    new title[64];
    new date_text[32];
    new player_name[32];
    new total_rows = 0;
    new offset = 0;
    new rows = 0;

    if(family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(page < 0)
        page = 0;

    offset = page * 15;
    printf("[FAMILY_BLACKLIST][OPEN] player=%d family_sql_id=%d page=%d offset=%d", playerid, family_sql_id, page, offset);
    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM familyblack WHERE family_id = %d", family_sql_id);
    printf("[FAMILY_BLACKLIST][OPEN] count_query=%s", query);
    new Cache:count_cache = mysql_query(mysql, query, true);
    if(cache_num_rows())
        total_rows = cache_get_field_content_int(0, "cnt");
    printf("[FAMILY_BLACKLIST][OPEN] total_rows=%d errno=%d count_cache=%d", total_rows, mysql_errno(), _:count_cache);
    cache_delete(count_cache);

    if(!total_rows)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    if(offset >= total_rows)
    {
        if(notify_if_empty)
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    mysql_format(mysql, query, sizeof query, "SELECT fb.account_id, fb.created_at, DATE_FORMAT(FROM_UNIXTIME(fb.created_at), '%%Y-%%m-%%d %%H:%%i:%%s') AS created_text, a.name AS account_name FROM familyblack fb LEFT JOIN accounts a ON a.id = fb.account_id WHERE fb.family_id = %d ORDER BY fb.created_at DESC LIMIT 15 OFFSET %d", family_sql_id, offset);
    printf("[FAMILY_BLACKLIST][OPEN] list_query=%s", query);
    new Cache:cache = mysql_query(mysql, query, true);
    rows = cache_num_rows();
    printf("[FAMILY_BLACKLIST][OPEN] list_rows=%d errno=%d cache=%d", rows, mysql_errno(), _:cache);

    if(!rows)
    {
        cache_delete(cache);
        if(notify_if_empty || !page)
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    format(dialog, sizeof dialog, "{FFFFFF}Следующая страница\n{FFFFFF}Предыдущая страница\n");
    for(new i; i < rows; i++)
    {
        new account_id = cache_get_field_content_int(i, "account_id");

        cache_get_field_content(i, "account_name", player_name, mysql, sizeof player_name);
        if(!strlen(player_name))
            format(player_name, sizeof player_name, "ID %d", account_id);

        cache_get_field_content(i, "created_text", date_text, mysql, sizeof date_text);
        if(!strlen(date_text))
            FamilyGuiFormatDateTime(cache_get_field_content_int(i, "created_at"), date_text, sizeof date_text);

        printf("[FAMILY_BLACKLIST][OPEN] row=%d account_id=%d name=%s created_at=%d created_text=%s", i, account_id, player_name, cache_get_field_content_int(i, "created_at"), date_text);
        format(entry_text, sizeof entry_text, "%s %s\n", player_name, date_text);
        strcat(dialog, entry_text);
        SetPlayerListitemValue(playerid, i + 2, account_id);
    }
    cache_delete(cache);
    cache_set_active(Cache:0);

    SetPVarInt(playerid, "family_blacklist_page", page);
    format(title, sizeof title, "{FF0000}Список игроков: %d", page + 1);
    Dialog(playerid, 2371, DIALOG_STYLE_LIST, title, dialog, "Выбрать", "Назад");
    return 1;
}

stock FamilyGuiHandleBlacklistAdd(playerid, const inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw_target[32];
    new raw_reason[64];
    new target_input[32];
    new reason[64];
    new target_name[32];
    new query[256];
    new comma_pos = strfind(inputtext, ",", true);
    new account_id = -1;
    new target_family_sql_id = -1;

    if(family_id == -1 || family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может управлять черным списком.", " ");

    if(comma_pos == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID и причину через запятую.", " ");

    strmid(raw_target, inputtext, 0, comma_pos, sizeof raw_target);
    strmid(raw_reason, inputtext, comma_pos + 1, strlen(inputtext), sizeof raw_reason);
    FamilyGuiTrimString(raw_target, target_input, sizeof target_input);
    FamilyGuiTrimString(raw_reason, reason, sizeof reason);

    if(!strlen(target_input) || !strlen(reason))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID и причину через запятую.", " ");

    if(!FamilyGuiResolveBlacklistTarget(target_input, account_id, target_name, sizeof target_name, target_family_sql_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок не найден.", " ");

    if(target_family_sql_id == family_sql_id)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок должен быть уволен из семьи.", " ");

    if(FamilyGuiIsBlacklisted(family_sql_id, account_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок уже находиться в черном списке.", " ");

    mysql_format(mysql, query, sizeof query, "INSERT INTO familyblack (family_id, account_id, reason, created_at) VALUES (%d, %d, '%e', %d)", family_sql_id, account_id, reason, gettime());
    mysql_query(mysql, query, false);
    if(mysql_errno())
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось обновить черный список.", " ");

    format(f_string144, sizeof f_string144, "%s[%d] добавил в черный список %s. Причина: %s", GetPlayerNameEx(playerid), playerid, target_name, reason);
    SendFamilyMessage(family_id, f_string144);
    return ShowNotificationNew(playerid, 3, 6, 0, 0, "Игрок добавлен в черный список.", " ");
}

stock FamilyGuiHandleBlacklistRemove(playerid, const inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new target_input[32];
    new target_name[32];
    new query[192];
    new account_id = -1;
    new target_family_sql_id = -1;

    if(family_id == -1 || family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может управлять черным списком.", " ");

    FamilyGuiTrimString(inputtext, target_input, sizeof target_input);
    if(!strlen(target_input))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID игрока.", " ");

    if(!FamilyGuiResolveBlacklistTarget(target_input, account_id, target_name, sizeof target_name, target_family_sql_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок не найден.", " ");

    if(!FamilyGuiIsBlacklisted(family_sql_id, account_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данного игрока нет в черном списке!", " ");

    mysql_format(mysql, query, sizeof query, "DELETE FROM familyblack WHERE family_id = %d AND account_id = %d", family_sql_id, account_id);
    mysql_query(mysql, query, false);
    if(mysql_errno())
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось обновить черный список.", " ");

    format(f_string144, sizeof f_string144, "%s[%d] удалил из черного списка %s.", GetPlayerNameEx(playerid), playerid, target_name);
    SendFamilyMessage(family_id, f_string144);
    return ShowNotificationNew(playerid, 3, 6, 0, 0, "Игрок удален из черного списка.", " ");
}

stock FamilyGuiSendUpgradeState(playerid)
{
    new Node:response = JSON_Object();
    new storage_level = 1;
    new weapon_level = 1;
    new compound_level = 1;
    new current_money = 0;

    if(GetPlayerIdFamily(playerid) != -1)
    {
        new f = GetPlayerIdFamily(playerid);
        storage_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
        weapon_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
        compound_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));
        current_money = GetFamily(f, family_money);
    }

    JSON_SetInt(response, "t", 4);
    JSON_SetInt(response, "m", current_money);
    JSON_SetArray(response, "y", JSON_Array(
        JSON_Int(storage_level),
        JSON_Int(weapon_level),
        JSON_Int(compound_level)
    ));
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleUpgradePurchase(playerid, upgrade_id)
{
    new f = GetPlayerIdFamily(playerid);
    new current_level = 0;
    new price = 0;
    new new_level = 0;
    new Node:response;

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", "OK");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может улучшать семью.", "OK");

    switch(upgrade_id)
    {
        case 0:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_sklad[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_storage, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_storage", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил склад до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        case 1:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_weapon[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_weapon, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_weapon", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил оружие до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        case 2:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_compound[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_compound, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_compound", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил состав до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        default: return ShowNotificationNew(playerid, 2, 6, 0, 0, "Неизвестное улучшение.", "OK");
    }

    UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
    SendFamilyMessage(f, f_string144);

    response = JSON_Object();
    JSON_SetInt(response, "t", 4);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "id", upgrade_id);
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
stock FamilyGuiSendMain(playerid)
{
    new Node:response = JSON_Object();
    new player_skin = GetPlayerSkin(playerid);

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "s", player_skin);

    if(GetPlayerIdFamily(playerid) != -1)
    {
        new f = GetPlayerIdFamily(playerid);
        new storage_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
        new weapon_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
        new compound_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));

        JSON_SetInt(response, "r", GetFamily(f, family_reputation));
        JSON_SetInt(response, "am", FamilyGuiGetActualMemberCount(playerid));
        JSON_SetArray(response, "ug", JSON_Array(
            JSON_Int(storage_level),
            JSON_Int(7),
            JSON_Int(weapon_level),
            JSON_Int(7),
            JSON_Int(compound_level),
            JSON_Int(7)
        ));
        JSON_SetArray(response, "my", JSON_Array(
            JSON_Int(GetFamily(f, family_money)),
            JSON_Int(count_money_level[storage_level - 1])
        ));
        JSON_SetArray(response, "ms", JSON_Array(
            JSON_Int(GetFamily(f, family_material)),
            JSON_Int(count_material_level[storage_level - 1])
        ));
        JSON_SetArray(response, "mk", JSON_Array(
            JSON_Int(GetFamily(f, family_mask)),
            JSON_Int(count_mask_level[storage_level - 1])
        ));
        JSON_SetArray(response, "kb", JSON_Array(
            JSON_Int(GetFamily(f, family_heath_kit)),
            JSON_Int(count_heath_kit_level[storage_level - 1])
        ));
        JSON_SetArray(response, "pn", JSON_Array(
            JSON_Int(GetFamily(f, family_patron)),
            JSON_Int(count_patron_level[weapon_level - 1])
        ));
        JSON_SetArray(response, "bt", JSON_Array(
            JSON_Int(GetFamily(f, family_armour)),
            JSON_Int(count_armour_level[storage_level - 1])
        ));
    }
    else
    {
        JSON_SetInt(response, "r", 0);
        JSON_SetInt(response, "am", 0);
        JSON_SetArray(response, "ug", JSON_Array(JSON_Int(1), JSON_Int(7), JSON_Int(1), JSON_Int(7), JSON_Int(1), JSON_Int(7)));
        JSON_SetArray(response, "my", JSON_Array(JSON_Int(0), JSON_Int(count_money_level[0])));
        JSON_SetArray(response, "ms", JSON_Array(JSON_Int(0), JSON_Int(count_material_level[0])));
        JSON_SetArray(response, "mk", JSON_Array(JSON_Int(0), JSON_Int(count_mask_level[0])));
        JSON_SetArray(response, "kb", JSON_Array(JSON_Int(0), JSON_Int(count_heath_kit_level[0])));
        JSON_SetArray(response, "pn", JSON_Array(JSON_Int(0), JSON_Int(count_patron_level[0])));
        JSON_SetArray(response, "bt", JSON_Array(JSON_Int(0), JSON_Int(count_armour_level[0])));
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotifications(playerid)
{
    new Node:response = JSON_Object();
    new Node:message_list = JSON_Array();
    new Node:id_list = JSON_Array();
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    for(new i; i < count; i++)
    {
        message_list = JSON_Append(message_list, JSON_Array(JSON_String(values[i])));
        message_list = JSON_Append(message_list, JSON_Array(JSON_String(authors[i])));
        id_list = JSON_Append(id_list, JSON_Array(JSON_Int(ids[i])));
    }

    JSON_SetInt(response, "t", 6);
    JSON_SetArray(response, "m", message_list);
    JSON_SetArray(response, "x", id_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    FamilyGuiSetNotificationReadState(playerid, FamilyGuiGetSqlFamilyId(playerid), FamilyGuiGetNotificationMaxId(ids, count));
    return 1;
}

stock FamilyGuiSendRating(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:value_list = JSON_Array();
    new my_position = 0;
    new my_type = 0;
    new my_reputation = 0;
    new my_zaxvati = 0;
    new my_family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    if(my_family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT syndicate, reputation, zaxvati FROM familynew WHERE id = %d LIMIT 1", my_family_sql_id);
        new Cache:my_cache = mysql_query(mysql, f_string184, true);

        if(cache_num_rows())
        {
            my_type = cache_get_field_content_int(0, "syndicate");
            my_reputation = cache_get_field_content_int(0, "reputation");
            my_zaxvati = cache_get_field_content_int(0, "zaxvati");
        }

        cache_delete(my_cache);
    }

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT id, name, reputation, zaxvati, syndicate FROM familynew WHERE reputation >= 0 ORDER BY reputation DESC, zaxvati DESC LIMIT 10");
    new Cache:cache = mysql_query(mysql, f_string144, true);

    for(new i, rows = cache_num_rows(); i < rows; i++)
    {
        new family_sql_id = cache_get_field_content_int(i, "id");
        new family_name_sql[32];
        new family_type_sql = cache_get_field_content_int(i, "syndicate");
        new family_reputation_sql = cache_get_field_content_int(i, "reputation");
        new family_zaxvati_sql = cache_get_field_content_int(i, "zaxvati");

        cache_get_field_content(i, "name", family_name_sql, mysql, sizeof family_name_sql);

        if(my_family_sql_id != -1 && my_family_sql_id == family_sql_id)
        {
            my_position = i + 1;
        }

        name_list = JSON_Append(name_list, JSON_Array(JSON_String(family_name_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_reputation_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_zaxvati_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_type_sql)));
    }

    cache_delete(cache);

    JSON_SetInt(response, "t", 7);
    JSON_SetInt(response, "p", my_position);
    JSON_SetInt(response, "tp", my_type);
    JSON_SetInt(response, "tr", my_reputation);
    JSON_SetInt(response, "tz", my_zaxvati);
    JSON_SetArray(response, "mn", name_list);
    JSON_SetArray(response, "m", value_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleNotificationCreate(playerid, Node:request)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new input_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new clean_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author[FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new new_id = 1;

    if(GetPlayerIdFamily(playerid) == -1)
        return 0;

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может добавлять уведомления", "qq");

    if(JSON_GetType(request, "m") != JSON_NODE_STRING)
        return 0;

    JSON_GetString(request, "m", input_text, sizeof input_text);
    FamilyGuiSanitizeNotificationText(input_text, clean_text, sizeof clean_text);

    if(!strlen(clean_text))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите текст в поле для ввода", "qq");

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    if(count >= FAMILY_GUI_NOTIF_LIMIT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно добавить только 5 уведомлений", "qq");

    new_id = FamilyGuiReserveNotificationId(playerid, FamilyGuiGetNotificationMaxId(ids, count));

    for(new i = count; i > 0; i--)
    {
        ids[i] = ids[i - 1];
        format(values[i], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", values[i - 1]);
        format(authors[i], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", authors[i - 1]);
    }

    ids[0] = new_id;
    format(values[0], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", clean_text);
    format(author, sizeof author, "%s", GetPlayerNameEx(playerid));
    format(authors[0], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", author);
    count++;

    if(!FamilyGuiSaveNotifications(playerid, ids, values, authors, count))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось сохранить уведомление", "qq");

    FamilyGuiSetNotificationReadState(playerid, family_sql_id, ids[0]);
    return FamilyGuiSendNotificationAdded(playerid, values[0], authors[0], ids[0]);
}

stock FamilyGuiHandleNotificationDelete(playerid, Node:request)
{
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new delete_id = -1;
    new delete_index = -1;

    if(GetPlayerIdFamily(playerid) == -1)
        return 0;

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может удалять уведомления", "qq");

    if(JSON_GetType(request, "x") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "x", delete_id);
    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    for(new i; i < count; i++)
    {
        if(ids[i] == delete_id)
        {
            delete_index = i;
            break;
        }
    }

    if(delete_index == -1)
        return 0;

    for(new i = delete_index; i < (count - 1); i++)
    {
        ids[i] = ids[i + 1];
        format(values[i], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", values[i + 1]);
        format(authors[i], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", authors[i + 1]);
    }

    count--;

    if(!FamilyGuiSaveNotifications(playerid, ids, values, authors, count))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось удалить уведомление", "qq");

    return FamilyGuiSendNotificationDeleted(playerid, delete_id);
}

stock FamilyGuiHandleLeave(playerid)
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return FamilyGuiSendLeaveResult(playerid, 0);

    new f_sql = GetPlayerFamily(playerid, ID_SQL_FAMILY);

    if(GetPlayerRangFamily(playerid) != 5)
    {
        format(f_string144, sizeof f_string144, "Игрок %s покинул семью. Причина: GUI", GetPlayerNameEx(playerid));
        SendFamilyMessage(f, f_string144);
        ExitFromFamily(playerid);
        FamilyGuiResetPlayerState(playerid);
        return FamilyGuiSendLeaveResult(playerid, 1);
    }

    format(f_string144, sizeof f_string144, "Лидер %s[%d] ушел и семья закрыта. Причина: C/Ж", GetPlayerNameEx(playerid), playerid);
    SendFamilyMessage(f, f_string144);

    foreach(new i : Player)
    {
        if(GetPlayerFamily(i, ID_SQL_FAMILY) != f_sql) continue;

        ExitFromFamily(i);
        SendClientMessage(i, -1, "Ваша семья была распущена. Лидер покинул семью.");
        FamilyGuiResetPlayerState(i);
        FamilyGuiSendLeaveResult(i, 1);
    }

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_cars WHERE family_owner = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_log WHERE family = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_ad WHERE family = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_storage_items WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM familyblack WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);
    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM familynew WHERE id = %d", f_sql);
    mysql_query(mysql, f_string64);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id = -1 WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);

    for(new i; i < MAX_OWNABLE_CARS; i++)
    {
        if(GetCarFamily(i, OW_F_database) != f_sql) continue;
        UnLoadFamilyCar(GetCarFamily(i, CAR_F_database));
    }

    SetFamily(f, family_database, -1);
    SetFamily(f, family_color, 0);
    SetFamily(f, family_reputation, 0);
    SetFamily(f, family_zaxvati, 0);
    SetFamily(f, family_moneti, 0);
    SetFamily(f, family_syndicate, 0);
    format(family[f][family_name], 32, "");
    SetFamily(f, family_owner, 0);
    SetFamily(f, family_slot_veh, 0);
    SetFamily(f, family_count_veh, 0);
    SetFamily(f, family_count_people, 0);
    SetFamily(f, family_status_storage, 0);
    SetFamily(f, family_money, 0);
    SetFamily(f, family_armour, 0);
    SetFamily(f, family_material, 0);
    SetFamily(f, family_heath_kit, 0);
    SetFamily(f, family_patron, 0);
    SetFamily(f, family_mask, 0);
    SetFamily(f, family_lvl_storage, 0);
    SetFamily(f, family_lvl_weapon, 0);
    SetFamily(f, family_lvl_compound, 0);

    return 1;
}

stock FamilyGuiHandlePacket(playerid, Node:request)
{
    new type = 0;
    JSON_GetInt(request, "t", type);

    switch(type)
    {
        case 3:
        {
            new shop_id = -1;
            JSON_GetInt(request, "id", shop_id);
            return FamilyGuiHandleShopPurchase(playerid, shop_id);
        }
        case 2:
        {
            new status = 0;
            JSON_GetInt(request, "s", status);

            switch(status)
            {
                case 1:
                {
                    new sql_id = 0;
                    JSON_GetInt(request, "id", sql_id);
                    return FamilyGuiSendCarInfo(playerid, sql_id);
                }
                case 2:
                {
                    return FamilyGuiHandleCarAction(playerid, request);
                }
            }

            return FamilyGuiSendCarList(playerid);
        }
        case 4:
        {
            new status = 0;
            new upgrade_id = -1;
            JSON_GetInt(request, "s", status);
            JSON_GetInt(request, "id", upgrade_id);

            if(status == 1)
                return FamilyGuiHandleUpgradePurchase(playerid, upgrade_id);

            return FamilyGuiSendUpgradeState(playerid);
        }
        case 5:
        {
            new menu_id = 0;
            new status = 0;
            new selected_name[24];

            JSON_GetInt(request, "id", menu_id);
            JSON_GetInt(request, "s", status);
            JSON_GetString(request, "n", selected_name, sizeof selected_name);

            if(menu_id == 0)
                return FamilyGuiSendMain(playerid);

            if(menu_id == 1)
            {
                switch(status)
                {
                    case 1: return FamilyGuiHandleFamilySettingRank(playerid, request);
                    case 2: return FamilyGuiHandleFamilySettingAccess(playerid, request);
                    case 3: return FamilyGuiHandleFamilySettingColor(playerid, request);
                }

                return FamilyGuiSendFamilySettings(playerid);
            }

            if(menu_id == 2)
            {
                switch(status)
                {
                    case 1: return FamilyGuiSendPlayerInfo(playerid, selected_name);
                    case 2: return FamilyGuiHandlePlayerAction(playerid, request);
                }

                return FamilyGuiSendPlayerList(playerid);
            }

            if(menu_id == 3)
            {
                return FamilyStorageHandleGuiAction(playerid, request);
            }

            if(menu_id == 4)
            {
                return FamilyGuiShowLogsMenu(playerid);
            }

            if(menu_id == 5)
            {
                return FamilyGuiShowBlacklistMenu(playerid);
            }
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "Раздел временно недоступен.", "OK");
        }
        case 6:
        { 
            new action = 0;
            JSON_GetInt(request, "b", action);

            if(action == 1)
                return FamilyGuiHandleNotificationCreate(playerid, request);

            if(action == 2)
                return FamilyGuiHandleNotificationDelete(playerid, request);

            return FamilyGuiSendNotifications(playerid);
        }
        case 7:
        {
            return FamilyGuiSendRating(playerid);
        }
        case 9:
        {
            new status = 0;
            new value = 0;

            JSON_GetInt(request, "s", status);
            JSON_GetInt(request, "v", value);
            return FamilyGuiHandleTokenAction(playerid, status, value);
        }
        case 10:
        {
            return FamilyGuiHandleLeave(playerid);
        }
    }

    return 1;
}
