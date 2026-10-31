#define SERVER_NAME_FOR_CONT SERVER_NAME
#define MAX_CONT 12

// ============================================
// СТРУКТУРЫ ДАННЫХ
// ============================================

enum PrizeInfo
{
    PRIZE_REGION,       
    PRIZE_ID,          
    PRIZE_NAME[64],      
    PRIZE_PRICE,        
};

enum Cont_Info
{
    ContObjectId,
    ContObjectDoorLId,
    ContObjectDoorRId,
    ContObjectOdejdaId,
    ContVehicleId,
    ContVehicleColor,

    ContRegion,
    ItemType,
    Item,
    ContPrice,
    ItemPrice,
    
    bool:Saled,
    SaleTime,

    BetPrice,
    BetedId,
    BetedName[MAX_PLAYER_NAME],
};

enum cP_Info
{
    BetUseCont,
    BuyUseCont,
}

// ============================================
// ПЕРЕМЕННЫЕ
// ============================================

new cInfo[MAX_CONT + 1][Cont_Info];
new c_pInfo[MAX_PLAYERS][cP_Info];
new Text3D:ContsText[MAX_CONT + 1];
new ContsZone[MAX_CONT + 1];
new ContsTimer[MAX_CONT + 1];

new Text:cont_fon;
new Text:cont_take;
new Text:cont_sell;
new Text:cont_close;
new Text:cont_name[MAX_CONT + 1];
new Text:cont_price[MAX_CONT + 1];
new Text:cont_model[MAX_CONT + 1];

// ============================================
// РЕГИОНЫ И ПРИЗЫ
// ============================================

enum RegionPrizes {
    REGION_RUSSIA = 1,
    REGION_CHINA,
    REGION_DUBAI,
    REGION_GERMANY
};

new const cSkin_Info[][PrizeInfo] = {
    {REGION_RUSSIA, 152, "Одежда", 236000},
    {REGION_RUSSIA, 240, "Одежда", 90000},
    {REGION_RUSSIA, 182, "Одежда", 175000},
    {REGION_RUSSIA, 85, "Одежда", 36000},
    {REGION_RUSSIA, 7, "Одежда", 45000},
    {REGION_RUSSIA, 91, "Одежда", 38610},
    {REGION_RUSSIA, 56, "Одежда", 105300},
    {REGION_RUSSIA, 122, "Одежда", 1000000},
    {REGION_RUSSIA, 75, "Одежда", 500000},
    {REGION_RUSSIA, 66, "Одежда", 133333},
    {REGION_RUSSIA, 45, "Одежда", 80000},
    {REGION_RUSSIA, 78, "Одежда", 50000},
    
    {REGION_DUBAI, 300, "Одежда", 1000000},
    {REGION_DUBAI, 211, "Одежда", 5000000},
    {REGION_DUBAI, 99, "Одежда", 3500000},
    {REGION_DUBAI, 102, "Одежда", 600000},
    {REGION_DUBAI, 125, "Одежда", 1000000},
    {REGION_DUBAI, 101, "Одежда", 3850000}
};

new const cCar_Info[][PrizeInfo] = {
    {REGION_RUSSIA, 404, "VAZ 2107", 50000},
    {REGION_RUSSIA, 555, "ZAZ 968", 20000},
    {REGION_RUSSIA, 401, "VAZ 2101", 42000},
    {REGION_RUSSIA, 401, "Lada Granta", 320000},
    {REGION_RUSSIA, 413, "Gazelle 3221", 1500000},

    {REGION_CHINA, 461, "Ducati SuperSport S", 1647000},
    {REGION_CHINA, 523, "Yamaha FZ-10", 3905000},
    {REGION_CHINA, 522, "Kawasaki Ninja H2R", 3500000},
    {REGION_CHINA, 526, "Infiniti Q60S", 1700000},
    {REGION_CHINA, 603, "Ford Mustang GT", 1500000},
    {REGION_CHINA, 562, "Nissan Skyline R34", 500000},
    {REGION_CHINA, 502, "Nissan GT-R R35", 7110000},
    {REGION_CHINA, 445, "Acura TSX", 1035000},
    {REGION_CHINA, 527, "BMW M3 E46", 945000},

    {REGION_DUBAI, 494, "BMW I8 EDrive", 11850000},
    {REGION_DUBAI, 2549, "Lamborghini Huracan", 14850000},
    {REGION_DUBAI, 2551, "Lamborghini Urus", 13770000},
    {REGION_DUBAI, 400, "BMW X6M F16", 7740000},
    {REGION_DUBAI, 505, "Cadillac Escalade", 6480000},
    {REGION_DUBAI, 475, "Audi Q7", 5400000},
    {REGION_DUBAI, 466, "BMW M5 F90", 8910000},
    {REGION_DUBAI, 502, "Nissan GT-R R35", 7110000},
    {REGION_DUBAI, 604, "Porsche Panamera S", 8100000},
    {REGION_DUBAI, 480, "BMW Z4 M40i", 4410000},
    {REGION_DUBAI, 470, "ГАЗ Тигр", 30000000},
    {REGION_DUBAI, 500, "ГАЗ 69", 30000000},
    {REGION_DUBAI, 596, "BMW M5 F90 (ППС)", 30000000},
    {REGION_DUBAI, 490, "Range Rover SVR", 0},
    {REGION_DUBAI, 429, "Mercedes-Benz GT-R", 12150000},

    {REGION_GERMANY, 461, "Ducati SuperSport S", 1647000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 523, "Yamaha FZ-10", 3905000},
    {REGION_GERMANY, 400, "BMW X6M F16", 7740000},
    {REGION_GERMANY, 402, "Mercedes Benz GT63s", 6320000},
    {REGION_GERMANY, 480, "BMW Z4 M40i", 4410000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 565, "Mercedes-Benz A45 AMG", 2200000},
    {REGION_GERMANY, 445, "Acura TSX", 1035000},
    {REGION_GERMANY, 527, "BMW M3 E46", 945000},
    {REGION_GERMANY, 415, "Lamborghini Aventador S", 10000000}
};

enum RegionInfo
{
    RegionName[15],
    ClothesPrice,
    VehiclePrice,
    ContModelId,
    VorotaModelId,
};

new const g_RegionData[5][RegionInfo] = {
    {"", 0, 0, 0, 0},
    {"Россия", 100000, 200000, 19248, 19249},
    {"Китай", 900000, 2000000, 19250, 19251},
    {"Дубай", 4350000, 9000000, 19252, 19253},
    {"Германия", 900000, 2000000, 19255, 19254}
};

// ============================================
// ПОЗИЦИИ КОНТЕЙНЕРОВ
// ============================================

new Float: cContsPos[12][12] = {
    {-1770.272, 2082.756, 8.567, 183.0,     -1771.866, 2087.164, 8.722, 3.0,      -1769.152, 2087.338, 8.722, -177.0},
    {-1777.229, 2082.354, 8.567, 183.0,     -1778.822, 2086.762, 8.722, 3.0,      -1776.109, 2086.937, 8.722, -177.0},
    {-1780.633, 2082.155, 8.567, 183.0,     -1782.227, 2086.562, 8.722, 3.0,      -1779.512, 2086.738, 8.722, -177.0},
    {-1787.589, 2081.854, 8.567, 183.0,     -1789.182, 2086.262, 8.722, 3.0,      -1786.468, 2086.437, 8.722, -177.0},
    {-1794.447, 2081.554, 8.568, 183.0,     -1796.039, 2085.962, 8.722, 3.0,      -1793.326, 2086.137, 8.722, -177.0},
    {-1770.463, 2104.320, 8.654, 3.0,       -1768.877, 2099.897, 8.809, -177.0,   -1771.588, 2099.733, 8.809, 3.0},
    {-1777.370, 2104.020, 8.654, 3.0,       -1775.784, 2099.597, 8.809, -177.0,   -1778.493, 2099.433, 8.809, 3.0},
    {-1784.227, 2103.569, 8.654, 3.0,       -1782.640, 2099.147, 8.809, -177.0,   -1785.350, 2098.982, 8.809, 3.0},
    {-1787.680, 2103.319, 8.654, 3.0,       -1786.094, 2098.896, 8.809, -177.0,   -1788.803, 2098.732, 8.809, 3.0},
    {-1794.587, 2102.918, 8.654, 3.0,       -1793.001, 2098.496, 8.809, -177.0,   -1795.710, 2098.331, 8.809, 3.0},
    {-1804.947, 2102.518, 8.654, 3.0,       -1803.361, 2098.096, 8.809, -177.0,   -1806.070, 2097.931, 8.809, 3.0},
    {-1811.904, 2102.068, 8.654, 3.0,       -1810.318, 2097.645, 8.809, -177.0,   -1813.028, 2097.481, 8.809, 3.0}
};

new Float: ContBuyTextPos[12][3] = {
    {-1770.466, 2088.101, 9.571},
    {-1777.412, 2087.488, 9.571},
    {1780.738, 2087.159, 9.571},
    {-1787.670, 2087.032, 9.571},
    {-1794.776, 2086.606, 9.571},
    {-1811.576, 2096.927, 9.614},
    {-1804.837, 2097.637, 9.625},
    {-1794.168, 2097.862, 9.602},
    {-1787.372, 2098.010, 9.588},
    {-1783.889, 2098.512, 9.610},
    {-1777.306, 2098.832, 9.606},
    {-1770.091, 2099.248, 9.608}
};

// ============================================
// ФОРВАРДЫ
// ============================================

forward TimerSecondUpdateCont(contid, moneystart[]);
forward SpawnNewCont(contid);
forward CorrectTimerMinute();
forward CheckContainersTime();

// ============================================
// ОСНОВНЫЕ ФУНКЦИИ
// ============================================

stock SpawnCont(contid)
{
    if(contid < 1 || contid > MAX_CONT) return printf("Ошибка контейнера %d", contid);
    
    new prize_region, prize_id, prize_price;
    new prize_name[64];
    new random_prize_index;
    
    new random_prize_type = random(2) + 1;
    if (random_prize_type == 1)
    {
        random_prize_index = random(sizeof(cSkin_Info));
        prize_region = cSkin_Info[random_prize_index][PRIZE_REGION];
        prize_id = cSkin_Info[random_prize_index][PRIZE_ID];
        format(prize_name, sizeof(prize_name), "%s", cSkin_Info[random_prize_index][PRIZE_NAME]);
        prize_price = cSkin_Info[random_prize_index][PRIZE_PRICE];
    }
    else
    {
        random_prize_index = random(sizeof(cCar_Info));
        prize_region = cCar_Info[random_prize_index][PRIZE_REGION];
        prize_id = cCar_Info[random_prize_index][PRIZE_ID];
        format(prize_name, sizeof(prize_name), "%s", cCar_Info[random_prize_index][PRIZE_NAME]);
        prize_price = cCar_Info[random_prize_index][PRIZE_PRICE];
    }
    
    cInfo[contid][ContRegion] = prize_region;
    cInfo[contid][ItemType] = random_prize_type;
    cInfo[contid][Item] = prize_id;
    cInfo[contid][ItemPrice] = prize_price;
    
    new initial_price = 0;
    if (cInfo[contid][ItemType] == 1)
    {
        initial_price = g_RegionData[cInfo[contid][ContRegion]][ClothesPrice];
    }
    else
    {
        initial_price = g_RegionData[cInfo[contid][ContRegion]][VehiclePrice];
    }
    
    cInfo[contid][ContPrice] = initial_price;
    cInfo[contid][BetPrice] = initial_price;
    
    new Float:x, Float:y, Float:z, Float:rot;
    new Float:door1X, Float:door1Y, Float:door1Z, Float:door1A;
    new Float:door2X, Float:door2Y, Float:door2Z, Float:door2A;
    
    x = cContsPos[contid-1][0];
    y = cContsPos[contid-1][1];
    z = cContsPos[contid-1][2];
    rot = cContsPos[contid-1][3];
    
    door1X = cContsPos[contid-1][4];
    door1Y = cContsPos[contid-1][5];
    door1Z = cContsPos[contid-1][6];
    door1A = cContsPos[contid-1][7];
    
    door2X = cContsPos[contid-1][8];
    door2Y = cContsPos[contid-1][9];
    door2Z = cContsPos[contid-1][10];
    door2A = cContsPos[contid-1][11];
    
    new object_model = g_RegionData[cInfo[contid][ContRegion]][ContModelId];
    new vorota_model = g_RegionData[cInfo[contid][ContRegion]][VorotaModelId];

    cInfo[contid][ContObjectId] = CreateObject(object_model, x, y, z, 0.0, 0.0, rot);
    cInfo[contid][ContObjectDoorLId] = CreateObject(vorota_model, door1X, door1Y, door1Z, 0.0, 0.0, door1A);
    cInfo[contid][ContObjectDoorRId] = CreateObject(vorota_model, door2X, door2Y, door2Z, 0.0, 0.0, door2A);

    new moneystr[15];
    ConvertMoney(cInfo[contid][ContPrice], moneystr);

    TextDrawSetString(cont_name[contid], prize_name);
    
    cInfo[contid][Saled] = true;
    cInfo[contid][BetedId] = INVALID_PLAYER_ID;

    new str[256];
    format(str, sizeof str, "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}торги за контейнер открыты\n{993333}Начальная ставка: {FFFFFF}%s рублей", 
        contid, 
        g_RegionData[cInfo[contid][ContRegion]][RegionName], 
        (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
        moneystr);
    
    if (ContsText[contid] == Dynamic3DTextLabel:INVALID_3DTEXT_ID)
    {
        ContsText[contid] = CreateDynamic3DTextLabel(str, -1, x, y, z+1.0, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, false, contid);
    }
    else
    {
        UpdateDynamic3DTextLabelText(ContsText[contid], 0xFF0000FF, str);
    }

    printf("Создан контейнер %d ||| тип %d ||| регион %d", contid, cInfo[contid][ItemType], cInfo[contid][ContRegion]);
    return 1;
}

stock ResetContInfo(contid)
{
    DestroyObject(cInfo[contid][ContObjectId]);
    DestroyObject(cInfo[contid][ContObjectDoorLId]);
    DestroyObject(cInfo[contid][ContObjectDoorRId]);
    DestroyObject(cInfo[contid][ContObjectOdejdaId]);
    DestroyVehicle(cInfo[contid][ContVehicleId]);
    KillTimer(ContsTimer[contid]);
    UpdateDynamic3DTextLabelText(ContsText[contid], 0xFF0000FF, "");
    
    for(new i = 0; i < 17; i++) 
    {
        cInfo[contid][i] = 0;
    }
    cInfo[contid][BetedId] = INVALID_PLAYER_ID;
    cInfo[contid][Saled] = false;
    return 1;
}

stock ConvertMoney(money, string[], length = sizeof string)
{
    format(string, length, "%d", money < 0 ? -money : money);
    for(new i = strlen(string); (i -= 3) > 0;)
    {
        if(string[i] != '\0' && '0' <= string[i] <= '9')
        {
            strins(string, ".", i, length);
        }
        else
        {
            return;
        }
    }
    if(money < 0)
    {
        strins(string, "-", 0, length);
    }
}

// ============================================
// УПРАВЛЕНИЕ КОНТЕЙНЕРАМИ
// ============================================

stock StartCont()
{
    print("[Контейнера] Доставка контейнеров в старый порт");
    StopCont();
    for(new cont=1; cont <= MAX_CONT; cont++)
    {
        SpawnCont(cont);
    }
}

stock StopCont()
{
    for(new cont=1; cont <= MAX_CONT; cont++)
    {
        DestroyObject(cInfo[cont][ContObjectId]);
        DestroyObject(cInfo[cont][ContObjectDoorLId]);
        DestroyObject(cInfo[cont][ContObjectDoorRId]);
        DestroyObject(cInfo[cont][ContObjectOdejdaId]);
        DestroyVehicle(cInfo[cont][ContVehicleId]);
        KillTimer(ContsTimer[cont]);
        ResetContInfo(cont);

        TextDrawHideForAll(cont_name[cont]);
        TextDrawHideForAll(cont_price[cont]);
        TextDrawHideForAll(cont_model[cont]);
    }
    TextDrawHideForAll(cont_fon);
    TextDrawHideForAll(cont_take);
    TextDrawHideForAll(cont_sell);
    TextDrawHideForAll(cont_close);
}

stock StartContBidding(contid)
{
    cInfo[contid][SaleTime] = 30;
    KillTimer(ContsTimer[contid]);

    new moneystr[15], betstr[15];
    ConvertMoney(cInfo[contid][ContPrice], moneystr);
    ConvertMoney(cInfo[contid][BetPrice], betstr);
    
    new str[366];
    format(str, sizeof str, "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}идут активные торги\n{993333}Последняя ставка: {FFFFFF}%s рублей\n{993333}Начальная ставка: {FFFFFF}%s рублей\n{993333}Ставка сделана от: {FFFFFF}%s\n{993333}Время проведения торгов: {FFFFFF}%d секунд", 
        contid, 
        g_RegionData[cInfo[contid][ContRegion]][RegionName], 
        (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
        betstr, 
        moneystr, 
        cInfo[contid][BetedName], 
        cInfo[contid][SaleTime]);
    UpdateDynamic3DTextLabelText(ContsText[contid], 0xFF0000FF, str);
    
    ContsTimer[contid] = SetTimerEx("TimerSecondUpdateCont", 1000, true, "ds", contid, moneystr);
    return 1;
}

// ============================================
// ТАЙМЕРЫ
// ============================================

public TimerSecondUpdateCont(contid, moneystart[])
{
    if(cInfo[contid][SaleTime] > 0)
    {
        cInfo[contid][SaleTime]--;
        cInfo[contid][Saled] = true;
        
        new moneystr[15], betstr[15];
        ConvertMoney(cInfo[contid][ContPrice], moneystr);
        ConvertMoney(cInfo[contid][BetPrice], betstr);
        
        new str[650];
        if (cInfo[contid][BetedId] != INVALID_PLAYER_ID) {
            format(str, sizeof str, "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}идут активные торги\n{993333}Последняя ставка: {FFFFFF}%s рублей\n{993333}Начальная ставка: {FFFFFF}%s рублей\n{993333}Ставка сделана от: {FFFFFF}%s\n{993333}До конца торгов осталось: {FFFFFF}%d секунд", 
                contid, 
                g_RegionData[cInfo[contid][ContRegion]][RegionName], 
                (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
                betstr, 
                moneystart, 
                cInfo[contid][BetedName], 
                cInfo[contid][SaleTime]);
        }
        else
        {
            format(str, sizeof str, "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}торги за контейнер открыты\n{993333}Начальная ставка: {FFFFFF}%s рублей", 
                contid, 
                g_RegionData[cInfo[contid][ContRegion]][RegionName], 
                (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
                moneystr);
        }
        UpdateDynamic3DTextLabelText(ContsText[contid], 0xFF0000FF, str);
    }
    else 
    {
        KillTimer(ContsTimer[contid]);
        ContsTimer[contid] = 0;
        cInfo[contid][Saled] = false;
        
        if (cInfo[contid][BetedId] != INVALID_PLAYER_ID)
        {
            new winnerid = cInfo[contid][BetedId];
            new winner_name[MAX_PLAYER_NAME];
            GetPlayerName(winnerid, winner_name, sizeof(winner_name));

            new Float:door1X = cContsPos[contid-1][4];
            new Float:door1Y = cContsPos[contid-1][5];
            new Float:door1Z = cContsPos[contid-1][6];
            new Float:door1A = cContsPos[contid-1][7];
            
            new Float:door2X = cContsPos[contid-1][8];
            new Float:door2Y = cContsPos[contid-1][9];
            new Float:door2Z = cContsPos[contid-1][10];
            new Float:door2A = cContsPos[contid-1][11];
            
            GivePlayerMoneyEx(winnerid, -cInfo[contid][BetPrice]);
            
            if(cInfo[contid][ItemType] == 2)
            {
                new colors[] = {1, 10, 22, 53, 50};
                cInfo[contid][ContVehicleColor] = colors[random(sizeof(colors))];
                TextDrawSetPreviewVehCol(cont_model[contid], cInfo[contid][ContVehicleColor], 1);
                
                switch(contid)
                {
                    case 1: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 690.51898, 1738.27002, 11.73000, 90, cInfo[contid][ContVehicleColor], 1, 0);
                    case 2: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 690.51898, 1731.78003, 11.73000, 90, cInfo[contid][ContVehicleColor], 1, 0);
                    case 3: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 665.81897, 1726.96997, 11.73000, 0, cInfo[contid][ContVehicleColor], 1, 0);
                    case 4: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 680.23999, 1694.77002, 11.73000, 0, cInfo[contid][ContVehicleColor], 1, 0);
                    case 5: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 672.75598, 1694.77002, 11.73000, 0, cInfo[contid][ContVehicleColor], 1, 0);
                    case 6: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 665.81897, 1694.77002, 11.73000, 0, cInfo[contid][ContVehicleColor], 1, 0);
                    case 7: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 655.51898, 1676.51001, 11.73000, 90, cInfo[contid][ContVehicleColor], 1, 0);
                    case 8: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 655.51898, 1669.80005, 11.73000, 90, cInfo[contid][ContVehicleColor], 1, 0);
                    case 9: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 655.51898, 1663.40002, 11.73000, 90, cInfo[contid][ContVehicleColor], 1, 0);
                    case 10: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 631.91901, 1709.30005, 11.73000, 270, cInfo[contid][ContVehicleColor], 1, 0);
                    case 11: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 631.91901, 1702.55005, 11.73000, 270, cInfo[contid][ContVehicleColor], 1, 0);
                    case 12: cInfo[contid][ContVehicleId] = CreateVehicle(cInfo[contid][Item], 631.91901, 1695.93994, 11.73000, 270, cInfo[contid][ContVehicleColor], 1, 0);
                }
                SetVehicleParamsEx(cInfo[contid][ContVehicleId], false, false, false, true, false, false, false);
                ChangeVehicleColor(cInfo[contid][ContVehicleId], cInfo[contid][ContVehicleColor], 0);
            }
            else
            {
                new Float:contX = cContsPos[contid-1][0];
                new Float:contY = cContsPos[contid-1][1];
                new Float:contZ = cContsPos[contid-1][2];
                new Float:contRot = cContsPos[contid-1][3];
                cInfo[contid][ContObjectOdejdaId] = CreateObject(959, contX, contY, contZ, 0.0, 0.0, contRot);
            }
            
            new str_win[270];
            new balansestr[15];
            ConvertMoney(cInfo[contid][BetPrice], balansestr);
            format(str_win, sizeof(str_win), "| {ffffff}Вы успешно выиграли контейнер{ffff00} #%d{ffffff}! С вашего счета списано {ffff00}%s {ffffff}рублей.", contid, balansestr);
            SendClientMessage(winnerid, 0xFFFF00FF, str_win);
            
            new moneystr[15];
            ConvertMoney(cInfo[contid][BetPrice], moneystr);
            new str[300];
            format(str, sizeof(str), "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}торги окончены\n{993333}Последняя попедная ставка: {FFFFFF}%s рублей\n{993333}Победитель торгов: {FFFFFF}%s\n{993333}Для открытия введите: {FFFFFF}/cont", 
                contid, 
                g_RegionData[cInfo[contid][ContRegion]][RegionName], 
                (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
                moneystr, 
                winner_name);
            UpdateDynamic3DTextLabelText(ContsText[contid], 0x00FF00FF, str);

            MoveObject(cInfo[contid][ContObjectDoorLId], door1X, door1Y, door1Z, 8.5, 0, 0, door1A + 128.0);
            MoveObject(cInfo[contid][ContObjectDoorRId], door2X, door2Y, door2Z, 8.5, 0, 0, door2A - 128.0);
        }
        else
        {
            new moneystr[15];
            ConvertMoney(cInfo[contid][ContPrice], moneystr);
            new str[256];
            format(str, sizeof str, "{993333}Контейнер #%d\n\nСтрана отправитель: {FFFFFF}%s\n{993333}Содержимое контейнера: {FFFFFF}%s\n{993333}Статус: {FFFFFF}торги не состоялись\n{993333}Начальная ставка: {FFFFFF}%s рублей", 
                contid, 
                g_RegionData[cInfo[contid][ContRegion]][RegionName], 
                (cInfo[contid][ItemType] == 1) ? ("Одежда") : ("Транспортное средство"), 
                moneystr);
            UpdateDynamic3DTextLabelText(ContsText[contid], 0xFFFF00FF, str);

            DestroyObject(cInfo[contid][ContObjectId]);
            DestroyObject(cInfo[contid][ContObjectDoorLId]);
            DestroyObject(cInfo[contid][ContObjectDoorRId]);
            DestroyObject(cInfo[contid][ContObjectOdejdaId]);
            DestroyVehicle(cInfo[contid][ContVehicleId]);
            
            SpawnCont(contid);
        }
    }
    return 1;
}

public SpawnNewCont(contid)
{
    SpawnCont(contid);
}

// ============================================
// ГЛАВНЫЙ ТАЙМЕР ДЛЯ АВТОМАТИЧЕСКОГО СПАВНА
// ============================================

public CheckContainersTime()
{
    new hour, minute, second;
    gettime(hour, minute, second);
    
    // Запуск контейнеров каждые 30 минут с 08:30 до 21:30
    if(hour >= 8 && hour <= 21 && minute == 30)
    {
        if(hour == 21 && minute == 30)
        {
            SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Начинаются последние торги за контейнеры в {ffff00}21:30{ffffff}!");
            SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Местоположение: {ffff00}/gps - Развлечения > Битва за контейнеры");
            StartCont();
            return 1;
        }
        
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Начинаются торги за контейнеры!");
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Местоположение: {ffff00}/gps - Развлечения > Битва за контейнеры");
        StartCont();
        return 1;
    }
    // Предупреждение за 10 минут до начала
    else if(hour >= 8 && hour <= 21 && minute == 20)
    {
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Через {ffff00}10{ffffff} минут начнутся торги за контейнеры!");
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Местоположение: {ffff00}/gps - Развлечения > Битва за контейнеры");
        return 1;
    }
    // Предупреждение за 5 минут до окончания
    else if(hour >= 8 && hour <= 21 && minute == 55)
    {
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}До окончания торгов осталось {ffff00}5{ffffff} минут!");
        return 1;
    }
    // Остановка торгов через 30 минут после запуска (в 09:00, 10:00, ... 22:00)
    else if(hour >= 9 && hour <= 22 && minute == 0)
    {
        SendClientMessageToAll(0xFF5533FF, "{ffff00}[Контейнера] {ffffff}Торги за контейнеры закончились!");
        StopCont();
        return 1;
    }
    return 1;
}

// ============================================
// ТЕКСТДРАВЫ
// ============================================

stock CreateContTextDraw()
{
    cont_fon = TextDrawCreate(190.000198, 109.013328, "txd:brcontosnova");
    TextDrawLetterSize(cont_fon, 0.000000, 0.000000);
    TextDrawTextSize(cont_fon, 237.999938, 237.937759);
    TextDrawAlignment(cont_fon, 1);
    TextDrawColor(cont_fon, -1);
    TextDrawSetShadow(cont_fon, 0);
    TextDrawSetOutline(cont_fon, 0);
    TextDrawFont(cont_fon, 4);

    cont_take = TextDrawCreate(190.800003, 349.937774, "txd:brconttake");
    TextDrawLetterSize(cont_take, 0.000000, 0.000000);
    TextDrawTextSize(cont_take, 132.400009, 36.835563);
    TextDrawAlignment(cont_take, 1);
    TextDrawColor(cont_take, -1);
    TextDrawFont(cont_take, 4);
    TextDrawSetSelectable(cont_take, true);

    cont_sell = TextDrawCreate(324.800170, 349.937957, "txd:brcontsell");
    TextDrawLetterSize(cont_sell, 0.000000, 0.000000);
    TextDrawTextSize(cont_sell, 103.600006, 36.337799);
    TextDrawAlignment(cont_sell, 1);
    TextDrawColor(cont_sell, -1);
    TextDrawFont(cont_sell, 4);
    TextDrawSetSelectable(cont_sell, true);

    cont_close = TextDrawCreate(395.600006, 108.515548, "txd:brcontclose");
    TextDrawLetterSize(cont_close, 0.000000, 0.000000);
    TextDrawTextSize(cont_close, 31.199993, 37.333328);
    TextDrawAlignment(cont_close, 1);
    TextDrawColor(cont_close, -1);
    TextDrawFont(cont_close, 4);
    TextDrawSetSelectable(cont_close, true);
    
    for(new cont = 1; cont <= MAX_CONT; cont++)
    {
        cont_name[cont] = TextDrawCreate(294.799987, 121.457778, "Контейнер");
        TextDrawLetterSize(cont_name[cont], 0.327599, 1.321245);
        TextDrawAlignment(cont_name[cont], 2);
        TextDrawColor(cont_name[cont], -1);
        TextDrawSetOutline(cont_name[cont], 1);
        TextDrawBackgroundColor(cont_name[cont], 51);
        TextDrawFont(cont_name[cont], 1);
        TextDrawSetProportional(cont_name[cont], 1);
        
        cont_price[cont] = TextDrawCreate(374.399963, 323.057739, "0 РУБ");
        TextDrawLetterSize(cont_price[cont], 0.307599, 1.236622);
        TextDrawAlignment(cont_price[cont], 2);
        TextDrawColor(cont_price[cont], -1);
        TextDrawSetShadow(cont_price[cont], 0);
        TextDrawSetOutline(cont_price[cont], 1);
        TextDrawBackgroundColor(cont_price[cont], 51);
        TextDrawFont(cont_price[cont], 1);
        TextDrawSetProportional(cont_price[cont], 1);
        
        cont_model[cont] = TextDrawCreate(226.399902, 149.333343, "");
        TextDrawTextSize(cont_model[cont], 175.599990, 165.804412);
        TextDrawColor(cont_model[cont], -1);
        TextDrawUseBox(cont_model[cont], true);
        TextDrawFont(cont_model[cont], 5);
        TextDrawSetPreviewModel(cont_model[cont], 18639);
        TextDrawBackgroundColor(cont_model[cont], 0x00000000);
        TextDrawSetPreviewRot(cont_model[cont], 0.000000, 0.000000, -30.000000, 1.000000);
    }
    return 1;
}

stock CreateContainers()
{
    for(new cont = 1; cont <= MAX_CONT; cont++)
    {
        cInfo[cont][BetedId] = INVALID_PLAYER_ID;
        ContsText[cont] = CreateDynamic3DTextLabel("", 0xFFFFFFFF, ContBuyTextPos[cont-1][0], ContBuyTextPos[cont-1][1], ContBuyTextPos[cont-1][2], 4.0);
        ContsZone[cont] = CreateDynamicCircle(ContBuyTextPos[cont-1][0], ContBuyTextPos[cont-1][1], 3.0, 0, 0, -1);
    }
}

stock cont_GivePlayerOwnableSkinEx(playerid, skinid)
{
    SetPlayerSkin(playerid, skinid);
    SetPlayerData(playerid, P_SKIN, skinid);
    UpdatePlayerDatabaseInt(playerid, "skin", skinid);
    SetPlayerSkinInit(playerid);
    if(mysql_errno()) return SendClientMessage(playerid, -1, "Проблема с базой данных, проверь её!");	
}

// ============================================
// КОМАНДЫ
// ============================================

CMD:cont(playerid)
{
    new bool:sell_limit;
    for(new cont=1; cont < MAX_CONT+1; cont++)
    {
        if(sell_limit == true) continue;
        if(IsPlayerInRangeOfPoint(playerid, 3.0, ContBuyTextPos[cont-1][0], ContBuyTextPos[cont-1][1], ContBuyTextPos[cont-1][2]))
        {
            sell_limit = true;
            
            if(cInfo[cont][Saled] == true)
            {
                if(cInfo[cont][BetedId] == playerid) return SendClientMessage(playerid, 0xFF0000FF, "| {ffffff}Ставка на контейнер уже ваша, вы не можете перебить свою ставку");
                
                c_pInfo[playerid][BetUseCont] = cont;

                new str[140], betstr[15];
                ConvertMoney(cInfo[cont][BetPrice], betstr);
                format(str, sizeof str, "Последняя сделанная ставка: %s рублей\n\nДля того, чтобы сделать свою ставку Вам необходимо\nбудет ввести ее в диалоговом поле ниже:", betstr);
                ShowPlayerDialog(playerid, 2854, DIALOG_STYLE_INPUT, "{FFFF00}"SERVER_NAME" {ffffff}| Битва за контейнер", str, "Готово", "Отмена");
            }
            else
            {
                if(cInfo[cont][BetedId] == playerid)
                {
                    c_pInfo[playerid][BuyUseCont] = cont;

                    new prize_name[64];
                    new prize_price_string[32];
                    new prize_modelid = cInfo[cont][Item];
                    
                    if (cInfo[cont][ItemType] == 1)
                    {
                        for(new i = 0; i < sizeof(cSkin_Info); i++)
                        {
                            if (cSkin_Info[i][PRIZE_ID] == prize_modelid)
                            {
                                format(prize_name, sizeof(prize_name), "%s", cSkin_Info[i][PRIZE_NAME]);
                                break;
                            }
                        }
                        TextDrawSetPreviewModel(cont_model[cont], prize_modelid);
                    }
                    else if (cInfo[cont][ItemType] == 2)
                    {
                        for(new i = 0; i < sizeof(cCar_Info); i++)
                        {
                            if (cCar_Info[i][PRIZE_ID] == prize_modelid)
                            {
                                format(prize_name, sizeof(prize_name), "%s", cCar_Info[i][PRIZE_NAME]);
                                break;
                            }
                        }
                        TextDrawSetPreviewModel(cont_model[cont], prize_modelid, cInfo[cont][ContVehicleColor], 1);
                    }
                    
                    ConvertMoney(cInfo[cont][ItemPrice], prize_price_string);
                    format(prize_price_string, sizeof(prize_price_string), "%s РУБ", prize_price_string);
                    
                    TextDrawSetString(cont_name[cont], prize_name);
                    TextDrawSetString(cont_price[cont], prize_price_string);

                    TextDrawShowForPlayer(playerid, cont_fon);
                    TextDrawShowForPlayer(playerid, cont_take);
                    TextDrawShowForPlayer(playerid, cont_sell);
                    TextDrawShowForPlayer(playerid, cont_close);
                    TextDrawShowForPlayer(playerid, cont_name[cont]);
                    TextDrawShowForPlayer(playerid, cont_price[cont]);
                    TextDrawShowForPlayer(playerid, cont_model[cont]);
                    
                    for(new a;a < 15;a++)  SendClientMessage(playerid, 0xFFFFFFFF, "");          
                    SelectTextDraw(playerid, 0xFFFFFFFF);
                }
            }
        }
    }
    return 1;
}

CMD:startcont(playerid)
{
    if(GetPlayerAdminEx(playerid) < 11) return 1;
    StartCont();  
    ShowNotificationNew(playerid, 1, 3, 0, 0, "Вы самостоятельно запустили торги за контейнера", ">>");
    return 1;
}

CMD:stopcont(playerid)
{
    if(GetPlayerAdminEx(playerid) < 11) return 1;
    StopCont();
    ShowNotificationNew(playerid, 1, 3, 0, 0, "Вы остановили торги за контейнера", ">>");
    return 1;
}

// ============================================
// CALLBACKS
// ============================================

public OnGameModeInit()
{
    CreateContTextDraw(); 
    CreateContainers();
    
    // Запускаем таймер проверки времени каждую минуту
    SetTimer("CheckContainersTime", 60000, true);
    
    #if defined cont_OnGameModeInit
        return cont_OnGameModeInit();
    #else
        return 1;
    #endif
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == cont_sell)
    {
        new cont = c_pInfo[playerid][BuyUseCont];
        if(IsPlayerInRangeOfPoint(playerid, 4.0, ContBuyTextPos[cont-1][0], ContBuyTextPos[cont-1][1], ContBuyTextPos[cont-1][2]) && cInfo[cont][Saled] == false)
        {
            if(cInfo[cont][BetedId] == playerid)
            {
                new sell_price_string[120];
                new sell_price = cInfo[cont][ItemPrice];
                GivePlayerMoneyEx(playerid, sell_price);
                format(sell_price_string, sizeof(sell_price_string), "| {ffffff}Вы успешно продали содержимое контейнера {ffff00}#%d {ffffff}за {ffff00}%d {ffff00}рублей!", cont, sell_price);
                SendClientMessage(playerid, 0x00FF00FF, sell_price_string);

                TextDrawHideForPlayer(playerid, cont_fon);
                TextDrawHideForPlayer(playerid, cont_take);
                TextDrawHideForPlayer(playerid, cont_sell);
                TextDrawHideForPlayer(playerid, cont_close);

                TextDrawHideForPlayer(playerid, cont_name[cont]);
                TextDrawHideForPlayer(playerid, cont_price[cont]);
                TextDrawHideForPlayer(playerid, cont_model[cont]);
                CancelSelectTextDraw(playerid);

                DestroyObject(cInfo[cont][ContObjectId]);
                DestroyObject(cInfo[cont][ContObjectOdejdaId]);
                DestroyVehicle(cInfo[cont][ContVehicleId]);
                KillTimer(ContsTimer[cont]);
                ResetContInfo(cont);
                c_pInfo[playerid][BuyUseCont] = 0;
                c_pInfo[playerid][BetUseCont] = 0;

                SetTimerEx("SpawnNewCont", 5000, false, "i", cont);
            }
        }
    }
    if(clickedid == cont_take)
    {
        new cont = c_pInfo[playerid][BuyUseCont];
        if(IsPlayerInRangeOfPoint(playerid, 4.0, ContBuyTextPos[cont-1][0], ContBuyTextPos[cont-1][1], ContBuyTextPos[cont-1][2]) && cInfo[cont][Saled] == false)
        {
            if(cInfo[cont][BetedId] == playerid)
            {
                if (cInfo[cont][ItemType] == 1) 
                {                  
                    cont_GivePlayerOwnableSkinEx(playerid, cInfo[cont][Item]);
                    SendClientMessage(playerid, 0x00FF00FF, "| {ffffff}Вы получили одежду которую выиграли в контейнере!");
                }
                else if (cInfo[cont][ItemType] == 2) 
                {
                    new car_modelid = cInfo[cont][Item];
                    new car_color = cInfo[cont][ContVehicleColor];
                    new Float: pos_x = 13.035842;
                    new Float: pos_y = 2549.344482;
                    new Float: pos_z = 10.876162;
                    new Float: angle = 358.785644;
                    new query[256], Cache: result;
                    
                    format(query, sizeof query, "INSERT INTO ownable_cars (owner_id, model_id, color_1, color_2, pos_x, pos_y, pos_z, angle, create_time) VALUES ('%d', '%d', '%d', '%d', '%f', '%f', '%f', '%f', '%d')",
                        GetPlayerAccountID(playerid), car_modelid, car_color, car_color, pos_x, pos_y, pos_z, angle, gettime());
                    
                    result = mysql_query(mysql, query, true);
                    cache_delete(result);
                    SendClientMessage(playerid, 0x00FF00FF, "| {ffffff}Поздравляем! Вы получили новый автомобиль, используй /car для подробностей");
                }

                TextDrawHideForPlayer(playerid, cont_fon);
                TextDrawHideForPlayer(playerid, cont_take);
                TextDrawHideForPlayer(playerid, cont_sell);
                TextDrawHideForPlayer(playerid, cont_close);

                TextDrawHideForPlayer(playerid, cont_name[cont]);
                TextDrawHideForPlayer(playerid, cont_price[cont]);
                TextDrawHideForPlayer(playerid, cont_model[cont]);
                CancelSelectTextDraw(playerid);

                DestroyObject(cInfo[cont][ContObjectId]);
                DestroyObject(cInfo[cont][ContObjectOdejdaId]);
                DestroyVehicle(cInfo[cont][ContVehicleId]);
                KillTimer(ContsTimer[cont]);
                ResetContInfo(cont);
                c_pInfo[playerid][BuyUseCont] = 0;
                c_pInfo[playerid][BetUseCont] = 0;

                SetTimerEx("SpawnNewCont", 5000, false, "i", cont);
            }
        }
    }
    if(clickedid == cont_close)
    {
        TextDrawHideForPlayer(playerid, cont_fon);
        TextDrawHideForPlayer(playerid, cont_take);
        TextDrawHideForPlayer(playerid, cont_sell);
        TextDrawHideForPlayer(playerid, cont_close);
        CancelSelectTextDraw(playerid);

        for(new cont=1; cont <= MAX_CONT; cont++)
        {
            TextDrawHideForPlayer(playerid, cont_name[cont]);
            TextDrawHideForPlayer(playerid, cont_price[cont]);
            TextDrawHideForPlayer(playerid, cont_model[cont]);
        }
    }
    #if defined cont_OnPlayerClickTextDraw
        return cont_OnPlayerClickTextDraw(playerid, Text:clickedid);
    #else
        return 1;
    #endif
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 2854)
    {
        if(response)
        {
            new cont = c_pInfo[playerid][BetUseCont];
            if(cont == 0) return printf("ERROR PLAYERID: %d (contuse == 0)");
            if(cInfo[cont][Saled] == true)
            {
                if(cInfo[cont][BetedId] == playerid) return SendClientMessage(playerid, 0xFF0000FF, "| {ffffff}Ставка на контейнер уже ваша, вы не можете перебить свою ставку");
                if(0 < strval(inputtext) < 100000000)
                {
                    if(GetPlayerMoneyEx(playerid) >= strval(inputtext))
                    {
                        if(strval(inputtext)-99999 > cInfo[cont][BetPrice])
                        {
                            if(strval(inputtext) > cInfo[cont][ContPrice] && strval(inputtext) > cInfo[cont][BetPrice])
                            {
                                new str[111];
                                new name[MAX_PLAYER_NAME]; GetPlayerName(playerid, name, MAX_PLAYER_NAME);
                                if(cInfo[cont][BetedId] != INVALID_PLAYER_ID)
                                {
                                    format(str, sizeof str, "| {ffffff}Ваша ставка была отменена в связи с тем, что игрок {FF6347}%s {ffffff}поставил больше!", name);
                                    SendClientMessage(cInfo[cont][BetedId], 0xFF0000FF, str);
                                }

                                cInfo[cont][BetPrice] = strval(inputtext);
                                cInfo[cont][BetedId] = playerid;
                                format(cInfo[cont][BetedName], MAX_PLAYER_NAME, "%s", name);

                                new betstr[15];
                                ConvertMoney(cInfo[cont][BetPrice], betstr);
                                format(str, sizeof str, "| {ffffff}Вы успешно сделали ставку в размере {FFFF00}%s {ffffff}рублей за контейнер {FFFF00}#%d", betstr, cont);
                                SendClientMessage(playerid, 0xFFFF00FF, str);

                                StartContBidding(cont);
                            }
                            else
                            {
                                new str[140], betstr[15];
                                ConvertMoney(cInfo[cont][BetPrice], betstr);
                                format(str, sizeof str, "Последняя сделанная ставка: %s рублей\n\nДля того, чтобы сделать свою ставку Вам необходимо\nбудет ввести ее в диалоговом поле ниже:", betstr);
                                ShowPlayerDialog(playerid, 2854, DIALOG_STYLE_INPUT, "{FFFF00}"SERVER_NAME_FOR_CONT" {ffffff}| Битва за контейнер", str,  "Готово", "Отмена");
                                SendClientMessage(playerid, 0xFF0000FF, "| {ffffff}Ваша ставка должна быть выше последней!");
                                c_pInfo[playerid][BetUseCont] = 0;
                            }
                        }
                        else
                        {
                            new str[140], betstr[15];
                            ConvertMoney(cInfo[cont][BetPrice], betstr);
                            format(str, sizeof str, "Последняя сделанная ставка: %s рублей\n\nДля того, чтобы сделать свою ставку Вам необходимо\nбудет ввести ее в диалоговом поле ниже:", betstr);
                            ShowPlayerDialog(playerid, 2854, DIALOG_STYLE_INPUT, "{FFFF00}"SERVER_NAME_FOR_CONT" {ffffff}| Битва за контейнер", str,  "Готово", "Отмена");
                            SendClientMessage(playerid, 0xFF0000FF, "| {ffffff}Минимальный подьем ставки 100.000 рублей!");
                            c_pInfo[playerid][BetUseCont] = 0;
                        }
                    }
                    else
                    {
                        new str[140], betstr[15];
                        ConvertMoney(cInfo[cont][BetPrice], betstr);
                        format(str, sizeof str, "Последняя сделанная ставка: %s рублей\n\nДля того, чтобы сделать свою ставку Вам необходимо\nбудет ввести ее в диалоговом поле ниже:", betstr);
                        ShowPlayerDialog(playerid, 2854, DIALOG_STYLE_INPUT, "{FFFF00}"SERVER_NAME_FOR_CONT" {ffffff}| Битва за контейнер", str,  "Готово", "Отмена");
                        SendClientMessage(playerid, 0xFF0000FF, "| {ffffff}У вас недостаточно средств для такой ставки!");
                        c_pInfo[playerid][BetUseCont] = 0;
                    }
                }
                else
                {
                    new str[140], betstr[15];
                    ConvertMoney(cInfo[cont][BetPrice], betstr);
                    format(str, sizeof str, "Последняя сделанная ставка: %s рублей\n\nДля того, чтобы сделать свою ставку Вам необходимо\nбудет ввести ее в диалоговом поле ниже:", betstr);
                    ShowPlayerDialog(playerid, 2854, DIALOG_STYLE_INPUT, "{FFFF00}"SERVER_NAME_FOR_CONT" {ffffff}| Битва за контейнер", str,  "Готово", "Отмена");
                    SendClientMessage(playerid, 0xFF0000FF, "{ffffff}Введите корректную ставку!");
                    c_pInfo[playerid][BetUseCont] = 0;
                }
            }
        }
    }
    #if defined cont_OnDialogResponse
        return cont_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 1;
    #endif
}

// ============================================
// ХУКИ
// ============================================

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit cont_OnGameModeInit
#if defined cont_OnGameModeInit
    forward cont_OnGameModeInit();
#endif

#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw cont_OnPlayerClickTextDraw
#if defined cont_OnPlayerClickTextDraw
    forward cont_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse cont_OnDialogResponse
#if defined cont_OnDialogResponse
    forward cont_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif