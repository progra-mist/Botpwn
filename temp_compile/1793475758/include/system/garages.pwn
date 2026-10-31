#if !defined _SYSTEM_GARAGES
#define _SYSTEM_GARAGES

#define MAX_GARAGES             500
#define GARAGE_INTERIOR         1
#define GARAGE_WORLD_BASE       5000
#define GARAGE_DIALOG_ID        58000

enum E_GARAGE
{
    gID,
    gOwner[MAX_PLAYER_NAME + 1],
    gPrice,
    Float:gX,
    Float:gY,
    Float:gZ,
    Float:gA,
    gInterior,
    gWorld,
    gVehicle[4],
    gPickup,
    gLabel
};

new Garage[MAX_GARAGES][E_GARAGE];
new PlayerGarage[MAX_PLAYERS] = { -1, ... };
new Float:GarageReturnPos[MAX_PLAYERS][3];
new Float:GarageReturnAngle[MAX_PLAYERS];
new GarageReturnInterior[MAX_PLAYERS];
new GarageReturnWorld[MAX_PLAYERS];
new GarageReturnVehicle[MAX_PLAYERS];

forward Garage_Load();
forward Garage_LoadData();
forward Garage_Save(id);

stock Garage_EnsureDatabaseTable()
{
    new query[1024];
    query[0] = EOS;
    strcat(query, "CREATE TABLE IF NOT EXISTS `garage_system` (");
    strcat(query, "`id` INT NOT NULL AUTO_INCREMENT,");
    strcat(query, "`owner` VARCHAR(32) NOT NULL DEFAULT '',");
    strcat(query, "`price` INT NOT NULL DEFAULT 500000,");
    strcat(query, "`x` FLOAT NOT NULL DEFAULT 0,");
    strcat(query, "`y` FLOAT NOT NULL DEFAULT 0,");
    strcat(query, "`z` FLOAT NOT NULL DEFAULT 0,");
    strcat(query, "`a` FLOAT NOT NULL DEFAULT 0,");
    strcat(query, "`interior` INT NOT NULL DEFAULT 0,");
    strcat(query, "`world` INT NOT NULL DEFAULT 0,");
    strcat(query, "`vehicle1` INT NOT NULL DEFAULT 0,");
    strcat(query, "`vehicle2` INT NOT NULL DEFAULT 0,");
    strcat(query, "`vehicle3` INT NOT NULL DEFAULT 0,");
    strcat(query, "`vehicle4` INT NOT NULL DEFAULT 0,");
    strcat(query, "PRIMARY KEY (`id`)");
    strcat(query, ") ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_query(mysql, query, false);

    // The supplied standalone system did not contain coordinates. Seed nine
    // entrances using the garage locations already present in this mod.
    new Cache:result = mysql_query(mysql, "SELECT COUNT(*) AS cnt FROM `garage_system`", true);
    if(cache_num_rows() > 0 && cache_get_field_content_int(0, "cnt", mysql) == 0)
    {
        new const Float:seed[][4] =
        {
            {353.4040, 800.0740, 12.0000, 69.3810},
            {354.9050, 804.0060, 12.0000, 66.7752},
            {356.4510, 808.0650, 12.0073, 66.5632},
            {357.9050, 811.8910, 12.0073, 67.9254},
            {359.4220, 815.8650, 12.0000, 65.2152},
            {360.9090, 819.7650, 12.0000, 72.5789},
            {362.4310, 823.7630, 12.0000, 64.0241},
            {363.9400, 827.7300, 12.0000, 71.2634},
            {365.4210, 831.6310, 12.0085, 70.8588}
        };

        new query[256];
        for(new i = 0; i < sizeof(seed); i++)
        {
            mysql_format(mysql, query, sizeof(query),
                "INSERT INTO `garage_system` (`owner`,`price`,`x`,`y`,`z`,`a`,`interior`,`world`) VALUES ('',500000,%f,%f,%f,%f,0,0)",
                seed[i][0], seed[i][1], seed[i][2], seed[i][3]
            );
            mysql_query(mysql, query, false);
        }
    }
    cache_delete(result);
    return 1;
}

stock Garage_Reset(id)
{
    Garage[id][gID] = 0;
    Garage[id][gOwner][0] = EOS;
    Garage[id][gPrice] = 500000;

    Garage[id][gX] = 0.0;
    Garage[id][gY] = 0.0;
    Garage[id][gZ] = 0.0;
    Garage[id][gA] = 0.0;

    Garage[id][gInterior] = 0;
    Garage[id][gWorld] = 0;

    for(new i = 0; i < 4; i++)
        Garage[id][gVehicle][i] = 0;

    Garage[id][gPickup] = -1;
    Garage[id][gLabel] = -1;
    return 1;
}

stock Garage_UpdateLabel(id)
{
    if(id < 0 || id >= MAX_GARAGES || Garage[id][gID] == 0)
        return 0;

    new text[256];
    if(Garage[id][gOwner][0] == EOS)
    {
        format(text, sizeof(text),
            "{FFFFFF}Гараж №%d\n{00FF00}Цена: $%d\n{FFFFFF}Свободен\n\nНажмите ALT",
            Garage[id][gID], Garage[id][gPrice]
        );
    }
    else
    {
        format(text, sizeof(text),
            "{FFFFFF}Гараж №%d\n{FFCC00}Владелец: %s\n\n{FFFFFF}Нажмите ALT",
            Garage[id][gID], Garage[id][gOwner]
        );
    }

    if(IsValidDynamic3DTextLabel(Garage[id][gLabel]))
        UpdateDynamic3DTextLabelText(Garage[id][gLabel], -1, text);

    return 1;
}

stock Garage_Create(id)
{
    if(id < 0 || id >= MAX_GARAGES || Garage[id][gID] == 0)
        return 0;

    if(IsValidDynamicPickup(Garage[id][gPickup]))
        DestroyDynamicPickup(Garage[id][gPickup]);
    if(IsValidDynamic3DTextLabel(Garage[id][gLabel]))
        DestroyDynamic3DTextLabel(Garage[id][gLabel]);

    Garage[id][gPickup] = CreateDynamicPickup(
        1273,
        1,
        Garage[id][gX],
        Garage[id][gY],
        Garage[id][gZ],
        Garage[id][gWorld],
        Garage[id][gInterior]
    );

    new text[256];
    if(Garage[id][gOwner][0] == EOS)
    {
        format(text, sizeof(text),
            "{FFFFFF}Гараж №%d\n{00FF00}Цена: $%d\n{FFFFFF}Свободен\n\nНажмите ALT",
            Garage[id][gID], Garage[id][gPrice]
        );
    }
    else
    {
        format(text, sizeof(text),
            "{FFFFFF}Гараж №%d\n{FFCC00}Владелец: %s\n\n{FFFFFF}Нажмите ALT",
            Garage[id][gID], Garage[id][gOwner]
        );
    }

    Garage[id][gLabel] = CreateDynamic3DTextLabel(
        text,
        -1,
        Garage[id][gX],
        Garage[id][gY],
        Garage[id][gZ] + 1.0,
        15.0,
        INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID,
        0,
        Garage[id][gWorld],
        Garage[id][gInterior],
        -1,
        100.0
    );

    return 1;
}

public Garage_Load()
{
    for(new i = 0; i < MAX_GARAGES; i++)
        Garage_Reset(i);

    mysql_tquery(mysql,
        "SELECT * FROM `garage_system` ORDER BY `id` ASC",
        "Garage_LoadData"
    );
    return 1;
}

public Garage_LoadData()
{
    new rows = cache_num_rows();
    if(rows > MAX_GARAGES) rows = MAX_GARAGES;

    for(new i = 0; i < rows; i++)
    {
        Garage[i][gID] = cache_get_field_content_int(i, "id", mysql);
        cache_get_field_content(i, "owner", Garage[i][gOwner], mysql, MAX_PLAYER_NAME + 1);
        Garage[i][gPrice] = cache_get_field_content_int(i, "price", mysql);

        Garage[i][gX] = cache_get_field_content_float(i, "x", mysql);
        Garage[i][gY] = cache_get_field_content_float(i, "y", mysql);
        Garage[i][gZ] = cache_get_field_content_float(i, "z", mysql);
        Garage[i][gA] = cache_get_field_content_float(i, "a", mysql);

        Garage[i][gInterior] = cache_get_field_content_int(i, "interior", mysql);
        Garage[i][gWorld] = cache_get_field_content_int(i, "world", mysql);

        Garage[i][gVehicle][0] = cache_get_field_content_int(i, "vehicle1", mysql);
        Garage[i][gVehicle][1] = cache_get_field_content_int(i, "vehicle2", mysql);
        Garage[i][gVehicle][2] = cache_get_field_content_int(i, "vehicle3", mysql);
        Garage[i][gVehicle][3] = cache_get_field_content_int(i, "vehicle4", mysql);

        Garage_Create(i);
    }

    printf("[GARAGE] Загружено гаражей: %d", rows);
    return 1;
}

stock Garage_FindPlayer(playerid)
{
    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    for(new i = 0; i < MAX_GARAGES; i++)
    {
        if(Garage[i][gID] == 0) continue;
        if(!strcmp(Garage[i][gOwner], name, true)) return i;
    }
    return -1;
}

stock Garage_Buy(playerid, garageid)
{
    if(garageid < 0 || garageid >= MAX_GARAGES)
        return 0;

    if(Garage[garageid][gOwner][0] != EOS)
    {
        SendClientMessage(playerid, -1, "Этот гараж уже занят.");
        return 0;
    }

    if(Garage_FindPlayer(playerid) != -1)
    {
        SendClientMessage(playerid, -1, "У вас уже есть гараж.");
        return 0;
    }

    if(GetPlayerMoneyEx(playerid) < Garage[garageid][gPrice])
    {
        SendClientMessage(playerid, -1, "У вас недостаточно денег.");
        return 0;
    }

    GivePlayerMoneyEx(playerid, -Garage[garageid][gPrice], "Покупка гаража", true, true);

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));
    format(Garage[garageid][gOwner], MAX_PLAYER_NAME + 1, "%s", name);

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `garage_system` SET `owner`='%e' WHERE `id`=%d",
        name, Garage[garageid][gID]
    );
    mysql_tquery(mysql, query);

    Garage_UpdateLabel(garageid);
    SendClientMessage(playerid, 0x00FF00FF, "Поздравляем! Вы приобрели гараж.");
    return 1;
}

stock Garage_Enter(playerid, garageid)
{
    if(garageid < 0 || garageid >= MAX_GARAGES || Garage[garageid][gID] == 0)
        return 0;

    if(Garage[garageid][gOwner][0] == EOS)
    {
        SendClientMessage(playerid, -1, "Этот гараж свободен. Используйте ALT для покупки.");
        return 0;
    }

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(Garage[garageid][gOwner], name, true))
    {
        SendClientMessage(playerid, -1, "Этот гараж принадлежит другому игроку.");
        return 0;
    }

    if(PlayerGarage[playerid] != -1)
        return 1;

    GetPlayerPos(playerid, GarageReturnPos[playerid][0], GarageReturnPos[playerid][1], GarageReturnPos[playerid][2]);
    GetPlayerFacingAngle(playerid, GarageReturnAngle[playerid]);
    GarageReturnInterior[playerid] = GetPlayerInterior(playerid);
    GarageReturnWorld[playerid] = GetPlayerVirtualWorld(playerid);
    GarageReturnVehicle[playerid] = INVALID_VEHICLE_ID;

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(IsAOwnableCar(vehicleid) && GetVehicleData(vehicleid, V_ACTION_ID) >= 0)
        {
            new index = GetVehicleData(vehicleid, V_ACTION_ID);
            if(GetOwnableCarData(index, OC_OWNER_ID) == GetPlayerAccountID(playerid))
            {
                GarageReturnVehicle[playerid] = vehicleid;
                SetVehicleVirtualWorld(vehicleid, GARAGE_WORLD_BASE + Garage[garageid][gID]);
                LinkVehicleToInterior(vehicleid, GARAGE_INTERIOR);
                SetVehiclePos(vehicleid, 0.0, 0.0, 1000.0);
                SetVehicleZAngle(vehicleid, Garage[garageid][gA]);
            }
        }
    }

    SetPlayerInterior(playerid, GARAGE_INTERIOR);
    SetPlayerVirtualWorld(playerid, GARAGE_WORLD_BASE + Garage[garageid][gID]);

    if(GarageReturnVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        PutPlayerInVehicle(playerid, GarageReturnVehicle[playerid], 0);
    }
    else
    {
        SetPlayerPos(playerid, 0.0, 0.0, 1000.0);
        SetPlayerFacingAngle(playerid, 0.0);
    }

    PlayerGarage[playerid] = garageid;

    ShowPlayerDialog(
        playerid,
        GARAGE_DIALOG_ID,
        DIALOG_STYLE_LIST,
        "Гараж",
        "1. Мои автомобили\n2. Поставить автомобиль\n3. Забрать автомобиль\n4. Выйти из гаража",
        "Выбрать",
        "Закрыть"
    );
    return 1;
}

stock Garage_Exit(playerid)
{
    if(PlayerGarage[playerid] == -1)
        return 0;

    new vehicleid = GarageReturnVehicle[playerid];
    new return_interior = GarageReturnInterior[playerid];
    new return_world = GarageReturnWorld[playerid];

    // Match the player's environment before putting them back into the car.
    SetPlayerInterior(playerid, return_interior);
    SetPlayerVirtualWorld(playerid, return_world);

    if(IsValidVehicle(vehicleid))
    {
        SetVehicleVirtualWorld(vehicleid, return_world);
        LinkVehicleToInterior(vehicleid, return_interior);
        SetVehiclePos(vehicleid,
            GarageReturnPos[playerid][0],
            GarageReturnPos[playerid][1],
            GarageReturnPos[playerid][2]
        );
        SetVehicleZAngle(vehicleid, GarageReturnAngle[playerid]);
        PutPlayerInVehicle(playerid, vehicleid, 0);
    }
    else
    {
        SetPlayerPos(playerid,
            GarageReturnPos[playerid][0],
            GarageReturnPos[playerid][1],
            GarageReturnPos[playerid][2]
        );
        SetPlayerFacingAngle(playerid, GarageReturnAngle[playerid]);
    }

    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, true);

    PlayerGarage[playerid] = -1;
    GarageReturnVehicle[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

stock Garage_TryInteract(playerid)
{
    if(PlayerGarage[playerid] != -1)
        return Garage_Exit(playerid);

    for(new i = 0; i < MAX_GARAGES; i++)
    {
        if(Garage[i][gID] == 0) continue;
        if(GetPlayerInterior(playerid) != Garage[i][gInterior]) continue;
        if(GetPlayerVirtualWorld(playerid) != Garage[i][gWorld]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, Garage[i][gX], Garage[i][gY], Garage[i][gZ]))
        {
            if(Garage[i][gOwner][0] == EOS)
                return Garage_Buy(playerid, i);
            return Garage_Enter(playerid, i);
        }
    }
    return 0;
}

public Garage_Save(id)
{
    if(id < 0 || id >= MAX_GARAGES || Garage[id][gID] == 0)
        return 0;

    new query[512];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `garage_system` SET `owner`='%e', `vehicle1`=%d, `vehicle2`=%d, `vehicle3`=%d, `vehicle4`=%d WHERE `id`=%d",
        Garage[id][gOwner],
        Garage[id][gVehicle][0],
        Garage[id][gVehicle][1],
        Garage[id][gVehicle][2],
        Garage[id][gVehicle][3],
        Garage[id][gID]
    );
    mysql_tquery(mysql, query);
    return 1;
}

stock Garage_OnPlayerConnect(playerid)
{
    PlayerGarage[playerid] = -1;
    GarageReturnVehicle[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

stock Garage_OnPlayerDisconnect(playerid)
{
    // Restore the car before the mod's disconnect handler calls SaveOwnableCar().
    if(PlayerGarage[playerid] != -1)
        Garage_Exit(playerid);

    PlayerGarage[playerid] = -1;
    GarageReturnVehicle[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

stock Garage_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext

    if(dialogid != GARAGE_DIALOG_ID)
        return 0;

    if(!response)
        return 1;

    if(PlayerGarage[playerid] == -1)
        return 1;

    switch(listitem)
    {
        case 0:
            SendClientMessage(playerid, -1, "Ваши автомобили находятся в гараже.");
        case 1:
            SendClientMessage(playerid, -1, "Поставьте автомобиль в гараж.");
        case 2:
            SendClientMessage(playerid, -1, "Выберите автомобиль для выдачи.");
        case 3:
            Garage_Exit(playerid);
    }
    return 1;
}

#endif
