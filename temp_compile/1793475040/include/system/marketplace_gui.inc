
#if defined _sander_marketplace_gui_included
    #endinput
#endif
#define _sander_marketplace_gui_included

#define MARKETPLACE_GUI_ID                    (77)
#define MARKETPLACE_FIX_REVISION              (17)
#define MARKETPLACE_MAX_PAGE_LOTS             (10)
#define MARKETPLACE_DEFAULT_EXPIRE            (604800)
#define MARKETPLACE_SELL_TAX                  (5)
#define MARKETPLACE_MIN_PRICE                 (1)
#define MARKETPLACE_MAX_PRICE                 (999999999)
#define MARKETPLACE_MAX_TOTAL                 (2000000000)
#define MARKETPLACE_MAX_ACCOUNT_MONEY         (2100000000)
#define MARKETPLACE_VIP_PROMO_ENABLED          (1)
#define MARKETPLACE_VIP_PROMO_PRICE            (1000) // existing donate/VIP entry
#define MARKETPLACE_VIP_MAX_TIER               (3)
#define MARKETPLACE_VIP_PROMO_TIMER             (30)
#define MP_LOT_ACTIVE                         (0)
#define MP_LOT_SOLD                           (1)
#define MP_LOT_WITHDRAWN                      (2)
#define MP_LOT_RESERVED                       (3)

#define MP_TAB_PROFILE                        (1)
#define MP_TAB_MAIN                           (2)
#define MP_TAB_INVENTORY                      (3) // client sell/inventory tab
#define MP_TAB_HISTORY                        (4)
#define MP_TAB_MY_STORE                       (5)
#define MP_TAB_FAVORITES                      (98)

#define MP_ACT_PAGE                           (6)
#define MP_ACT_DONATE                         (7)
#define MP_ACT_FILTER                         (8)
#define MP_ACT_CREATE_LOT                     (9)
#define MP_ACT_SELECT_INV_ITEM                (10)
#define MP_ACT_PUBLISH_LOT                    (11)
#define MP_ACT_BUY_CLICK                      (12)
#define MP_ACT_CONFIRM_BUY                    (13)
#define MP_ACT_LIKE                           (14)
#define MP_ACT_EDIT_LOT                       (15)
#define MP_ACT_CONFIRM_EDIT                   (16)
#define MP_ACT_DELETE_LOT                     (17)
#define MP_ACT_HISTORY_CARD                   (18)
#define MP_ACT_SEARCH                         (19)
#define MP_ACT_BUY_VIP                        (20)
#define MP_ACT_SORT                           (21)
#define MP_ACT_DOTS_UPDATE                    (22)
#define MP_ACT_LIKED_ARRAY                    (24)
#define MP_ACT_NOTIFY_VIP                     (25)
#define MP_ACT_MONEY_UPDATE                   (26)

#define MP_DIALOG_MAIN                        (28770)
#define MP_DIALOG_LOTS                        (28771)
#define MP_DIALOG_LOT_ACTION                  (28772)
#define MP_DIALOG_INV                         (28773)
#define MP_DIALOG_SELL_COUNT                  (28774)
#define MP_DIALOG_SELL_PRICE                  (28775)
#define MP_DIALOG_MYLOTS                      (28776)
#define MP_DIALOG_MYLOT_ACTION                (28777)
#define MP_DIALOG_SEARCH                      (28778)
#define MP_DIALOG_EDIT_PRICE                  (28779)

new g_MP_SelectedSlot[MAX_PLAYERS] = {-1, ...};
new g_MP_SelectedLot[MAX_PLAYERS] = {-1, ...};
new g_MP_SelectedSellCount[MAX_PLAYERS] = {1, ...};
new g_MP_CurrentTab[MAX_PLAYERS] = {2, ...};
new g_MP_CurrentPage[MAX_PLAYERS] = {0, ...};
new g_MP_Sort[MAX_PLAYERS] = {0, ...};
new g_MP_Search[MAX_PLAYERS][64];

forward Marketplace_OnLotsLoaded(playerid, response_type, tab);
forward Marketplace_OnProfileLoaded(playerid);
forward Marketplace_OnHistoryLoaded(playerid);
forward Marketplace_OnBuyInfoLoaded(playerid, lot_id);
forward Marketplace_OnDialogLots(playerid, my_lots);

stock Marketplace_ResetPlayer(playerid)
{
    g_MP_SelectedSlot[playerid] = -1;
    g_MP_SelectedLot[playerid] = -1;
    g_MP_SelectedSellCount[playerid] = 1;
    g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
    g_MP_CurrentPage[playerid] = 0;
    g_MP_Sort[playerid] = 0;
    g_MP_Search[playerid][0] = EOS;
    return 1;
}

stock Marketplace_OnGameModeInit()
{
    MPReward_CreateTables();

    // Create the main table synchronously after mysql_connect. Publishing cannot
    // report success unless this query and the subsequent INSERT both succeed.
    new Cache:market_schema;
    new market_schema_error;
    market_schema = mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_lots` (`id` INT NOT NULL AUTO_INCREMENT, `seller_id` INT NOT NULL, `seller_name` VARCHAR(24) NOT NULL, `item_id` INT NOT NULL, `item_count` INT NOT NULL, `amount` INT NOT NULL DEFAULT 1, `item_plate` VARCHAR(32) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `item_type` INT NOT NULL DEFAULT 0, `rarity` INT NOT NULL DEFAULT 1, `price` INT NOT NULL, `is_hot` TINYINT NOT NULL DEFAULT 0, `status` TINYINT NOT NULL DEFAULT 0, `created_at` INT NOT NULL, `expires_at` INT NOT NULL, `buyer_id` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `seller_id` (`seller_id`), KEY `status` (`status`), KEY `item_id` (`item_id`), KEY `expires_at` (`expires_at`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", true);
    market_schema_error = mysql_errno();
    cache_delete(market_schema);
    printf("[MARKET] database schema check: marketplace_lots errno=%d", market_schema_error);
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_history` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `lot_id` INT NOT NULL DEFAULT 0, `item_id` INT NOT NULL, `amount` INT NOT NULL DEFAULT 1, `price` INT NOT NULL DEFAULT 0, `status` TINYINT NOT NULL DEFAULT 0, `seller_name` VARCHAR(24) NOT NULL DEFAULT '', `buyer_name` VARCHAR(24) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `created_at` INT NOT NULL, PRIMARY KEY (`id`), KEY `account_id` (`account_id`), KEY `lot_id` (`lot_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_favorites` (`account_id` INT NOT NULL, `lot_id` INT NOT NULL, `created_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`,`lot_id`), KEY `lot_id` (`lot_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_wallet` (`account_id` INT NOT NULL, `balance` BIGINT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");

    // Recover lots which were left reserved after a restart.
    mysql_tquery(mysql, "UPDATE `marketplace_lots` SET `status`=0 WHERE `status`=3");
    // Existing active listings are migrated to the seven-day lifetime.
    mysql_tquery(mysql, "UPDATE `marketplace_lots` SET `expires_at`=`created_at`+604800 WHERE `status`=0 AND `expires_at`<>`created_at`+604800");
    // Normalize the deterministic skin type. Accessory rows are validated by
    // their real item_id at load/buy time, so stale item_type values cannot hide them.
    mysql_tquery(mysql, "UPDATE `marketplace_lots` SET `item_type`=3 WHERE `item_id`=134 AND `item_type`<>3");
    // Keep the cached seller name in sync with the authoritative account name.
    // This also repairs lots created by old revisions where the seller field
    // contained the numeric account id instead of the nickname.
    mysql_tquery(mysql, "UPDATE `marketplace_lots` l INNER JOIN `accounts` a ON a.`id`=l.`seller_id` SET l.`seller_name`=a.`name` WHERE l.`seller_name`<>a.`name` OR l.`seller_name`='' ");
    return 1;
}

stock Marketplace_GetVipTypeForGui(playerid)
{
    new vip = GetPlayerPremium(playerid);
    if(vip < 0) vip = 0;
    if(vip > MARKETPLACE_VIP_MAX_TIER) vip = MARKETPLACE_VIP_MAX_TIER;
    return vip;
}

stock Marketplace_UsesVipPromoSlot(playerid, tab)
{
    if(tab != MP_TAB_MAIN) return 0;
    if(strlen(g_MP_Search[playerid])) return 0;
    return (Marketplace_GetVipTypeForGui(playerid) < MARKETPLACE_VIP_MAX_TIER);
}

stock Marketplace_IsAllowedItem(item_id)
{
    return (item_id == 134 || Market_IsAccessoryInventoryItem(item_id));
}

stock Marketplace_IsSpecialItem(item_id)
{
    return Market_IsSingleInventoryEntity(item_id);
}

stock Marketplace_GetSlotSellAmount(playerid, source_id)
{
    if(!Market_CanSellSource(playerid, source_id)) return 0;

    new item_id = Market_GetSourceItemId(playerid, source_id);
    if(Marketplace_IsSpecialItem(item_id)) return 1;

    new amount = Market_GetSourceItemCount(playerid, source_id);
    return amount > 0 ? amount : 1;
}

stock Marketplace_GetProductType(item_id)
{
    if(item_id == 134) return 3;
    if(Market_IsAccessoryInventoryItem(item_id)) return 1;
    return 0;
}

stock Marketplace_GetRarity(item_id)
{
    if(item_id == 134) return 3;
    if(Market_IsAccessoryInventoryItem(item_id)) return 2;
    return 1;
}

stock Marketplace_GetClientVariant(playerid, source_id)
{
    new item_id = Market_GetSourceItemId(playerid, source_id);
    new stored_count = Market_GetSourceItemCount(playerid, source_id);

    if(item_id == 134) return stored_count;

    if(Market_IsAccessoryInventoryItem(item_id))
        return Market_GetAccessoryModelFromSource(playerid, source_id);

    return -1;
}

stock Marketplace_GetLotClientModel(item_id, item_count, item_plate[])
{
    #pragma unused item_plate
    if(item_id == 134)
    {
        if(item_count > 0) return item_count;
    }
    if(Market_IsAccessoryInventoryItem(item_id))
    {
        new accessory_model = Inv11_GetAccModelByItem(item_id);
        if(accessory_model > 0) return accessory_model;
    }
    return item_id;
}

stock Marketplace_GetLotClientTime(created_at, expires_at)
{
    #pragma unused created_at
    new remain = expires_at - gettime();
    if(remain < 0) remain = 0;
    return remain;
}

stock Marketplace_FormatCardTitle(item_name[], seller_name[], out[], out_size)
{
    #pragma unused seller_name
    format(out, out_size, "%s", item_name);
    return 1;
}

stock Marketplace_GetInventoryName(playerid, source_id, name[], len = sizeof(name))
{
    name[0] = EOS;
    if(!Market_CanSellSource(playerid, source_id)) return 0;

    new item_id = Market_GetSourceItemId(playerid, source_id);
    new stored_count = Market_GetSourceItemCount(playerid, source_id);
    new base_name[64];

    if(Market_IsAccessoryInventoryItem(item_id))
        Market_GetItemName(item_id, Market_GetAccessoryModelFromSource(playerid, source_id), base_name, sizeof(base_name));
    else
        GetItemName(item_id, base_name, sizeof(base_name));

    if(!strlen(base_name)) format(base_name, sizeof(base_name), "Item #%d", item_id);

    if(item_id == 134)
    {
        format(name, len, "%s #%d", base_name, stored_count);
    }
    else
    {
        format(name, len, "%s", base_name);
    }
    return 1;
}

stock Marketplace_FindPlayerByAccountID(account_id)
{
    foreach(new i: Player)
    {
        if(IsPlayerConnected(i) && IsPlayerLogged(i) && GetPlayerAccountID(i) == account_id) return i;
    }
    return INVALID_PLAYER_ID;
}

stock Marketplace_QueueMoney(account_id, money)
{
    if(account_id <= 0 || money <= 0) return 0;

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_wallet` (`account_id`,`balance`,`updated_at`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `balance`=`balance`+VALUES(`balance`),`updated_at`=VALUES(`updated_at`)",
        account_id, money, gettime());

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);
    return affected > 0;
}

stock Marketplace_AddMoneyToAccount(account_id, money)
{
    if(account_id <= 0 || money <= 0) return 0;

    new current_money;
    new online = Marketplace_FindPlayerByAccountID(account_id);

    if(online != INVALID_PLAYER_ID)
    {
        current_money = GetPlayerMoneyEx(online);
    }
    else
    {
        new query[192];
        mysql_format(mysql, query, sizeof(query), "SELECT `money` FROM `accounts` WHERE `id`=%d LIMIT 1", account_id);
        new Cache:result = mysql_query(mysql, query, true);
        if(!cache_num_rows())
        {
            cache_delete(result);
            return Marketplace_QueueMoney(account_id, money);
        }
        current_money = cache_get_field_content_int(0, "money", mysql);
        cache_delete(result);
    }

    if(current_money < 0) current_money = 0;
    new capacity = MARKETPLACE_MAX_ACCOUNT_MONEY - current_money;
    if(capacity < 0) capacity = 0;

    new direct_money = money;
    if(direct_money > capacity) direct_money = capacity;
    new pending_money = money - direct_money;

    // Persist overflow first so a full account can never lose sale proceeds.
    if(pending_money > 0 && !Marketplace_QueueMoney(account_id, pending_money)) return 0;

    if(direct_money > 0)
    {
        if(online != INVALID_PLAYER_ID)
        {
            if(!GivePlayerMoneyEx(online, direct_money, "Marketplace sale", true, true))
            {
                if(!Marketplace_QueueMoney(account_id, direct_money)) return 0;
            }
        }
        else
        {
            new query[256];
            mysql_format(mysql, query, sizeof(query),
                "UPDATE `accounts` SET `money`=`money`+%d WHERE `id`=%d AND `money`<=%d LIMIT 1",
                direct_money, account_id, MARKETPLACE_MAX_ACCOUNT_MONEY - direct_money);
            new Cache:update_result = mysql_query(mysql, query, true);
            new updated = cache_affected_rows(mysql);
            cache_delete(update_result);

            if(!updated && !Marketplace_QueueMoney(account_id, direct_money)) return 0;
        }
    }

    if(online != INVALID_PLAYER_ID && pending_money > 0)
    {
        ShowNotificationLaird(online, 1, 6, -1, -1, "\xd7\xe0\xf1\xf2\xfc\x20\xe4\xe5\xed\xe5\xe3\x20\xe7\xe0\x20\xef\xf0\xee\xe4\xe0\xe6\xf3\x20\xf1\xee\xf5\xf0\xe0\xed\xe5\xed\xe0\x2e\x20\xc7\xe0\xe1\xe5\xf0\xe8\xf2\xe5\x20\xe5\xb8\x20\xea\xee\xec\xe0\xed\xe4\xee\xe9\x20\x2f\x6d\x61\x72\x6b\x65\x74\x6d\x6f\x6e\x65\x79\x2e", "");
    }
    return 1;
}

stock Marketplace_ClaimMoney(playerid, notify = 1)
{
    if(!IsPlayerLogged(playerid)) return 0;

    new current_money = GetPlayerMoneyEx(playerid);
    new capacity = MARKETPLACE_MAX_ACCOUNT_MONEY - current_money;
    if(capacity <= 0)
    {
        if(notify) ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe0\x20\xf0\xf3\xea\xe0\xf5\x20\xf3\xe6\xe5\x20\xec\xe0\xea\xf1\xe8\xec\xe0\xeb\xfc\xed\xee\x20\xe4\xee\xef\xf3\xf1\xf2\xe8\xec\xe0\xff\x20\xf1\xf3\xec\xec\xe0\x2e", "");
        return 0;
    }

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT LEAST(`balance`,%d) AS `available` FROM `marketplace_wallet` WHERE `account_id`=%d LIMIT 1",
        MARKETPLACE_MAX_ACCOUNT_MONEY, GetPlayerAccountID(playerid));

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        if(notify) ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xce\xf2\xeb\xee\xe6\xe5\xed\xed\xfb\xf5\x20\xe2\xfb\xef\xeb\xe0\xf2\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe0\x20\xed\xe5\xf2\x2e", "");
        return 0;
    }

    new claim = cache_get_field_content_int(0, "available", mysql);
    cache_delete(result);
    if(claim > capacity) claim = capacity;
    if(claim <= 0) return 0;

    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_wallet` SET `balance`=`balance`-%d,`updated_at`=%d WHERE `account_id`=%d AND `balance`>=%d LIMIT 1",
        claim, gettime(), GetPlayerAccountID(playerid), claim);
    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);
    if(!updated) return 0;

    if(!GivePlayerMoneyEx(playerid, claim, "Marketplace wallet", true, true))
    {
        Marketplace_QueueMoney(GetPlayerAccountID(playerid), claim);
        return 0;
    }

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_wallet` WHERE `account_id`=%d AND `balance`<=0 LIMIT 1", GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query);

    if(notify) ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xc2\xfb\xef\xeb\xe0\xf2\xe0\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe0\x20\xef\xee\xeb\xf3\xf7\xe5\xed\xe0\x2e", "");
    return 1;
}

stock Marketplace_Send(Node:json, playerid)
{
    // The caller owns the packet and performs the explicit cleanup.
    // Prevent this helper's Node parameter from auto-cleaning it on return.
    JSON_ToggleGC(json, false);
    SendPacketToClient(playerid, MARKETPLACE_GUI_ID, json);
    return 1;
}

stock Marketplace_SendActionResult(playerid, action, success)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", action);
    JSON_SetInt(json, "err", success ? 1 : 0);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SendVipOfferInfo(playerid)
{
    // Detail packet for the legacy client's built-in "Best offer" card.
    // It deliberately does not use pt/model keys from the newer marketplace.
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_BUY_CLICK);
    JSON_SetInt(json, "id", 0);
    JSON_SetInt(json, "tp", 0);
    JSON_SetInt(json, "md", 0);
    JSON_SetInt(json, "ct", 1);
    JSON_SetInt(json, "cs", MARKETPLACE_VIP_PROMO_PRICE);
    JSON_SetInt(json, "tm", MARKETPLACE_VIP_PROMO_TIMER);
    JSON_SetInt(json, "ti", MARKETPLACE_VIP_PROMO_TIMER * 86400);
    JSON_SetInt(json, "r", 5);
    JSON_SetInt(json, "rt", 5);
    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "v", Marketplace_GetVipTypeForGui(playerid));
    JSON_SetString(json, "dm", "Platinum VIP", 13);
    JSON_SetString(json, "nm", "Market", 7);
    JSON_SetString(json, "sl", "Market", 7);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Node:Marketplace_MakeProductNode(lot_id, item_id, item_count, amount, price, item_name[], item_type, rarity, seller_id, seller_name[], created_at, expires_at, hot, liked = 0)
{
    new Node:item = JSON_Object();
    new card_title[96];
    new client_time = Marketplace_GetLotClientTime(created_at, expires_at);
    new client_model = Marketplace_GetLotClientModel(item_id, item_count, "");
    Marketplace_FormatCardTitle(item_name, seller_name, card_title, sizeof(card_title));

    // Keep the exact legacy marketplace card protocol. The mobile client uses
    // md as the inventory item identifier and can silently discard a card when
    // md is replaced by the skin/accessory model or when an unsupported pt key
    // is supplied. The real preview model is sent in additional compatibility
    // keys and does not affect card visibility on older clients.
    JSON_ToggleGC(item, false);
    JSON_SetInt(item, "id", lot_id);
    JSON_SetInt(item, "tp", 0);
    JSON_SetInt(item, "tm", hot);
    JSON_SetInt(item, "ti", client_time);
    JSON_SetInt(item, "md", item_id);
    JSON_SetInt(item, "mi", client_model);
    JSON_SetInt(item, "model", client_model);
    JSON_SetInt(item, "it", item_type);
    JSON_SetInt(item, "cs", price);
    JSON_SetInt(item, "ct", (item_id == 134 ? client_model : amount));
    JSON_SetString(item, "dm", card_title, sizeof(card_title));
    JSON_SetInt(item, "r", rarity);
    JSON_SetInt(item, "rt", rarity);
    JSON_SetString(item, "nm", seller_name, 24);
    JSON_SetString(item, "sl", seller_name, 24);
    JSON_SetInt(item, "sid", seller_id);
    JSON_SetInt(item, "l", liked ? 1 : 0);
    JSON_SetInt(item, "tb", created_at);

    return item;
}

stock Node:Marketplace_MakeInventoryProductNode(playerid, source_id)
{
    new item_id = Market_GetSourceItemId(playerid, source_id);
    new amount = Marketplace_GetSlotSellAmount(playerid, source_id);
    new rarity = Marketplace_GetRarity(item_id);
    new item_name[64];
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));

    new Node:item = JSON_Object();
    // This node is returned from the function. Disable automatic cleanup
    // immediately, not at the end after the node may already be invalid.
    JSON_ToggleGC(item, false);
    JSON_SetInt(item, "id", source_id);
    JSON_SetInt(item, "tp", 0);
    JSON_SetInt(item, "tm", 0);
    JSON_SetInt(item, "ti", MARKETPLACE_DEFAULT_EXPIRE);
    JSON_SetInt(item, "md", item_id);
    JSON_SetInt(item, "mi", (item_id == 134 ? Market_GetSourceItemCount(playerid, source_id) : Market_GetAccessoryModelFromSource(playerid, source_id)));
    JSON_SetInt(item, "cs", 0);
    JSON_SetInt(item, "ct", (item_id == 134 ? Market_GetSourceItemCount(playerid, source_id) : amount));
    JSON_SetString(item, "dm", item_name, sizeof(item_name));
    JSON_SetInt(item, "r", rarity);
    JSON_SetInt(item, "rt", rarity);

    new seller_buf[MAX_PLAYER_NAME];
    format(seller_buf, sizeof(seller_buf), "%s", GetPlayerNameEx(playerid));
    JSON_SetString(item, "nm", seller_buf, sizeof(seller_buf));
    JSON_SetString(item, "sl", seller_buf, sizeof(seller_buf));
    JSON_SetInt(item, "sid", GetPlayerAccountID(playerid));
    JSON_SetInt(item, "l", 0);
    JSON_SetInt(item, "tb", gettime());

    return item;
}

stock Node:Marketplace_BuildInventoryArray(playerid)
{
    new Node:products = JSON_Array();

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(!Market_CanSellSource(playerid, i)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, i);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    // Equipped accessories are authoritative in the legacy `accessories` table.
    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    // The caller owns the assembled array after this return.
    JSON_ToggleGC(products, false);
    return products;
}

stock Marketplace_CountInventoryProducts(playerid)
{
    new count;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
        if(Market_CanSellSource(playerid, i)) count++;

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
        if(Market_CanSellSource(playerid, Market_MakeActiveSource(active_slot))) count++;

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
        if(Market_CanSellSource(playerid, Market_MakeAccessorySource(accessory_slot))) count++;

    return count;
}

stock Marketplace_SendInventoryProducts(playerid, response_type = MP_ACT_CREATE_LOT)
{
    // Equipped accessories are stored separately from player_inventory.
    Market_RefreshAccessoryCache(playerid);

    // Build all sellable source IDs first. JSON cards are then created and
    // appended in this same function scope. This avoids returning child Node
    // IDs from helper functions, which caused pawn-json to invalidate them
    // before JSON_Array/JSON_Append could use them.
    new sell_sources[MAX_INVENTORY_SLOTS + MAX_ACTIVE_SLOTS + MARKET_SOURCE_ACCESSORY_SLOTS];
    new source_count = 0;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(Market_CanSellSource(playerid, i))
            sell_sources[source_count++] = i;
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    new Node:json = JSON_Object();
    new Node:products = JSON_Array();
    new seller_name[MAX_PLAYER_NAME];
    format(seller_name, sizeof(seller_name), "%s", GetPlayerNameEx(playerid));

    new appended = 0;
    for(new index = 0; index < source_count; index++)
    {
        new source_id = sell_sources[index];
        new item_id = Market_GetSourceItemId(playerid, source_id);
        new amount = Marketplace_GetSlotSellAmount(playerid, source_id);
        if(item_id <= 0 || amount <= 0) continue;

        new rarity = Marketplace_GetRarity(item_id);
        new item_name[64];
        Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));

        // Keep the card in the same scope as JSON_Append. JSON_Append consumes
        // both input nodes and returns the new array node.
        new Node:item = JSON_Object();
        JSON_SetInt(item, "id", source_id);
        JSON_SetInt(item, "tp", 0);
        JSON_SetInt(item, "tm", 0);
        JSON_SetInt(item, "ti", MARKETPLACE_DEFAULT_EXPIRE);
        JSON_SetInt(item, "tb", gettime());
        JSON_SetInt(item, "md", item_id);
        JSON_SetInt(item, "mi", (item_id == 134 ? Market_GetSourceItemCount(playerid, source_id) : Market_GetAccessoryModelFromSource(playerid, source_id)));
        JSON_SetInt(item, "cs", MARKETPLACE_MIN_PRICE);
        JSON_SetInt(item, "ct", (item_id == 134 ? Market_GetSourceItemCount(playerid, source_id) : amount));
        JSON_SetString(item, "dm", item_name, sizeof(item_name));
        JSON_SetInt(item, "r", rarity);
        JSON_SetInt(item, "rt", rarity);
        JSON_SetString(item, "nm", seller_name, sizeof(seller_name));
        JSON_SetString(item, "sl", seller_name, sizeof(seller_name));
        JSON_SetInt(item, "sid", GetPlayerAccountID(playerid));
        JSON_SetInt(item, "l", 0);

        products = JSON_Append(products, JSON_Array(item));
        appended++;
    }

    new json_count = 0;
    JSON_ArrayLength(products, json_count);
    if(json_count < 0) json_count = appended;

    JSON_SetInt(json, "t", response_type);
    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "v", Marketplace_GetVipTypeForGui(playerid));
    JSON_SetInt(json, "vm", MARKETPLACE_VIP_PROMO_PRICE);
    JSON_SetInt(json, "lp", appended);
    JSON_SetInt(json, "ls", 1);
    JSON_SetArray(json, "n", products);

    printf("[MARKET] fix=%d player=%d eligible=%d appended=%d json_count=%d (backpack+active+accessories DB)",
        MARKETPLACE_FIX_REVISION, playerid, source_count, appended, json_count);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SendLotsRequest(playerid, response_type, tab)
{
    if(!IsPlayerLogged(playerid)) return 0;

    // Remove favorites which can no longer be purchased.
    // Otherwise the client keeps a stale card for an unavailable lot.
    mysql_tquery(mysql, "DELETE f FROM `marketplace_favorites` f LEFT JOIN `marketplace_lots` l ON l.`id`=f.`lot_id` WHERE l.`id` IS NULL OR l.`status`<>0 OR l.`expires_at`<=UNIX_TIMESTAMP()");

    new where[512], order[128], query[1400], escaped[128], offset;
    new account_id = GetPlayerAccountID(playerid);
    new use_vip_slot = Marketplace_UsesVipPromoSlot(playerid, tab);
    new page_capacity = MARKETPLACE_MAX_PAGE_LOTS;

    // The legacy client draws the built-in VIP offer in a marketplace card slot.
    // Reserve exactly one slot on page 1 so the promo never covers a real skin/accessory.
    if(use_vip_slot && g_MP_CurrentPage[playerid] == 0) page_capacity--;

    offset = g_MP_CurrentPage[playerid] * MARKETPLACE_MAX_PAGE_LOTS;
    if(use_vip_slot && g_MP_CurrentPage[playerid] > 0) offset--;

    if(tab == MP_TAB_MY_STORE)
    {
        mysql_format(mysql, where, sizeof(where),
            "WHERE l.`status`=%d AND l.`seller_id`=%d",
            MP_LOT_ACTIVE, account_id);
    }
    else
    {
        // Do not trust the denormalized item_type column here. Older rows and
        // rows created by previous adapter revisions can contain a stale type.
        // Marketplace_OnLotsLoaded validates the real item_id before sending.
        mysql_format(mysql, where, sizeof(where),
            "WHERE l.`status`=%d AND l.`expires_at`>%d",
            MP_LOT_ACTIVE, gettime());

        if(tab == MP_TAB_FAVORITES)
        {
            strcat(where, " AND f.`account_id` IS NOT NULL", sizeof(where));
        }
    }

    if(strlen(g_MP_Search[playerid]))
    {
        new where_base[512];
        format(where_base, sizeof(where_base), "%s", where);
        mysql_escape_string(g_MP_Search[playerid], escaped, mysql, sizeof(escaped));
        format(where, sizeof(where), "%s AND l.`item_name` LIKE '%%%s%%'", where_base, escaped);
    }

    switch(g_MP_Sort[playerid])
    {
        case 1: format(order, sizeof(order), "ORDER BY l.`price` ASC, l.`id` DESC");
        case 2: format(order, sizeof(order), "ORDER BY l.`price` DESC, l.`id` DESC");
        default: format(order, sizeof(order), "ORDER BY l.`is_hot` DESC, l.`id` DESC");
    }

    mysql_format(mysql, query, sizeof(query),
        "SELECT l.*,IF(a.`name` IS NULL OR a.`name`='',l.`seller_name`,a.`name`) AS `seller_display_name`,IF(f.`account_id` IS NULL,0,1) AS `is_liked` FROM `marketplace_lots` l LEFT JOIN `accounts` a ON a.`id`=l.`seller_id` LEFT JOIN `marketplace_favorites` f ON f.`lot_id`=l.`id` AND f.`account_id`=%d %s %s LIMIT %d,%d",
        account_id, where, order, offset, page_capacity + 1);

    printf("[MARKET] list request player=%d tab=%d page=%d query=%s", playerid, tab, g_MP_CurrentPage[playerid], query);

    mysql_tquery(mysql, query, "Marketplace_OnLotsLoaded", "iii", playerid, response_type, tab);
    return 1;
}

public Marketplace_OnLotsLoaded(playerid, response_type, tab)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new rows, fields;
    cache_get_data(rows, fields, mysql);

    new Node:json = JSON_Object();
    new Node:products = JSON_Array();
    new use_vip_slot = Marketplace_UsesVipPromoSlot(playerid, tab);
    new page_capacity = MARKETPLACE_MAX_PAGE_LOTS;
    if(use_vip_slot && g_MP_CurrentPage[playerid] == 0) page_capacity--;

    // One extra SQL row is requested only to know whether another page exists.
    new has_more = (rows > page_capacity);
    new pages = has_more ? (g_MP_CurrentPage[playerid] + 2) : (g_MP_CurrentPage[playerid] + 1);
    new appended = 0;

    for(new i = 0; i < rows && appended < page_capacity; i++)
    {
        new loaded_item_id = cache_get_field_content_int(i, "item_id", mysql);
        if(tab != MP_TAB_MY_STORE && !Marketplace_IsAllowedItem(loaded_item_id)) continue;

        // Recalculate the type from the authoritative item_id. Some lots saved
        // by older revisions have item_type=0 even though the item is a skin or
        // accessory; sending that stale value makes the client discard the card.
        new loaded_item_type = Marketplace_GetProductType(loaded_item_id);
        if(loaded_item_type <= 0 && tab != MP_TAB_MY_STORE) continue;

        new item_name[64], seller_name[24];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "seller_display_name", seller_name, mysql, sizeof(seller_name));

        // Build the card directly in the cache callback. Returning child JSON
        // nodes from another Pawn function is unsafe on this pawn-json build and
        // could leave SQL rows present while the outgoing array stayed empty.
        new loaded_lot_id = cache_get_field_content_int(i, "id", mysql);
        new loaded_item_count = cache_get_field_content_int(i, "item_count", mysql);
        new loaded_amount = cache_get_field_content_int(i, "amount", mysql);
        new loaded_price = cache_get_field_content_int(i, "price", mysql);
        new loaded_rarity = cache_get_field_content_int(i, "rarity", mysql);
        new loaded_seller_id = cache_get_field_content_int(i, "seller_id", mysql);
        new loaded_created_at = cache_get_field_content_int(i, "created_at", mysql);
        new loaded_expires_at = cache_get_field_content_int(i, "expires_at", mysql);
        new loaded_hot = cache_get_field_content_int(i, "is_hot", mysql);
        new loaded_liked = cache_get_field_content_int(i, "is_liked", mysql);
        new loaded_client_time = Marketplace_GetLotClientTime(loaded_created_at, loaded_expires_at);
        new loaded_client_model = Marketplace_GetLotClientModel(loaded_item_id, loaded_item_count, "");
        new card_title[96];
        Marketplace_FormatCardTitle(item_name, seller_name, card_title, sizeof(card_title));

        new Node:item = JSON_Object();
        JSON_SetInt(item, "id", loaded_lot_id);
        JSON_SetInt(item, "tp", 0);
        JSON_SetInt(item, "tm", loaded_hot);
        JSON_SetInt(item, "ti", loaded_client_time);
        JSON_SetInt(item, "md", loaded_item_id);
        JSON_SetInt(item, "mi", loaded_client_model);
        JSON_SetInt(item, "model", loaded_client_model);
        JSON_SetInt(item, "it", loaded_item_type);
        JSON_SetInt(item, "cs", loaded_price);
        JSON_SetInt(item, "ct", (loaded_item_id == 134 ? loaded_client_model : loaded_amount));
        JSON_SetString(item, "dm", card_title, sizeof(card_title));
        JSON_SetInt(item, "r", loaded_rarity);
        JSON_SetInt(item, "rt", loaded_rarity);
        JSON_SetString(item, "nm", seller_name, sizeof(seller_name));
        JSON_SetString(item, "sl", seller_name, sizeof(seller_name));
        JSON_SetInt(item, "sid", loaded_seller_id);
        JSON_SetInt(item, "l", loaded_liked ? 1 : 0);
        JSON_SetInt(item, "tb", loaded_created_at);

        products = JSON_Append(products, JSON_Array(item));
        appended++;
    }

    if(response_type > 0) JSON_SetInt(json, "t", response_type);
    else
    {
        JSON_SetInt(json, "o", 1);
        JSON_SetInt(json, "t", MP_TAB_MAIN);
    }

    new products_count = 0;
    JSON_ArrayLength(products, products_count);
    if(products_count < 0) products_count = appended;

    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));

    // Keep the proven legacy product-card protocol untouched. VIP appearance is
    // controlled only by top-level fields: v is the player's real VIP tier.
    // tm activates the built-in "Best offer" card only when page 1 has a slot
    // reserved for it, so it cannot overlap a skin or accessory listing.
    JSON_SetInt(json, "v", Marketplace_GetVipTypeForGui(playerid));
    JSON_SetInt(json, "vm", MARKETPLACE_VIP_PROMO_PRICE);
    JSON_SetInt(json, "tm", (use_vip_slot && g_MP_CurrentPage[playerid] == 0) ? MARKETPLACE_VIP_PROMO_TIMER : 0);
    JSON_SetInt(json, "lp", products_count);
    JSON_SetInt(json, "ls", pages);
    JSON_SetInt(json, "lt", g_MP_CurrentPage[playerid] + 1);
    JSON_SetArray(json, "n", products);

    printf("[MARKET] list loaded player=%d tab=%d sql_rows=%d appended=%d json_cards=%d", playerid, tab, rows, appended, products_count);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_OpenGUI(playerid)
{
    if(!IsPlayerLogged(playerid)) return ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe0\xe2\xf2\xee\xf0\xe8\xe7\xee\xe2\xe0\xf2\xfc\xf1\xff\x2e", "");
    SetPVarInt(playerid, "market_open_pending", 1);
    Marketplace_ClaimMoney(playerid, 0);
    g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
    g_MP_CurrentPage[playerid] = 0;
    g_MP_Search[playerid][0] = EOS;
    Marketplace_SendLotsRequest(playerid, 0, MP_TAB_MAIN);
    return 1;
}

stock Marketplace_SendProfile(playerid)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query), "SELECT COUNT(*) AS active_count, LEAST(IFNULL(SUM((`price`*`amount`)),0),%d) AS active_sum FROM `marketplace_lots` WHERE `seller_id`=%d AND `status`=%d", MARKETPLACE_MAX_TOTAL, GetPlayerAccountID(playerid), MP_LOT_ACTIVE);
    mysql_tquery(mysql, query, "Marketplace_OnProfileLoaded", "i", playerid);
    return 1;
}

public Marketplace_OnProfileLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new active_count, active_sum;
    if(rows)
    {
        active_count = cache_get_field_content_int(0, "active_count", mysql);
        active_sum = cache_get_field_content_int(0, "active_sum", mysql);
    }

    new Node:json = JSON_Object();
    new Node:arr = JSON_Array();
    new Node:item = JSON_Object();
    JSON_SetInt(item, "id", GetPlayerAccountID(playerid));
    new seller_buf[MAX_PLAYER_NAME];
    format(seller_buf, sizeof seller_buf, "%s", GetPlayerNameEx(playerid));
    JSON_SetString(item, "dm", seller_buf, sizeof(seller_buf));
    JSON_SetInt(item, "ct", active_count);
    JSON_SetInt(item, "cs", active_sum);
    JSON_SetInt(item, "ma", GetPlayerMoneyEx(playerid));
    JSON_SetInt(item, "tm", gettime());
    JSON_SetInt(item, "r", 1);
    arr = JSON_Append(arr, JSON_Array(item));

    JSON_SetInt(json, "t", MP_TAB_PROFILE);
    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "v", Marketplace_GetVipTypeForGui(playerid));
    JSON_SetInt(json, "vm", MARKETPLACE_VIP_PROMO_PRICE);
    JSON_SetInt(json, "lp", active_count);
    JSON_SetArray(json, "n", arr);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SendHistory(playerid)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_history` WHERE `account_id`=%d ORDER BY `id` DESC LIMIT %d", GetPlayerAccountID(playerid), MARKETPLACE_MAX_PAGE_LOTS);
    mysql_tquery(mysql, query, "Marketplace_OnHistoryLoaded", "i", playerid);
    return 1;
}

public Marketplace_OnHistoryLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new Node:json = JSON_Object();
    new Node:history = JSON_Array();
    for(new i = 0; i < rows; i++)
    {
        new item_name[64], seller_name[24];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "seller_name", seller_name, mysql, sizeof(seller_name));
        new Node:item = Marketplace_MakeProductNode(
            cache_get_field_content_int(i, "lot_id", mysql),
            cache_get_field_content_int(i, "item_id", mysql),
            cache_get_field_content_int(i, "amount", mysql),
            cache_get_field_content_int(i, "amount", mysql),
            cache_get_field_content_int(i, "price", mysql),
            item_name,
            Marketplace_GetProductType(cache_get_field_content_int(i, "item_id", mysql)),
            Marketplace_GetRarity(cache_get_field_content_int(i, "item_id", mysql)),
            0,
            seller_name,
            cache_get_field_content_int(i, "created_at", mysql),
            cache_get_field_content_int(i, "created_at", mysql) + MARKETPLACE_DEFAULT_EXPIRE,
            0
        );
        JSON_ToggleGC(item, true);
        history = JSON_Append(history, JSON_Array(item));
    }
    JSON_SetInt(json, "t", MP_TAB_HISTORY);
    JSON_SetInt(json, "v", Marketplace_GetVipTypeForGui(playerid));
    JSON_SetInt(json, "vm", MARKETPLACE_VIP_PROMO_PRICE);
    JSON_SetInt(json, "ls", 1);
    JSON_SetArray(json, "n", history);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SelectInventorySlot(playerid, source_id)
{
    if(!Market_CanSellSource(playerid, source_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_SELECT_INV_ITEM, 0);
        return 0;
    }

    new item_id = Market_GetSourceItemId(playerid, source_id);
    g_MP_SelectedSlot[playerid] = source_id;
    g_MP_SelectedSellCount[playerid] = 1;

    new Node:json = JSON_Object();
    new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
    JSON_ToggleGC(item, true);
    JSON_SetInt(json, "t", MP_ACT_SELECT_INV_ITEM);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "rk", Marketplace_GetRarity(item_id));
    JSON_SetInt(json, "id", source_id);
    JSON_SetInt(json, "md", item_id);
    JSON_SetInt(json, "ct", (item_id == 134 ? Market_GetSourceItemCount(playerid, source_id) : Marketplace_GetSlotSellAmount(playerid, source_id)));
    JSON_SetInt(json, "cs", 0);

    new item_name[64];
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));

    new Node:arr = JSON_Array(item);
    JSON_SetArray(json, "n", arr);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_PublishSelected(playerid, amount, price, hot)
{
    new source_id = g_MP_SelectedSlot[playerid];
    if(!Market_CanSellSource(playerid, source_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        return 0;
    }

    if(price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xd3\xea\xe0\xe6\xe8\xf2\xe5 \xea\xee\xf0\xf0\xe5\xea\xf2\xed\xf3\xfe \xf6\xe5\xed\xf3.", "");
        return 0;
    }

    new item_id = Market_GetSourceItemId(playerid, source_id);
    if(!Marketplace_IsAllowedItem(item_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "Marketplace: only skins and accessories can be sold.", "");
        return 0;
    }
    new max_amount = Marketplace_GetSlotSellAmount(playerid, source_id);
    if(amount < 1) amount = 1;
    if(amount > max_amount) amount = max_amount;
    if(Marketplace_IsSpecialItem(item_id)) amount = 1;

    if(amount > 0 && price > (MARKETPLACE_MAX_TOTAL / amount))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xce\xe1\xf9\xe0\xff \xf1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc \xeb\xee\xf2\xe0 \xf1\xeb\xe8\xf8\xea\xee\xec \xe2\xe5\xeb\xe8\xea\xe0.", "");
        return 0;
    }

    new inv_count = Market_GetSourceItemCount(playerid, source_id);
    if(Market_IsAccessoryInventoryItem(item_id)) inv_count = 1;

    new item_plate[32], item_name[64], seller_name[MAX_PLAYER_NAME];
    Market_GetSourcePlate(playerid, source_id, item_plate, sizeof(item_plate));
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));
    format(seller_name, sizeof(seller_name), "%s", GetPlayerNameEx(playerid));

    new item_type = Marketplace_GetProductType(item_id);
    new rarity = Marketplace_GetRarity(item_id);
    new created = gettime();
    new expires = created + MARKETPLACE_DEFAULT_EXPIRE;
    hot = 0;

    new query[1200];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_lots` (`seller_id`,`seller_name`,`item_id`,`item_count`,`amount`,`item_plate`,`item_name`,`item_type`,`rarity`,`price`,`is_hot`,`status`,`created_at`,`expires_at`) VALUES (%d,'%e',%d,%d,%d,'%e','%e',%d,%d,%d,%d,%d,%d,%d)",
        GetPlayerAccountID(playerid), seller_name, item_id, inv_count, amount, item_plate, item_name,
        item_type, rarity, price, hot, MP_LOT_ACTIVE, created, expires);

    new Cache:insert_result = mysql_query(mysql, query, true);
    new inserted_lot_id = cache_insert_id();
    cache_delete(insert_result);

    if(inserted_lot_id <= 0)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcb\xee\xf2 \xed\xe5 \xe2\xfb\xf1\xf2\xe0\xe2\xeb\xe5\xed. \xcf\xf0\xe5\xe4\xec\xe5\xf2 \xee\xf1\xf2\xe0\xeb\xf1\xff \xe2 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xe5.", "");
        return 0;
    }

    new removed;
    if(Marketplace_IsSpecialItem(item_id) || amount >= max_amount)
        removed = Market_DeleteSource(playerid, source_id);
    else
        removed = Inventory_RemoveItem(playerid, source_id, amount);

    if(!removed)
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_lots` WHERE `id`=%d LIMIT 1", inserted_lot_id);
        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcb\xee\xf2 \xee\xf2\xec\xe5\xed\xb8\xed: \xef\xf0\xe5\xe4\xec\xe5\xf2 \xed\xe5 \xf3\xe4\xe0\xeb\xee\xf1\xfc \xf3\xe4\xe0\xeb\xe8\xf2\xfc \xe8\xe7 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xff.", "");
        return 0;
    }

    g_MP_SelectedSlot[playerid] = -1;
    g_MP_SelectedSellCount[playerid] = 1;

    printf("[MARKET] published lot=%d seller=%d item=%d type=%d model=%d price=%d expires=%d",
        inserted_lot_id, GetPlayerAccountID(playerid), item_id, item_type, inv_count, price, expires);

    Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 1);

    // Refresh the main storefront using the same response type as the initial
    // marketplace opening. This makes the newly published lot visible at once
    // and avoids client builds which do not redraw the My Store tab correctly.
    g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
    g_MP_CurrentPage[playerid] = 0;
    g_MP_Search[playerid][0] = EOS;
    Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
    ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xcb\xee\xf2 \xe2\xfb\xf1\xf2\xe0\xe2\xeb\xe5\xed \xed\xe0 \xef\xf0\xee\xe4\xe0\xe6\xf3.", "");
    return 1;
}

stock Marketplace_RequestBuy(playerid, lot_id)
{
    new query[512];
    mysql_format(mysql, query, sizeof(query), "SELECT l.*,IF(a.`name` IS NULL OR a.`name`='',l.`seller_name`,a.`name`) AS `seller_display_name` FROM `marketplace_lots` l LEFT JOIN `accounts` a ON a.`id`=l.`seller_id` WHERE l.`id`=%d AND l.`status`=0 AND l.`expires_at`>%d LIMIT 1", lot_id, gettime());
    mysql_tquery(mysql, query, "Marketplace_OnBuyInfoLoaded", "ii", playerid, lot_id);
    return 1;
}

public Marketplace_OnBuyInfoLoaded(playerid, lot_id)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    if(!rows)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_BUY_CLICK, 0);
        return 0;
    }
    new item_name[64], seller_name[24];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_get_field_content(0, "seller_display_name", seller_name, mysql, sizeof(seller_name));
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_BUY_CLICK);
    JSON_SetInt(json, "id", lot_id);
    new buy_item_id = cache_get_field_content_int(0, "item_id", mysql);
    if(!Marketplace_IsAllowedItem(buy_item_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_BUY_CLICK, 0);
        JSON_Cleanup(json);
        return 0;
    }
    new buy_item_count = cache_get_field_content_int(0, "item_count", mysql);
    JSON_SetInt(json, "md", buy_item_id);
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetString(json, "sl", seller_name, sizeof(seller_name));
    JSON_SetInt(json, "sid", cache_get_field_content_int(0, "seller_id", mysql));
    JSON_SetInt(json, "ct", (buy_item_id == 134 ? buy_item_count : cache_get_field_content_int(0, "amount", mysql)));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_ReserveLot(lot_id, seller_id = 0, check_expire = 1)
{
    new query[320];

    if(seller_id > 0)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, seller_id, MP_LOT_ACTIVE);
    }
    else if(check_expire)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d AND `expires_at`>%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, MP_LOT_ACTIVE, gettime());
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, MP_LOT_ACTIVE);
    }

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);
    return affected > 0;
}

stock Marketplace_ReleaseLot(lot_id)
{
    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
        MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);
    mysql_tquery(mysql, query);
    return 1;
}

stock Marketplace_ConfirmBuy(playerid, lot_id, amount)
{
    if(!IsPlayerLogged(playerid)) return 0;
    if(amount < 1) amount = 1;

    if(!Marketplace_ReserveLot(lot_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xdd\xf2\xee\xf2\x20\xeb\xee\xf2\x20\xf3\xe6\xe5\x20\xed\xe5\xe4\xee\xf1\xf2\xf3\xef\xe5\xed\x2e", "");
        return 0;
    }

    new query[1200];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `status`=%d LIMIT 1",
        lot_id, MP_LOT_RESERVED);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    new seller_id = cache_get_field_content_int(0, "seller_id", mysql);
    new lot_amount = cache_get_field_content_int(0, "amount", mysql);
    new price = cache_get_field_content_int(0, "price", mysql);
    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new inv_count = cache_get_field_content_int(0, "item_count", mysql);
    new plate[32], item_name[64], seller_name[24], buyer_name[24];

    cache_get_field_content(0, "item_plate", plate, mysql, sizeof(plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_get_field_content(0, "seller_name", seller_name, mysql, sizeof(seller_name));
    cache_delete(result);

    if(!Marketplace_IsAllowedItem(item_id))
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "Marketplace: this item type is no longer sold.", "");
        return 0;
    }

    if(seller_id == GetPlayerAccountID(playerid))
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\xeb\xfc\xe7\xff\x20\xea\xf3\xef\xe8\xf2\xfc\x20\xf1\xee\xe1\xf1\xf2\xe2\xe5\xed\xed\xfb\xe9\x20\xeb\xee\xf2\x2e", "");
        return 0;
    }

    if(lot_amount < 1 || price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(amount > lot_amount) amount = lot_amount;
    if(amount < 1) amount = 1;

    if(amount > (MARKETPLACE_MAX_TOTAL / price))
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    new total_price = price * amount;
    if(GetPlayerMoneyEx(playerid) < total_price)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\xe4\xee\xf1\xf2\xe0\xf2\xee\xf7\xed\xee\x20\xe4\xe5\xed\xe5\xe3\x20\xe4\xeb\xff\x20\xef\xee\xea\xf3\xef\xea\xe8\x2e", "");
        return 0;
    }

    if(!Marketplace_IsSpecialItem(item_id)) inv_count = amount;

    new bool:queued_to_reward = false;
    new freeSlot = Inventory_GetDeliverySlot(playerid, item_id);

    if(amount >= lot_amount)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_SOLD, GetPlayerAccountID(playerid), lot_id, MP_LOT_RESERVED);
    }
    else
    {
        // Keep the remainder reserved until item delivery finishes. This prevents
        // a second buyer from taking the lot while the first purchase is finalizing.
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `amount`=`amount`-%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            amount, lot_id, MP_LOT_RESERVED);
    }

    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);

    if(!updated)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(freeSlot == -1)
    {
        if(MPReward_QueueInvItem(GetPlayerAccountID(playerid), item_id, inv_count, plate, item_name, lot_id) <= 0)
        {
            if(amount >= lot_amount)
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=0 WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            else
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `amount`=`amount`+%d,`status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1", amount, MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);

            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
            ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\x20\xf3\xe4\xe0\xeb\xee\xf1\xfc\x20\xf1\xee\xf5\xf0\xe0\xed\xe8\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x20\xe2\x20\xed\xe0\xe3\xf0\xe0\xe4\xfb\x20\x2f\x6d\x70\x72\x65\x77\x61\x72\x64\x2e", "");
            return 0;
        }
        queued_to_reward = true;
    }
    else if(!Inventory_AddItem(playerid, item_id, freeSlot, inv_count, plate))
    {
        if(amount >= lot_amount)
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=0 WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
        else
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `amount`=`amount`+%d,`status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1", amount, MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);

        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(amount < lot_amount)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);
        new Cache:release_result = mysql_query(mysql, query, true);
        new released = cache_affected_rows(mysql);
        cache_delete(release_result);

        if(!released)
        {
            // Delivery already succeeded; do not restore quantity and duplicate the
            // item. Charge the purchase normally; startup recovery will reopen the
            // reduced remainder if this reservation stays locked.
            ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcf\xee\xea\xf3\xef\xea\xe0\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe5\xed\xe0\x2c\x20\xed\xee\x20\xee\xe1\xed\xee\xe2\xeb\xe5\xed\xe8\xe5\x20\xee\xf1\xf2\xe0\xf2\xea\xe0\x20\xeb\xee\xf2\xe0\x20\xe7\xe0\xe4\xe5\xf0\xe6\xe0\xeb\xee\xf1\xfc\x2e", "");
        }
    }

    GivePlayerMoneyEx(playerid, -total_price, "Marketplace buy", true, true);

    new seller_tax = ((total_price / 100) * MARKETPLACE_SELL_TAX) + (((total_price % 100) * MARKETPLACE_SELL_TAX) / 100);
    new seller_money = total_price - seller_tax;
    Marketplace_AddMoneyToAccount(seller_id, seller_money);

    format(buyer_name, sizeof(buyer_name), "%s", GetPlayerNameEx(playerid));

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_history` (`account_id`,`lot_id`,`item_id`,`amount`,`price`,`status`,`seller_name`,`buyer_name`,`item_name`,`created_at`) VALUES (%d,%d,%d,%d,%d,1,'%e','%e','%e',%d),(%d,%d,%d,%d,%d,2,'%e','%e','%e',%d)",
        GetPlayerAccountID(playerid), lot_id, item_id, amount, total_price, seller_name, buyer_name, item_name, gettime(),
        seller_id, lot_id, item_id, amount, total_price, seller_name, buyer_name, item_name, gettime());
    mysql_tquery(mysql, query);

    // Remove the purchased lot from every favorites list.
    // This also prevents a stale liked flag from remaining on the client
    // after the purchase.
    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_favorites` WHERE `lot_id`=%d", lot_id);
    // Complete deletion before refreshing GUI to avoid stale favorites.
    mysql_query(mysql, query);

    // Send current data again to replace any stale GUI cache.
    // Read the balance after charging the buyer.
    new Node:money_json = JSON_Object();
    JSON_SetInt(money_json, "t", MP_ACT_MONEY_UPDATE);
    new synced_money = GetPlayerMoneyEx(playerid);
    // Do not overwrite the client balance with an unsynchronized zero.
    if(synced_money > 0)
    {
        JSON_SetInt(money_json, "m", synced_money);
        Marketplace_Send(money_json, playerid);
    }
    JSON_Cleanup(money_json);

    Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 1);
    Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
    Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);

    if(queued_to_reward)
        ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xc8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\x20\xe7\xe0\xef\xee\xeb\xed\xe5\xed\x2e\x20\xcf\xf0\xe5\xe4\xec\xe5\xf2\x20\xee\xf2\xef\xf0\xe0\xe2\xeb\xe5\xed\x20\xe2\x20\x2f\x6d\x70\x72\x65\x77\x61\x72\x64\x2e", "");
    else
        ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xcf\xee\xea\xf3\xef\xea\xe0\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe5\xed\xe0\x2e\x20\xcf\xf0\xe5\xe4\xec\xe5\xf2\x20\xe4\xee\xe1\xe0\xe2\xeb\xe5\xed\x20\xe2\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\x2e", "");

    return 1;
}

public Marketplace_OnConfirmBuyLoaded(playerid, lot_id, amount)
{
    #pragma unused playerid
    #pragma unused lot_id
    #pragma unused amount
    return 1;
}

stock Marketplace_DeleteOrWithdrawLot(playerid, lot_id)
{
    if(!IsPlayerLogged(playerid)) return 0;

    if(!Marketplace_ReserveLot(lot_id, GetPlayerAccountID(playerid), 0))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
        lot_id, GetPlayerAccountID(playerid), MP_LOT_RESERVED);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new inv_count = cache_get_field_content_int(0, "item_count", mysql);
    new amount = cache_get_field_content_int(0, "amount", mysql);
    new plate[32], item_name[64];

    cache_get_field_content(0, "item_plate", plate, mysql, sizeof(plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_delete(result);

    if(!Marketplace_IsSpecialItem(item_id)) inv_count = amount;

    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
        MP_LOT_WITHDRAWN, lot_id, MP_LOT_RESERVED);

    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);

    if(!updated)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new bool:returned_to_reward = false;
    new freeSlot = Inventory_GetDeliverySlot(playerid, item_id);

    if(freeSlot == -1)
    {
        if(MPReward_QueueInvItem(GetPlayerAccountID(playerid), item_id, inv_count, plate, item_name, lot_id) <= 0)
        {
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
            ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\x20\xf3\xe4\xe0\xeb\xee\xf1\xfc\x20\xf1\xee\xf5\xf0\xe0\xed\xe8\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x20\xe2\x20\xed\xe0\xe3\xf0\xe0\xe4\xfb\x20\x2f\x6d\x70\x72\x65\x77\x61\x72\x64\x2e", "");
            return 0;
        }
        returned_to_reward = true;
    }
    else if(!Inventory_AddItem(playerid, item_id, freeSlot, inv_count, plate))
    {
        mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_favorites` WHERE `lot_id`=%d", lot_id);
    // Complete deletion before refreshing GUI to avoid stale favorites.
    mysql_query(mysql, query);

    Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 1);
    Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);

    if(returned_to_reward)
        ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xc8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\x20\xe7\xe0\xef\xee\xeb\xed\xe5\xed\x2e\x20\xcb\xee\xf2\x20\xe2\xee\xe7\xe2\xf0\xe0\xf9\xb8\xed\x20\xe2\x20\x2f\x6d\x70\x72\x65\x77\x61\x72\x64\x2e", "");
    else
        ShowNotificationLaird(playerid, 1, 5, -1, -1, "\xcb\xee\xf2\x20\xf1\xed\xff\xf2\x20\xf1\x20\xef\xf0\xee\xe4\xe0\xe6\xe8\x2c\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x20\xe2\xee\xe7\xe2\xf0\xe0\xf9\xb8\xed\x20\xe2\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\x2e", "");

    return 1;
}

public Marketplace_OnWithdrawLoaded(playerid, lot_id)
{
    #pragma unused playerid
    #pragma unused lot_id
    return 1;
}

stock Marketplace_EditLot(playerid, lot_id, price)
{
    if(price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_EDIT, 0);
        return 0;
    }

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `price`=%d WHERE `id`=%d AND `seller_id`=%d AND `status`=%d AND `amount`<=%d LIMIT 1",
        price, lot_id, GetPlayerAccountID(playerid), MP_LOT_ACTIVE, MARKETPLACE_MAX_TOTAL / price);

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);

    Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_EDIT, affected > 0);
    if(affected > 0)
        Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);
    else
        ShowNotificationLaird(playerid, 2, 5, -1, -1, "\xcd\xe5\x20\xf3\xe4\xe0\xeb\xee\xf1\xfc\x20\xe8\xe7\xec\xe5\xed\xe8\xf2\xfc\x20\xf6\xe5\xed\xf3\x3a\x20\xef\xf0\xee\xe2\xe5\xf0\xfc\xf2\xe5\x20\xeb\xe8\xec\xe8\xf2\x20\xee\xe1\xf9\xe5\xe9\x20\xf1\xf2\xee\xe8\xec\xee\xf1\xf2\xe8\x2e", "");
    return affected > 0;
}

stock Marketplace_RequestEdit(playerid, lot_id)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
        lot_id, GetPlayerAccountID(playerid), MP_LOT_ACTIVE);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_SendActionResult(playerid, MP_ACT_EDIT_LOT, 0);
        return 0;
    }

    new item_name[64];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_EDIT_LOT);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    new edit_item_id = cache_get_field_content_int(0, "item_id", mysql);
    new edit_item_count = cache_get_field_content_int(0, "item_count", mysql);
    JSON_SetInt(json, "md", edit_item_id);
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetInt(json, "ct", (edit_item_id == 134 ? edit_item_count : cache_get_field_content_int(0, "amount", mysql)));
    JSON_SetInt(json, "rs", cache_get_field_content_int(0, "is_hot", mysql));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    cache_delete(result);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_ToggleLike(playerid, lot_id)
{
    if(lot_id <= 0 || !IsPlayerLogged(playerid)) return 0;

    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `lot_id` FROM `marketplace_favorites` WHERE `account_id`=%d AND `lot_id`=%d LIMIT 1",
        GetPlayerAccountID(playerid), lot_id);

    new Cache:result = mysql_query(mysql, query, true);
    new liked = cache_num_rows() > 0;
    cache_delete(result);

    if(liked)
    {
        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `marketplace_favorites` WHERE `account_id`=%d AND `lot_id`=%d LIMIT 1",
            GetPlayerAccountID(playerid), lot_id);

        new Cache:delete_result = mysql_query(mysql, query, true);
        new changed = cache_affected_rows(mysql);
        cache_delete(delete_result);
        if(!changed) return Marketplace_SendActionResult(playerid, MP_ACT_LIKE, 0);
        liked = 0;
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "INSERT IGNORE INTO `marketplace_favorites` (`account_id`,`lot_id`,`created_at`) SELECT %d,`id`,%d FROM `marketplace_lots` WHERE `id`=%d AND `status`=%d AND `expires_at`>%d LIMIT 1",
            GetPlayerAccountID(playerid), gettime(), lot_id, MP_LOT_ACTIVE, gettime());

        new Cache:insert_result = mysql_query(mysql, query, true);
        new changed = cache_affected_rows(mysql);
        cache_delete(insert_result);
        if(!changed) return Marketplace_SendActionResult(playerid, MP_ACT_LIKE, 0);
        liked = 1;
    }

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_LIKE);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    JSON_SetInt(json, "l", liked);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);

    if(g_MP_CurrentTab[playerid] == MP_TAB_FAVORITES && !liked)
        Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);

    return 1;
}

stock Marketplace_RequestHistoryInfo(playerid, lot_id)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_history` WHERE `account_id`=%d AND `lot_id`=%d ORDER BY `id` DESC LIMIT 1",
        GetPlayerAccountID(playerid), lot_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_SendActionResult(playerid, MP_ACT_HISTORY_CARD, 0);
        return 0;
    }

    new item_name[64], seller_name[24];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_get_field_content(0, "seller_name", seller_name, mysql, sizeof(seller_name));

    new history_item_id = cache_get_field_content_int(0, "item_id", mysql);
    new history_model = Marketplace_GetLotClientModel(history_item_id, cache_get_field_content_int(0, "amount", mysql), "");
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_HISTORY_CARD);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    JSON_SetInt(json, "md", history_item_id);
    JSON_SetInt(json, "mi", history_model);
    JSON_SetInt(json, "model", history_model);
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetInt(json, "ct", (history_item_id == 134 ? history_model : cache_get_field_content_int(0, "amount", mysql)));
    JSON_SetInt(json, "st", cache_get_field_content_int(0, "status", mysql));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    JSON_SetString(json, "nm", seller_name, sizeof(seller_name));
    JSON_SetString(json, "sl", seller_name, sizeof(seller_name));
    cache_delete(result);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_OnPacket(playerid, Node:json)
{
    new type;
    JSON_GetInt(json, "t", type);

    switch(type)
    {
        case MP_TAB_PROFILE:
        {
            Marketplace_SendProfile(playerid);
        }
        case MP_TAB_MAIN:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
            g_MP_CurrentPage[playerid] = 0;
            g_MP_Search[playerid][0] = EOS;
            Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
        }
        case MP_TAB_HISTORY:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_HISTORY;
            Marketplace_SendHistory(playerid);
        }
        case MP_TAB_FAVORITES:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_FAVORITES;
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);
        }
        case MP_TAB_MY_STORE:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_MY_STORE;
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);
        }
        case MP_TAB_INVENTORY:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_INVENTORY;
            Marketplace_SendInventoryProducts(playerid, MP_TAB_INVENTORY);
        }
        case MP_ACT_PAGE:
        {
            new page;
            JSON_GetInt(json, "lt", page);
            if(page < 0) page = 0;
            g_MP_CurrentPage[playerid] = page;
            Marketplace_SendLotsRequest(playerid, MP_ACT_PAGE, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_CREATE_LOT:
        {
            Marketplace_SendInventoryProducts(playerid, MP_ACT_CREATE_LOT);
        }
        case MP_ACT_SELECT_INV_ITEM:
        {
            new slot;
            JSON_GetInt(json, "id", slot);
            Marketplace_SelectInventorySlot(playerid, slot);
        }
        case MP_ACT_PUBLISH_LOT:
        {
            new amount, price, hot;
            JSON_GetInt(json, "ct", amount);
            JSON_GetInt(json, "cs", price);
            JSON_GetInt(json, "rs", hot);
            Marketplace_PublishSelected(playerid, amount, price, hot);
        }
        case MP_ACT_BUY_CLICK:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            g_MP_SelectedLot[playerid] = lot_id;
            Marketplace_RequestBuy(playerid, lot_id);
        }
        case MP_ACT_CONFIRM_BUY:
        {
            new lot_id, amount;
            JSON_GetInt(json, "id", lot_id);
            JSON_GetInt(json, "ct", amount);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_ConfirmBuy(playerid, lot_id, amount);
        }
        case MP_ACT_EDIT_LOT:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            g_MP_SelectedLot[playerid] = lot_id;
            Marketplace_RequestEdit(playerid, lot_id);
        }
        case MP_ACT_CONFIRM_EDIT:
        {
            new lot_id, price;
            JSON_GetInt(json, "id", lot_id);
            JSON_GetInt(json, "cs", price);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_EditLot(playerid, lot_id, price);
        }
        case MP_ACT_DELETE_LOT:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_DeleteOrWithdrawLot(playerid, lot_id);
        }
        case MP_ACT_HISTORY_CARD:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            Marketplace_RequestHistoryInfo(playerid, lot_id);
        }
        case MP_ACT_SEARCH:
        {
            JSON_GetString(json, "s", g_MP_Search[playerid], 64);
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_ACT_SEARCH, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_SORT:
        {
            new sort;
            JSON_GetInt(json, "st", sort);
            if(sort < 0 || sort > 2) sort = 0;
            g_MP_Sort[playerid] = sort;
            Marketplace_SendLotsRequest(playerid, MP_ACT_SORT, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_LIKE:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            Marketplace_ToggleLike(playerid, lot_id);
        }
        case MP_ACT_FILTER, MP_ACT_DOTS_UPDATE, MP_ACT_LIKED_ARRAY:
        {
            Marketplace_SendLotsRequest(playerid, type, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_MONEY_UPDATE:
        {
            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", MP_ACT_MONEY_UPDATE);
            JSON_SetInt(response, "m", GetPlayerMoneyEx(playerid));
            Marketplace_Send(response, playerid);
            JSON_Cleanup(response);
        }
        case MP_ACT_BUY_VIP, MP_ACT_DONATE:
        {
            // The marketplace client sends type 20 from the Platinum VIP promo
            // Buy button (type 7 is the generic donate shortcut). Close the
            // marketplace and open the existing donate GUI instead of returning
            // an error, so the player can immediately choose a Platinum package.
            Marketplace_SendActionResult(playerid, type, 1);

            new Node:close_json = JSON_Object();
            JSON_SetInt(close_json, "c", 1);
            Marketplace_Send(close_json, playerid);
            JSON_Cleanup(close_json);

            donatess(playerid);
        }
        case MP_ACT_NOTIFY_VIP:
        {
            Marketplace_SendVipOfferInfo(playerid);
        }
        default:
        {
            Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
        }
    }
    return 1;
}

CMD:marketplace(playerid, params[])
{
    if(!RequireThreeHoursForEconomy(playerid)) return 1;
    #pragma unused params
    Marketplace_OpenGUI(playerid);
    return 1;
}

CMD:market(playerid, params[])
{
    if(!RequireThreeHoursForEconomy(playerid)) return 1;
    #pragma unused params
    Marketplace_OpenGUI(playerid);
    return 1;
}

CMD:marketmoney(playerid, params[])
{
    if(!RequireThreeHoursForEconomy(playerid)) return 1;
    #pragma unused params
    Marketplace_ClaimMoney(playerid, 1);
    return 1;
}

stock Marketplace_ShowDialogMain(playerid)
{
    ShowPlayerDialog(playerid, MP_DIALOG_MAIN, DIALOG_STYLE_LIST, "\xcc\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1", "\xce\xf2\xea\xf0\xfb\xf2\xfc\x20\x47\x55\x49\n\xca\xf3\xef\xe8\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\xfb\n\xcf\xf0\xee\xe4\xe0\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x20\xe8\xe7\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xff\n\xcc\xee\xe8\x20\xeb\xee\xf2\xfb\n\xcf\xee\xe8\xf1\xea", "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xc7\xe0\xea\xf0\xfb\xf2\xfc");
    return 1;
}

CMD:marketd(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerLogged(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe0\xe2\xf2\xee\xf0\xe8\xe7\xee\xe2\xe0\xf2\xfc\xf1\xff\x2e");
    Marketplace_ShowDialogMain(playerid);
    return 1;
}

stock Marketplace_ShowDialogLots(playerid, my_lots = 0)
{
    new query[384];
    if(my_lots)
    {
        mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_lots` WHERE `seller_id`=%d AND `status`=0 ORDER BY `id` DESC LIMIT 30", GetPlayerAccountID(playerid));
        mysql_tquery(mysql, query, "Marketplace_OnDialogLots", "ii", playerid, 1);
    }
    else
    {
        mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_lots` WHERE `status`=0 AND `expires_at`>%d ORDER BY `is_hot` DESC, `id` DESC LIMIT 30", gettime());
        mysql_tquery(mysql, query, "Marketplace_OnDialogLots", "ii", playerid, 0);
    }
    return 1;
}

public Marketplace_OnDialogLots(playerid, my_lots)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new list[2048];
    list[0] = EOS;
    if(!rows) strcat(list, "\xcb\xee\xf2\xee\xe2\x20\xed\xe5\xf2\n", sizeof(list));
    for(new i = 0; i < rows && i < 30; i++)
    {
        new lot_id = cache_get_field_content_int(i, "id", mysql);
        new amount = cache_get_field_content_int(i, "amount", mysql);
        new price = cache_get_field_content_int(i, "price", mysql);
        new item_name[64], lot_line[128];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof item_name);
        format(lot_line, sizeof lot_line, "#%d %s x%d - %d rub\n", lot_id, item_name, amount, price);
        strcat(list, lot_line, sizeof list);
    }
    ShowPlayerDialog(playerid, my_lots ? MP_DIALOG_MYLOTS : MP_DIALOG_LOTS, DIALOG_STYLE_LIST, my_lots ? "\xcc\xee\xe8\x20\xeb\xee\xf2\xfb" : "\xcb\xee\xf2\xfb\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe0", list, "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
    return 1;
}

stock Marketplace_ShowInventoryDialog(playerid)
{
    Market_RefreshAccessoryCache(playerid);

    new list[2048];
    list[0] = EOS;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(!Market_CanSellSource(playerid, i)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, i, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s\n", i, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [active]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [equipped accessory]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    if(!strlen(list)) strcat(list, "Only skins and accessories can be sold\n", sizeof(list));
    ShowPlayerDialog(playerid, MP_DIALOG_INV, DIALOG_STYLE_LIST, "Marketplace inventory", list, "Sell", "Back");
    return 1;
}

stock Marketplace_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == MP_DIALOG_MAIN)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: Marketplace_OpenGUI(playerid);
            case 1: Marketplace_ShowDialogLots(playerid, 0);
            case 2: Marketplace_ShowInventoryDialog(playerid);
            case 3: Marketplace_ShowDialogLots(playerid, 1);
            case 4: ShowPlayerDialog(playerid, MP_DIALOG_SEARCH, DIALOG_STYLE_INPUT, "\xcf\xee\xe8\xf1\xea\x20\xe2\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe5", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xed\xe0\xe7\xe2\xe0\xed\xe8\xe5\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\xe0\x3a", "\xcf\xee\xe8\xf1\xea", "\xcd\xe0\xe7\xe0\xe4");
        }
        return 1;
    }
    if(dialogid == MP_DIALOG_LOTS)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new lot_id;
        if(sscanf(inputtext, "p<#>i", lot_id)) return 1;
        g_MP_SelectedLot[playerid] = lot_id;
        ShowPlayerDialog(playerid, MP_DIALOG_LOT_ACTION, DIALOG_STYLE_INPUT, "\xcf\xee\xea\xf3\xef\xea\xe0\x20\xeb\xee\xf2\xe0", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xea\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x20\xe4\xeb\xff\x20\xef\xee\xea\xf3\xef\xea\xe8\x3a", "\xca\xf3\xef\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_LOT_ACTION)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 0);
        new amount = strval(inputtext);
        if(amount < 1) amount = 1;
        Marketplace_ConfirmBuy(playerid, g_MP_SelectedLot[playerid], amount);
        return 1;
    }
    if(dialogid == MP_DIALOG_INV)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new slot = -1;
        if(strfind(inputtext, "slot ", true) == 0)
        {
            new colon = strfind(inputtext, ":", true), tmp[12];
            if(colon != -1)
            {
                strmid(tmp, inputtext, 5, colon, sizeof(tmp));
                slot = strval(tmp);
            }
        }
        if(!Market_CanSellSource(playerid, slot)) return 1;
        g_MP_SelectedSlot[playerid] = slot;
        ShowPlayerDialog(playerid, MP_DIALOG_SELL_COUNT, DIALOG_STYLE_INPUT, "\xca\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x20\xe4\xeb\xff\x20\xef\xf0\xee\xe4\xe0\xe6\xe8", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xea\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x3a", "\xc4\xe0\xeb\xe5\xe5", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_SELL_COUNT)
    {
        if(!response) return Marketplace_ShowInventoryDialog(playerid);
        new amount = strval(inputtext), max_amount = Marketplace_GetSlotSellAmount(playerid, g_MP_SelectedSlot[playerid]);
        if(amount < 1) amount = 1;
        if(amount > max_amount) amount = max_amount;
        g_MP_SelectedSellCount[playerid] = amount;
        ShowPlayerDialog(playerid, MP_DIALOG_SELL_PRICE, DIALOG_STYLE_INPUT, "\xd6\xe5\xed\xe0\x20\xef\xf0\xee\xe4\xe0\xe6\xe8", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xf6\xe5\xed\xf3\x20\xe7\xe0\x20\x31\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x3a", "\xc2\xfb\xf1\xf2\xe0\xe2\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_SELL_PRICE)
    {
        if(!response) return Marketplace_ShowInventoryDialog(playerid);
        new price = strval(inputtext);
        Marketplace_PublishSelected(playerid, g_MP_SelectedSellCount[playerid], price, 0);
        return 1;
    }
    if(dialogid == MP_DIALOG_MYLOTS)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new lot_id;
        if(sscanf(inputtext, "p<#>i", lot_id)) return 1;
        g_MP_SelectedLot[playerid] = lot_id;
        ShowPlayerDialog(playerid, MP_DIALOG_MYLOT_ACTION, DIALOG_STYLE_LIST, "\xcc\xee\xe9\x20\xeb\xee\xf2", "\xd1\xed\xff\xf2\xfc\x20\xe2\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\n\xc8\xe7\xec\xe5\xed\xe8\xf2\xfc\x20\xf6\xe5\xed\xf3", "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_MYLOT_ACTION)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 1);
        if(listitem == 0) Marketplace_DeleteOrWithdrawLot(playerid, g_MP_SelectedLot[playerid]);
        else ShowPlayerDialog(playerid, MP_DIALOG_EDIT_PRICE, DIALOG_STYLE_INPUT, "\xcd\xee\xe2\xe0\xff\x20\xf6\xe5\xed\xe0", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xed\xee\xe2\xf3\xfe\x20\xf6\xe5\xed\xf3\x3a", "\xd1\xee\xf5\xf0\xe0\xed\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_EDIT_PRICE)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 1);
        new price = strval(inputtext);
        Marketplace_EditLot(playerid, g_MP_SelectedLot[playerid], price);
        return 1;
    }
    if(dialogid == MP_DIALOG_SEARCH)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        format(g_MP_Search[playerid], 64, "%s", inputtext);
        Marketplace_SendLotsRequest(playerid, MP_ACT_SEARCH, MP_TAB_MAIN);
        Marketplace_ShowDialogLots(playerid, 0);
        return 1;
    }
    return 0;
}
