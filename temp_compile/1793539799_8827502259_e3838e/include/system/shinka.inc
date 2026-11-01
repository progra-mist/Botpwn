CMD:shinka(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new model = GetVehicleModel(vehicleid);
    new price = GetVehiclePriceByModel(model);
    new Node:tuning_json = JSON_Object();

    InStailing[playerid] = true;

    JSON_SetInt(tuning_json, "o", 1);
    JSON_SetInt(tuning_json, "w", 2);
    JSON_SetInt(tuning_json, "j", price); 
    JSON_SetInt(tuning_json, "s", 5);

    JSON_SetString(tuning_json, "nm", GetPlayerNameEx(playerid));
    JSON_SetString(tuning_json, "n", GetVehicleNameByModel(model));
    JSON_SetInt(tuning_json, "m", GetPlayerMoneyEx(playerid));

    SetPlayerInterior(playerid, 1);

    new Float:x = 998.23653, Float:y = 1499.67341, Float:z = 1499.66617;
    SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
    SetVehicleZAngle(GetPlayerVehicleID(playerid), 270.0);

    new interior = 1;

    SetPlayerInterior(playerid, interior);

    SetPlayerInterior(playerid, interior);
    
    new carid = GetPlayerVehicleID(playerid); 

    if (carid != 0)
    {
       SetVehiclePos(carid, 995.7154, 1000.5235, 1500.1683);
    }

    SetVehiclePos(carid, 995.7154, 1000.5235, 1500.1683);
    SetVehicleZAngle(carid, 180.0);
    SetPlayerCameraPos(playerid, 999.1838, 995.9953, 1501.7263);
    SetPlayerCameraLookAt(playerid, 998.5103, 996.7333, 1501.5776);

    OnPacketIncoming(playerid, 28, tuning_json);

    return 1;
}