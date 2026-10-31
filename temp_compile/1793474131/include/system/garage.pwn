new LoadCarGarage[MAX_PLAYERS];

enum E_GARAGE_STRUCT
{
    GARAGE_ID,                 // айди гаража (by wеrton) 
    GARAGE_OWNER_ID,           // айди владельца в бд (by wеrton) 
    GARAGE_PRICE,              // цена гаража (by wеrton) 
    GARAGE_STATUS,             // lock статус гаража, 0 - открыт 1 - закрыт (by wеrton) 
    Float: GARAGE_X,	       // позиция пикапа входа (by wеrton) 
	Float: GARAGE_Y,		   // позиция пикапа входа (by wеrton) 
	Float: GARAGE_Z,	       // позиция пикапа входа (by wеrton) 
	Float: GARAGE_EXIT_X,      // позиция после выхода из дома (by wеrton) 
	Float: GARAGE_EXIT_Y,      // позиция после выхода из дома (by wеrton) 
	Float: GARAGE_EXIT_Z,      // позиция после выхода из дома (by wеrton) 
	Float: GARAGE_EXIT_ANGLE,  // угол поворота (by wеrton) 
    G_ENTER_PICKUP,            // пикап входа (by wеrton) 
    Text3D: G_LABEL,	       // 3д текст
    G_OWNER_NAME[20 + 1],	   // имя владельца
    GARAGE_IMPROVEMENTS, 
};

#define MAX_GARAGES           (100) 

#define GetPlayerInGarage(%0)	GetPlayerData(%0, P_IN_GARAGE) 		                    // в какой гараж вошел\находится
#define SetPlayerInGarage(%0,%1)				SetPlayerData(%0, P_IN_GARAGE, %1)		// установить гараж в котором находится

#define GetGarageData(%0,%1)			g_garage[%0][%1]
#define SetGarageData(%0,%1,%2)		g_garage[%0][%1] = %2
#define AddGarageData(%0,%1,%2,%3)	g_garage[%0][%1] %2= %3

#define IsGarageOwned(%0)			(GetGarageData(%0, GARAGE_OWNER_ID) > 0) // куплен ли гараж

new g_garage[MAX_GARAGES][E_GARAGE_STRUCT];
new g_garage_loaded;

#define DIALOG_GARAGE_INFO                      22313   // Информация о гараже
#define DIALOG_GARAGE_SETTINGS                  22323   // Меню настроек гаража
#define DIALOG_GARAGE_SELL                      22333   // Продажа гаража государству
#define DIALOG_GARAGE_BUY                       22343   // Покупка гаража
#define DIALOG_GARAGE_ENTER                     22353   // Вход в гараж
#define DIALOG_OWNABLE_CAR_LOAD_GARAGE          22363   // Загрузить транспорт в гараже
//#define DIALOG_OWNABLE_CAR_GARAGE_LIST        22373   // Выбор транспорта из списка
#define DIALOG_GARAGE_IMPROVEMENT               22383   // улучшение гаража
#define DIALOG_GARAGE_IMPROVEMENT_CONFIRM       22393   // улучшение гаража

// Определения типов действий для пикапов
#define PICKUP_ACTION_TYPE_GARAGE_EXIT          221     // Выход из гаража
#define PICKUP_ACTION_TYPE_GARAGE               222     // Вход в гараж

// Определения типов предложений
#define OFFER_TYPE_SELL_GARAGE                  221     // Предложение о продаже гаража

forward ShowPlayerGarageInfo(playerid, garageid);
forward CheckAndCreateGaragesTables();

public OnGameModeInit()
{
    SetTimer("CheckAndCreateGaragesTables", 1500, false);
    print("[MELLISS SYSTEM]: Система гаражей загружена!");
	SetTimer("LoadGarages", 3000, false);

    #if defined garage_OnGameModeInit
        return garage_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit garage_OnGameModeInit
#if defined garage_OnGameModeInit
    forward garage_OnGameModeInit();
#endif

public CheckAndCreateGaragesTables()
{
    new query[1024];

    mysql_format(mysql, query, sizeof(query), "SHOW TABLES LIKE 'garages'");
    mysql_query(mysql, query);

    if (cache_num_rows() == 0)
    {
        print("Таблица 'garages' не найдена. Создаем ее...");

        mysql_format(mysql, query, sizeof(query), "CREATE TABLE `garages` (`id` INT(11) NOT NULL, `owner_id` INT(11) NOT NULL, `price` INT(11) NOT NULL, `lock` INT(11) NOT NULL, `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `exit_x` FLOAT NOT NULL, `exit_y` FLOAT NOT NULL, `exit_z` FLOAT NOT NULL, `exit_angle` FLOAT NOT NULL, `improvements` INT(11) NOT NULL DEFAULT 1) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;");
        mysql_query(mysql, query);

        mysql_format(mysql, query, sizeof(query), "ALTER TABLE `garages` ADD PRIMARY KEY (`id`);");
        mysql_query(mysql, query);

        mysql_format(mysql, query, sizeof(query), "ALTER TABLE `garages` MODIFY `id` INT(11) NOT NULL AUTO_INCREMENT;");
        mysql_query(mysql, query);

        print("Таблица 'garages' успешно создана. Теперь вставляем начальные данные...");

        // Начальные данные для таблицы `garages`
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (1, 0, 500000, 0, 353.404, 800.074, 12, 350.682, 800.797, 12, 69.381, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (2, 0, 500000, 0, 354.905, 804.006, 12, 352.324, 804.991, 12, 66.7752, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (3, 0, 500000, 0, 356.451, 808.065, 12.0073, 353.898, 808.92, 12.0073, 66.5632, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (4, 0, 500000, 0, 357.905, 811.891, 12.0073, 355.276, 813.422, 12.0073, 67.9254, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (5, 0, 500000, 0, 359.422, 815.865, 12, 356.466, 816.753, 12.0073, 65.2152, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (6, 0, 500000, 0, 360.909, 819.765, 12, 358.047, 820.573, 12, 72.5789, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (7, 0, 500000, 0, 362.431, 823.763, 12, 360.489, 824.517, 12, 64.0241, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (8, 0, 500000, 0, 363.94, 827.73, 12, 361.112, 828.732, 12, 71.2634, 1);");
        mysql_query(mysql, query);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `garages` (`id`, `owner_id`, `price`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `improvements`) VALUES (9, 0, 500000, 0, 365.421, 831.631, 12.0085, 362.63, 832.608, 12, 70.8588, 1);");
        mysql_query(mysql, query);

        print("Начальные данные успешно вставлены в таблицу 'garages'.");
    }

    mysql_format(mysql, query, sizeof(query), "SHOW COLUMNS FROM `accounts` LIKE 'garage'");
    mysql_query(mysql, query);

    if (cache_num_rows() == 0)
    {
        print("Столбец 'garage' в таблице 'accounts' не найден. Добавляем его...");

        mysql_format(mysql, query, sizeof(query), "ALTER TABLE `accounts` ADD COLUMN `garage` INT(11) NOT NULL DEFAULT -1;");
        mysql_query(mysql, query);

        print("Столбец 'garage' успешно добавлен в таблицу 'accounts'.");
    }
}

public: LoadGarages()
{
 new query[85], buffer[2];
 new Cache: result, rows;

 result = mysql_query(mysql, "SELECT g.*, IFNULL(a.name, 'None') AS owner_name FROM garages g LEFT JOIN accounts a ON a.id=g.owner_id");
 rows = cache_num_rows();

    if(mysql_errno(mysql) != 0)
    {
        printf("[WERTON_GARAGES]: Ошибка при загрузке гаражей из БД: %s", mysql_errno(mysql));
        return 0;
    }

 if(rows > MAX_GARAGES)
 {
  rows = MAX_GARAGES;
  print("[garages by werton]: DB rows > MAX_GARAGES");
 }

 for(new idx; idx < rows; idx ++)
 {
  SetGarageData(idx, GARAGE_ID,   cache_get_field_content_int(idx, "id"));
  SetGarageData(idx, GARAGE_OWNER_ID, cache_get_field_content_int(idx, "owner_id"));

  SetGarageData(idx, GARAGE_PRICE,   cache_get_field_content_int(idx, "price"));
  SetGarageData(idx, GARAGE_STATUS, bool: cache_get_field_content_int(idx, "lock"));

  SetGarageData(idx, GARAGE_X,   cache_get_field_content_float(idx, "x"));
  SetGarageData(idx, GARAGE_Y,   cache_get_field_content_float(idx, "y"));
  SetGarageData(idx, GARAGE_Z,   cache_get_field_content_float(idx, "z"));
  
  SetGarageData(idx, GARAGE_EXIT_X,   cache_get_field_content_float(idx, "exit_x"));
  SetGarageData(idx, GARAGE_EXIT_Y,   cache_get_field_content_float(idx, "exit_y"));
  SetGarageData(idx, GARAGE_EXIT_Z,   cache_get_field_content_float(idx, "exit_z"));
  SetGarageData(idx, GARAGE_EXIT_ANGLE,   cache_get_field_content_float(idx, "exit_angle"));
  SetGarageData(idx, GARAGE_IMPROVEMENTS,   cache_get_field_content_int(idx, "improvements"));
  
  cache_get_field_content(idx, "owner_name", g_garage[idx][G_OWNER_NAME], mysql, 21);
   //  }

  // -------------------------

  new labelText[128];
  format(labelText, sizeof(labelText), "Нажмите [гудок] чтобы выехать");
  SetGarageData(idx, G_LABEL, CreateDynamic3DTextLabel(labelText, 0x3399FFFF, GetGarageData(idx, GARAGE_X), GetGarageData(idx, GARAGE_Y), GetGarageData(idx, GARAGE_Z) + 1.0, 15.0));

  if(IsGarageOwned(idx) && !strcmp(GetGarageData(idx, G_OWNER_NAME), "None", true))
  {
   mysql_format(mysql, query, sizeof query, "UPDATE accounts SET garage=-1 WHERE id=%d LIMIT 1", GetGarageData(idx, GARAGE_OWNER_ID));
   mysql_query(mysql, query, false);

   SetGarageData(idx, GARAGE_OWNER_ID, 0);

   mysql_format(mysql, query, sizeof query, "UPDATE garages SET owner_id=0 WHERE id=%d", GetGarageData(idx, GARAGE_ID));
   mysql_query(mysql, query, false);
  }

  CreatePickup(19134, 23, GetGarageData(idx, GARAGE_X), GetGarageData(idx, GARAGE_Y), GetGarageData(idx, GARAGE_Z), 0, PICKUP_ACTION_TYPE_GARAGE, idx);
  CreatePickup(1318, 23, 1.2011, 1994.7356, 1554.2031, -1, PICKUP_ACTION_TYPE_GARAGE_EXIT, idx);
  CreatePickup(1318, 23, 492.912048,1991.464599,1547.679687, -1, PICKUP_ACTION_TYPE_GARAGE_EXIT, idx);
  
  UpdateGarageInfo(idx);
 }
 g_garage_loaded = rows;
 cache_delete(result);
 
 CreateDynamic3DTextLabel("{ffffff}Нажмите на {ff0000}гудок\n{ffffff}Чтобы выехать", -1, -0.2940,2006.1188,1554.2031, 9.0, _, _, _, -1, -1);
 CreateDynamic3DTextLabel("{ffffff}Нажмите на {ff0000}гудок\n{ffffff}Чтобы выехать", -1, 492.663848,1988.835205,1548.586645, 9.0, _, _, _, -1, -1);
 printf("[WERTON_GARAGES]: Гаражей загружено: %d", g_garage_loaded);
}

stock GetPlayerGarage(playerid)
{
	new garageid = GetPlayerData(playerid, P_GARAGE);
	if(garageid != -1)
	{
					if(GetGarageData(garageid, GARAGE_OWNER_ID) == GetPlayerAccountID(playerid))
					{
						return garageid;
					}
			/*default:
				return garageid;*/
	}
	return -1;
}

stock UpdateGarages(garageid)
{
	DestroyPickup(GetGarageData(garageid, g_enter_pickup));
	g_enter_pickup = CreatePickup(19134, 23, GetGarageData(garageid, GARAGE_X), GetGarageData(garageid, GARAGE_Y), GetGarageData(garageid, GARAGE_Z), 0, PICKUP_ACTION_TYPE_GARAGE, garageid);
}

stock UpdateGarageInfo(idx)
{
    new query[666];
    new Cache: result;

    if(GetGarageData(idx, GARAGE_OWNER_ID) > 0) 
    {
            format(query, sizeof(query), "{ffff00}Гараж: №%d\n{ffffff}Владелец: {ff0000}%s\n{66CC00}Гараж открыт", GetGarageData(idx, GARAGE_ID), GetGarageData(idx, G_OWNER_NAME));
    }
    else 
    {
        format(query, sizeof(query), "{ffff00}Гараж: №%d\n{ffffff}Гараж продается", GetGarageData(idx, GARAGE_ID));
    }

        UpdateDynamic3DTextLabelText(GetGarageData(idx, G_LABEL), 0xfaf2f6AA, query);

    cache_delete(result); 
}

public: LoadPlayerData(playerid)
{
	new query[138];
	new Cache: result;

	mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", GetPlayerAccountID(playerid));
	result = mysql_query(mysql, query);

	if(cache_num_rows())
	{
    LoadCarGarage[playerid] = 0;

	new player_account_id = GetPlayerAccountID(playerid);

	new query_gar[128];
    mysql_format(mysql, query_gar, sizeof(query_gar), "SELECT `id` FROM `garages` WHERE `owner_id` = %d LIMIT 1", player_account_id);

    mysql_query(mysql, query_gar);

    new garage_id = 0;

    if (cache_num_rows() > 0)
    {
        garage_id = cache_get_field_content_int(0, "id");

        if (garage_id > 0)
        {
            new update_query[128];
            mysql_format(mysql, update_query, sizeof(update_query), "UPDATE `accounts` SET `garage` = %d WHERE `id` = %d LIMIT 1", garage_id, player_account_id);
            mysql_query(mysql, update_query);

			SetPlayerData(playerid, P_GARAGE, garage_id);

            printf("[WERTON_GARAGE OnPlayerConnect]: Игрок ID %d (Аккаунт ID: %d) - найден гараж ID: %d. Обновляю accounts.garage.", playerid, player_account_id, garage_id);
        }
    }
	}

    #if defined garage_LoadPlayerData
        return garage_LoadPlayerData(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_LoadPlayerData
    #undef LoadPlayerData
#else
    #define _ALS_LoadPlayerData
#endif
#define LoadPlayerData garage_LoadPlayerData
#if defined garage_LoadPlayerData
    forward garage_LoadPlayerData(playerid);
#endif

public OnPlayerSpawn(playerid)
{
    LoadCarGarage[playerid] = 0;
    
    SetPlayerData(playerid, P_IN_GARAGE, 		-1);
    #if defined garage_OnPlayerSpawn
        return garage_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn garage_OnPlayerSpawn
#if defined garage_OnPlayerSpawn
    forward garage_OnPlayerSpawn(playerid);
#endif

public OnPlayerDeath(playerid, killerid, reason)
{
    LoadCarGarage[playerid] = 0;
    
    SetPlayerData(playerid, P_IN_GARAGE, 		-1);
    #if defined garage_OnPlayerSpawn
        return garage_OnPlayerSpawn(playerid, killerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDeath
    #undef OnPlayerDeath
#else
    #define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath garage_OnPlayerDeath
#if defined garage_OnPlayerDeath
    forward garage_OnPlayerDeath(playerid, killerid, reason);
#endif

public OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id)
{
	        switch(action_type)
			{
                case PICKUP_ACTION_TYPE_GARAGE_EXIT:
				{
					new in_garage = GetPlayerInGarage(playerid);
					if(in_garage != -1)
					{
							SetPlayerPosEx
							(
								playerid,
								GetGarageData(in_garage, GARAGE_EXIT_X),
								GetGarageData(in_garage, GARAGE_EXIT_Y),
								GetGarageData(in_garage, GARAGE_EXIT_Z),
								GetGarageData(in_garage, GARAGE_EXIT_ANGLE),
								0,
								0
							);
							SetPlayerInGarage(playerid, -1);
					}
				}
				case PICKUP_ACTION_TYPE_GARAGE:
				{
					ShowPlayerGarageInfo(playerid, action_id);
				}
			}
    #if defined garage_OnPlayerPickUpPickupEx
        return garage_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerPickUpPickupEx
    #undef OnPlayerPickUpPickupEx
#else
    #define _ALS_OnPlayerPickUpPickupEx
#endif
#define OnPlayerPickUpPickupEx garage_OnPlayerPickUpPickupEx
#if defined garage_OnPlayerPickUpPickupEx
    forward garage_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id);
#endif

public: ShowPlayerGarageInfo(playerid, garageid)
{
			SetPlayerUseListitem(playerid, garageid);

			new fmt_str[60];
			new string[256];

			if(IsGarageOwned(garageid))
			{
					format(fmt_str, sizeof fmt_str, "{FFFFFF}Владелец:\t\t\t{33CCFF}%s\n\n", GetGarageData(garageid, G_OWNER_NAME));
					strcat(string, fmt_str);
			}

				format(fmt_str, sizeof fmt_str, "{ffffff}Номер гаража:\t\t\t%d\n", garageid);
				strcat(string, fmt_str);

				if(!IsGarageOwned(garageid)) strcat(string, "\n");

			format(fmt_str, sizeof fmt_str, "{ffffff}Стоимость:{ffff00}\t\t\t%d руб{ffffff}\n", GetGarageData(garageid, GARAGE_PRICE));
			strcat(string, fmt_str);

			if(IsGarageOwned(garageid))
			{
				Dialog(playerid, DIALOG_GARAGE_ENTER, DIALOG_STYLE_MSGBOX, "{FF9900}Гараж занят", string, "Войти", "Отмена");
			}
			else Dialog(playerid, DIALOG_GARAGE_BUY, DIALOG_STYLE_MSGBOX, "{33CC00}Гараж свободен", string, "Купить", "Отмена");
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
//выезд гаражи, обычный
if(newkeys == KEY_CROUCH)
   {
       print("[eq]");
       if(IsPlayerInRangeOfPoint(playerid,  5.0, -0.2940,2006.1188,1554.2031))
       {
                new garageid = GetPlayerGarage(playerid);
               if(!IsPlayerInVehicle(playerid, GetPlayerOwnableCar(playerid))) return SendClientMessage(playerid, -1, ""USC"Вы должны быть за рулем своего автомобиля");
		  new vehicleID = GetPlayerVehicleID(playerid);
		  for(new i = 0; i < MAX_PLAYERS; i++)
		  {
          if(IsPlayerInVehicle(i, vehicleID))

          SetPlayerVirtualWorld(i, 0);
          SetPlayerInterior(i, 0);
          SetCameraBehindPlayer(i);
          }
          new vehicleid = GetPlayerOwnableCar(playerid);
          
          SetVehiclePos(vehicleid, GetGarageData(garageid, GARAGE_EXIT_X), GetGarageData(garageid, GARAGE_EXIT_Y), GetGarageData(garageid, GARAGE_EXIT_Z));
          SetVehicleZAngle(vehicleid, GetGarageData(garageid, GARAGE_EXIT_ANGLE));
          SetVehicleVirtualWorld(vehicleid, 0);
          SetPlayerVirtualWorld(playerid, 0);
          LinkVehicleToInterior(vehicleid, 0);
          SetCameraBehindPlayer(playerid);
                    return 1;
       }
   }
   //далее элитный класс
   if(newkeys == KEY_CROUCH)
   {
       print("[eq]");
       if(IsPlayerInRangeOfPoint(playerid,  5.0, 492.663848,1988.835205,1548.586645))
       {
                new garageid = GetPlayerGarage(playerid);
               if(!IsPlayerInVehicle(playerid, GetPlayerOwnableCar(playerid))) return SendClientMessage(playerid, -1, ""USC"Вы должны быть за рулем своего автомобиля");
		  new vehicleID = GetPlayerVehicleID(playerid);
		  for(new i = 0; i < MAX_PLAYERS; i++)
		  {
          if(IsPlayerInVehicle(i, vehicleID))

          SetPlayerVirtualWorld(i, 0);
          SetPlayerInterior(i, 0);
          SetCameraBehindPlayer(i);
          }
          new vehicleid = GetPlayerOwnableCar(playerid);
          
          SetVehiclePos(vehicleid, GetGarageData(garageid, GARAGE_EXIT_X), GetGarageData(garageid, GARAGE_EXIT_Y), GetGarageData(garageid, GARAGE_EXIT_Z));
          SetVehicleZAngle(vehicleid, GetGarageData(garageid, GARAGE_EXIT_ANGLE));
          SetVehicleVirtualWorld(vehicleid, 0);
          SetPlayerVirtualWorld(playerid, 0);
          LinkVehicleToInterior(vehicleid, 0);
          SetCameraBehindPlayer(playerid);
                    return 1;
       }
   }
   #if defined garage_OnPlayerKeyStateChange
        return garage_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange garage_OnPlayerKeyStateChange
#if defined garage_OnPlayerKeyStateChange
    forward garage_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
   if(dialogid == DIALOG_GARAGE_IMPROVEMENT)
	{
	    if(response)
		{
			switch(listitem)
			{
				case 0:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				case 1:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				case 2:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				case 3:
				{
				new garageid = GetPlayerGarage(playerid);
				
				if(GetPlayerInGarage(playerid) != -1)
				{
					  SendClientMessage(playerid, 0xCECECEFF, "Вы должны находится на улице");
				}
				else 
                {
					  if(GetPlayerMoneyEx(playerid) < 5000000) return SendClientMessage(playerid, 0xCECECEFF, "Для покупки этого улучшения нужно иметь 5.000.000 рублей!");
					  ShowPlayerDialog(playerid, DIALOG_GARAGE_IMPROVEMENT_CONFIRM, DIALOG_STYLE_MSGBOX, "{ff0000}Улучшение", "При покупке этого улучшения Вы измените интерьер своего гаража\nи сможете доставлять в гараж больше автомобилей\n\nСтоимость ремонта гаража: 5.000.000 рублей.\nВы уверены, что хотите продолжить?", "Далее", "Выйти");
				}
				}
			}
		}
		else return 1;
	}
	if(dialogid == DIALOG_GARAGE_IMPROVEMENT_CONFIRM)
	{
	new query[255];
	new garageid = GetPlayerGarage(playerid);
	
	   if(response)
	   {
			format(query, sizeof query, "UPDATE garages SET improvements=2 WHERE id=%d LIMIT 1",  GetGarageData(garageid, GARAGE_ID));
		    mysql_query(mysql, query, false);
		    SetGarageData(garageid, GARAGE_IMPROVEMENTS, 2);
		if(USE_ZOMENO_OLD_ENGINE == 0)
        {
		    ShowNotification(playerid, 3, "Улучшение было куплено!", 3, "", "");
		    ShowNotification(playerid, 0, "Вы потратили 5000000 рублей", 3, "", "");
			GivePlayerMoneyEx(playerid, -5000000);
	    }
	    else
	    {
        	ShowNewNotification(playerid, 3, 5, 1, 10, "Улучшение было куплено!", "");
            GivePlayerMoneyEx(playerid, -5000000);
        }
	    }
 	   else 
        {
	       Dialog
               (
                    playerid, DIALOG_GARAGE_IMPROVEMENT, DIALOG_STYLE_LIST, 
                    "{ff0000}Улучшения",
                    "{FFFFFF}Название\t \t \t \t \t \t \t \t \t{FFFFFF}Цена\t \t \t \t \t \t \t \t \t{FFFFFF}Статус\n"\
                    "{ffffff}1. Возможность проживания в гараже\t{ffffff}30000 руб.\t\t{66CC00}имеется\n"\
                    "{ffffff}2. Сейф в гараже{ffffff}\t\t\t\t\t\t\t\t\t40000 руб.\t\t\t\t\t{66CC00}имеется\n"\
                    "{ffffff}3. Улучшить до элитного\t\t\t\t\t{ffffff}5000000 руб.\t\t\t\t\t{ff0000}не имеется",
                    "Далее", "Выйти"
                );
        }
    }
    if(dialogid == DIALOG_GARAGE_INFO)
	{
		if(response)
		{
			ShowPlayerGarageDialog(playerid);
		}
	}
	if(dialogid == DIALOG_GARAGE_SELL) 
	{
		new garageid = GetPlayerGarage(playerid);
		if(garageid != -1)
		{
			if(response)
			{
				SellGarage(playerid);
			}
		}
	}
	if(dialogid == 2432) //хз как называть
	{
	if(response)
		{
			switch(listitem)
			{
				case 0:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				
				case 1:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				
				case 2:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
				case 3:
				{
				SendClientMessage(playerid, 0x999999FF, ""USC"У вас уже приобретено это улучшение");
				}
			}
		}
		else return 1;
	}
	if(dialogid == DIALOG_GARAGE_SETTINGS) 
			{
			new garageid = GetPlayerGarage(playerid);
					if(response)
					{
							switch(listitem)
							{
								case 0:
								{
								  return SendClientMessage(playerid, 0x999999FF, "В разработке");
								}
								
								case 1:
								{
								callcmd::sellgarage(playerid, "");
								}
								
								case 2:
								{
								if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 1)
						   	{
								Dialog
                                    (
                                         playerid, DIALOG_GARAGE_IMPROVEMENT, DIALOG_STYLE_LIST, 
                                        "{ff0000}Улучшения",
                                        "{FFFFFF}Название\t \t \t \t \t \t \t \t \t{FFFFFF}Цена\t \t \t \t \t \t \t \t \t{FFFFFF}Статус\n"\
                                        "{ffffff}1. Возможность проживания в гараже\t{ffffff}30000 руб.\t\t{66CC00}имеется\n"\
                                        "{ffffff}2. Сейф в гараже{ffffff}\t\t\t\t\t\t\t\t\t40000 руб.\t\t\t\t\t{66CC00}имеется\n"\
                                        "{ffffff}3. Улучшить до элитного\t\t\t\t\t{ffffff}5000000 руб.\t\t\t\t\t{ff0000}не имеется",
                                        "Далее", "Выйти"
                                    );
                               }
                               else if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 2)
						   	{
								Dialog
                                    (
                                         playerid, 2432, DIALOG_STYLE_LIST, 
                                        "{ff0000}Улучшения",
                                        "{FFFFFF}Название\t \t \t \t \t \t \t \t \t{FFFFFF}Цена\t \t \t \t \t \t \t \t \t{FFFFFF}Статус\n"\
                                        "{ffffff}1. Возможность проживания в гараже\t{ffffff}30000 руб.\t\t{66CC00}имеется\n"\
                                        "{ffffff}2. Сейф в гараже{ffffff}\t\t\t\t\t\t\t\t\t40000 руб.\t\t\t\t\t{66CC00}имеется\n"\
                                        "{ffffff}3. Улучшить до элитного\t\t\t\t\t{ffffff}5000000 руб.\t\t\t\t\t{66CC00}имеется",
                                        "Далее", "Выйти"
                                    );
                               }
								}
								
								case 3:
								{
									if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 1) LoadCarGarage[playerid] = 1;					
                                    if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 2) LoadCarGarage[playerid] = 2;

								    callcmd::car(playerid, "");
								}
								case 4:
								{
							  	new Float: x = GetGarageData(garageid, GARAGE_X);
            	                  new Float: y = GetGarageData(garageid, GARAGE_Y);
	                              new Float: z = GetGarageData(garageid, GARAGE_Z);
	                        
	                              if(GetPlayerGPSInfo(playerid, G_ENABLED) == GPS_STATUS_OFF)
						     	{
						    		if(GetPlayerMoneyEx(playerid) >= 300)
							    	{
									   GivePlayerMoneyEx(playerid, -300, "Метка ТС на GPS", true, true);

									   EnablePlayerGPS(playerid, 55, x, y, z, "Местоположение Вашего гаража отмечено на GPS");
									   return 1;
							    	}
								    else SendClientMessage(playerid, 0x999999FF, "Недостаточно денег");
						     	}
						     	else SendClientMessage(playerid, 0xCECECEFF, "На Вашем GPS уже отмечено место");
								}
								
								case 5:
								{
								  SendClientMessage(playerid, 0x999999FF, "Используйте команду /sellmygarage");
                                }
							}
					}
					else 
					{
						LoadCarGarage[playerid] = 0;
						ShowPlayerGarageDialog(playerid);
					}
			}
	if(dialogid == DIALOG_GARAGE_BUY) 
	{
	     new garageid = GetPlayerUseListitem(playerid);
	
     	if(response)
		 {
              if(GetPlayerGarage(playerid) == -1)
          	{
						if(!IsGarageOwned(garageid))
						{
							if(GetPlayerMoneyEx(playerid) >= GetGarageData(garageid, GARAGE_PRICE))
							{
								SendClientMessage(playerid, 0xFFFFFFFF, "Поздравляем! Вы купили новый гараж");
								BuyPlayerGarage(playerid, garageid);

								//PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
								//Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX, "{3399FF}Новый бизнес", "{FFFFFF}Вам нужно заплатить за аренду гаража в ближайшем отделением банка {FFCD00}(/gps)", "Ок", "");
							}
							else SendClientMessage(playerid, 0xCECECEFF, "У Вас недостаточно денег для покупки этого гаража");
						}
						else
						{
							new fmt_str[64];

							format(fmt_str, sizeof fmt_str, "Этот гараж уже куплен. Владелец: %s", GetGarageData(garageid, G_OWNER_NAME));
							SendClientMessage(playerid, 0xCECECEFF, fmt_str);
						}
					}
					else SendClientMessage(playerid, 0xCECECEFF, "У Вас уже есть гараж. Чтобы купить новый - необходимо продать старый");
				}
				else return 1;
			}
			if(dialogid == DIALOG_GARAGE_ENTER)
			{
				new garageid = GetPlayerUseListitem(playerid);
                 if(response)
			     {
				      EnterPlayerToGarage(playerid, garageid);
				 }
				 else return 1;
			}
			if(dialogid == DIALOG_OWNABLE_CAR_LOAD_GARAGE)
			{
				if(response)
				{
					new idx = GetPVarInt(playerid, "ownablecar_id"),
						Float: x,
						Float: y,
						Float: z,
						Cache: result,
						query[100];

					mysql_format(mysql, query, sizeof query, "SELECT pos_x, pos_y, pos_z FROM ownable_cars WHERE id='%d'", idx);
					result = mysql_query(mysql, query, true);

					if(cache_num_rows())
					{
						x = cache_get_row_float(0, 0);
						y = cache_get_row_float(0, 1);
						z = cache_get_row_float(0, 2);
					}

					cache_delete(result);

              if(LoadCarGarage[playerid] == 0)
	      	{
					switch(listitem + 1)
					{
						case 1:
						{
							if(GetPlayerGPSInfo(playerid, G_ENABLED) == GPS_STATUS_OFF)
							{
								if(GetPlayerMoneyEx(playerid) >= 300)
								{
									GivePlayerMoneyEx(playerid, -300, "Метка ТС на GPS", true, true);

									EnablePlayerGPS(playerid, 55, x, y, z, "Местоположение Вашего транспорта отмечено на GPS");
									return 1;
								}
								else SendClientMessage(playerid, 0x999999FF, "Недостаточно денег");
							}
							else SendClientMessage(playerid, 0xCECECEFF, "На Вашем GPS уже отмечено место");
						}
						
						case 2:
						{
						SCM(playerid, -1, "{FFFF00}| {FFFFFF}Временно не доступно.");
						} 
						
						case 3:
						{
							if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
							{
								SendClientMessage(playerid, 0x999999FF, "Системная ошибка. Транспорт уже загружен.");
								return 1;
							}
							else
							{
								if(GetPVarInt(playerid, "rent_true") != 1)
								{
									if(LoadOwnableCar(idx, playerid) != -1)
									{
										PlayerOwnableCarInit(playerid);
										//LoadTun(playerid);
										SendClientMessage(playerid, 0x66CC33FF, "Ваш транспорт успешно загружен!");
									}
									else SendClientMessage(playerid, 0x999999FF, "Ошибка при загрузке личного транспорта");
								}
								else 
								{
									if(GetPlayerMoneyEx(playerid) >= GetPVarInt(playerid, "price_rent"))
									{
										if(LoadOwnableCarRent(playerid, idx) != -1)
										{
											PlayerOwnableCarInit(playerid);
											//LoadTun(playerid);
											PutPlayerInVehicle(playerid, GetPlayerData(playerid, P_OWNABLE_CAR), 0);
											SendClientMessage(playerid, 0x66CC33FF, "Ваш транспорт успешно выгружен!");

											GivePlayerMoneyEx(playerid, -GetPVarInt(playerid, "price_rent"));
											DeletePVar(playerid, "price_rent");
											DeletePVar(playerid, "rent_true");
										}
										else SendClientMessage(playerid, 0x999999FF, "Ошибка при загрузке личного транспорта");
									}
								}
							}
						}
					}
				}
					else
					{
					 new garageid = GetPlayerGarage(playerid);
	         
	                 new Float: x = GetGarageData(garageid, GARAGE_X);
            	     new Float: y = GetGarageData(garageid, GARAGE_Y);
	                 new Float: z = GetGarageData(garageid, GARAGE_Z);
				
					switch(listitem + 1)
					{
						case 1:
						{
							if(GetPlayerGPSInfo(playerid, G_ENABLED) == GPS_STATUS_OFF)
							{
								if(GetPlayerMoneyEx(playerid) >= 300)
								{
									GivePlayerMoneyEx(playerid, -300, "Метка ТС на GPS", true, true);

									EnablePlayerGPS(playerid, 55, x, y, z, "Местоположение загрузки Вашего транспорта отмечено на GPS");
									LoadCarGarage[playerid] = 0;
									return 1;
								}
								else SendClientMessage(playerid, 0x999999FF, "Недостаточно денег");
							}
							else SendClientMessage(playerid, 0xCECECEFF, "На Вашем GPS уже отмечено место");
							LoadCarGarage[playerid] = 0;
						}
						case 2:
						{
							if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
							{
								SendClientMessage(playerid, 0x999999FF, "Системная ошибка. Транспорт уже загружен.");
								LoadCarGarage[playerid] = 0;
								return 1;
							}
							else
							{
							if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 1)
							{
							   LoadCarGarage[playerid] = 1;
							}
							
							if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 2)
							{
							   LoadCarGarage[playerid] = 2;
							}
								if(GetPVarInt(playerid, "rent_true") != 1)
								{
									if(LoadOwnableCar(idx, playerid) != -1)
									{
										PlayerOwnableCarInit(playerid);
										//LoadTun(playerid);
										SendClientMessage(playerid, 0x66CC33FF, "Ваш транспорт успешно загружен!");
										LoadCarGarage[playerid] = 0;
									}
									else SendClientMessage(playerid, 0x999999FF, "Ошибка при загрузке личного транспорта");
								}
							}
						}
					  }
					}
				}
				else
				{
				    LoadCarGarage[playerid] = 0;
					if(GetPVarInt(playerid, "show_menu"))
					{
						DeletePVar(playerid, "show_menu");
						callcmd::car(playerid, "");
					}
				}
				
				return 1;
			}
    #if defined garage_OnDialogResponse
    return garage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse garage_OnDialogResponse
#if defined garage_OnDialogResponse
forward garage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

stock ShowPlayerGarageDialog(playerid) 
{
Dialog
 (
	playerid, DIALOG_GARAGE_SETTINGS, DIALOG_STYLE_LIST,
	"{ffff00}Управление гаражем",
    "1. {669966}Открыть {FFFFFF}или {CC3333}закрыть {FFFFFF}гараж\n"\
    "2. Продать гараж\n"\
    "3. Улучшения\n"\
    "4. Доставить транспорт в гараж\n"\
    "5. Отметить гараж на GPS\n"\
    "6. Продать гараж другому игроку", 
	"Выбрать",
	"Отмена"
 );
}

stock SellGarage(playerid, to_player = INVALID_PLAYER_ID, price = 0)
{
	new garageid = GetPlayerGarage(playerid);

	if(garageid != -1)
	{
		new garage_price = GetGarageData(garageid, GARAGE_PRICE);
new garage_percent = (garage_price * 30) / 100;

		new query[200];
		new return_money = (garage_price - garage_percent);

		SetPlayerData(playerid, P_GARAGE, -1);

		SetGarageData(garageid, GARAGE_OWNER_ID, 0);

		if(to_player == INVALID_PLAYER_ID)
		{
			AddPlayerData(playerid, P_BANK, +, return_money);

			BankLog(playerid, return_money, "Продажа гаража");

			SetGarageData(garageid, GARAGE_STATUS,	0);

			format(query, sizeof query, "UPDATE accounts a,garages g SET a.bank=%d,a.garage=-1,g.owner_id=0,g.lock=0 WHERE a.id=%d AND g.id=%d", GetPlayerData(playerid, P_BANK), GetPlayerAccountID(playerid), GetGarageData(garageid, GARAGE_ID));
			mysql_query(mysql, query, false);

			GivePlayerMoneyEx(playerid, 0, "Продажа гаража государству", false, false);
			UpdateGarageInfo(garageid);
            
            format(query, sizeof query, "UPDATE garages SET improvements=1 WHERE id=%d LIMIT 1",  GetGarageData(garageid, GARAGE_ID));
		    mysql_query(mysql, query, false);
		    SetGarageData(garageid, GARAGE_IMPROVEMENTS, 2);
            
			SendClientMessage(playerid, 0x66CC00FF, "Вы продали свой гараж!");

			format(query, sizeof query, "Налог за продажу бизнеса составил 30 процентов от его стоимости {99CC00}(%d руб)", garage_percent);
			SendClientMessage(playerid, 0xCECECEFF, query);

			format(query, sizeof query, "Итого на банковский счет перечислено: {3399FF}%d руб", return_money);
			SendClientMessage(playerid, 0xFFFFFFFF, query);
		}
		else
		{
			if(BuyPlayerGarage(to_player, garageid, true, price) == 1)
			{
				new total_price = price;

				format(query, sizeof query, "UPDATE accounts SET money=%d,garage=-1 WHERE id=%d LIMIT 1", GetPlayerMoneyEx(playerid)+total_price, GetPlayerAccountID(playerid));
				mysql_query(mysql, query, false);

				GivePlayerMoneyEx(playerid, total_price, "Продажа гаража игроку", false, false);

				garage_price = price;
				garage_percent = 0;
			}
			else return ;
		}
		format(query, sizeof query, "~g~+%d rub~n~+%d rub", (garage_price - garage_percent));
		GameTextForPlayer(playerid, query, 4000, 1);
	}
}

stock EnterPlayerToGarage(playerid, garageid)
{
if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 1)
	{
		SetPlayerPosEx
		(
			playerid,
			1.265544,
            1996.246215,
            1554.203125,
            359.354705,
			1,
			garageid + 2000
		);
		SetPlayerInGarage(playerid, garageid);
	}
	else 
    if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 2)
	{
		SetPlayerPosEx
		(
			playerid,
			495.083526,
            1990.127807,
            1547.679687,
            272.186431,
			1,
			garageid + 2000
		);
		SetPlayerInGarage(playerid, garageid);
	}
}

stock BuyPlayerGarage(playerid, garageid, bool: buy_from_owner = false, price = -1)
{
	if(!IsGarageOwned(garageid) && GetPlayerGarage(playerid) == -1)
	{
		if(price <= 0)
			price = GetGarageData(garageid, GARAGE_PRICE);

		if(GetPlayerMoneyEx(playerid) >= price)
		{
			new query[256];

			format(query, sizeof query, "UPDATE accounts a, garages g SET a.garage=%d,g.owner_id=%d WHERE a.id=%d AND g.id=%d", garageid, GetPlayerAccountID(playerid), GetPlayerAccountID(playerid), GetGarageData(garageid, GARAGE_ID));
			mysql_query(mysql, query, false);
			printf("sql %s", query);

			if(!mysql_errno())
			{
				SetPlayerData(playerid, P_GARAGE, garageid);

				SetGarageData(garageid, GARAGE_OWNER_ID, GetPlayerAccountID(playerid));
				
				format(g_garage[garageid][G_OWNER_NAME], 21, GetPlayerNameEx(playerid), 0);
				//CallLocalFunction("UpdateGarageLabel", "i", garageid);
				EnterPlayerToGarage(playerid, garageid);
				UpdateGarageInfo(garageid);

				GivePlayerMoneyEx(playerid, -price, "Покупка гаража", false, true);
				SendClientMessage(playerid, 0x66CC00FF, "Напишите {0099FF}/garage {66CC00}чтобы узнать о возможностях");

				return 1;
			}
			SendClientMessage(playerid, 0xFF6600FF, "Ошибка сохранения, повторите попытку {FF0000}(equ-code 21)");
			return 0;
		}
		return 0;
	}
	return -1;
}

CMD:addgarage(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) != 13) return 1;

	extract params -> new price; else return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /addgarage [стоимость]");

	if(price < 1) return SendClientMessage(playerid, 0x999999FF, "Стоимость гаража не может быть меньше 1");

    new fmt_text[320];

	new Cache: result,
		idx = g_garage_loaded;

    new Float:POS[3];
	GetPlayerPos(playerid, POS[0],POS[1],POS[2]);
	//GetPlayerFacingAngle(playerid, POS[3]);
								
	new Float: pos_x = POS[0];
	new Float: pos_y = POS[1];
	new Float: pos_z = POS[2];
	//new Float: angle = 356.7986;

	SetGarageData(idx, GARAGE_PRICE,			price);
	
	format
	(
		fmt_text, sizeof fmt_text,
		"INSERT INTO garages \
		(price, x, y, z)\
		VALUES ('%d', '%f', '%f', '%f')",
		price,
		pos_x,
		pos_y,
		pos_z
	);

	result = mysql_query(mysql, fmt_text, true);

	SetGarageData(idx, GARAGE_ID, 		cache_insert_id());
	
	cache_delete(result);

	g_garage_loaded ++;


	CreatePickup(19134, 23, pos_x, pos_y, pos_z, 0, PICKUP_ACTION_TYPE_GARAGE, idx);

	//UpdateGarageLabel(idx);
	UpdateGarageInfo(idx);

	new city[MAX_ZONES_NAME + 1], area[MAX_ZONES_NAME + 1];
	GetCityName(GetGarageData(idx, GARAGE_X), GetGarageData(idx, GARAGE_Y), city);
	GetAreaName(GetGarageData(idx, GARAGE_X), GetGarageData(idx, GARAGE_Y), area);
	format(fmt_text, sizeof fmt_text, "[A] %s[%d] создал гараж №%d (%s / %s)", GetPlayerNameEx(playerid), playerid, idx, city, area);

	SendMessageToAdmins(fmt_text, 0x66CC33FF);

	SendClientMessage(playerid, 0x3399FFFF, "Используйте {FFFF00}/gsetexitpos{3399FF}, чтобы установить позицию выхода из гаража");

	return 1;
}		

CMD:gsetexitpos(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) < 13) return 1;

	extract params -> new garage_id; else return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /gsetexitpos [id гаража]");

	if(!(0 <= garage_id <= g_garage_loaded - 1)) return SendClientMessage(playerid, 0x999999FF, "Данного гаража не существует на сервере");

	new Float:POS[4];
	GetPlayerPos(playerid, POS[0],POS[1],POS[2]);
	GetPlayerFacingAngle(playerid, POS[3]);
								
	new Float: exit_pos_x = POS[0];
	new Float: exit_pos_y = POS[1];
	new Float: exit_pos_z = POS[2];
	new Float: exit_angle = POS[3];

	new fmt_text[144];

	format
	(
		fmt_text, sizeof fmt_text,
		"UPDATE garages SET exit_x='%f', exit_y='%f', exit_z='%f', exit_angle='%f' WHERE id=%d",
		exit_pos_x,
		exit_pos_y,
		exit_pos_z,
		exit_angle,
		GetGarageData(garage_id, GARAGE_ID)
	);

	mysql_query(mysql, fmt_text, false);

	format(fmt_text, sizeof fmt_text, "Вы успешно изменили координаты выхода у гаража №%d", garage_id);

	SendClientMessage(playerid, 0x66CC33FF, fmt_text);

	return 1;
}

CMD:garage(playerid, params[])
{
	new garageid = GetPlayerGarage(playerid);
	if(garageid != -1)
	{
		new fmt_str[1024];
		new city[MAX_ZONES_NAME + 1], area[MAX_ZONES_NAME + 1];
		GetCityName(GetGarageData(garageid, GARAGE_X), GetBusinessData(garageid, GARAGE_Y), city);
		GetAreaName(GetGarageData(garageid, GARAGE_X), GetBusinessData(garageid, GARAGE_Y), area);
		format
		(
			fmt_str, sizeof fmt_str,
			"{FFFFFF}Номер гаража:\t\t\t%d\n"\
			"Владелец:\t\t\t\t%s\n"\
			"Город / область:\t\t\t%s\n"\
			"Район:\t\t\t\t\t%s\n"\
			"{FFFFFF}Гос. стоимость:\t\t\t%d руб\n"\
			"Статус:\t\t\t\t\t%s\n\n"\
			"{669966}Для открытия панели управления вашим бизнесом\n"\
			"нажмите кнопку \"Изменить\"",
			garageid,
			GetGarageData(garageid, G_OWNER_NAME),
			city,
			area,
			GetGarageData(garageid, GARAGE_PRICE),
			GetGarageData(garageid, GARAGE_STATUS) ? ("{CC3333}гараж закрыт") : ("{66CC33}гараж открыт")
		);
		Dialog(playerid, DIALOG_GARAGE_INFO, DIALOG_STYLE_MSGBOX, "{33AACC}Информация о гараже", fmt_str, "Управление", "Выйти");
		
		//CreateBusinessMenuTextDraws(playerid);
	}
	else SendClientMessage(playerid, 0x999999FF, "У Вас нет гаража");

	return 1;
}

CMD:sellgarage(playerid, params[])
{
	new garageid = GetPlayerGarage(playerid);
	if(garageid != -1)
	{
		Dialog
		(
			playerid, DIALOG_GARAGE_SELL, DIALOG_STYLE_MSGBOX,
			"{FFCD00}Продажа гаража",
			"{FFFFFF}Вы уверены что хотите продать свой гараж государству?\n\n"\
			"Вам будет возвращено его стоимость за вычитом 30%\n"\
			"Если Вы хотите продать бизнес другому игроку,\n"\
			"используйте команду /sellmygarage",
			"Да", "Нет"
		);
	}
	else SendClientMessage(playerid, 0x999999FF, "У Вас нет гаража");

	return 1;
}

CMD:sellmygarage(playerid, params[])
{
	new garageid = GetPlayerGarage(playerid);
	if(garageid != -1)
	{
		if(!strlen(params))
			return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /sellmybiz [id игрока] [стоимость]");

		extract params -> new to_player, price;

		if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player) || to_player == playerid)
			return SendClientMessage(playerid, 0xCECECEFF, "Такого игрока нет");

		if(price < 1)
			return SendClientMessage(playerid, 0xCECECEFF, "Укажите стоимость продажи");

		new Float: g_pos_x = GetGarageData(garageid, GARAGE_X);
		new Float: g_pos_y = GetGarageData(garageid, GARAGE_Y);
		new Float: g_pos_z = GetGarageData(garageid, GARAGE_Z);

		if(GetPlayerMoneyEx(to_player) < price)
			return SendClientMessage(playerid, 0xCECECEFF, "У покупателя нет такого количества средств");

		if(!(IsPlayerInRangeOfPoint(playerid, 7.0, g_pos_x, g_pos_y, g_pos_z) && IsPlayerInRangeOfPoint(to_player, 7.0, g_pos_x, g_pos_y, g_pos_z)))
			SendClientMessage(playerid, 0xCECECEFF, "Вы и покупатель должны находиться рядом с гаражеи который хотите продать");

		SendPlayerOffer(playerid, to_player, OFFER_TYPE_SELL_GARAGE, garageid, price);
	}
	else SendClientMessage(playerid, 0x999999FF, "У Вас нет гаража");

	return 1;
}

stock spawningarage(playerid)
{
	new garageid = GetPlayerGarage(playerid);
	if(garageid != -1)
	{
	if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 1)
	{
		SetPlayerPosEx
		(
			playerid,
			1.265544,
            1996.246215,
            1554.203125,
            359.354705,
			1,
			garageid + 2000
		);
		SetPlayerInGarage(playerid, garageid);
	}
	else 
    if(GetGarageData(garageid, GARAGE_IMPROVEMENTS) == 2)
	{
		SetPlayerPosEx
		(
			playerid,
			499.663299,
            1983.485473,
            1547.686645,
             358.738708,
			1,
			garageid + 2000
		);
		SetPlayerInGarage(playerid, garageid);
	}
	}
	else 
    {
     SendClientMessage(playerid, 0x999999FF, "У Вас нет гаража");
     SetPlayerSpawnInit(playerid);
     SpawnPlayer(playerid);
     }
    return 1;
}

CMD:asellgarage(playerid, params[])
{
    if (GetPlayerAdminEx(playerid) < 6) return SendClientMessage(playerid, 0x999999FF, "У вас нет прав для использования этой команды.");

    new garageid;
    new reason[128];

    if (sscanf(params, "d s[128]", garageid, reason))
    {
        SendClientMessage(playerid, 0xCECECEFF, "Использование: /asellgarage [ID гаража] [Причина (необязательно)]");
        return 1;
    }

    if (garageid < 1 || garageid > MAX_GARAGES)
    {
        SendClientMessage(playerid, 0x999999FF, "Неверный ID гаража. ID должен быть от 1 до MAX_GARAGES.");
        return 1;
    }

    new query[256];
    new owner_account_id = 0;
    new former_owner_name[MAX_PLAYER_NAME + 1];

    mysql_format(mysql, query, sizeof(query), "SELECT `owner_id` FROM `garages` WHERE `id` = %d LIMIT 1", garageid);
    mysql_query(mysql, query);

    if (mysql_errno(mysql) != 0)
    {
        printf("[MySQL Error]: Ошибка при получении owner_id для гаража %d: %s", garageid, mysql_errno(mysql));
        SendClientMessage(playerid, COLOR_RED, "Ошибка базы данных при проверке владельца гаража. Пожалуйста, сообщите разработчикам.");
        return 1;
    }

    if (cache_num_rows() > 0)
    {
        owner_account_id = cache_get_field_content_int(0, "owner_id");
    }
    else
    {
        SendClientMessage(playerid, 0xCECECEFF, "Гараж с таким ID не найден в базе данных.");
        return 1;
    }

    if (owner_account_id > 0)
    {
        mysql_format(mysql, query, sizeof(query), "SELECT `name` FROM `accounts` WHERE `id` = %d LIMIT 1", owner_account_id);
        mysql_query(mysql, query);
        if (mysql_errno(mysql) != 0)
        {
            printf("[MySQL Error]: Ошибка при получении имени владельца аккаунта %d: %s", owner_account_id, mysql_errno(mysql));
            SendClientMessage(playerid, COLOR_RED, "Ошибка базы данных при получении имени владельца.");
            format(former_owner_name, sizeof(former_owner_name), "Неизвестный игрок (ID: %d)", owner_account_id);
        }
        else if (cache_num_rows() > 0)
        {
            cache_get_field_content(0, "name", former_owner_name, mysql, sizeof(former_owner_name));
        }
        else
        {
            format(former_owner_name, sizeof(former_owner_name), "Неизвестный игрок (ID: %d)", owner_account_id);
        }

        new garage_idx = garageid - 1;
        if (g_garage_loaded > garage_idx)
        {
            SetGarageData(garage_idx, GARAGE_OWNER_ID, 0);
            UpdateGarageInfo(garage_idx);
        }

        mysql_format(mysql, query, sizeof(query), "UPDATE `garages` SET `owner_id` = 0 WHERE `id` = %d LIMIT 1", garageid);
        mysql_query(mysql, query);
        if (mysql_errno(mysql) != 0)
        {
            printf("[MySQL Error]: Ошибка при обновлении garages.owner_id для гаража %d: %s", garageid, mysql_errno(mysql));
            SendClientMessage(playerid, COLOR_RED, "Ошибка БД при обнулении владельца гаража.");
            return 1;
        }

        mysql_format(mysql, query, sizeof(query), "UPDATE `accounts` SET `garage` = -1 WHERE `id` = %d LIMIT 1", owner_account_id);
        mysql_query(mysql, query);
        if (mysql_errno(mysql) != 0)
        {
            printf("[MySQL Error]: Ошибка при обновлении accounts.garage для владельца %d: %s", owner_account_id, mysql_errno(mysql));
            SendClientMessage(playerid, COLOR_RED, "Ошибка БД при обнулении гаража у владельца.");
            return 1;
        }

        SendClientMessage(playerid, 0x00FF00FF, !"Гараж успешно обнулен.");
        printf("[ADMIN]: Администратор %s (ID: %d) обнулил гараж ID: %d, бывший владелец аккаунт ID: %d",
               GetPlayerNameEx(playerid), playerid, garageid, owner_account_id);

        new broadcast_message[MAX_PLAYER_NAME + MAX_PLAYER_NAME + 150];
        format(broadcast_message, sizeof(broadcast_message), "Администратор %s обнулил гараж игрока %s", GetPlayerNameEx(playerid), former_owner_name);

        if(strlen(reason) > 0)
        {
            new reason_text[sizeof(reason) + 16];
            format(reason_text, sizeof(reason_text), ". Причина: %s", reason);
            strcat(broadcast_message, reason_text);
        }

        SendClientMessageToAll(0xFF5533FF, broadcast_message);
    }
    else
    {
        // Гараж уже никем не владеет (owner_id <= 0)
        SendClientMessage(playerid, 0x999999FF, !"Гаражом никто не владеет.");
    }

    return 1;
}