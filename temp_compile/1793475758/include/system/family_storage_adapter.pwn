#if defined _INC_FAMILY_STORAGE_ADAPTER
    #endinput
#endif
#define _INC_FAMILY_STORAGE_ADAPTER

#define FAM_DIALOG_STORAGE_MAIN             (22940)
#define FAM_DIALOG_STORAGE_SAFE             (22942)
#define FAM_DIALOG_STORAGE_SAFE_TAKE        (22943)
#define FAM_DIALOG_STORAGE_SAFE_PUT         (22944)
#define FAM_DIALOG_STORAGE_SAFE_MONEY       (22945)
#define FAM_DIALOG_STORAGE_SAFE_AMMO        (22946)
#define FAM_DIALOG_STORAGE_SAFE_WEAPON      (22947)
#define FAM_DIALOG_STORAGE_SAFE_ARMOUR      (22948)
#define FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT  (22949)

#define FAMILY_SAFE_ACTION_TAKE             (1)
#define FAMILY_SAFE_ACTION_PUT              (2)

#define FAMILY_WAREHOUSE_MAX_SLOTS          (60)
#define FAMILY_WAREHOUSE_MAX_WEIGHT_KG      (1500)
#define FAMILY_SAFE_MAX_MONEY_AMOUNT        (1000000)

#define PVAR_FAMILY_SAFE_MONEY_ACTION       "family_safe_money_action"
#define PVAR_FAMILY_SAFE_AMMO_ACTION        "family_safe_ammo_action"
#define PVAR_FAMILY_SAFE_WEAPON_INDEX       "family_safe_weapon_index"

#define PVAR_FAMILY_WAREHOUSE_GUI           "family_warehouse_gui"
#define PVAR_FAMILY_WAREHOUSE_ID            "family_warehouse_id"

enum E_FAMILY_WAREHOUSE_SLOT
{
    FWS_SQL_ID,
    FWS_ITEM_ID,
    FWS_ITEM_AMOUNT,
    FWS_ITEM_VALUE,
    FWS_MODEL_ID,
    FWS_EXTRA_1,
    FWS_EXTRA_2,
    FWS_OLD_SKIN
};

new g_family_warehouse[MAX_FAM][FAMILY_WAREHOUSE_MAX_SLOTS][E_FAMILY_WAREHOUSE_SLOT];
new g_family_warehouse_item_value[MAX_FAM][FAMILY_WAREHOUSE_MAX_SLOTS];

#define GetFamilyWarehouseData(%0,%1,%2)   g_family_warehouse[%0][%1][%2]
#define SetFamilyWarehouseData(%0,%1,%2,%3) g_family_warehouse[%0][%1][%2] = %3
#define AddFamilyWarehouseData(%0,%1,%2,%3,%4) g_family_warehouse[%0][%1][%2] %3= %4
#define IsFamilyWarehouseFreeSlot(%0,%1)   !GetFamilyWarehouseData(%0, %1, FWS_SQL_ID)

stock FamilyStorageResetState(playerid)
{
    DeletePVar(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION);
    DeletePVar(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION);
    DeletePVar(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX);
    return 1;
}

stock FamilyStorageResetWarehouseGui(playerid)
{
    DeletePVar(playerid, PVAR_FAMILY_WAREHOUSE_GUI);
    DeletePVar(playerid, PVAR_FAMILY_WAREHOUSE_ID);
    return 1;
}

stock FamilyStorageIsWarehouseGui(playerid)
{
    return GetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_GUI) == 1;
}

stock FamilyStorageGetWarehouseFamilyId(playerid)
{
    return GetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_ID);
}

stock FamilyStorageShowAccessDenied(playerid)
{
    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вам недоступна данная функция", " ");
}

stock FamilyStorageShowClosed(playerid)
{
    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Склад семьи закрыт", " ");
}

stock FamilyStorageClampLevel(level)
{
    if(level < 1) return 1;
    if(level > 7) return 7;
    return level;
}

stock FamilyStorageIsValidFamilyId(family_id)
{
    return (family_id >= 0 && family_id < MAX_FAM && GetFamily(family_id, family_database) != -1);
}

stock FamilyStorageGetRankName(playerid, dest[], size)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank = GetPlayerRangFamily(playerid);

    if(FamilyStorageIsValidFamilyId(family_id) && rank >= 1 && rank <= 5)
        format(dest, size, "%s", family_rang_name[family_id][rank - 1]);
    else
        format(dest, size, "%d ранг", rank);

    return 1;
}

stock FamilyStorageBuildChatText(playerid, action_text[], dest[], size)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_name[24];

    FamilyStorageGetRankName(playerid, rank_name, sizeof(rank_name));
    format(dest, size, "%s %s[%d] %s", rank_name, GetPlayerNameEx(playerid), playerid, action_text);
    return 1;
}

stock FamilyStorageGetWarehouseSqlId(family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return -1;

    return GetFamily(family_id, family_database);
}

stock bool:FamilyStorageSavePlateMeta(family_id, slot, plate_type, plate[], region[])
{
    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0 || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE family_storage_items SET plate_type = %d, plate_number = '%e', plate_region = '%e' WHERE family_id = %d AND slot = %d LIMIT 1",
        plate_type, plate, region, family_sql_id, slot);
    mysql_query(mysql, query, true);
    return mysql_errno() == 0;
}

stock bool:FamilyStorageGetPlateMeta(family_id, slot, &plate_type, plate[], plate_size, region[], region_size)
{
    plate_type = TYPE_RU;
    plate[0] = '\0';
    region[0] = '\0';

    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0 || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    new query[224];
    mysql_format(mysql, query, sizeof(query),
        "SELECT plate_type, plate_number, plate_region FROM family_storage_items WHERE family_id = %d AND slot = %d LIMIT 1",
        family_sql_id, slot);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno() || cache_num_rows() <= 0)
    {
        cache_delete(result);
        return false;
    }

    plate_type = cache_get_field_content_int(0, "plate_type");
    cache_get_field_content(0, "plate_number", plate, mysql, plate_size);
    cache_get_field_content(0, "plate_region", region, mysql, region_size);
    cache_delete(result);

    if(plate_type < TYPE_RU || plate_type > TYPE_KZ)
        plate_type = TYPE_RU;

    return strlen(plate) > 0;
}

stock FamilyStorageClearPlateMeta(family_id, slot)
{
    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0 || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return 0;

    new query[224];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE family_storage_items SET plate_type = 0, plate_number = '', plate_region = '' WHERE family_id = %d AND slot = %d LIMIT 1",
        family_sql_id, slot);
    mysql_query(mysql, query, false);
    return 1;
}

stock FamilyStorageGetPlatePseudoSlot(family_id, slot)
{
    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);

    if(family_sql_id <= 0 || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return -1;

    return 300000000 + (family_sql_id * 100) + slot;
}

stock FamilyStorageSetWarehouseSlotValue(family_id, slot, value)
{
    g_family_warehouse_item_value[family_id][slot] = value;
    return 1;
}

stock FamilyStorageGetWarehouseSlotValue(family_id, slot)
{
    return g_family_warehouse_item_value[family_id][slot];
}

stock FamilyStorageClearWarehouseCache(family_id)
{
    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_MODEL_ID, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_1, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_2, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_OLD_SKIN, 0);
        FamilyStorageSetWarehouseSlotValue(family_id, slot, 0);
    }
    return 1;
}

stock FamilyStorageRemoveWarehouseItem(family_id, slot)
{
    if(!FamilyStorageIsValidFamilyId(family_id) || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return 0;

    SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_MODEL_ID, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_1, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_2, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_OLD_SKIN, 0);
    FamilyStorageSetWarehouseSlotValue(family_id, slot, 0);
    return 1;
}

stock bool:FamilyStorageIsWarehouseAllowedItem(item_id)
{
    // Family warehouse mirrors the regular inventory grid. Metadata is stored
    // together with the item, so skins/SIM/accessories and ordinary items are safe.
    return (item_id > 0);
}

stock bool:FamilyStorageIsStackableItem(item_id)
{
    return TrunkTest_IsStackableItem(item_id);
}

stock FamilyStorageFindBusySlot(family_id, item_id, model_id, extra_1, extra_2, old_skin)
{
    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        if(GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID) != item_id)
            continue;

        if(GetFamilyWarehouseData(family_id, slot, FWS_MODEL_ID) != model_id)
            continue;
        if(GetFamilyWarehouseData(family_id, slot, FWS_EXTRA_1) != extra_1)
            continue;
        if(GetFamilyWarehouseData(family_id, slot, FWS_EXTRA_2) != extra_2)
            continue;
        if(GetFamilyWarehouseData(family_id, slot, FWS_OLD_SKIN) != old_skin)
            continue;

        return slot;
    }
    return -1;
}

stock FamilyStorageLoadWarehouse(playerid, family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0)
        return 0;

    FamilyStorageClearWarehouseCache(family_id);

    new query[196];
    mysql_format(mysql, query, sizeof(query), "SELECT slot, item_id, amount, value, model_id, extra_1, extra_2, old_skin FROM family_storage_items WHERE family_id = %d ORDER BY slot ASC", family_sql_id);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] load failed: player=%d family=%d sql=%d errno=%d query=%s", playerid, family_id, family_sql_id, mysql_errno(), query);
        cache_delete(result);
        return 0;
    }

    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
            continue;

        new item_id = cache_get_field_content_int(i, "item_id");
        new amount = cache_get_field_content_int(i, "amount");
        new value = cache_get_field_content_int(i, "value");
        new model_id = cache_get_field_content_int(i, "model_id");
        new extra_1 = cache_get_field_content_int(i, "extra_1");
        new extra_2 = cache_get_field_content_int(i, "extra_2");
        new old_skin = cache_get_field_content_int(i, "old_skin");

        if(!FamilyStorageIsWarehouseAllowedItem(item_id))
            continue;

        if(amount <= 0)
            amount = 1;

        SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 1);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, item_id);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, amount);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, value);
        SetFamilyWarehouseData(family_id, slot, FWS_MODEL_ID, model_id);
        SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_1, extra_1);
        SetFamilyWarehouseData(family_id, slot, FWS_EXTRA_2, extra_2);
        SetFamilyWarehouseData(family_id, slot, FWS_OLD_SKIN, old_skin);
        FamilyStorageSetWarehouseSlotValue(family_id, slot, value);
    }

    cache_delete(result);
    return 1;
}

stock bool:FamilyStorageSaveWarehouseSlot(playerid, family_id, slot)
{
    if(!FamilyStorageIsValidFamilyId(family_id) || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0)
        return false;

    new query[640];

    if(IsFamilyWarehouseFreeSlot(family_id, slot))
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM family_storage_items WHERE family_id = %d AND slot = %d", family_sql_id, slot);
        mysql_query(mysql, query, true);

        if(mysql_errno())
        {
            printf("[FAMILY_STORAGE][ERROR] delete failed: player=%d family=%d slot=%d errno=%d query=%s", playerid, family_id, slot, mysql_errno(), query);
            return false;
        }

        return true;
    }

    new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
    new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);
    new value = FamilyStorageGetWarehouseSlotValue(family_id, slot);
    new model_id = GetFamilyWarehouseData(family_id, slot, FWS_MODEL_ID);
    new extra_1 = GetFamilyWarehouseData(family_id, slot, FWS_EXTRA_1);
    new extra_2 = GetFamilyWarehouseData(family_id, slot, FWS_EXTRA_2);
    new old_skin = GetFamilyWarehouseData(family_id, slot, FWS_OLD_SKIN);

    if(amount <= 0)
        amount = 1;

    if(!Inventory11_IsPlateItem(item_id))
        FamilyStorageClearPlateMeta(family_id, slot);

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "INSERT INTO family_storage_items (family_id, slot, item_id, amount, value, model_id, extra_1, extra_2, old_skin) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d) ON DUPLICATE KEY UPDATE item_id = VALUES(item_id), amount = VALUES(amount), value = VALUES(value), model_id = VALUES(model_id), extra_1 = VALUES(extra_1), extra_2 = VALUES(extra_2), old_skin = VALUES(old_skin)",
        family_sql_id,
        slot,
        item_id,
        amount,
        value,
        model_id,
        extra_1,
        extra_2,
        old_skin
    );
    mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] upsert failed: player=%d family=%d slot=%d errno=%d query=%s", playerid, family_id, slot, mysql_errno(), query);
        return false;
    }

    return true;
}

stock FamilyStorageWhWeightX10(family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    new total_weight_x10 = 0;

    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
        new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);

        if(amount <= 0)
            amount = 1;

        new item_weight_x10 = InventoryCfg_GetItemWeightX10(item_id);
        if(item_weight_x10 <= 0)
            item_weight_x10 = 10;

        if(FamilyStorageIsStackableItem(item_id))
            total_weight_x10 += item_weight_x10 * amount;
        else
            total_weight_x10 += item_weight_x10;
    }

    return total_weight_x10;
}

stock FamilyStorageWhWeightKg(family_id)
{
    return (FamilyStorageWhWeightX10(family_id) + 9) / 10;
}

stock FamilyStorageBuildWarehouseJson(playerid, family_id, out_json[], out_size)
{
    format(out_json, out_size, "[");

    new loaded = 0;

    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
        new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);
        new value = FamilyStorageGetWarehouseSlotValue(family_id, slot);

        if(amount <= 0 || !FamilyStorageIsWarehouseAllowedItem(item_id))
            continue;

        new model_id = TrunkTest_GetDisplayModelForTrunkItem(item_id, amount, value);

        if(Inventory11_IsPlateItem(item_id))
        {
            new plate_type = PlateCountryToType(PlateItemIdToCountry(item_id));
            new plate[16], region[8], plate_text[32];

            if(FamilyStorageGetPlateMeta(family_id, slot, plate_type, plate, sizeof(plate), region, sizeof(region)))
            {
                Inv11Trade_BuildPlateText(plate_type, plate, region, plate_text, sizeof(plate_text));
                Inventory11_AppendPlateItemToJson(out_json, out_size, PlateTypeToItemId(plate_type), plate_text, slot);
                loaded++;
                continue;
            }
        }

        new item_value = amount;
        if(item_id == 134)
        {
            item_value = (value > 0) ? value : model_id;
            if(item_value <= 0) item_value = 1;
        }
        else if(item_id == 58)
        {
            item_value = (value > 0) ? value : amount;
        }

        // Same 4-field flat protocol as vehicle trunk GUI.
        Inventory11_AppendItemToJson(out_json, out_size, item_id, item_value, slot, 0);
        loaded++;
    }

    new len = strlen(out_json);
    if(len > 1 && out_json[len - 1] == ',')
        out_json[len - 1] = '\0';

    strcat(out_json, "]", out_size);
    return loaded;
}

stock bool:FamilyStorageCanUseWarehouse(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    if(!FamilyStorageIsValidFamilyId(family_id))
        return false;

    // family_status_storage: 0 = open, 1 = closed. Leader can always use it.
    if(GetFamily(family_id, family_status_storage) && GetPlayerRangFamily(playerid) < 5)
        return false;

    return true;
}

stock FamilyStorageOpenWarehouseGui(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    if(!FamilyStorageCanUseWarehouse(playerid))
    {
        if(FamilyStorageIsValidFamilyId(family_id) && GetFamily(family_id, family_status_storage))
            return FamilyStorageShowClosed(playerid);
        return FamilyStorageShowAccessDenied(playerid);
    }

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось открыть склад семьи", " ");

    new Node:JSONObject = JSON_Object();
    new it_json[8192];
    new ic_json[4096];

    TrunkTest_BuildInventoryJson(playerid, it_json, sizeof(it_json));
    FamilyStorageBuildWarehouseJson(playerid, family_id, ic_json, sizeof(ic_json));

    new Node:itArray = JSON_Array();
    JSON_Parse(it_json, itArray);
    JSON_SetArray(JSONObject, "it", itArray);

    new Node:icArray = JSON_Array();
    JSON_Parse(ic_json, icArray);
    JSON_SetArray(JSONObject, "ic", icArray);

    JSON_SetInt(JSONObject, "tb", 2);
    JSON_SetInt(JSONObject, "w", Inventory11_GetCurrentWeightKg(playerid));
    JSON_SetInt(JSONObject, "mw", Inventory11_GetMaxWeightKg(playerid));
    JSON_SetInt(JSONObject, "bw", FamilyStorageWhWeightKg(family_id));
    JSON_SetInt(JSONObject, "cw", FAMILY_WAREHOUSE_MAX_WEIGHT_KG);
    JSON_SetInt(JSONObject, "sl", Inventory11_GetMaxSlots(playerid));
    JSON_SetInt(JSONObject, "v", Inventory11_GetVipForGui(playerid));
    JSON_SetInt(JSONObject, "sb", FAMILY_WAREHOUSE_MAX_SLOTS);
    JSON_SetInt(JSONObject, "nm", GetPlayerPhone(playerid));

    Inventory11_SetAiArrayOnJson(playerid, JSONObject);

    SetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_GUI, 1);
    SetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_ID, family_id);

    DeletePVar(playerid, PVAR_TRUNKTEST_VEHICLE);
    ShowPlayerGUI(playerid, GUICarsTrunkOrCloset, JSONObject);
    JSON_Cleanup(JSONObject);
    return 1;
}

stock bool:FamilyStorageMoveInventoryToWarehouse(playerid, family_id, req_item_id, old_slot, new_slot, req_value)
{
    if(new_slot < 0 || new_slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return false;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0)
        return false;

    new query[320];
    mysql_format(mysql, query, sizeof(query), "SELECT item_id, model_id, amount, extra_1, extra_2, old_skin FROM inventory WHERE account_id = %d AND slot = %d LIMIT 1", account_id, old_slot);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] inv->storage select failed: player=%d slot=%d errno=%d query=%s", playerid, old_slot, mysql_errno(), query);
        cache_delete(result);
        return false;
    }

    if(cache_num_rows() <= 0)
    {
        cache_delete(result);
        return false;
    }

    new item_id = cache_get_field_content_int(0, "item_id");
    new model_id = cache_get_field_content_int(0, "model_id");
    new amount = cache_get_field_content_int(0, "amount");
    new extra_1 = cache_get_field_content_int(0, "extra_1");
    new extra_2 = cache_get_field_content_int(0, "extra_2");
    new old_skin = cache_get_field_content_int(0, "old_skin");
    cache_delete(result);

    if(req_item_id > 0 && req_item_id != item_id)
        printf("[FAMILY_STORAGE][WARN] inv->storage item mismatch: player=%d req=%d db=%d slot=%d", playerid, req_item_id, item_id, old_slot);

    if(!FamilyStorageIsWarehouseAllowedItem(item_id))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Этот предмет нельзя положить на склад семьи", " ");
        return false;
    }

    if(amount <= 0)
        amount = 1;

    new bool:is_stackable = FamilyStorageIsStackableItem(item_id);
    new move_amount = req_value;

    if(!is_stackable)
    {
        move_amount = 1;
    }
    else
    {
        if(move_amount <= 0) move_amount = 1;
        if(move_amount > amount) move_amount = amount;
        if(move_amount <= 0) return false;
    }

    new item_weight_x10 = InventoryCfg_GetItemWeightX10(item_id);
    if(item_weight_x10 <= 0) item_weight_x10 = 10;

    new add_weight_x10 = item_weight_x10 * (is_stackable ? move_amount : 1);
    if(FamilyStorageWhWeightX10(family_id) + add_weight_x10 > (FAMILY_WAREHOUSE_MAX_WEIGHT_KG * 10))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно места на складе семьи", " ");
        return false;
    }

    new item_value = TrunkTest_GetItemValueFromInventoryData(item_id, model_id, amount, extra_1, old_skin);
    new target_slot = new_slot;

    new storage_plate_type = TYPE_RU;
    new storage_plate[16], storage_region[8];
    storage_plate[0] = '\0';
    storage_region[0] = '\0';
    new bool:has_storage_plate = false;

    if(Inventory11_IsPlateItem(item_id))
        has_storage_plate = Inventory11_GetPlateData(playerid, old_slot, storage_plate_type, storage_plate, sizeof(storage_plate), storage_region, sizeof(storage_region));

    if(is_stackable)
    {
        new busy_slot = FamilyStorageFindBusySlot(family_id, item_id, model_id, extra_1, extra_2, old_skin);

        if(busy_slot != -1 && busy_slot != new_slot)
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Выберите другой слот склада", " ");
            return false;
        }

        if(busy_slot == -1 && !IsFamilyWarehouseFreeSlot(family_id, new_slot))
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Слот склада уже занят", " ");
            return false;
        }

        if(busy_slot != -1)
        {
            target_slot = busy_slot;
            AddFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, +, move_amount);

            if(FamilyStorageGetWarehouseSlotValue(family_id, target_slot) <= 0 && item_value > 0)
            {
                FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
                SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
            }
        }
        else
        {
            SetFamilyWarehouseData(family_id, target_slot, FWS_SQL_ID, 1);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_ID, item_id);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, move_amount);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
            SetFamilyWarehouseData(family_id, target_slot, FWS_MODEL_ID, model_id);
            SetFamilyWarehouseData(family_id, target_slot, FWS_EXTRA_1, extra_1);
            SetFamilyWarehouseData(family_id, target_slot, FWS_EXTRA_2, extra_2);
            SetFamilyWarehouseData(family_id, target_slot, FWS_OLD_SKIN, old_skin);
            FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
        }
    }
    else
    {
        if(!IsFamilyWarehouseFreeSlot(family_id, target_slot))
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Слот склада уже занят", " ");
            return false;
        }

        SetFamilyWarehouseData(family_id, target_slot, FWS_SQL_ID, 1);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_ID, item_id);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, 1);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
        SetFamilyWarehouseData(family_id, target_slot, FWS_MODEL_ID, model_id);
        SetFamilyWarehouseData(family_id, target_slot, FWS_EXTRA_1, extra_1);
        SetFamilyWarehouseData(family_id, target_slot, FWS_EXTRA_2, extra_2);
        SetFamilyWarehouseData(family_id, target_slot, FWS_OLD_SKIN, old_skin);
        FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
    }

    if(!FamilyStorageSaveWarehouseSlot(playerid, family_id, target_slot))
        return false;

    if(Inventory11_IsPlateItem(item_id) && has_storage_plate)
    {
        if(!FamilyStorageSavePlateMeta(family_id, target_slot, storage_plate_type, storage_plate, storage_region))
        {
            printf("[FAMILY_STORAGE][ERROR] inv->storage save plate failed: player=%d family=%d slot=%d", playerid, family_id, target_slot);
            return false;
        }
    }

    if(is_stackable && amount > move_amount)
    {
        new left_amount = amount - move_amount;
        if(left_amount < 1) left_amount = 1;

        mysql_format(mysql, query, sizeof(query), "UPDATE inventory SET amount = %d, model_id = %d WHERE account_id = %d AND slot = %d LIMIT 1", left_amount, left_amount, account_id, old_slot);
        mysql_query(mysql, query, true);

        if(mysql_errno())
        {
            printf("[FAMILY_STORAGE][ERROR] inv->storage update inventory amount failed: player=%d slot=%d errno=%d query=%s", playerid, old_slot, mysql_errno(), query);
            return false;
        }
    }
    else if(!Inventory11_DeleteSlotFromDatabase(playerid, old_slot))
    {
        printf("[FAMILY_STORAGE][ERROR] inv->storage delete inventory slot failed: player=%d slot=%d", playerid, old_slot);
        return false;
    }

    return true;
}

stock bool:FamilyStorageMoveWarehouseToInventory(playerid, family_id, old_slot, new_slot, req_item_id, req_value)
{
    if(old_slot < 0 || old_slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    if(new_slot < 1 || new_slot > Inventory11_GetMaxSlots(playerid))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        return false;
    }

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return false;

    if(IsFamilyWarehouseFreeSlot(family_id, old_slot))
        return false;

    if(TrunkTest_IsInventorySlotBusy(playerid, new_slot))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Выберите другой слот в инвентаре", " ");
        return false;
    }

    new item_id = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_ID);
    if(!FamilyStorageIsWarehouseAllowedItem(item_id))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Этот предмет нельзя взять со склада семьи", " ");
        return false;
    }

    if(req_item_id > 0 && req_item_id != item_id)
        printf("[FAMILY_STORAGE][WARN] storage->inv item mismatch: player=%d req=%d db=%d slot=%d", playerid, req_item_id, item_id, old_slot);

    new amount = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_AMOUNT);
    if(amount <= 0)
        return false;

    new bool:is_stackable = FamilyStorageIsStackableItem(item_id);
    new move_amount = req_value;

    if(!is_stackable)
    {
        move_amount = 1;
    }
    else
    {
        if(move_amount <= 0) move_amount = 1;
        if(move_amount > amount) move_amount = amount;
        if(move_amount <= 0) return false;
    }

    new item_value = FamilyStorageGetWarehouseSlotValue(family_id, old_slot);
    if(item_value <= 0)
        item_value = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_VALUE);

    new storage_plate_type = TYPE_RU;
    new storage_plate[16], storage_region[8];
    storage_plate[0] = '\0';
    storage_region[0] = '\0';
    new bool:has_storage_plate = false;

    if(Inventory11_IsPlateItem(item_id))
        has_storage_plate = FamilyStorageGetPlateMeta(family_id, old_slot, storage_plate_type, storage_plate, sizeof(storage_plate), storage_region, sizeof(storage_region));

    new model_id = GetFamilyWarehouseData(family_id, old_slot, FWS_MODEL_ID);
    new extra_1 = GetFamilyWarehouseData(family_id, old_slot, FWS_EXTRA_1);
    new extra_2 = GetFamilyWarehouseData(family_id, old_slot, FWS_EXTRA_2);
    new old_skin = GetFamilyWarehouseData(family_id, old_slot, FWS_OLD_SKIN);

    // Backward compatibility with rows created by the older adapter.
    if(Inventory11_IsAccessoryItem(item_id))
    {
        if(extra_1 <= 0) extra_1 = (item_value > 0) ? item_value : Inv11_GetAccModelByItem(item_id);
        if(extra_1 <= 0) extra_1 = item_id;
        if(model_id <= 0) model_id = 1;
        move_amount = 1;
    }
    else if(item_id == 58)
    {
        if(model_id <= 0) model_id = (item_value > 0) ? item_value : 1;
        if(extra_1 <= 0) extra_1 = model_id;
        move_amount = 1;
    }
    else if(item_id == 134)
    {
        if(old_skin <= 0) old_skin = (item_value > 0) ? item_value : model_id;
        if(model_id <= 0) model_id = old_skin;
        move_amount = 1;
    }
    else if(Inventory11_IsPlateItem(item_id))
    {
        if(model_id <= 0) model_id = PlateItemIdToModel(item_id);
        move_amount = 1;
    }
    else
    {
        if(model_id <= 0) model_id = (item_value > 0) ? item_value : item_id;
    }

    if(!Inventory11_CanAddItemWeight(playerid, item_id, move_amount))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        return false;
    }

    if(!TrunkTest_InsertInventoryItemAtSlot(playerid, new_slot, item_id, model_id, move_amount, extra_1, extra_2, old_skin))
        return false;

    if(Inventory11_IsPlateItem(item_id) && has_storage_plate)
    {
        if(!Inventory11_SavePlateData(playerid, new_slot, storage_plate_type, storage_plate, storage_region))
        {
            printf("[FAMILY_STORAGE][ERROR] storage->inv save plate failed: player=%d family=%d slot=%d", playerid, family_id, old_slot);
            return false;
        }
    }

    new left_amount = amount - move_amount;
    if(left_amount <= 0)
    {
        FamilyStorageRemoveWarehouseItem(family_id, old_slot);

        // Plate metadata is stored in the same family_storage_items row and is
        // removed together with the row by FamilyStorageSaveWarehouseSlot().
    }
    else
    {
        SetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_AMOUNT, left_amount);
    }

    if(!FamilyStorageSaveWarehouseSlot(playerid, family_id, old_slot))
        return false;

    return true;
}

stock FamilyStorageHandleWarehouseSlotToInventory(playerid, type, ga, os, ns, family_id, Node:resp)
{
    new slot_item = ga;
    new active_slot = os;
    new target_slot = ns;
    new bool:ok = false;

    if(slot_item == 134 || slot_item == 122)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нельзя снять одежду", " ");
    }
    else if(!Inventory11_IsAccessoryItem(slot_item))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Неверный аксессуар", " ");
    }
    else
    {
        if(active_slot == 0)
            active_slot = 1;

        if(active_slot < 1 || active_slot > 2)
            active_slot = 1;

        if(target_slot < 1 || target_slot > Inventory11_GetMaxSlots(playerid))
            target_slot = TrunkTest_GetFreeInventorySlot(playerid);

        if(target_slot == -1)
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        }
        else
        {
            new item_weight_x10 = InventoryCfg_GetItemWeightX10(slot_item);
            if(item_weight_x10 <= 0) item_weight_x10 = 10;

            if(Inventory11_GetCurrentWeightX10(playerid) + item_weight_x10 > (Inventory11_GetMaxWeightKg(playerid) * 10))
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
            }
            else
            {
                new moved_model = 0;
                new used_slot = active_slot;

                if(!Inventory11_MoveActiveAccessoryToInventorySlot(playerid, slot_item, used_slot, target_slot, moved_model))
                {
                    used_slot = (used_slot == 1) ? 2 : 1;

                    if(!Inventory11_MoveActiveAccessoryToInventorySlot(playerid, slot_item, used_slot, target_slot, moved_model))
                    {
                        ShowNotificationNew(playerid, 2, 6, 0, 0, "Аксессуар не надет", " ");
                    }
                    else
                    {
                        ok = true;
                    }
                }
                else
                {
                    ok = true;
                }
            }
        }
    }

    JSON_SetInt(resp, "t", type);
    JSON_SetInt(resp, "s", ok ? 1 : 0);

    if(ok)
    {
        JSON_SetInt(resp, "w", Inventory11_GetCurrentWeightKg(playerid));
        JSON_SetInt(resp, "bw", FamilyStorageWhWeightKg(family_id));
    }

    OnPacketIncoming(playerid, 34, resp);
    return ok;
}

stock FamilyStorageHandleInventoryPacket(playerid, Node:json)
{
    if(!FamilyStorageIsWarehouseGui(playerid))
        return 0;

    new family_id = FamilyStorageGetWarehouseFamilyId(playerid);
    if(!FamilyStorageIsValidFamilyId(family_id))
    {
        FamilyStorageResetWarehouseGui(playerid);
        return 1;
    }

    if(!FamilyStorageCanUseWarehouse(playerid))
    {
        HidePlayerGUI(playerid, GUICarsTrunkOrCloset);
        FamilyStorageResetWarehouseGui(playerid);
        if(GetFamily(family_id, family_status_storage))
            FamilyStorageShowClosed(playerid);
        else
            FamilyStorageShowAccessDenied(playerid);
        return 1;
    }

    new type = -1;
    JSON_GetInt(json, "t", type);

    if(type == 8)
    {
        // Client can send t=8 during internal GUI refresh; keep family warehouse context.
        return 1;
    }

    if(type == 3 || type == 4 || type == 5 || type == 6 || type == 7)
        return 1;

    new ga = 0, os = -1, ns = -1, value = 0;
    JSON_GetInt(json, "ga", ga);
    JSON_GetInt(json, "os", os);
    JSON_GetInt(json, "ns", ns);
    JSON_GetInt(json, "v", value);

    if(ns == -1)
        JSON_GetInt(json, "s", ns);

    new bool:ok = false;
    new Node:resp = JSON_Object();

    switch(type)
    {
        case 0:
        {
            new db_old_slot = Inventory11_ClientSlotToDbSlot(os);
            ok = FamilyStorageMoveInventoryToWarehouse(playerid, family_id, ga, db_old_slot, ns, value);
        }
        case 1:
        {
            new db_new_slot = Inventory11_ClientSlotToDbSlot(ns);
            ok = FamilyStorageMoveWarehouseToInventory(playerid, family_id, os, db_new_slot, ga, value);
        }
        case 2, 9:
        {
            new active_slot = os;
            if(active_slot == 3 || active_slot == 4) active_slot -= 2;
            new db_new_slot = Inventory11_ClientSlotToDbSlot(ns);
            ok = FamilyStorageHandleWarehouseSlotToInventory(playerid, type, ga, active_slot, db_new_slot, family_id, resp);
            JSON_Cleanup(resp);

            if(ok)
                FamilyStorageOpenWarehouseGui(playerid);

            return 1;
        }
        default:
        {
            JSON_SetInt(resp, "t", type);
            JSON_SetInt(resp, "s", 0);
            OnPacketIncoming(playerid, 34, resp);
            JSON_Cleanup(resp);
            return 1;
        }
    }

    JSON_SetInt(resp, "t", type);
    JSON_SetInt(resp, "s", ok ? 1 : 0);

    if(ok)
    {
        JSON_SetInt(resp, "w", Inventory11_GetCurrentWeightKg(playerid));
        JSON_SetInt(resp, "bw", FamilyStorageWhWeightKg(family_id));
    }

    OnPacketIncoming(playerid, 34, resp);
    JSON_Cleanup(resp);

    if(ok)
        FamilyStorageOpenWarehouseGui(playerid);

    return 1;
}

stock FamilyStorageShowSettingsDialog(playerid)
{
    DeletePVar(playerid, "select_get_dostup");

    ShowPlayerDialog
    (
        playerid, 2230, DIALOG_STYLE_LIST,
        "{E0584B}Настройки склада",
        "1. Выдать доступ\n"\
        "2. Забрать доступ\n"\
        "3. Просмотр доступов",
        "Далее", "Назад"
    );
    return 1;
}

stock FamilyStorageShowAccessInfo(playerid)
{
    new text[512];

    if(GetPlayerRangFamily(playerid) == 5)
    {
        format(text, sizeof(text), "{FFFFFF}Как лидеру семьи Вам доступны все действия со складом и сейфом без ограничений.");
    }
    else
    {
        format
        (
            text, sizeof(text),
            "{FFFFFF}Изменение доступов: %s\n"\
            "{FFFFFF}Деньги: %d\n"\
            "{FFFFFF}Патроны: %d\n"\
            "{FFFFFF}Бронежилеты: %d\n"\
            "{FFFFFF}Материалы: %d\n"\
            "{FFFFFF}Аптечки: %d\n"\
            "{FFFFFF}Маски: %d",
            GetPlayerFamily(playerid, ACCESS_GIVE) ? ("{66CC66}Доступно") : ("{FF6666}Недоступно"),
            GetPlayerFamily(playerid, ACCESS_MONEY),
            GetPlayerFamily(playerid, ACCESS_PATRON),
            GetPlayerFamily(playerid, ACCESS_ARMOUR),
            GetPlayerFamily(playerid, ACCESS_MATERIAL),
            GetPlayerFamily(playerid, ACCESS_HEATH_KIT),
            GetPlayerFamily(playerid, ACCESS_MASK)
        );
    }

    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{E0584B}Мои доступы на складе", text, "Закрыть", "");
    return 1;
}

stock FamilyStorageShowMainDialog(playerid)
{
    new text[256];

    FamilyStorageResetState(playerid);

    if(GetPlayerRangFamily(playerid) == 5)
    {
        format
        (
            text, sizeof(text),
            "1. Склад\n"\
            "2. Сейф\n"\
            "3. Мои доступы на складе\n"\
            "4. Настройки склада"
        );
    }
    else
    {
        format
        (
            text, sizeof(text),
            "1. Склад\n"\
            "2. Сейф\n"\
            "3. Мои доступы на складе"
        );
    }

    ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_MAIN, DIALOG_STYLE_LIST, "{E0584B}Хранилище семьи", text, "Далее", "Выйти");
    return 1;
}

stock FamilyStorageShowSafeDialog(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new text[256];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    format
    (
        text, sizeof(text),
        "%s\n"\
        "1. Взять\n"\
        "2. Положить\n"\
        "3. Доступы",
        GetFamily(family_id, family_status_storage) ? ("{33CC66}| {FFFFFF}Сейф {33CC66}Открыть") : ("{E0584B}| {FFFFFF}Сейф {E0584B}Закрыть")
    );

    ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE, DIALOG_STYLE_LIST, "{E0584B}Сейф", text, "Далее", "Выйти");
    return 1;
}

stock FamilyStorageShowSafeTakeDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_TAKE, DIALOG_STYLE_LIST,
        "{E0584B}Взять предмет из сейфа",
        "{FFFF00}|{FFFF00} {FFFFFF}Деньги\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Патроны\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Бронежилет",
        "Далее", "Отмена"
    );
    return 1;
}

stock FamilyStorageShowSafePutDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_PUT, DIALOG_STYLE_LIST,
        "{E0584B}Положить предмет в сейф",
        "{FFFF00}|{FFFF00} {FFFFFF}Деньги\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Патроны\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Бронежилет",
        "Далее", "Отмена"
    );
    return 1;
}

stock FamilyStorageShowAmmoActionDialog(playerid, action_type)
{
    SetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION, action_type);

    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_AMMO, DIALOG_STYLE_LIST,
        action_type == FAMILY_SAFE_ACTION_TAKE ? "{E0584B}Взять оружие" : "{E0584B}Положить оружие",
        action_type == FAMILY_SAFE_ACTION_TAKE ?
        ("{FFFFFF}1. Информация\n{FFFFFF}2. Взять") :
        ("{FFFFFF}1. Информация\n{FFFFFF}2. Положить"),
        "Далее", "Выйти"
    );
    return 1;
}

stock FamilyStorageShowAmmoInfo(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new text[256];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    format
    (
        text, sizeof(text),
        "{FFFFFF}Доступные патроны для оружия:\n"\
        "- Патроны для пистолета\n"\
        "- Патроны для дробовика\n"\
        "- Патроны для автомата\n"\
        "- Патроны для винтовки\n\n"\
        "Доступно: %d шт.",
        GetFamily(family_id, family_patron)
    );

    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{E0584B}Информация о патронах", text, "Закрыть", "");
    return 1;
}

stock FamilyStorageShowWeaponDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_WEAPON, DIALOG_STYLE_LIST,
        "{E0584B}Выберите оружие",
        "1. Desert Eagle\n"\
        "2. AK-47\n"\
        "3. MP5\n"\
        "4. Shotgun\n"\
        "5. Country Rifle\n"\
        "6. Sniper Rifle\n"\
        "7. M4",
        "Выбрать", "Отмена"
    );
    return 1;
}

stock FamilyStorageHasTakeAccess(playerid, access_type, amount)
{
    if(GetPlayerRangFamily(playerid) == 5)
        return 1;

    switch(access_type)
    {
        case ACCESS_MONEY:  return GetPlayerFamily(playerid, ACCESS_MONEY) >= amount;
        case ACCESS_PATRON: return GetPlayerFamily(playerid, ACCESS_PATRON) >= amount;
        case ACCESS_ARMOUR: return GetPlayerFamily(playerid, ACCESS_ARMOUR) >= amount;
    }

    return 0;
}

stock FamilyStorageConsumeAccess(playerid, access_type, amount)
{
    if(GetPlayerRangFamily(playerid) == 5)
        return 1;

    AddPlayerFamily(playerid, access_type, -, amount);
    UpdateAccessPlayerFamily(playerid);
    return 1;
}

stock FamilyStorageHandleTakeMoney(playerid, amount)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || amount <= 0)
        return 0;

    if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно взять от 1 до 1000000 рублей.", " ");

    if(GetFamily(family_id, family_money) < amount)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "В сейфе недостаточно денег", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_MONEY, amount))
        return FamilyStorageShowAccessDenied(playerid);

    FamilyStorageConsumeAccess(playerid, ACCESS_MONEY, amount);
    AddFamily(family_id, family_money, -, amount);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "money", GetFamily(family_id, family_money));
    GivePlayerMoneyEx(playerid, amount, "Сейф семьи", true, true);

    format(action_text, sizeof(action_text), "взял %d рублей.", amount);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_money, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы получили %d рублей", amount);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandlePutMoney(playerid, amount)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];
    new limit, limit_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || amount <= 0)
        return 0;

    if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно положить от 1 до 1000000 рублей.", " ");

    if(GetPlayerMoneyEx(playerid) < amount)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас недостаточно денег", " ");

    limit = count_money_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_storage)) - 1];
    if((GetFamily(family_id, family_money) + amount) > limit)
    {
        format(limit_text, sizeof(limit_text), "Сейф переполнен, можно хранить %d рублей", limit);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, limit_text, " ");
    }

    AddFamily(family_id, family_money, +, amount);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "money", GetFamily(family_id, family_money));
    GivePlayerMoneyEx(playerid, -amount, "Пополнение сейфа семьи", true, true);

    format(action_text, sizeof(action_text), "положил %d рублей.", amount);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_money, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы положили %d рублей", amount);
    ShowNotificationNew(playerid, 2, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandleTakeArmour(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    if(GetFamily(family_id, family_armour) < 1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "В сейфе нет бронежилетов", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_ARMOUR, 1))
        return FamilyStorageShowAccessDenied(playerid);

    FamilyStorageConsumeAccess(playerid, ACCESS_ARMOUR, 1);
    AddFamily(family_id, family_armour, -, 1);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "armour", GetFamily(family_id, family_armour));
    SetPlayerArmour(playerid, 100.0);

    FamilyStorageBuildChatText(playerid, "взял бронежилет.", chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_armour, playerid, -1, chat_text);
    ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы получили бронежилет", " ");
    return 1;
}

stock FamilyStorageHandlePutArmour(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200];
    new limit;
    new Float:armour;

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    GetPlayerArmour(playerid, armour);
    if(armour < 20.0)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет бронежилета", " ");

    limit = count_armour_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_storage)) - 1];
    if((GetFamily(family_id, family_armour) + 1) > limit)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Превышен лимит сейфа", " ");

    AddFamily(family_id, family_armour, +, 1);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "armour", GetFamily(family_id, family_armour));
    SetPlayerArmour(playerid, 0.0);

    FamilyStorageBuildChatText(playerid, "положил бронежилет.", chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_armour, playerid, -1, chat_text);
    ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы положили бронежилет", " ");
    return 1;
}

stock FamilyStorageHandleTakeAmmo(playerid, weapon_index, ammo_count)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || weapon_index < 0 || weapon_index >= sizeof(count_weapon_level) || ammo_count <= 0)
        return 0;

    if(GetFamily(family_id, family_patron) < ammo_count)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "В сейфе недостаточно патронов", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_PATRON, ammo_count))
        return FamilyStorageShowAccessDenied(playerid);

    FamilyStorageConsumeAccess(playerid, ACCESS_PATRON, ammo_count);
    AddFamily(family_id, family_patron, -, ammo_count);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "patron", GetFamily(family_id, family_patron));
    GivePlayerWeapon(playerid, count_weapon_level[weapon_index], ammo_count);

    format(action_text, sizeof(action_text), "взял %d патронов для %s.", ammo_count, name_weapon_family[weapon_index]);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_patron, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы получили %d патронов", ammo_count);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandlePutAmmo(playerid, ammo_count)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];
    new weapon = GetPlayerWeapon(playerid);
    new ammo = GetPlayerAmmo(playerid);
    new limit;
    new slot_weapon_native = 0, slot_ammo_native = 0;
    new slot_weapon_ac = 0, slot_ammo_ac = 0;
    new slot_ammo_found = -1;

    if(!FamilyStorageIsValidFamilyId(family_id) || ammo_count <= 0)
        return 0;

    switch(weapon)
    {
        case 24, 25, 29, 30, 31, 33, 34:
        {
        }
        default:
        {
            printf("[FAMILY_STORAGE][PUT_AMMO] player=%d invalid current weapon=%d current_ammo=%d request=%d", playerid, weapon, ammo, ammo_count);
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "Возьмите оружие в руки", " ");
        }
    }

    printf("[FAMILY_STORAGE][PUT_AMMO] player=%d current_weapon=%d current_ammo=%d request=%d", playerid, weapon, ammo, ammo_count);

    for(new i = 0; i < 12; i++)
    {
        GetPlayerWeaponData(playerid, i, slot_weapon_native, slot_ammo_native);
        GetPlayerWeaponDataAC(playerid, i, slot_weapon_ac, slot_ammo_ac);
        printf("[FAMILY_STORAGE][PUT_AMMO] player=%d slot=%d native_weapon=%d native_ammo=%d ac_weapon=%d ac_ammo=%d current_weapon=%d current_ammo=%d request=%d", playerid, i, slot_weapon_native, slot_ammo_native, slot_weapon_ac, slot_ammo_ac, weapon, ammo, ammo_count);

        if(slot_weapon_native == weapon && slot_ammo_native > slot_ammo_found)
            slot_ammo_found = slot_ammo_native;

        if(slot_weapon_ac == weapon && slot_ammo_ac > slot_ammo_found)
            slot_ammo_found = slot_ammo_ac;
    }

    if(slot_ammo_found > ammo)
        ammo = slot_ammo_found;

    printf("[FAMILY_STORAGE][PUT_AMMO] player=%d final_weapon=%d final_ammo=%d request=%d family=%d", playerid, weapon, ammo, ammo_count, family_id);

    if(ammo < ammo_count)
    {
        printf("[FAMILY_STORAGE][PUT_AMMO] player=%d insufficient ammo: final_ammo=%d request=%d", playerid, ammo, ammo_count);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас недостаточно патронов", " ");
    }

    limit = count_patron_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_weapon)) - 1];
    if((GetFamily(family_id, family_patron) + ammo_count) > limit)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Превышен лимит сейфа", " ");

    AddFamily(family_id, family_patron, +, ammo_count);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "patron", GetFamily(family_id, family_patron));
    SetPlayerAmmo(playerid, weapon, ammo - ammo_count);

    format(action_text, sizeof(action_text), "положил %d патронов.", ammo_count);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_patron, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы положили %d патронов", ammo_count);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}
stock FamilyStorageHandleGuiAction(playerid, Node:request)
{
    new selected = -1;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
    {
        HidePlayerGUI(playerid, 45);
        return FamilyStorageShowMainDialog(playerid);
    }

    JSON_GetInt(request, "r", selected);

    if(selected == 0)
    {
        HidePlayerGUI(playerid, 45);
        return FamilyStorageShowSafeDialog(playerid);
    }

    if(selected == 1)
    {
        if(GetPlayerRangFamily(playerid) != 5)
            return FamilyStorageShowAccessDenied(playerid);

        HidePlayerGUI(playerid, 45);
        return FamilyStorageOpenWarehouseGui(playerid);
    }

    HidePlayerGUI(playerid, 45);
    return FamilyStorageShowMainDialog(playerid);
}

stock FamilyStorage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new amount = 0;
    new chat_text[200];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    switch(dialogid)
    {
        case FAM_DIALOG_STORAGE_MAIN:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    return FamilyStorageOpenWarehouseGui(playerid);
                }
                case 1: return FamilyStorageShowSafeDialog(playerid);
                case 2: return FamilyStorageShowAccessInfo(playerid);
                case 3:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    return FamilyStorageShowSettingsDialog(playerid);
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    SetFamily(family_id, family_status_storage, GetFamily(family_id, family_status_storage) ? 0 : 1);
                    FamilyStorageBuildChatText(playerid, GetFamily(family_id, family_status_storage) ? "открыл сейф." : "закрыл сейф.", chat_text, sizeof(chat_text));
                    SendFamilyMessage(family_id, chat_text);
                    return 1;
                }
                case 1:
                {
                    if(!GetFamily(family_id, family_status_storage) && GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowClosed(playerid);

                    return FamilyStorageShowSafeTakeDialog(playerid);
                }
                case 2:
                {
                    if(!GetFamily(family_id, family_status_storage) && GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowClosed(playerid);

                    return FamilyStorageShowSafePutDialog(playerid);
                }
                case 3:
                {
                    if(GetPlayerRangFamily(playerid) == 5)
                        return FamilyStorageShowSettingsDialog(playerid);

                    return FamilyStorageShowAccessInfo(playerid);
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_TAKE:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            switch(listitem)
            {
                case 0:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_TAKE);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_MONEY, DIALOG_STYLE_INPUT, "{E0584B}Взять деньги", "{FFFFFF}Введите кол-во денег:", "Далее", "Отмена");
                }
                case 1: return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_TAKE);
                case 2:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_TAKE);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_ARMOUR, DIALOG_STYLE_MSGBOX, "{E0584B}Взять бронежилет", "{FFFFFF}Вы хотите взять бронежилет из сейфа?", "Далее", "Отмена");
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_PUT:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            switch(listitem)
            {
                case 0:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_PUT);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_MONEY, DIALOG_STYLE_INPUT, "{E0584B}Положить деньги", "{FFFFFF}Введите кол-во денег:", "Далее", "Отмена");
                }
                case 1: return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_PUT);
                case 2:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_PUT);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_ARMOUR, DIALOG_STYLE_MSGBOX, "{E0584B}Положить бронежилет", "{FFFFFF}Вы хотите положить бронежилет в сейф?", "Далее", "Отмена");
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_MONEY:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            amount = strval(inputtext);
            if(amount <= 0)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество", " ");

            if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
            {
                if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно положить от 1 до 1000000 рублей.", " ");

                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно взять от 1 до 1000000 рублей.", " ");
            }

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutMoney(playerid, amount);

            return FamilyStorageHandleTakeMoney(playerid, amount);
        }
        case FAM_DIALOG_STORAGE_SAFE_AMMO:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            if(listitem == 0)
                return FamilyStorageShowAmmoInfo(playerid);

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT, DIALOG_STYLE_INPUT, "{E0584B}Введите патроны", "{FFFFFF}Введите кол-во патронов, которое хотите положить:", "Далее", "Назад");

            return FamilyStorageShowWeaponDialog(playerid);
        }
        case FAM_DIALOG_STORAGE_SAFE_WEAPON:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            SetPVarInt(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX, listitem);
            format(chat_text, sizeof(chat_text), "{FFFFFF}Введите нужное кол-во патронов, доступно %d", GetFamily(family_id, family_patron));
            return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT, DIALOG_STYLE_INPUT, "{E0584B}Введите патроны", chat_text, "Далее", "Назад");
        }
        case FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT:
        {
            if(!response)
            {
                if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                    return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_PUT);

                return FamilyStorageShowWeaponDialog(playerid);
            }

            amount = strval(inputtext);
            if(amount <= 0)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество", " ");

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutAmmo(playerid, amount);

            return FamilyStorageHandleTakeAmmo(playerid, GetPVarInt(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX), amount);
        }
        case FAM_DIALOG_STORAGE_SAFE_ARMOUR:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutArmour(playerid);

            return FamilyStorageHandleTakeArmour(playerid);
        }
    }

    return 0;
}
