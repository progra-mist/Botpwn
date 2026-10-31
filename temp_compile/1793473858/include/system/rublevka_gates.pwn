// Rublevka gates system adapted from gate.pwn for the current house system.
// Gates are linked to gHousesForSale / bought_houses owners instead of the old g_house array.

#if defined _RUBLEVKA_GATES_INCLUDED
    #endinput
#endif
#define _RUBLEVKA_GATES_INCLUDED

#define MAX_RUBLEVKA_GATES              (70)
#define INVALID_RUBLEVKA_GATE_ID        (-1)
#define RUBLEVKA_GATE_DOUBLE_MODEL      (7241)
#define RUBLEVKA_GATE_SINGLE_MODEL      (7242)
#define RUBLEVKA_GATE_OPEN_TIME_MS      (5000)

enum E_RUBLEVKA_GATE_DATA
{
    RG_SQL_ID,
    RG_TYPE,
    Float:RG_GATE1_X,
    Float:RG_GATE1_Y,
    Float:RG_GATE1_Z,
    Float:RG_GATE1_ANGLE,
    Float:RG_GATE2_X,
    Float:RG_GATE2_Y,
    Float:RG_GATE2_Z,
    Float:RG_GATE2_ANGLE,
    Float:RG_ZONE_X,
    Float:RG_ZONE_Y,
    Float:RG_ZONE_Z,
    RG_OBJECT1,
    RG_OBJECT2,
    RG_AREA,
    bool:RG_IS_OPENED,
    RG_NEAREST_HOUSE_ID
};

new g_rublevka_gate[MAX_RUBLEVKA_GATES][E_RUBLEVKA_GATE_DATA];
new g_rublevka_gate_count;

new const Float:g_RublevkaInitialGateCoords[][12] =
{
    {0, -972.25,266.04,26.16,-35.0, -977.99,269.97,26.16,147.0, -975.109802,268.110626,25.564952},
    {0, -981.31,207.61,25.42,56.00, -985.21,201.90,25.42,-126.0, -983.656860,204.917953,24.822523},
    {1, -1087.87,268.21,25.56,143.2, 0,     0,     0,    0,      -1085.882812,267.158691,24.968379}, // 1 дверь
    {0, -1014.42,199.56,26.37,147.0, -1008.59,195.75,26.37,-33.0, -1011.150085,197.888442,25.770933},
    {0, -1050.70,296.34,25.72,-34.0, -1056.42,300.26,25.72,146.0, -1053.922973,297.880523,25.113557},
    {0, -1138.42,451.45,21.36,145.0, -1132.72,447.48,21.36,-35.0, -1135.271118,449.727020,20.760240},
    {1, -1205.47,547.98,18.81,118.0,  0,      0,     0,     0,    -1204.079223,546.164978,18.209592}, // 1 дверь
    {0, -1262.13,650.35,17.54,119.0, -1258.73,644.24,17.54,-61.0, -1260.025756,647.346618,16.921714},
    {0, -1297.32,708.67,17.41,121.0, -1293.63,702.65,17.41,-58.0, -1295.061035,705.669860,16.802509},
    {0, -1258.29,275.92,33.81,176.0, -1251.21,275.41,33.81,-4.0,  -1254.857299,275.269348,33.212692},
    {0, -1308.53,310.21,33.58,145.0, -1302.85,306.26,33.58,-34.0, -1306.021972,307.950347,32.984519},
    {0, -1356.85,374.00,33.50,124.0, -1352.94,368.20,33.50,-56.0, -1354.431762,371.075744,32.877708},
    {0, -1306.15,386.45,33.16,-54.0, -1310.26,392.01,33.16,127.0, -1308.610229,389.161682,32.559524},
    {0, -1389.25,423.23,32.55,121.0, -1385.70,417.31,32.55,-59.0, -1387.168457,420.497558,31.938650},
    {0, -1328.10,419.58,32.08,-59.0, -1331.62,425.54,32.08,120.0, -1330.218750,422.353057,31.478160},
    {0, -1416.20,468.69,31.79,121.0, -1412.66,462.75,31.79,-60.0, -1414.110961,466.003356,31.181919},
    {0, -1369.23,488.98,31.91,-59.0, -1372.83,494.90,31.91,121.0, -1371.352539,491.736877,31.314098},
    {1, -1458.09,542.42,31.78,121.0, 0,       0,     0,    0,     -1456.657226,540.784912,31.181507}, // 1 дверь
    {0, -1411.62,559.31,31.87,-59.0, -1415.23,565.22,31.87,121.0, -1413.757568,562.035766,31.267444},
    {0, -1518.83,643.05,32.17,121.0, -1515.22,637.15,32.17,-59.0, -1516.688354,640.314086,31.568733},
    {0, -1467.64,652.09,31.58,-59.0, -1471.18,658.03,31.58,120.0, -1469.785034,654.850646,30.963838},
    {0, -1563.82,698.53,32.17,126.0, -1560.00,693.19,31.57,-55.0, -1561.476196,695.936523,31.574047},
    {0, -1616.48,722.02,33.45,65.0,  -1619.40,715.82,33.45,-115.0,-1617.591186,718.762145,32.851882},
    {0, -1943.93,650.19,29.71,-77.0, -1945.47,656.91,29.71,103.0, -1945.084960,653.502441,29.099472},
    {0, -1978.35,630.05,29.51,104.0, -1976.71,623.32,29.51,-77.0, -1977.140747,626.770935,28.894866},
    {1, -1920.43,564.34,30.43,-72.0, 0,       0,     0,    0,     -1921.453247,566.277038,29.834266}, // 1 дверь
    {0, -1960.20,519.30,29.51,13.0,  -1966.93,517.66,29.51,-166.0,-1963.491210,518.151977,28.915008},
    {0, -1879.32,463.31,29.14,-64.0, -1882.41,469.50,29.14,117.0, -1881.160278,466.211700,28.531690},
    {0, -1983.90,458.28,30.40,-153.0,-1977.80,461.39,30.40,27.0,  -1981.020019,460.183502,29.796112},
    {0, -1859.15,420.81,29.32,-66.0, -1862.11,427.05,29.32,116.0, -1860.947387,423.834442,28.703405},
    {0, -1886.51,383.35,28.61,116.0, -1883.47,377.19,28.61,-63.0, -1884.639526,380.324066,28.014749}
};

stock RublevkaGate_FindNearestHouse(Float:x, Float:y, Float:z)
{
    new nearest_house = -1;
    new Float:min_distance = 100.0;

    for(new houseid = 0; houseid < HOUSES_FOR_SALE_COUNT; houseid++)
    {
        new Float:dx = x - gHousesForSale[houseid][0];
        new Float:dy = y - gHousesForSale[houseid][1];
        new Float:dz = z - gHousesForSale[houseid][2];
        new Float:distance = floatsqroot(dx * dx + dy * dy + dz * dz);

        if(distance < min_distance)
        {
            min_distance = distance;
            nearest_house = houseid;
        }
    }
    return nearest_house;
}

stock RublevkaGate_GetNearest(playerid)
{
    new Float:x, Float:y, Float:z;

    if(IsPlayerInAnyVehicle(playerid))
        GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
    else
        GetPlayerPos(playerid, x, y, z);

    new nearest_gate = INVALID_RUBLEVKA_GATE_ID;
    new Float:min_distance = 6.0;

    for(new gateid = 0; gateid < g_rublevka_gate_count; gateid++)
    {
        new Float:dx = x - g_rublevka_gate[gateid][RG_ZONE_X];
        new Float:dy = y - g_rublevka_gate[gateid][RG_ZONE_Y];
        new Float:dz = z - g_rublevka_gate[gateid][RG_ZONE_Z];
        new Float:distance = floatsqroot(dx * dx + dy * dy + dz * dz);

        if(distance < min_distance)
        {
            min_distance = distance;
            nearest_gate = gateid;
        }
    }
    return nearest_gate;
}

stock bool:RublevkaGate_CanPlayerOpen(playerid, gateid)
{
    if(gateid < 0 || gateid >= g_rublevka_gate_count)
        return false;

    new houseid = g_rublevka_gate[gateid][RG_NEAREST_HOUSE_ID];
    if(houseid < 0 || houseid >= HOUSES_FOR_SALE_COUNT)
        return false;

    if(!gHouseOwned[houseid])
        return false;

    new owner_account_id = gHouseOwnerID[houseid];
    if(owner_account_id <= 0)
        return false;

    if(owner_account_id == GetPlayerAccountID(playerid))
        return true;

    // Original gate.pwn allowed members of the owner's family when the owner
    // is the family leader. In the current mod leader rank is 10 and the
    // account columns are `family` / `family_rank`.
    new player_family = GetPlayerData(playerid, P_FAMILY);
    if(player_family <= 0)
        return false;

    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `family`,`family_rank` FROM `accounts` WHERE `id`=%d LIMIT 1",
        owner_account_id);

    new Cache:result = mysql_query(mysql, query, true);
    new bool:allowed = false;

    if(cache_num_rows() > 0)
    {
        new owner_family = cache_get_field_content_int(0, "family");
        new owner_family_rank = cache_get_field_content_int(0, "family_rank");

        if(owner_family > 0 && owner_family == player_family && owner_family_rank == 10)
            allowed = true;
    }

    cache_delete(result);
    return allowed;
}

stock RublevkaGate_DestroyLoaded()
{
    for(new gateid = 0; gateid < g_rublevka_gate_count; gateid++)
    {
        if(g_rublevka_gate[gateid][RG_OBJECT1] != INVALID_STREAMER_ID)
            DestroyDynamicObject(g_rublevka_gate[gateid][RG_OBJECT1]);

        if(g_rublevka_gate[gateid][RG_OBJECT2] != INVALID_STREAMER_ID)
            DestroyDynamicObject(g_rublevka_gate[gateid][RG_OBJECT2]);

        if(g_rublevka_gate[gateid][RG_AREA] != INVALID_STREAMER_ID)
            DestroyDynamicArea(g_rublevka_gate[gateid][RG_AREA]);
    }

    g_rublevka_gate_count = 0;
    return 1;
}

stock RublevkaGate_Load()
{
    RublevkaGate_DestroyLoaded();

    new Cache:result = mysql_query(mysql, "SELECT * FROM `gates` ORDER BY `id` ASC", true);
    new rows = cache_num_rows();

    if(rows > MAX_RUBLEVKA_GATES)
        rows = MAX_RUBLEVKA_GATES;

    for(new gateid = 0; gateid < rows; gateid++)
    {
        g_rublevka_gate[gateid][RG_SQL_ID] = cache_get_field_content_int(gateid, "id");
        g_rublevka_gate[gateid][RG_TYPE] = cache_get_field_content_int(gateid, "gate_type");

        g_rublevka_gate[gateid][RG_GATE1_X] = cache_get_field_content_float(gateid, "gate1_x");
        g_rublevka_gate[gateid][RG_GATE1_Y] = cache_get_field_content_float(gateid, "gate1_y");
        g_rublevka_gate[gateid][RG_GATE1_Z] = cache_get_field_content_float(gateid, "gate1_z");
        g_rublevka_gate[gateid][RG_GATE1_ANGLE] = cache_get_field_content_float(gateid, "gate1_angle");

        g_rublevka_gate[gateid][RG_GATE2_X] = cache_get_field_content_float(gateid, "gate2_x");
        g_rublevka_gate[gateid][RG_GATE2_Y] = cache_get_field_content_float(gateid, "gate2_y");
        g_rublevka_gate[gateid][RG_GATE2_Z] = cache_get_field_content_float(gateid, "gate2_z");
        g_rublevka_gate[gateid][RG_GATE2_ANGLE] = cache_get_field_content_float(gateid, "gate2_angle");

        g_rublevka_gate[gateid][RG_ZONE_X] = cache_get_field_content_float(gateid, "gatezone_x");
        g_rublevka_gate[gateid][RG_ZONE_Y] = cache_get_field_content_float(gateid, "gatezone_y");
        g_rublevka_gate[gateid][RG_ZONE_Z] = cache_get_field_content_float(gateid, "gatezone_z");

        g_rublevka_gate[gateid][RG_IS_OPENED] = false;
        g_rublevka_gate[gateid][RG_NEAREST_HOUSE_ID] = RublevkaGate_FindNearestHouse(
            g_rublevka_gate[gateid][RG_ZONE_X],
            g_rublevka_gate[gateid][RG_ZONE_Y],
            g_rublevka_gate[gateid][RG_ZONE_Z]);

        if(g_rublevka_gate[gateid][RG_TYPE] == 0)
        {
            g_rublevka_gate[gateid][RG_OBJECT1] = CreateDynamicObject(
                RUBLEVKA_GATE_DOUBLE_MODEL,
                g_rublevka_gate[gateid][RG_GATE1_X],
                g_rublevka_gate[gateid][RG_GATE1_Y],
                g_rublevka_gate[gateid][RG_GATE1_Z],
                0.0, 0.0, g_rublevka_gate[gateid][RG_GATE1_ANGLE]);

            g_rublevka_gate[gateid][RG_OBJECT2] = CreateDynamicObject(
                RUBLEVKA_GATE_DOUBLE_MODEL,
                g_rublevka_gate[gateid][RG_GATE2_X],
                g_rublevka_gate[gateid][RG_GATE2_Y],
                g_rublevka_gate[gateid][RG_GATE2_Z],
                0.0, 0.0, g_rublevka_gate[gateid][RG_GATE2_ANGLE]);
        }
        else
        {
            g_rublevka_gate[gateid][RG_OBJECT1] = CreateDynamicObject(
                RUBLEVKA_GATE_SINGLE_MODEL,
                g_rublevka_gate[gateid][RG_GATE1_X],
                g_rublevka_gate[gateid][RG_GATE1_Y],
                g_rublevka_gate[gateid][RG_GATE1_Z],
                0.0, 0.0, g_rublevka_gate[gateid][RG_GATE1_ANGLE]);

            g_rublevka_gate[gateid][RG_OBJECT2] = INVALID_STREAMER_ID;
        }

        g_rublevka_gate[gateid][RG_AREA] = CreateDynamicSphere(
            g_rublevka_gate[gateid][RG_ZONE_X],
            g_rublevka_gate[gateid][RG_ZONE_Y],
            g_rublevka_gate[gateid][RG_ZONE_Z],
            5.0);
    }

    g_rublevka_gate_count = rows;
    cache_delete(result);

    printf("[RUBLEVKA GATES] Loaded gates: %d", g_rublevka_gate_count);
    return 1;
}

public RublevkaGates_Init()
{
    new query[768];

    mysql_format(mysql, query, sizeof(query),
        "CREATE TABLE IF NOT EXISTS `gates` (" \
        "`id` INT(11) NOT NULL AUTO_INCREMENT," \
        "`gate_type` INT NOT NULL," \
        "`gate1_x` FLOAT NOT NULL," \
        "`gate1_y` FLOAT NOT NULL," \
        "`gate1_z` FLOAT NOT NULL," \
        "`gate1_angle` FLOAT NOT NULL," \
        "`gate2_x` FLOAT NOT NULL," \
        "`gate2_y` FLOAT NOT NULL," \
        "`gate2_z` FLOAT NOT NULL," \
        "`gate2_angle` FLOAT NOT NULL," \
        "`gatezone_x` FLOAT NOT NULL," \
        "`gatezone_y` FLOAT NOT NULL," \
        "`gatezone_z` FLOAT NOT NULL," \
        "PRIMARY KEY (`id`)" \
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251");

    mysql_query(mysql, query, false);

    // Seed every missing Rublevka gate separately. This also fixes servers where
    // the `gates` table already existed but was empty or only partially filled.
    for(new i = 0; i < sizeof(g_RublevkaInitialGateCoords); i++)
    {
        mysql_format(mysql, query, sizeof(query),
            "SELECT `id` FROM `gates` WHERE ABS(`gate1_x`-(%f)) < 0.02 " \
            "AND ABS(`gate1_y`-(%f)) < 0.02 AND ABS(`gate1_z`-(%f)) < 0.02 LIMIT 1",
            g_RublevkaInitialGateCoords[i][1],
            g_RublevkaInitialGateCoords[i][2],
            g_RublevkaInitialGateCoords[i][3]);

        new Cache:result = mysql_query(mysql, query, true);
        new exists = cache_num_rows();
        cache_delete(result);

        if(exists)
            continue;

        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO `gates` " \
            "(`gate_type`,`gate1_x`,`gate1_y`,`gate1_z`,`gate1_angle`," \
            "`gate2_x`,`gate2_y`,`gate2_z`,`gate2_angle`," \
            "`gatezone_x`,`gatezone_y`,`gatezone_z`) " \
            "VALUES (%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f)",
            floatround(g_RublevkaInitialGateCoords[i][0]),
            g_RublevkaInitialGateCoords[i][1],
            g_RublevkaInitialGateCoords[i][2],
            g_RublevkaInitialGateCoords[i][3],
            g_RublevkaInitialGateCoords[i][4],
            g_RublevkaInitialGateCoords[i][5],
            g_RublevkaInitialGateCoords[i][6],
            g_RublevkaInitialGateCoords[i][7],
            g_RublevkaInitialGateCoords[i][8],
            g_RublevkaInitialGateCoords[i][9],
            g_RublevkaInitialGateCoords[i][10],
            g_RublevkaInitialGateCoords[i][11]);

        mysql_query(mysql, query, false);
    }

    RublevkaGate_Load();
    return 1;
}

stock RublevkaGates_HandleArea(playerid, areaid)
{
    for(new gateid = 0; gateid < g_rublevka_gate_count; gateid++)
    {
        if(areaid != g_rublevka_gate[gateid][RG_AREA])
            continue;

        if(RublevkaGate_CanPlayerOpen(playerid, gateid))
            SendClientMessage(playerid, 0xFFFFFFFF, "Для открытия ворот используйте {FFFF00}[/opengate]");

        return 1;
    }
    return 0;
}

forward RublevkaGate_CloseTimer(gateid);
public RublevkaGate_CloseTimer(gateid)
{
    if(gateid < 0 || gateid >= g_rublevka_gate_count)
        return 1;

    if(!g_rublevka_gate[gateid][RG_IS_OPENED])
        return 1;

    if(g_rublevka_gate[gateid][RG_OBJECT1] != INVALID_STREAMER_ID)
    {
        MoveDynamicObject(
            g_rublevka_gate[gateid][RG_OBJECT1],
            g_rublevka_gate[gateid][RG_GATE1_X],
            g_rublevka_gate[gateid][RG_GATE1_Y],
            g_rublevka_gate[gateid][RG_GATE1_Z],
            7.0, 0.0, 0.0, g_rublevka_gate[gateid][RG_GATE1_ANGLE]);
    }

    if(g_rublevka_gate[gateid][RG_OBJECT2] != INVALID_STREAMER_ID)
    {
        MoveDynamicObject(
            g_rublevka_gate[gateid][RG_OBJECT2],
            g_rublevka_gate[gateid][RG_GATE2_X],
            g_rublevka_gate[gateid][RG_GATE2_Y],
            g_rublevka_gate[gateid][RG_GATE2_Z],
            7.0, 0.0, 0.0, g_rublevka_gate[gateid][RG_GATE2_ANGLE]);
    }

    g_rublevka_gate[gateid][RG_IS_OPENED] = false;
    return 1;
}

CMD:opengate(playerid)
{
    new gateid = RublevkaGate_GetNearest(playerid);

    if(gateid == INVALID_RUBLEVKA_GATE_ID)
        return SendClientMessage(playerid, 0xCECECEFF, "Рядом с Вами нет ворот.");

    if(!RublevkaGate_CanPlayerOpen(playerid, gateid))
        return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет доступа к этим воротам.");

    if(g_rublevka_gate[gateid][RG_IS_OPENED])
        return SendClientMessage(playerid, 0xCECECEFF, "Ворота уже открыты.");

    if(g_rublevka_gate[gateid][RG_OBJECT1] != INVALID_STREAMER_ID)
    {
        MoveDynamicObject(
            g_rublevka_gate[gateid][RG_OBJECT1],
            g_rublevka_gate[gateid][RG_GATE1_X],
            g_rublevka_gate[gateid][RG_GATE1_Y],
            g_rublevka_gate[gateid][RG_GATE1_Z],
            7.0, 0.0, 0.0, g_rublevka_gate[gateid][RG_GATE1_ANGLE] - 90.0);
    }

    if(g_rublevka_gate[gateid][RG_OBJECT2] != INVALID_STREAMER_ID)
    {
        MoveDynamicObject(
            g_rublevka_gate[gateid][RG_OBJECT2],
            g_rublevka_gate[gateid][RG_GATE2_X],
            g_rublevka_gate[gateid][RG_GATE2_Y],
            g_rublevka_gate[gateid][RG_GATE2_Z],
            7.0, 0.0, 0.0, g_rublevka_gate[gateid][RG_GATE2_ANGLE] + 90.0);
    }

    g_rublevka_gate[gateid][RG_IS_OPENED] = true;
    SetTimerEx("RublevkaGate_CloseTimer", RUBLEVKA_GATE_OPEN_TIME_MS, false, "i", gateid);
    return 1;
}

CMD:checkgate(playerid)
{
    new gateid = RublevkaGate_GetNearest(playerid);

    if(gateid == INVALID_RUBLEVKA_GATE_ID)
        return SendClientMessage(playerid, 0xCECECEFF, "Рядом с Вами нет ворот.");

    new message[144];
    format(message, sizeof(message),
        "Ворота: server ID %d, SQL ID %d, house ID %d.",
        gateid,
        g_rublevka_gate[gateid][RG_SQL_ID],
        g_rublevka_gate[gateid][RG_NEAREST_HOUSE_ID]);

    SendClientMessage(playerid, 0xFFFFFFFF, message);
    return 1;
}
