enum s_family_player
{
    ID_FAMILY,
    ID_SQL_FAMILY,
    STREAMER_TAG_3D_TEXT_LABEL:TEXT_FAMILY,
    RANG_FAMILY,

    MUTE_FAMILY,
    //WARN_FAMILY,

    ACCESS_GIVE,
    ACCESS_MONEY,
    ACCESS_ARMOUR,
    ACCESS_MATERIAL,
    ACCESS_HEATH_KIT,
    ACCESS_PATRON,
    ACCESS_MASK,
};

//family log
#define type_log_money  3
#define type_log_material 4
#define type_log_armour  8
#define type_log_heath_kit 6
#define type_log_patron  7
#define type_log_mask  5

#define type_log_kick 2
#define type_log_invite 1

#define type_log_car 9
#define type_log_dostup 11
#define type_log_rang 10

new player_family[MAX_PLAYERS][s_family_player];

#define GetPlayerFamily(%0,%1)  player_family[%0][%1]
#define SetPlayerFamily(%0,%1,%2)  player_family[%0][%1]=%2
#define AddPlayerFamily(%0,%1,%2,%3)  player_family[%0][%1]%2=%3
#define GetPlayerRangFamily(%0)  player_family[%0][RANG_FAMILY]
#define GetPlayerIdFamily(%0)  player_family[%0][ID_FAMILY]

new price_up_sklad[7] = {0, 100000, 200000, 500000, 800000, 1000000, 2000000};
new price_up_weapon[7] = {0, 700000, 1000000, 1200000, 1350000, 1500000, 2000000};
new price_up_compound[7] = {0, 700000, 1000000, 1500000, 2000000, 2500000, 3000000};

new count_money_level[7] = {200000, 500000, 2000000, 4000000, 8000000, 15000000, 30000000};
new count_material_level[7] = {250, 500, 1500, 3000, 6000, 12000, 15000};
new count_heath_kit_level[7] = {100, 250, 400, 500, 600, 700, 1000};
new count_mask_level[7] = {25, 50, 150, 300, 600, 1200, 1500};
new count_armour_level[7] = {100, 100, 100, 100, 100, 100, 100};

new count_weapon_level[7] = {24, 30, 29, 25, 33, 34, 31};
new count_patron_level[7] = {100000, 200000, 300000, 500000, 600000, 800000, 10000000};

new count_compound_level[7] = {100, 200, 350, 400, 500, 700, 1000};

new name_weapon_family[7][24] =
{
    {"Desert Eagle"},
    {"AK-47"},
    {"MP5"},
    {"Shotgun"},
    {"Country Rifle"},
    {"Sniper Rifle"},
    {"M4"}
};

#define FSendClientMessage(%0,%1,%2,%3,%4)	format(%0, sizeof(%0),%3,%4) && SendClientMessage(%1, %2, %0)
#define BackSendClientMessage(%0,%1,%2)	SendClientMessage(%0, %1, %2) && callcmd::family(%0)

enum s_family
{
    family_database,
    family_color,
    family_reputation,
    family_name[32],
    family_owner,
    family_slot_veh,
    family_count_veh,
    family_count_people,
    family_status_storage,
    family_money,
    family_armour,
    family_material,
    family_heath_kit,
    family_patron,
    family_mask,
    family_lvl_storage,
    family_lvl_weapon,
    family_lvl_compound,
    family_house
};

new family_type_color[18][12] =
{
    {"{af9a5b}"},   // Золотистый
    {"{b1b7f1}"},   // Лавандовый
    {"{5ba8a4}"},   // Бирюзовый
    {"{b9378f}"},   // Розовый
    {"{1028f4}"},   // Синий
    {"{5054ec}"},   // Фиолетовый
    {"{01ff23}"},   // Зеленый
    {"{f29527}"},   // Оранжевый
    {"{6c4559}"},   // Бордовый
    {"{f2dafe}"},   // Светло-розовый
    {"{7eadff}"},   // Голубой
    {"{c95eec}"},   // Пурпурный
    {"{852048}"},   // Вишневый
    {"{76b3f2}"},   // Небесный
    {"{dcb72b}"},   // Желтый
    {"{31d166}"},   // Изумрудный
    {"{3969cd}"},   // Кобальтовый
    {"{c9e8f2}"}    // Бледно-голубой
};

#define MAX_FAM  5000
new family[MAX_FAM][s_family];
new family_rang_name[MAX_FAM][5][24];
new family_rang_dostup[MAX_FAM][5][6];

#define GetFamily(%0,%1)  family[%0][%1]
#define SetFamily(%0,%1,%2)  family[%0][%1]=%2
#define AddFamily(%0,%1,%2,%3)  family[%0][%1]%2=%3

#define c_f "{D9FF00}[Семья]{FFFFFF} "
#define c_f_g "{1EFF00}[Семья]{FFFFFF} "
#define c_f_r "{FF0000}[Семья]{FFFFFF} "

#define STATUS_UNLOADED 0
#define STATUS_LOADED 1

enum s_family_vehicle
{
    OW_F_database,
    OW_F_server,
    CAR_F_database,
    V_F_NUMBER[32],
    V_F_VINYL_NAME[32],
    V_F_REGION[8],
    V_F_NUMBER_TYPE,
    V_F_MODEL,
    V_F_COLOR_1,
    V_F_COLOR_2,
    V_F_RANG,
    Float:V_F_SPAWN_X,
    Float:V_F_SPAWN_Y,
    Float:V_F_SPAWN_Z,
    Float:V_F_SPAWN_A,
    Float:V_F_SPAWN_LAST_X,
    Float:V_F_SPAWN_LAST_Y,
    Float:V_F_SPAWN_LAST_Z,
    Float:V_F_SPAWN_LAST_A,
    V_F_WORLD,
    V_F_INT,
    V_F_FSTATE,
    V_F_NITRO,
    V_F_LAUNCH,
    V_F_PDVRADAR,
    V_F_LIGHTS_COLOR,
    V_F_UNDERLIGHT_COLOR,
    V_F_UNDERLIGHT_COLOR_LF,
    V_F_UNDERLIGHT_COLOR_RT,
    V_F_IS_FAR_LIGHT_ACTIVE,
    V_F_SELECTED_PNEVMO,
    V_F_PERCENT_CLR,
    V_F_PERCENT_CLR_Z,
    V_F_IS_HYDRO_ACTIVE,
    Float:V_F_FUEL,
    Float:V_F_HEALTH,

    //addition (покупай дополнение с каптами и контами фамы)
    V_F_COUNT_BOX,
    STREAMER_TAG_3D_TEXT_LABEL:V_F_TEXT_CONT,
    V_F_AREA_CONT,
    bool:V_F_STATUS_CONT
};

new vehicle_family[MAX_OWNABLE_CARS][s_family_vehicle];

#define GetCarFamily(%0,%1)  vehicle_family[%0][%1]
#define SetCarFamily(%0,%1,%2)  vehicle_family[%0][%1]=%2
#define AddCarFamily(%0,%1,%2,%3)  vehicle_family[%0][%1]%2=%3



new f_string144[144];
new f_string64[64];
new f_string184[184];
new f_string32[32];

stock bool:FamilyParseStoredPlateValue(stored[], &plate_type, plate[], plate_size, region[], region_size)
{
    plate_type = TYPE_RU;
    if(plate_size > 0) plate[0] = '\0';
    if(region_size > 0) region[0] = '\0';

    if(!strlen(stored)) return false;

    // Ownable cars store plates as: type|number|region.
    new first = strfind(stored, "|");
    if(first != -1)
    {
        new second = strfind(stored, "|", false, first + 1);
        if(second != -1)
        {
            new type_buf[8];
            strmid(type_buf, stored, 0, first, sizeof type_buf);

            plate_type = strval(type_buf);
            if(plate_type < TYPE_RU || plate_type > TYPE_KZ) plate_type = TYPE_RU;

            strmid(plate, stored, first + 1, second, plate_size);
            strmid(region, stored, second + 1, strlen(stored), region_size);
            return strlen(plate) > 0;
        }

        // Compatibility with the temporary bridge format: number|region.
        strmid(plate, stored, 0, first, plate_size);
        strmid(region, stored, first + 1, strlen(stored), region_size);
        return strlen(plate) > 0;
    }

    format(plate, plate_size, "%s", stored);
    switch(strlen(plate))
    {
        case 8: plate_type = TYPE_UA;
        case 7: plate_type = TYPE_BY;
        default: plate_type = TYPE_RU;
    }
    return true;
}

stock FamilyBuildStoredPlateValue(plate_type, plate[], region[], dest[], size)
{
    // Keep exactly the same storage format as ownable_cars: type|number|region.
    format(dest, size, "%d|%s|%s", plate_type, plate, region);
    return 1;
}

stock FamilyNormalizeLoadedPlate(free_id)
{
    new plate_type = GetCarFamily(free_id, V_F_NUMBER_TYPE);
    new plate[32], region[16];
    format(plate, sizeof plate, "%s", vehicle_family[free_id][V_F_NUMBER]);
    format(region, sizeof region, "%s", vehicle_family[free_id][V_F_REGION]);

    new bool:changed = false;

    // Repair rows produced by the old broken bridge:
    // number='1', region='A123BC|77' (or a truncated 'A123BC|').
    new region_split = strfind(region, "|");
    if(region_split != -1 && strlen(plate) <= 2)
    {
        new old_type = strval(plate);
        new fixed_plate[32], fixed_region[8];
        strmid(fixed_plate, region, 0, region_split, sizeof fixed_plate);
        strmid(fixed_region, region, region_split + 1, strlen(region), sizeof fixed_region);

        if(old_type >= TYPE_RU && old_type <= TYPE_KZ) plate_type = old_type;
        format(plate, sizeof plate, "%s", fixed_plate);
        format(region, sizeof region, "%s", fixed_region);
        changed = true;
    }
    else
    {
        // Also accept a canonical ownable value accidentally stored in family_cars.number.
        new parsed_type, parsed_plate[32], parsed_region[8];
        if(strfind(plate, "|") != -1 && FamilyParseStoredPlateValue(plate, parsed_type, parsed_plate, sizeof parsed_plate, parsed_region, sizeof parsed_region))
        {
            plate_type = parsed_type;
            format(plate, sizeof plate, "%s", parsed_plate);
            format(region, sizeof region, "%s", parsed_region);
            changed = true;
        }
    }

    // A previous broken bridge could truncate `number|region` to something like `A123BC|`.
    // If the split produced no region, recover it from the legacy compatibility column while
    // the SELECT family_cars cache is still active.
    if(!strlen(region))
    {
        new legacy_region[8];
        cache_get_field_content(0, "plate_region", legacy_region, mysql, sizeof legacy_region);
        if(strlen(legacy_region)) format(region, sizeof region, "%s", legacy_region);
    }

    SetCarFamily(free_id, V_F_NUMBER_TYPE, plate_type);
    format(vehicle_family[free_id][V_F_NUMBER], 32, "%s", plate);
    format(vehicle_family[free_id][V_F_REGION], 8, "%s", region);

    // Keep both the donor and legacy plate columns synchronized. This also repairs old rows
    // where `region` was empty but `plate_region` still contained the correct value.
    new query[384];
    mysql_format(mysql, query, sizeof query,
        "UPDATE family_cars SET number='%e', region='%e', number_type=%d, plate_number='%e', plate_region='%e', plate_type=%d WHERE id=%d LIMIT 1",
        plate, region, plate_type, plate, region, plate_type, GetCarFamily(free_id, CAR_F_database));
    mysql_tquery(mysql, query);
    #pragma unused changed
    return 1;
}

stock FamilyEnsureColumn(const table_name[], const column_name[], const definition[])
{
    new query[512];
    format(query, sizeof query, "SHOW COLUMNS FROM `%s` LIKE '%s'", table_name, column_name);
    new Cache:result = mysql_query(mysql, query, true);
    new error_code = mysql_errno();
    if(error_code)
    {
        cache_delete(result);
        printf("[DONOR FAMILY DB][COLUMN CHECK ERROR] table=%s column=%s errno=%d", table_name, column_name, error_code);
        return 0;
    }

    new exists = cache_num_rows();
    cache_delete(result);
    if(exists) return 1;

    format(query, sizeof query, "ALTER TABLE `%s` ADD `%s` %s", table_name, column_name, definition);
    mysql_query(mysql, query, false);
    error_code = mysql_errno();
    if(error_code)
    {
        printf("[DONOR FAMILY DB][COLUMN CREATE ERROR] table=%s column=%s errno=%d query=%s", table_name, column_name, error_code, query);
        return 0;
    }
    return 1;
}

stock FamilyEnsureCoreTables()
{
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `family` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,"\
        "`owner` INT NOT NULL DEFAULT '0',"\
        "`color` INT NOT NULL DEFAULT '0',"\
        "`reputation` INT NOT NULL DEFAULT '0',"\
        "`name` VARCHAR(32) NOT NULL DEFAULT '',"\
        "`slot_veh` INT NOT NULL DEFAULT '5',"\
        "`patron` INT NOT NULL DEFAULT '0',"\
        "`material` INT NOT NULL DEFAULT '0',"\
        "`heath_kit` INT NOT NULL DEFAULT '0',"\
        "`armour` INT NOT NULL DEFAULT '0',"\
        "`arnour_count` INT NOT NULL DEFAULT '0',"\
        "`money` INT NOT NULL DEFAULT '0',"\
        "`mask` INT NOT NULL DEFAULT '0',"\
        "`level_storage` INT NOT NULL DEFAULT '1',"\
        "`level_weapon` INT NOT NULL DEFAULT '1',"\
        "`level_compound` INT NOT NULL DEFAULT '1',"\
        "`house` INT NOT NULL DEFAULT '-1',"\
        "`rang_1` VARCHAR(96) NOT NULL DEFAULT '1 ранг,0,0,0,0,0,0',"\
        "`rang_2` VARCHAR(96) NOT NULL DEFAULT '2 ранг,0,0,0,0,0,0',"\
        "`rang_3` VARCHAR(96) NOT NULL DEFAULT '3 ранг,0,0,0,0,0,0',"\
        "`rang_4` VARCHAR(96) NOT NULL DEFAULT '4 ранг,0,0,0,0,0,0',"\
        "`rang_5` VARCHAR(96) NOT NULL DEFAULT '5 ранг,1,1,1,1,1,1',"\
        "PRIMARY KEY (`id`), KEY `idx_family_owner` (`owner`), UNIQUE KEY `uniq_family_name` (`name`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        false
    );
    if(mysql_errno()) printf("[DONOR FAMILY DB][TABLE ERROR] family errno=%d", mysql_errno());

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `family_cars` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,"\
        "`family_owner` INT NOT NULL DEFAULT '0',"\
        "`model_id` INT NOT NULL DEFAULT '0',"\
        "`color_1` INT NOT NULL DEFAULT '0',"\
        "`color_2` INT NOT NULL DEFAULT '0',"\
        "`pos_x` FLOAT NOT NULL DEFAULT '0',`pos_y` FLOAT NOT NULL DEFAULT '0',`pos_z` FLOAT NOT NULL DEFAULT '0',`angle` FLOAT NOT NULL DEFAULT '0',"\
        "`pos_last_x` FLOAT NOT NULL DEFAULT '0',`pos_last_y` FLOAT NOT NULL DEFAULT '0',`pos_last_z` FLOAT NOT NULL DEFAULT '0',`angle_last` FLOAT NOT NULL DEFAULT '0',"\
        "`world` INT NOT NULL DEFAULT '0',`interior` INT NOT NULL DEFAULT '0',"\
        "`create_time` INT NOT NULL DEFAULT '0',"\
        "`number` VARCHAR(32) NOT NULL DEFAULT '',`region` VARCHAR(8) NOT NULL DEFAULT '',`number_type` INT NOT NULL DEFAULT '1',"\
        "`plate_number` VARCHAR(16) NOT NULL DEFAULT '',`plate_region` VARCHAR(8) NOT NULL DEFAULT '',`plate_type` INT NOT NULL DEFAULT '1',"\
        "`rang` INT NOT NULL DEFAULT '1',`vynil_name` VARCHAR(32) NOT NULL DEFAULT '',"\
        "`f_state` INT NOT NULL DEFAULT '0',`nitro_level` INT NOT NULL DEFAULT '0',`launch` INT NOT NULL DEFAULT '0',`pdvradar` INT NOT NULL DEFAULT '0',"\
        "`lights_color` INT NOT NULL DEFAULT '0',`underlights_color` INT NOT NULL DEFAULT '0',`underlights_color_lf` INT NOT NULL DEFAULT '0',`underlights_color_rt` INT NOT NULL DEFAULT '0',"\
        "`is_FarLight_active` INT NOT NULL DEFAULT '0',`pnevmo_selected` INT NOT NULL DEFAULT '0',`percentofclirness` INT NOT NULL DEFAULT '0',`percentofclirnessZ` INT NOT NULL DEFAULT '0',`is_hydro_active` INT NOT NULL DEFAULT '0',"\
        "`fuel` FLOAT NOT NULL DEFAULT '40',`health` FLOAT NOT NULL DEFAULT '1000',"\
        "PRIMARY KEY (`id`), KEY `idx_family_cars_owner` (`family_owner`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        false
    );
    if(mysql_errno()) printf("[DONOR FAMILY DB][TABLE ERROR] family_cars errno=%d", mysql_errno());

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `family_log` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,`family` INT NOT NULL DEFAULT '0',`player` INT NOT NULL DEFAULT '0',`to_player` INT NOT NULL DEFAULT '0',"\
        "`text` VARCHAR(192) NOT NULL DEFAULT '',`time` INT NOT NULL DEFAULT '0',`type` INT NOT NULL DEFAULT '0',"\
        "PRIMARY KEY (`id`), KEY `idx_family_log_family` (`family`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        false
    );

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `family_ad` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,`family` INT NOT NULL DEFAULT '0',`ad_text` VARCHAR(192) NOT NULL DEFAULT '',"\
        "`create_id` INT NOT NULL DEFAULT '0',`create_name` VARCHAR(24) NOT NULL DEFAULT '',`time` INT NOT NULL DEFAULT '0',"\
        "PRIMARY KEY (`id`), KEY `idx_family_ad_family` (`family`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        false
    );

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `family_storage_items` ("\
        "`family_id` INT NOT NULL DEFAULT '0',`slot` INT NOT NULL DEFAULT '0',`item_id` INT NOT NULL DEFAULT '0',"\
        "`amount` INT NOT NULL DEFAULT '1',`value` INT NOT NULL DEFAULT '0',`model_id` INT NOT NULL DEFAULT '0',"\
        "`extra_1` INT NOT NULL DEFAULT '0',`extra_2` INT NOT NULL DEFAULT '0',`old_skin` INT NOT NULL DEFAULT '0',"\
        "PRIMARY KEY (`family_id`,`slot`), KEY `idx_family_storage_family` (`family_id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=cp1251",
        false
    );

    FamilyEnsureColumn("family_storage_items", "model_id", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_storage_items", "extra_1", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_storage_items", "extra_2", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_storage_items", "old_skin", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_storage_items", "plate_type", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_storage_items", "plate_number", "VARCHAR(16) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_storage_items", "plate_region", "VARCHAR(8) NOT NULL DEFAULT ''");

    FamilyEnsureColumn("accounts", "family_id", "INT NOT NULL DEFAULT '-1'");
    FamilyEnsureColumn("accounts", "family_rang", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("accounts", "family_mute", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("accounts", "family_access", "VARCHAR(24) NOT NULL DEFAULT '0,0,0,0,0,0,0'");
    FamilyEnsureColumn("accounts", "fam_token", "INT NOT NULL DEFAULT '0'");

    FamilyEnsureColumn("family", "owner", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "color", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "reputation", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "name", "VARCHAR(32) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family", "slot_veh", "INT NOT NULL DEFAULT '5'");
    FamilyEnsureColumn("family", "patron", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "material", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "heath_kit", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "armour", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "arnour_count", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "money", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "mask", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family", "level_storage", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("family", "level_weapon", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("family", "level_compound", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("family", "house", "INT NOT NULL DEFAULT '-1'");
    FamilyEnsureColumn("family", "rang_1", "VARCHAR(96) NOT NULL DEFAULT '1 ранг,0,0,0,0,0,0'");
    FamilyEnsureColumn("family", "rang_2", "VARCHAR(96) NOT NULL DEFAULT '2 ранг,0,0,0,0,0,0'");
    FamilyEnsureColumn("family", "rang_3", "VARCHAR(96) NOT NULL DEFAULT '3 ранг,0,0,0,0,0,0'");
    FamilyEnsureColumn("family", "rang_4", "VARCHAR(96) NOT NULL DEFAULT '4 ранг,0,0,0,0,0,0'");
    FamilyEnsureColumn("family", "rang_5", "VARCHAR(96) NOT NULL DEFAULT '5 ранг,1,1,1,1,1,1'");

    FamilyEnsureColumn("family_cars", "family_owner", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "model_id", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "color_1", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "color_2", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pos_x", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pos_y", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pos_z", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "angle", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "number", "VARCHAR(32) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_cars", "vynil_name", "VARCHAR(32) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_cars", "pos_last_x", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pos_last_y", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pos_last_z", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "angle_last", "FLOAT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "region", "VARCHAR(8) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_cars", "number_type", "INT NOT NULL DEFAULT '1'");
    // Compatibility with the previous family system: old rows kept the visible plate here.
    FamilyEnsureColumn("family_cars", "plate_number", "VARCHAR(16) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_cars", "plate_region", "VARCHAR(8) NOT NULL DEFAULT ''");
    FamilyEnsureColumn("family_cars", "plate_type", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("family_cars", "rang", "INT NOT NULL DEFAULT '1'");
    FamilyEnsureColumn("family_cars", "f_state", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "nitro_level", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "launch", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pdvradar", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "lights_color", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "underlights_color", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "underlights_color_lf", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "underlights_color_rt", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "is_FarLight_active", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "pnevmo_selected", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "percentofclirness", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "percentofclirnessZ", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "is_hydro_active", "INT NOT NULL DEFAULT '0'");
    FamilyEnsureColumn("family_cars", "fuel", "FLOAT NOT NULL DEFAULT '40'");
    FamilyEnsureColumn("family_cars", "health", "FLOAT NOT NULL DEFAULT '1000'");
    return 1;
}

public:CREATE_ACCOUNTS_TABLE()
{
    FamilyEnsureCoreTables();
    EnsureFamilyCarTuningSchema();
    return 1;
}

public OnGameModeInit()
{
    for(new i;i < MAX_PLAYERS;i++) SetPlayerFamily(i, ID_FAMILY, -1);
    for(new i;i < MAX_FAM;i++) SetFamily(i, family_database, -1);
    for(new i;i < MAX_OWNABLE_CARS;i++) SetCarFamily(i, CAR_F_database, -1);

    SetTimer("CREATE_ACCOUNTS_TABLE", 300, false);
    SetTimer("welsi_LoadFamily", 1600, false);
    SetTimer("CheckMutePlayer", 1000, true);
    #if defined fam_OnGameModeInit
        return fam_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit fam_OnGameModeInit
#if defined fam_OnGameModeInit
    forward fam_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
    SetTimerEx("LoadPlayerFamily", 3000, false, "i", playerid);
    #if defined fam_OnPlayerConnect
        return fam_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect fam_OnPlayerConnect
#if defined fam_OnPlayerConnect
    forward fam_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    SetTimerEx("UnLoadPlayerFamily", 1000, false, "i", playerid);
    #if defined fam_OnPlayerDisconnect
        return fam_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect fam_OnPlayerDisconnect
#if defined fam_OnPlayerDisconnect
    forward fam_OnPlayerDisconnect(playerid, reason);
#endif

public: welsi_LoadFamily()
{
    new Cache:cache=mysql_query(mysql, "SELECT * FROM family");

    if(mysql_errno())
        return printf("[FAMILY SQL #1] LoadFamily %d", mysql_errno());

    if(!cache_num_rows())
        return print("None Cache | Query load Family");

    new rows = cache_num_rows();

    if(rows > MAX_FAM)
    {
        printf("count family (%d) > MAX_FAM (%d), extra rows skipped", rows, MAX_FAM);
        rows = MAX_FAM;
    } 

    for(new i; i < rows; i ++)
    {
        SetFamily(i, family_database, cache_get_field_content_int(i, "id"));
        SetFamily(i, family_owner, cache_get_field_content_int(i, "owner"));
        SetFamily(i, family_color, cache_get_field_content_int(i, "color"));
        SetFamily(i, family_count_veh, cache_get_field_content_int(i, "slot_veh"));
        SetFamily(i, family_reputation, cache_get_field_content_int(i, "reputation"));
        SetFamily(i, family_slot_veh, cache_get_field_content_int(i, "slot_veh"));
        cache_get_field_content(i, "name", GetFamily(i, family_name), mysql, 32);

        SetFamily(i, family_patron, cache_get_field_content_int(i, "patron"));
        SetFamily(i, family_material, cache_get_field_content_int(i, "material"));
        SetFamily(i, family_heath_kit, cache_get_field_content_int(i, "heath_kit"));
        SetFamily(i, family_armour, cache_get_field_content_int(i, "armour"));
        SetFamily(i, family_money, cache_get_field_content_int(i, "money"));

        SetFamily(i, family_lvl_storage, cache_get_field_content_int(i, "level_storage"));
        SetFamily(i, family_lvl_weapon, cache_get_field_content_int(i, "level_weapon"));
        SetFamily(i, family_lvl_compound, cache_get_field_content_int(i, "level_compound"));
        SetFamily(i, family_house, cache_get_field_content_int(i, "house"));

        new rang[5][96], name[24], setting_1,
        setting_2, setting_3, setting_4, setting_5, setting_6;

        cache_get_field_content(i, "rang_1", rang[0], mysql, sizeof(rang[]));
        cache_get_field_content(i, "rang_2", rang[1], mysql, sizeof(rang[]));
        cache_get_field_content(i, "rang_3", rang[2], mysql, sizeof(rang[]));
        cache_get_field_content(i, "rang_4", rang[3], mysql, sizeof(rang[]));
        cache_get_field_content(i, "rang_5", rang[4], mysql, sizeof(rang[]));

        for(new l;l < 5;l++)
        {
            setting_1 = setting_2 = setting_3 = setting_4 = setting_5 = setting_6 = 0;
            if(sscanf(rang[l], "P<,>s[24]dddddd", name, setting_1, setting_2, setting_3, setting_4, setting_5, setting_6))
            {
                format(name, sizeof(name), "Rank %d", l + 1);
            }
            format(family_rang_name[i][l], 24, name);
            family_rang_dostup[i][l][0] = setting_1;
            family_rang_dostup[i][l][1] = setting_2;
            family_rang_dostup[i][l][2] = setting_3;
            family_rang_dostup[i][l][3] = setting_4;
            family_rang_dostup[i][l][4] = setting_5;
            family_rang_dostup[i][l][5] = setting_6;
        }
    }

    for(new i; i < MAX_FAM;i++)
    {
        if(GetFamily(i, family_database) == -1) continue;

        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT"\
        "(SELECT COUNT(*) FROM accounts WHERE family_id = %d) AS accounts_count,"\
        "(SELECT COUNT(*) FROM family_cars WHERE family_owner = %d) AS cars_count", GetFamily(i, family_database), GetFamily(i, family_database)); //спасибо Grok
        new Cache:ccache = mysql_query(mysql, f_string184);

        if(cache_num_rows())
        {
            new count_people = cache_get_row_int(0, 0),
            count_auto = cache_get_row_int(0, 1);

            SetFamily(i, family_count_veh, count_auto);
            SetFamily(i, family_count_people, count_people);
            //printf("%d | people = %d car = %d", mysql_errno(), count_people, count_auto);
        }

        cache_delete(ccache);
    }

    cache_delete(cache);
    return 1;
}

public: UnLoadPlayerFamily(playerid)
{
    if(GetPlayerFamily(playerid, ID_FAMILY) == -1) return 1;

    UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(playerid, ID_SQL_FAMILY));
    UpdatePlayerDatabaseInt(playerid, "family_rang", GetPlayerFamily(playerid, RANG_FAMILY));
    UpdatePlayerDatabaseInt(playerid, "family_mute", GetPlayerFamily(playerid, MUTE_FAMILY));
    UpdateAccessPlayerFamily(playerid);

    SetPlayerFamily(playerid, ID_FAMILY, -1);
    SetPlayerFamily(playerid, ID_SQL_FAMILY, -1);
    
    DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(playerid, RANG_FAMILY, 0);
    SetPlayerFamily(playerid, MUTE_FAMILY, 0);
    //SetPlayerFamily(playerid, WARN_FAMILY, 0);

    SetPlayerFamily(playerid, ACCESS_GIVE, 0);
    SetPlayerFamily(playerid, ACCESS_MONEY, 0);
    SetPlayerFamily(playerid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(playerid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(playerid, ACCESS_PATRON, 0);
    SetPlayerFamily(playerid, ACCESS_MASK, 0);

    return 1;
}

/*

ALTER TABLE `accounts` ADD `family_id` INT NOT NULL DEFAULT '-1' AFTER `admin`, ADD `family_rang` INT NOT NULL DEFAULT '1' AFTER `family_id`, ADD `family_mute` INT NOT NULL AFTER `family_rang`, ADD `family_access` VARCHAR(24) NOT NULL DEFAULT '0,0,0,0,0,0,0' AFTER `family_mute`;

*/
public:LoadPlayerFamily(playerid)
{
    mysql_format(mysql, f_string64, sizeof(f_string64), "SELECT * FROM accounts WHERE id=%d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:cache=mysql_query(mysql, f_string64);

    if(mysql_errno())
        return print("[FAMILY SQL #2] LoadPlayerFamily");

    if(!cache_num_rows()) return printf("%d - none accounts", cache_num_rows());

    new access_c[7], access[24];

    new id = cache_get_field_content_int(0, "family_id");
    if(id == -1) return 1;

    for(new i; i <MAX_FAM;i++)
    {
        if(GetFamily(i, family_database) != id) continue;

        SetPlayerFamily(playerid, ID_FAMILY, i);
        break;
    }

    if(GetPlayerFamily(playerid, ID_FAMILY) == -1) return printf("None fAmily - %d", id);

    SetPlayerFamily(playerid, ID_SQL_FAMILY, id);

    SetPlayerFamily(playerid, RANG_FAMILY, cache_get_field_content_int(0, "family_rang"));
    SetPlayerFamily(playerid, MUTE_FAMILY, cache_get_field_content_int(0, "family_mute"));

    //SetPlayerFamily(playerid, WARN_FAMILY, cache_get_field_content_int(0, "family_warn"));

    cache_get_field_content(0, "family_access", access, mysql, 24);
    sscanf(access, "P<,>ddddddd", access_c[0], access_c[1], access_c[2], access_c[3], access_c[4], 
    access_c[5], access_c[6]);

    SetPlayerFamily(playerid, ACCESS_GIVE,      access_c[0]);
    SetPlayerFamily(playerid, ACCESS_MONEY,     access_c[1]);
    SetPlayerFamily(playerid, ACCESS_ARMOUR,    access_c[2]);
    SetPlayerFamily(playerid, ACCESS_MATERIAL,  access_c[3]);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, access_c[4]);
    SetPlayerFamily(playerid, ACCESS_PATRON,    access_c[5]);
    SetPlayerFamily(playerid, ACCESS_MASK,      access_c[6]);

	new familyName[64];
	format(familyName, sizeof familyName, "%s", GetFamily(GetPlayerIdFamily(playerid), family_name));
	utf8_to_cp1251(familyName); // преобразуем в cp1251

    format(f_string144, sizeof f_string144, "%sСемья:{FFFFFF} %s", family_type_color[GetFamily(GetPlayerIdFamily(playerid), family_color)], GetFamily(GetPlayerIdFamily(playerid), family_name));
    printf("%s    color %s  name %s ", f_string144, family_type_color[GetFamily(GetPlayerIdFamily(playerid), family_color)], GetFamily(GetPlayerIdFamily(playerid), family_name));
    
    if(IsValidDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY))) DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, CreateDynamic3DTextLabel(f_string144, -1, 0.0, 0.0, 0.8, 7.8, playerid));

    cache_delete(cache);
    return 1;   
}

public:CheckMutePlayer()
{
    foreach(new i : Player)
    {
        if(GetPlayerIdFamily(i) == -1) continue;
        else if(!GetPlayerFamily(i, MUTE_FAMILY)) continue;

        player_family[i][MUTE_FAMILY]--;

        if(!player_family[i][MUTE_FAMILY]) SendClientMessage(i, -1, ""c_f_r" Ваш мут в чате семьи истек. Не нарушайте больше!");
    }    

    return 1;
}

stock FamilyCreate(playerid, const source_name[])
{
    new fam_name[32];
    format(fam_name, sizeof fam_name, "%s", source_name);

    if(!(6 <= strlen(fam_name) <= 31))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Название семьи должно содержать от 6 до 31 символа.", "OK");
    if(GetPlayerIdFamily(playerid) != -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы уже состоите в семье.", "OK");
    if(GetPlayerMoneyEx(playerid) < 3_000_000)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Для создания семьи требуется 3.000.000 рублей.", "OK");

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Аккаунт ещё не загружен. Повторите попытку позже.", "OK");

    FamilyEnsureCoreTables();

    new free_id = -1;
    for(new i; i < MAX_FAM; i++)
    {
        if(GetFamily(i, family_database) != -1) continue;
        free_id = i;
        break;
    }
    if(free_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Нет свободного слота для новой семьи.", "OK");

    mysql_format(mysql, f_string184, sizeof f_string184,
        "SELECT id,owner FROM family WHERE name='%e' ORDER BY id DESC LIMIT 1", fam_name);
    new Cache:dup_cache = mysql_query(mysql, f_string184, true);
    new dup_errno = mysql_errno();
    if(dup_errno)
    {
        cache_delete(dup_cache);
        printf("[DONOR FAMILY CREATE][NAME CHECK ERROR] player=%d account=%d errno=%d", playerid, account_id, dup_errno);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Ошибка проверки названия семьи.", "OK");
    }

    new family_sql_id = 0;
    if(cache_num_rows())
    {
        new existing_owner = cache_get_field_content_int(0, "owner");
        family_sql_id = cache_get_field_content_int(0, "id");
        if(existing_owner != account_id)
        {
            cache_delete(dup_cache);
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "Такое название семьи уже занято.", "OK");
        }
    }
    cache_delete(dup_cache);

    if(family_sql_id <= 0)
    {
        mysql_format(mysql, f_string184, sizeof f_string184,
            "INSERT INTO family (owner,name) VALUES (%d,'%e')", account_id, fam_name);
        new Cache:create_cache = mysql_query(mysql, f_string184, true);
        new create_errno = mysql_errno();
        family_sql_id = cache_insert_id();
        cache_delete(create_cache);
        if(create_errno || family_sql_id <= 0)
        {
            printf("[DONOR FAMILY CREATE][INSERT ERROR] player=%d account=%d errno=%d id=%d query=%s", playerid, account_id, create_errno, family_sql_id, f_string184);
            format(f_string144, sizeof f_string144, "Не удалось создать семью. SQL ошибка: %d", create_errno);
            return ShowNotificationNew(playerid, 2, 6, 0, 0, f_string144, "OK");
        }
    }

    mysql_format(mysql, f_string184, sizeof f_string184,
        "UPDATE accounts SET family_access='1,1,1,1,1,1,1',family_id=%d,family_rang=5,family_mute=0 WHERE id=%d LIMIT 1",
        family_sql_id, account_id);
    mysql_query(mysql, f_string184, false);
    new update_errno = mysql_errno();
    if(update_errno)
    {
        printf("[DONOR FAMILY CREATE][ACCOUNT ERROR] player=%d account=%d family=%d errno=%d", playerid, account_id, family_sql_id, update_errno);
        format(f_string144, sizeof f_string144, "Семья создана, но аккаунт не привязан. SQL ошибка: %d", update_errno);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, f_string144, "OK");
    }

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family WHERE id=%d LIMIT 1", family_sql_id);
    new Cache:cache = mysql_query(mysql, f_string64, true);
    new select_errno = mysql_errno();
    if(select_errno || !cache_num_rows())
    {
        cache_delete(cache);
        printf("[DONOR FAMILY CREATE][LOAD ERROR] player=%d account=%d family=%d errno=%d", playerid, account_id, family_sql_id, select_errno);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Семья записана, но не загрузилась.", "OK");
    }

    SetFamily(free_id, family_database, family_sql_id);
    SetFamily(free_id, family_owner, account_id);
    SetFamily(free_id, family_color, cache_get_field_content_int(0, "color"));
    SetFamily(free_id, family_reputation, cache_get_field_content_int(0, "reputation"));
    SetFamily(free_id, family_slot_veh, cache_get_field_content_int(0, "slot_veh"));
    cache_get_field_content(0, "name", GetFamily(free_id, family_name), mysql, 32);
    SetFamily(free_id, family_patron, cache_get_field_content_int(0, "patron"));
    SetFamily(free_id, family_material, cache_get_field_content_int(0, "material"));
    SetFamily(free_id, family_heath_kit, cache_get_field_content_int(0, "heath_kit"));
    SetFamily(free_id, family_armour, cache_get_field_content_int(0, "armour"));
    SetFamily(free_id, family_money, cache_get_field_content_int(0, "money"));
    SetFamily(free_id, family_mask, cache_get_field_content_int(0, "mask"));
    SetFamily(free_id, family_lvl_storage, cache_get_field_content_int(0, "level_storage"));
    SetFamily(free_id, family_lvl_weapon, cache_get_field_content_int(0, "level_weapon"));
    SetFamily(free_id, family_lvl_compound, cache_get_field_content_int(0, "level_compound"));
    SetFamily(free_id, family_house, cache_get_field_content_int(0, "house"));
    SetFamily(free_id, family_count_people, 1);
    SetFamily(free_id, family_count_veh, 0);

    new rang[5][96], rank_name[24], access_1, access_2, access_3, access_4, access_5, access_6;
    cache_get_field_content(0, "rang_1", rang[0], mysql, sizeof(rang[]));
    cache_get_field_content(0, "rang_2", rang[1], mysql, sizeof(rang[]));
    cache_get_field_content(0, "rang_3", rang[2], mysql, sizeof(rang[]));
    cache_get_field_content(0, "rang_4", rang[3], mysql, sizeof(rang[]));
    cache_get_field_content(0, "rang_5", rang[4], mysql, sizeof(rang[]));
    cache_delete(cache);

    for(new l; l < 5; l++)
    {
        access_1 = access_2 = access_3 = access_4 = access_5 = access_6 = 0;
        if(sscanf(rang[l], "P<,>s[24]dddddd", rank_name, access_1, access_2, access_3, access_4, access_5, access_6))
        {
            format(rank_name, sizeof rank_name, "%d ранг", l + 1);
            if(l == 4) access_1 = access_2 = access_3 = access_4 = access_5 = access_6 = 1;
        }
        format(family_rang_name[free_id][l], 24, "%s", rank_name);
        family_rang_dostup[free_id][l][0] = access_1;
        family_rang_dostup[free_id][l][1] = access_2;
        family_rang_dostup[free_id][l][2] = access_3;
        family_rang_dostup[free_id][l][3] = access_4;
        family_rang_dostup[free_id][l][4] = access_5;
        family_rang_dostup[free_id][l][5] = access_6;
    }

    SetPlayerFamily(playerid, ID_FAMILY, free_id);
    SetPlayerFamily(playerid, ID_SQL_FAMILY, family_sql_id);
    SetPlayerFamily(playerid, RANG_FAMILY, 5);
    SetPlayerFamily(playerid, MUTE_FAMILY, 0);
    SetPlayerFamily(playerid, ACCESS_GIVE, 1);
    SetPlayerFamily(playerid, ACCESS_MONEY, 1);
    SetPlayerFamily(playerid, ACCESS_ARMOUR, 1);
    SetPlayerFamily(playerid, ACCESS_MATERIAL, 1);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, 1);
    SetPlayerFamily(playerid, ACCESS_PATRON, 1);
    SetPlayerFamily(playerid, ACCESS_MASK, 1);

    // Create/update the overhead label immediately; only the word "Семья:" uses the family color.
    format(f_string144, sizeof f_string144, "%sСемья:{FFFFFF} %s", family_type_color[GetFamily(free_id, family_color)], GetFamily(free_id, family_name));
    if(IsValidDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY)))
        DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, CreateDynamic3DTextLabel(f_string144, -1, 0.0, 0.0, 0.8, 7.8, playerid));

    GivePlayerMoneyEx(playerid, -3_000_000);
    printf("[DONOR FAMILY CREATE][SUCCESS] player=%d account=%d family=%d slot=%d name=%s", playerid, account_id, family_sql_id, free_id, fam_name);
    format(f_string144, sizeof f_string144, "Вы успешно создали семью %s", fam_name);
    ShowNotificationNew(playerid, 2, 6, 0, 0, f_string144, "OK");
    callcmd::family(playerid);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new f = GetPlayerIdFamily(playerid);

    if(dialogid == 2223)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerFamily(playerid, RANG_FAMILY) >= 4)
                    {
                        new status = GetFamily(f, family_status_storage);

                        SetFamily(f, family_status_storage, status^1);

                        format(f_string144, sizeof f_string144, "%s %s склад.", GetPlayerNameEx(playerid), status ? "закрыл" : "открыл");
                        SendFamilyMessage(f, f_string144);
                        ShowFamilyLegacyStorageMenu(playerid);
                    }
                    else SendClientMessage(playerid,-1,""c_f_r"Закрывать/открывать склад доступно только заместителю или лидеру семьи");
                }
                case 1:
                {
                    if(!GetFamily(f, family_status_storage) && GetPlayerFamily(playerid, RANG_FAMILY) < 5)
                        return SendClientMessage(playerid, -1,""c_f_r"Склад закрыт.");

                    ShowDialogFamilySklad(playerid, 1, false);
                }
                case 2:ShowDialogFamilySklad(playerid, 1, true);
                case 3:
                {
                    DeletePVar(playerid, "select_get_dostup");

                    if(GetPlayerFamily(playerid, ACCESS_GIVE) || GetPlayerRangFamily(playerid) == 5)
                    {
                        ShowPlayerDialog
                        (
                            playerid, 2230, DIALOG_STYLE_LIST,
                            "{FF000}Доступа",
                            "1. Выдать доступ\n"\
                            "2. Забрать доступ\n"\
                            "3. Просмотр доступов",
                            "Далее", "Назад"
                        );
                    }
                }
            }
        }
    }
    if(dialogid == 2225)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "type_sklad"))
            {
                new type_take_or_put;

                switch(GetPVarInt(playerid, "type_sklad"))
                {
                    case 1:type_take_or_put = false;
                    case 2:type_take_or_put = true;
                }

                SetPVarInt(playerid, "type_action_sklad", type_take_or_put+1);
                ShowDialogFamilySklad(playerid, listitem+2, type_take_or_put);
            }
        }
    }
    if(dialogid == 2226)
{
    if(response)
    {
        new take_or_put = GetPVarInt(playerid, "type_action_sklad")-1, type = GetPVarInt(playerid, "select_type_sklad_use");

        switch(type)
        {
            case 2:
            {
                new money = strval(inputtext);

                if(!money)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                if(!take_or_put)
                {
                    if(money <= GetFamily(f, family_money))
                    {
                        if(!GetPlayerFamily(playerid, ACCESS_MONEY))
                            return SendClientMessage(playerid, -1, "У вас нет доступа.");

                        new money_access = GetPlayerFamily(playerid, ACCESS_MONEY)-money; 

                        if(money_access <= -1 && GetPlayerRangFamily(playerid) != 5)
                            return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_MONEY));

                        AddPlayerFamily(playerid, ACCESS_MONEY, -, money);
                        AddFamily(f, family_money, -, money);
                        GivePlayerMoneyEx(playerid, money);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи деньги.");
                        format(f_string144, sizeof f_string144, "%s взял из склада %d рублей.", GetPlayerNameEx(playerid), money);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                        SendFamilyLog(type_log_money, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                }
                else
                {
                    if(!(GetFamily(f, family_money)+money <= count_money_level[GetFamily(f, family_lvl_storage)-1]))
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                    if(money <= GetPlayerMoneyEx(playerid))
                    {
                        AddFamily(f, family_money, +, money);
                        GivePlayerMoneyEx(playerid, -money);
                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи деньги.");
                        format(f_string144, sizeof f_string144, "%s положил на склад %d рублей.", GetPlayerNameEx(playerid), money);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                        SendFamilyLog(type_log_money, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                }
            }
            case 3:
            {
                new material = strval(inputtext);

                if(!material)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                if(!take_or_put)
                {
                    if(material <= GetFamily(f, family_material))
                    { 
                        if(!GetPlayerFamily(playerid, ACCESS_MATERIAL))
                            return SendClientMessage(playerid, -1, "У вас нет доступа.");

                        new material_access = GetPlayerFamily(playerid, ACCESS_MATERIAL)-material; 

                        if(material_access <= -1 && GetPlayerRangFamily(playerid) != 5)
                            return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_MATERIAL));

                        AddPlayerFamily(playerid, ACCESS_MATERIAL, -, 1);

                        AddFamily(f, family_material, -, material);
                        AddPlayerData(playerid, P_METALL, +, material);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи материалы.");
                        format(f_string144, sizeof f_string144, "%s взял из склада %d шт. материалов.", GetPlayerNameEx(playerid), material);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "material", GetFamily(f, family_material));
                        SendFamilyLog(type_log_material, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                }
                else
                {
                    if(!(GetFamily(f, family_material)+material <= count_material_level[GetFamily(f, family_lvl_storage)-1]))
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");
                            
                    if(material <= GetPlayerData(playerid, P_METALL))
                    {
                        AddFamily(f, family_material, +, material);
                        AddPlayerData(playerid, P_METALL, -, material);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи материалы.");
                        format(f_string144, sizeof f_string144, "%s положил на склад %d шт. материалов.", GetPlayerNameEx(playerid), material);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "material", GetFamily(f, family_material));
                        SendFamilyLog(type_log_material, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                }
            }
            case 4:
            {
                if(!take_or_put)
                {
                    if(GetFamily(f, family_material))
                    {
                        if(!GetPlayerFamily(playerid, ACCESS_MASK) && GetPlayerRangFamily(playerid) != 5)
                            return SendClientMessage(playerid, -1, "У вас нет доступа.");
                            
                        AddPlayerFamily(playerid, ACCESS_MASK, -, 1);

                        AddFamily(f, family_material, -, 1);
                        AddPlayerData(playerid, P_MASK, +, 1);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи маску.");
                        format(f_string144, sizeof f_string144, "%s взял из склада маску.", GetPlayerNameEx(playerid));
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "mask", GetFamily(f, family_mask));
                        SendFamilyLog(type_log_mask, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                }
                else
                {
                    if(!(GetFamily(f, family_mask)+1 <= count_material_level[GetFamily(f, family_lvl_storage)-1]))
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                    if(GetPlayerData(playerid, P_MASK))
                    {
                        AddFamily(f, family_mask, +, 1);
                        AddPlayerData(playerid, P_MASK, -, 1);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи маску.");
                        format(f_string144, sizeof f_string144, "%s положил на склад маску.", GetPlayerNameEx(playerid));
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "mask", GetFamily(f, family_mask));
                        SendFamilyLog(type_log_mask, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                }
            }
            case 5:
            {
                if(!take_or_put)
                {
                    switch(listitem)
                    {
                        case 0:
                        {
                            ShowPlayerDialog
                            (
                                playerid, -1, DIALOG_STYLE_MSGBOX, 
                                "{FF0000}Информация",
                                "На первом уровне улучшения оружия на складе доступен {FFFF00}Desert Eagle\n"\
                                "{FFFFFF}На втором уровне {FFFF00}AK-47\n"\
                                "{FFFFFF}На третьем уровне {FFFF00}MP5\n"\
                                "{FFFFFF}На четветром уровне {FFFF00}Shotgun\n"\
                                "{FFFFFF}На пятом уровне {FFFF00}Country Rifle\n"\
                                "{FFFFFF}На шестом уровне {FFFF00}Sniper Rifle\n"\
                                "{FFFFFF}На седьмом уровне {FFFF00}M4",
                                "Выйти", ""
                            );
                        }
                        case 1:
                        {
                            if(!GetPlayerFamily(playerid, ACCESS_PATRON) && GetPlayerRangFamily(playerid) < 5)
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");

                            new dialog[234], weapon[26];

                            for(new i; i < GetFamily(f, family_lvl_weapon); i++)
                            {
                                format(weapon, sizeof weapon, "%d. %s\n", i+1, name_weapon_family[i]);
                                strcat(dialog, weapon);
                            }

                           ShowPlayerDialog(playerid, 2227, DIALOG_STYLE_LIST, "{FF0000}Выберите оружие", dialog, "Далее", "Выйти");

                            if(GetPVarInt(playerid, "select_weapon")) DeletePVar(playerid, "select_weapon");
                            if(GetPVarInt(playerid, "select_weapon_count")) DeletePVar(playerid, "select_weapon_count");
                            SetPVarInt(playerid, "select_weapon", 1);
                        }
                    }
                }
                else
                {
                    switch(listitem)
                    {
                        case 0:
                        {
                            ShowPlayerDialog
                            (
                                playerid, -1, DIALOG_STYLE_MSGBOX, 
                                "{FF0000}Информация",
                                "На первом уровне улучшения оружия на складе доступен {FFFF00}Desert Eagle\n"\
                                "{FFFFFF}На втором уровне {FFFF00}AK-47\n"\
                                "{FFFFFF}На третьем уровне {FFFF00}MP5\n"\
                                "{FFFFFF}На четветром уровне {FFFF00}Shotgun\n"\
                                "{FFFFFF}На пятом уровне {FFFF00}Country Rifle\n"\
                                "{FFFFFF}На шестом уровне {FFFF00}Sniper Rifle\n"\
                                "{FFFFFF}На седьмом уровне {FFFF00}M4",
                                "Выйти", ""
                            );
                        }
                        case 1:
                        {
                            ShowPlayerDialog
                            (
                                playerid, 2227, DIALOG_STYLE_INPUT, 
                                "{FF0000}Введите количество",
                                "Введите кол-во патронов которые хотите положить на склад",
                                "Далее", "Назад"
                            );
                        }
                    }
                }
            }
            case 6:
            {
                if(!take_or_put)
                {
                    if(GetFamily(f, family_armour))
                    {
                        if(!GetPlayerFamily(playerid, ACCESS_ARMOUR) && GetPlayerRangFamily(playerid) != 5)
                            return SendClientMessage(playerid, -1, "У вас нет доступа.");
                            
                        AddPlayerFamily(playerid, ACCESS_ARMOUR, -, 1);

                        AddFamily(f, family_armour, -, 1);
                        SetPlayerArmour(playerid, 100.0);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи бронежилет.");
                        format(f_string144, sizeof f_string144, "%s взял из склада бронежилет.", GetPlayerNameEx(playerid));
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "armour", GetFamily(f, family_armour));
                        SendFamilyLog(type_log_armour, playerid, -1, f_string144);
                    }
                    else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                }
                else
                {
                    if(!(GetFamily(f, family_armour)+1 <= count_armour_level[GetFamily(f, family_lvl_storage)-1]))
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                    AddFamily(f, family_armour, +, 1);
                    SetPlayerArmour(playerid, 0.0);

                    SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи бронежилет.");
                    format(f_string144, sizeof f_string144, "%s положил на склад бронежилет.", GetPlayerNameEx(playerid));
                    SendFamilyMessage(f, f_string144);
                    UpdateColumnFamilyInt(GetFamily(f, family_database), "armour", GetFamily(f, family_armour));
                    SendFamilyLog(type_log_armour, playerid, -1, f_string144);
                }
            }
            case 7:
            {
                if(!take_or_put)
                {
                    if(!GetFamily(f, family_heath_kit))
                        return SendClientMessage(playerid, -1, ""c_f_r"У семьи нет аптечек.");
                    if(!GetPlayerFamily(playerid, ACCESS_HEATH_KIT) && GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, "У вас нет доступа.");

                    new inv_slot = Inventory11_AddItemToDatabase(playerid, 22, 1, 1, 0, 0);
                    if(inv_slot == -1)
                        return SendClientMessage(playerid, -1, ""c_f_r"Не удалось добавить аптечку: нет места или превышен вес.");

                    AddFamily(f, family_heath_kit, -, 1);
                    SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи аптечку.");
                    format(f_string144, sizeof f_string144, "%s взял из склада аптечку.", GetPlayerNameEx(playerid));
                    SendFamilyMessage(f, f_string144);
                    UpdateColumnFamilyInt(GetFamily(f, family_database), "heath_kit", GetFamily(f, family_heath_kit));
                    SendFamilyLog(type_log_heath_kit, playerid, -1, f_string144);
                }
                else
                {
                    new storage_level = GetFamily(f, family_lvl_storage);
                    if(storage_level < 1) storage_level = 1;
                    if(storage_level > sizeof(count_heath_kit_level)) storage_level = sizeof(count_heath_kit_level);
                    if(GetFamily(f, family_heath_kit) + 1 > count_heath_kit_level[storage_level - 1])
                        return SendClientMessage(playerid, -1, ""c_f_r"На складе достигнут лимит аптечек.");

                    new account_id = GetPlayerAccountID(playerid);
                    new query[196];
                    mysql_format(mysql, query, sizeof query,
                        "SELECT slot,amount FROM inventory WHERE account_id=%d AND item_id=22 ORDER BY slot ASC LIMIT 1", account_id);
                    new Cache:med_cache = mysql_query(mysql, query, true);
                    if(mysql_errno() || !cache_num_rows())
                    {
                        cache_delete(med_cache);
                        return SendClientMessage(playerid, -1, ""c_f_r"У вас нет аптечки.");
                    }
                    new med_slot = cache_get_field_content_int(0, "slot");
                    new med_amount = cache_get_field_content_int(0, "amount");
                    cache_delete(med_cache);

                    if(med_amount > 1)
                    {
                        mysql_format(mysql, query, sizeof query,
                            "UPDATE inventory SET amount=%d,model_id=%d WHERE account_id=%d AND slot=%d LIMIT 1",
                            med_amount - 1, med_amount - 1, account_id, med_slot);
                        mysql_query(mysql, query, false);
                    }
                    else Inventory11_DeleteSlotFromDatabase(playerid, med_slot);

                    if(mysql_errno())
                        return SendClientMessage(playerid, -1, ""c_f_r"Ошибка сохранения инвентаря.");

                    AddFamily(f, family_heath_kit, +, 1);
                    SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи аптечку.");
                    format(f_string144, sizeof f_string144, "%s положил на склад аптечку.", GetPlayerNameEx(playerid));
                    SendFamilyMessage(f, f_string144);
                    UpdateColumnFamilyInt(GetFamily(f, family_database), "heath_kit", GetFamily(f, family_heath_kit));
                    SendFamilyLog(type_log_heath_kit, playerid, -1, f_string144);
                }
                SetPVarInt(playerid, "select_type_sklad_use", 7);
            }
        }
    }
}
    if(dialogid == 2227)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_weapon"))
            {
                if(!GetPVarInt(playerid, "select_weapon_count"))
                {
                    SetPVarInt(playerid, "weapon_select_id", listitem);

                    format(f_string144, sizeof f_string144, "Введите нужное кол-во патронов, доступно %d", GetFamily(f, family_patron));

                    ShowPlayerDialog
                    (
                        playerid, 2227, DIALOG_STYLE_INPUT, 
                        "{FF0000}Введите количество",
                        f_string144,
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_weapon_count", 1);
                    return 1;
                }

                new id = GetPVarInt(playerid, "weapon_select_id");

                new patron = strval(inputtext);

                if(!patron)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                if(patron > 1000)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть меньше 1000");

                if(GetFamily(f, family_patron) >= patron)
                {
                    new patron_access = GetPlayerFamily(playerid, ACCESS_PATRON) - patron;

                    if(patron_access <= -1 && GetPlayerRangFamily(playerid) != 5) return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_PATRON));
                    
                    AddPlayerFamily(playerid, ACCESS_PATRON, -, patron);

                    AddFamily(f, family_patron, -, patron);
                    //SetPlayerAmmo(playerid, count_weapon_level[listitem], patron);
                    GivePlayerWeapon(playerid, count_weapon_level[id], patron);

                    SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склад семьи оружие и патроны.");
                    format(f_string144, sizeof f_string144, "%s взял из склада %s и %d патрон.", GetPlayerNameEx(playerid), name_weapon_family[id], patron);
                    SendFamilyMessage(f, f_string144);
                    SendFamilyLog(type_log_patron, playerid, -1, f_string144);
                    UpdateColumnFamilyInt(GetFamily(f, family_database), "patron", GetFamily(f, family_patron));
                }

                return 1;
            }

            new patron = strval(inputtext);

            if(!patron)
                return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

            new weapon = GetPlayerWeapon(playerid);
            
            switch(weapon)
            {
                case 0:return SendClientMessage(playerid, -1, ""c_f_r"Возьмите оружие в руки.");
                case 24, 30, 29, 25, 33, 34, 31:
                {
                    if(!(GetFamily(f, family_patron)+patron <= count_patron_level[GetFamily(f, family_lvl_weapon)-1]))
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                    new weapon_id = -1, ammo;

                    for(new i; i < 12;i++)
                    {
                        GetPlayerWeaponData(playerid, i, weapon_id, ammo);

                        if(weapon_id == weapon) break;
                    }    

                    if(weapon_id == -1) return 1;

                    if(ammo >= patron)
                    {
                        new ammo_new = ammo - patron;

                        AddFamily(f, family_patron, +, patron);
                        //SetPlayerAmmo(playerid, weapon_id, ammo_new);
                        ResetPlayerWeapons(playerid);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи патроны.");
                        format(f_string144, sizeof f_string144, "%s положил на склад %d патрон.", GetPlayerNameEx(playerid), patron);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "patron", GetFamily(f, family_patron));
                    }
                    else SendClientMessage(playerid, -1, ""c_f_g"У вас нету такого кол-во патрон.");
                }
                default:return SendClientMessage(playerid, -1, ""c_f_r"Ваше оружие не подходит чтобы положить патроны на склад");
            }
        }
    }
    if(dialogid == 2230)
    {
        if(GetPVarInt(playerid, "select_get_dostup"))
        {
            new Name[24], e, to_player = -1, string[234];

            if(sscanf(inputtext, "s[24]", Name))e++ ;
            else if(sscanf(inputtext, "d", to_player))e++;

            if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

            if(to_player == -1)
            {
                if(!strcmp(Name, GetPlayerNameEx(playerid), true))
                    return 1;

                foreach(new i : Player)
                {
                    if(!strcmp(Name, GetPlayerNameEx(i), true))
                    {
                        if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;
                        to_player = i;
                        break;
                    }
                }
            }

            if(!IsPlayerConnected(to_player))
                return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

            format(string, sizeof string,
            "Никнейм:%s\n"\
            "Доступ на изменение доступов: %s\n"\
            "Доступ к деньгам: %d\n"\
            "Доступ к материалам: %d\n"\
            "Доступ к маскам: %d\n"\
            "Доступ к аптечкам: %d\n"\
            "Доступ к оружию: %d\n"\
            "Доступ к бронежилетам: %d",
            GetPlayerNameEx(to_player), GetPlayerFamily(to_player, ACCESS_GIVE) ? "Есть" : "Нет",
            GetPlayerFamily(to_player, ACCESS_MONEY),
            GetPlayerFamily(to_player, ACCESS_MATERIAL),
            GetPlayerFamily(to_player, ACCESS_MASK),
            GetPlayerFamily(to_player, ACCESS_HEATH_KIT),
            GetPlayerFamily(to_player, ACCESS_PATRON),
            GetPlayerFamily(to_player, ACCESS_ARMOUR));

           ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "{FF0000}Информация доступов", string, "Выйти","");
            return 1;
        }

        DeletePVar(playerid, "status_dialog_access");
        DeletePVar(playerid, "type_dialog_access");
        if(response)
        {
            switch(listitem)
            {
                case 0:ShowDialogAccess(playerid, 1, true);
                case 1:ShowDialogAccess(playerid, 1, false);
                case 2:
                {
                    ShowPlayerDialog
                    (
                        playerid, 2230, DIALOG_STYLE_INPUT,
                        "Просмотр доступов",
                        "Введите имя или ID игрока для просмотра доступа",
                        "Далее",
                        "Назад"
                    );
                    
                    SetPVarInt(playerid, "select_get_dostup", 1);
                }
            }
        }
    }
    if(dialogid == 2231)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "status_dialog_access"))
            {
                new give = GetPVarInt(playerid, "status_dialog_access")-1;

                if(GetPVarInt(playerid, "type_dialog_access"))
                {
                    new Name[24], e, to_player = -1, count, give_text[10];

                    if(give) 
                    {
                        format(give_text, sizeof give_text, "выдал");
                        if(sscanf(inputtext, "P<,>s[24]d", Name, count)) e++;
                        else if(sscanf(inputtext, "P<,>dd", to_player, count))e++;
                    } 
                    else {
                        format(give_text, sizeof give_text, "забрал");
                        if(sscanf(inputtext, "s[24]", Name))e++ ;
                        else if(sscanf(inputtext, "d", to_player))e++;
                    } 

                    if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

                    if(count > 200_000_000) return SendClientMessage(playerid, -1, ""c_f_r"Количество должно быть больше 200.000.000");

                    if(to_player == -1)
                    {
                        if(!strcmp(Name, GetPlayerNameEx(playerid), true)) return 1;

                        foreach(new i : Player)
                        {
                            if(!strcmp(Name, GetPlayerNameEx(i), true))
                            {
                                if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;

                                to_player = i;
                                break;
                            }
                        }
                    }

                    if(!IsPlayerConnected(to_player))
                        return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                    new type = GetPVarInt(playerid, "type_dialog_access")-2;

                    switch(type)
                    {
                        case 0:
                        {
                            SetPlayerFamily(to_player, ACCESS_ARMOUR, count);
                            SetPlayerFamily(to_player, ACCESS_MONEY, count);
                            SetPlayerFamily(to_player, ACCESS_HEATH_KIT, count);
                            SetPlayerFamily(to_player, ACCESS_PATRON, count);
                            SetPlayerFamily(to_player, ACCESS_MASK, count);
                            SetPlayerFamily(to_player, ACCESS_MATERIAL, count);
                            SetPlayerFamily(to_player, ACCESS_GIVE, give);
                            format(f_string144, sizeof f_string144, "%s %s %s все доступа", GetPlayerNameEx(playerid), give_text,GetPlayerNameEx(to_player));
                        }
                        case 1:
                        {
                            SetPlayerFamily(to_player, ACCESS_GIVE, give);
                            format(f_string144, sizeof f_string144, "%s %s %s доступ на выдачу доступа", GetPlayerNameEx(playerid), give_text, GetPlayerNameEx(to_player));
                        }
                        case 2:SetPlayerFamily(to_player, ACCESS_MONEY, count);
                        case 3:SetPlayerFamily(to_player, ACCESS_MATERIAL, count);
                        case 4:SetPlayerFamily(to_player, ACCESS_MASK, count);
                        case 5:SetPlayerFamily(to_player, ACCESS_HEATH_KIT, count);
                        case 6:SetPlayerFamily(to_player, ACCESS_PATRON, count);
                        case 7:SetPlayerFamily(to_player, ACCESS_ARMOUR, count);
                    }

                    new dostup[8][24] = {"", "", "деньги", "материалы", "маски", "аптечки", "оружие", "бронижелет"};

                    if(2 <= type <= 7) format(f_string144, sizeof f_string144, "%s %s %s доступ на %s в кол-во %d", GetPlayerNameEx(playerid), give_text, GetPlayerNameEx(to_player), dostup[type], count);
                    SendFamilyLog(type_log_dostup, playerid, to_player, f_string144);

                    format(f_string144, sizeof f_string144, "%s[%d] изменил настройки доступа %s[%d]", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(to_player), to_player);
                    SendFamilyMessage(f, f_string144);

                    UpdateAccessPlayerFamily(to_player);
                }   
                else ShowDialogAccess(playerid, listitem+2, give);
            }
        }
    }
    
    if(dialogid == 2236)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_type_2236"))
            {
                new id_p, count, prichina[16];
                switch(GetPVarInt(playerid, "select_type_2236"))
                {
                    case 1:callcmd::faminvite(playerid, inputtext);
                    case 2:
                    {
                        if(0 <= listitem <= 1 && GetPVarInt(playerid, "prichina") == 0) return ShowMembersFamily(playerid, listitem);

                        new id = GetPlayerListitemValue(playerid, listitem), name[24];

                        format(f_string32, sizeof f_string32, "p_familyrang%d", listitem);
                    
                        if(GetPVarInt(playerid, f_string32) >= GetPlayerRangFamily(playerid))
                            return SendClientMessage(playerid, -1, ""c_f_r"Игрок выше вас рангом.");

                        //printf("rang = %d || rang = %d || id = %d ", GetPVarInt(playerid, f_string32), GetPlayerRangFamily(playerid))

                        format(f_string32, sizeof f_string32, "p_familyname%d", listitem);
                        GetPVarString(playerid, f_string32, name, 24);

                        if(!GetPVarInt(playerid, "prichina")) 
                        { 
                           ShowPlayerDialog(
                                playerid, 2236, DIALOG_STYLE_INPUT,
                                "{FF0000}Выгнать игрока",
                                "Напишите причину для того чтобы выгнать игрока",
                                "Далее","Назад"
                            );
                            SetPVarInt(playerid, "family_player_id", id);
                            SetPVarString(playerid, "family_playername", name);
                            SetPVarInt(playerid, "prichina", 1);
                            SetPVarInt(playerid, "select_type_2326", 2);  
                            return 1; 

                        }
                        else
                        {
                            if(sscanf(inputtext, "s[16]", prichina) || strlen(inputtext) < 5)
                            {
                                SendClientMessage(playerid, -1, ""c_f_r"Причина может быть от 5 до 16 символов");
                                return ShowMembersFamily(playerid, 1);
                            } 
                        }

                        new param[24];

                        id = GetPVarInt(playerid, "family_player_id");
                        GetPVarString(playerid, "family_playername", name, sizeof name);

                        foreach(new i : Player)
                        {
                            if(GetPlayerAccountID(i) != id) continue;
                            format(param, sizeof param, "%d %s", i, prichina);
                            callcmd::unfaminvite(playerid, param);
                            return 1;
                        }

                        mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=-1 WHERE id = %d", id);
                        mysql_query(mysql, f_string144, false);

                        if(!mysql_errno())
                        {
                            format(f_string144, sizeof f_string144, "%s выгнал игрока %s. Причина: %s (оффлайн)", GetPlayerNameEx(playerid), name, prichina);
                            SendFamilyMessage(f, f_string144);
                            SendFamilyLog(type_log_kick, playerid, id, f_string144);
                        }
                    }
                    case 3:
                    {
                        if(sscanf(inputtext, "P<,>dds[12]", id_p, count, prichina))
                         return SendClientMessage(playerid, -1, ""c_f_g"Вы не правильно ввели параметры.");
                        
                        format(inputtext, 18, "%d %d %s", id_p, count, prichina);
                        callcmd::fammute(playerid, inputtext);
                    }
                    case 4:
                    {
                        if(sscanf(inputtext, "P<,>ds[12]", id_p, prichina))
                         return SendClientMessage(playerid, -1, ""c_f_g"Вы не правильно ввели параметры.");

                        format(inputtext, 16, "%d %s", id_p, prichina);
                        callcmd::unfammute(playerid, inputtext);
                    }
                    case 5:
                    {
                        new Name[24], e, to_player = -1, rang;

                        if(sscanf(inputtext, "P<,>s[24]d", Name, rang))e++ ;
                        else if(sscanf(inputtext, "P<,>dd", to_player, rang))e++;

                        if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

                        if(to_player == -1)
                        {
                            if(!strcmp(Name, GetPlayerNameEx(playerid), true, sizeof Name)) return 1;

                            foreach(new i : Player)
                            {
                                if(!strcmp(Name, GetPlayerNameEx(i), true))
                                {
                                    if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;
                                    to_player = i;
                                    break;
                                }
                            }
                        }

                        if(!IsPlayerConnected(to_player) || to_player == playerid)
                            return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                        if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2])
                            return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно изменять ранги.");

                        if(rang >= GetPlayerRangFamily(playerid))
                            return SendClientMessage(playerid, -1, ""c_f_r"Невозможно выдать тот же ранг как у Вас или выше.");

                        if(GetPlayerIdFamily(to_player) != f)
                            return SendClientMessage(playerid, -1, ""c_f_r"Игрок не в вашей семье.");

                        SetPlayerFamily(to_player, RANG_FAMILY, rang);
                        UpdatePlayerDatabaseInt(to_player, "family_rang", rang);
                        
                        format(f_string144, sizeof f_string144, "%s выдал игроку %s - %s (%d ранг).", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player),
                        family_rang_name[f][rang-1], rang);
                        SendFamilyMessage(f, f_string144);
                        SendFamilyLog(type_log_rang, playerid, to_player, f_string144);
                        return 1;
                    }
                }
                return 1;
            }

            switch(listitem)
            {
                case 0:
                {
                    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу это не доступно.");
                    ShowPlayerDialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Принять игрока",
                        "Введите ID игрока снизу чтобы принять игрока.",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 1);
                }
                case 1:
                {
                    DeletePVar(playerid, "count_list");

                    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу это не доступно.");


                    ShowMembersFamily(playerid, 0);
                }
                case 2:
                {
                    ShowPlayerDialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Выдать мут",
                        "Введите ID игрока, кол-во минут, причину (до 12 симвл.), снизу \n"\
                        "чтобы выдать мут игроку.\n"\
                        "- Пример: 0, 25, Оск.",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 3);
                }
                case 3:
                {
                    ShowPlayerDialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Снять мут",
                        "Введите ID игрока, причину (до 12 симвл.) снизу чтобы снять мут игроку\n"\
                        "- Пример: 0, Заплатил",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 4);
                }
                case 4:
                {
                    ShowPlayerDialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Изменить ранг",
                        "Введите ID игрока или имя игрока и ранг через запятую\n"\
                        "- Ранг - это какой ранг выдать игроку.\n"\
                        "- Пример: Nick_Name, 2",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 5);
                }
            }
        }
    }
    if(dialogid == 2237)
    {
        if(!response) return 1;

        new type = GetPVarInt(playerid, "select_type_log");

        if(!type)
        {
            SetPVarInt(playerid, "select_type_log", listitem+1);

            type = GetPVarInt(playerid, "select_type_log");

            mysql_format(mysql, f_string184, sizeof f_string184, "SELECT * FROM family_log WHERE family ='%d' AND type = %d", GetFamily(GetPlayerIdFamily(playerid), family_database), type);
            new Cache:result = mysql_query(mysql, f_string184, true);

            new c = cache_num_rows();
            
            new r = c;

            if(!c) return SendClientMessage(playerid, -1, ""c_f_r"Логи не найдены.");

            new dialog[sizeof f_string184 * 10], text[124], time_data[24];

            if(c > 10) c = 10;

            for(new i, time; i < c; i++)
            {
                time = cache_get_field_content_int(i, "time");
                cache_get_field_content(i, "text", text);

                format(time_data, sizeof time_data, "%02d.%02d.%d %02d:%02d:%02d", 
                ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));

                format(f_string184, sizeof f_string184, "{FFFFFF}%d. %s %s\n", i + 1, text, time_data);
                strcat(dialog, f_string184);
            }

            if(r >= 11)
            {
                new buttom[21];
                format(buttom, sizeof buttom, "Следующая страница");
                strcat(dialog, buttom);
                SetPVarInt(playerid, "count_list", 1);

                SetPVarInt(playerid, "up_count", 10);
                SetPVarInt(playerid, "down_count", 11);
            } 

            ShowPlayerDialog
            (
                playerid, 2237, DIALOG_STYLE_LIST,
                "{FF0000} Логи",
                dialog,
                "Закрыть", ""
            );

            cache_delete(result);
            return 1;
        }

        new up = GetPVarInt(playerid, "up_count"),
        down = GetPVarInt(playerid, "down_count");

        if(listitem == up || listitem == down)
        {
            new list = GetPVarInt(playerid, "count_list");

            if(listitem == up)  list++;
            else if(listitem == down) list--;
            SetPVarInt(playerid, "count_list", list);

            new 
            Cache: result,
            id;

            mysql_format(mysql, f_string184, sizeof f_string184, "SELECT * FROM family_log WHERE family ='%d' AND type = %d", GetFamily(GetPlayerIdFamily(playerid), family_database), type);
            result = mysql_query(mysql, f_string184, true);

            new rows = cache_num_rows();
            
            if(!rows) return SendClientMessage(playerid, -1, ""c_f_r"Логи не найдены.");

            new count_rows, count = 10 * GetPVarInt(playerid, "count_list");

            if(rows >= count)
            {
                count_rows = count;
                SetPVarInt(playerid, "up_count", 10);
                SetPVarInt(playerid, "down_count", 11);
            }
            else
            {
                count_rows = rows;
                new p = count_rows - (count - 10);
                SetPVarInt(playerid, "down_count", p);
                SetPVarInt(playerid, "up_count", 10);
            }

            new dialog[sizeof f_string184 * 10], text[124], time_data[24];

            for(new i = count-10, time; i < count_rows; i++)
            {
                time = cache_get_field_content_int(i, "time");
                cache_get_field_content(i, "text", text);

                format(time_data, sizeof time_data, "%02d.%02d.%d %02d:%02d:%02d", 
                ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));

                format(f_string184, sizeof f_string184, "{FFFFFF}%d. %s %s\n", i + 1, text, time_data);
                strcat(dialog, f_string184);
            }

            if(rows >= count+1)
            {
                new buttom[21];
                format(buttom, sizeof buttom, "Следующая страница\n");
                strcat(dialog, buttom);

            }

            if(count >= 11)
            {
                new buttom_1[21];
                format(buttom_1, sizeof buttom_1, "Предыдущая страница");
                strcat(dialog, buttom_1);
            }

            ShowPlayerDialog
            (
                playerid, 2237, DIALOG_STYLE_LIST,
                "{FF0000} Логи",
                dialog,
                "Закрыть", ""
            );

            cache_delete(result);

            return 1;
        }
    }
    
    if(dialogid == 2238)
    {
        if(response) return FamilyCreate(playerid, inputtext);
        return 1;
    }
    if(dialogid == 2239)
    {
        if(response)
        {
            new rang = strval(inputtext);

            if(!(1 <= rang <= 5))
                return BackSendClientMessage(playerid, -1,  "Ранг должен быть от 1 до 5");

            new id = GetPVarInt(playerid, "select_fam_car");

            mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE family_cars SET rang=%d WHERE id=%d LIMIT 1", rang, id);
            mysql_query(mysql, f_string144, false);

            mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", id);
            new Cache:cache = mysql_query(mysql, f_string64);

            new model = cache_get_field_content_int(0, "model_id")-400, sql = cache_get_field_content_int(0, "id");

            cache_delete(cache);

            format(f_string144, sizeof f_string144, "%s[%d] изменил доступ к %s (%d) на %d ранг.", GetPlayerNameEx(playerid), playerid, GetVehicleInfo(model, VI_NAME), sql, rang);
            SendFamilyMessage(f,  f_string144);
        }
    }
    if(dialogid == 2240)
    {
        if(response)
        {
            if(GetPlayerDonateRub(playerid) >= 300)
            {
                GivePlayerDonateRub(playerid, -300);
                AddFamily(f, family_slot_veh, +, 1);
                UpdateColumnFamilyInt(GetFamily(f, family_database), "slot_veh", GetFamily(f, family_slot_veh));

                format(f_string144, sizeof f_string144, "%s[%d] купил слот для транспорта в семью. Всего: %d", 
                GetPlayerNameEx(playerid), playerid, GetFamily(f, family_slot_veh));
                SendFamilyMessage(f, f_string144);

                SendClientMessage(playerid, -1, ""c_f_g"Вы купили слот для транспорта в семью");
            }
            else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает %d донат-рублей", 300-GetPlayerDonateRub(playerid));
        }
    }
    if(dialogid == 2241)
    {
        if(response)
        {
            if(GetPlayerDonateRub(playerid) >= 100)
            {
                new to_player = strval(inputtext);

                if(!IsPlayerConnected(to_player) || to_player == playerid)
                    return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                if(GetPlayerIdFamily(to_player) != -1)
                    return SendClientMessage(playerid, -1, ""c_f_r"Игрок уже состоит в семье.");

                if(!IsPlayerInRangeOfPlayer(playerid, to_player, 5.0))
                    return SendClientMessage(playerid, 0xCECECEFF, "Игрок слишком далеко");

                format(f_string144, sizeof f_string144, "{FFFF00}%s{FFFFFF}хочет передать полномочия семьи %s Вам.",
                GetPlayerNameEx(playerid), GetFamily(f, family_name));

                DeletePVar(to_player, "player_offer");
                ShowPlayerDialog
                (
                    to_player, 2242, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Передача семьи",
                    f_string144,
                    "Принять", "Отказать"
                );

                SetPVarInt(to_player, "player_offer", playerid);
            }
            else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает %d донат-рублей", 100-GetPlayerDonateRub(playerid));
        }
    }
    if(dialogid == 2242)
    {
        new player_offer = GetPVarInt(playerid, "player_offer"), ff = GetPlayerIdFamily(player_offer);

        if(!response)
        {
            SendClientMessage(player_offer, -1, ""c_f"Игрок отказался от вашего предложения.");
            SendClientMessage(playerid, -1, ""c_f"Вы отказались от предложения.");
            return 1;
        }

        if(!IsPlayerConnected(player_offer)) return SendClientMessage(playerid, -1, ""c_f_r"Игрок вышел из игры.");

        GivePlayerDonateRub(player_offer, -100);
        
        SetPlayerFamily(playerid, RANG_FAMILY, 5);
        SetPlayerFamily(playerid, ID_SQL_FAMILY, GetFamily(ff, family_database));
        SetPlayerFamily(playerid, ID_FAMILY, ff);
        UpdatePlayerDatabaseInt(playerid, "family_rang", GetPlayerFamily(playerid, RANG_FAMILY));
        UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(playerid, ID_SQL_FAMILY));

        SetPlayerFamily(player_offer, RANG_FAMILY, 1);
        UpdatePlayerDatabaseInt(player_offer, "family_rang", GetPlayerFamily(player_offer, RANG_FAMILY));

        SetFamily(ff, family_owner, GetPlayerAccountID(playerid));
        UpdateColumnFamilyInt(GetFamily(ff, family_database), "owner", GetFamily(ff, family_owner));

        format(f_string144, sizeof f_string144, "%s[%d] передал семью %s[%d]", 
        GetPlayerNameEx(player_offer), player_offer, GetPlayerNameEx(playerid), playerid);
        SendFamilyMessage(ff, f_string144);

        LoadPlayerFamily(playerid);
        LoadPlayerFamily(player_offer);

        FSendClientMessage(f_string144, player_offer, -1, ""c_f_g"Вы передали полномочия вашей семье игроку {FFFF00}%s", GetPlayerNameEx(playerid));
        FSendClientMessage(f_string144, playerid, -1, ""c_f_g"Вы получили полномочия семьи игрока {FFFF00}%s", GetPlayerNameEx(player_offer));
    }
    if(dialogid == 2243)
    {
        if(response)
        {
            new fff, player = GetPVarInt(playerid, "invite_player");

            fff = GetPlayerIdFamily(player);
            
            UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(player, ID_SQL_FAMILY));
            UpdatePlayerDatabaseInt(playerid, "family_rang", 1);
        
            LoadPlayerFamily(playerid);
            SendClientMessage(player, -1, ""c_f"Вы приняли в семью игрока.");
            format(f_string144, sizeof f_string144, "%s принял в семью %s", GetPlayerNameEx(player), GetPlayerNameEx(playerid));
            SendFamilyMessage(fff, f_string144);
            SendFamilyLog(type_log_invite, playerid, player, f_string144);
            if(GetPlayerData(playerid, P_QUEST_7) == 0)
		    {
            SendClientMessage(playerid, COR_SERVER, "{ffffff}Вы успешно выполнили квест {009900}'Вступить в семью'. {ffffff}Ваша награда: {009900}10000 руб");
		    SendClientMessage(playerid, COR_SERVER, "{ffffff}Введите {009900}/quest{ffffff},для подробной информации по Вашим квестам");
		    GivePlayerMoneyEx(playerid, 10000, "Выполнение квеста");
            SetPlayerData(player, P_QUEST_7, 1);
			UpdatePlayerDatabaseInt(player, "quest_7", 1);
			} 
        }
        else
        {
            SendClientMessage(GetPVarInt(playerid, "invite_player"), -1, ""c_f"Игрок отказался от вашего предложения.");
            SendClientMessage(playerid, -1, ""c_f"Вы отказались от предложения.");
            return 1;
        }
    }
    if(dialogid == 2244)
    {
        if(response)
        {
            new fam_name[32];

            if(sscanf(inputtext, "s[32]", fam_name) || strlen(inputtext) < 6)
                return SendClientMessage(playerid, -1, "Название семьи должно состоят от 6 до 32 символов");

            for(new i; i < strlen(fam_name); i++) if(fam_name[i] == '-' && fam_name[i+7] == '}') fam_name[i] = '{';

            format(family[f][family_name], 32, fam_name);
            mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE family SET name='%s' WHERE id = %d", GetFamily(f, family_name), GetFamily(f, family_database));
            mysql_query(mysql, f_string144, false);

            GivePlayerDonateRub(playerid, -100);

            FSendClientMessage(f_string144, playerid, -1, ""c_f_g"Вы изменили название вашей семьи на %s.", GetFamily(f, family_name));
            
            foreach(new i : Player)
            {
                if(GetPlayerIdFamily(i) != f) continue;

                format(f_string144, sizeof f_string144, "%sСемья:{FFFFFF} %s", family_type_color[GetFamily(f, family_color)], GetFamily(f, family_name));
                if(IsValidDynamic3DTextLabel(GetPlayerFamily(i, TEXT_FAMILY)))
                    UpdateDynamic3DTextLabelText(GetPlayerFamily(i, TEXT_FAMILY), -1, f_string144);
            }

            format(f_string144, sizeof f_string144, "Лидер семьи %s[%d] изменил название семьи на %s.", GetPlayerNameEx(playerid), playerid, fam_name);
            SendFamilyMessage(f, f_string144);
        }
    }
    if(dialogid == 2245)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    ShowPlayerDialog
                    (
                        playerid, -1, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Сезоны семьи",
                        "В сезонах семьи главное это репутации.\n"\
                        "Получать репутацию можно в сражениях за {FFFF00}разные предприятия {FFFFFF}и\n"\
                        "{FFFF00}семейных контейнерах.\n"\
                        "{FFFFFF}Конец сезона семьи происходит в {FFFF00}00:00 Четверга.\n\n"\
                        "{FFFFFF}Награда за {FFFF00}первое место{FFFFFF} в топе семей:\n"\
                        "90.000 рублей и 40 донат-рублей каждому игроку из семьи\n"\
                        "Два слота для транспорта в семью\n\n"\
                        "{FFFFFF}Награда за {FFFF00}второе место{FFFFFF} в топе семей:\n"\
                        "60.000 рублей и 30 донат-рублей каждому игроку из семьи\n"\
                        "Один слот для транспорта в семью\n\n"\
                        "{FFFFFF}Награда за {FFFF00}третье место{FFFFFF} в топе семей:\n"\
                        "30.000 рублей и 20 донат-рублей каждому игроку из семьи",
                        "Выйти", ""
                    );
                }
                case 1:
                {

                    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT * FROM family WHERE reputation >= '0' ORDER BY reputation DESC");
                    new Cache:result = mysql_query(mysql, f_string144);

                    if(mysql_errno()) return print("[COLLECTOR_SYSTEM] Error Sql Query: №1");

                    new rows = cache_num_rows();

                    new list[68], dialog[584];

                    new name[32], name_pl[32], rep_pl, reputation, mesto, id, select_family = true, database_family = GetFamily(GetPlayerIdFamily(playerid), family_database);

                    for(new i, count;i < rows;i++)
                    {
                        id = cache_get_field_content_int(i, "id");
                        cache_get_field_content(i, "name", name, mysql, 32);
                        reputation = cache_get_field_content_int(i, "reputation");

                        if(database_family == id)
                        {
                            format(name_pl, sizeof name_pl, name);
                            rep_pl = reputation;
                            mesto = i+1;
                        } 

                        if(count != 10)
                        {
                            format(list, sizeof list, "{FFFFFF} №%d %s %d\n", i+1, name, reputation);
                            strcat(dialog, list);
                            count++;
                        }
                    }

                    format(list, sizeof list, "{FFFF00}- {FFFFFF}№%d %s %d", mesto, name_pl, rep_pl);
                    strcat(dialog, list);
                    
                   ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "{FF0000}Рейтинг лучших семей", dialog, "Закрыть", "");
                }
            }
        }
    }
    #if defined fam_OnDialogResponse
    return fam_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
   #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse fam_OnDialogResponse
#if defined fam_OnDialogResponse
forward fam_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif





stock ShowDialogFamilyCar(playerid, id)
{
    SetPVarInt(playerid, "select_fam_car", id);

    new status = GetStatusFamilyCar(id);

    if(!status)
    {
        if(GetPlayerRangFamily(playerid) != 5)
        {
            ShowPlayerDialog
            (
                playerid, 2224, DIALOG_STYLE_LIST, 
                "{FF0000}Семейный транспорт",
                "1. Отметить транспорт на GPS\n"\
                "2. Загрузить транспорт\n"\
                "3. Удалить транспорт",
                "Далее", "Выйти"
            );
        }
        else
        {
            ShowPlayerDialog
            (
                playerid, 2224, DIALOG_STYLE_LIST, 
                "{FF0000}Семейный транспорт",
                "1. Отметить транспорт на GPS\n"\
                "2. Загрузить транспорт\n"\
                "3. Удалить транспорт\n"\
                "4. Изменить доступ к т/с",
                "Далее", "Выйти"
            );  
        }
    }
    else
    {
        ShowPlayerDialog
        (
            playerid, 2224, DIALOG_STYLE_LIST, 
            "{FF0000}Семейный транспорт",
            "1. Отметить транспорт на GPS\n"\
            "2. Выгрузить транспорт",
            "Далее", "Выйти"
        );     
    }
}

stock MoveOwnableCar(playerid, database_car, fam)
{
    new fam_id = GetPlayerIdFamily(playerid);

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM ownable_cars WHERE id=%d", database_car);
    new Cache:cache_sql = mysql_query(mysql, f_string64);

    if(mysql_errno())
        return SendClientMessage(playerid,-1,""c_f_r"Ошибка в SQL-запросе / Code: MoveOwnableCar");

    if(!cache_num_rows())
        return SendClientMessage(playerid,-1,""c_f_r"Транспорт не найден.");

    new model_id, color_1, color_2, number[32], region[8], number_type, 
    Float:pos_x, Float:pos_y, Float:pos_z, Float:angle, Float:fuel, Float:health, Float:mileage;

    model_id = cache_get_field_content_int(0, "model_id");
    color_1 = cache_get_field_content_int(0, "color_1");
    color_2 = cache_get_field_content_int(0, "color_2");
    pos_x = cache_get_field_content_float(0, "pos_x");
    pos_y = cache_get_field_content_float(0, "pos_y");
    pos_z = cache_get_field_content_float(0, "pos_z");
    angle = cache_get_field_content_float(0, "angle");
    fuel = cache_get_field_content_float(0, "fuel");
    health = cache_get_field_content_float(0, "health");
    mileage = cache_get_field_content_float(0, "mileage");

    // If the personal vehicle is currently loaded, preserve the live mileage/fuel/health,
    // not an older value that may still be waiting for periodic DB sync.
    new active_vehicleid = GetPlayerOwnableCar(playerid);
    if(active_vehicleid != INVALID_VEHICLE_ID && IsValidVehicle(active_vehicleid))
    {
        new active_index = GetVehicleData(active_vehicleid, V_ACTION_ID);
        if(active_index >= 0 && GetOwnableCarData(active_index, OC_SQL_ID) == database_car)
        {
            mileage = GetVehicleData(active_vehicleid, V_MILEAGE);
            fuel = GetVehicleData(active_vehicleid, V_FUEL);
            GetVehicleHealth(active_vehicleid, health);
        }
    }

    if(fuel < 0.0) fuel = 40.0;
    if(health < 300.0) health = 1000.0;
    if(mileage < 0.0) mileage = 0.0;
    cache_get_field_content(0, "number", number, mysql, 32);
    new stored_number[32];
    format(stored_number, sizeof stored_number, "%s", number);
    FamilyParseStoredPlateValue(stored_number, number_type, number, sizeof number, region, sizeof region);

    
    new query[2048];
mysql_format
(
    mysql, query, sizeof query,
    "INSERT INTO family_cars \
    (family_owner, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, create_time, number, region, number_type, plate_number, plate_region, plate_type, fuel, health, mileage, trunk_source_oc_id) \
    VALUES \
    (%d, %d, %d, %d, %f, %f, %f, %f, %d, '%e', '%e', %d, '%e', '%e', %d, %f, %f, %f, %d)",
    fam, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, gettime(), number, region, number_type, number, region, number_type, fuel, health, mileage, database_car
);
    new Cache:family_insert_cache = mysql_query(mysql, query, true);
    new family_car_sql_id = cache_insert_id();
    new family_insert_errno = mysql_errno();
    cache_delete(family_insert_cache);

    if(family_insert_errno || family_car_sql_id <= 0)
    {
        printf("[FAMILY CAR MOVE][INSERT ERROR] ownable=%d errno=%d new_id=%d", database_car, family_insert_errno, family_car_sql_id);
        cache_delete(cache_sql);
        return SendClientMessage(playerid, -1, ""c_f_r" Database error while moving vehicle to family.");
    }

    CopyVehicleTuningOwnableToFamily(database_car, family_car_sql_id);

    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM ownable_cars WHERE id=%d", database_car);
    mysql_query(mysql, f_string64, false);
    
    if(!mysql_errno())
    {
        UnloadPlayerOwnableCar(playerid);
        SendClientMessage(playerid, -1, ""c_f_g" Вы успешно добавили транспорт в семью.");
        format(f_string144, sizeof f_string144, "Владелец %s добавил в семью автомобиль %s", GetPlayerNameEx(playerid), GetVehicleInfo(model_id-400, VI_NAME));
        SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
        AddFamily(fam_id, family_count_veh, +, 1);
    }
    cache_delete(cache_sql);
    return 1;
}

stock MoveFamilyCar(database_car, playerid)
{
    new fam = GetPlayerIdFamily(playerid);

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", database_car);
    new Cache:cache_sql = mysql_query(mysql, f_string64);

    if(mysql_errno())
        return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: MoveFamilyCar");

    if(!cache_num_rows())
        return SendClientMessage(playerid,-1,""c_f_r" Транспорт не найден.");

    new model_id, color_1, color_2, number[32], region[8], number_type, trunk_source_oc_id,
    Float:pos_x, Float:pos_y, Float:pos_z, Float:angle, Float:fuel, Float:health, Float:mileage;

    model_id = cache_get_field_content_int(0, "model_id");
    color_1 = cache_get_field_content_int(0, "color_1");
    color_2 = cache_get_field_content_int(0, "color_2");
    pos_x = cache_get_field_content_float(0, "pos_x");
    pos_y = cache_get_field_content_float(0, "pos_y");
    pos_z = cache_get_field_content_float(0, "pos_z");
    angle = cache_get_field_content_float(0, "angle");
    fuel = cache_get_field_content_float(0, "fuel");
    health = cache_get_field_content_float(0, "health");
    mileage = cache_get_field_content_float(0, "mileage");
    trunk_source_oc_id = cache_get_field_content_int(0, "trunk_source_oc_id");
    if(fuel < 0.0) fuel = 40.0;
    if(health < 300.0) health = 1000.0;
    if(mileage < 0.0) mileage = 0.0;
    cache_get_field_content(0, "number", number, mysql, 32);
    cache_get_field_content(0, "region", region, mysql, 8);
    number_type = cache_get_field_content_int(0, "number_type"); // Исправлено: было cache_get_field_content_float

    // Rows from the previous family system may still keep the visible plate in plate_* only.
    if(!strlen(number)) cache_get_field_content(0, "plate_number", number, mysql, sizeof number);
    if(!strlen(region)) cache_get_field_content(0, "plate_region", region, mysql, sizeof region);
    if(number_type < TYPE_RU || number_type > TYPE_KZ) number_type = cache_get_field_content_int(0, "plate_type");

    new stored_number[32];
    FamilyBuildStoredPlateValue(number_type, number, region, stored_number, sizeof stored_number);

    new query[2048];
    mysql_format
    (
        mysql, query, sizeof query,
        "INSERT INTO ownable_cars \
        (owner_id, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, create_time, number, fuel, health, mileage) \
        VALUES \
        (%d, %d, %d, %d, %f, %f, %f, %f, %d, '%e', %f, %f, %f)",
        GetPlayerAccountID(playerid), model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, gettime(), stored_number, fuel, health, mileage
    );
    new Cache:ownable_insert_cache = mysql_query(mysql, query, true);
    new ownable_car_sql_id = cache_insert_id();
    new ownable_insert_errno = mysql_errno();
    cache_delete(ownable_insert_cache);

    if(ownable_insert_errno || ownable_car_sql_id <= 0)
    {
        printf("[FAMILY CAR MOVE BACK][INSERT ERROR] family_car=%d errno=%d new_id=%d", database_car, ownable_insert_errno, ownable_car_sql_id);
        cache_delete(cache_sql);
        return SendClientMessage(playerid, -1, ""c_f_r" Database error while moving vehicle out of family.");
    }

    CopyVehicleTuningFamilyToOwnable(database_car, ownable_car_sql_id);

    // Restore the complete personal trunk after the vehicle comes back from the family.
    // trunkcar is used by GUI 34; trunks is kept for compatibility with the old trunk code.
    if(trunk_source_oc_id > 0)
    {
        new trunk_query[320];
        new old_plate_base = 200000000 + (trunk_source_oc_id * 100);
        new new_plate_base = 200000000 + (ownable_car_sql_id * 100);

        mysql_format(mysql, trunk_query, sizeof trunk_query,
            "UPDATE trunkcar SET acc_id=%d, oc_id=%d WHERE oc_id=%d",
            GetPlayerAccountID(playerid), ownable_car_sql_id, trunk_source_oc_id);
        mysql_query(mysql, trunk_query, false);

        mysql_format(mysql, trunk_query, sizeof trunk_query,
            "UPDATE trunks SET oc_id=%d WHERE oc_id=%d",
            ownable_car_sql_id, trunk_source_oc_id);
        mysql_query(mysql, trunk_query, false);

        // Number plates stored inside the trunk use a virtual inventory_plates slot
        // based on the vehicle SQL id. Move those slots to the new SQL id as well.
        mysql_format(mysql, trunk_query, sizeof trunk_query,
            "UPDATE inventory_plates SET account_id=%d, slot=(slot-%d)+%d WHERE slot BETWEEN %d AND %d",
            GetPlayerAccountID(playerid), old_plate_base, new_plate_base, old_plate_base, old_plate_base + 25);
        mysql_query(mysql, trunk_query, false);
    }

    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM family_cars WHERE id=%d", database_car);
    mysql_query(mysql, f_string64, false);

    if(!mysql_errno())
    {
        SendClientMessage(playerid, -1, ""c_f_g" Вы успешно забрали транспорт из семьи.");
        format(f_string144, sizeof f_string144, "Владелец %s забрал из семьи автомобиль %s", GetPlayerNameEx(playerid), GetVehicleInfo(model_id-400, VI_NAME));
        SendFamilyMessage(fam, f_string144);
        AddFamily(fam, family_count_veh, -, 1);
    }
    cache_delete(cache_sql);
    return 1;
}

stock LoadFamilyCar(database)
{
    new rows, vehicleid;
    new Cache: result;

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", database);
    result = mysql_query(mysql, f_string64, true);
    rows = cache_num_rows();

    if(!rows) return 1;

    new free_id = GetFreeIDFamilyCar();
    SetCarFamily(free_id, CAR_F_database,       cache_get_field_content_int(0, "id"));

    SetCarFamily(free_id, OW_F_database,     cache_get_field_content_int(0, "family_owner"));
    SetCarFamily(free_id, OW_F_server,     GetFamilyIDSQL(GetCarFamily(free_id, OW_F_database)));

    SetCarFamily(free_id, V_F_MODEL,     cache_get_field_content_int(0, "model_id"));
    SetCarFamily(free_id, V_F_COLOR_1,      cache_get_field_content_int(0, "color_1"));
    SetCarFamily(free_id, V_F_COLOR_2,      cache_get_field_content_int(0, "color_2"));
    SetCarFamily(free_id, V_F_RANG,         cache_get_field_content_int(0, "rang"));

    SetCarFamily(free_id, V_F_SPAWN_X,        cache_get_field_content_float(0, "pos_x"));
    SetCarFamily(free_id, V_F_SPAWN_Y,        cache_get_field_content_float(0, "pos_y"));
    SetCarFamily(free_id, V_F_SPAWN_Z,        cache_get_field_content_float(0, "pos_z"));
    SetCarFamily(free_id, V_F_SPAWN_A,        cache_get_field_content_float(0, "angle"));
   
    SetCarFamily(free_id, V_F_SPAWN_LAST_X,        cache_get_field_content_float(0, "pos_last_x"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_Y,        cache_get_field_content_float(0, "pos_last_y"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_Z,        cache_get_field_content_float(0, "pos_last_z"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_A,        cache_get_field_content_float(0, "angle_last"));

    SetCarFamily(free_id, V_F_COUNT_BOX,        0);
    SetCarFamily(free_id, V_F_TEXT_CONT,        STREAMER_TAG_3D_TEXT_LABEL:-1);
    SetCarFamily(free_id, V_F_AREA_CONT,        -1);
    SetCarFamily(free_id, V_F_STATUS_CONT,      false);

    cache_get_field_content(0, "number", vehicle_family[free_id][V_F_NUMBER], mysql, 32);
    cache_get_field_content(0, "vynil_name", vehicle_family[free_id][V_F_VINYL_NAME], mysql, 32);
    cache_get_field_content(0, "region", vehicle_family[free_id][V_F_REGION], mysql, 8);
    SetCarFamily(free_id, V_F_NUMBER_TYPE, cache_get_field_content_int(0, "number_type"));

    // Old family rows may still have the real plate/region only in plate_* columns.
    if(!strlen(vehicle_family[free_id][V_F_NUMBER]))
        cache_get_field_content(0, "plate_number", vehicle_family[free_id][V_F_NUMBER], mysql, 32);
    if(!strlen(vehicle_family[free_id][V_F_REGION]))
        cache_get_field_content(0, "plate_region", vehicle_family[free_id][V_F_REGION], mysql, 8);
    if(GetCarFamily(free_id, V_F_NUMBER_TYPE) < TYPE_RU || GetCarFamily(free_id, V_F_NUMBER_TYPE) > TYPE_KZ)
        SetCarFamily(free_id, V_F_NUMBER_TYPE, cache_get_field_content_int(0, "plate_type"));

    FamilyNormalizeLoadedPlate(free_id);
    SetCarFamily(free_id, V_F_FSTATE,           cache_get_field_content_int(0, "f_state"));
    SetCarFamily(free_id, V_F_NITRO,            cache_get_field_content_int(0, "nitro_level"));
    SetCarFamily(free_id, V_F_LAUNCH,           cache_get_field_content_int(0, "launch"));
    SetCarFamily(free_id, V_F_PDVRADAR,         cache_get_field_content_int(0, "pdvradar"));
    SetCarFamily(free_id, V_F_LIGHTS_COLOR,     cache_get_field_content_int(0, "lights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR, cache_get_field_content_int(0, "underlights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_LF, cache_get_field_content_int(0, "underlights_color_lf"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_RT, cache_get_field_content_int(0, "underlights_color_rt"));
    SetCarFamily(free_id, V_F_IS_FAR_LIGHT_ACTIVE, 0);
    SetCarFamily(free_id, V_F_SELECTED_PNEVMO,  cache_get_field_content_int(0, "pnevmo_selected"));
    SetCarFamily(free_id, V_F_PERCENT_CLR,      cache_get_field_content_int(0, "percentofclirness"));
    SetCarFamily(free_id, V_F_PERCENT_CLR_Z,    cache_get_field_content_int(0, "percentofclirnessZ"));
    SetCarFamily(free_id, V_F_IS_HYDRO_ACTIVE, cache_get_field_content_int(0, "is_hydro_active"));
    SetCarFamily(free_id, V_F_FUEL, cache_get_field_content_float(0, "fuel"));
    SetCarFamily(free_id, V_F_HEALTH, cache_get_field_content_float(0, "health"));
    if(GetCarFamily(free_id, V_F_FUEL) < 0.0) SetCarFamily(free_id, V_F_FUEL, 40.0);
    if(GetCarFamily(free_id, V_F_HEALTH) < 300.0) SetCarFamily(free_id, V_F_HEALTH, 1000.0);

    vehicleid = CreateVehicle
    (
        GetCarFamily(free_id, V_F_MODEL),
        GetCarFamily(free_id, V_F_SPAWN_X),
        GetCarFamily(free_id, V_F_SPAWN_Y),
        GetCarFamily(free_id, V_F_SPAWN_Z),
        GetCarFamily(free_id, V_F_SPAWN_A),
        GetCarFamily(free_id, V_F_COLOR_1),
        GetCarFamily(free_id, V_F_COLOR_2),
        -1,
        0,
        VEHICLE_ACTION_TYPE_FAMILY_CAR,
        free_id
    );

    printf("%d, %f %f %f %f %d %d", GetCarFamily(free_id, V_F_MODEL), GetCarFamily(free_id, V_F_SPAWN_X), GetCarFamily(free_id, V_F_SPAWN_Y), GetCarFamily(free_id, V_F_SPAWN_Z), GetCarFamily(free_id, V_F_SPAWN_A), GetCarFamily(free_id, V_F_COLOR_1), GetCarFamily(free_id, V_F_COLOR_2));
    
    new f_server = GetFamilyIDSQL(GetCarFamily(free_id, OW_F_database));

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        new familyName[64];
        format(familyName, sizeof familyName, "%s", GetFamily(f_server, family_name));
        utf8_to_cp1251(familyName);

        SetVehicleNumberPlateEx(vehicleid, vehicle_family[free_id][V_F_NUMBER_TYPE], vehicle_family[free_id][V_F_NUMBER], vehicle_family[free_id][V_F_REGION]);
        SetVehicleParam(vehicleid, V_LOCK, false);
        SetVehicleData(vehicleid, V_MILEAGE, 0.0);
        SetVehicleData(vehicleid, V_FUEL, GetCarFamily(free_id, V_F_FUEL));
        SetVehicleData(vehicleid, V_HEALTH, GetCarFamily(free_id, V_F_HEALTH));
        SetVehicleHealth(vehicleid, GetCarFamily(free_id, V_F_HEALTH));
        SetVehicleSpeedometerInfo(vehicleid, GetCarFamily(free_id, V_F_FUEL), 0.0);
        SetVehicleParam(vehicleid, V_ENGINE, VEHICLE_PARAM_OFF);
        SetVehicleParam(vehicleid, V_LIGHTS, VEHICLE_PARAM_OFF);
        TurnLightState[vehicleid] = false;

        // Load complete Style / Tech / tire-shop tuning into shared vInfo runtime.
        PrepareFamilyCarTuningRuntime(vehicleid, free_id, 0);
        ApplyFamilyCarStoredComponents(vehicleid, GetCarFamily(free_id, CAR_F_database));
    
        foreach(new playerid: Player)
        {
            if(IsVehicleStreamedIn(vehicleid, playerid))
            {
                SetTimerEx("ApplyVehicleTuning", 250, false, "dd", playerid, vehicleid);
            }
        }
    }

    cache_delete(result);
    return vehicleid != INVALID_VEHICLE_ID ? 1 : 0;
}

stock LoadFamilyCarLastPos(database)
{
    new rows, vehicleid;
    new Cache: result;

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", database);
    result = mysql_query(mysql, f_string64, true);
    rows = cache_num_rows();

    if(!rows) return 1;

    new free_id = GetFreeIDFamilyCar();
    SetCarFamily(free_id, CAR_F_database,       cache_get_field_content_int(0, "id"));

    SetCarFamily(free_id, OW_F_database,     cache_get_field_content_int(0, "family_owner"));
    SetCarFamily(free_id, OW_F_server,     GetFamilyIDSQL(GetCarFamily(free_id, OW_F_database)));

    SetCarFamily(free_id, V_F_MODEL,     cache_get_field_content_int(0, "model_id"));
    SetCarFamily(free_id, V_F_COLOR_1,      cache_get_field_content_int(0, "color_1"));
    SetCarFamily(free_id, V_F_COLOR_2,      cache_get_field_content_int(0, "color_2"));
    SetCarFamily(free_id, V_F_RANG,         cache_get_field_content_int(0, "rang"));

    SetCarFamily(free_id, V_F_SPAWN_X,        cache_get_field_content_float(0, "pos_x"));
    SetCarFamily(free_id, V_F_SPAWN_Y,        cache_get_field_content_float(0, "pos_y"));
    SetCarFamily(free_id, V_F_SPAWN_Z,        cache_get_field_content_float(0, "pos_z"));
    SetCarFamily(free_id, V_F_SPAWN_A,        cache_get_field_content_float(0, "angle"));
   
    SetCarFamily(free_id, V_F_SPAWN_LAST_X,        cache_get_field_content_float(0, "pos_last_x"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_Y,        cache_get_field_content_float(0, "pos_last_y"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_Z,        cache_get_field_content_float(0, "pos_last_z"));
    SetCarFamily(free_id, V_F_SPAWN_LAST_A,        cache_get_field_content_float(0, "angle_last"));

    SetCarFamily(free_id, V_F_COUNT_BOX,        0);
    SetCarFamily(free_id, V_F_TEXT_CONT,        STREAMER_TAG_3D_TEXT_LABEL:-1);
    SetCarFamily(free_id, V_F_AREA_CONT,        -1);
    SetCarFamily(free_id, V_F_STATUS_CONT,      false);

    cache_get_field_content(0, "number", vehicle_family[free_id][V_F_NUMBER], mysql, 32);
    cache_get_field_content(0, "vynil_name", vehicle_family[free_id][V_F_VINYL_NAME], mysql, 32);
    cache_get_field_content(0, "region", vehicle_family[free_id][V_F_REGION], mysql, 8);
    SetCarFamily(free_id, V_F_NUMBER_TYPE, cache_get_field_content_int(0, "number_type"));

    // Old family rows may still have the real plate/region only in plate_* columns.
    if(!strlen(vehicle_family[free_id][V_F_NUMBER]))
        cache_get_field_content(0, "plate_number", vehicle_family[free_id][V_F_NUMBER], mysql, 32);
    if(!strlen(vehicle_family[free_id][V_F_REGION]))
        cache_get_field_content(0, "plate_region", vehicle_family[free_id][V_F_REGION], mysql, 8);
    if(GetCarFamily(free_id, V_F_NUMBER_TYPE) < TYPE_RU || GetCarFamily(free_id, V_F_NUMBER_TYPE) > TYPE_KZ)
        SetCarFamily(free_id, V_F_NUMBER_TYPE, cache_get_field_content_int(0, "plate_type"));

    FamilyNormalizeLoadedPlate(free_id);
    SetCarFamily(free_id, V_F_FSTATE,           cache_get_field_content_int(0, "f_state"));
    SetCarFamily(free_id, V_F_NITRO,            cache_get_field_content_int(0, "nitro_level"));
    SetCarFamily(free_id, V_F_LAUNCH,           cache_get_field_content_int(0, "launch"));
    SetCarFamily(free_id, V_F_PDVRADAR,         cache_get_field_content_int(0, "pdvradar"));
    SetCarFamily(free_id, V_F_LIGHTS_COLOR,     cache_get_field_content_int(0, "lights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR, cache_get_field_content_int(0, "underlights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_LF, cache_get_field_content_int(0, "underlights_color_lf"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_RT, cache_get_field_content_int(0, "underlights_color_rt"));
    SetCarFamily(free_id, V_F_IS_FAR_LIGHT_ACTIVE, 0);
    SetCarFamily(free_id, V_F_SELECTED_PNEVMO,  cache_get_field_content_int(0, "pnevmo_selected"));
    SetCarFamily(free_id, V_F_PERCENT_CLR,      cache_get_field_content_int(0, "percentofclirness"));
    SetCarFamily(free_id, V_F_PERCENT_CLR_Z,    cache_get_field_content_int(0, "percentofclirnessZ"));
    SetCarFamily(free_id, V_F_IS_HYDRO_ACTIVE, cache_get_field_content_int(0, "is_hydro_active"));
    SetCarFamily(free_id, V_F_FUEL, cache_get_field_content_float(0, "fuel"));
    SetCarFamily(free_id, V_F_HEALTH, cache_get_field_content_float(0, "health"));
    if(GetCarFamily(free_id, V_F_FUEL) < 0.0) SetCarFamily(free_id, V_F_FUEL, 40.0);
    if(GetCarFamily(free_id, V_F_HEALTH) < 300.0) SetCarFamily(free_id, V_F_HEALTH, 1000.0);

    vehicleid = CreateVehicle
    (
        GetCarFamily(free_id, V_F_MODEL),
        GetCarFamily(free_id, V_F_SPAWN_LAST_X),
        GetCarFamily(free_id, V_F_SPAWN_LAST_Y),
        GetCarFamily(free_id, V_F_SPAWN_LAST_Z),
        GetCarFamily(free_id, V_F_SPAWN_LAST_A),
        GetCarFamily(free_id, V_F_COLOR_1),
        GetCarFamily(free_id, V_F_COLOR_2),
        -1,
        0,
        VEHICLE_ACTION_TYPE_FAMILY_CAR,
        free_id
    );

    printf("%d, %f %f %f %f %d %d", GetCarFamily(free_id, V_F_MODEL), GetCarFamily(free_id, V_F_SPAWN_X), GetCarFamily(free_id, V_F_SPAWN_Y), GetCarFamily(free_id, V_F_SPAWN_Z), GetCarFamily(free_id, V_F_SPAWN_A), GetCarFamily(free_id, V_F_COLOR_1), GetCarFamily(free_id, V_F_COLOR_2));
    
    new f_server = GetFamilyIDSQL(GetCarFamily(free_id, OW_F_database));

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        new familyName[64];
        format(familyName, sizeof familyName, "%s", GetFamily(f_server, family_name));
        utf8_to_cp1251(familyName);

        SetVehicleNumberPlateEx(vehicleid, vehicle_family[free_id][V_F_NUMBER_TYPE], vehicle_family[free_id][V_F_NUMBER], vehicle_family[free_id][V_F_REGION]);
        SetVehicleParam(vehicleid, V_LOCK, false);
        SetVehicleData(vehicleid, V_MILEAGE, 0.0);
        SetVehicleData(vehicleid, V_FUEL, GetCarFamily(free_id, V_F_FUEL));
        SetVehicleData(vehicleid, V_HEALTH, GetCarFamily(free_id, V_F_HEALTH));
        SetVehicleHealth(vehicleid, GetCarFamily(free_id, V_F_HEALTH));
        SetVehicleSpeedometerInfo(vehicleid, GetCarFamily(free_id, V_F_FUEL), 0.0);
        SetVehicleParam(vehicleid, V_ENGINE, VEHICLE_PARAM_OFF);
        SetVehicleParam(vehicleid, V_LIGHTS, VEHICLE_PARAM_OFF);
        TurnLightState[vehicleid] = false;

        // Load complete Style / Tech / tire-shop tuning into shared vInfo runtime.
        PrepareFamilyCarTuningRuntime(vehicleid, free_id, 0);
        ApplyFamilyCarStoredComponents(vehicleid, GetCarFamily(free_id, CAR_F_database));
    
        foreach(new playerid: Player)
        {
            if(IsVehicleStreamedIn(vehicleid, playerid))
            {
                SetTimerEx("ApplyVehicleTuning", 250, false, "dd", playerid, vehicleid);
            }
        }
    }

    cache_delete(result);
    return vehicleid != INVALID_VEHICLE_ID ? 1 : 0;
}

stock UnLoadFamilyCar(database)
{
	new vehicleid = GetVehicleFamilyCar(database);

	if(vehicleid == INVALID_VEHICLE_ID)
	{
		return -1;
	}

	new id = GetVehicleData(vehicleid, V_ACTION_ID);

	DestroyVehicleLabel(vehicleid);
	
	new Float:lastposx, Float:lastposy, Float:lastposz, Float:lastposa;
    new Float:lastfuel = GetVehicleData(vehicleid, V_FUEL);
    new Float:lasthealth;
	GetVehiclePos(vehicleid, lastposx, lastposy, lastposz);
	GetVehicleZAngle(vehicleid, lastposa);
    GetVehicleHealth(vehicleid, lasthealth);
    if(lastfuel < 0.0) lastfuel = 0.0;
    if(lasthealth < 300.0) lasthealth = 300.0;

    SetCarFamily(id, CAR_F_database,       -1);

    SetCarFamily(id, OW_F_database,     -1);

    SetCarFamily(id, V_F_MODEL,     0);
    SetCarFamily(id, V_F_COLOR_1,   0);
    SetCarFamily(id, V_F_COLOR_2,   0);
    SetCarFamily(id, V_F_RANG,      0);

    SetCarFamily(id, V_F_SPAWN_X,        0.0);
    SetCarFamily(id, V_F_SPAWN_Y,        0.0);
    SetCarFamily(id, V_F_SPAWN_Z,        0.0);
    SetCarFamily(id, V_F_SPAWN_A,        0.0);
   
    SetCarFamily(id, V_F_SPAWN_LAST_X,        lastposx);
    SetCarFamily(id, V_F_SPAWN_LAST_Y,        lastposy);
    SetCarFamily(id, V_F_SPAWN_LAST_Z,        lastposz);
    SetCarFamily(id, V_F_SPAWN_LAST_A,        lastposa);

    if(IsValidDynamicArea(GetCarFamily(id, V_F_AREA_CONT))) DestroyDynamicArea(GetCarFamily(id, V_F_AREA_CONT));
    if(GetCarFamily(id, V_F_TEXT_CONT) != STREAMER_TAG_3D_TEXT_LABEL:-1)  Delete3DTextLabel(GetCarFamily(id, V_F_TEXT_CONT));

    SetCarFamily(id, V_F_TEXT_CONT,        STREAMER_TAG_3D_TEXT_LABEL:-1);
    SetCarFamily(id, V_F_AREA_CONT,        -1);
    SetCarFamily(id, V_F_STATUS_CONT,      false);
    SetCarFamily(id, V_F_COUNT_BOX,        0);
  
    new dbsend[512];
	mysql_format(mysql, dbsend, sizeof(dbsend),
    "UPDATE family_cars SET pos_last_x = %f, pos_last_y = %f, pos_last_z = %f, angle_last = %f, fuel = %f, health = %f, is_FarLight_active = 0 WHERE id = %d",
    lastposx, lastposy, lastposz, lastposa, lastfuel, lasthealth, database);
	mysql_query(mysql, dbsend, false);

	
	DestroyVehicle(vehicleid);

	return 1;
}


stock SendFamilyMessage(fam, text[])
{
    if(fam < 0 || fam >= MAX_FAM) return 0;

    new color_idx = GetFamily(fam, family_color);
    if(color_idx < 0 || color_idx >= sizeof(family_type_color))
        color_idx = 0;

    new string[384];
    // Используем только цвет, выбранный лидером в GUI семьи.
    // Цветовые теги в названии больше не перебивают настройку чата.
    format(string, sizeof string, "%s[%s] %s", family_type_color[color_idx], GetFamily(fam, family_name), text);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        if(GetPlayerFamily(i, ID_FAMILY) != fam) continue;

        SendClientMessage(i, 0xFFFFFFFF, string);
    }

    return 1;
}

stock GetStatusFamilyCar(database_car)
{
    foreach(new i : Vehicle)
    {
        if(GetVehicleData(i, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_FAMILY_CAR) continue;
        else if(GetCarFamily(GetVehicleData(i, V_ACTION_ID), CAR_F_database) != database_car) continue;
        return 1;
    }
    return 0;
} 

stock GetVehicleFamilyCar(database_car)
{
    new id = -1;
    foreach(new i : Vehicle)
    {
        if(GetVehicleData(i, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_FAMILY_CAR) continue;

        id = GetVehicleData(i, V_ACTION_ID);
        if(GetCarFamily(id, CAR_F_database) != database_car) continue;
        return i;
    }
    return INVALID_VEHICLE_ID;
}

stock GetFreeIDFamilyCar()
{
    for(new i; i < MAX_OWNABLE_CARS;i++)
    {
        if(GetCarFamily(i, CAR_F_database) != -1) continue;
        return i;
    }
    return -1;
}

stock ResolveFamilyCarVinylName(family_index, dest[], size, bool:save_if_missing = false)
{
    if(size <= 0) return 0;
    dest[0] = '\0';
    if(!(0 <= family_index < MAX_OWNABLE_CARS)) return 0;
    if(GetCarFamily(family_index, CAR_F_database) == -1) return 0;

    if(GetCarFamily(family_index, V_F_VINYL_NAME)[0] != '\0')
    {
        format(dest, size, "%s", GetCarFamily(family_index, V_F_VINYL_NAME));
        return 1;
    }

    GetRemapName(GetCarFamily(family_index, V_F_MODEL), dest, size);
    if(dest[0] == '\0') return 0;

    format(vehicle_family[family_index][V_F_VINYL_NAME], 32, "%s", dest);
    if(save_if_missing)
    {
        new query[160];
        mysql_format(mysql, query, sizeof query,
            "UPDATE family_cars SET vynil_name='%e' WHERE id=%d LIMIT 1",
            dest, GetCarFamily(family_index, CAR_F_database));
        mysql_query(mysql, query, false);
    }
    return 1;
}

stock GetFamilyIDSQL(database)
{
    for(new i; i <MAX_FAM;i++) if(GetFamily(i, family_database) == database) return i;
    return -1;
}

stock ShowDialogFamilySklad(playerid, type, take_or_put = false)
{
    switch(type)
    {
        case 1:
        {
            if(!take_or_put)
            {
                ShowPlayerDialog
                (
                    playerid, 2225, DIALOG_STYLE_LIST,
                    "{FF0000}Взять предмет из склада",
                    "{FFFF00}|{FFFFFF} Деньги\n"\
                    "{FFFF00}|{FFFFFF} Материалы\n"\
                    "{FFFF00}|{FFFFFF} Маски\n"\
                    "{FFFF00}|{FFFFFF} Оружие\n"\
                    "{FFFF00}|{FFFFFF} Бронежилет\n"\
                    "{FFFF00}|{FFFFFF} Аптечка",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "type_sklad", 1);
            }else{
                ShowPlayerDialog
                (
                    playerid, 2225, DIALOG_STYLE_LIST,
                    "{FF0000}Положить предмет на склад",
                    "{FFFF00}|{FFFFFF} Деньги\n"\
                    "{FFFF00}|{FFFFFF} Материалы\n"\
                    "{FFFF00}|{FFFFFF} Маски\n"\
                    "{FFFF00}|{FFFFFF} Оружие\n"\
                    "{FFFF00}|{FFFFFF} Бронежилет\n"\
                    "{FFFF00}|{FFFFFF} Аптечка",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "type_sklad", 2);
            }
        }
        case 2:
        {
            if(!take_or_put)
            {
                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите взять (Доступно:%d)", GetFamily(GetPlayerIdFamily(playerid), family_money));
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Взять деньги из склада",
                    f_string144,
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerMoneyEx(playerid))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет денег.");

                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите положить (Доступно:%d)", GetPlayerMoneyEx(playerid));
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Положить деньги на склад",
                    f_string144,
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 2);
        }
        case 3:
        {
            if(!take_or_put)
            {
                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите взять (Доступно:%d)", GetFamily(GetPlayerIdFamily(playerid), family_material));
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Взять материалы из склада",
                    f_string144,
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerData(playerid, P_METALL))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет материалов.");

                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите положить (Доступно:%d)", GetPlayerData(playerid, P_METALL));
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Положить материалы на склад",
                    f_string144,
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 3);
        }
        case 4:
        {
            if(!take_or_put)
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять маску",
                    "Вы хотите взять маску из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerData(playerid, P_MASK))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет маски.");

                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить маску",
                    "Вы хотите положить маску на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 4);
        }
        case 5:
        {
            if(!take_or_put)
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_LIST,
                    "{FF0000}Взять оружие",
                    "Информация\n"\
                    "Взять",
                    "Далее", "Назад"
                );
            }
            else
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_LIST,
                    "{FF0000}Положить оружие",
                    "Информация\n"\
                    "Положить",
                    "Далее", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 5);
        }
        case 6:
        {
            if(!take_or_put)
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять бронежилет",
                    "Вы хотите взять бронежилет из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                new Float:armour;
                
                GetPlayerArmour(playerid, armour);

                if(armour <= 19.9)
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет бронежилета или его прочность меньше 20 процентов.");

                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить бронежилет",
                    "Вы хотите положить бронежилет на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 6);
        }
        case 7:
        {
            if(!take_or_put)
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять аптечку",
                    "Вы хотите взять аптечку из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                ShowPlayerDialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить аптечку",
                    "Вы хотите положить аптечку на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 7);
        }
    }
    return 1;
}

stock UpdateColumnFamilyInt(f, column[], number)
{
	new query[256];

	mysql_format(mysql, query, sizeof query, "UPDATE family SET `%s`=%d WHERE `id`=%d LIMIT 1", column, number, f);
	mysql_query(mysql, query, false);
	return 1;
}

stock DialogFamily(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}

stock ShowDialogAccess(playerid, type, give)
{
    switch(type)
    {
        case 1:
        {
            if(give)
            {
                ShowPlayerDialog
                (
                    playerid, 2231, DIALOG_STYLE_LIST,
                    "{FF0000}Выдать доступ",
                    "1. Выдать доступ ко всему\n"\
                    "2. Доступ к изменению доступов\n"\
                    "3. Доступ к деньгам\n"\
                    "4. Доступ к материалам\n"\
                    "5. Доступ к маскам\n"\
                    "6. Доступ к аптечкам\n"\
                    "7. Доступ к оружию\n"\
                    "8. Доступ к бронежилетам",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "status_dialog_access", 2);
            }
            else
            {
                ShowPlayerDialog
                (
                    playerid, 2231, DIALOG_STYLE_LIST,
                    "{FF0000}Забрать доступ",
                    "1. Забрать доступ ко всему\n"\
                    "2. Доступ к изменению доступов\n"\
                    "3. Доступ к деньгам\n"\
                    "4. Доступ к материалам\n"\
                    "5. Доступ к маскам\n"\
                    "6. Доступ к аптечкам\n"\
                    "7. Доступ к оружию\n"\
                    "8. Доступ к бронежилетам",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "status_dialog_access", 1);
            }
        }
        case 3:
        {
            ShowPlayerDialog
            (
                playerid, 2231, DIALOG_STYLE_INPUT,
                "Настройка доступа",
                "Введите имя или ID игрока для редактирования доступа",
                "Далее",
                "Назад"
            );

            SetPVarInt(playerid, "type_dialog_access", type);
        }
        case 2,4..10:
        {
            if(give)
            {
                ShowPlayerDialog
                (
                    playerid, 2231, DIALOG_STYLE_INPUT,
                    "Настройка доступа",
                    "Введите имя или ID игрока и количество через запятую\n"\
                    "- Количество - это сколько игрок сможет взять того или иного предмета.\n"\
                    "- Пример: Nick_Name, 1000",
                    "Далее",
                    "Назад"
                );
            }else{
                ShowPlayerDialog
                (
                    playerid, 2231, DIALOG_STYLE_INPUT,
                    "Настройка доступа",
                    "Введите имя или ID игрока для редактирования доступа",
                    "Далее",
                    "Назад"
                );
            }

            SetPVarInt(playerid, "type_dialog_access", type);
        }
    }
}



stock UpdateDostupFamily(fam, rang)
{
    if(!(0 <= fam < MAX_FAM) || !(0 <= rang < 5)) return 0;

    new setting[96];
    format(setting, sizeof setting, "%s,%d,%d,%d,%d,%d,%d", family_rang_name[fam][rang], family_rang_dostup[fam][rang][0], 
    family_rang_dostup[fam][rang][1], family_rang_dostup[fam][rang][2], family_rang_dostup[fam][rang][3], 
    family_rang_dostup[fam][rang][4], family_rang_dostup[fam][rang][5]);

    new rang_sql_name[5][7] = {"rang_1","rang_2", "rang_3", "rang_4", "rang_5"};

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE family SET %s = '%e' WHERE id=%d", rang_sql_name[rang], setting, GetFamily(fam, family_database));
    mysql_query(mysql, f_string184, false);

    return 1;
}
CMD:infdos(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        SendClientMessage(playerid, -1, ""c_f_r"У вас нет семьи.");
        return 1;
    }
    
    new rank;
    if(sscanf(params, "d", rank))
    {
        SendClientMessage(playerid, -1, ""c_f_r"Используйте: /infdos [ранг] (1-5)");
        return 1;
    }
    
    if(rank < 1 || rank > 5)
    {
        SendClientMessage(playerid, -1, ""c_f_r"Ранг должен быть от 1 до 5.");
        return 1;
    }
    
    new rank_name[32];
    format(rank_name, sizeof(rank_name), "%s", family_rang_name[f][rank - 1]);
    
    new info[512];
    format(info, sizeof(info),
        "{FF0000}Доступы для ранга %d (%s):\n\n"\
        "{FFFFFF}Принимать игроков: {FFB700}%s\n"\
        "{FFFFFF}Выгонять игроков: {FFB700}%s\n"\
        "{FFFFFF}Изменять ранг: {FFB700}%s\n"\
        "{FFFFFF}Выдавать мут: {FFB700}%s\n"\
        "{FFFFFF}Участвовать в войне: {FFB700}%s\n"\
        "{FFFFFF}Доступ к складу: {FFB700}%s",
        rank, rank_name,
        (family_rang_dostup[f][rank-1][0] == 0) ? "{00FF00}Есть" : "{FF0000}Нет",
        (family_rang_dostup[f][rank-1][1] == 0) ? "{00FF00}Есть" : "{FF0000}Нет",
        (family_rang_dostup[f][rank-1][2] == 0) ? "{00FF00}Есть" : "{FF0000}Нет",
        (family_rang_dostup[f][rank-1][3] == 0) ? "{00FF00}Есть" : "{FF0000}Нет",
        (family_rang_dostup[f][rank-1][4] == 0) ? "{00FF00}Есть" : "{FF0000}Нет",
        (family_rang_dostup[f][rank-1][5] == 0) ? "{00FF00}Есть" : "{FF0000}Нет"
    );
    
   ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{FF0000}Информация о доступах", info, "Закрыть", "");
    
    return 1;
}

stock UpdateAccessPlayerFamily(playerid)
{
    new setting[30];
    format(setting, sizeof setting, "%d,%d,%d,%d,%d,%d,%d", GetPlayerFamily(playerid, ACCESS_GIVE),  GetPlayerFamily(playerid, ACCESS_MONEY), 
    GetPlayerFamily(playerid, ACCESS_ARMOUR),  GetPlayerFamily(playerid, ACCESS_MATERIAL),  GetPlayerFamily(playerid, ACCESS_HEATH_KIT), 
    GetPlayerFamily(playerid, ACCESS_PATRON),  GetPlayerFamily(playerid, ACCESS_MASK));

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE accounts SET family_access = '%s' WHERE id=%d", setting, GetPlayerAccountID(playerid));
    mysql_query(mysql, f_string184, false);

    return 1;   
}

stock PacketIncomingFamily(playerid, Node:JSONObject)
{
    new type;
    JSON_GetInt(JSONObject, "t", type);

    printf("[IPacket:252] Player %d, GUIID 45, Type: %d", playerid, type);
    new f = GetPlayerIdFamily(playerid);

    switch(type)
    {
        case 1: // Квест
        {
            new quest_id;
            JSON_GetInt(JSONObject, "id", quest_id);
            
            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", 1);
            JSON_SetInt(response, "s", 1);
            JSON_SetInt(response, "id", quest_id);
            
            OnPacketIncoming(playerid, 45, response);
            JSON_Cleanup(response);
        }
       case 2: // Автопарк
{
    new s_value;
    JSON_GetInt(JSONObject, "s", s_value);
    
    printf("[FAMILY] Автопарк: s_value = %d", s_value);
    
    if(s_value == 1) // Запрос информации о машине
    {
        printf("[FAMILY] Запрос информации о машине");
        
        new full_json[512];
        JSON_Stringify(JSONObject, full_json, sizeof(full_json));
        printf("[FAMILY] Полный JSON от клиента: %s", full_json);
        
        new car_id = 0;
        
        if(JSON_GetInt(JSONObject, "id", car_id))
        {
            printf("[FAMILY] Через JSON_GetInt получили ID: %d", car_id);
        }
        
        if(car_id == 0)
        {
            new Node:idNode;
            if(JSON_GetObject(JSONObject, "id", idNode))
            {
                JSON_GetNodeInt(idNode, car_id);
                printf("[FAMILY] Через JSON_GetNodeInt получили ID: %d", car_id);
                JSON_Cleanup(idNode);
            }
        }
        
        if(car_id == 0)
        {
            new id_str[16];
            if(JSON_GetString(JSONObject, "id", id_str, sizeof(id_str)))
            {
                car_id = strval(id_str);
                printf("[FAMILY] Через JSON_GetString получили ID: %d", car_id);
            }
        }
        
        if(car_id == 0)
        {
            printf("[FAMILY] Не удалось получить ID машины");
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка, не удалось загрузить транспорт!", "");
            return 1;
        }
        
        new f = GetPlayerIdFamily(playerid);
        printf("[FAMILY] f = %d", f);
        
        if(f == -1)
        {
            printf("[FAMILY] У игрока нет семьи!");
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
            return 1;
        }
        
        new family_db = GetFamily(f, family_database);
        printf("[FAMILY] family_db = %d", family_db);
        
        mysql_format(mysql, f_string64, sizeof f_string64, 
            "SELECT * FROM family_cars WHERE id = %d AND family_owner = %d", 
            car_id, family_db);
        
        printf("[FAMILY] SQL: %s", f_string64);
        
        new Cache:cache = mysql_query(mysql, f_string64);
        
        if(mysql_errno())
        {
            printf("[FAMILY] SQL ERROR: %d", mysql_errno());
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка в SQL-запросе", "");
            cache_delete(cache);
            return 1;
        }
        
        new rows = cache_num_rows();
        printf("[FAMILY] rows = %d", rows);
        
        if(!rows)
        {
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Транспорт не найден.", "");
            cache_delete(cache);
            return 1;
        }
        
        new rang = cache_get_field_content_int(0, "rang");
        new status = GetStatusFamilyCar(car_id);
        new model_id = cache_get_field_content_int(0, "model_id");
        new model_name[64];
        GetVehicleModelName(model_id, model_name, sizeof(model_name));
        
        printf("[FAMILY] Информация о машине: id=%d, name=%s, rang=%d, status=%d", 
            car_id, model_name, rang, status);
        
        new Node:response = JSON_Object();
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 1);
        JSON_SetInt(response, "r", rang);
        JSON_SetInt(response, "d", status);
        JSON_SetInt(response, "m", model_id);
        JSON_SetString(response, "n", model_name);
        JSON_SetInt(response, "g", 0);
        
        new debug_str[2048];
        JSON_Stringify(response, debug_str, sizeof debug_str);
        printf("[FAMILY] ОТВЕТ: %s", debug_str);
        
        OnPacketIncoming(playerid, 45, response);
        
        JSON_Cleanup(response);
        cache_delete(cache);
        printf("[FAMILY] Ответ отправлен");
        return 1;
    }
    else if(s_value == 2) // Действие с машиной
    {
        printf("[FAMILY] Действие с машиной");
        new car_id, action_id, access, Node:response = JSON_Object();
        JSON_GetInt(JSONObject, "m", car_id);
        JSON_GetInt(JSONObject, "id", action_id);
        JSON_GetInt(JSONObject, "r", access);
        
        if(car_id <= 0)
        {
            printf("[FAMILY] Ошибка: неверный ID машины");
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка, попробуйте позже.", "");
            JSON_Cleanup(response);
            return 1;
        }
        
        printf("[FAMILY] car_id=%d, action_id=%d, access=%d", car_id, action_id, access);
        
        new model_id = 0;
        new model_name[64] = "Неизвестно";
        
        mysql_format(mysql, f_string64, sizeof f_string64, 
            "SELECT model_id FROM family_cars WHERE id = %d", car_id);
        new Cache:info_cache = mysql_query(mysql, f_string64);
        if(cache_num_rows())
        {
            model_id = cache_get_field_content_int(0, "model_id");
            GetVehicleModelName(model_id, model_name, sizeof(model_name));
        }
        cache_delete(info_cache);
        
        if(action_id == 1) // загрузить на парковке
        {
            if(LoadFamilyCar(car_id))
            {
                JSON_SetInt(response, "t", 2); 
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 1);
                
                format(f_string144, sizeof f_string144, "%s %s[%d] загрузил автомобиль %s.",
                    family_rang_name[GetPlayerIdFamily(playerid)][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, model_name);
                SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                ShowNotificationNew(playerid, 3, 5, -1, -1, "Автомобиль успешно загружен.", "");
            }
            else
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка загрузки транспорта", "");
            } 
        }
        else if(action_id == 4) // выгрузить
        {
            new vehicleid = GetVehicleFamilyCar(car_id);
            
            if(vehicleid != INVALID_VEHICLE_ID && GetVehicleDriver(vehicleid) == INVALID_PLAYER_ID && GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Транспорт занят", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
            }
            else if(UnLoadFamilyCar(car_id))
            {
                JSON_SetInt(response, "t", 2); 
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 1);
                
                format(f_string144, sizeof f_string144, "%s %s[%d] выгрузил автомобиль %s",
                    family_rang_name[GetPlayerIdFamily(playerid)][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, model_name);
                SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                ShowNotificationNew(playerid, 3, 5, -1, -1, "Вы успешно выгрузили транспорт", "");
            }
            else
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка выгрузки транспорта", "");
            }
        }
        else if(action_id == 0) // отметить на GPS
        {
            new Float:pos_x, Float:pos_y, Float:pos_z;
            new status = GetStatusFamilyCar(car_id);
            new vehicleid = GetVehicleFamilyCar(car_id);
            
            if(status == 1 && vehicleid != INVALID_VEHICLE_ID)
            {
                GetVehiclePos(vehicleid, pos_x, pos_y, pos_z);
                printf("[FAMILY] Машина загружена, координаты: %f, %f, %f", pos_x, pos_y, pos_z);
            }
            else
            {
                mysql_format(mysql, f_string64, sizeof f_string64, 
                    "SELECT pos_x, pos_y, pos_z FROM family_cars WHERE id = %d", car_id);
                new Cache:cache = mysql_query(mysql, f_string64);
                if(cache_num_rows())
                {
                    pos_x = cache_get_field_content_float(0, "pos_x");
                    pos_y = cache_get_field_content_float(0, "pos_y");
                    pos_z = cache_get_field_content_float(0, "pos_z");
                    printf("[FAMILY] Машина выгружена, координаты из БД: %f, %f, %f", pos_x, pos_y, pos_z);
                }
                cache_delete(cache);
            }
            EnablePlayerGPS(playerid, 55, pos_x, pos_y, pos_z, "Местоположение парковки семейного транспорта отмечена на GPS");
            JSON_SetInt(response, "t", 2);
            JSON_SetInt(response, "s", 2);
            JSON_SetInt(response, "d", 1);
        }
        else if(action_id == 7) // сбросить парковку
        {
            printf("[FAMILY] Сброс парковки для машины ID: %d", car_id);
            
            new f = GetPlayerIdFamily(playerid);
            if(f == -1)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Сброс парковки доступен только лидеру семьи.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            new vehicleid = GetVehicleFamilyCar(car_id);
            
            if(vehicleid != INVALID_VEHICLE_ID)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Невозможно сбросить парковку. Сначала выгрузите транспорт.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            new Float:new_pos_x = 2501.752;
            new Float:new_pos_y = -760.497;
            new Float:new_pos_z = 11.358;
            new Float:new_angle = 0.0;
            
            new query[256];
            format(query, sizeof(query), 
                "UPDATE family_cars SET pos_x = %f, pos_y = %f, pos_z = %f, angle = %f WHERE id = %d",
                new_pos_x, new_pos_y, new_pos_z, new_angle, car_id);
            
            printf("[FAMILY] SQL: %s", query);
            
            mysql_query(mysql, query, false);
            
            if(!mysql_errno())
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 1);
                
                format(f_string144, sizeof f_string144, "%s сбросил парковку %s на стандартную.",
                    GetPlayerNameEx(playerid), model_name);
                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                
                ShowNotificationNew(playerid, 3, 5, -1, -1, "Парковка была успешно сброшена", "");
                
                printf("[FAMILY] Парковка машины %d сброшена на координаты: %f, %f, %f", 
                    car_id, new_pos_x, new_pos_y, new_pos_z);
            }
            else
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка сброса парковки", "");
                printf("[FAMILY] SQL ERROR при сбросе парковки: %d", mysql_errno());
            }
        }
        else if(action_id == 3) // изменить ранг
        {
            printf("[FAMILY] Изменение ранга для машины ID: %d", car_id);
            
            new f = GetPlayerIdFamily(playerid);
            if(f == -1)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Изменение ранга транспорта доступно только лидеру семьи.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            new vehicleid = GetVehicleFamilyCar(car_id);
            
            if(vehicleid != INVALID_VEHICLE_ID)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Сначала выгрузите транспорт.", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            new current_rang = 0;
            mysql_format(mysql, f_string64, sizeof f_string64, 
                "SELECT rang FROM family_cars WHERE id = %d", car_id);
            new Cache:rang_cache = mysql_query(mysql, f_string64);
            if(cache_num_rows())
            {
                current_rang = cache_get_field_content_int(0, "rang");
            }
            cache_delete(rang_cache);
            
            printf("[FAMILY] Текущий ранг машины %d: %d", car_id, current_rang);
            printf("[FAMILY] access = %d (0 - уменьшить, 1 - увеличить)", access);
            
            new new_rang = current_rang;
            
            if(access == 0)
            {
                if(current_rang > 1)
                {
                    new_rang = current_rang - 1;
                    printf("[FAMILY] Уменьшаем ранг с %d на %d", current_rang, new_rang);
                    ShowNotificationNew(playerid, 3, 5, -1, -1, "Ранг использования автомобиля был успешно изменен", "");
                }
                else
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "В данной машине уже минимальный ранг.", "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 2);
                    JSON_SetInt(response, "d", 0);
                    OnPacketIncoming(playerid, 45, response);
                    JSON_Cleanup(response);
                    return 1;
                }
            }
            else if(access == 1)
            {
                if(current_rang < 5)
                {
                    new_rang = current_rang + 1;
                    printf("[FAMILY] Увеличиваем ранг с %d на %d", current_rang, new_rang);
                    ShowNotificationNew(playerid, 3, 5, -1, -1, "Ранг использования автомобиля был успешно изменен", "");
                }
                else
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "В данной машине уже максимальный ранг.", "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 2);
                    JSON_SetInt(response, "d", 0);
                    OnPacketIncoming(playerid, 45, response);
                    JSON_Cleanup(response);
                    return 1;
                }
            }
            
            mysql_format(mysql, f_string64, sizeof f_string64, 
                "UPDATE family_cars SET rang = %d WHERE id = %d", new_rang, car_id);
            mysql_query(mysql, f_string64, false);
            
            if(!mysql_errno())
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 1);
                JSON_SetInt(response, "new_rang", new_rang);
                
                format(f_string144, sizeof f_string144, "%s изменил доступ к %s с %d на %d ранг.",
                    GetPlayerNameEx(playerid), model_name, current_rang, new_rang);
                SendFamilyLog(type_log_dostup, playerid, -1, f_string144);
            }
            else
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка изменения ранга", "");
            }
        }
        else if(action_id == 2) // вернуть из семьи (забрать машину)
        {
            printf("[FAMILY] Возврат транспорта из семьи, машина ID: %d", car_id);
            
            if(GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Забрать транспорт из семьи может только лидер", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(GetStatusFamilyCar(car_id))
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Невозможно забрать транспорт, сначала выгрузите его", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if((GetPlayerOwnableCars(playerid) + 1) > GetPlayerCarSlots(playerid))
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "У вас нет свободных слотов для транспорта", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(MoveFamilyCar(car_id, playerid))
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 1);
                
                format(f_string144, sizeof f_string144, "%s забрал транспорт %s из семьи",
                    GetPlayerNameEx(playerid), model_name);
                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                
                ShowNotificationNew(playerid, 3, 5, -1, -1, "Вы успешно удалили авто из семьи.", "");
            }
            else
            {
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 2);
                JSON_SetInt(response, "d", 0);
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка удаления авто из семьи.", "");
            }
        }
        else if(action_id == 5) // загрузить в гараж
        {
            ShowNotificationNew(playerid, 2, 5, -1, -1, "action id 5");
            JSON_SetInt(response, "t", 2);
            JSON_SetInt(response, "s", 5);
            JSON_SetInt(response, "d", 1);
        }
        else if(action_id == 6) // загрузить на месте выгрузки
{
    printf("[FAMILY] Загрузка на месте выгрузки для машины ID: %d", car_id);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "d", 0);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    
    // Проверяем, загружена ли уже машина
    if(GetStatusFamilyCar(car_id))
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Транспорт уже загружен", "");
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "d", 0);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    
    // Получаем ранг доступа к машине
    new rang = 0;
    mysql_format(mysql, f_string64, sizeof f_string64, 
        "SELECT rang FROM family_cars WHERE id = %d", car_id);
    new Cache:rang_cache = mysql_query(mysql, f_string64);
    if(cache_num_rows())
    {
        rang = cache_get_field_content_int(0, "rang");
    }
    cache_delete(rang_cache);
    
    // Проверяем ранг игрока
    if(GetPlayerRangFamily(playerid) < rang)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Ваш ранг не позволяет загрузить этот транспорт", "");
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "d", 0);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    
    // Загружаем машину
    if(LoadFamilyCarLastPos(car_id))
    {
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "d", 1);
        
        format(f_string144, sizeof f_string144, "%s %s[%d] загрузил автомобиль %s.",
                    family_rang_name[GetPlayerIdFamily(playerid)][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, model_name);
                SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                ShowNotificationNew(playerid, 3, 5, -1, -1, "Автомобиль успешно загружен.", "");
    }
    else
    {
        JSON_SetInt(response, "t", 2);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "d", 0);
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка загрузки транспорта", "");
    }
}
        
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
    }
    else // Получение списка машин
    {
        printf("[FAMILY] Получение списка машин");
        new Node:response = JSON_Object();
        new f = GetPlayerIdFamily(playerid);
        printf("[FAMILY] f = %d", f);
        
        if(f == -1)
        {
            printf("[FAMILY] У игрока нет семьи!");
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
            return 1;
        }
        
        new family_db = GetFamily(f, family_database);
        printf("[FAMILY] family_db = %d", family_db);
        
        mysql_format(mysql, f_string64, sizeof f_string64, 
            "SELECT * FROM family_cars WHERE family_owner = %d", 
            family_db);
        
        printf("[FAMILY] SQL: %s", f_string64);
        
        new Cache:cache = mysql_query(mysql, f_string64);
        
        if(mysql_errno())
        {
            printf("[FAMILY] SQL ERROR: %d", mysql_errno());
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка в SQL-запросе", "");
            cache_delete(cache);
            return 1;
        }
        
        new rows = cache_num_rows();
        printf("[FAMILY] rows = %d", rows);
        
        if(rows == 0)
{
    printf("[FAMILY] Автопарк пуст (0 машин)");
    ShowNotificationNew(playerid, 2, 5, -1, -1, "Автопарк пуст.", "");
    
    // Отправляем пустой массив, а не уничтожаем ответ
    JSON_SetInt(response, "t", 2);
    JSON_SetArray(response, "id", JSON_Array());  // пустой массив
    JSON_SetArray(response, "n", JSON_Array());
    JSON_SetArray(response, "r", JSON_Array());
    JSON_SetArray(response, "st", JSON_Array());
    JSON_SetInt(response, "g", 0);
    
    OnPacketIncoming(playerid, 45, response);
    
    cache_delete(cache);
    JSON_Cleanup(response);
    return 1;
}
        
        new Node:carsArray = JSON_Array();
        new Node:carsnameArray = JSON_Array();
        new Node:rangArray = JSON_Array();
        new Node:statusArray = JSON_Array();
        
        for(new i; i < rows; i++)
        {
            new car_id = cache_get_field_content_int(i, "id");
            new model_id = cache_get_field_content_int(i, "model_id");
            new rang = cache_get_field_content_int(i, "rang");
            new status = GetStatusFamilyCar(car_id);
            
            new model_name[64];
            GetVehicleModelName(model_id, model_name, sizeof(model_name));
            
            printf("[FAMILY] Машина %d: id=%d, model=%d, name=%s, rang=%d, status=%d", 
                i, car_id, model_id, model_name, rang, status);
            
            new Node:carNode = JSON_Array(JSON_Int(car_id));
            new Node:carnameNode = JSON_Array(JSON_String(model_name));
            new Node:rangNode = JSON_Array(JSON_Int(rang));
            new Node:statusNode = JSON_Array(JSON_Int(status));
            
            carsArray = JSON_Append(carsArray, carNode);
            carsnameArray = JSON_Append(carsnameArray, carnameNode);
            rangArray = JSON_Append(rangArray, rangNode);
            statusArray = JSON_Append(statusArray, statusNode);
        }
        
        
        JSON_SetInt(response, "t", 2);
        JSON_SetArray(response, "id", carsArray);
        JSON_SetArray(response, "n", carsnameArray);
        JSON_SetArray(response, "r", rangArray);
        JSON_SetArray(response, "st", statusArray);
        JSON_SetInt(response, "g", 0);
        
        new debug_str[2048];
        JSON_Stringify(response, debug_str, sizeof debug_str);
        printf("[FAMILY] ОТВЕТ: %s", debug_str);
        
        OnPacketIncoming(playerid, 45, response);
        
        JSON_Cleanup(carsArray);
        JSON_Cleanup(response);
        
        cache_delete(cache);
        printf("[FAMILY] Ответ отправлен");
    }
}
        case 3: // Магазин
{
    new item_id;
    JSON_GetInt(JSONObject, "id", item_id);
    printf("[FAMILY] Магазин: item_id=%d", item_id);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        return 1;
    }
    
    
    new item_price = 0;
    new item_object_id = 0;
    new item_server_id = 0;
    new item_title[64];
    new item_type_id = 0;
    
    // Данные из вашего JSON Shop
    switch(item_id)
    {
        case 0: // Кейс
        {
            item_price = 80;
            item_object_id = 18526;
            item_server_id = 389;
            format(item_title, sizeof(item_title), "Кейс");
            item_type_id = 3;
        }
        case 1:
        {
            item_price = 100;
            item_object_id = 7378;
            item_server_id = 442;
            format(item_title, sizeof(item_title), "Катана");
            item_type_id = 0;
        }
        case 2:
        {
            item_price = 60;
            item_object_id = 7344;
            item_server_id = 408;
            format(item_title, sizeof(item_title), "Панама Stone");
            item_type_id = 0;
        }
        case 3:
        {
            item_price = 100;
            item_object_id = 7374;
            item_server_id = 438;
            format(item_title, sizeof(item_title), "Медведь");
            item_type_id = 0;
        }
        case 4:
        {
            item_price = 100;
            item_object_id = 7387;
            item_server_id = 451;
            format(item_title, sizeof(item_title), "Акула");
            item_type_id = 0;
        }
        case 5:
        {
            item_price = 100;
            item_object_id = 7385;
            item_server_id = 449;
            format(item_title, sizeof(item_title), "Лодка");
            item_type_id = 0;
        }
        case 6:
        {
            item_price = 50;
            item_object_id = 7397;
            item_server_id = 461;
            format(item_title, sizeof(item_title), "Пакет");
            item_type_id = 0;
        }
        case 7:
        {
            item_price = 60;
            item_object_id = 7390;
            item_server_id = 454;
            format(item_title, sizeof(item_title), "Гитара");
            item_type_id = 0;
        }
        default:
        {
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Предмет не найден", "");
            return 1;
        }
    }
    
    // Проверка на наличие средств
    new current_tokens = GetPlayerData(playerid, P_FAMILY_TOKEN);
    
    if(current_tokens < item_price)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Недостаточно семейных токенов!", "");
        
        new Node:response = JSON_Object();
        JSON_SetInt(response, "t", 3);
        JSON_SetInt(response, "s", 0);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    
    // ЛОГИКА ДЛЯ КЕЙСА (type_id == 3)
    if(item_id == 0)
    {
        // Массив доступных предметов из кейса (id предметов из магазина)
        new case_items[] = {1, 2, 3, 4, 5, 6, 7}; // ID предметов которые могут выпасть
        new case_items_count = sizeof(case_items);
        
        // Выбираем рандомный предмет
        new random_index = random(case_items_count);
        new reward_item_id = case_items[random_index];
        
        // Получаем данные выпавшего предмета
        new reward_price = 0;
        new reward_server_id = 0;
        new reward_title[64];
        new reward_object_id = 0;
        
        switch(reward_item_id)
        {
            case 1:
            {
                reward_price = 100;
                reward_server_id = 442;
                format(reward_title, sizeof(reward_title), "Катана");
                reward_object_id = 7378;
            }
            case 2:
            {
                reward_price = 60;
                reward_server_id = 408;
                format(reward_title, sizeof(reward_title), "Панама Stone");
                reward_object_id = 7344;
            }
            case 3:
            {
                reward_price = 100;
                reward_server_id = 438;
                format(reward_title, sizeof(reward_title), "Медведь");
                reward_object_id = 7374;
            }
            case 4:
            {
                reward_price = 100;
                reward_server_id = 451;
                format(reward_title, sizeof(reward_title), "Акула");
                reward_object_id = 7387;
            }
            case 5:
            {
                reward_price = 100;
                reward_server_id = 449;
                format(reward_title, sizeof(reward_title), "Лодка");
                reward_object_id = 7385;
            }
            case 6:
            {
                reward_price = 50;
                reward_server_id = 461;
                format(reward_title, sizeof(reward_title), "Пакет");
                reward_object_id = 7397;
            }
            case 7:
            {
                reward_price = 60;
                reward_server_id = 454;
                format(reward_title, sizeof(reward_title), "Гитара");
                reward_object_id = 7390;
            }
        }
        
        // Выдаём предмет в актуальную систему Inventory11.
        new reward_slot = Inventory11_AddItemToDatabase(playerid, reward_server_id, reward_object_id, 1, reward_object_id, 0);
        if(reward_slot == -1)
        {
            ShowNotificationNew(playerid, 2, 7, -1, -1, "Нет места или превышен вес инвентаря!", "");
            return 1;
        }
        
        // Показываем диалог с результатом
        new dialog_text[512];
        format(dialog_text, sizeof(dialog_text),
            "{FF0000}Вы открыли кейс и получили:\n\n"\
            "{FFFFFF}Предмет: {FFB700}%s\n"\
            "{FFFFFF}Ценность: {FFB700}%d токенов\n\n"\
            "{FFFFFF}Предмет добавлен в инвентарь!",
            reward_title, reward_price);
        
        ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{FF0000}Результат кейса", dialog_text, "Закрыть", "");
        
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Кейс открыт! Проверьте инвентарь.", "");
        
        // Списываем токены (только за кейс)
        SetPlayerData(playerid, P_FAMILY_TOKEN, current_tokens - item_price);
        UpdatePlayerDatabaseInt(playerid, "fam_token", GetPlayerData(playerid, P_FAMILY_TOKEN));
        
        // Отправляем ответ об успешной покупке
        new Node:response = JSON_Object();
        JSON_SetInt(response, "t", 3);
        JSON_SetInt(response, "s", 1);
        JSON_SetInt(response, "na", GetPlayerData(playerid, P_FAMILY_TOKEN));
        JSON_SetInt(response, "tp", 0);
        
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        
        return 1;
    }
    else // Обычный предмет (не кейс)
    {
        // Добавляем предмет в актуальную систему Inventory11.
        new item_slot = Inventory11_AddItemToDatabase(playerid, item_server_id, item_object_id, 1, item_object_id, 0);
        if(item_slot == -1)
        {
            ShowNotificationNew(playerid, 2, 7, -1, -1, "Нет места или превышен вес инвентаря!", "");
            return 1;
        }
        
        // Списываем токены
        SetPlayerData(playerid, P_FAMILY_TOKEN, current_tokens - item_price);
        UpdatePlayerDatabaseInt(playerid, "fam_token", GetPlayerData(playerid, P_FAMILY_TOKEN));
        
        // Отправляем ответ об успешной покупке
        new Node:response = JSON_Object();
        JSON_SetInt(response, "t", 3);
        JSON_SetInt(response, "s", 1);
        JSON_SetInt(response, "na", GetPlayerData(playerid, P_FAMILY_TOKEN));
        JSON_SetInt(response, "tp", 0);
        
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);

        ShowNotificationNew(playerid, 2, 5, -1, -1, "Предмет добавлен в инвентарь!", "");
        
        return 1;
    }
}
        case 4: // Улучшения
        {
            new s_value, id_value, f = GetPlayerIdFamily(playerid);
            JSON_GetInt(JSONObject, "s", s_value);
            JSON_GetInt(JSONObject, "id", id_value);
            
            if(f == -1)
            {
           	ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
          	 return 1;
            }
            
            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", 4);
            
            if(s_value == 1)
            {
                 switch(id_value) 
                 {
                		case 0:
               		 {
              			if(GetFamily(f, family_money) >= price_up_sklad[GetFamily(f, family_lvl_storage)])
                        {
                            AddFamily(f, family_money, -, price_up_sklad[GetFamily(f, family_lvl_storage)]);
                            SetFamily(f, family_lvl_storage, GetFamily(f, family_lvl_storage)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_storage", GetFamily(f, family_lvl_storage));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                            
                            JSON_SetInt(response, "s", 1); 
                            JSON_SetInt(response, "id", 0); 

                            format(f_string144, sizeof f_string144, "%s улучшил склад до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_storage));
                            SendFamilyMessage(f, f_string144);
                        }
                        else 
						{
						 new fmt[512];
						format(fmt, sizeof(fmt), "На складе не хватает %d.", price_up_sklad[GetFamily(f, family_lvl_storage)]-GetFamily(f, family_money));
						ShowNotificationNew(playerid, 2, 5, -1, -1, fmt, ""); 
						JSON_SetInt(response, "s", 0);
						} 
              		  } 
             		   case 1:
            			{
           			  if(GetFamily(f, family_money) >= price_up_weapon[GetFamily(f, family_lvl_weapon)])
                        {
                            AddFamily(f, family_money, -, price_up_weapon[GetFamily(f, family_lvl_weapon)]);
                            SetFamily(f, family_lvl_weapon, GetFamily(f, family_lvl_weapon)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_weapon", GetFamily(f, family_lvl_weapon));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                            
                            JSON_SetInt(response, "s", 1); 
                            JSON_SetInt(response, "id", 1); 

                            format(f_string144, sizeof f_string144, "%s улучшил оружие до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_weapon));
                            SendFamilyMessage(f, f_string144);
                        }
                        else 
						{
						 new fmt[512];
						format(fmt, sizeof(fmt), "На складе не хватает %d.", price_up_sklad[GetFamily(f, family_lvl_weapon)]-GetFamily(f, family_money));
						ShowNotificationNew(playerid, 2, 5, -1, -1, fmt, ""); 
						JSON_SetInt(response, "s", 0);
						}
           			 } 
          			  case 2:
            			{
           			  if(GetFamily(f, family_money) >= price_up_compound[GetFamily(f, family_lvl_compound)])
                        {
                            AddFamily(f, family_money, -, price_up_compound[GetFamily(f, family_lvl_compound)]);
                            SetFamily(f, family_lvl_compound, GetFamily(f, family_lvl_compound)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_compound", GetFamily(f, family_lvl_compound));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                            
                            JSON_SetInt(response, "s", 1); 
                            JSON_SetInt(response, "id", 2); 

                            format(f_string144, sizeof f_string144, "%s улучшил состав до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_compound));
                            SendFamilyMessage(f, f_string144);
                        }
                        else 
						{
						 new fmt[512];
						format(fmt, sizeof(fmt), "На складе недостаточно средств.");
						ShowNotificationNew(playerid, 2, 5, -1, -1, fmt, ""); 
						JSON_SetInt(response, "s", 0);
						}
           			 } 
                 }
                 OnPacketIncoming(playerid, 45, response);
                 JSON_Cleanup(response);
                 return 1;
            }
            else
            {
           	 JSON_SetInt(response, "s", 3); 
                JSON_SetInt(response, "m", GetFamily(f, family_money));
                
                new Node:upgradesNode = JSON_Array(
                    JSON_Int(GetFamily(f, family_lvl_storage)),
                    JSON_Int(GetFamily(f, family_lvl_weapon)),
                    JSON_Int(GetFamily(f, family_lvl_compound))
                );
                
                JSON_SetArray(response, "y", upgradesNode);
                OnPacketIncoming(playerid, 45, response);
                JSON_Cleanup(response);
                JSON_Cleanup(upgradesNode);
                return 1;
            }
        }
        case 5:
{
    new id_value, s_value, r_value, k_value, n_value;
    JSON_GetInt(JSONObject, "id", id_value);
    JSON_GetInt(JSONObject, "s", s_value);
    JSON_GetInt(JSONObject, "r", r_value);
    JSON_GetInt(JSONObject, "k", k_value);
    JSON_GetInt(JSONObject, "n", n_value);
    
    printf("[FAMILY] case 5: id=%d, s=%d, r=%d, k=%d, n=%d", id_value, s_value, r_value, k_value, n_value);
    
    new Node:response = JSON_Object();
    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", id_value);
    
    if(id_value == 0)
    {
        printf("[FAMILY] Отправка главного меню (id=0)");
        
        JSON_SetInt(response, "t", 5);
        JSON_SetInt(response, "r", GetFamily(GetPlayerIdFamily(playerid), family_reputation));
        JSON_SetInt(response, "am", GetFamily(GetPlayerIdFamily(playerid), family_count_people));
        JSON_SetInt(response, "s", GetPlayerSkinEx(playerid));
        
        new Node:myNode = JSON_Array(JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_money)), JSON_Int(count_money_level[GetFamily(GetPlayerIdFamily(playerid), family_lvl_storage)-1]));
        new Node:mkNode = JSON_Array(JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_material)), JSON_Int(count_material_level[GetFamily(GetPlayerIdFamily(playerid), family_lvl_storage)-1]));
        new Node:msNode = JSON_Array(JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_mask)), JSON_Int(count_mask_level[GetFamily(GetPlayerIdFamily(playerid), family_lvl_storage)-1]));
        new Node:kbNode = JSON_Array(JSON_Int(0), JSON_Int(0));
        new Node:pnNode = JSON_Array(JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_patron)), JSON_Int(count_patron_level[GetFamily(GetPlayerIdFamily(playerid), family_lvl_weapon)-1]));
        new Node:btNode = JSON_Array(JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_armour)), JSON_Int(count_armour_level[GetFamily(GetPlayerIdFamily(playerid), family_lvl_storage)-1]));
        new Node:ugNode = JSON_Array(
            JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_lvl_storage)), JSON_Int(7),
            JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_lvl_weapon)), JSON_Int(7),
            JSON_Int(GetFamily(GetPlayerIdFamily(playerid), family_lvl_compound)), JSON_Int(7)
        );
        
        JSON_SetArray(response, "ug", ugNode);
        JSON_SetArray(response, "my", myNode);
        JSON_SetArray(response, "ms", msNode);
        JSON_SetArray(response, "mk", mkNode);
        JSON_SetArray(response, "kb", kbNode);
        JSON_SetArray(response, "bt", btNode);
        JSON_SetArray(response, "pn", pnNode);
        
        OnPacketIncoming(playerid, 45, response);
        
        JSON_Cleanup(myNode);
        JSON_Cleanup(mkNode);
        JSON_Cleanup(kbNode);
        JSON_Cleanup(pnNode);
        JSON_Cleanup(ugNode);
        JSON_Cleanup(response);
        return 1;
    }
    else if(id_value == 1)
    {
        printf("[FAMILY] Настройка рангов/цветов (id=1), s=%d", s_value);
        
        if(s_value == 1) // Переименование ранга
{
    new ranksPosition;
    new newRankName[32];
    utf8_to_cp1251(newRankName);
    JSON_GetInt(JSONObject, "r", ranksPosition);
    JSON_GetString(JSONObject, "n", newRankName, sizeof(newRankName));
    
    printf("Ранг: %d, Название: %s", ranksPosition, newRankName);

    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    if(GetPlayerRangFamily(playerid) != 5)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Доступно только лидеру семьи.", "");
        JSON_Cleanup(response);
        return 1;
    }
  
    new len = strlen(newRankName);
    if(len < 3 || len > 24)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Название ранга должно быть от 3 до 24 символов.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    if(strfind(newRankName, ",") != -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Название ранга не должно содержать запятую.", "");
        JSON_Cleanup(response);
        return 1;
    }
  
    format(family_rang_name[f][ranksPosition - 1], 24, newRankName);
   
    UpdateDostupFamily(f, ranksPosition - 1);
   
    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "n", 1);  
    JSON_SetInt(response, "r", ranksPosition);
    
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    
    
    ShowNotificationNew(playerid, 2, 5, -1, -1, "Название ранга изменено.", "");
    
    return 1;
}
else if(s_value == 2) // Изменение доступа
{
    new access_value;
    JSON_GetInt(JSONObject, "n", access_value);
    printf("[FAMILY] ========== ИЗМЕНЕНИЕ ДОСТУПА ==========");
    printf("[FAMILY] Параметры: r=%d, k=%d, n=%d", r_value, k_value, access_value);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        printf("[FAMILY] ОШИБКА: Игрок не состоит в семье!");
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    new player_rang = GetPlayerRangFamily(playerid);
    printf("[FAMILY] Ранг игрока: %d", player_rang);
    
    if(player_rang != 5)
    {
        printf("[FAMILY] ОШИБКА: Недостаточно прав!");
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Изменять доступы может только лидер семьи.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    if(r_value >= 1 && r_value <= 5 && k_value >= 0 && k_value <= 5)
    {
        printf("[FAMILY] Доступ изменяется для: ранга %d, доступа %d", r_value, k_value);
        
        // КАСКАДНОЕ ИЗМЕНЕНИЕ
        if(access_value == 1) // ВКЛЮЧИТЬ доступ
        {
            // Включаем для выбранного ранга и ВСЕХ ВЫШЕ
            for(new i = r_value - 1; i < 5; i++)
            {
                family_rang_dostup[f][i][k_value] = 0;
                UpdateDostupFamily(f, i);
            }
        }
        else // ВЫКЛЮЧИТЬ доступ
        {
            // Выключаем для выбранного ранга и ВСЕХ НИЖЕ
            for(new i = 0; i <= r_value - 1; i++)
            {
                family_rang_dostup[f][i][k_value] = 1;
                UpdateDostupFamily(f, i);
            }
        }
        
        
        // ОТВЕТ КАК РАНЬШЕ
        JSON_SetInt(response, "t", 5);
        JSON_SetInt(response, "id", 1);
        JSON_SetInt(response, "s", 2);
        JSON_SetInt(response, "n", 1);
        JSON_SetInt(response, "r", r_value);
        JSON_SetInt(response, "k", k_value);
        JSON_SetInt(response, "b", access_value);
    }
    else
    {
        printf("[FAMILY] ОШИБКА: Неверные параметры!");
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Неверные параметры доступа", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
        else if(s_value == 3) // Установка цвета
{
    printf("[FAMILY] Установка цвета, r=%d", r_value);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    // Проверка, что игрок имеет права изменять цвет (только лидер)
    if(GetPlayerRangFamily(playerid) != 5)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Изменять цвет семьи может только лидер.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    // Проверка, что цвет существует (0-17)
    if(r_value >= 0 && r_value <= 17)
    {
        SetFamily(f, family_color, r_value);
        UpdateColumnFamilyInt(GetFamily(f, family_database), "color", r_value);

        foreach(new i : Player)
        {
            if(GetPlayerIdFamily(i) != f) continue;

            format(f_string144, sizeof f_string144, "%sСемья:{FFFFFF} %s", family_type_color[GetFamily(f, family_color)], GetFamily(f, family_name));
            if(IsValidDynamic3DTextLabel(GetPlayerFamily(i, TEXT_FAMILY)))
                UpdateDynamic3DTextLabelText(GetPlayerFamily(i, TEXT_FAMILY), -1, f_string144);
        }
        
        JSON_SetInt(response, "t", 5);
        JSON_SetInt(response, "s", 3);
        JSON_SetInt(response, "n", 1);
        JSON_SetInt(response, "r", r_value);
    }
    else
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Неверный ID цвета!", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
else // Получение списка рангов
{
    printf("[FAMILY] Получение списка рангов");
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "st", 1);
    JSON_SetInt(response, "cl", GetFamily(f, family_color));
    
    // Названия рангов
    new Node:ranksArray = JSON_Array(
        JSON_String(family_rang_name[f][0]), 
        JSON_String(family_rang_name[f][1]), 
        JSON_String(family_rang_name[f][2]),
        JSON_String(family_rang_name[f][3]),
        JSON_String(family_rang_name[f][4])
    );
    
    // Массив доступов (6 значений)
    new Node:dostupArray = JSON_Array();
    
    for(new d = 0; d < 6; d++)
    {
        new min_rank = 0;
        // Ищем с 1 ранга вверх
        for(new i = 0; i < 5; i++)
        {
            if(family_rang_dostup[f][i][d] == 0) // 0 - разрешено
            {
                min_rank = i + 1;
                break;
            }
        }
        
        // ЕСЛИ НИ ОДИН РАНГ НЕ НАЙДЕН (min_rank = 0), ставим 5 (только лидер) или 1 (все)
        // Чтобы доступ не горел включённым для всех, ставь 5 - только лидер
        if(min_rank == 0) min_rank = 5; // или 1, в зависимости от того, кому ты хочешь дать доступ
        
        printf("[FAMILY] Доступ %d: минимальный ранг = %d", d, min_rank);
        
        new Node:dostupNode = JSON_Array(JSON_Int(min_rank));
        dostupArray = JSON_Append(dostupArray, dostupNode);
    }
    
    JSON_SetArray(response, "r", ranksArray);
    JSON_SetArray(response, "rp", dostupArray);
    
    new otvet[2054];
    JSON_Stringify(response, otvet, sizeof(otvet));
    printf("[FAMILY] ответ: %s", otvet);
    
    OnPacketIncoming(playerid, 45, response);
    
    JSON_Cleanup(ranksArray);
    JSON_Cleanup(dostupArray);
    JSON_Cleanup(response);
    
    return 1;
}
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    else if(id_value == 2)
    {
        printf("[FAMILY] Управление игроками (id=2), s=%d", s_value);
        
        if(s_value == 1)
        {
            new players_nick[24];
            JSON_GetString(JSONObject, "n", players_nick, sizeof(players_nick));
            printf("[FAMILY] Информация об игроке: %s", players_nick);
            SetPVarString(playerid, "last_selected_player", players_nick);
            
            new f = GetPlayerIdFamily(playerid);
            if(f == -1)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
                JSON_Cleanup(response);
                return 1;
            }
            
            new family_db = GetFamily(f, family_database);
            
            mysql_format(mysql, f_string184, sizeof f_string184,
                "SELECT id, family_rang, family_mute, level, skin, phone FROM accounts WHERE family_id = %d AND name = '%e'",
                family_db, players_nick);
            
            printf("[FAMILY] SQL: %s", f_string184);
            
            new Cache:cache = mysql_query(mysql, f_string184);
            
            if(mysql_errno())
            {
                printf("[FAMILY] SQL ERROR: %d", mysql_errno());
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка SQL", "");
                cache_delete(cache);
                JSON_Cleanup(response);
                return 1;
            }
            
            new rows = cache_num_rows();
            printf("[FAMILY] Найдено строк: %d", rows);
            
            if(rows == 0)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Игрок не найден в семье", "");
                cache_delete(cache);
                JSON_Cleanup(response);
                return 1;
            }
            
            new target_account_id = cache_get_field_content_int(0, "id");
            new family_rang = cache_get_field_content_int(0, "family_rang");
            new family_mute = cache_get_field_content_int(0, "family_mute");
            new level = cache_get_field_content_int(0, "level");
            new skin_id = cache_get_field_content_int(0, "skin");
            new phone = cache_get_field_content_int(0, "phone");
            
            printf("[FAMILY] Данные из БД: id=%d, rang=%d, mute=%d, level=%d, skin=%d, phone=%d",
                target_account_id, family_rang, family_mute, level, skin_id, phone);
            
            cache_delete(cache);
            
            new rank_name[32];
            if(family_rang >= 1 && family_rang <= 5)
            {
                format(rank_name, sizeof(rank_name), "%s", family_rang_name[f][family_rang - 1]);
            }
            else
            {
                format(rank_name, sizeof(rank_name), "Рядовой");
            }
            
            new status = 0;
            new mute_time = family_mute;
            new bool:is_online = false;
            
            foreach(new p : Player)
            {
                if(IsPlayerConnected(p) && GetPlayerAccountID(p) == target_account_id)
                {
                    is_online = true;
                    status = 1;
                    
                    new player_mute = GetPlayerFamily(p, MUTE_FAMILY);
                    if(player_mute > 0 && player_mute > gettime())
                    {
                        status = 2;
                        mute_time = player_mute - gettime();
                    }
                    break;
                }
            }
            
            if(!is_online && family_mute > 0 && family_mute > gettime())
            {
                status = 2;
                mute_time = family_mute - gettime();
            }
            
            new reprimands = 0;
            if(mute_time > 0)
            {
                new mute_minutes = mute_time / 60;
                if(mute_minutes > 60) reprimands = 3;
                else if(mute_minutes > 30) reprimands = 2;
                else reprimands = 1;
            }
            
            new Node:infoResponse = JSON_Object();
            JSON_SetInt(infoResponse, "t", 5);
            JSON_SetInt(infoResponse, "id", 2);
            JSON_SetInt(infoResponse, "s", 1);
            JSON_SetInt(infoResponse, "sk", skin_id);
            JSON_SetInt(infoResponse, "rk", family_rang);
            JSON_SetInt(infoResponse, "rb", level);
            JSON_SetInt(infoResponse, "rv", reprimands);
            JSON_SetInt(infoResponse, "rp", phone);
            JSON_SetInt(infoResponse, "m", mute_time);
            JSON_SetString(infoResponse, "rn", rank_name);
            
            new debug_str[1024];
            JSON_Stringify(infoResponse, debug_str, sizeof debug_str);
            printf("[FAMILY] ИНФОРМАЦИЯ ОБ ИГРОКЕ %s: %s", players_nick, debug_str);
            
            OnPacketIncoming(playerid, 45, infoResponse);
            JSON_Cleanup(infoResponse);
            
            return 1;
        }
        else if(s_value == 2)
{
    new action_type, action_value;
    JSON_GetInt(JSONObject, "r", action_type);
    JSON_GetInt(JSONObject, "k", action_value);
    printf("[FAMILY] Действие с игроком: type=%d, value=%d", action_type, action_value);
    
    // ПЫТАЕМСЯ ПОЛУЧИТЬ НИК ИЗ ЗАПРОСА
    new target_nick[128];
    JSON_GetString(JSONObject, "n", target_nick, sizeof(target_nick));
    
    // ЕСЛИ НИК НЕ ПЕРЕДАН, БЕРЁМ ИЗ СОХРАНЁННОГО
    if(strlen(target_nick) == 0)
    {
        GetPVarString(playerid, "last_selected_player", target_nick, sizeof(target_nick));
        printf("[FAMILY] Ник взят из сохранённого: %s", target_nick);
    }
    
    if(strlen(target_nick) == 0)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Не выбран игрок для действия", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    printf("[FAMILY] Цель: %s", target_nick);
    
    new Node:act_response = JSON_Object();
    JSON_SetInt(act_response, "t", 5);
    JSON_SetInt(act_response, "id", 2);
    JSON_SetInt(act_response, "s", 2);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье", "");
        JSON_Cleanup(act_response);
        return 1;
    }
    
    new family_db = GetFamily(f, family_database);
    new player_rang = GetPlayerRangFamily(playerid);
    
    // Получаем данные цели из БД
    mysql_format(mysql, f_string184, sizeof f_string184,
        "SELECT id, family_rang, family_mute FROM accounts WHERE family_id = %d AND name = '%e'",
        family_db, target_nick);
    
    new Cache:cache = mysql_query(mysql, f_string184);
    
    if(mysql_errno() || cache_num_rows() == 0)
    {
        printf("[FAMILY] Игрок %s не найден в семье", target_nick);
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Игрок не найден в семье", "");
        cache_delete(cache);
        JSON_Cleanup(act_response);
        return 1;
    }
    
    new target_account_id = cache_get_field_content_int(0, "id");
    new target_rang = cache_get_field_content_int(0, "family_rang");
    new target_mute = cache_get_field_content_int(0, "family_mute");
    
    cache_delete(cache);
    
    // Проверка на себя
    if(target_account_id == GetPlayerAccountID(playerid))
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не можете взаимодействовать с собой.", "");
        JSON_Cleanup(act_response);
        return 1;
    }
    // Проверка прав (нельзя трогать вышестоящих)
    if(target_rang >= player_rang && player_rang != 5)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Нельзя выполнить действие над игроком с равным или высшим рангом", "");
        JSON_Cleanup(act_response);
        return 1;
    }
    
    // Находим playerid цели (если онлайн)
    new target_playerid = -1;
    foreach(new i : Player)
    {
        if(IsPlayerConnected(i) && GetPlayerAccountID(i) == target_account_id)
        {
            target_playerid = i;
            break;
        }
    }
    
    switch(action_value)
    {
        case 0: // МИНУС
        {
            if(action_type == 0) // Понизить ранг
            {
           	if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2])
           {
           ShowNotificationNew(playerid, 2, 5, -1, -1, "У Вас нет доступа к использованию данной функции", "");
        JSON_Cleanup(act_response);
        return 1;
       } 
                if(target_rang <= 1)
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "Нельзя понизить ранг ниже 1", "");
                    JSON_Cleanup(act_response);
                    return 1;
                }
                
                new new_rang = target_rang - 1;
                
                mysql_format(mysql, f_string64, sizeof f_string64,
                    "UPDATE accounts SET family_rang = %d WHERE id = %d", new_rang, target_account_id);
                mysql_query(mysql, f_string64, false);
                
                if(target_playerid != -1)
                {
                    SetPlayerFamily(target_playerid, RANG_FAMILY, new_rang);
                }
                
                format(f_string144, sizeof f_string144, "%s %s[%d] понизил ранг игроку %s с %d до %d",
                    family_rang_name[f][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, target_nick, target_rang, new_rang);
                SendFamilyMessage(f, f_string144);
                SendFamilyLog(type_log_rang, playerid, target_account_id, f_string144);
                
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ранг изменён", "");
                JSON_SetInt(act_response, "r", 1);
            }
            else if(action_type == 2) // Уменьшить мут
            {
           	if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
           {
           ShowNotificationNew(playerid, 2, 5, -1, -1, "У Вас нет доступа к использованию данной функции", "");
        JSON_Cleanup(act_response);
        return 1;
       }  
                new current_time = gettime();
                new mute_minutes = 10;
                new new_mute = 0;
                
                if(target_mute > current_time)
                {
                    new_mute = target_mute - (mute_minutes * 60);
                    if(new_mute < current_time) new_mute = 0;
                }
                else
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "У игрока нет активного мута", "");
                    JSON_Cleanup(act_response);
                    return 1;
                }
                
                mysql_format(mysql, f_string64, sizeof f_string64,
                    "UPDATE accounts SET family_mute = %d WHERE id = %d", new_mute, target_account_id);
                mysql_query(mysql, f_string64, false);
                
                if(target_playerid != -1)
                {
                    SetPlayerFamily(target_playerid, MUTE_FAMILY, new_mute);
                }
                
                format(f_string144, sizeof f_string144, "%s %s[%d] уменьшил мут игроку %s на %d минут",
                    family_rang_name[f][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, target_nick, mute_minutes);
                SendFamilyMessage(f, f_string144);
                SendFamilyLog(type_log_kick, playerid, target_account_id, f_string144);
                
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Мут уменьшен на 10 минут", "");
                JSON_SetInt(act_response, "r", 1);
            }
            else if(action_type == 3) // Кик
            {
           	if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
          	{
           	 ShowNotificationNew(playerid, 2, 5, -1, -1, "У Вас нет доступа к использованию данной функции", "");
       		 JSON_Cleanup(act_response);
        		return 1; 
       		} 
                new kick_reason[64] = "Не указана";
                JSON_GetString(JSONObject, "t", kick_reason, sizeof(kick_reason));
                
                if(target_playerid != -1)
                {
                    SetPlayerFamily(target_playerid, ID_FAMILY, -1);
                    SetPlayerFamily(target_playerid, ID_SQL_FAMILY, -1);
                    SetPlayerFamily(target_playerid, RANG_FAMILY, 0);
                    SetPlayerFamily(target_playerid, MUTE_FAMILY, 0);
                    SetPlayerFamily(target_playerid, ACCESS_GIVE, 0);
                    SetPlayerFamily(target_playerid, ACCESS_MONEY, 0);
                    SetPlayerFamily(target_playerid, ACCESS_ARMOUR, 0);
                    SetPlayerFamily(target_playerid, ACCESS_MATERIAL, 0);
                    SetPlayerFamily(target_playerid, ACCESS_HEATH_KIT, 0);
                    SetPlayerFamily(target_playerid, ACCESS_PATRON, 0);
                    SetPlayerFamily(target_playerid, ACCESS_MASK, 0);
                    
                    UpdatePlayerDatabaseInt(target_playerid, "family_id", -1);
                    UpdatePlayerDatabaseInt(target_playerid, "family_rang", 0);
                    UpdatePlayerDatabaseInt(target_playerid, "family_mute", 0);
                    
                    ShowNotificationNew(target_playerid, 2, 5, -1, -1, "Вас исключили из семьи!", "");
                }
                else
                {
                    mysql_format(mysql, f_string184, sizeof f_string184,
                        "UPDATE accounts SET family_id = -1, family_rang = 0, family_mute = 0 WHERE id = %d", target_account_id);
                    mysql_query(mysql, f_string184, false);
                }
                
                AddFamily(f, family_count_people, -, 1);
                
                format(f_string144, sizeof f_string144, "%s %s[%d] исключил игрока %s из семьи. Причина: %s",
                    family_rang_name[f][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, target_nick, kick_reason);
                SendFamilyMessage(f, f_string144);
                SendFamilyLog(type_log_kick, playerid, target_account_id, f_string144);
                
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Игрок исключён из семьи", "");
                JSON_SetInt(act_response, "r", 1);
            }
        }
        case 1: // ПЛЮС
        {
            if(action_type == 0) // Повысить ранг
            {
           	if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2])
           {
           ShowNotificationNew(playerid, 2, 5, -1, -1, "У Вас нет доступа к использованию данной функции", "");
        JSON_Cleanup(act_response);
        return 1;
       }  
                if(target_rang >= 4)
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "Нельзя повысить ранг выше 5", "");
                    JSON_Cleanup(act_response);
                    return 1;
                }
                
                new new_rang = target_rang + 1;
                
                mysql_format(mysql, f_string64, sizeof f_string64,
                    "UPDATE accounts SET family_rang = %d WHERE id = %d", new_rang, target_account_id);
                mysql_query(mysql, f_string64, false);
                
                if(target_playerid != -1)
                {
                    SetPlayerFamily(target_playerid, RANG_FAMILY, new_rang);
                }
                
                format(f_string144, sizeof f_string144, "%s %s[%d] повысил ранг игроку %s с %d до %d",
                    family_rang_name[f][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, target_nick, target_rang, new_rang);
                SendFamilyMessage(f, f_string144);
                SendFamilyLog(type_log_rang, playerid, target_account_id, f_string144);
                
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ранг повышен", "");
                JSON_SetInt(act_response, "r", 1);
            }
            else if(action_type == 2) // Увеличить мут
            {
           	if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
           {
           ShowNotificationNew(playerid, 2, 5, -1, -1, "У Вас нет доступа к использованию данной функции", "");
        JSON_Cleanup(act_response);
        return 1;
       } 
                new current_time = gettime();
                new mute_minutes = 10;
                new new_mute = 0;
                new max_mute = current_time + (60 * 60);
                
                if(target_mute > current_time)
                {
                    new_mute = target_mute + (mute_minutes * 60);
                }
                else
                {
                    new_mute = current_time + (mute_minutes * 60);
                }
                
                if(new_mute > max_mute)
                {
                    ShowNotificationNew(playerid, 2, 5, -1, -1, "Нельзя выдать мут больше 60 минут!", "");
                    JSON_Cleanup(act_response);
                    return 1;
                }
                
                mysql_format(mysql, f_string64, sizeof f_string64,
                    "UPDATE accounts SET family_mute = %d WHERE id = %d", new_mute, target_account_id);
                mysql_query(mysql, f_string64, false);
                
                if(target_playerid != -1)
                {
                    SetPlayerFamily(target_playerid, MUTE_FAMILY, new_mute);
                }
                
                format(f_string144, sizeof f_string144, "%s %s[%d] увеличил мут игроку %s на %d минут",
                    family_rang_name[f][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, target_nick, mute_minutes);
                SendFamilyMessage(f, f_string144);
                
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Мут увеличен на 10 минут", "");
                JSON_SetInt(act_response, "r", 1);
            }
        }
    }
    
    OnPacketIncoming(playerid, 45, act_response);
    JSON_Cleanup(act_response);
    
    return 1;
}
        else
        {
            printf("[FAMILY] Получение списка игроков");
            
            new f = GetPlayerIdFamily(playerid);
            if(f == -1)
            {
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
                JSON_Cleanup(response);
                return 1;
            }
            
            new family_db = GetFamily(f, family_database);
            
            mysql_format(mysql, f_string184, sizeof f_string184,
                "SELECT name, family_rang, family_mute FROM accounts WHERE family_id = %d", family_db);
            new Cache:cache = mysql_query(mysql, f_string184);
            
            if(mysql_errno())
            {
                printf("[FAMILY] SQL ERROR: %d", mysql_errno());
                ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка получения списка игроков", "");
                cache_delete(cache);
                JSON_Cleanup(response);
                return 1;
            }
            
            new rows = cache_num_rows();
            printf("[FAMILY] Найдено игроков: %d", rows);
            
            new Node:nicksArray = JSON_Array();
            new Node:infoArray = JSON_Array();
            
            new name_buf[24];
            
            for(new i; i < rows; i++)
            {
                cache_get_field_content(i, "name", name_buf, mysql, 24);
                new family_rang = cache_get_field_content_int(i, "family_rang");
                new family_mute = cache_get_field_content_int(i, "family_mute");
                
                printf("[FAMILY] Игрок %d: %s, ранг=%d, мут=%d", i + 1, name_buf, family_rang, family_mute);
                
                new status = 0;
                
                foreach(new p : Player)
                {
                    if(IsPlayerConnected(p) && strcmp(GetPlayerNameEx(p), name_buf, true) == 0)
                    {
                        status = 1;
                        if(family_mute > 0) status = 2;
                        break;
                    }
                }
                
                new nicksNode = JSON_Array(JSON_String(name_buf));
                new infoNode = JSON_Array(JSON_Int(family_rang), JSON_Int(status));
                
                nicksArray = JSON_Append(nicksArray, nicksNode);
                infoArray = JSON_Append(infoArray, infoNode);
            }
            
            cache_delete(cache);
            
            JSON_SetInt(response, "t", 5);
            JSON_SetInt(response, "id", 2);
            JSON_SetInt(response, "s", 0);
            JSON_SetArray(response, "np", nicksArray);
            JSON_SetArray(response, "rs", infoArray);
            
            new debug_str[2048];
            JSON_Stringify(response, debug_str, sizeof debug_str);
            printf("[FAMILY] ОТВЕТ СПИСОК ИГРОКОВ: %s", debug_str);
            
            OnPacketIncoming(playerid, 45, response);
            
            JSON_Cleanup(nicksArray);
            JSON_Cleanup(infoArray);
            JSON_Cleanup(response);
            
            printf("[FAMILY] Список игроков отправлен");
            return 1;
        }
    }
    else if(id_value == 3) // Склад/Сейф
{
    printf("[FAMILY] Склад/Сейф (id=3), r=%d, s=%d", r_value, s_value);
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 3);
    JSON_SetInt(response, "r", r_value);
    
    if(r_value == 1) // Склад
    {
        JSON_SetInt(response, "s", 1);
        if(s_value == 1) // Открыть склад
        {
            JSON_Cleanup(response);
            HidePlayerGUI(playerid, 45);
            return FamilyStorageOpenWarehouseGui(playerid);
        }
    }
    else if(r_value == 0) // Сейф
    {
   	JSON_SetInt(response, "s", 0);
        if(s_value == 0) // Открыть сейф
        {
            // Открываем команду /famsklad
            ShowFamilyLegacyStorageMenu(playerid);
            JSON_SetInt(response, "s", 0);
            HidePlayerGUI(playerid, 45);
        }
    }
    
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
    else if(id_value == 4) 
{
    printf("[FAMILY] Логи семьи (id=4)");
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    if(GetPlayerRangFamily(playerid) != 5)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Доступно только лидеру.", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    DeletePVar(playerid, "select_type_log");
   
    ShowPlayerDialog
    (
        playerid, 2237, DIALOG_STYLE_LIST,
        "{FF0000}Выберите лог", 
        "1. Принятие новых членов семьи\n"\
        "2. Увольнение членов семьи\n"\
        "3. Взаимодействие с деньгами склада\n"\
        "4. Взаимодействие с материалами склада\n"\
        "5. Взаимодействие с масками склада\n"\
        "6. Взаимодействие с аптечками склада\n"\
        "7. Взаимодействие с оружием склада\n"\
        "8. Взаимодействие с бронежилетами склада\n"\
        "9. Взаимодействие с семейным автопарком\n"\
        "10. Выдача рангов\n"\
        "11. Выдача доступов",
        "Далее", "Назад"
    );
    
    JSON_SetInt(response, "s", 1);
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    
    return 1;
}
    else if(id_value == 5)
    {
        printf("[FAMILY] Черный список (id=5)");
        JSON_SetInt(response, "s", 1);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Временно не доступно.", "");
        return 1;
    }
    
    JSON_Cleanup(response);
    printf("[FAMILY] case 5 завершен, id=%d не обработан", id_value);
    return 1;
}
        case 6: // Уведомления
{
    new b;
    JSON_GetInt(JSONObject, "b", b);
    new f = GetPlayerIdFamily(playerid);
    new Node:response = JSON_Object();
    
    
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Ошибка", "");
        JSON_Cleanup(response);
        return 1;
    }
    
    if(b == 1)
    {
    	new msg[258];
        utf8_to_cp1251(msg);
        JSON_GetString(JSONObject, "m", msg);
        printf("%s сообщение бля нахуй", msg);
        
        if(strlen(msg) < 1)
        {
       	 ShowNotificationNew(playerid, 2, 5, -1, -1, "Введите текст", "");
        }
        new fm_db = GetFamily(f, family_database);
        
        mysql_format(mysql, f_string184, sizeof f_string184, "INSERT INTO family_ad (family, ad_text, create_id, create_name, time) VALUES ('%d', '%s', '%d', '%s', '%d')", GetPlayerFamily(playerid, ID_SQL_FAMILY),\
                        msg, GetPlayerAccountID(playerid), GetPlayerNameEx(playerid), gettime()+10800);
                        mysql_query(mysql, f_string184, false);
                        
                        /*JSON_SetInt(response, "t", 6);
                        JSON_SetInt(response, "b", 1);
                        JSON_SetString(response, "k", msg);
                        JSON_SetString(response, "n", GetPlayerNameEx(playerid));
                        JSON_SetInt(response, "x", 0);
                        
                        OnPacketIncoming(playerid, 45, response);*/
                        new json_str[2054];
                        format(json_str, sizeof(json_str),
        "{\"t\":6,\"b\":1,\"k\":\"%s\",\"n\":\"%s\",\"x\":0}",
        msg, GetPlayerNameEx(playerid));
    printf("ответ нахуй, бля %s", json_str);
    SendPacketToClientString(playerid, 45, json_str);
                        
        JSON_Cleanup(response);
        return 1;
    }
    else if(b == 2)
    {
   	 new xid;
        JSON_GetInt(JSONObject, "x", xid);
        
        mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM family_ad WHERE id = %d", xid);
                    new Cache:cache = mysql_query(mysql, f_string64);
                    
                    JSON_SetInt(response, "t", 6);
                    JSON_SetInt(response, "b", 2);
                    JSON_SetInt(response, "d", xid);
                    JSON_SetInt(response, "x", -1);
                    
                    OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    else
    {
        mysql_format(mysql, f_string64, sizeof f_string64, 
            "SELECT * FROM family_ad WHERE family = %d", GetPlayerFamily(playerid, ID_SQL_FAMILY));
        new Cache:cache = mysql_query(mysql, f_string64);

        if(mysql_errno())
        {
            printf("[FAMILY] Ошибка SQL: %d", mysql_errno());
            SendClientMessage(playerid, -1, ""c_f_r" Ошибка в SQL-запросе");
            cache_delete(cache);
            JSON_Cleanup(response);
            return 1;
        }

        new rows = cache_num_rows();
        printf("[FAMILY] Найдено уведомлений: %d", rows);
        
        new Node:mArray = JSON_Array();
        new Node:xArray = JSON_Array();
        
        for(new i; i < rows; i++)
        {
            new ad_text[62];
            new create_name[24];
            new id;
            
            cache_get_field_content(i, "ad_text", ad_text, mysql, 62);
            cache_get_field_content(i, "create_name", create_name, mysql, 24);
            id = cache_get_field_content_int(i, "id");
            
            printf("[FAMILY] %d: текст=%s, автор=%s, id=%d", i, ad_text, create_name, id);
            
            // ПРАВИЛЬНАЯ СТРУКТУРА: каждый элемент mArray = [текст, автор]
            new Node:mNode = JSON_Array(
                JSON_String(ad_text),
                JSON_String(create_name)
            );
            mArray = JSON_Append(mArray, mNode);
            
            // ПРАВИЛЬНАЯ СТРУКТУРА: каждый элемент xArray = [id]
            new Node:xNode = JSON_Array(JSON_Int(id));
            xArray = JSON_Append(xArray, xNode);
        }
        
        JSON_SetInt(response, "t", 6);
        JSON_SetArray(response, "m", mArray);
        JSON_SetArray(response, "x", xArray);
        JSON_SetInt(response, "b", 0);
        
        new debug_str[2048];
        JSON_Stringify(response, debug_str, sizeof(debug_str));
        printf("[FAMILY] ОТВЕТ УВЕДОМЛЕНИЯ: %s", debug_str);
        
        OnPacketIncoming(playerid, 45, response);
        
        JSON_Cleanup(mArray);
        JSON_Cleanup(xArray);
        JSON_Cleanup(response);
        cache_delete(cache);
    }
    return 1;
}
        case 7: // Рейтинг
{
    printf("[FAMILY] Запрос рейтинга семей");
    
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
        return 1;
    }
    
    new Node:ratingResponse = JSON_Object();
    
    mysql_format(mysql, f_string184, sizeof f_string184, 
        "SELECT id, name, reputation FROM family ORDER BY reputation DESC LIMIT 20");
    new Cache:result = mysql_query(mysql, f_string184);
    
    if(mysql_errno())
    {
        printf("[FAMILY] SQL Error: %d", mysql_errno());
        cache_delete(result);
        return 1;
    }
    
    new rows = cache_num_rows();
    printf("[FAMILY] Найдено семей: %d", rows);
    
    new database_family = GetFamily(f, family_database);
    new my_reputation = GetFamily(f, family_reputation);
    new my_position = -1;
    
    JSON_SetInt(ratingResponse, "t", 7);
    JSON_SetInt(ratingResponse, "r", 1500);
    JSON_SetInt(ratingResponse, "tz", 0);
    JSON_SetInt(ratingResponse, "tr", my_reputation);
    
    new Node:pointsArray = JSON_Array();
    new Node:nameArray = JSON_Array();
    
    for(new i; i < rows; i++)
    {
        new id = cache_get_field_content_int(i, "id");
        new reputation = cache_get_field_content_int(i, "reputation");
        new name[32];
        cache_get_field_content(i, "name", name, mysql, 32);
        
        // ВАЖНО: pointsNode должен содержать reputation, 0, 0
        new Node:pointsNode = JSON_Array(
            JSON_Int(reputation), 
            JSON_Int(0), 
            JSON_Int(0)
        );
        pointsArray = JSON_Append(pointsArray, pointsNode);
        
        new Node:nameNode = JSON_Array(JSON_String(name));
        nameArray = JSON_Append(nameArray, nameNode);
        
        if(id == database_family)
        {
            my_position = i + 1;
        }
    }
    
    cache_delete(result);
    
    if(my_position == -1)
    {
        my_position = rows + 1;
    }
    
    JSON_SetInt(ratingResponse, "p", my_position);
    JSON_SetInt(ratingResponse, "tp", 3);
    JSON_SetArray(ratingResponse, "m", pointsArray);
    JSON_SetArray(ratingResponse, "mn", nameArray);
    
    OnPacketIncoming(playerid, 45, ratingResponse);
    
    JSON_Cleanup(pointsArray);
    JSON_Cleanup(nameArray);
    JSON_Cleanup(ratingResponse);
    
    return 1;
}
        case 8: // Закрытие интерфейса
        {
            new Node:response = JSON_Object();
			DeletePVar(playerid, "last_selected_player");
            JSON_SetInt(response, "t", 8);
            OnPacketIncoming(playerid, 45, response);
            JSON_Cleanup(response);
        }
        case 9: // Токены (покупка жетонов)
{
    new s_value, token_value;
    JSON_GetInt(JSONObject, "s", s_value);
    JSON_GetInt(JSONObject, "v", token_value);
    
    new Node:response = JSON_Object();
    JSON_SetInt(response, "t", 9);
    
    if(s_value == 1) // Запрос стоимости (открытие диалога)
    {
        new price = token_value * 10;
        JSON_SetInt(response, "s", 1);
        JSON_SetInt(response, "m", price); // цена за 1 токен
        JSON_SetInt(response, "tp", 0);
        
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        return 1;
    }
    else if(s_value == 2) // Покупка токенов
    {
        new count = token_value; // количество токенов
        if(count <= 0)
        {
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Укажите корректное количество токенов!", "");
            return 1;
        }
        
        new price = count * 10; // 1 токен = 10 донат-рублей
        new current_donate = GetPlayerDonateRub(playerid);
        
        if(current_donate >= price)
        {
            // Списываем донат-рубли
            GivePlayerDonateRub(playerid, -price);
            
            // Добавляем токены игроку
            new current_tokens = GetPlayerData(playerid, P_FAMILY_TOKEN);
            SetPlayerData(playerid, P_FAMILY_TOKEN, current_tokens + count);
            UpdatePlayerDatabaseInt(playerid, "fam_token", GetPlayerData(playerid, P_FAMILY_TOKEN));
            
            // Отправляем ответ об успешной покупке
            JSON_SetInt(response, "s", 2);
            JSON_SetInt(response, "r", 1); // успех
            JSON_SetInt(response, "m", GetPlayerData(playerid, P_FAMILY_TOKEN)); // остаток донат-рублей
            JSON_SetInt(response, "bc", GetPlayerDonateRub(playerid)); // сколько токенов стало
            
            OnPacketIncoming(playerid, 45, response);
            JSON_Cleanup(response);
        }
        else
        {
            // Недостаточно средств
            JSON_SetInt(response, "s", 2);
            JSON_SetInt(response, "r", 0); // ошибка
            JSON_SetInt(response, "need", price - current_donate); // сколько не хватает
            
            OnPacketIncoming(playerid, 45, response);
            JSON_Cleanup(response);
            
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Недостаточно BC!", "");
        }
        
        return 1;
    }
    
    return 1;
}
        case 10: // Диалоги подтверждения (покинуть семью)
{
    new s_value;
    JSON_GetInt(JSONObject, "s", s_value);
    
    new Node:response = JSON_Object();
    JSON_SetInt(response, "t", 10);
    
    if(s_value == 0) // Подтверждение выхода из семьи
    {
        new f = GetPlayerIdFamily(playerid);
        if(f == -1)
        {
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы не состоите в семье.", "");
            JSON_Cleanup(response);
            return 1;
        }
        
        new player_rang = GetPlayerRangFamily(playerid);
        
        if(player_rang == 5) // Лидер удаляет всю семью
        {
            new family_sql = GetFamily(f, family_database);
            new leader_id = GetPlayerAccountID(playerid);
            new leader_name[24];
            GetPlayerName(playerid, leader_name, sizeof(leader_name));
            
            // ВОЗВРАЩАЕМ ВСЕ МАШИНЫ ЛИДЕРУ
            mysql_format(mysql, f_string184, sizeof f_string184, 
                "SELECT id, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, number, region, number_type FROM family_cars WHERE family_owner = %d", family_sql);
            new Cache:cars_cache = mysql_query(mysql, f_string184);
            
            new rows = cache_num_rows();
            printf("[FAMILY] Возвращаем %d машин лидеру", rows);
            
            new cars_returned = 0;
            
            for(new i; i < rows; i++)
            {
                new model_id = cache_get_field_content_int(i, "model_id");
                new color_1 = cache_get_field_content_int(i, "color_1");
                new color_2 = cache_get_field_content_int(i, "color_2");
                new Float:pos_x = cache_get_field_content_float(i, "pos_x");
                new Float:pos_y = cache_get_field_content_float(i, "pos_y");
                new Float:pos_z = cache_get_field_content_float(i, "pos_z");
                new Float:angle = cache_get_field_content_float(i, "angle");
                new number[32];
                cache_get_field_content(i, "number", number, mysql, 32);
                new region[8];
                cache_get_field_content(i, "region", region, mysql, 8);
                new number_type = cache_get_field_content_int(i, "number_type");
                
                
                    new free_car_id = GetFreeOwnableCarID();
                    if(free_car_id != -1)
                    {
                        SetOwnableCarData(free_car_id, OC_OWNER_ID, leader_id);
                        SetOwnableCarData(free_car_id, OC_MODEL_ID, model_id);
                        SetOwnableCarData(free_car_id, OC_COLOR_1, color_1);
                        SetOwnableCarData(free_car_id, OC_COLOR_2, color_2);
                        SetOwnableCarData(free_car_id, OC_POS_X, pos_x);
                        SetOwnableCarData(free_car_id, OC_POS_Y, pos_y);
                        SetOwnableCarData(free_car_id, OC_POS_Z, pos_z);
                        SetOwnableCarData(free_car_id, OC_ANGLE, angle);
                        FamilyBuildStoredPlateValue(number_type, number, region, g_ownable_car[free_car_id][OC_NUMBER], 32);
                        SetOwnableCarData(free_car_id, OC_CREATE, gettime());
                        format(g_ownable_car[free_car_id][OC_OWNER_NAME], 24, leader_name);
                        
                        new query[1024];
                        mysql_format(mysql, query, sizeof(query), 
                            "INSERT INTO ownable_cars (owner_id, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, number, create_time) \
                            VALUES (%d, %d, %d, %d, %f, %f, %f, %f, '%e', %d)",
                            leader_id, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, g_ownable_car[free_car_id][OC_NUMBER], gettime());
                        mysql_query(mysql, query, false);
                    }
            }
            
            cache_delete(cars_cache);
            
            // Удаляем всех игроков из семьи
            foreach(new i : Player)
            {
                if(GetPlayerFamily(i, ID_SQL_FAMILY) == family_sql)
                {
                    ExitFromFamily(i);
                    SendClientMessage(i, -1, ""c_f_r"Лидер распустил семью. Семья удалена.");
                }
            }
            
            // Удаляем все машины из семейных (они уже возвращены)
            mysql_format(mysql, f_string144, sizeof f_string144, 
                "DELETE FROM family_cars WHERE family_owner = %d", family_sql);
            mysql_query(mysql, f_string144);
            
            // Удаляем логи семьи
            mysql_format(mysql, f_string144, sizeof f_string144, 
                "DELETE FROM family_log WHERE family = %d", family_sql);
            mysql_query(mysql, f_string144);
            
            // Удаляем объявления семьи
            mysql_format(mysql, f_string144, sizeof f_string144, 
                "DELETE FROM family_ad WHERE family = %d", family_sql);
            mysql_query(mysql, f_string144);

            // Удаляем предметы графического склада семьи
            mysql_format(mysql, f_string144, sizeof f_string144,
                "DELETE FROM family_storage_items WHERE family_id = %d", family_sql);
            mysql_query(mysql, f_string144);
            
            // Удаляем саму семью
            mysql_format(mysql, f_string64, sizeof f_string64, 
                "DELETE FROM family WHERE id = %d", family_sql);
            mysql_query(mysql, f_string64);
            
            // Обновляем аккаунты
            mysql_format(mysql, f_string144, sizeof f_string144, 
                "UPDATE accounts SET family_id = -1 WHERE family_id = %d", family_sql);
            mysql_query(mysql, f_string144);
            
            // Очищаем данные семьи в массиве
            SetFamily(f, family_database, -1);
            SetFamily(f, family_color, 0);
            SetFamily(f, family_reputation, 0);
            format(GetFamily(f, family_name), 32, "");
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
            
            
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы покинули семью, и она была распущена.", "");
        }
        else // Обычный игрок покидает семью
        {
            
            format(f_string144, sizeof f_string144, "%s покинул семью.", GetPlayerNameEx(playerid));
            SendFamilyMessage(f, f_string144);
            SendFamilyLog(type_log_kick, playerid, -1, f_string144);
            
            ExitFromFamily(playerid);
            
            ShowNotificationNew(playerid, 2, 5, -1, -1, "Вы покинули семью.", "");
        }
        
        JSON_SetInt(response, "s", 1);
        OnPacketIncoming(playerid, 45, response);
        JSON_Cleanup(response);
        
        return 1;
    }
    
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
    }
    OnPacketIncoming(playerid, 45, JSONObject);
}

alias:family("fm", "fammenu")
CMD:family(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);
    if(f == -1)
    {
        if(GetPlayerMoneyEx(playerid) < 3_000_000)
            return ShowNotificationNew(playerid, 2, 6, -1, -1, "Для создания семьи требуется 3.000.000 рублей.", "OK");
        Dialog(playerid, 2238, DIALOG_STYLE_INPUT, "{FF0000}Создание семьи",
            "{FFFFFF}Введите название семьи от 6 до 31 символа.\nСтоимость: {32A44B}3.000.000 рублей", "Создать", "Закрыть");
        return 1;
    }
   
    new ld_flag = (GetPlayerRangFamily(playerid) == 5) ? 1 : 0;
    
    new Node:family_response = JSON_Object(
        "o", JSON_Int(1),
        "t", JSON_Int(0), 
        "n", JSON_String(GetFamily(f, family_name)),
        "k", JSON_Int(ld_flag),  
        "m", JSON_Int(GetPlayerData(playerid, P_FAMILY_TOKEN)),  
        "j", JSON_Int(0),  
        "y", JSON_Int(0), 
        "b", JSON_Int(4),  
        "pn", JSON_String(GetPlayerNameEx(playerid)),  
        "pi", JSON_Int(playerid),  
        "is", JSON_Int(1)  
    );
    
    OnPacketIncoming(playerid, 45, family_response);
    JSON_Cleanup(family_response);
    return 1;
}

CMD:fmenu(playerid, params[])
{
    return pc_cmd_family(playerid, params);
}

stock ShowFamilyLegacyStorageMenu(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи.");

    format(f_string144, sizeof f_string144,
        "| Склад: %s\n1. Взять со склада\n2. Положить на склад\n3. Доступы",
        GetFamily(GetPlayerIdFamily(playerid), family_status_storage) ? ("{FF0000}Закрыт") : ("{00FF00}Открыт"));

    ShowPlayerDialog(playerid, 2223, DIALOG_STYLE_LIST, "{FF0000}Сейф семьи", f_string144, "Далее", "Выйти");
    return 1;
}

alias:famsklad("fs", "fsklad")
CMD:famsklad(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи.");

    return FamilyStorageOpenWarehouseGui(playerid);
}

CMD:famsafe(playerid)
{
    return ShowFamilyLegacyStorageMenu(playerid);
}

CMD:fam(playerid, params[])
{
    if(GetPlayerIdFamily(playerid) == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи."); 

    if(!strlen(params)) return SendClientMessage(playerid, 0xFFFFFFFF, ""c_f_r"Используйте: /fam [текст]");   

    if(GetPlayerFamily(playerid, MUTE_FAMILY) > 0) 
        return SendClientMessage(playerid, -1, ""c_f_r"У вас мут в семейном чате.");

    new message[254];

    extract params -> new string:text[125];

    format(message, sizeof message, "%s %s[%d]: %s", family_rang_name[GetPlayerIdFamily(playerid)][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, text);
    SendFamilyMessage(GetPlayerIdFamily(playerid), message);
    return 1;
}

CMD:fammute(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи."); 
    
    new to_player, count, prichina[12];
    if(sscanf(params, "dds[12]", to_player, count, prichina))
        return SendClientMessage(playerid, -1, ""c_f_r"/fammute [ID игрока] [Минуты] [Причина (до 12 символ.)]");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не состоит в вашей семье.");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно выдавать муты.");
    
    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerRangFamily(to_player) >= GetPlayerRangFamily(playerid))
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок такого же ранга или выше.");

    if(GetPlayerFamily(to_player, MUTE_FAMILY) >= 1) return SendClientMessage(playerid, -1, ""c_f_r"У игрока уже есть мут");

    if(count > 180 || !count)
        return SendClientMessage(playerid, -1, ""c_f_r" Количество мута не должно превышать 180 минут.");
    
    SetPlayerFamily(to_player, MUTE_FAMILY, 60*count);

    format(f_string144, sizeof f_string144, "%s выдал мут %s на %d минут. Причина: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player), count,
    prichina);
    SendFamilyMessage(f, f_string144);

    return 1;
}

CMD:unfammute(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи."); 
    
    new to_player, prichina[12];
    if(sscanf(params, "ds[12]", to_player, prichina))
        return SendClientMessage(playerid, -1, ""c_f_r"/unfammute [ID игрока] [Причина (до 12 символ.)]");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не состоит в вашей семье.");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно снимать муты.");
    
    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerRangFamily(to_player) >= GetPlayerRangFamily(playerid))
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок такого же ранга или выше.");

    if(GetPlayerFamily(to_player, MUTE_FAMILY) == 0) return SendClientMessage(playerid, -1, ""c_f_r"У игрока нет мута");

    SetPlayerFamily(to_player, MUTE_FAMILY, 0);

    format(f_string144, sizeof f_string144, "%s снял мут %s. Причина: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player),
    prichina);
    SendFamilyMessage(f, f_string144);

    return 1;
}

CMD:faminvite(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи."); 
    
    new to_player;
    if(sscanf(params, "d", to_player))
        return SendClientMessage(playerid, -1, ""c_f_r"/faminvite [ID игрока]");

    if(family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][0])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно принимать игроков.");
    
    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerIdFamily(to_player) != -1)
        return SendClientMessage(playerid, -1, ""c_f_r"У игрока уже есть семья.");

    if(GetFamily(f, family_count_people)+1 > count_compound_level[GetFamily(f, family_lvl_compound)-1])
        return SendClientMessage(playerid, -1, ""c_f_r"Состав семьи полон.");

	if(!IsPlayerInRangeOfPlayer(playerid, to_player, 5.0))
		return SendClientMessage(playerid, 0xCECECEFF, "Игрок слишком далеко");

    format(f_string144, sizeof f_string144, "{FFFF00}%s{FFFFFF} приглашает вас в семью %s",
    GetPlayerNameEx(playerid), GetFamily(f, family_name));

    ShowPlayerDialog
    (
        to_player, 2243, DIALOG_STYLE_MSGBOX,
        "{FF0000}Приглашение в семью",
        f_string144,
        "Принять", "Отказать"
    );

    SetPVarInt(to_player, "invite_player", playerid);

    return 1;
}

CMD:unfaminvite(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return SendClientMessage(playerid, -1, ""c_f"У вас нету семьи."); 
    
    new to_player,prichinaept[12];
    if(sscanf(params, "ds[12]", to_player, prichinaept))
        return SendClientMessage(playerid, -1, ""c_f_r"/unfaminvite [ID игрока] [Причина (до 12 символ.)]");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно выгонять игроков.");
    
    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не из вашей семьи.");

    SetPlayerFamily(to_player, ID_FAMILY, -1);
    SetPlayerFamily(to_player, ID_SQL_FAMILY, -1);
    
    DestroyDynamic3DTextLabel(GetPlayerFamily(to_player, TEXT_FAMILY));
    SetPlayerFamily(to_player, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(to_player, RANG_FAMILY, 0);
    SetPlayerFamily(to_player, MUTE_FAMILY, 0);
    //SetPlayerFamily(to_player, WARN_FAMILY, 0);

    SetPlayerFamily(to_player, ACCESS_GIVE, 0);
    SetPlayerFamily(to_player, ACCESS_MONEY, 0);
    SetPlayerFamily(to_player, ACCESS_ARMOUR, 0);
    SetPlayerFamily(to_player, ACCESS_MATERIAL, 0);
    SetPlayerFamily(to_player, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(to_player, ACCESS_PATRON, 0);
    SetPlayerFamily(to_player, ACCESS_MASK, 0);

    UpdatePlayerDatabaseInt(to_player, "family_id", GetPlayerFamily(to_player, ID_FAMILY));
    UpdatePlayerDatabaseInt(to_player, "family_rang", GetPlayerFamily(to_player, RANG_FAMILY));
    UpdatePlayerDatabaseInt(to_player, "family_mute", GetPlayerFamily(to_player, MUTE_FAMILY));
    //UpdatePlayerDatabaseInt(to_player, "family_warn", GetPlayerFamily(to_player, WARN_FAMILY));
    UpdateAccessPlayerFamily(to_player);
    AddFamily(f, family_count_people, -, 1);


    format(f_string144, sizeof f_string144, "%s выгнал из семьи %s. Причина:%s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player), prichinaept);
    SendFamilyLog(type_log_kick, playerid, to_player, f_string144);
    SendFamilyMessage(f, f_string144);

    return 1;
}

stock SendFamilyLog(type, playerid, to_player = -1, text[])
{
    new string[324], sql;

    if(to_player != -1) sql = GetPlayerAccountID(to_player);
    else sql = -1;

    mysql_format(mysql, string, sizeof string, "INSERT INTO family_log (family,player,to_player,text,time,type) VALUES (%d,%d,%d,'%s',%d,%d)", GetPlayerFamily(playerid, ID_SQL_FAMILY), GetPlayerAccountID(playerid),
    sql, text, gettime()+10800, type);
    mysql_query(mysql, string, false);

    if(mysql_errno()) return printf("error insert family_log");

    return 1;
}


stock ShowMembersFamily(playerid, listitem)
{
    new list = GetPVarInt(playerid, "count_list");

    if(listitem == 0)  list++;
    else if(listitem == 1 && list != 1) list--;
    SetPVarInt(playerid, "count_list", list);

    new Cache: result;

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT * FROM accounts WHERE family_id = %d", GetFamily(GetPlayerIdFamily(playerid), family_database));
    result = mysql_query(mysql, f_string144, true);
    if(mysql_errno()) return SendClientMessage(playerid, -1, "error");

    new rows = cache_num_rows();
    
    new count_rows, count = 10 * GetPVarInt(playerid, "count_list");

    if(rows >= count) count_rows = count;
    else count_rows = rows;

    new d_list[86], dialog[sizeof d_list*10+50] = "Следующая страница\nПредыдущая страница\n", family_rang, bool:online, id, name[24], last_login, data[54];
    
    for(new i = count-10, da = 2; i < count_rows;i++, da++)
    {
        online = false;
        id = cache_get_field_content_int(i, "id");
        cache_get_field_content(i, "name", name, mysql, 24);
        last_login = cache_get_field_content_int(i, "last_login");
        family_rang = cache_get_field_content_int(i, "family_rang");

        format(f_string32, sizeof f_string32, "p_familyrang%d", da);
        SetPVarInt(playerid, f_string32, family_rang);
        format(f_string32, sizeof f_string32, "p_familyname%d", da);
        SetPVarString(playerid, f_string32, name);

        foreach(new yo : Player)
        {
            if(GetPlayerAccountID(yo) != id) continue;
            online = true;
            break;
        }

        if(!online)
        {
            format(data, sizeof data, "%02d.%02d.%d %02d:%02d:%02d", ConvertUnixTime(last_login, CONVERT_TIME_TO_DAYS), ConvertUnixTime(last_login, CONVERT_TIME_TO_MONTHS),
            ConvertUnixTime(last_login, CONVERT_TIME_TO_YEARS), ConvertUnixTime(last_login, CONVERT_TIME_TO_HOURS), ConvertUnixTime(last_login, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(last_login, CONVERT_TIME_TO_SECONDS));
        }
        else format(data, sizeof data, "{00FF00}Онлайн{FFFFFF}");

        format(d_list, sizeof d_list, "%s %s\n", name, data);
        strcat(dialog, d_list);
        SetPlayerListitemValue(playerid, da, id);
    }


    ShowPlayerDialog
    (
        playerid, 2236, DIALOG_STYLE_LIST,
        "{FF0000}Выберите кого выгнать",
        dialog,
        "Выбрать", "Закрыть"
    );
    SetPVarInt(playerid, "prichina", 0);
    SetPVarInt(playerid, "select_type_2236", 2);
    cache_delete(result);
    return 1;
}

stock GetVehicleDriver(vehicleid)
{
    foreach(new i : Player)
    {
        if(GetPlayerVehicleID(i) == vehicleid) return i;
    }
    return INVALID_PLAYER_ID;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(GetVehicleData(vehicleid, V_ACTION_TYPE) == VEHICLE_ACTION_TYPE_FAMILY_CAR){
        new id = GetVehicleData(vehicleid, V_ACTION_ID);
        
		if(GetPlayerRangFamily(playerid) < GetCarFamily(id, V_F_RANG))
        {
            ClearAnimations(playerid);
            return SendClientMessage(playerid, -1, ""c_f_r"Вам не доступен данные транспорт.");
        }
    }
    #if defined fam_OnPlayerEnterVehicle
        return fam_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnPlayerEnterVehicle
    #undef OnPlayerEnterVehicle
#else
    #define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle fam_OnPlayerEnterVehicle
#if defined fam_OnPlayerEnterVehicle
    forward fam_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#endif

stock ExitFromFamily(playerid)
{
    new f = GetPlayerIdFamily(playerid);

    AddFamily(f, family_count_people, -, 1);

    SetPlayerFamily(playerid, ID_FAMILY, -1);
    SetPlayerFamily(playerid, ID_SQL_FAMILY, -1);
    
    DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(playerid, RANG_FAMILY, 0);
    SetPlayerFamily(playerid, MUTE_FAMILY, 0);
    //SetPlayerFamily(playerid, WARN_FAMILY, 0);

    SetPlayerFamily(playerid, ACCESS_GIVE, 0);
    SetPlayerFamily(playerid, ACCESS_MONEY, 0);
    SetPlayerFamily(playerid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(playerid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(playerid, ACCESS_PATRON, 0);
    SetPlayerFamily(playerid, ACCESS_MASK, 0);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=%d, family_rang=%d, family_mute=%d WHERE id = %d", 
    GetPlayerFamily(playerid, ID_SQL_FAMILY), GetPlayerRangFamily(playerid), GetPlayerFamily(playerid, MUTE_FAMILY), GetPlayerAccountID(playerid));
    mysql_query(mysql, f_string144, false);
    if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);
    //UpdatePlayerDatabaseInt(playerid, "family_warn", GetPlayerFamily(playerid, WARN_FAMILY));
    UpdateAccessPlayerFamily(playerid);

    return 1;
}
