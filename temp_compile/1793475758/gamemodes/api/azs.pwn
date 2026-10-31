#if !defined BrDialogFuelFill
    #define BrDialogFuelFill (2)
#endif

//by melliss

stock AZC_GetFuelName(type, dest[], size = sizeof dest)
{
    switch(type)
    {
        case 0: format(dest, size, "\xc0\xc8\x2d\x39\x32");
        case 1: format(dest, size, "\xc0\xc8\x2d\x39\x35");
        case 2: format(dest, size, "\xc0\xc8\x2d\x39\x38");
        case 3: format(dest, size, "\xc0\xc8\x2d\x31\x30\x30");
        case 4: format(dest, size, "\xc4\xd2");
        default: format(dest, size, "\xd2\xee\xef\xeb\xe8\xe2\xee");
    }
    return 1;
}

stock AZC_GetVehicleFreeFuel(vehicleid)
{
    new Float:current_fuel = GetVehicleData(vehicleid, V_FUEL);
    new free_liters = floatround(150.0 - current_fuel, floatround_floor);

    if(free_liters < 0) free_liters = 0;
    if(free_liters > 150) free_liters = 150;
    return free_liters;
}

stock AZC_ShowFuelStation(playerid, vehicleid, stationid)
{
    if(vehicleid == INVALID_VEHICLE_ID || !IsPlayerInVehicle(playerid, vehicleid))
        return SendClientMessage(playerid, 0xCECECEFF, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xed\xe0\xf5\xee\xe4\xe8\xf2\xfc\xf1\xff\x20\xe2\x20\xf2\xf0\xe0\xed\xf1\xef\xee\xf0\xf2\xe5"), 1;

    if(!IsPlayerDriver(playerid))
        return SendClientMessage(playerid, 0xCECECEFF, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe1\xfb\xf2\xfc\x20\xe7\xe0\x20\xf0\xf3\xeb\xe5\xec"), 1;

    if(IsABike(vehicleid))
        return SendClientMessage(playerid, 0xCECECEFF, "\xdd\xf2\xee\xf2\x20\xf2\xf0\xe0\xed\xf1\xef\xee\xf0\xf2\x20\xed\xe5\xeb\xfc\xe7\xff\x20\xe7\xe0\xef\xf0\xe0\xe2\xe8\xf2\xfc"), 1;

    if(stationid == -1)
        return SendClientMessage(playerid, 0xCECECEFF, "\xcf\xee\xe1\xeb\xe8\xe7\xee\xf1\xf2\xe8\x20\xed\xe5\xf2\x20\xe7\xe0\xef\xf0\xe0\xe2\xee\xf7\xed\xfb\xf5\x20\xf1\xf2\xe0\xed\xf6\xe8\xe9"), 1;

    if(GetFuelStationData(stationid, FS_LOCK_STATUS))
        return SendClientMessage(playerid, 0xCECECEFF, "\xc0\xc7\xd1\x20\xe7\xe0\xea\xf0\xfb\xf2\xe0") , 1;

    new max_liters = AZC_GetVehicleFreeFuel(vehicleid);
    if(max_liters < 1)
        return SendClientMessage(playerid, 0xCECECEFF, "\xc1\xe5\xed\xe7\xee\xe1\xe0\xea\x20\xf3\xe6\xe5\x20\xef\xee\xeb\xed\xfb\xe9"), 1;

    if(IsFuelStationOwned(stationid) && GetFuelStationData(stationid, FS_FUELS) < max_liters)
        max_liters = GetFuelStationData(stationid, FS_FUELS);

    if(max_liters < 1)
        return SendClientMessage(playerid, 0xCECECEFF, "\xcd\xe0\x20\xc0\xc7\xd1\x20\xed\xe5\xf2\x20\xf2\xee\xef\xeb\xe8\xe2\xe0"), 1;

    SetPVarInt(playerid, "azc_vehicle", vehicleid);
    SetPVarInt(playerid, "azc_station", stationid);
    SetPVarInt(playerid, "azc_max_liters", max_liters);

    new price = GetFuelStationData(stationid, FS_FUEL_PRICE) * 10;
    if(price < 1) price = 50;
    SetPVarInt(playerid, "azc_price", price);

    new gui_hint[64];
    format(gui_hint, sizeof gui_hint, "%s", "\xd0\xe5\xea\xee\xec\xe5\xed\xe4\xf3\xe5\xec\xfb\xe9\x20\xf2\xe8\xef\x20\xf2\xee\xef\xeb\xe8\xe2\xe0\x3a\x20\x39\x35");

    new Node:json = JSON_Object();
    new Node:prices = JSON_Array(JSON_Int(price), JSON_Int(price), JSON_Int(price), JSON_Int(price), JSON_Int(price));

    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "m", max_liters);
    JSON_SetArray(json, "ma", prices);
    JSON_SetString(json, "h", gui_hint, strlen(gui_hint));
    OnPacketIncoming(playerid, BrDialogFuelFill, json);
    JSON_Cleanup(json);
    return 1;
}

stock AZC_SendFuelHint(playerid, const text[])
{
    new hint_text[144];
    format(hint_text, sizeof hint_text, "%s", text);

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", -1);
    JSON_SetString(json, "h", hint_text, strlen(hint_text));
    OnPacketIncoming(playerid, BrDialogFuelFill, json);
    JSON_Cleanup(json);
    return 1;
}

stock AZC_ResetPlayerVars(playerid)
{
    DeletePVar(playerid, "azc_vehicle");
    DeletePVar(playerid, "azc_station");
    DeletePVar(playerid, "azc_price");
    DeletePVar(playerid, "azc_max_liters");
    return 1;
}

stock AZC_DoRefuel(playerid, liters, fuel_type)
{
    new stationid = GetPVarInt(playerid, "azc_station");
    new vehicleid = GetPVarInt(playerid, "azc_vehicle");

    if(vehicleid == INVALID_VEHICLE_ID || vehicleid <= 0 || !IsValidVehicle(vehicleid) || !IsPlayerInVehicle(playerid, vehicleid))
    {
        vehicleid = GetPlayerVehicleID(playerid);
    }

    if(vehicleid == INVALID_VEHICLE_ID || vehicleid <= 0 || !IsValidVehicle(vehicleid) || !IsPlayerInVehicle(playerid, vehicleid))
        return AZC_SendFuelHint(playerid, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xed\xe0\xf5\xee\xe4\xe8\xf2\xfc\xf1\xff\x20\xe2\x20\xf2\xf0\xe0\xed\xf1\xef\xee\xf0\xf2\xe5") , 1;

    if(!IsPlayerDriver(playerid))
        return AZC_SendFuelHint(playerid, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe1\xfb\xf2\xfc\x20\xe7\xe0\x20\xf0\xf3\xeb\xe5\xec") , 1;

    if(IsABike(vehicleid))
        return AZC_SendFuelHint(playerid, "\xdd\xf2\xee\xf2\x20\xf2\xf0\xe0\xed\xf1\xef\xee\xf0\xf2\x20\xed\xe5\xeb\xfc\xe7\xff\x20\xe7\xe0\xef\xf0\xe0\xe2\xe8\xf2\xfc") , 1;

    new nearest_station = GetNearestFuelStation(playerid, 15.0);
    if(stationid < 0 || stationid >= g_fuel_station_loaded)
        stationid = nearest_station;

    if(nearest_station != -1)
        stationid = nearest_station;

    if(stationid < 0 || stationid >= g_fuel_station_loaded)
        return AZC_SendFuelHint(playerid, "\xc0\xc7\xd1\x20\xed\xe5\x20\xed\xe0\xe9\xe4\xe5\xed\xe0") , 1;

    if(liters < 1)
    {
        liters = GetPVarInt(playerid, "azc_max_liters");
        if(liters < 1) liters = 1;
    }

    if(liters > 150) liters = 150;

    new free_liters = AZC_GetVehicleFreeFuel(vehicleid);
    if(free_liters < 1)
        return AZC_SendFuelHint(playerid, "\xc1\xe5\xed\xe7\xee\xe1\xe0\xea\x20\xf3\xe6\xe5\x20\xef\xee\xeb\xed\xfb\xe9") , 1;

    if(liters > free_liters)
        liters = free_liters;

    new price_per_liter = GetPVarInt(playerid, "azc_price");
    new station_price = GetFuelStationData(stationid, FS_FUEL_PRICE);
    if(station_price > 0) price_per_liter = station_price * 10;
    if(price_per_liter < 1) price_per_liter = 50;

    if(IsFuelStationOwned(stationid) && GetFuelStationData(stationid, FS_FUELS) < liters)
        return AZC_SendFuelHint(playerid, "\xcd\xe0\x20\xc0\xc7\xd1\x20\xed\xe5\xf2\x20\xf2\xe0\xea\xee\xe3\xee\x20\xea\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xe0\x20\xf2\xee\xef\xeb\xe8\xe2\xe0") , 1;

    new price = price_per_liter * liters;
    if(GetPlayerMoneyEx(playerid) < price)
        return AZC_SendFuelHint(playerid, "\xcd\xe5\xe4\xee\xf1\xf2\xe0\xf2\xee\xf7\xed\xee\x20\xe4\xe5\xed\xe5\xe3\x20\xe4\xeb\xff\x20\xe7\xe0\xef\xf0\xe0\xe2\xea\xe8") , 1;

    if(IsFuelStationOwned(stationid))
    {
        AddFuelStationData(stationid, FS_FUELS, -, liters);
        AddFuelStationData(stationid, FS_BALANCE, +, price);
    }

    new Float:new_fuel = GetVehicleData(vehicleid, V_FUEL) + float(liters);
    if(new_fuel > 150.0) new_fuel = 150.0;

    // V_FUEL хранитс€ как Float. ƒополнительно синхронизируем старый vInfo
    // и сразу отправл€ем новое значение на спидометр водителю.
    SetVehicleData(vehicleid, V_FUEL, new_fuel);
    vInfo[vehicleid][vFuel] = new_fuel;
    SetVehicleSpeedometerInfoFP(
        playerid,
        vehicleid,
        new_fuel,
        GetVehicleData(vehicleid, V_MILEAGE)
    );

    GivePlayerMoneyEx(playerid, -price, "\xcf\xee\xea\xf3\xef\xea\xe0\x20\xf2\xee\xef\xeb\xe8\xe2\xe0\x20\xed\xe0\x20\xc0\xc7\xd1", true, true);

    if(IsFuelStationOwned(stationid))
    {
        new query[256];
        mysql_format(mysql, query, sizeof query, "UPDATE fuel_stations SET fuels=%d,balance=%d WHERE id=%d LIMIT 1",
            GetFuelStationData(stationid, FS_FUELS),
            GetFuelStationData(stationid, FS_BALANCE),
            GetFuelStationData(stationid, FS_SQL_ID)
        );
        mysql_query(mysql, query, false);
    }

    new buy_fuel_pay = GetPVarInt(playerid, "buy_fuel_pay") + price;
    new buy_fuel_count = GetPVarInt(playerid, "buy_fuel_count") + liters;
    SetPVarInt(playerid, "buy_fuel_pay", buy_fuel_pay);
    SetPVarInt(playerid, "buy_fuel_count", buy_fuel_count);

    new fuel_name[16], msg[144];
    AZC_GetFuelName(fuel_type, fuel_name, sizeof fuel_name);
    format(msg, sizeof msg, "\xc2\xfb\x20\xe7\xe0\xef\xf0\xe0\xe2\xe8\xeb\xe8 %d \xeb (%s) \xe7\xe0 %d \xf0\xf3\xe1\xeb\xe5\xe9", liters, fuel_name, price);
    SendClientMessage(playerid, 0x66CC00FF, msg);
    GameTextForPlayer(playerid, "~g~refueled", 2500, 1);

    AZC_SendFuelHint(playerid, " ");
    AZC_ResetPlayerVars(playerid);
    return 1;
}

stock AZC_HandleFuelGui(playerid, Node:json)
{
    new action = -1;
    new liters = 0;
    new fuel_type = 1;

    JSON_GetInt(json, "t", action);
    JSON_GetInt(json, "v", liters);
    JSON_GetInt(json, "f", fuel_type);

    if(liters <= 0) JSON_GetInt(json, "l", liters);
    if(liters <= 0) JSON_GetInt(json, "liters", liters);
    if(liters <= 0) JSON_GetInt(json, "litres", liters);
    if(liters <= 0) JSON_GetInt(json, "count", liters);
    if(liters <= 0) JSON_GetInt(json, "c", liters);

    if(fuel_type < 0) JSON_GetInt(json, "type", fuel_type);
    if(fuel_type < 0) JSON_GetInt(json, "fuel", fuel_type);
    if(fuel_type < 0) JSON_GetInt(json, "fuel_type", fuel_type);

    if(action == 1)
    {
        AZC_ResetPlayerVars(playerid);
        return 1;
    }

    if(liters <= 0)
        return 1;

    return AZC_DoRefuel(playerid, liters, fuel_type);
}

stock AZC_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused playerid, dialogid, response, listitem, inputtext
    return 0;
}

CMD:azc(playerid, params[])
{
    #pragma unused params
    new vehicleid = GetPlayerVehicleID(playerid);
    new stationid = GetNearestFuelStation(playerid, 10.0);
    return AZC_ShowFuelStation(playerid, vehicleid, stationid);
}

CMD:azs(playerid, params[])
{
    #pragma unused params
    new vehicleid = GetPlayerVehicleID(playerid);
    new stationid = GetNearestFuelStation(playerid, 10.0);
    return AZC_ShowFuelStation(playerid, vehicleid, stationid);
}


CMD:buyazs(playerid, params[])
{
    #pragma unused params
    return callcmd::buyfuelst(playerid, "");
}

CMD:azsbiz(playerid, params[])
{
    #pragma unused params
    return callcmd::fuelst(playerid, "");
}

CMD:sellazs(playerid, params[])
{
    #pragma unused params
    return callcmd::sellfuelst(playerid, "");
}

CMD:azslock(playerid, params[])
{
    #pragma unused params
    new stationid = GetPlayerFuelStation(playerid);
    if(stationid == -1) return SendClientMessage(playerid, 0xCECECEFF, "U vas net AZS"), 1;
    ShowPlayerFuelStationDialog(playerid, FUEL_ST_OPERATION_LOCK);
    return 1;
}

CMD:azshelp(playerid, params[])
{
    #pragma unused params
    SendClientMessage(playerid, 0xFFCD00FF, "AZS: /azc ili /azs - zapravitsya cherez krasivoe GUI");
    SendClientMessage(playerid, 0xFFCD00FF, "Biznes: /buyazs /azsbiz /sellazs /azslock");
    SendClientMessage(playerid, 0xFFCD00FF, "Takzhe rabotayut standartnye: /buyfuelst /fuelst /sellfuelst");
    return 1;
}

CMD:addazc(playerid, params[])
{
    if(GetPlayerAdminEx(playerid) < 10) return 1;

    if(g_fuel_station_loaded >= MAX_FUEL_STATIONS)
        return SendClientMessage(playerid, 0xCECECEFF, "\xc4\xee\xf1\xf2\xe8\xe3\xed\xf3\xf2\x20\xeb\xe8\xec\xe8\xf2\x20\xc0\xc7\xd1\x2e\x20\xd3\xe2\xe5\xeb\xe8\xf7\xfc\xf2\xe5\x20\x4d\x41\x58\x5f\x46\x55\x45\x4c\x5f\x53\x54\x41\x54\x49\x4f\x4e\x53"), 1;

    new price = 1000000, rent_price = 5000;
    if(strlen(params)) sscanf(params, "dd", price, rent_price);

    new idx = g_fuel_station_loaded;
    GetPlayerPos(playerid, g_fuel_station[idx][FS_POS_X], g_fuel_station[idx][FS_POS_Y], g_fuel_station[idx][FS_POS_Z]);

    new Cache:result, query[320];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `fuel_stations` (`owner_id`,`name`,`improvements`,`fuels`,`fuel_price`,`buy_fuel_price`,`balance`,`rent_time`,`price`,`rent_price`,`lock`,`x`,`y`,`z`,`eviction`) VALUES (0,'AZC bylibplugin',0,5000,5,2,0,0,%d,%d,0,%f,%f,%f,0)",
        price,
        rent_price,
        GetFuelStationData(idx, FS_POS_X),
        GetFuelStationData(idx, FS_POS_Y),
        GetFuelStationData(idx, FS_POS_Z)
    );
    result = mysql_query(mysql, query, true);

    SetFuelStationData(idx, FS_SQL_ID, cache_insert_id());
    cache_delete(result);

    format(g_fuel_station[idx][FS_NAME], 20, "AZC bylibplugin");
    SetFuelStationData(idx, FS_OWNER_ID, 0);
    SetFuelStationData(idx, FS_IMPROVEMENTS, 0);
    SetFuelStationData(idx, FS_FUELS, 5000);
    SetFuelStationData(idx, FS_FUEL_PRICE, 5);
    SetFuelStationData(idx, FS_BUY_FUEL_PRICE, 2);
    SetFuelStationData(idx, FS_BALANCE, 0);
    SetFuelStationData(idx, FS_RENT_DATE, 0);
    SetFuelStationData(idx, FS_PRICE, price);
    SetFuelStationData(idx, FS_RENT_PRICE, rent_price);
    SetFuelStationData(idx, FS_LOCK_STATUS, false);
    SetFuelStationData(idx, FS_EVICTION, 0);
    format(g_fuel_station[idx][FS_OWNER_NAME], 21, "None");

    SetFuelStationData(idx, FS_LABEL, CreateDynamic3DTextLabel(GetFuelStationData(idx, FS_NAME), 0x3399FFFF, GetFuelStationData(idx, FS_POS_X), GetFuelStationData(idx, FS_POS_Y), GetFuelStationData(idx, FS_POS_Z) + 0.5, 15.0));
    SetFuelStationData(idx, FS_AREA, CreateDynamicSphere(GetFuelStationData(idx, FS_POS_X), GetFuelStationData(idx, FS_POS_Y), GetFuelStationData(idx, FS_POS_Z), 15.0));
    SetFuelStationData(idx, FS_ORDER_ID, -1);
    CreateDynamicMapIcon(GetFuelStationData(idx, FS_POS_X), GetFuelStationData(idx, FS_POS_Y), GetFuelStationData(idx, FS_POS_Z), 47, 0, 0, 0, -1, STREAMER_MAP_ICON_SD, MAPICON_LOCAL);

    g_fuel_station_loaded++;
    UpdateFuelStationLabel(idx);

    new msg[96];
    format(msg, sizeof msg, "AZC bylibplugin created. ID: %d", idx);
    SendClientMessage(playerid, 0x66CC00FF, msg);
    return 1;
}