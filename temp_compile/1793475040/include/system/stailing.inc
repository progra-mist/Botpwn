new const VinylNames[][] = {
    "remapbody8", "remapbody5", "remapbody32", "remapbody40", "remapbody21", "remapbody29",
    "remapbody41", "remapbody6", "remapbody31", "remapbody19", "remapbody28", "remapbody30",
    "remapbody11", "remapbody12", "remapbody15", "remapbody26", "remapbody16", "remapbody13",
    "remapbody18", "remapbody35", "remapbody10", "remapbody17", "remapbody38", "remapbody2",
    "remapbody23", "remapbody36", "remapbody4", "remapbody14", "remapbody37", "remapbody20",
    "remapbody7", "remapbody25", "remapbody39", "remapbody1", "remapbody33", "remapbody9",
    "remapbody22", "remapbody24", "remapbody34", "remapbody42", "remapbody47", "remapbody48",
    "remapbody43", "remapbody44", "remapbody49", "remapbody51", "remapbody45", "remapbody46",
    "remaphbody1", "remaphbody2", "remaphbody3", "remaphbody4", "remaphbody5", "remaphbody6",
    "remaphbody7", "remaphbody8", "remaphbody9", "remaphbody10", "remaphbody11", "remapnbody1",
    "remapnbody2", "remapnbody3", "remapnbody4", "remapnbody5", "remapnbody6", "remapnbody7",
    "remapnbody8", "remapnbody9", "remapnbody10", "remapnbody11", "remapnbody12", "remapnbody13",
    "remapnbody14", "remapnbody15", "remapnbody16", "remapnbody17", "remapmbody1", "remapmbody2",
    "remapmbody3", "remapmbody4", "remapmbody5", "remapmbody6", "remapmbody7", "remapmbody8",
    "remapmbody9", "remapmbody10", "remapmbody11", "remapmbody12", "remapmbody13", "remapmbody14",
    "remapmbody15", "remapmbody16", "remapmbody17", "", "", "", "", "", "", "", "", "", "", 
    "", "", "", "", "", "", "", "remapnbody18", "remapnbody19", "remapnbody20", "remapnbody21", 
    "remapnbody22", "remapnbody23", "remapnbody24", "remapnbody25", "remapnbody26", "remapnbody27"
};

CMD:tungui(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new model = GetVehicleModel(vehicleid);
    new price = GetVehiclePriceByModel(model);
    new Node:tuning_json = JSON_Object();

    InStailing[playerid] = true;

    JSON_SetInt(tuning_json, "o", 1);
    JSON_SetInt(tuning_json, "w", 0);
    JSON_SetInt(tuning_json, "j", price); 
    JSON_SetInt(tuning_json, "s", 5);

    JSON_SetString(tuning_json, "nm", GetPlayerNameEx(playerid));
    JSON_SetString(tuning_json, "n", GetVehicleNameByModel(model));
    JSON_SetInt(tuning_json, "m", GetPlayerMoneyEx(playerid));

    SetPlayerInterior(playerid, 1);

    new carid = GetPlayerVehicleID(playerid);
    if (carid != 0)
    {
        SetVehiclePos(carid, 1000.0, 1500.0, 1498.0);
        SetVehicleZAngle(carid, 180.0);
    }

    SetPlayerCameraPos(playerid, 1003.9196, 1493.9724, 1499.7500);
    SetPlayerCameraLookAt(playerid, 1003.3480, 1494.7935, 1499.5002);

    OnPacketIncoming(playerid, 28, tuning_json);

    return 1;
}

stock GetBodyPaintCost(price)
{
    return (price / 100) + 10000;
}

stock GetUnivCost(price)
{
    return (price / 100) + 10000 + 40000;
}

stock GetDalniyCost(price)
{
    return (price / 1000) + 10000;
}
stock GetDoubleCost(price)
{
    return ((price / 100) + 10000) * 2;
}

stock GetExtraCost(price)
{
    return (price / 100) + 10000 + 10000;
}

stock GetDonatCost(price)
{
    return (((price / 100) + 10000 + 40000) * 3) / 1000;
}