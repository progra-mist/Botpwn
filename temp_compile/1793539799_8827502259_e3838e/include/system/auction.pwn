#define MAX_AUCTION_SLOT 1024
#define MAX_AUCTION_LIST 256

#define TYPE_BUSINESS         1
#define TYPE_VEHICLE          2
#define TYPE_HOUSE            3
#define TYPE_VEHICLE_NUMBER   4
#define TYPE_SUM_NUMBER       5
#define TYPE_CLOTHES          6
#define TYPE_ACCESSORY        7
#define TYPE_FUEL_STATION     8

#define AUCTION_WORLD               183
#define AUCTION_DEFAULT_DURATION    (24 * 60 * 60)
#define AUCTION_STATE_DURATION      (2 * 60 * 60)
#define AUCTION_DIALOG_RESULT       5994

new enter_auction, exit_auction;
new auction_exit_pickup;

new type_slot[9][24] =
{
    {""},
    {"Бизнес"},
    {"Транспортное_средство"},
    {"Недвижимость"},
    {"Номерной_знак"},
    {"Сим-карта"},
    {"Одежда"},
    {"Аксессуар"},
    {"АЗС"}
};

new icon_slot[9][20] =
{
    {""},
    {"txd:braucbiz"},
    {"txd:brauccar"},
    {"txd:brauchome"},
    {"txd:braucnumber"},
    {"txd:braucsimcard"},
    {"txd:brauccloth"},
    {"txd:brauccloth"},
    {"txd:braucbiz"}
};

new bool:load_business_action;
new bool:gAuctionDatabaseReady;
new bool:gAuctionNoticeShown[MAX_PLAYERS];
new gAuctionServiceBiz[9] = {-1, -1, -1, -1, -1, -1, -1, -1, -1};

enum STRUCT_AUCTION_SLOT
{
    SLOT_TYPE,
    OWNER_SLOT_SQL,
    OWNER_SLOT_NAME[24],
    SLOT_NAME[32],
    OPISANIE_SLOT[124],
    OWNER_RATE,
    START_RATE,
    CURRENT_RATE,
    TIMER_END,
    DATABASE_ID,
    SERVER_ID,
    NUMBER_VEHICLE[16],
    NUMBER_SUM,

    AUCTION_DB_ID,
    ITEM_ID,
    ITEM_MODEL,
    ITEM_AMOUNT,
    ITEM_EXTRA_1,
    ITEM_EXTRA_2,
    ITEM_OLD_SKIN,
    ITEM_SIM,
    ITEM_OLD_SIM,
    ITEM_META[40]
}

new auction_slot[MAX_AUCTION_SLOT][STRUCT_AUCTION_SLOT];

new player_cd_auction[MAX_PLAYERS];
new PlayerText:auction_PTD[MAX_PLAYERS][40];

new slot_td[4][3] = //айди тд где информация о слоте
{
    {11, 12, 13},
    {15, 16, 17},
    {19, 20, 21},
    {7, 8, 9}
};

enum STRUCT_AUCTION_PANEL
{
    bool:show_panel,
    count_list,
    select_slot,
    select_type,
    select_tab,
    filter_min_price,
    filter_max_price,
    filter_type,
    filter_tovar_type,
    filter_vehicle_model,
    bool:type_tovar, 
    bool:price_tovar, 
    bool:opisanie_tovar, 
    bool:tovar,
}

new player_show_slot[MAX_PLAYERS][4];
new player_info_panel[MAX_PLAYERS][STRUCT_AUCTION_PANEL];

/*new type_panel_auction[3][14] =
{
    {"txd:braucbuy"},
    {"txd:braucsell"},
    {"txd:braucmy"}
};*/
new auction_button[8][2][20] =
{
    {"txd:braucnulist", "txd:brauculist"}, //slot
    {"txd:braucnubuy", "txd:braucubuy"}, //купить
    {"txd:braucnusell", "txd:braucusell"}, //продать
    {"txd:braucnumy", "txd:braucumy"}, //вкладка мое
    {"txd:braucnutip", "txd:braucutip"}, //тип товара
    {"txd:braucnutovar", "txd:braucutovar"}, //выбор товара
    {"txd:braucnuopisanie", "txd:braucuopisanie"}, //описание товара
    {"txd:braucnucost", "txd:braucucost"} //цена товара
};




public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == AUCTION_DIALOG_RESULT)
    {
        SetTimerEx("Auction_ShowPendingResult", 250, false, "i", playerid);
        return 1;
    }

    if(dialogid == 5990)
    {
        if(!response) return 1;

        new rate = strval(inputtext);
        new id = GetPVarInt(playerid, "select_slot");
        if(id < 0 || id >= MAX_AUCTION_SLOT || !auction_slot[id][SLOT_TYPE])
            return SendClientMessage(playerid, -1, ""USC" Лот больше не существует.");

        if(auction_slot[id][TIMER_END] <= gettime())
        {
            finish_auction_slot(id);
            return SendClientMessage(playerid, -1, ""USC" Торги по этому лоту уже завершены.");
        }

        new account_id = GetPlayerAccountID(playerid);
        if(account_id <= 0) return 1;
        if(auction_slot[id][OWNER_SLOT_SQL] == account_id)
            return SendClientMessage(playerid, -1, ""USC" Нельзя делать ставку на собственный лот.");

        new min_rate = auction_slot[id][CURRENT_RATE] + ((auction_slot[id][CURRENT_RATE] * 2) / 100);
        if(min_rate <= auction_slot[id][CURRENT_RATE]) min_rate = auction_slot[id][CURRENT_RATE] + 1;
        if(rate < min_rate)
            return SendClientMessage(playerid, -1, ""SC" Ваша ставка должна быть выше минимальной ставки на лот.");

        new old_bidder = auction_slot[id][OWNER_RATE];
        new old_rate = auction_slot[id][CURRENT_RATE];
        new charge = rate;

        if(old_bidder == account_id)
            charge = rate - old_rate;

        if(charge <= 0 || GetPlayerMoneyEx(playerid) < charge)
            return SendClientMessage(playerid, -1, ""USC" У Вас недостаточно денег для этой ставки.");

        if(old_bidder > 0 && old_bidder != account_id)
        {
            Auction_RefundAccount(old_bidder, old_rate);
            Auction_CreateNotification(old_bidder, auction_slot[id][AUCTION_DB_ID], 3, auction_slot[id][SLOT_NAME], 0, old_rate);
        }

        GivePlayerMoneyEx(playerid, -charge);
        auction_slot[id][OWNER_RATE] = account_id;
        auction_slot[id][CURRENT_RATE] = rate;
        if(auction_slot[id][SLOT_TYPE] == TYPE_BUSINESS)
            auction_slot[id][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
        Auction_SaveLot(id);

        default_select_slot(playerid);
        player_info_panel[playerid][select_slot] = 0;
        for(new i = 1; i < 6; i++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][i], "-");
        SendClientMessage(playerid, -1, ""SC" Ваша ставка принята. Деньги зарезервированы до завершения торгов.");
        return 1;
    }
    if(dialogid == 5991)
    {
        if(!response) return 0;

        switch(GetPVarInt(playerid, "select_param"))
        {
            case 1://type
            {
                switch(listitem + 1)
                {
                    case 1:SetPVarInt(playerid, "type_param", TYPE_VEHICLE);
                    case 2:SetPVarInt(playerid, "type_param", TYPE_HOUSE);
                    case 3:SetPVarInt(playerid, "type_param", TYPE_BUSINESS);
                    case 4:SetPVarInt(playerid, "type_param", TYPE_VEHICLE_NUMBER);
                    case 5:SetPVarInt(playerid, "type_param", TYPE_SUM_NUMBER);
                    case 6:SetPVarInt(playerid, "type_param", TYPE_CLOTHES);
                    case 7:SetPVarInt(playerid, "type_param", TYPE_ACCESSORY);
                }

                if(!player_info_panel[playerid][type_tovar])
                {
                    player_info_panel[playerid][type_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][1]);
                } 

                PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[GetPVarInt(playerid, "type_param")]);
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], type_slot[GetPVarInt(playerid, "type_param")]);
            }
            case 2: // opisanie
            {
                //if(!inputtext) return SendClientMessage(playerid, -1, ""USC" Нельзя оставлять описание пустым");

                SetPVarString(playerid, "opisanie_param", inputtext);

                if(!player_info_panel[playerid][opisanie_tovar])
                {
                    player_info_panel[playerid][opisanie_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][1]);
                }
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], "Есть");
            }
            case 3://price
            {
                new price;

                sscanf(inputtext, "d", price);

                if(price >= 1_000_000_001 || price <= 4_999) return SendClientMessage(playerid, -1, ""USC" Введите сумму от 5000 руб до 1000000000 руб");

                SetPVarInt(playerid, "price_param", price);

                if(!player_info_panel[playerid][price_tovar])
                {
                    player_info_panel[playerid][price_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][1]);
                } 
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], inputtext);
            }
        }
    }
    if(dialogid == 5992) // согласие
    {
        if(!response) return 1;

        new text[124], name[24];

        switch(GetPVarInt(playerid, "type_param"))
        {
            case TYPE_VEHICLE_NUMBER, TYPE_SUM_NUMBER, TYPE_CLOTHES, TYPE_ACCESSORY:
            {
                if(!GetPVarInt(playerid, "auction_inventory_confirmed"))
                {
                    new source_slot = GetPlayerListitemValue(playerid, listitem);
                    new selected_name[64];

                    if(!Auction_SelectInventorySource(playerid, GetPVarInt(playerid, "type_param"), source_slot, selected_name, sizeof(selected_name)))
                        return 1;

                    SetPVarInt(playerid, "auction_inventory_confirmed", 1);
                    format(text, sizeof text, "Вы хотите выставить на аукцион %s?", selected_name);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                    return 1;
                }

                Auction_GetSelectedInventoryName(playerid, name, sizeof(name));
            }
            case TYPE_BUSINESS:
                format(name, 24, GetBusinessData(GetPVarInt(playerid, "tovar_param_server"), B_NAME));

            case TYPE_HOUSE:
                format(name, 24, "Дом %d", GetPVarInt(playerid, "tovar_param_server"));
case TYPE_VEHICLE:
            {
                new id = GetVehicleModel(GetPVarInt(playerid, "tovar_param_server")) - 400;
                format(name, 24, ProbelText(GetVehicleInfo(id, VI_NAME)));
            }
        }

        if(!player_info_panel[playerid][tovar])
        {
            player_info_panel[playerid][tovar] = true;
            PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][1]);
        }
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], name);

    }
    if(dialogid == 5993)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "filter_select_veh"))
            {
                new model = GetPlayerListitemValue(playerid, listitem);

                player_info_panel[playerid][filter_vehicle_model] = model;
                player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE;

                player_info_panel[playerid][count_list] = 1;
                LeafAuction(playerid, 3);
                DeletePVar(playerid, "filter_select_veh");

                return 1;
            }
            else if(player_info_panel[playerid][filter_type] == 2)
            {
                new min_price, max_price;

                if(sscanf(inputtext, "P<,>dd", min_price, max_price))
                {
                    SendClientMessage(playerid, 0x999999FF, "Некорректный ввод");
                    player_info_panel[playerid][filter_type] = 0;

                    return OnDialogResponse(playerid, 5993, 1, 1, "");
                }
                else
                {
                    if(min_price >= max_price) 
                    {
                        SendClientMessage(playerid, 0xFFFFFFFF, ""USC" Минимальная цена должна быть меньше чем максимальная");
                        player_info_panel[playerid][filter_type] = 0;

                        return OnDialogResponse(playerid, 5993, 1, 1, "");
                    }
                    else if(min_price <= 999 || max_price >= 500_000_000)
                    {
                        SendClientMessage(playerid, 0xFFFFFFFF, ""USC" Цена должна быть от 1000 руб до 500000000 руб");
                        player_info_panel[playerid][filter_type] = 0;

                        return OnDialogResponse(playerid, 5993, 1, 1, "");                               
                    }
                    else
                    {
                        player_info_panel[playerid][filter_type] = 2;
                        player_info_panel[playerid][filter_min_price] = min_price;
                        player_info_panel[playerid][filter_max_price] = max_price;

                        player_info_panel[playerid][count_list] = 1;
                        LeafAuction(playerid, 3);
                        return 1;
                    }
                }
            }
            else if(player_info_panel[playerid][filter_type] == 1)
            {
                if(player_info_panel[playerid][filter_tovar_type] == TYPE_VEHICLE)
                {
                    new dialog[284], list[54], market;

                    switch(listitem+1)
                    {
                        case 1:market = 1;
                        case 2:market = 3;
                        case 3:market = 2;
                    }

                    for(new v, model; v < 32;v++)
                    {
                        if(!car_market_data[market][v][0]) continue;

                        model = car_market_data[market][v][0]-400;

                        format(list, sizeof list, "%d. %s\n", v + 1, GetVehicleInfo(model, VI_NAME));
                        strcat(dialog, list);

                        SetPlayerListitemValue(playerid, v, model);
                    }

                    Dialog
                    (
                        playerid, 5993, DIALOG_STYLE_LIST,
                        "{FF0000}Фильтр",
                        dialog,
                        "Далее", "Назад"
                    );

                    SetPVarInt(playerid, "filter_select_veh", 1);

                    return 1;
                }
                else
                {
                    switch(listitem)
                    {
                        case 0:
                        {
                            Dialog
                            (
                                playerid, 5993, DIALOG_STYLE_LIST,
                                "{FF0000}Фильтр",
                                "1. Низкий класс\n"\
                                "1. Средний класс\n"\
                                "1. Высокий класс",
                                "Далее", "Назад"
                            );
                            
                            player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE;

                            return 1;
                        }
                        case 1:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_HOUSE;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 2:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_BUSINESS;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 3:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE_NUMBER;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 4:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_SUM_NUMBER;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 5:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_CLOTHES;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                    }
                }
            }    
            else
            {       
                switch(listitem)
                {
                    case 0:
                    {
                        Dialog
                        (
                            playerid, 5993, DIALOG_STYLE_LIST,
                            "{FF0000}Фильтр",
                            "1. Автомобиль\n"\
                            "2. Недвижимость\n"\
                            "3. Бизнес\n"\
                            "4. Номерной знак\n"\
                            "5. Сим-карта\n"\
                            "6. Одежда\n"\
                            "7. Аксессуар",
                            "Далее", "Назад"
                        );

                        player_info_panel[playerid][filter_type] = 1;
                        return 1;
                    }
                    case 1:
                    {   
                        Dialog
                        (
                            playerid, 5993, DIALOG_STYLE_INPUT,
                            "{FF0000}Фильтр",
                            "Введите цену от и до через запятую (1000, 500000000)",
                            "Далее", "Назад"
                        );

                        player_info_panel[playerid][filter_type] = 2;
                        return 1;
                    }
                }
            }
        }
        else 
        {
            player_info_panel[playerid][filter_type] = 0;
            player_info_panel[playerid][filter_tovar_type] = 0;
        }
    }
    #if defined auc_OnDialogResponse
        return auc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse auc_OnDialogResponse
#if defined auc_OnDialogResponse
forward auc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public:PlayerTextDrawAuction(playerid)
{
    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 27.3333, 100.2444, "txd:braucbuy"); // фон / основа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 588.0000, 294.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][0], 0);

    auction_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 490.6665, 211.9851, "-"); // имя владельца слота
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][1], 0.2480, 1.3330);//0.3133, 1.2888
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][1], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][1], 0);

    auction_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 490.6665, 236.4593, "-"); // тип слота
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][2], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][2], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][2], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][2], 0);

    auction_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 490.6665, 261.7631, "-"); // стартовая
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][3], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][3], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][3], 0);

    auction_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 490.6665, 286.6520, "-"); // текущяя цена
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][4], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][4], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][4], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][4], 0);

    auction_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 490.6665, 311.5410, "-"); // время
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][5], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][5], -20.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][5], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][5], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][5], 0);

    auction_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 174.6666, 293.9630, "txd:braucnulist"); // 4
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][6], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][6], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][6], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][6], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][6], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][6], 1);

    auction_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 193.3333, 316.5185, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][7], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][7], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][7], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][7], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][7], 0);

    auction_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 303.6669, 317.3482, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][8], 0.2350, 1.4262);//0.3026, 1.2971
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][8], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][8], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][8], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][8], 0);

    auction_PTD[playerid][9] = CreatePlayerTextDraw(playerid, 381.3334, 326.8889, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][9], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][9], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][9], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][9], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][9], 0);

    auction_PTD[playerid][10] = CreatePlayerTextDraw(playerid, 174.6666, 144.6296, "txd:braucnulist"); // 1
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][10], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][10], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][10], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][10], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][10], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][10], 1);

    auction_PTD[playerid][11] = CreatePlayerTextDraw(playerid, 193.3333, 167.1852, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][11], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][11], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][11], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][11], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][11], 0);

    auction_PTD[playerid][12] = CreatePlayerTextDraw(playerid, 303.6669, 168.0148, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][12], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][12], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][12], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][12], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][12], 0);

    auction_PTD[playerid][13] = CreatePlayerTextDraw(playerid, 381.3334, 177.5556, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][13], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][13], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][13], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][13], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][13], 0);

    auction_PTD[playerid][14] = CreatePlayerTextDraw(playerid, 174.6666, 195.2370, "txd:braucnulist"); // 2
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][14], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][14], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][14], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][14], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][14], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][14], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][14], 1);

    auction_PTD[playerid][15] = CreatePlayerTextDraw(playerid, 193.3333, 217.7926, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][15], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][15], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][15], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][15], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][15], 0);

    auction_PTD[playerid][16] = CreatePlayerTextDraw(playerid, 303.6669, 218.6222, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][16], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][16], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][16], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][16], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][16], 0);

    auction_PTD[playerid][17] = CreatePlayerTextDraw(playerid, 381.3334, 228.1630, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][17], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][17], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][17], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][17], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][17], 0);

    auction_PTD[playerid][18] = CreatePlayerTextDraw(playerid, 174.6666, 244.6000, "txd:braucnulist"); // 3
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][18], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][18], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][18], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][18], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][18], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][18], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][18], 1);

    auction_PTD[playerid][19] = CreatePlayerTextDraw(playerid, 193.3333, 267.1556, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][19], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][19], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][19], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][19], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][19], 0);

    auction_PTD[playerid][20] = CreatePlayerTextDraw(playerid, 303.6669, 267.9852, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][20], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][20], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][20], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][20], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][20], 0);

    auction_PTD[playerid][21] = CreatePlayerTextDraw(playerid, 381.3334, 277.5260, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][21], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][21], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][21], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][21], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][21], 0);

    auction_PTD[playerid][22] = CreatePlayerTextDraw(playerid, 492.3333, 132.6000, "txd:brauchome"); // иконка слота
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][22], 103.0000, 65.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][22], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][22], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][22], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][22], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][22], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid, 43.3333, 125.1333, "txd:braucubuy"); // вклада покупки
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][23], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid, 43.3333, 170.3481, "txd:braucnusell"); // вкладка продажа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][24], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid, 43.6666, 216.8074, "txd:braucnumy"); // вкладка мои
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][25], 109.0000, 61.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid, 43.3333, 285.6667, "txd:braucexit"); // выйти
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][26], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][26], 1);

    auction_PTD[playerid][27] = CreatePlayerTextDraw(playerid, 94.3333, 368.3703, "1"); // страница
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][27], 0.3563, 1.6207);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][27], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][27], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][27], 0);

    auction_PTD[playerid][28] = CreatePlayerTextDraw(playerid, 172.0000, 289.4001, "txd:braucnucost"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][28], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][28], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][28], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][28], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][28], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][28], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][28], 1);

    auction_PTD[playerid][29] = CreatePlayerTextDraw(playerid,171.3333, 154.5852, "txd:braucnutip"); // тип товара
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][29], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][29], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][29], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][29], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][29], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][29], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][29], 1);

    auction_PTD[playerid][30] = CreatePlayerTextDraw(playerid,172.0000, 200.2147, "txd:braucnutovar"); // товар
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][30], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][30], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][30], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][30], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][30], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][30], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][30], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][30], 1);

    auction_PTD[playerid][31] = CreatePlayerTextDraw(playerid,172.6666, 244.1851, "txd:braucnuopisanie"); // описание
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][31], 302.0000, 63.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][31], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][31], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][31], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][31], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][31], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][31], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][31], 1);

    auction_PTD[playerid][32] = CreatePlayerTextDraw(playerid,491.9997, 310.7110, "0_RUB"); // продвижение
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][32], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][32], 496.9997, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][32], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][32], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][32], 0);

    auction_PTD[playerid][33] = CreatePlayerTextDraw(playerid, 240.3332, 132.1851, "txd:braucsale"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][33], 158.0000, 197.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][33], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][33], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][33], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][33], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][33], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][33], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][33], 1);

    auction_PTD[playerid][34] = CreatePlayerTextDraw(playerid, 393.3332, 146.2888, "txd:braucpurchase"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][34], 143.0000, 175.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][34], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][34], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][34], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][34], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][34], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][34], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][34], 1);

    auction_PTD[playerid][35] = CreatePlayerTextDraw(playerid, 140.0001, 362.5701, "txd:braucright"); //следующий список
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][35], 24.0000, 27.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][35], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][35], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][35], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][35], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][35], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][35], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][35], 1);

    auction_PTD[playerid][36] = CreatePlayerTextDraw(playerid, 39.3333, 362.9849, "txd:braucleft"); // прошлый список
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][36], 23.0000, 27.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][36], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][36], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][36], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][36], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][36], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][36], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][36], 1);

    auction_PTD[playerid][37] = CreatePlayerTextDraw(playerid, 482.3333, 319.6813, "txd:braucbet"); // сделать ставку
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][37], 122.0000, 57.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][37], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][37], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][37], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][37], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][37], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][37], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][37], 1);

    auction_PTD[playerid][38] = CreatePlayerTextDraw(playerid, 439.0000, 115.1778, "txd:braucfilter"); // фильтер
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][38], 24.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][38], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][38], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][38], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][38], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][38], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][38], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][38], 1);

    auction_PTD[playerid][39] = CreatePlayerTextDraw(playerid, 482.3333, 319.6813, "txd:braucexpose"); // выставить
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][39], 122.0000, 57.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][39], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][39], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][39], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][39], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][39], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][39], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][39], 1);
}

public OnGameModeInit()
{
    for(new i;i < MAX_BUSINESS; i ++)
    {
        if(GetBusinessData(i, B_NAME)) continue;

        SetTimer("SetBusinessName", 1500, false);

        break;
    }

    CreateDynamic3DTextLabel("Введите команду {FF0000}/auction{FFFFFF}\nЧтобы использовать аукцион", -1, 1000.000915,2508.325927,1497.994628, 5.0);
    enter_auction = CreateDynamicSphere(2092.610351,-2283.928955,23.096267, 1.0, 0, 0);
    exit_auction = CreateDynamicSphere(999.965148,2488.335205,1499.304687, 0.7, AUCTION_WORLD, 1);
    CreateDynamicPickup(19134, 23, 2092.610351,-2283.928955,23.096267, 0, 0);
    auction_exit_pickup = CreatePickup(19134, 23, 1000.037353,2488.334960,1499.344726, AUCTION_WORLD);
    Create3DTextLabel("{FFFF00}Вход в аукцион\n{FFFFFF}Подойдите ближе чтобы войти", -1, 2092.610351,-2283.928955,23.096267, 10.0, 0);
    
    CreateDynamic3DTextLabel("{FFFF00}\xc2\xfb\xf5\xee\xe4 \xe8\xe7 \xe0\xf3\xea\xf6\xe8\xee\xed\xe0\n{FFFFFF}\xcf\xee\xe4\xee\xe9\xe4\xe8\xf2\xe5 \xea \xef\xe8\xea\xe0\xef\xf3 \xe8 \xe2\xee\xe9\xe4\xe8\xf2\xe5", -1, 999.965148,2488.335205,1500.304687, 8.0, AUCTION_WORLD, 1);


    // Technical Center entrance from the supplied screenshot coordinates.
    CreateDynamic3DTextLabel("{00CCFF}\xd2\xe5\xf5\xed\xe8\xf7\xe5\xf1\xea\xe8\xe9 \xd6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, -426.255401,1006.047912,12.422812 + 0.9, 8.0);

    // Three Styling Center horn entrances.
    CreateDynamic3DTextLabel("{00CCFF}\xd1\xf2\xe0\xe9\xeb\xe8\xed\xe3 \xd6\xe5\xed\xf2\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 2311.239257,-2607.611816,21.829063, 8.0);
    CreateDynamic3DTextLabel("{00CCFF}\xd1\xf2\xe0\xe9\xeb\xe8\xed\xe3 \xd6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 2311.243408,-2613.474365,21.829063, 8.0);
    CreateDynamic3DTextLabel("{00CCFF}\xd1\xf2\xe0\xe9\xeb\xe8\xed\xe3 \xd6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 2311.249267,-2619.260253,21.829063, 8.0);

    // Three Tire Shop horn entrances.
    CreateDynamic3DTextLabel("{00CCFF}\xd8\xe8\xed\xee\xec\xee\xed\xf2\xe0\xe6\xed\xfb\xe9 \xf6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 1731.136718,2452.428955,14.979245, 8.0);
    CreateDynamic3DTextLabel("{00CCFF}\xd8\xe8\xed\xee\xec\xee\xed\xf2\xe0\xe6\xed\xfb\xe9 \xf6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 1729.999389,2457.254150,14.979245, 8.0);
    CreateDynamic3DTextLabel("{00CCFF}\xd8\xe8\xed\xee\xec\xee\xed\xf2\xe0\xe6\xed\xfb\xe9 \xf6\xe5\xed\xf2\xf0\n{FFFFFF}\xcd\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea, \xf7\xf2\xee\xe1\xfb \xe7\xe0\xe5\xf5\xe0\xf2\xfc", -1, 1729.081420,2461.694091,14.979245, 8.0);

    // STO-Tuning horn entrance.
    CreateDynamic3DTextLabel("{00CCFF}\xd1\xd2\xce-\xd2\xfe\xed\xe8\xed\xe3\n{FFFFFF}\xd7\xf2\xee\xe1\xfb \xe7\xe0\xe9\xf2\xe8, \xed\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea", -1, 2163.304199,-865.232116,27.984485, 8.0);
    CreateDynamic3DTextLabel("{00CCFF}\xd1\xd2\xce-\xd2\xfe\xed\xe8\xed\xe3\n{FFFFFF}\xd7\xf2\xf2\xee\xe1\xfb \xe7\xe0\xe9\xf2\xe8, \xed\xe0\xe6\xec\xe8\xf2\xe5 \xed\xe0 \xc3\xf3\xe4\xee\xea", -1, 2163.279052,-870.303955,27.982631, 8.0);
    defualt_slot();
    SetTimer("AuctionDatabaseInit", 8000, false);
    #if defined auc_OnGameModeInit
        return auc_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit auc_OnGameModeInit
#if defined auc_OnGameModeInit
    forward auc_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
    gAuctionNoticeShown[playerid] = false;
    SetTimerEx("PlayerTextDrawAuction", 6000, false, "i", playerid);
    #if defined auc_OnPlayerConnect
        return auc_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect auc_OnPlayerConnect
#if defined auc_OnPlayerConnect
    forward auc_OnPlayerConnect(playerid);
#endif

public OnPlayerSpawn(playerid)
{
    if(IsPlayerLogged(playerid) && !gAuctionNoticeShown[playerid])
    {
        gAuctionNoticeShown[playerid] = true;
        SetTimerEx("Auction_ShowPendingResult", 2500, false, "i", playerid);
    }

    #if defined auc_OnPlayerSpawn
        return auc_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn auc_OnPlayerSpawn
#if defined auc_OnPlayerSpawn
    forward auc_OnPlayerSpawn(playerid);
#endif

cmd:tpa(playerid){
    CallLocalFunction("OnPlayerEnterDynamicArea", "ii", playerid, enter_auction);
    return 1;
}


CMD:leaveauction(playerid)
{
    if(GetPlayerVirtualWorld(playerid) == AUCTION_WORLD)
    {
        SetPlayerPosEx(playerid, 2090.941650,-2283.999511,23.101566,92.530944, 0, 0);
        SendClientMessage(playerid, 0x66CC33FF, "\xc2\xfb \xe2\xfb\xf8\xeb\xe8 \xe8\xe7 \xe0\xf3\xea\xf6\xe8\xee\xed\xe0.");
    }
    return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == enter_auction)
    {
        SetPlayerPosEx(playerid, 999.987854,2489.679443,1499.304687,359.335876, 1, AUCTION_WORLD);
    }
    if(areaid == exit_auction)
    {
        SetPlayerPosEx(playerid, 2090.941650,-2283.999511,23.101566,92.530944, 0, 0);
    }
    #if defined auc_OnPlayerEnterDynamicArea
        return auc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea auc_OnPlayerEnterDynamicArea
#if defined auc_OnPlayerEnterDynamicArea
    forward auc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

stock default_select_slot(playerid)
{
    if(player_info_panel[playerid][select_slot] != 0)
    {
        new string[20];
        strcat(string, auction_button[0][0]);
        switch(player_info_panel[playerid][select_slot])
        {
            case 4:PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], string);
            case 1:PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], string);
            case 2:PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], string);
            case 3:PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], string);
        }
    }
    return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    printf("[TD] TextDraw:%d", _:auction_PTD[playerid][0]);
    if(playertextid == auction_PTD[playerid][6])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][3];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        format(string, 9, "%d_ч.",  ConvertUnixTime(auction_slot[slot][TIMER_END] - gettime(), CONVERT_TIME_TO_HOURS));

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);


        player_info_panel[playerid][select_slot] = 4;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 4 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][10])
    {
        default_select_slot(playerid);

        new slot = player_show_slot[playerid][0];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        format(string, 9, "%d_ч.",  ConvertUnixTime(auction_slot[slot][TIMER_END]- gettime(), CONVERT_TIME_TO_HOURS));

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);


        player_info_panel[playerid][select_slot] = 1;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 1 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][14])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][1];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        format(string, 9, "%d_ч.",  ConvertUnixTime(auction_slot[slot][TIMER_END]- gettime(), CONVERT_TIME_TO_HOURS));

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);

        player_info_panel[playerid][select_slot] = 2;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 2 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][18])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][2];
        if(slot == -1) return 1;
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        format(string, 9, "%d_ч.",  ConvertUnixTime(auction_slot[slot][TIMER_END] - gettime(), CONVERT_TIME_TO_HOURS));

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);

        player_info_panel[playerid][select_slot] = 3;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 3 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][23])
    {
        //SCM(playerid, -1, "ВКЛАДКА ПОКУПКА");      
        ShowTabBuy(playerid);
    }
    if(playertextid == auction_PTD[playerid][24])
    {
        //SCM(playerid, -1, "ВКЛАДКА ПРОДАЖА");   
        ShowTabSell(playerid);     
    }
    if(playertextid == auction_PTD[playerid][25])
    {
        //player_info_panel[playerid][select_tab] = 3;

        //SCM(playerid, -1, "ВКЛАДКА МОИ");  
        ShowTabMy(playerid);     
    }
    if(playertextid == auction_PTD[playerid][26])
    {
        HideTextDrawAuction(playerid);
        //SCM(playerid, -1, "ВЫЙТИ");
    }
    if(playertextid == auction_PTD[playerid][28])
    {
        if(!player_info_panel[playerid][opisanie_tovar]) return SCM(playerid, -1, " Сначало напишите описание");
        if(player_info_panel[playerid][price_tovar]) return 0;

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_INPUT,
            "{FF0000} Продажа",
            "Введите начальную цену за Ваш товар: (5 процентов коммиссия аукциона от итоговой суммы)",
            "Далее","Назад"
        );
        SetPVarInt(playerid, "select_param", 3);
        //SCM(playerid, -1, "ЦЕНА");
    }
    if(playertextid == auction_PTD[playerid][29])
    {
        player_info_panel[playerid][filter_vehicle_model] = 0;
        player_info_panel[playerid][filter_tovar_type] = 0;
        player_info_panel[playerid][filter_type] = 0;
        player_info_panel[playerid][type_tovar] = false;
        player_info_panel[playerid][price_tovar] = false;
        player_info_panel[playerid][tovar] = false;
        player_info_panel[playerid][opisanie_tovar] = false;

        //if(GetPVarInt(playerid, "type_param")) return 1;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][0]);

        for(new pon = 1; pon < 6;pon++)
        {
            PlayerTextDrawSetString(playerid, auction_PTD[playerid][pon], "-");
        }

        DeletePVar(playerid, "opisanie_param");
        DeletePVar(playerid, "tovar_param_num");
        if(GetPVarInt(playerid, "type_param"))DeletePVar(playerid, "type_param");
        if(GetPVarInt(playerid, "tovar_param_server"))DeletePVar(playerid, "tovar_param_server");
        if(GetPVarInt(playerid, "price_param"))DeletePVar(playerid, "price_param");
        if(GetPVarInt(playerid, "tovar_param"))DeletePVar(playerid, "tovar_param");
        if(GetPVarInt(playerid, "select_type"))DeletePVar(playerid, "select_type");

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_LIST,
            "{FF0000}Продажа",
            "1. Автомобиль\n"\
            "2. Недвижимость\n"\
            "3. Бизнес\n"\
            "4. Номерной знак\n"\
            "5. Сим-карта\n"\
            "6. Одежда\n"\
            "7. Аксессуар",
            "Далее", "Назад"
        );

        SetPVarInt(playerid, "select_param", 1);
        //SCM(playerid, -1, "ТИП");
    }
    if(playertextid == auction_PTD[playerid][30])
    {
        if(!player_info_panel[playerid][type_tovar]) return SCM(playerid, -1, "Сначало выберите тип товара");
        if(player_info_panel[playerid][tovar]) return 0;

        new text[284];

        switch(GetPVarInt(playerid, "type_param"))
        {
            case TYPE_VEHICLE:
            {
                if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
                {
                    new vehicle = GetPlayerOwnableCar(playerid);
                    new model = GetVehicleModel(vehicle) - 400;
                    new action = GetVehicleData(vehicle, V_ACTION_ID);

                    SetPVarInt(playerid, "tovar_param", GetOwnableCarData(action, OC_SQL_ID));
                    SetPVarInt(playerid, "tovar_param_server", vehicle);

                    format(text, sizeof text, "Вы хотите выставить на аукцион транспорт %s [%d]?", GetVehicleInfo(model, VI_NAME), GetOwnableCarData(action, OC_SQL_ID));

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else SendClientMessage(playerid, -1, ""USC" Ваш транспорт не загружен на сервер");
            }
            case TYPE_BUSINESS:
            {
                if(GetPlayerBusiness(playerid) != -1)
                {
                    new business = GetPlayerBusiness(playerid);
                    new sql = GetBusinessData(business, B_SQL_ID);

                    SetPVarInt(playerid, "tovar_param", sql);
                    SetPVarInt(playerid, "tovar_param_server", business);

                    format(text, sizeof text, "Вы хотите выставить на аукцион бизнес %s?", GetBusinessData(business, B_NAME), sql);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else SendClientMessage(playerid, -1, ""USC" У вас нет бизнеса");
            }
            case TYPE_HOUSE:
            {
                if(GetPlayerHouse(playerid) != -1)
                {
                    new house = GetPlayerHouse(playerid);
                    new sql = GetHouseData(house, H_SQL_ID);

                    SetPVarInt(playerid, "tovar_param", sql);
                    SetPVarInt(playerid, "tovar_param_server", house);

                    format(text, sizeof text, "Вы хотите выставить на аукцион Дом %d?", house);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else SendClientMessage(playerid, -1, ""USC" У вас нет недвижимости");
            }
            case TYPE_SUM_NUMBER, TYPE_VEHICLE_NUMBER, TYPE_CLOTHES, TYPE_ACCESSORY:
            {
                DeletePVar(playerid, "auction_inventory_confirmed");
                Auction_ShowInventoryItems(playerid, GetPVarInt(playerid, "type_param"));
            }
        }

        //SCM(playerid, -1, "ТОВАР");
    }
    if(playertextid == auction_PTD[playerid][31])
    {
        if(!player_info_panel[playerid][tovar]) return SCM(playerid, -1, "Сначало выберите товар");
        if(player_info_panel[playerid][opisanie_tovar]) return 0;

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_INPUT,
           "{FF0000}Продажа",
           "Введите описание к Вашему товару, чем лучше описание - тем быстрее Вы сможете продать Ваш товар",
           "Далее","Назад"
        );

        SetPVarInt(playerid, "select_param", 2);
        //SCM(playerid, -1, "ОПИСАНИЕ");
    }
    if(playertextid == auction_PTD[playerid][33])
    {
        new bool:have_sell, list[48], dialog[284];

        for(new c, account = GetPlayerAccountID(playerid);c < MAX_AUCTION_LIST;c++)
        {
            if(auction_slot[c][OWNER_SLOT_SQL] != account) continue;

            format(list, sizeof list, "%d. %s \t %d ч.\n", c + 1, auction_slot[c][SLOT_NAME], ConvertUnixTime(auction_slot[c][TIMER_END] - gettime(), CONVERT_TIME_TO_HOURS));
            strcat(dialog, list);
            have_sell = true;
        }

        if(!have_sell) return ShowNotification(playerid, 2, "У вас нет ставок на продажу", 3, "", "");

        Dialog
        (
            playerid, -1, DIALOG_STYLE_LIST,
            "{FF0000}Продажи",
            dialog, 
            "Выйти", ""
        );

        //SCM(playerid, -1, "МОИ ПРОДАЖИ");
    }
    if(playertextid == auction_PTD[playerid][34])
    {
        new bool:have_buy, list[48], dialog[284];
        for(new c, account = GetPlayerAccountID(playerid);c < MAX_AUCTION_LIST;c++)
        {
            if(auction_slot[c][OWNER_RATE] != account) continue;

            format(list, sizeof list, "%d. %s \t %d ч.\n", c + 1, auction_slot[c][SLOT_NAME], ConvertUnixTime(auction_slot[c][TIMER_END] - gettime(), CONVERT_TIME_TO_HOURS));
            strcat(dialog, list);
            have_buy = true;
        }

        if(!have_buy) return ShowNotification(playerid, 2, "У вас нет ставок на покупку", 3, "", ""); 

        Dialog
        (
            playerid, -1, DIALOG_STYLE_LIST,
            "{FF0000}Покупки",
            dialog, 
            "Выйти", ""
        );
        //SCM(playerid, -1, "МОИ ПОКУПКА");
    } 
    if(playertextid == auction_PTD[playerid][37])
    {
        new id_slot, dialog[254];

        switch(player_info_panel[playerid][select_slot])
        {
            case 1:id_slot = player_show_slot[playerid][0];
            case 2:id_slot = player_show_slot[playerid][1];
            case 3:id_slot = player_show_slot[playerid][2];
            case 4:id_slot = player_show_slot[playerid][3];
        }

        if(!auction_slot[id_slot][SLOT_TYPE]) return 0;

        if(auction_slot[id_slot][TIMER_END] <= gettime()) return SendClientMessage(playerid, -1, ""SC" Время вышло. Лот скоро удалиться.");

        if(GetPlayerMoneyEx(playerid) < auction_slot[id_slot][CURRENT_RATE])
        {
            format(dialog, sizeof dialog, "У вас %d, а нужно %d рублей", GetPlayerMoneyEx(playerid), auction_slot[id_slot][CURRENT_RATE]);
            ShowNotification(playerid, 2, dialog, 2, "", "");

            return 1;
        }
        else if(auction_slot[id_slot][OWNER_SLOT_SQL] == GetPlayerAccountID(playerid))
        {
            SendClientMessage(playerid, -1, ""SC" Вы не можете сделать ставку на свой лот.");
            return 1;
        }
        
        switch(auction_slot[id_slot][SLOT_TYPE])
        {
            case TYPE_BUSINESS:
            {
                new auction_businessid = auction_slot[id_slot][SERVER_ID];
                new bool:is_tcompany_lot = (auction_businessid >= 0 && auction_businessid < g_business_loaded && GetBusinessData(auction_businessid, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY);

                if(is_tcompany_lot)
                {
                    if(TCompany_GetOwnedBusiness(playerid) != -1)
                        return SendClientMessage(playerid, -1, ""SC" Вы уже являетесь владельцем транспортной компании.");

                    for(new i, account = GetPlayerAccountID(playerid); i < MAX_AUCTION_SLOT; i++)
                    {
                        if(i == id_slot || auction_slot[i][SLOT_TYPE] != TYPE_BUSINESS) continue;
                        if(auction_slot[i][OWNER_RATE] != account) continue;
                        new other_biz = auction_slot[i][SERVER_ID];
                        if(other_biz >= 0 && other_biz < g_business_loaded && GetBusinessData(other_biz, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY)
                            return SendClientMessage(playerid, -1, ""SC" Вы уже лидируете в торгах за другую транспортную компанию.");
                    }
                }
                else
                {
                    new max_business = 1 + GetPlayerData(playerid, P_BUSS_SLOTS);
                    if(max_business > 2) max_business = 2;
                    if(GetPlayerBusinessCount(playerid) >= max_business)
                        return SendClientMessage(playerid, -1, ""SC" У Вас нет свободного слота для нового бизнеса.");

                    for(new i, account = GetPlayerAccountID(playerid); i < MAX_AUCTION_SLOT; i++)
                    {
                        if(i == id_slot || auction_slot[i][SLOT_TYPE] != TYPE_BUSINESS) continue;
                        if(auction_slot[i][OWNER_RATE] != account) continue;
                        new other_biz = auction_slot[i][SERVER_ID];
                        if(other_biz >= 0 && other_biz < g_business_loaded && GetBusinessData(other_biz, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY) continue;
                        return SendClientMessage(playerid, -1, ""SC" Вы уже лидируете в торгах за другой бизнес.");
                    }
                }
            }
            case TYPE_HOUSE:
            {
                if(GetPlayerHouse(playerid) != -1)
                    return SendClientMessage(playerid, -1, ""SC" У Вас уже имеется недвижимость.");

                for(new i, account = GetPlayerAccountID(playerid); i < MAX_AUCTION_SLOT; i++)
                {
                    if(i == id_slot || auction_slot[i][SLOT_TYPE] != TYPE_HOUSE) continue;
                    if(auction_slot[i][OWNER_RATE] != account) continue;
                    return SendClientMessage(playerid, -1, ""SC" Вы уже лидируете в торгах за другую недвижимость.");
                }
            }
        }

        new percent = auction_slot[id_slot][CURRENT_RATE] * 98 / 100;
        new da = auction_slot[id_slot][CURRENT_RATE]  - percent;
        new price = da  + auction_slot[id_slot][CURRENT_RATE];

        format(dialog, sizeof dialog,
        "Описание от {FFFF00}продавца: {FFFFFF}%s\n\n"\
        "{FFFFFF}%s: {FFFF00}%s\n\n"\
        "{FFFFFF}Введите сумму которую хотите отдать за данный лот. Минимальная ставка: {FFFF00}%d рублей",
        auction_slot[id_slot][OPISANIE_SLOT], type_slot[auction_slot[id_slot][SLOT_TYPE]], auction_slot[id_slot][SLOT_NAME], 
        price
        );

        Dialog
        (
            playerid, 5990, DIALOG_STYLE_INPUT,
            "{FF0000}Ставка",
            dialog,
            "Далее", "Назад"
        );


        SetPVarInt(playerid, "select_slot", id_slot);

        //SCM(playerid, -1, "ПОСТАВИТЬ");
    }
    if(playertextid == auction_PTD[playerid][38]) 
    {
        Dialog
        (
            playerid, 5993, DIALOG_STYLE_LIST,
            "{FF0000}Фильтр",
            "1. Выбрать тип покупки\n"\
            "2. Выбрать цену покупки",
            "Далее", "Назад"
        );

        player_info_panel[playerid][filter_type] = 0;
        player_info_panel[playerid][filter_tovar_type] = 0;
        player_info_panel[playerid][count_list] = 1;
        LeafAuction(playerid, 3);
    }
    if(playertextid == auction_PTD[playerid][39]) 
    {
        if(!player_info_panel[playerid][price_tovar]) return SendClientMessage(playerid, -1, ""USC" Сначало выберите все");
               
        new type, opisanie[124], start, data_base, server_id, number_veh[7], number_phone;

        type = GetPVarInt(playerid, "type_param");
        
        if(type == TYPE_SUM_NUMBER) number_phone = GetPVarInt(playerid, "tovar_param");

        GetPVarString(playerid, "opisanie_param", opisanie, 124);
        GetPVarString(playerid, "tovar_param_num", number_veh, 7);

        data_base = GetPVarInt(playerid, "tovar_param");
        server_id = GetPVarInt(playerid, "tovar_param_server");
        if(type == TYPE_VEHICLE)
        {
            if(GetPlayerOwnableCar(playerid) != GetPVarInt(playerid, "tovar_param_server"))
                return SendClientMessage(playerid,-1, ""USC" Ваш транспорт выгружен");

            server_id = GetVehicleModel(GetPVarInt(playerid, "tovar_param_server"));
        } 
        
        start = GetPVarInt(playerid, "price_param");
        

        create_auction_slot(playerid, type, opisanie, start, data_base, server_id, number_veh, number_phone);
    }
    if(playertextid == auction_PTD[playerid][35])
    {
        if(player_info_panel[playerid][count_list] == 256) return 1;

        player_info_panel[playerid][count_list]++;

        new all_slot = player_info_panel[playerid][count_list]*4 - 1;

        LeafAuction(playerid, all_slot);
        //UpdateListSlot(playerid, player_info_panel[playerid][count_list]);
        //SCM(playerid, -1, "СЛЕДУЮЩИЙ СПИСОК");
    }
    if(playertextid == auction_PTD[playerid][36])
    {
        if(player_info_panel[playerid][count_list] == 1) return 1;

        player_info_panel[playerid][count_list]--;

        new all_slot = player_info_panel[playerid][count_list]*4 - 1;
        
        LeafAuction(playerid, all_slot);
        //UpdateListSlot(playerid, player_info_panel[playerid][count_list]);
        //SCM(playerid, -1, "ПРЕДЫДУЩИЙ СПИСОК");
    }
	#if defined auc_OnPlayerClickPlayer
		return auc_OnPlayerClickPlayer(playerid, playertextid);
	#else
	    return 0;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTextD
    #undef OnPlayerClickPlayerTextDraw
#else
    #define _ALS_OnPlayerClickPlayerTextD
#endif
#if defined auc_OnPlayerClickPlayer
	forward auc_OnPlayerClickPlayer(playerid, PlayerText:playertextid);
#endif
#define	OnPlayerClickPlayerTextDraw auc_OnPlayerClickPlayer


CMD:auction(playerid)
{
    new hour;

    gettime(hour);

   if(!(8 <= hour <= 21)) return SendClientMessage(playerid, -1, ""USC"Аукцион работает с 8:00 до 22:00");

    if(GetPlayerVirtualWorld(playerid) != AUCTION_WORLD)
    {
        EnablePlayerGPS(playerid, 55, 2090.941650,-2283.999511,23.101566, "Местоположение аукциона отмечено на карте.");
        return 1;
    }

    HideTextDrawAuction(playerid);

    if(player_cd_auction[playerid] < gettime()) HideHud(playerid);
    SetPlayerCleanChat(playerid, 1);
    SetPlayerCleanChat(playerid, 0);

    ShowTabBuy(playerid);

    return 1;
}

stock HideTextDrawAuction(playerid)
{
    ShowHud(playerid);
    SetPlayerCleanChat(playerid, 0);

    default_select_slot(playerid);
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 2:HideTabSell(playerid);
        case 3:HideTabMy(playerid);
    }

    player_info_panel[playerid][count_list] = 1;
    player_info_panel[playerid][show_panel] = false;
    player_info_panel[playerid][select_slot] = 0;
    player_info_panel[playerid][select_type] = 0;
    player_info_panel[playerid][select_tab] = 0;
    player_info_panel[playerid][filter_min_price] = -1;
    player_info_panel[playerid][filter_max_price] = -1;
    player_info_panel[playerid][filter_vehicle_model] = 0;
    player_info_panel[playerid][filter_tovar_type] = 0;
    player_info_panel[playerid][filter_type] = 0;
    player_info_panel[playerid][type_tovar] = false;
    player_info_panel[playerid][price_tovar] = false;
    player_info_panel[playerid][tovar] = false;
    player_info_panel[playerid][opisanie_tovar] = false;

    TogglePlayerControllable(playerid, true);

    return 1;
}

stock ShowTabBuy(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 2:HideTabSell(playerid);
        case 3:HideTabMy(playerid);
        case 1:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 1;

        //load slot auction

    if(player_info_panel[playerid][select_slot])
    {
        new string[34];
        strcat(string, auction_button[0][0]);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], string);

        player_info_panel[playerid][select_slot] = 0;
    }

    for(new p = 1;p < 6;p++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][p], "-");
    
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][27], "1");
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][0], "txd:braucbuy");

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][23], auction_button[1][1]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][24], auction_button[2][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][25], auction_button[3][0]);

    //PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);
    new all_slot = player_info_panel[playerid][count_list]*4 - 1;
    LeafAuction(playerid, all_slot);

    for(new t; t < 39; t++)
    {
        if(28 <= t <= 34) continue;

        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    return 1;
}

stock ShowTabSell(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 3:HideTabMy(playerid);
        default:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 2;
    
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][0], "txd:braucsell");

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][23], auction_button[1][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][24], auction_button[2][1]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][25], auction_button[3][0]);


    //PlayerTextDrawSetString(playerid, auction_TD[5]);
    
    for(new p = 1;p < 5;p++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][p], "-");
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], "Нет");
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][32], "Нет");

    //PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);

    for(new t; t < 5; t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }
    for(new t = 28; t < 33; t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][22]);

    for(new b = 23;b < 27;b++) // цикл для открытия вкладок
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][b]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][39]);

    return 1;
}

stock HideTabSell(playerid)
{
    CancelSelectTextDraw(playerid);
    player_info_panel[playerid][type_tovar] = false;
    player_info_panel[playerid][price_tovar] = false;
    player_info_panel[playerid][tovar] = false;
    player_info_panel[playerid][opisanie_tovar] = false;

    PlayerTextDrawHide(playerid, auction_PTD[playerid][39]);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1107374134);

    for(new t; t < 6; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawHide(playerid, auction_PTD[playerid][22]);

    for(new t = 28; t < 33; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    for(new b = 23;b < 27;b++) // цикл для открытия вкладок
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][b]);
    }
    return 1;
}

stock HideTabBuy(playerid)
{
    default_select_slot(playerid);
    CancelSelectTextDraw(playerid);
    player_info_panel[playerid][count_list] = 1;
    player_info_panel[playerid][show_panel] = false;
    player_info_panel[playerid][select_slot] = 0;
    player_info_panel[playerid][select_type] = 0;
    player_info_panel[playerid][select_tab] = 0;
    player_info_panel[playerid][filter_min_price] = -1;
    player_info_panel[playerid][filter_max_price] = -1;

    for(new t = 35; t < 39; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    for(new t; t < 28; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }
    return 1;
}

stock HideTabMy(playerid)
{
    CancelSelectTextDraw(playerid);

    PlayerTextDrawDestroy(playerid, auction_PTD[playerid][0]);
    for(new i = 23;i < 27;i++) PlayerTextDrawDestroy(playerid, auction_PTD[playerid][i]);
    
    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 27.3333, 100.2444, "txd:braucbuy"); // фон / основа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 588.0000, 294.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][0], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid, 43.3333, 125.1333, "txd:braucubuy"); // вклада покупки
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][23], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid, 43.3333, 170.3481, "txd:braucnusell"); // вкладка продажа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][24], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid, 43.6666, 216.8074, "txd:braucnumy"); // вкладка мои
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][25], 109.0000, 61.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid, 43.3333, 285.6667, "txd:braucexit"); // выйти
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][26], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][26], 1);

    PlayerTextDrawHide(playerid, auction_PTD[playerid][0]);

    for(new t = 23; t < 27;t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }
    
    PlayerTextDrawHide(playerid, auction_PTD[playerid][33]);
    PlayerTextDrawHide(playerid, auction_PTD[playerid][34]);

    return 1;
}

stock ShowTabMy(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 2:HideTabSell(playerid);
        default:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 3;

    PlayerTextDrawDestroy(playerid, auction_PTD[playerid][0]);
    for(new i = 23;i < 27;i++) PlayerTextDrawDestroy(playerid, auction_PTD[playerid][i]);

    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 83.9999, 103.5629, "txd:braucmy"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 462.0000, 256.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][0], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid,97.3332, 115.5925, "txd:braucnubuy"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][23], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid,97.6666, 164.5406, "txd:braucnusell"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][24], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid,97.6666, 213.4888, "txd:braucumy"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][25], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid,97.6666, 272.3926, "txd:braucexit"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][26], 120.0000, 62.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][26], 1);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][26], 1);

    PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);

    for(new t = 23; t < 27;t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][33]);
    PlayerTextDrawShow(playerid, auction_PTD[playerid][34]);
    
    return 1;
}

forward AuctionDatabaseInit();
forward AuctionUpdate();
forward Auction_ShowPendingResult(playerid);

stock Auction_IsInventoryType(type)
{
    return type == TYPE_VEHICLE_NUMBER || type == TYPE_SUM_NUMBER || type == TYPE_CLOTHES || type == TYPE_ACCESSORY;
}

stock Auction_ItemMatchesType(type, item_id)
{
    switch(type)
    {
        case TYPE_VEHICLE_NUMBER: return Inventory11_IsPlateItem(item_id);
        case TYPE_SUM_NUMBER: return item_id == 58;
        case TYPE_CLOTHES: return item_id == 134;
        case TYPE_ACCESSORY: return Inventory11_IsAccessoryItem(item_id);
    }
    return 0;
}

stock Auction_FormatInventoryName(item_id, model_id, old_skin, sim_value, oldsim_value, extra_1, const meta[], name[], name_size)
{
    if(item_id == 134)
    {
        new skin_id = old_skin > 0 ? old_skin : model_id;
        format(name, name_size, "Скин #%d", skin_id);
        return 1;
    }
    if(item_id == 58)
    {
        new sim_number = oldsim_value;
        if(sim_number <= 0) sim_number = extra_1;
        if(sim_number <= 0) sim_number = model_id;
        if(sim_number <= 0) sim_number = sim_value;
        format(name, name_size, "SIM-карта %d", sim_number);
        return 1;
    }
    if(Inventory11_IsPlateItem(item_id))
    {
        new plate_type, plate[16], region[8], marker[2];
        if(!sscanf(meta, "p<|>s[2]is[16]s[8]", marker, plate_type, plate, region) && plate[0])
            format(name, name_size, "Госномер %s%s", plate, region);
        else
            format(name, name_size, "Государственный номер");
        return 1;
    }
    if(Inventory11_IsAccessoryItem(item_id))
    {
        Market_GetItemName(item_id, model_id, name, name_size);
        if(!name[0]) format(name, name_size, "Аксессуар #%d", item_id);
        return 1;
    }
    Market_GetItemName(item_id, model_id, name, name_size);
    return 1;
}

stock Auction_ShowInventoryItems(playerid, type)
{
    DeletePVar(playerid, "auction_inventory_confirmed");
    new dialog[4096], count, dialog_len;
    new max_slots = Inventory11_GetMaxSlots(playerid);
    if(max_slots < 1 || max_slots > INVENTORY11_MAX_SLOTS) max_slots = INVENTORY11_MAX_SLOTS;

    for(new slot = 1; slot <= max_slots; slot++)
    {
        new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
        if(!Market_ReadSlot(playerid, slot, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value)) continue;
        if(!Auction_ItemMatchesType(type, item_id)) continue;

        new meta[40], item_name[64];
        Market_GetSourcePlate(playerid, slot, meta, sizeof(meta));
        Auction_FormatInventoryName(item_id, model_id, old_skin, sim_value, oldsim_value, extra_1, meta, item_name, sizeof(item_name));

        // Compatibility with the old Pawn compiler: append directly.
        for(new c = 0; item_name[c] != 0 && dialog_len < sizeof(dialog) - 2; c++)
        {
            dialog[dialog_len++] = item_name[c];
        }
        if(dialog_len < sizeof(dialog) - 1)
        {
            dialog[dialog_len++] = '\n';
        }
        dialog[dialog_len] = 0;

        SetPlayerListitemValue(playerid, count, slot);
        count++;
    }

    if(!count)
        return SendClientMessage(playerid, -1, ""USC" В инвентаре нет подходящих предметов.");

    Dialog(playerid, 5992, DIALOG_STYLE_LIST, "{FF0000}Выбор предмета", dialog, "Выбрать", "Назад");
    return 1;
}

stock Auction_SelectInventorySource(playerid, type, source_slot, selected_name[], selected_name_size)
{
    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_slot, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value))
    {
        SendClientMessage(playerid, -1, ""USC" Предмет больше не найден в инвентаре.");
        return 0;
    }
    if(!Auction_ItemMatchesType(type, item_id))
    {
        SendClientMessage(playerid, -1, ""USC" Этот предмет нельзя выставить в выбранной категории.");
        return 0;
    }

    new meta[40];
    Market_GetSourcePlate(playerid, source_slot, meta, sizeof(meta));
    SetPVarInt(playerid, "tovar_param", source_slot);
    SetPVarInt(playerid, "tovar_param_server", model_id);
    SetPVarString(playerid, "auction_item_meta", meta);
    Auction_FormatInventoryName(item_id, model_id, old_skin, sim_value, oldsim_value, extra_1, meta, selected_name, selected_name_size);
    return 1;
}

stock Auction_GetSelectedInventoryName(playerid, name[], name_size)
{
    new source_slot = GetPVarInt(playerid, "tovar_param");
    new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
    if(!Market_ReadSlot(playerid, source_slot, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value))
    {
        format(name, name_size, "Предмет");
        return 0;
    }
    new meta[40];
    Market_GetSourcePlate(playerid, source_slot, meta, sizeof(meta));
    return Auction_FormatInventoryName(item_id, model_id, old_skin, sim_value, oldsim_value, extra_1, meta, name, name_size);
}

stock Auction_GetFreeSlot()
{
    for(new slot; slot < MAX_AUCTION_SLOT; slot++)
        if(!auction_slot[slot][SLOT_TYPE]) return slot;
    return -1;
}

stock Auction_IsBusinessListed(businessid)
{
    if(businessid < 0) return 0;
    for(new slot; slot < MAX_AUCTION_SLOT; slot++)
    {
        if(auction_slot[slot][SLOT_TYPE] != TYPE_BUSINESS) continue;
        if(auction_slot[slot][SERVER_ID] == businessid) return 1;
    }
    return 0;
}

stock Auction_RefundAccount(account_id, amount)
{
    if(account_id <= 0 || amount <= 0) return 0;
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != account_id) continue;
        GivePlayerMoneyEx(i, amount);
        SendClientMessage(i, -1, ""SC" Вашу ставку перебили. Деньги возвращены.");
        return 1;
    }
    new query[144];
    mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET money=money+%d WHERE id=%d LIMIT 1", amount, account_id);
    mysql_query(mysql, query, false);
    return !mysql_errno();
}

stock Auction_AddAccountMoney(account_id, amount)
{
    if(account_id <= 0 || amount <= 0) return 0;
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != account_id) continue;
        GivePlayerMoneyEx(i, amount);
        return 1;
    }
    new query[144];
    mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET money=money+%d WHERE id=%d LIMIT 1", amount, account_id);
    mysql_query(mysql, query, false);
    return !mysql_errno();
}

stock Auction_CreateNotification(account_id, lot_id, kind, const title[], object_id, amount)
{
    if(account_id <= 0 || !gAuctionDatabaseReady) return 0;
    new query[512];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO auction_notifications (account_id,lot_id,kind,title,object_id,amount,created_at,shown) VALUES (%d,%d,%d,'%e',%d,%d,%d,0)",
        account_id, lot_id, kind, title, object_id, amount, gettime());
    mysql_query(mysql, query, false);
    if(mysql_errno()) return 0;
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != account_id) continue;
        SetTimerEx("Auction_ShowPendingResult", 500, false, "i", i);
        break;
    }
    return 1;
}

public Auction_ShowPendingResult(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid) || !gAuctionDatabaseReady) return 0;
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query), "SELECT id,kind,title,object_id,amount FROM auction_notifications WHERE account_id=%d AND shown=0 ORDER BY id ASC LIMIT 1", account_id);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() || !cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    new notice_id = cache_get_field_content_int(0, "id");
    new kind = cache_get_field_content_int(0, "kind");
    new object_id = cache_get_field_content_int(0, "object_id");
    new amount = cache_get_field_content_int(0, "amount");
    new title[64], body[640], dialog_title[64];
    cache_get_field_content(0, "title", title, mysql, sizeof(title));
    cache_delete(result);

    switch(kind)
    {
        case 1:
        {
            format(dialog_title, sizeof(dialog_title), "Победа на аукционе");
            format(body, sizeof(body),
                "Поздравляем! Вы выиграли бизнес #%d \"%s\" на аукционе.\n\nБизнес уже закреплён за Вашим аккаунтом.\nУправление: /business\n\nНе забудьте своевременно продлевать аренду в банке.\nБез оплаты бизнес будет изъят государством.",
                object_id, title);
        }
        case 6:
        {
            format(dialog_title, sizeof(dialog_title), "Победа на аукционе");
            format(body, sizeof(body),
                "Поздравляем! Вы выиграли транспортную компанию \"%s\" на аукционе.\n\nУправление компанией: /tcompany\nФуры для автопарка приобретаются в грузовом салоне.",
                title);
        }
        case 2:
        {
            format(dialog_title, sizeof(dialog_title), "Победа на аукционе");
            format(body, sizeof(body), "Поздравляем! Вы выиграли лот \"%s\".\n\nПредмет отправлен в /mpreward. Получите его после появления в игре.", title);
        }
        case 3:
        {
            format(dialog_title, sizeof(dialog_title), "Ставка перебита");
            format(body, sizeof(body), "Вашу ставку на лот \"%s\" перебили.\n\n%d рублей возвращены на Ваш счёт.", title, amount);
        }
        case 4:
        {
            format(dialog_title, sizeof(dialog_title), "Лот продан");
            format(body, sizeof(body), "Ваш лот \"%s\" продан.\n\nПосле комиссии аукциона Вам начислено %d рублей.", title, amount);
        }
        default:
        {
            format(dialog_title, sizeof(dialog_title), "Аукцион");
            format(body, sizeof(body), "Торги по лоту \"%s\" завершились без ставок.\n\nПредмет возвращён в /mpreward.", title);
        }
    }

    mysql_format(mysql, query, sizeof(query), "UPDATE auction_notifications SET shown=1 WHERE id=%d LIMIT 1", notice_id);
    mysql_query(mysql, query, false);
    Dialog(playerid, AUCTION_DIALOG_RESULT, DIALOG_STYLE_MSGBOX, dialog_title, body, "Понятно", "");
    return 1;
}

stock Auction_SaveLot(slot)
{
    if(!gAuctionDatabaseReady || slot < 0 || slot >= MAX_AUCTION_SLOT || auction_slot[slot][AUCTION_DB_ID] <= 0) return 0;
    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE auction_lots SET bidder_id=%d,current_price=%d,expires_at=%d WHERE id=%d AND status=0 LIMIT 1",
        auction_slot[slot][OWNER_RATE], auction_slot[slot][CURRENT_RATE], auction_slot[slot][TIMER_END], auction_slot[slot][AUCTION_DB_ID]);
    mysql_query(mysql, query, false);
    return !mysql_errno();
}

stock Auction_InsertLot(slot)
{
    new query[2048];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO auction_lots (slot_type,seller_id,seller_name,title,description,bidder_id,start_price,current_price,expires_at,database_id,server_id,number_vehicle,number_sum,item_id,item_model,item_amount,item_extra1,item_extra2,item_old_skin,item_sim,item_oldsim,item_meta,status) VALUES (%d,%d,'%e','%e','%e',%d,%d,%d,%d,%d,%d,'%e',%d,%d,%d,%d,%d,%d,%d,%d,%d,'%e',0)",
        auction_slot[slot][SLOT_TYPE], auction_slot[slot][OWNER_SLOT_SQL],
        auction_slot[slot][OWNER_SLOT_NAME], auction_slot[slot][SLOT_NAME], auction_slot[slot][OPISANIE_SLOT],
        auction_slot[slot][OWNER_RATE], auction_slot[slot][START_RATE], auction_slot[slot][CURRENT_RATE],
        auction_slot[slot][TIMER_END], auction_slot[slot][DATABASE_ID], auction_slot[slot][SERVER_ID],
        auction_slot[slot][NUMBER_VEHICLE], auction_slot[slot][NUMBER_SUM], auction_slot[slot][ITEM_ID],
        auction_slot[slot][ITEM_MODEL], auction_slot[slot][ITEM_AMOUNT], auction_slot[slot][ITEM_EXTRA_1],
        auction_slot[slot][ITEM_EXTRA_2], auction_slot[slot][ITEM_OLD_SKIN], auction_slot[slot][ITEM_SIM],
        auction_slot[slot][ITEM_OLD_SIM], auction_slot[slot][ITEM_META]);
    new Cache:result = mysql_query(mysql, query, true);
    new lot_id = cache_insert_id();
    cache_delete(result);
    if(mysql_errno() || lot_id <= 0) return 0;
    auction_slot[slot][AUCTION_DB_ID] = lot_id;
    return lot_id;
}

stock Auction_QueueInventory(account_id, slot)
{
    if(account_id <= 0 || auction_slot[slot][ITEM_ID] <= 0) return 0;
    new item_id = auction_slot[slot][ITEM_ID];
    new item_count = auction_slot[slot][ITEM_AMOUNT];
    new meta[40];
    format(meta, sizeof(meta), "%s", auction_slot[slot][ITEM_META]);

    if(item_id == 134)
    {
        item_count = auction_slot[slot][ITEM_OLD_SKIN];
        if(item_count <= 0) item_count = auction_slot[slot][ITEM_MODEL];
    }
    else if(item_id == 58)
    {
        item_count = auction_slot[slot][ITEM_OLD_SIM];
        if(item_count <= 0) item_count = auction_slot[slot][ITEM_EXTRA_1];
        if(item_count <= 0) item_count = auction_slot[slot][ITEM_MODEL];
        if(item_count <= 0) item_count = auction_slot[slot][ITEM_SIM];
        if(!meta[0] && item_count > 0) format(meta, sizeof(meta), "%d", item_count);
    }
    else if(Inventory11_IsAccessoryItem(item_id) || Inventory11_IsPlateItem(item_id))
        item_count = 1;

    if(item_count <= 0) item_count = 1;
    return MPReward_QueueInvItem(account_id, item_id, item_count, meta, auction_slot[slot][SLOT_NAME], auction_slot[slot][AUCTION_DB_ID]);
}

stock Auction_ClearSlot(slot)
{
    auction_slot[slot][SLOT_TYPE] = 0;
    auction_slot[slot][OWNER_SLOT_SQL] = -1;
    format(auction_slot[slot][OWNER_SLOT_NAME], 24, "-");
    format(auction_slot[slot][SLOT_NAME], 32, "-");
    format(auction_slot[slot][OPISANIE_SLOT], 124, "-");
    format(auction_slot[slot][NUMBER_VEHICLE], 16, "-");
    auction_slot[slot][OWNER_RATE] = -1;
    auction_slot[slot][START_RATE] = 0;
    auction_slot[slot][CURRENT_RATE] = 0;
    auction_slot[slot][TIMER_END] = 0;
    auction_slot[slot][DATABASE_ID] = -1;
    auction_slot[slot][SERVER_ID] = -1;
    auction_slot[slot][NUMBER_SUM] = 0;
    auction_slot[slot][AUCTION_DB_ID] = 0;
    auction_slot[slot][ITEM_ID] = 0;
    auction_slot[slot][ITEM_MODEL] = 0;
    auction_slot[slot][ITEM_AMOUNT] = 0;
    auction_slot[slot][ITEM_EXTRA_1] = 0;
    auction_slot[slot][ITEM_EXTRA_2] = 0;
    auction_slot[slot][ITEM_OLD_SKIN] = 0;
    auction_slot[slot][ITEM_SIM] = 0;
    auction_slot[slot][ITEM_OLD_SIM] = 0;
    auction_slot[slot][ITEM_META][0] = EOS;
    return 1;
}

stock reset_slot_auction(slot, status = 1)
{
    if(slot < 0 || slot >= MAX_AUCTION_SLOT) return 0;
    if(gAuctionDatabaseReady && auction_slot[slot][AUCTION_DB_ID] > 0)
    {
        new query[160];
        mysql_format(mysql, query, sizeof(query), "UPDATE auction_lots SET status=%d WHERE id=%d LIMIT 1", status, auction_slot[slot][AUCTION_DB_ID]);
        mysql_query(mysql, query, false);
    }
    return Auction_ClearSlot(slot);
}

stock Auction_AddBusinessIncomeById(businessid, amount)
{
    if(businessid < 0 || businessid >= g_business_loaded || amount <= 0) return 0;
    if(GetBusinessData(businessid, B_OWNER_ID) <= 0) return 0;
    new profit = (amount * 75) / 100;
    if(profit <= 0) profit = 1;
    SetBusinessData(businessid, B_BALANCE, GetBusinessData(businessid, B_BALANCE) + profit);
    new query[160];
    mysql_format(mysql, query, sizeof(query), "UPDATE business SET balance=%d WHERE id=%d LIMIT 1", GetBusinessData(businessid, B_BALANCE), GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);
    return 1;
}

stock Auction_AddServiceIncome(playerid, amount)
{
    new businessid = -1;
    switch(g_player[playerid][P_LAST_TUNING])
    {
        case 0: businessid = gAuctionServiceBiz[8];
        case 1: businessid = gAuctionServiceBiz[7];
        case 2: businessid = gAuctionServiceBiz[1];
        case 3: businessid = gAuctionServiceBiz[0];
    }
    if(businessid == -1) return 0;
    return Auction_AddBusinessIncomeById(businessid, amount);
}

stock Auction_RegisterServiceBusiness(service_index, const business_name[], business_type, business_price, Float:x, Float:y, Float:z, Float:angle)
{
    new businessid = -1;
    for(new idx; idx < g_business_loaded; idx++)
    {
        // Coordinates are the authoritative key; do not move an unrelated same-name business.
        if(GetDistanceBetweenCoords(x, y, z, GetBusinessData(idx, B_POS_X), GetBusinessData(idx, B_POS_Y), GetBusinessData(idx, B_POS_Z)) <= 1.5)
        {
            businessid = idx;
            break;
        }
    }

    new query[640];
    if(businessid == -1)
    {
        if(g_business_loaded >= MAX_BUSINESS) return -1;
        businessid = g_business_loaded++;
        SetBusinessData(businessid, B_SQL_ID, 0);
        SetBusinessData(businessid, B_OWNER_ID, 0);
        SetBusinessData(businessid, B_ENTER_PRICE, 0);
        SetBusinessData(businessid, B_ENTER_MUSIC, 0);
        SetBusinessData(businessid, B_IMPROVEMENTS, 0);
        SetBusinessData(businessid, B_PRODS, 10000);
        SetBusinessData(businessid, B_PROD_PRICE, 0);
        SetBusinessData(businessid, B_BALANCE, 0);
        SetBusinessData(businessid, B_RENT_DATE, 0);
        SetBusinessData(businessid, B_LOCK_STATUS, false);
        SetBusinessData(businessid, B_ORDER_ID, -1);
        SetBusinessData(businessid, B_HEALTH_PICKUP, 0);
        SetBusinessData(businessid, B_EVICTION, 0);
        format(g_business[businessid][B_OWNER_NAME], 21, "None");

        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO business (owner_id,type,price,rent_price,x,y,z,interior,name,exit_x,exit_y,exit_z,exit_angle) VALUES (0,%d,%d,5000,'%f','%f','%f',0,'%e','%f','%f','%f','%f')",
            business_type, business_price, x, y, z, business_name, x, y, z, angle);
        new Cache:result = mysql_query(mysql, query, true);
        SetBusinessData(businessid, B_SQL_ID, cache_insert_id());
        cache_delete(result);
        if(GetBusinessData(businessid, B_SQL_ID) <= 0)
        {
            g_business_loaded--;
            return -1;
        }
        SetBusinessData(businessid, B_LABEL, Text3D:-1);
    }

    SetBusinessData(businessid, B_TYPE, business_type);
    SetBusinessData(businessid, B_PRICE, business_price);
    SetBusinessData(businessid, B_RENT_PRICE, 5000);
    SetBusinessData(businessid, B_INTERIOR, business_type == BUSINESS_TYPE_CAR_TUNING ? BUSINESS_INTERIOR_CAR_TUNING : 0);
    SetBusinessData(businessid, B_POS_X, x);
    SetBusinessData(businessid, B_POS_Y, y);
    SetBusinessData(businessid, B_POS_Z, z);
    SetBusinessData(businessid, B_EXIT_POS_X, x);
    SetBusinessData(businessid, B_EXIT_POS_Y, y);
    SetBusinessData(businessid, B_EXIT_POS_Z, z);
    SetBusinessData(businessid, B_EXIT_ANGLE, angle);
    format(g_business[businessid][B_NAME], 26, "%s", business_name);

    mysql_format(mysql, query, sizeof(query),
        "UPDATE business SET type=%d,price=%d,rent_price=5000,interior=%d,name='%e',x='%f',y='%f',z='%f',exit_x='%f',exit_y='%f',exit_z='%f',exit_angle='%f' WHERE id=%d LIMIT 1",
        business_type, business_price, business_type == BUSINESS_TYPE_CAR_TUNING ? BUSINESS_INTERIOR_CAR_TUNING : 0, business_name, x, y, z, x, y, z, angle, GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);

    // Moving a business requires recreating the label and pickup; changing
    // only the text left the old objects at their previous coordinates.
    if(IsValidDynamic3DTextLabel(Text3D:GetBusinessData(businessid, B_LABEL)))
        DestroyDynamic3DTextLabel(Text3D:GetBusinessData(businessid, B_LABEL));

    SetBusinessData(businessid, B_LABEL, CreateDynamic3DTextLabel(business_name, 0xFFFF00FF, x, y, z + 1.0, 8.0));

    // Keep the normal business pickup for every service business, including
    // the styling center, STO and tire shop.
    RecreateBusinessEnterPickup(businessid);

    gAuctionServiceBiz[service_index] = businessid;
    UpdateBusinessLabel(businessid);
    return businessid;
}

stock Auction_EnsureServiceBusinesses()
{
    Auction_RegisterServiceBusiness(0, "Технический центр", BUSINESS_TYPE_TECH_CENTER, 5000000, -432.036956, 1005.609924, 12.189999, 353.804565);
    Auction_RegisterServiceBusiness(1, "\xd8\xe8\xed\xee\xec\xee\xed\xf2\xe0\xe6\xed\xfb\xe9 \xf6\xe5\xed\xf2\xf0", BUSINESS_TYPE_TIRE_SHOP, 2500000, 1732.109619, 2448.038574, 14.979245, 286.483520);
    Auction_RegisterServiceBusiness(2, "Ларёк Южный", BUSINESS_TYPE_FOOD_STALL, 750000, -2402.414306, 194.326232, 26.070606, 0.0);
    Auction_RegisterServiceBusiness(3, "Ларёк Арзамас", BUSINESS_TYPE_FOOD_STALL, 750000, 2744.309326, -2429.061279, 21.821552, 0.0);
    Auction_RegisterServiceBusiness(4, "Ларёк Батырево", BUSINESS_TYPE_FOOD_STALL, 750000, 1801.018432, 2531.215087, 14.686512, 0.0);
    Auction_RegisterServiceBusiness(5, "Ларёк Лыткарино", BUSINESS_TYPE_FOOD_STALL, 750000, 846.679809, 803.254028, 13.400713, 0.0);
    // Accessory shop from the supplied coordinates. It uses the existing full accessory UI.
    Auction_RegisterServiceBusiness(6, "\xcc\xe0\xe3\xe0\xe7\xe8\xed \xe0\xea\xf1\xe5\xf1\xf1\xf3\xe0\xf0\xee\xe2", BUSINESS_TYPE_ACCESSORY_SHOP, 20000000, 216.539886, 860.654296, 13.420687, 133.007980);
    // STO (126) from the supplied coordinates.
    Auction_RegisterServiceBusiness(7, "\xd1\xd2\xce", BUSINESS_TYPE_CAR_TUNING, 5000000, 2163.264648, -875.586303, 27.947052, 265.048645);
    // Existing styling center from the database coordinates.
    Auction_RegisterServiceBusiness(8, "\xd1\xf2\xe0\xe9\xeb\xe8\xed\xe3 \xd6\xe5\xed\xf2\xf0", BUSINESS_TYPE_CAR_TUNING, 35000000, 2311.740000, -2601.810000, 21.829100, 0.0);

    // The BR BONUS armory shown in the supplied screenshot must also be a state auction lot.
    for(new idx; idx < g_business_loaded; idx++)
    {
        if(GetBusinessData(idx, B_TYPE) != BUSINESS_TYPE_SHOP_GUN) continue;
        if(strcmp(g_business[idx][B_OWNER_NAME], "BR BONUS", true) != 0) continue;

        // Do not steal a player-owned BR BONUS business on restart. Only reset
        // the special NPC/state business when it is already unowned.
        if(GetBusinessData(idx, B_OWNER_ID) > 0) continue;

        SetBusinessData(idx, B_OWNER_ID, 0);
        SetBusinessData(idx, B_BALANCE, 0);
        SetBusinessData(idx, B_PRODS, 0);
        format(g_business[idx][B_OWNER_NAME], 21, "None");

        new gun_query[256];
        mysql_format(mysql, gun_query, sizeof gun_query, "UPDATE business SET owner_id=0,balance=0,products=0,prod_price=0,lock=0 WHERE id=%d LIMIT 1", GetBusinessData(idx, B_SQL_ID));
        mysql_query(mysql, gun_query, false);
        UpdateBusinessLabel(idx);
    }
    return 1;
}


stock Auction_ForceServiceBusinessesToAuction()
{
    new added = 0;
    for(new service_index = 0; service_index < sizeof(gAuctionServiceBiz); service_index++)
    {
        new businessid = gAuctionServiceBiz[service_index];
        if(businessid < 0 || businessid >= g_business_loaded) continue;

        new sql_id = GetBusinessData(businessid, B_SQL_ID);
        if(sql_id <= 0) continue;

        new exists = 0;
        for(new slot = 0; slot < MAX_AUCTION_SLOT; slot++)
        {
            if(auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS && auction_slot[slot][DATABASE_ID] == sql_id)
            {
                exists = 1;
                break;
            }
        }
        if(exists) continue;

        // A service business can return to the state auction only when it is
        // actually unowned. Never strip a real player's ownership here.
        if(GetBusinessData(businessid, B_OWNER_ID) > 0) continue;

        new free_slot = Auction_GetFreeSlot();
        if(free_slot == -1) break;

        Auction_ClearSlot(free_slot);
        auction_slot[free_slot][SLOT_TYPE] = TYPE_BUSINESS;
        auction_slot[free_slot][OWNER_SLOT_SQL] = -2;
        auction_slot[free_slot][OWNER_RATE] = -1;
        auction_slot[free_slot][DATABASE_ID] = sql_id;
        auction_slot[free_slot][SERVER_ID] = businessid;
        auction_slot[free_slot][START_RATE] = GetBusinessData(businessid, B_PRICE);
        if(auction_slot[free_slot][START_RATE] < 5000)
            auction_slot[free_slot][START_RATE] = 5000;
        auction_slot[free_slot][CURRENT_RATE] = auction_slot[free_slot][START_RATE];
        auction_slot[free_slot][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
        format(auction_slot[free_slot][OWNER_SLOT_NAME], 24, "Государство");
        format(auction_slot[free_slot][SLOT_NAME], 32, "%s", GetBusinessData(businessid, B_NAME));
        format(auction_slot[free_slot][OPISANIE_SLOT], 124, "Государственный тюнинг/сервисный бизнес #%d", businessid);

        if(Auction_InsertLot(free_slot)) added++;
        else Auction_ClearSlot(free_slot);
    }
    printf("[AUCTION] Forced service/tuning businesses added: %d", added);
    return added;
}

public AuctionDatabaseInit()
{
    new query[3072];
    format(query, sizeof(query),
        "CREATE TABLE IF NOT EXISTS auction_lots (" \
        "id INT NOT NULL AUTO_INCREMENT,slot_type TINYINT NOT NULL,seller_id INT NOT NULL," \
        "seller_name VARCHAR(24) NOT NULL DEFAULT '',title VARCHAR(64) NOT NULL DEFAULT ''," \
        "description VARCHAR(124) NOT NULL DEFAULT '',bidder_id INT NOT NULL DEFAULT -1," \
        "start_price INT NOT NULL,current_price INT NOT NULL,expires_at INT NOT NULL," \
        "database_id INT NOT NULL DEFAULT -1,server_id INT NOT NULL DEFAULT -1," \
        "number_vehicle VARCHAR(16) NOT NULL DEFAULT '',number_sum INT NOT NULL DEFAULT 0," \
        "item_id INT NOT NULL DEFAULT 0,item_model INT NOT NULL DEFAULT 0,item_amount INT NOT NULL DEFAULT 0," \
        "item_extra1 INT NOT NULL DEFAULT 0,item_extra2 INT NOT NULL DEFAULT 0," \
        "item_old_skin INT NOT NULL DEFAULT 0,item_sim INT NOT NULL DEFAULT 0,item_oldsim INT NOT NULL DEFAULT 0," \
        "item_meta VARCHAR(40) NOT NULL DEFAULT '',status TINYINT NOT NULL DEFAULT 0," \
        "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(id)," \
        "KEY active_idx(status,expires_at),KEY seller_idx(seller_id,status)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_query(mysql, query, false);
    if(mysql_errno())
    {
        printf("[AUCTION] Failed to create auction_lots, errno=%d. Retry in 5 seconds", mysql_errno());
        SetTimer("AuctionDatabaseInit", 5000, false);
        return 0;
    }

    format(query, sizeof(query),
        "CREATE TABLE IF NOT EXISTS auction_notifications (id INT NOT NULL AUTO_INCREMENT,account_id INT NOT NULL,lot_id INT NOT NULL DEFAULT 0,kind TINYINT NOT NULL,title VARCHAR(64) NOT NULL DEFAULT '',object_id INT NOT NULL DEFAULT 0,amount INT NOT NULL DEFAULT 0,created_at INT NOT NULL DEFAULT 0,shown TINYINT NOT NULL DEFAULT 0,PRIMARY KEY(id),KEY account_idx(account_id,shown)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_query(mysql, query, false);
    if(mysql_errno())
    {
        printf("[AUCTION] Failed to create auction_notifications, errno=%d. Retry in 5 seconds", mysql_errno());
        SetTimer("AuctionDatabaseInit", 5000, false);
        return 0;
    }

    MPReward_CreateTables();
    gAuctionDatabaseReady = true;
    Auction_EnsureServiceBusinesses();
    Auction_LoadLots();
    LoadBusinessToAuction();
    Auction_ForceServiceBusinessesToAuction();
    LoadFuelStationsToAuction();
    SetTimer("AuctionUpdate", 1000, true);
    printf("[AUCTION] Database ready, active lots loaded");
    return 1;
}

stock Auction_LoadLots()
{
    defualt_slot();
    new Cache:result = mysql_query(mysql, "SELECT * FROM auction_lots WHERE status=0 ORDER BY id ASC", true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }

    new rows = cache_num_rows();
    if(rows > MAX_AUCTION_SLOT) rows = MAX_AUCTION_SLOT;
    for(new row; row < rows; row++)
    {
        new slot = Auction_GetFreeSlot();
        if(slot == -1) break;
        auction_slot[slot][AUCTION_DB_ID] = cache_get_field_content_int(row, "id");
        auction_slot[slot][SLOT_TYPE] = cache_get_field_content_int(row, "slot_type");
        auction_slot[slot][OWNER_SLOT_SQL] = cache_get_field_content_int(row, "seller_id");
        cache_get_field_content(row, "seller_name", auction_slot[slot][OWNER_SLOT_NAME], mysql, 24);
        cache_get_field_content(row, "title", auction_slot[slot][SLOT_NAME], mysql, 32);
        cache_get_field_content(row, "description", auction_slot[slot][OPISANIE_SLOT], mysql, 124);
        auction_slot[slot][OWNER_RATE] = cache_get_field_content_int(row, "bidder_id");
        auction_slot[slot][START_RATE] = cache_get_field_content_int(row, "start_price");
        auction_slot[slot][CURRENT_RATE] = cache_get_field_content_int(row, "current_price");
        auction_slot[slot][TIMER_END] = cache_get_field_content_int(row, "expires_at");
        auction_slot[slot][DATABASE_ID] = cache_get_field_content_int(row, "database_id");
        auction_slot[slot][SERVER_ID] = cache_get_field_content_int(row, "server_id");
        cache_get_field_content(row, "number_vehicle", auction_slot[slot][NUMBER_VEHICLE], mysql, 16);
        auction_slot[slot][NUMBER_SUM] = cache_get_field_content_int(row, "number_sum");
        auction_slot[slot][ITEM_ID] = cache_get_field_content_int(row, "item_id");
        auction_slot[slot][ITEM_MODEL] = cache_get_field_content_int(row, "item_model");
        auction_slot[slot][ITEM_AMOUNT] = cache_get_field_content_int(row, "item_amount");
        auction_slot[slot][ITEM_EXTRA_1] = cache_get_field_content_int(row, "item_extra1");
        auction_slot[slot][ITEM_EXTRA_2] = cache_get_field_content_int(row, "item_extra2");
        auction_slot[slot][ITEM_OLD_SKIN] = cache_get_field_content_int(row, "item_old_skin");
        auction_slot[slot][ITEM_SIM] = cache_get_field_content_int(row, "item_sim");
        auction_slot[slot][ITEM_OLD_SIM] = cache_get_field_content_int(row, "item_oldsim");
        cache_get_field_content(row, "item_meta", auction_slot[slot][ITEM_META], mysql, 40);

        // Convert old state-business lots created with the former 12h timer to the new 2h timer.
        if(auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS && auction_slot[slot][OWNER_SLOT_SQL] == -2 &&
           auction_slot[slot][TIMER_END] > gettime() + AUCTION_STATE_DURATION)
        {
            auction_slot[slot][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
            Auction_SaveLot(slot);
        }
    }
    cache_delete(result);

    for(new slot; slot < MAX_AUCTION_SLOT; slot++)
        if(auction_slot[slot][SLOT_TYPE] && auction_slot[slot][TIMER_END] <= gettime()) finish_auction_slot(slot);
    return rows;
}

public:AuctionUpdate()
{
    if(!gAuctionDatabaseReady) return 1;

    static state_business_refresh;
    if(++state_business_refresh >= 300)
    {
        state_business_refresh = 0;
        LoadBusinessToAuction();
        Auction_ForceServiceBusinessesToAuction();
        LoadFuelStationsToAuction();
    }

    for(new slot; slot < MAX_AUCTION_SLOT; slot++)
    {
        if(!auction_slot[slot][SLOT_TYPE]) continue;
        if(auction_slot[slot][TIMER_END] <= gettime()) finish_auction_slot(slot);
    }
    return 1;
}

stock create_auction_slot(playerid, type, opisanie[124], start_rate, data_base, server_id, number_vehicle[7] = "", number_SUM = 0)
{
    if(!gAuctionDatabaseReady)
        return SendClientMessage(playerid, -1, ""USC" Аукцион ещё загружается. Повторите попытку позже.");
    if(start_rate < 5000 || start_rate > 1000000000)
        return SendClientMessage(playerid, -1, ""USC" Некорректная начальная цена.");

    new id = Auction_GetFreeSlot();
    if(id == -1) return SendClientMessage(playerid, -1, ""SC" Достигнут лимит лотов аукциона.");

    new account_id = GetPlayerAccountID(playerid);
    for(new s; s < MAX_AUCTION_SLOT; s++)
    {
        if(!auction_slot[s][SLOT_TYPE] || auction_slot[s][OWNER_SLOT_SQL] != account_id) continue;
        if(auction_slot[s][SLOT_TYPE] == type && auction_slot[s][DATABASE_ID] == data_base)
            return SendClientMessage(playerid, -1, ""USC" Этот товар уже выставлен на аукцион.");
    }

    Auction_ClearSlot(id);
    auction_slot[id][OWNER_SLOT_SQL] = account_id;
    auction_slot[id][SLOT_TYPE] = type;
    auction_slot[id][OWNER_RATE] = -1;
    auction_slot[id][START_RATE] = start_rate;
    auction_slot[id][CURRENT_RATE] = start_rate;
    auction_slot[id][DATABASE_ID] = data_base;
    auction_slot[id][SERVER_ID] = server_id;
    auction_slot[id][TIMER_END] = gettime() + AUCTION_DEFAULT_DURATION;
    format(auction_slot[id][OWNER_SLOT_NAME], 24, "%s", GetPlayerNameEx(playerid));
    format(auction_slot[id][OPISANIE_SLOT], 124, "%s", opisanie);

    if(Auction_IsInventoryType(type))
    {
        new item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value;
        if(!Market_ReadSlot(playerid, data_base, item_id, model_id, amount, extra_1, extra_2, old_skin, sim_value, oldsim_value) || !Auction_ItemMatchesType(type, item_id))
        {
            Auction_ClearSlot(id);
            return SendClientMessage(playerid, -1, ""USC" Предмет больше не найден в инвентаре.");
        }

        auction_slot[id][ITEM_ID] = item_id;
        auction_slot[id][ITEM_MODEL] = model_id;
        auction_slot[id][ITEM_AMOUNT] = amount;
        auction_slot[id][ITEM_EXTRA_1] = extra_1;
        auction_slot[id][ITEM_EXTRA_2] = extra_2;
        auction_slot[id][ITEM_OLD_SKIN] = old_skin;
        auction_slot[id][ITEM_SIM] = sim_value;
        auction_slot[id][ITEM_OLD_SIM] = oldsim_value;
        Market_GetSourcePlate(playerid, data_base, auction_slot[id][ITEM_META], 40);
        Auction_FormatInventoryName(item_id, model_id, old_skin, sim_value, oldsim_value, extra_1, auction_slot[id][ITEM_META], auction_slot[id][SLOT_NAME], 32);

        if(!Inventory11_DeleteSlotFromDatabase(playerid, data_base))
        {
            Auction_ClearSlot(id);
            return SendClientMessage(playerid, -1, ""USC" Не удалось переместить предмет в хранилище аукциона.");
        }
    }
    else
    {
        switch(type)
        {
            case TYPE_BUSINESS:
            {
                if(server_id < 0 || server_id >= g_business_loaded || GetBusinessData(server_id, B_OWNER_ID) != account_id)
                {
                    Auction_ClearSlot(id);
                    return SendClientMessage(playerid, -1, ""USC" Этот бизнес Вам не принадлежит.");
                }
                auction_slot[id][DATABASE_ID] = GetBusinessData(server_id, B_SQL_ID);
                format(auction_slot[id][SLOT_NAME], 32, "%s", GetBusinessData(server_id, B_NAME));
            }
            case TYPE_VEHICLE:
            {
                new model_index = server_id - 400;
                format(auction_slot[id][SLOT_NAME], 32, "%s", ProbelText(GetVehicleInfo(model_index, VI_NAME)));
                UnloadPlayerOwnableCar(playerid);
            }
            case TYPE_HOUSE:
            {
                if(server_id < 0 || server_id >= MAX_HOUSES || GetHouseData(server_id, H_OWNER_ID) != account_id)
                {
                    Auction_ClearSlot(id);
                    return SendClientMessage(playerid, -1, ""USC" Этот дом Вам не принадлежит.");
                }
                auction_slot[id][DATABASE_ID] = GetHouseData(server_id, H_SQL_ID);
                format(auction_slot[id][SLOT_NAME], 32, "Дом_(%d)", server_id);
            }
        }
    }

    if(!Auction_InsertLot(id))
    {
        if(Auction_IsInventoryType(type)) Auction_QueueInventory(account_id, id);
        Auction_ClearSlot(id);
        return SendClientMessage(playerid, -1, ""USC" Ошибка базы данных. Предмет возвращён в /mpreward.");
    }

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][0]);
    DeletePVar(playerid, "opisanie_param");
    DeletePVar(playerid, "tovar_param_num");
    DeletePVar(playerid, "type_param");
    DeletePVar(playerid, "tovar_param_server");
    DeletePVar(playerid, "price_param");
    DeletePVar(playerid, "tovar_param");
    DeletePVar(playerid, "select_type");
    DeletePVar(playerid, "auction_item_meta");
    DeletePVar(playerid, "auction_inventory_confirmed");
    for(new pon = 1; pon < 6; pon++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][pon], "-");
    SendClientMessage(playerid, -1, ""SC" Лот выставлен на аукцион на 24 часа.");
    return 1;
}

stock AuctionBusiness(sql_id, slot)
{
    new businessid = auction_slot[slot][SERVER_ID];
    if(businessid < 0 || businessid >= g_business_loaded || sql_id <= 0) return 0;

    if(GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY)
        return TCompany_AuctionAssignOwner(sql_id, businessid);

    new query[512], name[24];
    mysql_format(mysql, query, sizeof(query), "SELECT name FROM accounts WHERE id=%d LIMIT 1", sql_id);
    new Cache:result = mysql_query(mysql, query, true);
    if(cache_num_rows()) cache_get_field_content(0, "name", name, mysql, sizeof(name));
    cache_delete(result);
    if(!name[0]) format(name, sizeof(name), "Account_%d", sql_id);

    if(auction_slot[slot][OWNER_SLOT_SQL] > 0)
    {
        mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET business=-1 WHERE id=%d AND business=%d LIMIT 1", auction_slot[slot][OWNER_SLOT_SQL], businessid);
        mysql_query(mysql, query, false);
        foreach(new i : Player)
            if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_SLOT_SQL]) SetPlayerData(i, P_BUSINESS, -1);
    }

    if(GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_CASINO)
        CasinoClearBusinessStaff(businessid);

    new time = gettime();
    new rent_time = (time - (time % 86400)) + 86400;

    // Assign the business both in SQL and in runtime data before the lot is removed.
    mysql_format(mysql, query, sizeof(query),
        "UPDATE business SET owner_id=%d,improvements=0,products=20,prod_price=0,balance=0,rent_time=%d,`lock`=0 WHERE id=%d LIMIT 1",
        sql_id, rent_time, GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, query, false);
    if(mysql_errno()) return 0;

    // Always replace the account's selected business with the won business.
    mysql_format(mysql, query, sizeof(query), "UPDATE accounts SET business=%d WHERE id=%d LIMIT 1", businessid, sql_id);
    mysql_query(mysql, query, false);
    if(mysql_errno()) return 0;

    SetBusinessData(businessid, B_OWNER_ID, sql_id);
    SetBusinessData(businessid, B_IMPROVEMENTS, 0);
    SetBusinessData(businessid, B_PRODS, 20);
    SetBusinessData(businessid, B_PROD_PRICE, 0);
    SetBusinessData(businessid, B_ENTER_MUSIC, 0);
    SetBusinessData(businessid, B_ENTER_PRICE, 0);
    SetBusinessData(businessid, B_BALANCE, 0);
    SetBusinessData(businessid, B_RENT_DATE, rent_time);
    SetBusinessData(businessid, B_LOCK_STATUS, false);
    format(g_business[businessid][B_OWNER_NAME], 21, "%s", name);
    CallLocalFunction("UpdateBusinessLabel", "i", businessid);

    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != sql_id) continue;
        SetPlayerData(i, P_BUSINESS, businessid);
        SetSelectedBusiness(i, businessid);
        SendClientMessage(i, 0x66CC00FF, "\xcd\xe0\xef\xe8\xf8\xe8\xf2\xe5 {0099FF}/business {66CC00}\xe4\xeb\xff \xf3\xef\xf0\xe0\xe2\xeb\xe5\xed\xe8\xff \xe1\xe8\xe7\xed\xe5\xf1\xee\xec.");
        break;
    }
    return 1;
}

stock finish_auction_slot(slot)
{
    if(slot < 0 || slot >= MAX_AUCTION_SLOT || !auction_slot[slot][SLOT_TYPE]) return 0;

    new bidder = auction_slot[slot][OWNER_RATE];
    new seller = auction_slot[slot][OWNER_SLOT_SQL];
    new lot_id = auction_slot[slot][AUCTION_DB_ID];
    new type = auction_slot[slot][SLOT_TYPE];

    if(bidder <= 0)
    {
        if((type == TYPE_BUSINESS || type == TYPE_FUEL_STATION) && seller == -2)
        {
            auction_slot[slot][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
            Auction_SaveLot(slot);
            return 1;
        }

        if(Auction_IsInventoryType(type)) Auction_QueueInventory(seller, slot);
        Auction_CreateNotification(seller, lot_id, 5, auction_slot[slot][SLOT_NAME], auction_slot[slot][DATABASE_ID], 0);
        reset_slot_auction(slot, 2);
        return 1;
    }

    new seller_income;
    if(seller > 0) seller_income = (auction_slot[slot][CURRENT_RATE] * 95) / 100;

    new success = 1;
    new query[256];
    switch(type)
    {
        case TYPE_BUSINESS:
        {
            new businessid = auction_slot[slot][SERVER_ID];
            new bool:is_tcompany = (businessid >= 0 && businessid < g_business_loaded && GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_TRUCKING_COMPANY);
            success = AuctionBusiness(bidder, slot);
            if(success) Auction_CreateNotification(bidder, lot_id, is_tcompany ? 6 : 1, auction_slot[slot][SLOT_NAME], auction_slot[slot][SERVER_ID], auction_slot[slot][CURRENT_RATE]);
        }
        case TYPE_FUEL_STATION:
        {
            new stationid = auction_slot[slot][SERVER_ID];
            if(stationid < 0 || stationid >= g_fuel_station_loaded) success = 0;
            else
            {
                mysql_format(mysql, query, sizeof query, "UPDATE accounts a,fuel_stations f SET a.fuel_st=%d,f.owner_id=%d WHERE a.id=%d AND f.id=%d", stationid, bidder, bidder, auction_slot[slot][DATABASE_ID]);
                mysql_query(mysql, query, false);
                success = !mysql_errno();
                if(success)
                {
                    SetFuelStationData(stationid, FS_OWNER_ID, bidder);
                    Auction_CreateNotification(bidder, lot_id, 1, auction_slot[slot][SLOT_NAME], stationid, auction_slot[slot][CURRENT_RATE]);
                }
            }
        }
        case TYPE_HOUSE:
        {
            success = AuctionHouse(slot, bidder, auction_slot[slot][SERVER_ID]);
            if(success) Auction_CreateNotification(bidder, lot_id, 2, auction_slot[slot][SLOT_NAME], auction_slot[slot][SERVER_ID], auction_slot[slot][CURRENT_RATE]);
        }
        case TYPE_VEHICLE:
        {
            mysql_format(mysql, query, sizeof(query), "UPDATE ownable_cars SET owner_id=%d WHERE id=%d LIMIT 1", bidder, auction_slot[slot][DATABASE_ID]);
            mysql_query(mysql, query, false);
            success = !mysql_errno();
            if(success) Auction_CreateNotification(bidder, lot_id, 2, auction_slot[slot][SLOT_NAME], auction_slot[slot][DATABASE_ID], auction_slot[slot][CURRENT_RATE]);
        }
        case TYPE_VEHICLE_NUMBER, TYPE_SUM_NUMBER, TYPE_CLOTHES, TYPE_ACCESSORY:
        {
            success = Auction_QueueInventory(bidder, slot) > 0;
            if(success) Auction_CreateNotification(bidder, lot_id, 2, auction_slot[slot][SLOT_NAME], auction_slot[slot][ITEM_ID], auction_slot[slot][CURRENT_RATE]);
        }
    }

    if(!success)
    {
        Auction_RefundAccount(bidder, auction_slot[slot][CURRENT_RATE]);
        if(Auction_IsInventoryType(type)) Auction_QueueInventory(seller, slot);
        reset_slot_auction(slot, 3);
        return 0;
    }

    if(seller_income > 0)
    {
        Auction_AddAccountMoney(seller, seller_income);
        Auction_CreateNotification(seller, lot_id, 4, auction_slot[slot][SLOT_NAME], auction_slot[slot][DATABASE_ID], seller_income);
    }
    reset_slot_auction(slot, 1);
    return 1;
}


public: SetBusinessName()
{
    new text[124];

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин 24/7' WHERE `type` = 1");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Клуб' WHERE `type` = 2");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Управление Статистики' WHERE `type` = 3");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Риелторское Агенство' WHERE `type` = 4");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин одежды' WHERE `type` = 5");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Отель' WHERE `type` = 6");
    mysql_query(mysql, text, false);

    // Vehicle dealerships have unique names and are persisted by InitStaticCarMarkets.
    // Do not replace them all with the generic name "Автосалон".

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Казино' WHERE `type` = 8");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='СТО' WHERE `type` = 10");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Сотовый салон' WHERE `type` = 9");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин Оружия' WHERE `type` = 11");
    mysql_query(mysql, text, false);

    if(mysql_errno()) print("ERROR AUCTION UPDATE NAME BUSINESS SQL");

}

public:LoadBusinessToAuction()
{
    load_business_action = true;
    if(!gAuctionDatabaseReady) return 0;

    // Only unowned businesses are state-auction candidates. Never reset an
    // already owned business here: this function is also called periodically.
    new Cache:result = mysql_query(mysql, "SELECT id,name,price,owner_id FROM business ORDER BY id ASC", true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }

    new rows = cache_num_rows(), added;
    for(new row; row < rows; row++)
    {
        new sql_id = cache_get_field_content_int(row, "id");
        new owner_id = cache_get_field_content_int(row, "owner_id");

        new businessid = -1;
        for(new idx; idx < g_business_loaded; idx++)
        {
            if(GetBusinessData(idx, B_SQL_ID) == sql_id)
            {
                businessid = idx;
                break;
            }
        }
        if(businessid == -1) continue;

        // If a state-auction lot still exists for a now-owned business, cancel
        // that stale lot instead of resetting the owner.
        if(owner_id > 0 || GetBusinessData(businessid, B_OWNER_ID) > 0)
        {
            for(new slot; slot < MAX_AUCTION_SLOT; slot++)
            {
                if(auction_slot[slot][SLOT_TYPE] != TYPE_BUSINESS) continue;
                if(auction_slot[slot][DATABASE_ID] != sql_id) continue;
                if(auction_slot[slot][OWNER_SLOT_SQL] == -2)
                {
                    if(auction_slot[slot][OWNER_RATE] > 0)
                    {
                        Auction_RefundAccount(auction_slot[slot][OWNER_RATE], auction_slot[slot][CURRENT_RATE]);
                        Auction_CreateNotification(auction_slot[slot][OWNER_RATE], auction_slot[slot][AUCTION_DB_ID], 3, auction_slot[slot][SLOT_NAME], 0, auction_slot[slot][CURRENT_RATE]);
                    }
                    reset_slot_auction(slot, 1);
                }
            }
            continue;
        }

        new exists;
        for(new slot; slot < MAX_AUCTION_SLOT; slot++)
        {
            if(auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS && auction_slot[slot][DATABASE_ID] == sql_id)
            {
                exists = 1;
                break;
            }
        }
        if(exists) continue;

        new slot = Auction_GetFreeSlot();
        if(slot == -1) break;
        Auction_ClearSlot(slot);
        auction_slot[slot][SLOT_TYPE] = TYPE_BUSINESS;
        auction_slot[slot][OWNER_SLOT_SQL] = -2;
        auction_slot[slot][OWNER_RATE] = -1;
        auction_slot[slot][DATABASE_ID] = sql_id;
        auction_slot[slot][SERVER_ID] = businessid;
        auction_slot[slot][START_RATE] = cache_get_field_content_int(row, "price");
        if(auction_slot[slot][START_RATE] < 5000) auction_slot[slot][START_RATE] = 5000;
        auction_slot[slot][CURRENT_RATE] = auction_slot[slot][START_RATE];
        auction_slot[slot][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
        format(auction_slot[slot][OWNER_SLOT_NAME], 24, "\xc3\xee\xf1\xf3\xe4\xe0\xf0\xf1\xf2\xe2\xee");
        cache_get_field_content(row, "name", auction_slot[slot][SLOT_NAME], mysql, 32);
        format(auction_slot[slot][OPISANIE_SLOT], 124, "\xc3\xee\xf1\xf3\xe4\xe0\xf0\xf1\xf2\xe2\xe5\xed\xed\xfb\xe9 \xe1\xe8\xe7\xed\xe5\xf1 #%d", businessid);
        if(Auction_InsertLot(slot)) added++;
        else Auction_ClearSlot(slot);
    }
    cache_delete(result);
    printf("[AUCTION] Unowned businesses added: %d", added);
    return 1;
}

public:LoadFuelStationsToAuction()
{
    if(!gAuctionDatabaseReady || g_fuel_station_loaded <= 0) return 0;
    new added;
    for(new fs; fs < g_fuel_station_loaded; fs++)
    {
        new sql_id = GetFuelStationData(fs, FS_SQL_ID);
        new exists;
        for(new slot; slot < MAX_AUCTION_SLOT; slot++)
        {
            if(auction_slot[slot][SLOT_TYPE] == TYPE_FUEL_STATION && auction_slot[slot][DATABASE_ID] == sql_id)
            { exists = 1; break; }
        }
        if(exists) continue;

        // Make every fuel station state-owned/free before auctioning it.
        new old_owner = GetFuelStationData(fs, FS_OWNER_ID);
        if(old_owner > 0)
        {
            new query[128];
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET fuel_st=-1 WHERE id=%d LIMIT 1", old_owner);
            mysql_query(mysql, query, false);
            SetFuelStationData(fs, FS_OWNER_ID, 0);
            mysql_format(mysql, query, sizeof query, "UPDATE fuel_stations SET owner_id=0 WHERE id=%d LIMIT 1", sql_id);
            mysql_query(mysql, query, false);
        }

        new slot = Auction_GetFreeSlot();
        if(slot == -1) break;
        Auction_ClearSlot(slot);
        auction_slot[slot][SLOT_TYPE] = TYPE_FUEL_STATION;
        auction_slot[slot][OWNER_SLOT_SQL] = -2;
        auction_slot[slot][OWNER_RATE] = -1;
        auction_slot[slot][DATABASE_ID] = sql_id;
        auction_slot[slot][SERVER_ID] = fs;
        auction_slot[slot][START_RATE] = GetFuelStationData(fs, FS_PRICE);
        if(auction_slot[slot][START_RATE] < 5000) auction_slot[slot][START_RATE] = 5000;
        auction_slot[slot][CURRENT_RATE] = auction_slot[slot][START_RATE];
        auction_slot[slot][TIMER_END] = gettime() + AUCTION_STATE_DURATION;
        format(auction_slot[slot][OWNER_SLOT_NAME], 24, "\xc3\xee\xf1\xf3\xe4\xe0\xf0\xf1\xf2\xe2\xee");
        format(auction_slot[slot][SLOT_NAME], 32, "\xc0\xc7\xd1: %s", GetFuelStationData(fs, FS_NAME));
        format(auction_slot[slot][OPISANIE_SLOT], 124, "\xc3\xee\xf1\xf3\xe4\xe0\xf0\xf1\xf2\xe2\xe5\xed\xed\xe0\xff \xc0\xc7\xd1 #%d", fs + 1);
        if(Auction_InsertLot(slot)) added++; else Auction_ClearSlot(slot);
    }
    if(added > 0) printf("[AUCTION] State fuel stations added: %d", added);
    return added;
}

stock defualt_slot()
{
    for(new slot; slot < MAX_AUCTION_SLOT; slot++) Auction_ClearSlot(slot);
    return 1;
}

stock AuctionHouse(slot, win_slot, houseid)
{
    new query[256];

    foreach(new i : Player)
    {
        if(auction_slot[slot][OWNER_SLOT_SQL] == GetPlayerAccountID(i))
        {
            SetPlayerData(i, P_HOUSE, -1);
            SetPlayerData(i, P_HOUSE_TYPE, -1);
        }
    }

    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET house_type = -1, house = -1 WHERE id=%d", auction_slot[slot][OWNER_SLOT_SQL]);
    mysql_query(mysql, query, false);

    format(query, sizeof query, "UPDATE accounts a, houses h SET a.house_type=%d,a.house=%d,h.owner_id=%d WHERE a.id=%d AND h.id=%d", HOUSE_TYPE_HOME, houseid, win_slot, win_slot, GetHouseData(houseid, H_SQL_ID));
    mysql_query(mysql, query, false);
    if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13");
    printf("sql %s", query);

    if(!mysql_errno())
    {
        foreach(new i : Player)
        {
            if(GetPlayerAccountID(i) == win_slot)
            {
                SetPlayerData(i, P_HOUSE, 		houseid);
                SetPlayerData(i, P_HOUSE_TYPE, 	HOUSE_TYPE_HOME);
            }
        }


        SetHouseData(houseid, H_OWNER_ID, win_slot);
        SetHouseData(houseid, H_IMPROVEMENTS, 	0);

        SetHouseData(houseid, H_STORE_X, 0.0);
        SetHouseData(houseid, H_STORE_Y, 0.0);
        SetHouseData(houseid, H_STORE_Z, 0.0);

        new time = gettime();
        new rent_time = (time - (time % 86400)) + 86400;

        SetHouseData(houseid,	H_RENT_DATE,	rent_time);
        SetHouseData(houseid,	H_LOCK_STATUS,	false);

        new entranceid = GetHouseData(houseid, H_ENTRACE);
        if(entranceid != -1)
        {
            CallLocalFunction("EntranceStatusInit", "i", entranceid);
        }

        new Cache:result, name[24];

        mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", win_slot);
        result = mysql_query(mysql, query, true);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13.1");

        cache_get_field_content(0, "name", name, mysql, 24);

        format(g_house[houseid][H_OWNER_NAME], 21, name, 0);

        cache_delete(result);

        UpdateHouse(houseid);

        HouseHealthInit(houseid);
        HouseStoreInit(houseid);

        format(query, sizeof query, "UPDATE houses SET improvements=0,rent_time=%d,`lock`=%d,store_x=0.0,store_y=0.0,store_z=0.0 WHERE id=%d LIMIT 1", GetHouseData(houseid, H_RENT_DATE), GetHouseData(houseid, H_LOCK_STATUS), GetHouseData(houseid, H_SQL_ID));
        mysql_query(mysql, query, false);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13.2");
        return 1;
    }

        return 0;
}

stock LeafAuction(playerid, all_slot)
{
    for(new p;p < 4;p++) player_show_slot[playerid][p] = -1;

    for(new td; td < 4; td++)
    {
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][0]], "-");
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][1]], "-");
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][2]], "-");
    }

    for(new i = 1; i < 6;i++ ) PlayerTextDrawSetString(playerid, auction_PTD[playerid][i], "-");

    default_select_slot(playerid);

    player_info_panel[playerid][select_slot] = 0;

    for(new i;i < 4;i++) player_show_slot[playerid][i] = -1;
    
    new string[9];
    valstr(string, player_info_panel[playerid][count_list]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][27], string);

    new active_slot_id[MAX_AUCTION_SLOT], slot = -1, filter = player_info_panel[playerid][filter_type], 
    tovar_type = player_info_panel[playerid][filter_tovar_type];

    for(new c;c < MAX_AUCTION_SLOT;c++)
    {
        if(!auction_slot[c][SLOT_TYPE]) continue;

        switch(filter)
        {
            case 1:
            {
                switch(tovar_type)
                {
                    case TYPE_VEHICLE: if(auction_slot[c][SERVER_ID] != player_info_panel[playerid][filter_vehicle_model] && auction_slot[c][SLOT_TYPE] != TYPE_VEHICLE) continue;
                    case TYPE_BUSINESS: if(auction_slot[c][SLOT_TYPE] != TYPE_BUSINESS) continue;
                    case TYPE_HOUSE: if(auction_slot[c][SLOT_TYPE] != TYPE_HOUSE) continue;
                    case TYPE_VEHICLE_NUMBER: if(auction_slot[c][SLOT_TYPE] != TYPE_VEHICLE_NUMBER) continue;
                    case TYPE_SUM_NUMBER: if(auction_slot[c][SLOT_TYPE] != TYPE_SUM_NUMBER) continue;
                    case TYPE_CLOTHES: if(auction_slot[c][SLOT_TYPE] != TYPE_CLOTHES) continue;
                    case TYPE_ACCESSORY: if(auction_slot[c][SLOT_TYPE] != TYPE_ACCESSORY) continue;
                }
            }
            case 2:
            {
                if(auction_slot[c][CURRENT_RATE] < player_info_panel[playerid][filter_min_price]) continue;
                else if(auction_slot[c][CURRENT_RATE] > player_info_panel[playerid][filter_max_price]) continue;
            }
        }
    
        slot++;

        active_slot_id[slot] = c;
        
        if(slot == all_slot - 3) player_show_slot[playerid][0] = active_slot_id[slot];
        if(slot == all_slot - 2) player_show_slot[playerid][1] = active_slot_id[slot];
        if(slot == all_slot - 1) player_show_slot[playerid][2] = active_slot_id[slot];
        if(slot == all_slot)
        {
            player_show_slot[playerid][3] = active_slot_id[slot];
            break;
        }
    }

    for(new td; td < 4; td++)
    {
        if(player_show_slot[playerid][td] == -1) continue;
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][0]], auction_slot[player_show_slot[playerid][td]][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][1]], auction_slot[player_show_slot[playerid][td]][SLOT_NAME]);
        printf("%d | slot td = %d", td, player_show_slot[playerid][td]);

        valstr(string, auction_slot[player_show_slot[playerid][td]][CURRENT_RATE]);
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][2]], string);
    }
}

stock ProbelText(string[])
{
    new result[256];
    for (new i = 0; i < sizeof(result); i++)
    {
        switch(string[i])
        {
            case ' ':result[i] = '_';
            default: result[i] = string[i];
        }
    }
    return result;
}
