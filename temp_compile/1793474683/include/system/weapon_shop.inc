
#define MAX_WEAPONS 5
#define WEAPON_CATEGORY_ALL 0
#define WEAPON_CATEGORY_PISTOL 1
#define WEAPON_CATEGORY_RIFLE 2
#define WEAPON_CATEGORY_SHOTGUN 3
#define WEAPON_CATEGORY_SNIPER 4
#define WEAPON_CATEGORY_MELEE 5
#define WEAPON_CATEGORY_AMMO 6
#define WEAPON_CATEGORY_ARMOR 7

#define DIALOG_GUN_SHOP_MAIN 2000
#define DIALOG_GUN_SHOP_PISTOLS 2001
#define DIALOG_GUN_SHOP_RIFLES 2002
#define DIALOG_GUN_SHOP_SHOTGUNS 2003
#define DIALOG_GUN_SHOP_SNIPERS 2004
#define DIALOG_GUN_SHOP_CONFIRM 2005
#define DIALOG_GUN_SHOP_AMMO 2006
#define DIALOG_GUN_SHOP_ARMOR 2007

enum WeaponData
{
	W_ID,
	W_NAME[32],
	W_PRICE,
	W_AMMO,
	W_CATEGORY,
	W_DESCRIPTION[64]
};

new Weapons[MAX_WEAPONS][WeaponData] = 
{
	{25, "Помповый дробовик", 40000, 50, WEAPON_CATEGORY_SHOTGUN, "Помповое оружие ближнего боя"},
	{29, "Штурмовой укороченный автомат", 60000, 100, WEAPON_CATEGORY_RIFLE, "Компактный автомат"},
	{31, "Штурмовой автомат", 70000, 100, WEAPON_CATEGORY_RIFLE, "Полноразмерный автомат"},
	{33, "Охотничья винтовка", 50000, 50, WEAPON_CATEGORY_SNIPER, "Дальнобойная винтовка"},
	{24, "Боевой пистолет", 65000, 50, WEAPON_CATEGORY_PISTOL, "Мощный пистолет"}
};

enum AmmoPackData
{
	A_NAME[32],
	A_PRICE,
	A_AMOUNT,
	A_DESCRIPTION[64]
};

new AmmoPacks[4][AmmoPackData] =
{
	{"Пачка патронов для дробовика", 1680, 50, "Патроны для дробовика"},
	{"Пачка патронов для автомата", 3600, 100, "Патроны для автоматического оружия"},
	{"Пачка патронов для винтовки", 1200, 30, "Патроны для винтовки"},
	{"Пачка патронов для пистолета", 1250, 40, "Патроны для пистолета"}
};

enum ArmorData
{
	AR_NAME[32],
	AR_PRICE,
	AR_AMOUNT,
	AR_DESCRIPTION[64]
};

new Armor[4][ArmorData] =
{
	{"Лёгкий жилет", 2500, 50, "Стандартная защита"},
	{"Боевой жилет", 5000, 100, "Усиленная защита"},
	{"Тактический жилет", 8000, 150, "Профессиональная защита"},
	{"Спецназовский жилет", 12000, 200, "Максимальная защита"}
};

new g_PlayerSelectedWeapon[MAX_PLAYERS] = {-1, ...};
new g_PlayerSelectedAmmoPack[MAX_PLAYERS] = {-1, ...};
new g_PlayerSelectedArmor[MAX_PLAYERS] = {-1, ...};
new g_PlayerWeaponCategory[MAX_PLAYERS] = {WEAPON_CATEGORY_ALL, ...};

#define STATIC_GUN_SHOP_COUNT (7)
#define STATIC_GUN_SHOP_INTERIOR (1)
#define STATIC_GUN_SHOP_WORLD (0)
#define STATIC_GUN_SHOP_PICKUP_MODEL (19132)
#define STATIC_GUN_SHOP_NPC_MODEL (102)
#define STATIC_GUN_SHOP_NPC_RANGE (2.2)
#define STATIC_GUN_SHOP_EXIT_DISTANCE (2.5)

new const Float:g_static_gun_shop_pos[STATIC_GUN_SHOP_COUNT][3] =
{
	{207.629000, 829.766000, 13.383100},
	{2350.050000, -2138.410000, 22.570600},
	{-2381.790000, -60.819000, 26.752400},
	{-1788.000000, 671.136000, 35.399800},
	{1950.070000, 1899.340000, 15.558000},
	{-1931.960000, 2380.450000, 58.652100},
	{-2560.400000, 1078.310000, 10.390000}
};

new const Float:g_static_gun_shop_enter_pos[4] = {91.174934, -4.497013, 1002.046936, 7.039999};
new const Float:g_static_gun_shop_exit_pos[4] = {91.463623, -6.881072, 1002.046936, 177.447967};
new const Float:g_static_gun_shop_npc_pos[4] = {94.211112, 7.443953, 1002.046936, 135.360992};

new g_static_gun_shop_npc_area = -1;
new g_static_gun_shop_player_entrance[MAX_PLAYERS] = {-1, ...};
new Float:g_static_gun_shop_player_exit_pos[MAX_PLAYERS][4];

stock bool:WeaponShop_IsPlayerNearStaticNpc(playerid)
{
	if(GetPlayerInterior(playerid) != STATIC_GUN_SHOP_INTERIOR) return false;
	if(GetPlayerVirtualWorld(playerid) != STATIC_GUN_SHOP_WORLD) return false;
	if(!IsPlayerInRangeOfPoint(playerid, STATIC_GUN_SHOP_NPC_RANGE, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2])) return false;
	return true;
}

stock WeaponShop_UpdateStaticShopExitPos(playerid, shopid)
{
	new Float:x, Float:y, Float:z, Float:angle;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

	new Float:dir_x = x - g_static_gun_shop_pos[shopid][0];
	new Float:dir_y = y - g_static_gun_shop_pos[shopid][1];
	new Float:distance = floatsqroot((dir_x * dir_x) + (dir_y * dir_y));

	if(distance < 0.25)
	{
		dir_x = floatsin(-angle + 180.0, degrees);
		dir_y = floatcos(-angle + 180.0, degrees);
	}
	else
	{
		dir_x /= distance;
		dir_y /= distance;
	}

	g_static_gun_shop_player_exit_pos[playerid][0] = g_static_gun_shop_pos[shopid][0] + (dir_x * STATIC_GUN_SHOP_EXIT_DISTANCE);
	g_static_gun_shop_player_exit_pos[playerid][1] = g_static_gun_shop_pos[shopid][1] + (dir_y * STATIC_GUN_SHOP_EXIT_DISTANCE);
	g_static_gun_shop_player_exit_pos[playerid][2] = g_static_gun_shop_pos[shopid][2];
	g_static_gun_shop_player_exit_pos[playerid][3] = angle;
	return 1;
}

stock WeaponShop_CreateStaticShops()
{
	new label_text[160];
	format(label_text, sizeof label_text, "{FFFF00}Амуниция (65)\n{FFFF00}Крыша: отсуствует\n{FFFFFF}Владелец: {0b7ecf}BR BONUS");

	for(new i; i < STATIC_GUN_SHOP_COUNT; i++)
	{
		CreatePickup(STATIC_GUN_SHOP_PICKUP_MODEL, 23, g_static_gun_shop_pos[i][0], g_static_gun_shop_pos[i][1], g_static_gun_shop_pos[i][2], STATIC_GUN_SHOP_WORLD, PICKUP_ACTION_TYPE_STATIC_GUN_SHOP, i);
		CreateDynamic3DTextLabel(label_text, 0xFFFF00FF, g_static_gun_shop_pos[i][0], g_static_gun_shop_pos[i][1], g_static_gun_shop_pos[i][2] + 1.0, 10.0, _, _, _, STATIC_GUN_SHOP_WORLD, 0);
	}

	new actorid = CreateActor(STATIC_GUN_SHOP_NPC_MODEL, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2], g_static_gun_shop_npc_pos[3]);
	if(actorid != -1) SetActorVirtualWorld(actorid, STATIC_GUN_SHOP_WORLD);

	CreateDynamic3DTextLabel("{0b7ecf}Покупка{0b7ecf}\n{FFFFFF}Оружия{FFFFFF}", 0x0B7ECFFF, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2] + 1.1, 8.0, _, _, _, STATIC_GUN_SHOP_WORLD, STATIC_GUN_SHOP_INTERIOR);
	g_static_gun_shop_npc_area = CreateDynamicSphere(g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2], STATIC_GUN_SHOP_NPC_RANGE, STATIC_GUN_SHOP_WORLD, STATIC_GUN_SHOP_INTERIOR);

	CreatePickup(STATIC_GUN_SHOP_PICKUP_MODEL, 23, g_static_gun_shop_exit_pos[0], g_static_gun_shop_exit_pos[1], g_static_gun_shop_exit_pos[2], STATIC_GUN_SHOP_WORLD, PICKUP_ACTION_TYPE_STATIC_GUN_SHOP_EXIT, 0);
	return 1;
}

stock WeaponShop_EnterStaticShop(playerid, shopid)
{
	if(shopid < 0 || shopid >= STATIC_GUN_SHOP_COUNT) shopid = 0;
	g_static_gun_shop_player_entrance[playerid] = shopid;
	WeaponShop_UpdateStaticShopExitPos(playerid, shopid);
	SetPlayerInBiz(playerid, -1);
	SetPlayerPosEx(playerid, g_static_gun_shop_enter_pos[0], g_static_gun_shop_enter_pos[1], g_static_gun_shop_enter_pos[2], g_static_gun_shop_enter_pos[3], STATIC_GUN_SHOP_INTERIOR, STATIC_GUN_SHOP_WORLD);
	return 1;
}

stock WeaponShop_ExitStaticShop(playerid)
{
	new shopid = g_static_gun_shop_player_entrance[playerid];
	new bool:has_exit_pos = (0 <= shopid < STATIC_GUN_SHOP_COUNT);
	if(!has_exit_pos) shopid = 0;
	g_static_gun_shop_player_entrance[playerid] = -1;

	if(has_exit_pos)
	{
		SetPlayerPosEx(playerid, g_static_gun_shop_player_exit_pos[playerid][0], g_static_gun_shop_player_exit_pos[playerid][1], g_static_gun_shop_player_exit_pos[playerid][2], g_static_gun_shop_player_exit_pos[playerid][3], 0, STATIC_GUN_SHOP_WORLD);
	}
	else
	{
		SetPlayerPosEx(playerid, g_static_gun_shop_pos[shopid][0], g_static_gun_shop_pos[shopid][1] - STATIC_GUN_SHOP_EXIT_DISTANCE, g_static_gun_shop_pos[shopid][2], 0.0, 0, STATIC_GUN_SHOP_WORLD);
	}
	return 1;
}

stock WeaponShop_OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid != g_static_gun_shop_npc_area) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return 1;
	ShowGunShopMenu(playerid);
	return 1;
}

stock ShowGunShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;
	
	
	new string[512];
	string[0] = '\0';
	
	strcat(string, "{FF5252}1. {FFFFFF}Оружие\n");
	strcat(string, "{FF5252}2. {FFFFFF}Боеприпасы\n");
	strcat(string, "{FF5252}3. {FFFFFF}Экипировка\n");
	
	Dialog(playerid, DIALOG_GUN_SHOP_MAIN, DIALOG_STYLE_LIST,
		"{FF5252}BR BONUS {FFFFFF}| Магазин амуниции",
		string,
		"Выбрать", "Закрыть");
	return 1;
}

stock WeaponShop_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid != DIALOG_BIZ_SHOP_GUN && dialogid != DIALOG_GUN_SHOP_MAIN && dialogid != DIALOG_GUN_SHOP_PISTOLS && dialogid != DIALOG_GUN_SHOP_AMMO && dialogid != DIALOG_GUN_SHOP_ARMOR && dialogid != DIALOG_GUN_SHOP_CONFIRM)
		return 0;

	if(dialogid == DIALOG_BIZ_SHOP_GUN)
	{
		if(!response) return 1;
		ShowGunShopMenu(playerid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_MAIN)
	{
		if(!response) return 1;

		if(listitem == 0)
		{
			ShowWeaponsByCategory(playerid, WEAPON_CATEGORY_ALL);
		}
		else if(listitem == 1)
		{
			ShowAmmoShopMenu(playerid);
		}
		else if(listitem == 2)
		{
			ShowArmorShopMenu(playerid);
		}
		else
		{
			ShowGunShopMenu(playerid);
		}
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_PISTOLS)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new category = g_PlayerWeaponCategory[playerid];
		new count = 0, weaponid = -1;

		for(new i = 0; i < MAX_WEAPONS; i++)
		{
			if(category == WEAPON_CATEGORY_ALL || Weapons[i][W_CATEGORY] == category)
			{
				if(count == listitem)
				{
					weaponid = i;
					break;
				}
				count++;
			}
		}

		if(weaponid == -1)
		{
			ShowWeaponsByCategory(playerid, category);
			return 1;
		}

		ShowWeaponConfirmDialog(playerid, weaponid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_AMMO)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new ammoid = listitem;
		if(ammoid < 0 || ammoid >= 4)
		{
			ShowAmmoShopMenu(playerid);
			return 1;
		}

		ShowAmmoConfirmDialog(playerid, ammoid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_ARMOR)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new armorid = listitem;
		if(armorid < 0 || armorid >= 4)
		{
			ShowArmorShopMenu(playerid);
			return 1;
		}

		ShowArmorConfirmDialog(playerid, armorid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_CONFIRM)
	{
		if(!response)
		{
			if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_AMMO)
				return ShowAmmoShopMenu(playerid), 1;
			else if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_ARMOR)
				return ShowArmorShopMenu(playerid), 1;
			return ShowWeaponsByCategory(playerid, g_PlayerWeaponCategory[playerid]), 1;
		}

		if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_AMMO)
			BuyAmmoFromShop(playerid);
		else if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_ARMOR)
			BuyArmorFromShop(playerid);
		else
			BuyWeaponFromShop(playerid);
		return 1;
	}

	return 0;
}

stock ShowWeaponsByCategory(playerid, category)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;
	
	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';
	
	strcat(string, "{FFFFFF}№\tНаименование\tЦена\tДействие\n");
	new category_name[32] = "Оружие";
	
	if(category == WEAPON_CATEGORY_PISTOL)
	{
		format(category_name, sizeof(category_name), "Пистолеты");
	}
	else if(category == WEAPON_CATEGORY_RIFLE)
	{
		format(category_name, sizeof(category_name), "Винтовки");
	}
	else if(category == WEAPON_CATEGORY_SHOTGUN)
	{
		format(category_name, sizeof(category_name), "Дробовики");
	}
	else if(category == WEAPON_CATEGORY_SNIPER)
	{
		format(category_name, sizeof(category_name), "Снайперские");
	}
	else if(category == WEAPON_CATEGORY_MELEE)
	{
		format(category_name, sizeof(category_name), "Холодное");
	}

	for(i = 0; i < MAX_WEAPONS; i++)
	{
		if(category == WEAPON_CATEGORY_ALL || Weapons[i][W_CATEGORY] == category)
		{
			format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d руб.\t{FFFFFF}нажмите для выбора\n",
				count + 1,
				Weapons[i][W_NAME],
				Weapons[i][W_PRICE]
			);
			strcat(string, temp);
			count++;
		}
	}
	
	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: нет оружия в этой категории"), 0;
	
	new title[128];
	format(title, sizeof(title), "{FF5252}BR BONUS {FFFFFF}| %s", category_name);
	
	Dialog(playerid, DIALOG_GUN_SHOP_PISTOLS, DIALOG_STYLE_TABLIST_HEADERS,
		title, string, "Купить", "Назад");
	
	g_PlayerWeaponCategory[playerid] = category;
	return 1;
}

stock ShowAmmoShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;


	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';
	strcat(string, "{FFFFFF}№\tНаименование\tЦена\tДействие\n");

	for(i = 0; i < 4; i++)
	{
		format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d руб.\t{FFFFFF}нажмите для выбора\n",
			i + 1,
			AmmoPacks[i][A_NAME],
			AmmoPacks[i][A_PRICE]
		);
		strcat(string, temp);
		count++;
	}

	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: нет боеприпасов в магазине"), 0;

	Dialog(playerid, DIALOG_GUN_SHOP_AMMO, DIALOG_STYLE_TABLIST_HEADERS,
		"{FF5252}BR BONUS {FFFFFF}| Боеприпасы",
		string,
		"Купить", "Назад");

	g_PlayerWeaponCategory[playerid] = WEAPON_CATEGORY_AMMO;
	return 1;
}

stock ShowAmmoConfirmDialog(playerid, ammoid)
{
	if(ammoid < 0 || ammoid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректный патрон"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;

	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}Вы собираетесь приобрести: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Стоимость за пачку ({FF5252}%d шт.{FFFFFF}): {FF5252}%d рублей.",
		AmmoPacks[ammoid][A_NAME],
		AmmoPacks[ammoid][A_AMOUNT],
		AmmoPacks[ammoid][A_PRICE]
	);

	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Купить патроны",
		message, "Далее", "Назад");

	g_PlayerSelectedAmmoPack[playerid] = ammoid;
	return 1;
}

stock BuyAmmoFromShop(playerid)
{
	new ammoid = g_PlayerSelectedAmmoPack[playerid];

	if(ammoid < 0 || ammoid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректный патрон"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;

	new price = AmmoPacks[ammoid][A_PRICE];
	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректная цена"), 0;

	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Недостаточно денег! Требуется %d руб.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}

	new query[512];
	format(query, sizeof query,
		"UPDATE accounts SET money=%d WHERE id=%d LIMIT 1",
		GetPlayerMoneyEx(playerid) - price,
		GetPlayerAccountID(playerid)
	);
	mysql_query(mysql, query, false);

	if(mysql_errno() != 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка БД. Повторите попытку (28)"), 0;

	AddPlayerData(playerid, P_AMMO, +, AmmoPacks[ammoid][A_AMOUNT]);
	UpdatePlayerDatabaseInt(playerid, "ammo", GetPlayerData(playerid, P_AMMO));
	GivePlayerMoneyEx(playerid, -price, "Покупка боеприпасов", false, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, вы приобрели %s (%d шт.) за %d рублей.", playername, AmmoPacks[ammoid][A_NAME], AmmoPacks[ammoid][A_AMOUNT], price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new notify[128];
	format(notify, sizeof(notify), "Вы потратили %d руб", price);
	ShowNotificationLaird(playerid, 0, 6, 0, 0, notify, " ");

	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

	g_PlayerSelectedAmmoPack[playerid] = -1;
	return 1;
}

stock ShowWeaponConfirmDialog(playerid, weaponid)
{
	if(weaponid < 0 || weaponid >= MAX_WEAPONS) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректное оружие"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;
	
	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}Вы собираетесь приобрести оружие: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Стоимость: {FF5252}%d рублей.",
		Weapons[weaponid][W_NAME],
		Weapons[weaponid][W_PRICE]
	);
	
	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Купить оружие", message, "Далее", "Назад");
	
	g_PlayerSelectedWeapon[playerid] = weaponid;
	return 1;
}

stock WeaponShop_GetWeaponSlot(weapon_id)
{
	switch(weapon_id)
	{
		case 0, 1: return 0;
		case 2..9: return 1;
		case 22..24: return 2;
		case 25..27: return 3;
		case 28, 29, 32: return 4;
		case 30, 31: return 5;
		case 33, 34: return 6;
		case 35..38: return 7;
		case 16..18: return 8;
		case 41..43: return 9;
		case 10..15: return 10;
		case 44..46: return 11;
		case 40: return 12;
	}
	return 0;
}

stock WeaponShop_GiveReplacementWeapon(playerid, weapon_id, weapon_ammo)
{
	new replace_slot = WeaponShop_GetWeaponSlot(weapon_id);
	new slot_weapon[13], slot_ammo[13];

	for(new idx; idx < 13; idx++)
	{
		GetPlayerWeaponData(playerid, idx, slot_weapon[idx], slot_ammo[idx]);
	}

	ResetPlayerWeapons(playerid);

	for(new idx; idx < 13; idx++)
	{
		if(idx == replace_slot) continue;
		if(slot_weapon[idx] == 0 || slot_ammo[idx] <= 0) continue;

		GivePlayerWeapon(playerid, slot_weapon[idx], slot_ammo[idx]);
	}

	GivePlayerWeapon(playerid, weapon_id, weapon_ammo);
	return 1;
}

stock BuyWeaponFromShop(playerid)
{
	new weaponid = g_PlayerSelectedWeapon[playerid];
	
	if(weaponid < 0 || weaponid >= MAX_WEAPONS) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректное оружие"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;
	
	new price = Weapons[weaponid][W_PRICE];
	new weapon_name[32];
	
	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректная цена"), 0;
	strmid(weapon_name, Weapons[weaponid][W_NAME], 0, strlen(Weapons[weaponid][W_NAME]));
	
	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Недостаточно денег! Требуется %d руб.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}
	
	new query[512];
	format(query, sizeof query, 
		"UPDATE accounts SET money=%d WHERE id=%d LIMIT 1", 
		GetPlayerMoneyEx(playerid) - price, 
		GetPlayerAccountID(playerid)
	);
	
	mysql_query(mysql, query, false);
	
	if(mysql_errno() != 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка БД. Повторите попытку (28)"), 0;
	
	WeaponShop_GiveReplacementWeapon(playerid, Weapons[weaponid][W_ID], Weapons[weaponid][W_AMMO]);
	GivePlayerMoneyEx(playerid, -price, "Покупка оружия", false, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, вы приобрели оружие %s (1 шт.) за %d рублей.", playername, weapon_name, price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new notify[128];
	format(notify, sizeof(notify), "Вы потратили %d руб", price);
	ShowNotificationLaird(playerid, 0, 6, 0, 0, notify, " ");
	
	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);
	
	g_PlayerSelectedWeapon[playerid] = -1;
	return 1;
}

stock GetWeaponIndexByName(const weapon_name[])
{
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(!strcmp(Weapons[i][W_NAME], weapon_name, true)) return i;
	}
	return -1;
}

stock GetWeaponNameByID(weaponid)
{
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(Weapons[i][W_ID] == weaponid) return i;
	}
	return -1;
}

stock ShowArmorShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;


	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';
	strcat(string, "{FFFFFF}номер\tнаименование\tстоимость\tдоступное действие\n");

	for(i = 0; i < 4; i++)
	{
		format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d руб.\t{FFFFFF}нажмите для взаимодействия\n",
			i + 1,
			Armor[i][AR_NAME],
			Armor[i][AR_PRICE]
		);
		strcat(string, temp);
		count++;
	}

	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: нет экипировки в магазине"), 0;

	Dialog(playerid, DIALOG_GUN_SHOP_ARMOR, DIALOG_STYLE_TABLIST_HEADERS,
		"{FF5252}BR BONUS {FFFFFF}| Экипировка",
		string,
		"Купить", "Назад");

	g_PlayerWeaponCategory[playerid] = WEAPON_CATEGORY_ARMOR;
	return 1;
}

stock ShowArmorConfirmDialog(playerid, armorid)
{
	if(armorid < 0 || armorid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректная экипировка"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;

	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}Вы собираетесь приобрести экипировку: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Стоимость: {FF5252}%d рублей.",
		Armor[armorid][AR_NAME],
		Armor[armorid][AR_PRICE]
	);

	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Купить экипировку", message, "Далее", "Назад");

	g_PlayerSelectedArmor[playerid] = armorid;
	return 1;
}

stock BuyArmorFromShop(playerid)
{
	new armorid = g_PlayerSelectedArmor[playerid];

	if(armorid < 0 || armorid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректная экипировка"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Подойдите ближе к продавцу оружия"), 0;

	new price = Armor[armorid][AR_PRICE];
	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка: некорректная цена"), 0;

	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Недостаточно денег! Требуется %d руб.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}

	new query[512];
	format(query, sizeof query,
		"UPDATE accounts SET money=%d WHERE id=%d LIMIT 1",
		GetPlayerMoneyEx(playerid) - price,
		GetPlayerAccountID(playerid)
	);
	mysql_query(mysql, query, false);

	if(mysql_errno() != 0) return SendClientMessage(playerid, 0xFF0000FF, "Ошибка БД. Повторите попытку (28)"), 0;

	SetPlayerArmour(playerid, Armor[armorid][AR_AMOUNT]);
	GivePlayerMoneyEx(playerid, -price, "Покупка экипировки", false, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, вы приобрели %s за %d рублей.", playername, Armor[armorid][AR_NAME], price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new broadcast[128];
	format(broadcast, sizeof(broadcast), "%s купил(а) %s", playername, Armor[armorid][AR_NAME]);
	SendClientMessage(-1, 0xFF66CCFF, broadcast);

	new notify[128];
	format(notify, sizeof(notify), "Вы потратили %d руб", price);
	ShowNotificationLaird(playerid, 0, 6, 0, 0, notify, " ");

	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

	g_PlayerSelectedArmor[playerid] = -1;
	return 1;
}
