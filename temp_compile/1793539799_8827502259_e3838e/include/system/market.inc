#if defined _vigsa_market_module_included
    #endinput
#endif
#define _vigsa_market_module_included

// Marketplace adapter for this Black Russia build (Inventory11).
#define MAX_INVENTORY_SLOTS (INVENTORY11_MAX_SLOTS + 1)
#define MAX_ACTIVE_SLOTS (0)
#define MARKET_SOURCE_ACTIVE_BASE (1000)
#define MARKET_SOURCE_ACCESSORY_BASE (2000)
#define MARKET_SOURCE_ACCESSORY_SLOTS (10)

stock Market_ReadSlot(playerid, slot, &item_id, &model_id, &amount, &extra_1, &extra_2, &old_skin, &sim_value, &oldsim_value)
{
    item_id = 0;
    model_id = 0;
    amount = 0;
    extra_1 = 0;
    extra_2 = 0;
    old_skin = 0;
    sim_value = 0;
    oldsim_value = 0;

    if(slot < 1 || slot > INVENTORY11_MAX_SLOTS) return 0;
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "SELECT item_id,model_id,amount,extra_1,extra_2,old_skin,sim,oldsim FROM inventory WHERE account_id=%d AND slot=%d LIMIT 1",
        account_id, slot);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() || cache_num_rows() <= 0)
    {
        cache_delete(result);
        return 0;
    }

    item_id = cache_get_field_content_int(0, "item_id");
    model_id = cache_get_field_content_int(0, "model_id");
    amount = cache_get_field_content_int(0, "amount");
    extra_1 = cache_get_field_content_int(0, "extra_1");
    extra_2 = cache_get_field_content_int(0, "extra_2");
    old_skin = cache_get_field_content_int(0, "old_skin");
    sim_value = cache_get_field_content_int(0, "sim");
    oldsim_value = cache_get_field_content_int(0, "oldsim");
    cache_delete(result);

    if(amount <= 0) amount = 1;
    return item_id > 0;
}

stock Market_GetAccessoryCanonicalItemByStoredId(item_id)
{
    return Inventory11_IsAccessoryItem(item_id) ? item_id : -1;
}

stock Market_GetAccessoryModelByCanonicalItem(item_id)
{
    return Inv11_GetAccModelByItem(item_id);
}

stock Market_GetAccessoryModelByStoredId(item_id)
{
    return Inv11_GetAccModelByItem(item_id);
}

stock Market_IsAccessoryInventoryItem(item_id)
{
    return Inventory11_IsAccessoryItem(item_id);
}

stock Market_ClearAccessoryCache(playerid)
{
    #pragma unused playerid
    return 1;
}

stock Market_RefreshAccessoryCache(playerid)
{
    #pragma unused playerid
    return 1;
}

stock Market_IsAccessorySource(source_id)
{
    #pragma unused source_id
    return 0;
}

stock Market_MakeAccessorySource(accessory_slot)
{
    return MARKET_SOURCE_ACCESSORY_BASE + accessory_slot;
}

stock Market_GetAccessorySlotFromSource(source_id)
{
    #pragma unused source_id
    return -1;
}

stock Market_IsActiveSource(source_id)
{
    #pragma unused source_id
    return 0;
}

stock Market_MakeActiveSource(active_slot)
{
    return MARKET_SOURCE_ACTIVE_BASE + active_slot;
}

stock Market_GetActiveSlotFromSource(source_id)
{
    #pragma unused source_id
    return -1;
}

stock Market_GetAccessoryModelFromSource(playerid, source_id)
{
    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_id, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) return -1;
    if(!Inventory11_IsAccessoryItem(item_id)) return -1;

    if(extra_1 > 0) return extra_1;
    if(model_id > 1) return model_id;
    return Inv11_GetAccModelByItem(item_id);
}

stock Market_IsSingleInventoryEntity(item_id)
{
    if(item_id == 58 || item_id == 134) return 1;
    if(Inventory11_IsAccessoryItem(item_id)) return 1;
    if(Inventory11_IsPlateItem(item_id)) return 1;
    return 0;
}

stock Market_IsSellableInventoryItem(item_id)
{
    // Marketplace policy: only skins and accessories can be listed.
    // SIM cards, vehicle plates and all other inventory items are rejected.
    if(item_id == 134) return 1;
    if(Inventory11_IsAccessoryItem(item_id)) return 1;
    return 0;
}

stock Market_GetSourceItemId(playerid, source_id)
{
    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_id, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) return 0;
    return item_id;
}

stock Market_GetSourceItemCount(playerid, source_id)
{
    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_id, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) return 0;

    if(item_id == 134)
    {
        if(old_skin > 0) return old_skin;
        return model_id;
    }
    if(item_id == 58)
    {
        if(oldsim_value > 0) return oldsim_value;
        if(extra_1 > 0) return extra_1;
        if(model_id > 0) return model_id;
        if(sim_value > 0) return sim_value;
    }
    return amount > 0 ? amount : 1;
}

stock Market_GetSourcePlate(playerid, source_id, meta[], meta_size)
{
    meta[0] = EOS;

    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_id, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) return 0;

    if(item_id == 58)
    {
        new number = oldsim_value;
        if(number <= 0) number = extra_1;
        if(number <= 0) number = model_id;
        if(number <= 0) number = sim_value;
        if(number > 0) format(meta, meta_size, "%d", number);
        return 1;
    }

    if(Inventory11_IsAccessoryItem(item_id))
    {
        new accessory_model = extra_1;
        if(accessory_model <= 0 && model_id > 1) accessory_model = model_id;
        if(accessory_model <= 0) accessory_model = Inv11_GetAccModelByItem(item_id);
        format(meta, meta_size, "A|%d", accessory_model);
        return 1;
    }

    if(Inventory11_IsPlateItem(item_id))
    {
        new plate_type, plate[16], region[8];
        if(Inventory11_GetPlateData(playerid, source_id, plate_type, plate, sizeof(plate), region, sizeof(region)))
            format(meta, meta_size, "P|%d|%s|%s", plate_type, plate, region);
        return 1;
    }
    return 1;
}

stock Market_CanSellSource(playerid, source_id)
{
    new max_slots = Inventory11_GetMaxSlots(playerid);
    if(max_slots < 1 || max_slots > INVENTORY11_MAX_SLOTS) max_slots = INVENTORY11_MAX_SLOTS;
    if(source_id < 1 || source_id > max_slots) return 0;
    return Market_IsSellableInventoryItem(Market_GetSourceItemId(playerid, source_id));
}

stock Market_DeleteInventorySlot(playerid, slot)
{
    if(!Market_CanSellSource(playerid, slot)) return 0;
    return Inventory11_DeleteSlotFromDatabase(playerid, slot);
}

stock Market_DeleteActiveSource(playerid, active_slot)
{
    #pragma unused playerid
    #pragma unused active_slot
    return 0;
}

stock Market_DeleteAccessorySource(playerid, accessory_slot)
{
    #pragma unused playerid
    #pragma unused accessory_slot
    return 0;
}

stock Market_DeleteSource(playerid, source_id)
{
    return Market_DeleteInventorySlot(playerid, source_id);
}

stock Inventory_GetFreeSlot(playerid)
{
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return -1;

    new max_slots = Inventory11_GetMaxSlots(playerid);
    if(max_slots < 1 || max_slots > INVENTORY11_MAX_SLOTS) max_slots = INVENTORY11_MAX_SLOTS;

    new bool:used[INVENTORY11_MAX_SLOTS + 1];
    new query[196];
    mysql_format(mysql, query, sizeof(query),
        "SELECT slot FROM inventory WHERE account_id=%d AND slot BETWEEN 1 AND %d",
        account_id, max_slots);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return -1;
    }

    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot >= 1 && slot <= max_slots) used[slot] = true;
    }
    cache_delete(result);

    for(new slot = 1; slot <= max_slots; slot++)
        if(!used[slot]) return slot;
    return -1;
}

stock Inventory_GetDeliverySlot(playerid, item_id)
{
    // Medkits are stackable in Inventory11 and can be delivered even when
    // every regular slot is occupied, as long as a medkit stack already exists.
    if(item_id == 22)
    {
        new query[192];
        mysql_format(mysql, query, sizeof(query),
            "SELECT slot FROM inventory WHERE account_id=%d AND item_id=22 ORDER BY slot ASC LIMIT 1",
            GetPlayerAccountID(playerid));
        new Cache:result = mysql_query(mysql, query, true);
        if(!mysql_errno() && cache_num_rows() > 0)
        {
            new stack_slot = cache_get_field_content_int(0, "slot");
            cache_delete(result);
            if(stack_slot >= 1 && stack_slot <= Inventory11_GetMaxSlots(playerid)) return stack_slot;
        }
        else cache_delete(result);
    }
    return Inventory_GetFreeSlot(playerid);
}

stock Inventory_RemoveItem(playerid, slot, remove_amount)
{
    if(remove_amount <= 0) return 0;

    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, slot, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) return 0;

    if(Market_IsSingleInventoryEntity(item_id) || remove_amount >= amount)
        return Inventory11_DeleteSlotFromDatabase(playerid, slot);

    new left_amount = amount - remove_amount;
    if(left_amount <= 0) return Inventory11_DeleteSlotFromDatabase(playerid, slot);

    new query[224];
    if(item_id == 22)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE inventory SET amount=%d,model_id=%d WHERE account_id=%d AND slot=%d AND item_id=%d LIMIT 1",
            left_amount, left_amount, GetPlayerAccountID(playerid), slot, item_id);
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE inventory SET amount=%d WHERE account_id=%d AND slot=%d AND item_id=%d LIMIT 1",
            left_amount, GetPlayerAccountID(playerid), slot, item_id);
    }
    new Cache:result = mysql_query(mysql, query, true);
    new changed = cache_affected_rows(mysql);
    cache_delete(result);
    return changed > 0;
}

stock Inventory_AddItem(playerid, item_id, preferred_slot, item_count, item_meta[])
{
    #pragma unused preferred_slot
    if(item_count <= 0) item_count = 1;

    new model_id = item_id, amount = item_count, extra_1 = 0, extra_2 = 0;
    new plate_type = -1, plate[16], region[8];
    plate[0] = EOS;
    region[0] = EOS;

    if(item_id == 134)
    {
        model_id = item_count;
        amount = 1;
    }
    else if(item_id == 58)
    {
        new sim_number = strval(item_meta);
        if(sim_number <= 0) sim_number = item_count;
        model_id = sim_number;
        extra_1 = sim_number;
        amount = 1;
    }
    else if(Inventory11_IsAccessoryItem(item_id))
    {
        new accessory_model, marker[2];
        if(sscanf(item_meta, "p<|>s[2]i", marker, accessory_model)) accessory_model = 0;
        if(accessory_model <= 0) accessory_model = Inv11_GetAccModelByItem(item_id);
        // Inventory11 stores the actual accessory model in extra_1; model_id
        // remains 1, exactly like the built-in player-to-player trade system.
        model_id = 1;
        extra_1 = accessory_model;
        amount = 1;
    }
    else if(Inventory11_IsPlateItem(item_id))
    {
        new marker[2];
        if(sscanf(item_meta, "p<|>s[2]is[16]s[8]", marker, plate_type, plate, region))
        {
            plate_type = PlateCountryToType(PlateItemIdToCountry(item_id));
            plate[0] = EOS;
            region[0] = EOS;
        }
        model_id = PlateItemIdToModel(item_id);
        amount = 1;
    }

    new new_slot = Inventory11_AddItemToDatabase(playerid, item_id, model_id, amount, extra_1, extra_2);
    if(new_slot == -1) return 0;

    if(Inventory11_IsPlateItem(item_id) && plate_type >= 0 && strlen(plate))
    {
        if(!Inventory11_SavePlateData(playerid, new_slot, plate_type, plate, region))
        {
            Inventory11_DeleteSlotFromDatabase(playerid, new_slot);
            return 0;
        }
    }

    // Return the real Inventory11 slot. Existing callers only test for zero,
    // while reward rollback needs the exact slot (medkits may merge into a stack).
    return new_slot;
}

stock Market_GetItemName(item_id, model_id, name[], name_size)
{
    name[0] = EOS;
    switch(item_id)
    {
        case 22: format(name, name_size, "Аптечка");
        case 58: format(name, name_size, "SIM-карта");
        case 59: format(name, name_size, "Госномер России");
        case 81: format(name, name_size, "Госномер Украины");
        case 82: format(name, name_size, "Госномер Беларуси");
        case 83: format(name, name_size, "Госномер Казахстана");
        case 134: format(name, name_size, "Скин");
        default:
        {
            if(Inventory11_IsAccessoryItem(item_id))
            {
                if(model_id <= 0) model_id = Inv11_GetAccModelByItem(item_id);
                new index = AccessoryGetIndexByModel(model_id);
                if(index >= 0) format(name, name_size, "%s", accessory[index][NAME_ACCESSORY]);
                else format(name, name_size, "Аксессуар #%d", item_id);
            }
            else format(name, name_size, "Предмет #%d", item_id);
        }
    }
    return 1;
}

stock GetItemName(item_id, name[], name_size)
{
    return Market_GetItemName(item_id, 0, name, name_size);
}

stock GetItemNameById(item_id, name[], name_size)
{
    return Market_GetItemName(item_id, Inv11_GetAccModelByItem(item_id), name, name_size);
}

stock SendPacketToClient(playerid, guiid, Node:json)
{
    if(guiid == MarketplaceGuiFragment && GetPVarInt(playerid, "market_open_pending"))
    {
        JSON_SetInt(json, "o", 1);
        DeletePVar(playerid, "market_open_pending");
    }
    if(guiid == BpRewardsGuiFragment && GetPVarInt(playerid, "mpreward_open_pending"))
    {
        JSON_SetInt(json, "o", 1);
        DeletePVar(playerid, "mpreward_open_pending");
    }
    OnPacketIncoming(playerid, guiid, json);
    return 1;
}

#include "../include/system/marketplace_reward.inc"
#include "../include/system/marketplace_gui.inc"

#define MARKET_GUI_ID MARKETPLACE_GUI_ID

stock Marketplace_Init()
{
    return Marketplace_OnGameModeInit();
}

stock Market_ResetPlayer(playerid)
{
    Marketplace_ResetPlayer(playerid);
    MPReward_ResetPlayer(playerid);
    DeletePVar(playerid, "market_open_pending");
    DeletePVar(playerid, "mpreward_open_pending");
    return 1;
}

stock Market_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    return Marketplace_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
}

stock Market_OnPacket(playerid, Node:json)
{
    return Marketplace_OnPacket(playerid, json);
}

stock Market_Open(playerid)
{
    return Marketplace_OpenGUI(playerid);
}
