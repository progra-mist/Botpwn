/* ТО ЧТО ДОБАВИТЬ В МОД

//эти строки добавить в enum E_OWNABLE_CAR_STRUCT
	OC_COMFORT_PL,
	OC_SPORT,
	OC_SPORT_PL,
	OC_DRIFT,

//эти строки добавить в LoadOwnableCar (где находиться подобные строки)

		SetOwnableCarData(idx, 	OC_COMFORT_PL,	cache_get_field_content_int(0, "comfort"));
		SetOwnableCarData(idx, 	OC_SPORT,	cache_get_field_content_int(0, "sport"));
		SetOwnableCarData(idx, 	OC_SPORT_PL,	cache_get_field_content_int(0, "sport_plus"));
		SetOwnableCarData(idx, 	OC_DRIFT,	cache_get_field_content_int(0, "drift"));

//эти строки добавить в stock IsBusinessNoEnter(action_id) 
	if(GetBusinessData(action_id, B_TYPE) == 20) return 1;
*/


enum STRUCT_VEHICLE
{
    Float:V_MASS,
    Float:V_TURN_MASS,
    Float:V_TRACTION_COEF,
    Float:V_TRACTION_LOSS,
    Float:V_TRACTION_BIAS,
    V_GEAR,
    Float:V_MAX_SPEED,
    Float:V_ACCELERATION,
    Float:V_ENG_INERT,
    Float:V_BRAKE_COEF,
    Float:V_SUSPINSION_LOWER,
    Float:V_SUSPINSION_BIAS,
};


new business_stage = -1;
new Float:coord_enter_stage[3][3] =
{
    {-413.479156,1004.876037,12.228313},
    {-419.762145,1004.876037,12.163836},
    {-426.040313,1004.876037,12.222449}
};

new Float:coord_exit_stage[3][4] =
{
    {-413.178039,1026.381225,11.207756,359.111328},
    {-426.550415,1025.983154,11.206798,354.677520},
    {-419.570526,1025.581665,11.205725,1.031186}
};

new player_select_stage[MAX_PLAYERS], player_price_stage[MAX_PLAYERS];
new Text:stg_TD[5];
new PlayerText:stg_PTD[MAX_PLAYERS][14];
new stage_td_select[4][2][] =
{
    {"txd:brtuning4stg1", "txd:brtuning4astg1"},
    {"txd:brtuning4stg2", "txd:brtuning4astg2"},
    {"txd:brtuning4stg3", "txd:brtuning4astg3"},
    {"txd:brtuning4stg4", "txd:brtuning4astg4"}
};

new stage_td_p_select[4][] = 
{
    {"txd:brtuning4nstage1"},
    {"txd:brtuning4nstage2"},
    {"txd:brtuning4nstage3"},
    {"txd:brtuning4nstage4"} 
};

new Float:count_setting[4][10] =
{
    {
        5.0, 13.0, 16.0, 19.0, 25.0, 28.0, 30.0, 33.5, 35.0, 45.0
    },

    {
        0.4, 0.5, 0.55, 0.6, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90
    },
    { 
        1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0
    }, 
    {
        0.0, 0.01, 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    }
};

//Инструкция какой столбец за что отвчечает
//БУКВА          ФУНКЦИЯ                        ОПИСАНИЕ
//B  --         SetVehiclerMass                 -- Масса (100...50000)           
//C  --         SetVehiclerMassTurn             -- Масса в повороте
//J  --         SetVehicleTractionCoef          -- Сила сцепления с дорогой (0.5...2.0)
//K  --         SetVehicleTractionLoss          -- Потеря сцепления (скорость поворота 0.5...2.0)
//L  --         SetVehicleTractionBias          -- Смещение сцепления (корпуса0.1...0.6)
//M  --         SetVehicleGear                  --- Количество передач (всего 5)
//N  --         SetVehicleMaxSpeed              —- Максимальная скорость
//O  --         SetVehicleAcceleration          —— Ускорение (мощность)
//P  --         SetVehicleEngInert              —— Инерция двигателя (влияет на ускорение 0.0...250.0)
//S  --         SetVehicleBrakeCoef             -— Эффективность торможения (1.0...20.0)
//f  --         SetVehicleSuspensionBias        -- подвестка
//e  --         SetVehicleSuspinsionLower       -- подвестка

new setting_vehicle[210][STRUCT_VEHICLE] = 
{ 
    //  B         C       J      K     L        M   N      O     P          S             e    f   		
    {1700.0 ,   5008.0 ,  0.75, 0.85, 0.5 , 	5, 280.0, 18.7, 35.0 ,	    6.2  ,  	-0.14, 0.5 },   //400   == id шники транспорта
    {1300.0 ,   2200.0 ,  0.75, 0.80, 0.52,     5, 160.0, 15.0, 10.0 ,	    8.0  , 	    -0.15, 0.57},//401
    {1500.0 ,   4000.0 ,  0.7 , 0.9 , 0.5 , 	5, 315.0, 20.5, 10.0 ,  	11.0 ,  	-0.24, 0.5 },//402
    {3800.0 ,  19953.2 ,  0.95, 0.65, 0.4 , 	5, 120.0, 25.0, 30.0 ,  	8.0  ,  	-0.20, 0.5 },//403
    {1200.0 ,   3000.0 ,  0.70, 0.90, 0.48, 	5, 150.0, 13.0, 122.0,  	4.0  ,  	-0.17, 0.5 },//404
    {1600.0 ,   4000.0 ,  0.75, 0.75, 0.5 , 	5, 305.0, 18.9, 20.0 ,  	10.0 ,  	-0.20, 0.5 }	,//405
    {20000.0,  200000.0,  0.78, 0.8 , 0.55,     4, 110.0, 25.0, 30.0 , 	    3.17 ,  	-0.30, 0.55}	,//406
    {6500.0 ,  36670.8 ,  0.55, 0.8 , 0.5 , 	5, 170.0, 27.0, 10.0 ,   	10.00,  	-0.17, 0.5 }	,//407
    {5500.0 ,  33187.9 ,  0.70, 0.9 , 0.5 , 	4, 110.0, 20.0, 30.0 ,   	3.5  ,  	-0.25, 0.55}	,//408
    {2200.0 ,  10000.0 ,  0.70, 0.8 , 0.5 , 	5, 180.0, 18.0, 25.0 ,   	10.0 ,  	-0.20, 0.5 }	,//409
    {1000.0 ,   1400.0 ,  0.80, 0.8 , 0.5 , 	5, 280.0, 20.0, 10.0 ,   	8.0  ,  	-0.15, 0.5 }	,//410
    {1400.0 ,   2725.3 ,  0.80, 0.8 , 0.50, 	5, 224.0, 30.0, 10.0 ,   	11.0 ,  	-0.10, 0.5 }	,//411
    {1800.0 ,   4411.5 ,  0.95, 0.80, 0.45, 	5, 160.0, 23.0, 19.0  ,   	6.50 ,  	-0.25, 0.5 }	,//412
    {2600.0 ,   8666.7 ,  0.55, 0.90, 0.50, 	5, 160.0, 15.0, 25.0 ,   	6.0  ,  	-0.15, 0.25}	,//413
    {3500.0 ,  14000.0 ,  0.55, 0.85, 0.46, 	5, 140.0, 18.0, 20.0 ,   	4.5  ,  	-0.15, 0.5 }	,//414
    {1200.0 ,   3000.0 ,  0.80, 0.9 , 0.50,     5, 350.0, 24.0, 7.0  ,   	11.1 ,  	-0.15, 0.5 }	,//415
    {1900.0 ,   6333.3 ,  0.75, 0.80, 0.47, 	5, 160.0, 13.0, 75.0 ,   	7.0  ,  	-0.20, 0.5 }	,//416
    {2000.0 ,   5848.3 ,  0.70, 0.80, 0.50, 	5, 150.0, 15.0, 15.0 ,   	5.5  ,  	-0.15, 0.55}	,//417
    {1800.0 ,   4350.0 ,  0.55, 0.88, 0.52, 	5, 160.0, 18.0, 16.0  ,   	4.0  ,  	-0.18, 0.5 }	,//418
    {1600.0 ,   4000.0 ,  0.80, 0.75, 0.45, 	5, 205.0, 20.8, 23.0 ,   	9.1  ,  	-0.15, 0.54}	,//419
    {1850.0 ,   5000.0 ,  0.75, 0.65, 0.52, 	4, 187.0, 13.5, 99.0 ,   	7.5  ,  	-0.20, 0.5 }	,	//420
    {1700.0 ,   4000.0 ,  0.75, 0.85, 0.57, 	5, 165.0, 20.0, 15.0 ,   	8.5  ,  	-0.18, 0.4 }	,//421
    {1700.0 ,   4108.3 ,  0.75, 0.75, 0.5 , 	5, 145.0, 14.0, 50.0 ,   	4.17 ,  	-0.15, 0.5 }	,//422
    {1200.0 ,   2000.0 ,  0.75, 0.85, 0.5,      4, 170.0, 30.0, 10.0 , 	    6.0  ,  	-0.15, 0.45}	,//423
    {1600.0 ,   3921.3 ,  0.75, 0.85, 0.52, 	5, 200.0, 22.0, 10.0 ,   	10.0 ,  	-0.12, 0.38}	,//424
    {4000.0 ,  17333.3 ,  0.55, 0.8 , 0.48, 	5, 170.0, 20.0, 20.0 ,   	5.4  ,  	-0.25, 0.5 }	,//425
    {7000.0 ,  30916.7 ,  0.50, 0.7 , 0.46, 	5, 170.0, 15.0, 30.0 ,   	8.4  ,  	-0.15, 0.5 }	,//426
    {1400.0 ,   3000.0 ,  0.75, 0.89, 0.50, 	5, 318.0, 22.5, 10.0 ,   	8.0  ,  	-0.15, 0.5 }	,//427
    {5500.0 ,  33187.9 ,  0.75, 0.85, 0.40, 	4, 130.0, 14.0, 50.0 ,   	4.17 ,  	-0.25, 0.45}	,//428
    {25000.0,  250000.0,  2.50, 0.8 , 0.5 , 	4, 280.0 ,40.0 ,150.0 ,   	5.0  , 	    -0.10, 0.5 }	,//429
    {10500.0,   61407.5,  0.75, 0.7 , 0.47, 	5, 180.0, 20.0, 50.0 ,   	4.00 ,  	-0.17, 0.5 }	,//430
    {1400.0 ,   3400.0 ,  0.75, 0.8 , 0.5 , 	5, 200.0, 28.0, 5.0  ,   	11.0 ,  	-0.20, 0.4 }	,//431
    {3800.0 ,  30000.0 ,  0.45, 0.75, 0.5 , 	5, 120.0, 18.0, 5.0  ,   	8.0  ,  	-0.15, 0.5 }	,//432
    {1400.0 ,   3000.0 ,  0.70, 0.80, 0.45,     5, 242.0, 16.8, 44.0 ,   	8.0  ,  	-0.18, 0.55}	,//433
    {9500.0 ,  57324.6 ,  0.75, 0.85, 0.35, 	5, 160.0, 18.0, 10.0 , 	    5.7  ,  	-0.25, 0.5 }	,//434
    {1400.0 ,   4000.0 ,  0.75, 0.85, 0.51, 	5, 238.0, 15.5, 90.0 , 	    7.0  ,  	-0.30, 0.5 }	,//435
    {1600.0 ,   3921.3 ,  0.80, 0.75, 0.55, 	4, 160.0, 23.0, 5.0  , 	    8.17 ,  	-0.2 , 0.5 }	,//436
    {2000.0 ,   4901.7 ,  0.7 , 0.75, 0.52, 	5, 160.0, 18.0, 15.0 , 	    5.5  ,  	-0.11, 0.5 }	,//437
    {100.0  ,    24.1  ,  0.80, 0.90, 0.49, 	1,  75.0, 35.0, 5.0  , 	    5.5  ,  	-0.08, 0.5 }	,//438
    {2500.0 ,   5960.4 ,  0.75, 0.80, 0.50, 	5, 150.0, 16.0, 15.0 , 	    4.0  ,  	-0.15, 0.4 }	,//439
    {8000.0 ,  48273.3 ,  0.75, 0.85, 0.35, 	5, 150.0, 13.0, 5.0  , 	    5.7  ,  	-0.25, 0.5 }	,//440
    {5000.0 ,  20000.0 ,  0.75, 0.85, 0.55,     5, 110.0, 45.0, 25.0 , 	    7.0  ,  	-0.30, 0.5 }	,//441
    {1650.0 ,   3851.4 ,  0.75, 0.90, 0.51, 	5, 258.0, 16.4, 67.0 , 	    8.5  ,  	-0.19, 0.5 }	,	//442
    {1900.0 ,   4795.9 ,  0.97, 0.77, 0.51, 	5, 150.0, 25.0, 5.0  , 	    8.5  ,  	-1.00, 0.4 }	,//443
    {25500.0,  139272.5,  0.58, 0.7 , 0.46, 	5, 140.0, 24.0, 5.0  , 	    10.00,  	-0.17, 0.5 }	,//444
    {3800.0 ,  30000.0 ,  0.45, 0.75, 0.5 , 	5, 120.0, 18.0, 5.0  , 	    8.0  ,  	-0.15, 0.5 }	,//445
    {2200.0 ,  29333.3 ,  3.00, 15.0, 0.65, 	5, 190.0, 3.0 , 5.0  ,   	0.02 ,  	 0.05, 0.0  }	,//446
    {8500.0 ,  48804.2 ,  0.70, 0.7 , 0.46, 	5, 140.0, 25.0, 80.0 , 	    10.00,  	-0.17, 0.5 }	,//447
    {4500.0 ,  18003.7 ,  0.55, 0.70, 0.48,     5, 160.0, 14.0, 40.0 ,   	4.5  ,  	-0.25, 0.5 }	,//448
    {1000.0 ,   1354.2 ,  0.55, 0.85, 0.5 , 	3, 160.0, 15.0, 30.0 ,   	13.0 ,  	-0.13, 0.5 }	,//449
    {3000.0 ,  3500.0  ,  0.75, 0.75, 0.6 ,     4 , 130.0, 30.0, 50.0 ,      8.0  ,      -0.1 , 0.4 },//450
    {1400.0 ,   3000.0 ,  0.75, 0.85, 0.45, 	5, 240.0, 30.0, 10.0 , 	    11.0 ,  	-0.20, 0.5  }	,//451
    {1600.0 ,   4000.0 ,  0.70, 0.84, 0.52, 	5, 305.0, 20.8, 23.0 ,  	6.2  ,  	-0.22, 0.5 }	,//452
    {1900.0 ,   4529.9 ,  0.77, 0.75, 0.52, 	5, 140.0, 13.0, 150.0,  	5.0  ,  	-0.17, 0.5 }	,//453
    {2500.0 ,   7968.7 ,  0.70, 0.85, 0.5 , 	5, 170.0, 25.0, 20.0 ,  	8.0  ,  	-0.35, 0.5 }	,//454
    {1950.0 ,   4712.5 ,  0.70, 0.75, 0.51, 	5, 160.0, 18.0, 15.0 ,  	3.5  ,  	-0.20, 0.58}	,//455
    {1700.0 ,   4000.0 ,  0.70, 0.80, 0.53, 	5, 250.0, 16.5, 23.0 ,  	8.0  ,  	-0.20, 0.5 }	,	//456
    {1400.0 ,   2979.7 ,  0.80, 0.80, 0.51, 	5, 200.0, 28.0, 10.0 ,  	11.1 ,      -0.15, 0.5 },//457
    {1850.0 ,   3534.0 ,  0.70, 0.70, 0.5 , 	4, 150.0, 14.0, 25.0 ,  	6.5  ,  	-0.18, 0.4 }	,//458
    {1500.0 ,   3800.0 ,  0.75, 0.85, 0.52, 	5, 170.0, 13.0, 150.0,  	5.0  , 	    -0.17, 0.5 }	,//459
    {1400.0 ,   2200.0 ,  0.70, 0.9 , 0.5 , 	5, 250.0, 17.7, 30.0 ,   	11.0 ,  	-0.15, 0.5 }	,//460
    {1900.0 ,   5000.0 ,  0.70, 0.87, 0.51, 	5, 150.0, 25.0, 100.0,  	8.5  ,  	-0.25, 0.4 }	,//461
    {1900.0 ,   4000.0 ,  0.60, 0.80, 0.46, 	5, 120.0, 16.0, 20.0 ,     	8.5  ,  	-0.10, 0.4 }	,//462
    {1000.0 ,   1354.2 ,  1.00, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,     	5.0  ,  	-0.10, 0.5 }	,//463
    {10000.0,   35000.0,  0.85, 0.8 , 0.60,     5, 100.0, 35.0, 150.0,   	5.0  ,  	-0.20, 0.35}	,//464
    {2500.0 ,   7604.2 ,  0.70, 0.85, 0.54,     5, 250.0, 16.5, 40.0 ,   	7.0  ,  	-0.25, 0.45}	,//465
    {3500.0 ,  11156.2 ,  0.80, 0.80, 0.52,     5, 260.0, 18.2, 38.0 ,   	8.5  ,  	-0.20, 0.5 }	,//466
    {1700.0 ,   3435.4 ,  0.70, 0.86, 0.5 , 	4, 160.0, 18.0, 15.0 ,   	7.0  ,  	-0.15, 0.5 }	,//467
    {1600.0 ,   4000.0 ,  0.70, 0.8 , 0.52, 	4, 160.0, 20.0, 20.0 ,   	5.4  ,  	-0.20, 0.5 }	,//468
    {1200.0 ,   3000.0 ,  0.85, 0.80, 0.48, 	0, 320.0, 20.9, 3.0  ,   	10.0 ,      -0.16, 0.6 },//469
    {2000.0 ,   4000.0 ,  0.75, 0.85, 0.5 , 	5, 210.0, 16.3, 37.0 ,   	8.0  ,  	-0.31, 0.5 }	,//470
    {1000.0 ,   2141.7 ,  0.85, 0.85, 0.5 , 	5, 200.0, 26.0, 5.0  ,   	11.0 ,  	-0.12, 0.5 }	,//471
    {5500.0 ,  23489.6 ,  0.82, 0.70, 0.46, 	5, 140.0, 14.0, 45.0 ,   	4.5  ,  	-0.25, 0.35}	,//472
    {3500.0 ,  13865.8 ,  0.75, 0.70, 0.46, 	5, 140.0, 14.0, 20.0 ,   	4.5  ,  	-0.15, 0.45}	,//473
    {1300.0 ,   1900.0 ,  0.70, 0.80, 0.50, 	5, 160.0, 24.0, 15.0 ,   	8.0  ,  	-0.20, 0.35}	,//474
    {2100.0 ,   5146.7 ,  0.75, 0.70, 0.52, 	5, 160.0, 24.0, 5.0  ,   	6.2  ,  	-0.24, 0.5 }	,//475
    {1400.0 ,   2800.0 ,  0.75, 0.86, 0.48, 	5, 230.0, 26.0, 5.0  ,   	8.0  ,  	-0.10, 0.5 }	,//476
    {2200.0 ,   5000.0 ,  0.70, 0.80, 0.46, 	5, 240.0, 15.4, 50.0 ,   	6.0  ,  	-0.15, 0.5 }	,//477
    {3500.0 ,  13865.8 ,  0.72, 0.70, 0.46, 	5, 140.0, 14.0, 25.0 ,   	4.5  ,  	-0.15, 0.5 }	,//478
    {3800.0 ,  20000.0 ,  0.85, 0.75, 0.4 , 	5, 120.0, 25.0, 20.0 ,   	8.0  ,  	-0.20, 0.5 }	,//479
    {5000.0 ,  28000.0 ,  0.95, 0.75, 0.4 , 	5, 120.0, 25.0, 20.0 ,   	8.0  ,  	-0.17, 0.5 }	,//480
    {1400.0 ,   4000.0 ,  0.75, 0.80, 0.50, 	5, 238.0, 15.5, 90.0 ,   	8.0  ,  	-0.10, 0.58}	,//481
    {1400.0 ,   3267.8 ,  0.75, 0.80, 0.52, 	5, 165.0, 22.0, 10.0 ,   	7.0  ,  	-0.15, 0.5 }	,//482
    {1700.0 ,   4500.0 ,  0.70, 0.86, 0.54, 	4, 160.0, 24.0, 15.0 ,   	5.0  ,  	-0.20, 0.54}	,//483
    {5500.0 ,  33187.9 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 ,   	3.17 , 	    -0.25, 0.55}	,//484
    {3500.0 ,  12000.0 ,  0.85, 0.70, 0.46, 	5, 160.0, 25.0, 30.0 ,   	6.0  ,  	-0.15, 0.25}	,//485
    {1700.0 ,   4166.4 ,  0.70, 0.84, 0.53, 	5, 270.0, 18.0, 35.0 ,   	8.17 ,  	-0.10, 0.5 }	,	//486
    {1200.0 ,   2000.0 ,  0.70, 0.86, 0.5 ,     5, 250.0, 17.6, 47.0 ,   	8.0  ,  	-0.08, 0.5 }	,//487
    {4000.0 ,  10000.0 ,  0.75, 0.85, 0.54,     5, 170.0, 25.0, 25.0 ,   	6.0  ,  	-0.15, 0.5 }	,//488
    {1800.0 ,   4350.0 ,  0.70, 0.8 , 0.52, 	5, 183.0, 13.6, 100.0,  	5.4  ,  	-0.14, 0.5 }	,//489
    {1000.0 ,   1354.2 ,  0.80, 0.85, 0.5 , 	3,  60.0, 20.0, 15.0 ,   	6.0  ,  	-0.20, 0.5 }	,//490
    {2000.0 ,   5000.0 ,  0.90, 0.85, 0.5 , 	4,  70.0, 20.0, 90.0 ,   	15.0 ,  	-0.05, 0.5 }	,//491
    {8500.0 ,  48804.2 ,  0.88, 0.7 , 0.46, 	5, 140.0, 25.0, 80.0 ,   	10.00,  	-0.11, 0.5 }	,//492
    {1600.0 ,   4500.0 ,  0.75, 0.9 , 0.5 , 	5, 320.0, 21.0, 5.0  ,   	7.0  ,  	-0.10, 0.5 }	,//493
    {1800.0 ,   4000.0 ,  0.75, 0.80, 0.56,     5, 235.0, 16.2, 65.0 ,	    6.50 ,  	-0.20, 0.4 }	,//494
    {1950.0 ,   4712.5 ,  0.75, 0.90, 0.50, 	5, 160.0, 40.0, 10.0 ,   	10.0 ,  	-0.14, 0.5 }	,//495
    {1500.0 ,   2500.0 ,  0.75, 0.84, 0.53, 	5, 175.0, 13.7, 100.0,  	8.17 ,  	-0.15, 0.44}	,	//496
    {5500.0 ,  65000.0 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 ,   	3.17 , 	     0.0 , 0.55}	,//497
    {5500.0 ,  65000.0 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 ,   	3.17 , 	    -0.10, 0.55}	,//498
    {1800.0 ,   3000.0 ,  0.70, 0.8 , 0.5 , 	5, 210.0, 13.4, 80.0 ,   	5.4  ,  	-0.16, 0.56}	,//499
    {1200.0 ,   2500.0 ,  0.75, 0.90, 0.48, 	5, 330.0, 24.9, 12.0 ,   	8.0  ,  	-0.10, 0.45}	,//500
    {1400.0,    3000.0 ,  0.73, 0.89, 0.47,	    5, 280.0, 19.9, 40.0, 	    24.0 ,	    -0.12, 0.3	}	,//501
    {1600.0 ,   3000.0 ,  0.75, 0.80, 0.52, 	5, 142.0, 12.9, 90.0 ,   	8.0  ,  	-0.10, 0.5 }	,	//502
    {1700.0 ,   4500.0 ,  0.75, 0.70, 0.5 , 	5, 165.0, 25.0, 20.0 ,   	8.5  ,  	-0.15, 0.4 }	,//503
    {1700.0 ,   4108.3 ,  0.85, 0.85, 0.51, 	5, 160.0, 20.0, 5.0  ,   	6.2  ,  	-0.15, 0.5 }	,	//504
    {1700.0 ,   4000.0 ,  0.75, 0.75, 0.52, 	5, 160.0, 22.0, 10.0 ,   	8.0  ,  	-0.15, 0.5 }	,//505
    {1800.0 ,   4350.0 ,  0.70, 0.8 , 0.49, 	5, 160.0, 18.0, 25.0 ,   	5.4  ,  	-0.15, 0.54}	,//506
    {1600.0 ,   3300.0 ,  0.70, 0.8 , 0.54, 	4, 160.0, 18.0, 7.0  ,   	5.4  ,  	-0.14, 0.5 }	,//507
    {1700.0 ,   4166.4 ,  0.70, 0.85, 0.52, 	4, 120.0, 22.0, 260.0,  	8.17 ,  	-0.16, 0.5 }	,	//508
    {1600.0 ,   3550.0 ,  0.70, 0.8 , 0.52, 	5, 240.0, 16.7, 60.0 ,   	5.4  ,  	-0.12, 0.55}	,//509
    {1800.0 ,   4500.0 ,  0.75, 0.8 , 0.49, 	5, 307.0, 20.8, 20.0 ,   	9.0  ,  	-0.08, 0.54}	,//510
    {2600.0 ,   8666.7 ,  0.85, 0.70, 0.46, 	5, 160.0, 18.0, 10.0 ,   	6.0  ,  	-0.18, 0.25}	,//511
    {3000.0 ,   6000.0 ,  0.70, 0.80, 0.4 , 	5, 170.0, 25.0, 15.0 ,   	8.5  ,  	-0.20, 0.5 }	,//512
    {1500.0 ,   3500.0 ,  0.55, 0.85, 0.5 , 	4, 120.0, 12.5, 280.0,  	8.0  ,  	-0.10, 0.5 }	,//513
    {5000.0 ,  20000.0 ,  0.75, 0.85, 0.55,     5, 110.0, 45.0, 25.0 ,   	7.0  ,  	-0.30, 0.5 }	,//514
    {5000.0 ,  20000.0 ,  0.75, 0.85, 0.55,     5, 110.0, 45.0, 25.0 ,   	7.0  ,  	-0.30, 0.5 }	,//515
    {1400.0 ,   2998.3 ,  0.80, 0.85, 0.47,     5, 250.0, 19.3, 40.0 ,   	8.0  , 	    -0.10, 0.5 }	,//516
    {1500.0 ,   3600.0 ,  0.85, 0.8 , 0.5 , 	5, 220.0, 15.1, 95.0 ,   	10.0 ,  	-0.15, 0.5 }	,//517
    {1400.0 ,   3400.0 ,  0.80, 0.8 , 0.5 , 	5, 250.0, 16.6, 60.0 ,   	10.0 ,  	-0.20, 0.5 }	,//518
    {15000.0,   81250.0,  0.55, 0.8 , 0.7 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.00, 0.3 }	,//519
    {1500.0 ,   3500.0 ,  0.75, 0.9 , 0.5 , 	5, 252.0, 16.5, 60.0 ,   	8.0  ,  	-0.10, 0.5 }	,//520
    {100.0  ,    24.1  ,  0.70, 0.9 , 0.49, 	1,  75.0, 35.0, 15.0 ,   	5.0  ,  	-0.14, 0.5 }	,//521
    {1400.0 ,   2998.3 ,  0.75, 0.9 , 0.5 , 	5, 248.0, 18.4, 60.0 ,   	8.0  ,  	-0.10, 0.5 }	,//522
    {1800.0 ,   4000.0 ,  0.75, 0.85, 0.52,     5, 160.0, 24.0, 10.0 ,   	7.0  ,  	-0.20, 0.45}	,//523
    {1500.0 ,   2500.0 ,  0.70, 0.84, 0.55, 	4, 160.0, 24.0, 5.0  ,   	8.17 ,  	-0.15, 0.3 }	,	//524
    {1000.0 ,   2500.3 ,  0.70, 0.88, 0.55, 	4, 170.0, 35.0, 5.0  ,   	6.1  ,  	-0.20, 0.35}	,	//525
    {5500.0 ,  33187.9 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 ,   	03.17,  	 0.0 , 0.55}	,//526
    {5500.0 ,  33187.9 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 ,   	03.17,  	-0.10, 0.55}	,//527
    {300.0  ,   150.0  ,  0.90, 0.85, 0.48, 	4,  90.0, 18.0, 5.0  ,   	15.0 ,  	-0.04, 0.5 }	,//528
    {800.0  ,   500.0  ,  0.70, 0.80, 0.48, 	3,  60.0, 12.0, 30.0 ,   	6.1  ,  	-0.05, 0.5 }	,//529
    {10000.0,   50000.0,  0.75, 0.85, 0.5 , 	5, 110.0, 35.0, 25.0 ,   	7.0  ,  	-0.40, 0.5 }	,//530
    {800.0  ,   632.7  ,  0.70, 0.80, 0.46, 	3,  60.0, 12.0, 30.0 ,   	6.1  ,  	-0.10, 0.5 }	,//531
    {1700.0 ,   4166.4 ,  0.75, 0.75, 0.46, 	4, 160.0, 20.0, 10.0 ,   	6.0  ,  	-0.14, 0.5 }	,	//532
    {1700.0 ,   4166.4 ,  0.75, 0.75, 0.52, 	4, 160.0, 20.0, 10.0 ,   	6.0  ,  	-0.15, 0.5 }	,	//533
    {5500.0 ,  33187.9 ,  0.75, 0.8 , 0.40,     5, 110.0, 20.0, 20.0 ,   	3.5  ,  	-0.25, 0.55}	,//534
    {2500.0 ,   6000.0 ,  0.72, 0.89, 0.5 , 	5, 230.0, 18.4, 25.0 , 	    7.0  ,  	-0.21, 0.45}	,//535
    {2200.0 ,   6000.0 ,  0.75, 0.92, 0.5 , 	5, 165.0, 24.0, 15.0 , 	    5.0  ,  	-0.22, 0.5 }	,//536
    {1900.0 ,   6333.3 ,  0.85, 0.70, 0.46, 	5, 147.0, 13.0, 80.0 , 	    6.0  ,  	-0.15, 0.45}	,//537
    {800.0  ,   632.7  ,  0.85, 0.80, 0.46, 	4, 170.0, 15.0, 30.0 , 	    6.1  ,  	-0.10, 0.5 }	,//538
    {3800.0 ,  30000.0 ,  0.45, 0.75, 0.5 , 	5, 120.0, 18.0, 5.0  , 	    8.0  ,  	-0.15, 0.5 }	,//539
    {1800.0 ,   4000.0 ,  0.75, 0.80, 0.52, 	5, 160.0, 13.4, 75.0 , 	    8.0  ,  	-0.10, 0.5 }	,//540
    {5500.0 ,  33187.9 ,  0.58, 0.8 , 0.5 , 	4, 110.0, 20.0, 20.0 , 	    03.17,  	-0.25, 0.55}	,//541
    {1400.0 ,   2998.3 ,  0.70, 0.8 , 0.5 , 	5, 266.0, 18.4, 50.0 , 	    8.0  ,  	-0.10, 0.5 }	,//542
    {5500.0 ,  23489.6 ,  0.72, 0.70, 0.46, 	5, 140.0, 14.0, 25.0 , 	    4.5  ,  	-0.24, 0.4 }	,//543
    {1400.0 ,   3000.0 ,  0.75, 0.90, 0.49,     5, 246.0, 15.9, 80.0 , 	    11.0 ,  	-0.12, 0.5 }	,//544
    {3800.0 ,  30000.0 ,  0.45, 0.75, 0.5 , 	5, 120.0, 18.0, 5.0  ,  	8.0  ,  	-0.15, 0.5 }	,//545
    {100.0  ,    50.0  ,  0.70, 0.90, 0.49, 	1,  60.0, 50.0, 10.0 ,  	5.5  ,  	-0.15, 0.5 }	,//546
    {1600.0 ,   4000.0 ,  0.75, 0.85, 0.50, 	5, 305.0, 20.8, 23.0 ,  	10.0 ,  	-0.12, 0.55}	,//547
    {1800.0 ,   4350.0 ,  0.75, 0.85, 0.52, 	5, 183.0, 13.6, 100.0,  	10.0 ,  	-0.17, 0.55}	,//548
    {1400.0 ,   4000.0 ,  0.75, 0.85, 0.52, 	5, 238.0, 15.5, 90.0 ,  	10.0 ,  	-0.17, 0.55}	,//549
    {2500.0 ,   5500.0 ,  0.75, 0.85, 0.55, 	5, 160.0, 30.0, 15.0 ,  	6.2  ,  	-0.25, 0.5 }	,	//550
    {1600.0 ,   3800.0 ,  0.75, 0.70, 0.52,     5, 165.0, 25.0, 20.0 , 	    8.5  ,  	-0.15, 0.4 }	,//551
    {5000.0 ,  10000.0 ,  0.75, 0.7 , 0.46, 	5, 110.0, 24.0, 25.0 ,   	6.4  ,  	-0.18, 0.5 }	,//552
    {1500.0 ,   3400.0 ,  0.7 , 0.8 , 0.5 , 	5, 200.0, 23.0, 5.0  ,   	7.0  ,  	-0.15, 0.5 }	,//553
    {1500.0 ,   4000.0 ,  0.7 , 0.9 , 0.52,     5, 270.0, 19.4, 20.0 ,   	6.0  ,  	-0.24, 0.59}	,//554
    {1000.0 ,   1354.2 ,  1.00, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,   	5.0  ,  	-0.10, 0.5 }	,//555
    {1000.0 ,   1354.2 ,  1.00, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,   	5.0  ,  	-0.10, 0.5 }	,//556
    {1000.0 ,   2500.0 ,  1.00, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,   	5.0  ,  	-0.10, 0.5 }	,//557
    {5500.0 ,  23489.6 ,  0.82, 0.70, 0.46, 	5, 140.0, 14.0, 25.0 ,   	4.5  ,  	-0.25, 0.35}	,//558
    {400.0  ,   400.0  ,  0.70, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,   	5.0  ,  	-0.10, 0.5 }	,//559
    {1000.0 ,   1354.2 ,  1.00, 0.85, 0.5 , 	3, 160.0, 20.0, 30.0 ,   	5.0  ,  	-0.10, 0.5 }	,//560
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//561
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//562
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//563
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//564
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//565
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//566
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//567
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//568
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//569
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//570
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//571
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//572
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//573
    {1800.0 ,   4500.0 ,  0.70, 0.85, 0.5 , 	5, 250.0, 20.0,  5.0 ,   	7.0  ,  	-0.16, 0.5}	,//574
    {2200.0 ,  29333.3 ,  2.30, 15.0, 0.58, 	5, 190.0, 1.7 , 5.0  ,   	0.05 ,  	 0.1 , 0.0 },//575
    {2200.0 ,  20210.7 ,  2.5 , 15.0, 0.65, 	5, 190.0, 2.5 , 5.0  ,   	0.04 ,  	 0.5 , 2.0 },//576
    {5000.0 ,  25520.8 , -1.50, 15.0, 0.45, 	5, 190.0, 0.7 , 5.0  ,   	0.02 ,  	 0.1 , 0.0 },//577
    {3000.0 ,  17312.5 , -4.00, 25.0, 0.50, 	5, 190.0, 0.5 , 5.0  ,   	0.02 ,  	 0.1 , 0.0 },//578
    {2200.0 ,  29333.3 ,  3.00, 15.0, 0.65, 	5, 190.0, 3.0 , 5.0  ,   	0.02 ,  	 0.05, 0.0 },//579
    {2200.0 ,  29333.3 ,  2.20, 12.0, 0.45, 	5, 190.0, 1.4 , 5.0  ,   	0.05 ,  	 0.1 , 0.0 },//580
    {1200.0 ,   6525.0 ,  2.00, 4.2 , 0.70, 	5, 190.0, 1.6 , 5.0  ,   	0.05 ,  	 0.1 , 2.5 },//581
    {800.0  ,  1483.3  ,  3.50, 3.5 , 1.00, 	5, 190.0, 1.2 , 5.0  ,   	0.07 ,  	 0.1 , 0.7 },//582
    {5000.0 , 155520.8 , -3.50, 25.0, 0.40, 	5, 190.0, 0.5 , 5.0  ,   	0.04 ,  	 0.0 , 1.0 },//583
    {3000.0 ,  40000.0 ,  2.00, 15.0, 0.50, 	5, 190.0, 3.0 , 5.0  ,   	0.02 ,  	 0.3 , 1.5 },//584
    {2200.0 ,  20210.7 ,  1.5 , 15.0, 0.65, 	5, 190.0, 1.5 , 5.0  ,   	0.03 ,  	 0.5 , 2.0 },//585
    {5000.0 ,  27083.3 ,  0.83, 45.0, 0.5 , 	1, 200.0,  1.7, 5.0  ,   	0.01 ,  	 0.0 , 2.0 },//586
    {1900.0 ,   4795.9 ,  0.05, 1.0 , 0.5 , 	5, 150.0,  2.0, 5.0  ,   	1.0  ,  	-0.25, 0.5 },	//587
    {5000.0 ,  27083.3 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.20, 0.5 },//588
    {10000.0,   80000.0,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.10, 0.35},	//589
    {5000.0 ,  27083.3 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.05, 0.5 },//590
    {5000.0 ,  20000.0 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.10, 0.9 },//591
    {15000.0,   81250.0,  0.55, 0.8 , 0.7 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.00, 0.3 },//592
    {9000.0 ,  48750.0 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.20, 0.8 },//593
    {25000.0,  438750.0,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.0  ,  	-0.30, 0.5 },//594
    {60000.0, 9000000.0,  1.5 , 0.9 , 0.85,     1, 200.0, 16.0, 5.0  ,   	1.0  ,  	-0.20, 0.3 },//595
    {40000.0, 3000000.0,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.0  ,  	-0.20, 0.5 },//596
    {5000.0 ,  27083.3 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	1.5  ,  	-0.05, 0.2 },//597
    {2500.0 ,   6041.7 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.5 },//598
    {3000.0 ,   7250.0 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.5 },//599
    {5000.0 ,  29270.8 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.5 },//600
    {3500.0 ,   8458.3 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.5 },//601
    {4500.0 ,  26343.7 ,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.5 },//602
    {10000.0,  150000.0,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.15, 0.85},//603
    {15000.0,  200000.0,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.20, 0.9 },//604
    {20000.0,   48333.3,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.10, 0.3 },//605
    {10000.0,   96666.7,  0.75, 0.9 , 0.5 , 	1, 200.0, 16.0, 5.0  ,   	5.0  ,  	-0.15, 0.5 },//606
    {100.0  ,    50.0  ,  0.20, 0.9 , 0.5 , 	1,  75.0,  1.0, 5.0  ,   	0.5  ,  	-0.00, 0.8 },//607
    {100.0  ,    24.1  ,  1.10, 0.75, 0.50, 	1,  75.0, 35.0, 5.0  ,   	5.5  ,  	-0.08, 0.5 },//608
    {100.0  ,    24.1  ,  1.10, 0.75, 0.50, 	1,  75.0, 35.0, 5.0  ,   	5.5  ,  	-0.08, 0.5 }//609
};

stock st_CreateVehicle(model_id, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawn_delay, addsiren=0, action_type=VEHICLE_ACTION_TYPE_NONE, action_id=VEHICLE_ACTION_ID_NONE)
{
    new model = model_id-400;

	model_id = CreateVehicle(model_id , x, y, z, angle, color1, color2, respawn_delay, addsiren, action_type, action_id);

    if(sizeof setting_vehicle-1 >= model && model_id != INVALID_VEHICLE_ID)
    {
        SetVehicleMass(model_id, setting_vehicle[model][V_MASS]);                
        SetVehicleMassTurn(model_id, setting_vehicle[model][V_TURN_MASS]);  
        SetVehicleAcceleration(model_id, setting_vehicle[model][V_ACCELERATION]);  
        SetVehicleTractionCoef(model_id, setting_vehicle[model][V_TRACTION_COEF]);  
        SetVehicleTractionLoss(model_id, setting_vehicle[model][V_TRACTION_LOSS]);  
        SetVehicleTractionBias (model_id, setting_vehicle[model][V_TRACTION_BIAS]);  
        SetVehicleGear(model_id, floatround(setting_vehicle[model][V_GEAR]));  
        SetVehicleBrakeCoef(model_id, setting_vehicle[model][V_BRAKE_COEF]);  
        SetVehicleSuspensionBias(model_id, setting_vehicle[model][V_SUSPINSION_BIAS]);  
        SetVehicleSuspensionLower(model_id, setting_vehicle[model][V_SUSPINSION_LOWER]);  
        SetVehicleEngInert(model_id, setting_vehicle[model][V_ENG_INERT]);  
        SetVehicleMaxSpeed(model_id, setting_vehicle[model][V_MAX_SPEED]);
    }

    return model_id;
}
#if defined _ALS_CreateVehicle
    #undef CreateVehicle
#else
    #define _ALS_CreateVehicle
#endif
#define CreateVehicle st_CreateVehicle

stock SetVehicleStageDefault(veh)
{
    new model = GetVehicleModel(veh)-400;

    if(sizeof setting_vehicle-1 >= model && veh != INVALID_VEHICLE_ID)
    {
        SetVehicleMass(veh, setting_vehicle[model][V_MASS]);                
        SetVehicleMassTurn(veh, setting_vehicle[model][V_TURN_MASS]);  
        SetVehicleAcceleration(veh, setting_vehicle[model][V_ACCELERATION]);  
        SetVehicleTractionCoef(veh, setting_vehicle[model][V_TRACTION_COEF]);  
        SetVehicleTractionLoss(veh, setting_vehicle[model][V_TRACTION_LOSS]);  
        SetVehicleTractionBias  (veh, setting_vehicle[model][V_TRACTION_BIAS]);  
        SetVehicleGear(veh, floatround(setting_vehicle[model][V_GEAR]));  
        SetVehicleBrakeCoef(veh, setting_vehicle[model][V_BRAKE_COEF]);  
        SetVehicleSuspensionBias(veh, setting_vehicle[model][V_SUSPINSION_BIAS]);  
        SetVehicleSuspensionLower(veh, setting_vehicle[model][V_SUSPINSION_LOWER]);  
        SetVehicleEngInert(veh, setting_vehicle[model][V_ENG_INERT]);  
        SetVehicleMaxSpeed(veh, setting_vehicle[model][V_MAX_SPEED]);
    }
    return 1;
}

new stage_vehicle[MAX_VEHICLES], name_stage[4][12] = {"Comfort+", "Sport", "Sport+", "Drift"};

cmd:stage(playerid)
{
    if(GetPlayerVehicleID(playerid) == INVALID_VEHICLE_ID)
        return SendClientMessage(playerid, -1, "Вы должны быть в транспорте");

    new string[248], veh = GetPlayerVehicleID(playerid), model = GetVehicleModel(veh)-400;

    if(GetVehicleData(veh, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_OWNABLE_CAR) 
        return SendClientMessage(playerid, -1, "Этот транспорт не личный.");

    new id = GetVehicleData(veh, V_ACTION_ID);

    if(id == -1) return SendClientMessage(playerid, -1, "Этот транспорт не личный.");

    new a[10] = "{FF0000}»", b[10] = "{FF0000}»", c[10] = "{FF0000}»", d[10] = "{FF0000}»";  
    if(GetOwnableCarData(id, OC_COMFORT_PL)) format(a, sizeof a, "{00FF00}»");
    if(GetOwnableCarData(id, OC_SPORT)) format(b, sizeof b, "{00FF00}»");
    if(GetOwnableCarData(id, OC_SPORT_PL)) format(c, sizeof c, "{00FF00}»");
    if(GetOwnableCarData(id, OC_DRIFT)) format(d, sizeof d, "{00FF00}»");
    

    new stage[4][24];

    for(new i;i < 4;i ++)
    { 
        if(stage_vehicle[veh] == i+1)
        {
            format(string, sizeof string, "{00FF00}Включен");
            strcat(stage[i], string);
        }
        else
        {
            format(string, sizeof string, "{FF0000}Отключен");
            strcat(stage[i], string);
        }
    }
    
    format(
        string, sizeof string,
        "%s {FFFFFF}Stage 1\t\t\t%s\n"\
        "%s {FFFFFF}Stage 2\t\t\t%s\n"\
        "%s {FFFFFF}Stage 3\t\t\t%s\n", a, stage[0], b, stage[1], c, stage[2]
    );

       if(sizeof setting_vehicle <= model || model <= -1)
        return SendClientMessage(playerid, -1, "На ваш транспорт нельзя поставить прошивки.");

    Dialog(playerid, 4646, DIALOG_STYLE_LIST, "Прошивки", string, "Включить", "Выйти");

    return 1;  
}

stock stage_DestroyVehicle(vehicleid)
{
   // SetVehicleStageDefault(vehicleid);
    stage_vehicle[vehicleid] = 0;
	return DestroyVehicle(vehicleid);
}
#if defined _ALS_DestroyVehicle
    #undef DestroyVehicle
#else
    #define _ALS_DestroyVehicle
#endif
#define DestroyVehicle stage_DestroyVehicle

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 4646)
    {
        if(response)
        {
            new veh = GetPlayerOwnableCar(playerid), id = GetVehicleData(veh, V_ACTION_ID);

            if(veh == INVALID_VEHICLE_ID || id == -1)
                return SendClientMessage(playerid, -1, "Вы должны быть в транспорте");
            
            switch(listitem+1)
            {
                case 1:if(!GetOwnableCarData(id, OC_COMFORT_PL)) return SendClientMessage(playerid, -1, "На этом транспорте не установлен {FFFF00}Stage 1");
                case 2:if(!GetOwnableCarData(id, OC_SPORT)) return SendClientMessage(playerid, -1, "На этом транспорте не установлен {FFFF00}Stage 2");
                case 3:if(!GetOwnableCarData(id, OC_SPORT_PL)) return SendClientMessage(playerid, -1, "На этом транспорте не установлен {FFFF00}Stage 3");
                case 4:if(!GetOwnableCarData(id, OC_DRIFT)) return SendClientMessage(playerid, -1, "На этом транспорте не установлен {FFFF00}Drift");
            }

            if(stage_vehicle[veh] == listitem+1) 
            {           
                new string[124];
                format(string, sizeof string, "Вы успешно отключили прошивку: {FFFF00}%s", name_stage[listitem]);
                SendClientMessage(playerid, -1, string); 
                SetVehicleStage(veh, 0);
                return 1;
            }

            if(SetVehicleStage(veh, listitem+1))
            {
                new string[124];
                format(string, sizeof string, "Вы успешно включили прошивку: {FFFF00}%s", name_stage[listitem]);
                SendClientMessage(playerid, -1, string);

            }
            else SendClientMessage(playerid, -1, "На ваш транспорт нельзя поставить прошивку.");
        }
    }
    #if defined stage_OnDialogResponse
return stage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse stage_OnDialogResponse
#if defined stage_OnDialogResponse
forward stage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnGameModeInit()
{
    print("[W_SYSTEM] Система прошивок загружена.");
    SetTimer("CREATE_DATABASE_STAGE", 4000, false);

    CreateTextDrawStage();
    // 3D-текст техцентра создаётся в основном OnGameModeInit, чтобы не было двойной надписи.

    #if defined stage_OnGameModeInit
        return stage_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit stage_OnGameModeInit
#if defined stage_OnGameModeInit
    forward stage_OnGameModeInit();
#endif


public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(GetVehicleData(vehicleid, V_ACTION_TYPE) == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
    {
        new idx = GetVehicleData(vehicleid, V_ACTION_ID), string[158] = "Прошивки которые присутствуют в транспорте:{FFFF00}";

        if(GetOwnableCarData(idx, OC_COMFORT_PL) || GetOwnableCarData(idx, OC_SPORT) ||GetOwnableCarData(idx, OC_SPORT_PL) || GetOwnableCarData(idx, OC_DRIFT))
        {
            if(GetOwnableCarData(idx, OC_COMFORT_PL)) strcat(string, " Comfort+");
            if(GetOwnableCarData(idx, OC_SPORT)) strcat(string, " Sport");
            if(GetOwnableCarData(idx, OC_SPORT_PL)) strcat(string, " Sport+");
            if(GetOwnableCarData(idx, OC_DRIFT)) strcat(string, " Drift");

            SendClientMessage(playerid, -1, "Напишите /stage чтобы выбрать прошивку");
            SendClientMessage(playerid, -1, string);
        }
    }


    #if defined stage_OnPlayerEnterVehicle
        return stage_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnPlayerEnterVehicle
    #undef OnPlayerEnterVehicle
#else
    #define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle stage_OnPlayerEnterVehicle
#if defined stage_OnPlayerEnterVehicle
    forward stage_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#endif

stock SetVehicleStage(vehicle, stage)
{
    new model = GetVehicleModel(vehicle)-400;

    if(sizeof setting_vehicle <= model || model <= -1)
        return 0;

    if(stage_vehicle[vehicle] == stage)
        return 2;

    stage_vehicle[vehicle] = stage;

    new Float:inert = setting_vehicle[model][V_ENG_INERT];
    switch(stage)
    {
        case 0:SetVehicleStageDefault(vehicle);
        case 1:
        {
            SetVehicleAcceleration(vehicle, setting_vehicle[model][V_ACCELERATION]+2.0);  
            SetVehicleTractionCoef(vehicle, setting_vehicle[model][V_TRACTION_COEF]+0.04); 

            if(0.8 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.9) SetVehicleTractionLoss  (vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.05); 
            else if(0.7 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.8) SetVehicleTractionLoss(vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.09);  

            if(0.6 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.65) SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]-0.02); 
            else if(0.4 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.5)SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]+0.02);   
            SetVehicleBrakeCoef(vehicle, setting_vehicle[model][V_BRAKE_COEF]+0.5);

            if(inert >= 8*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-4.0);       
            else if(inert >= 6*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-2.0);       
            else if(inert >= 5*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-1.5);
            else if(inert >= 4*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-1.0);
            else if(inert >= 2*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-0.5);
            else if(inert >= 4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-0.5);

            SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]+5.0);       
        }
        case 2:
        {
            SetVehicleAcceleration(vehicle, setting_vehicle[model][V_ACCELERATION]+8.0);  
            SetVehicleTractionCoef(vehicle, setting_vehicle[model][V_TRACTION_COEF]+0.04); 

            if(0.8 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.9) SetVehicleTractionLoss  (vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.05); 
            else if(0.7 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.8) SetVehicleTractionLoss(vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.1);  

            if(0.6 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.65) SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]-0.03); 
            else if(0.4 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.5)SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]+0.03);  

            SetVehicleBrakeCoef(vehicle, setting_vehicle[model][V_BRAKE_COEF]+1.0);  

            if(inert >= 8*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-8.0);       
            else if(inert >= 6*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-6.0);       
            else if(inert >= 5*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-5.0);
            else if(inert >= 4*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-4.0);
            else if(inert >= 2*4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-2.0);
            else if(inert >= 4)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-1.0);

            SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]+10.0);    
            if(setting_vehicle[model][V_GEAR] > 1)SetVehicleGear (vehicle, floatround(setting_vehicle[model][V_GEAR])-1);     
        }
        case 3:
        {
            SetVehicleAcceleration(vehicle, setting_vehicle[model][V_ACCELERATION]+13.0); 
             
            SetVehicleTractionCoef(vehicle, setting_vehicle[model][V_TRACTION_COEF]+0.05);  

            if(0.8 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.9) SetVehicleTractionLoss  (vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.07); 
            else if(0.7 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.8) SetVehicleTractionLoss(vehicle, setting_vehicle[model][V_TRACTION_LOSS]+0.12);  
            
            if(0.6 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.65) SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]-0.05); 
            else if(0.4 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.5)SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]+0.05);  

            SetVehicleBrakeCoef(vehicle, setting_vehicle[model][V_BRAKE_COEF]+1.5);  

            if(inert >= 8*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-8.0);       
            else if(inert >= 6*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-6.0);       
            else if(inert >= 5*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-5.0);
            else if(inert >= 4*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-4.0);
            else if(inert >= 2*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-2.0);

            SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]+20.0);

            if(setting_vehicle[model][V_GEAR] > 1)SetVehicleGear (vehicle, floatround(setting_vehicle[model][V_GEAR])-1);  
        }
        case 4:
        {
            SetVehicleAcceleration(vehicle, setting_vehicle[model][V_ACCELERATION]+15.0);  
            if(setting_vehicle[model][V_TRACTION_COEF] >= 0.05) SetVehicleTractionCoef(vehicle, setting_vehicle[model][V_TRACTION_COEF]-0.05);  

            if(0.8 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.9) SetVehicleTractionLoss  (vehicle, setting_vehicle[model][V_TRACTION_LOSS]-0.5); 
            else if(0.7 <= setting_vehicle[model][V_TRACTION_LOSS] <= 0.8) SetVehicleTractionLoss(vehicle, setting_vehicle[model][V_TRACTION_LOSS]-0.3);  
            
            if(0.6 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.65) SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]+0.05); 
            else if(0.4 <= setting_vehicle[model][V_TRACTION_BIAS] <= 0.5)SetVehicleTractionBias  (vehicle, setting_vehicle[model][V_TRACTION_BIAS]+0.15);  

            if(setting_vehicle[model][V_GEAR] > 1) SetVehicleGear (vehicle, floatround(setting_vehicle[model][V_GEAR])-1);   
            SetVehicleBrakeCoef(vehicle, setting_vehicle[model][V_BRAKE_COEF]+1.0);  

            if(inert >= 8*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-8.0);       
            else if(inert >= 6*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-6.0);       
            else if(inert >= 5*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-5.0);
            else if(inert >= 4*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-4.0);
            else if(inert >= 2*3)SetVehicleEngInert(vehicle, setting_vehicle[model][V_ENG_INERT]-2.0); 

            new Float:speed = setting_vehicle[model][V_MAX_SPEED];
            if(speed >= 80*2)SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]-80.0);       
            else if(speed >= 60*2)SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]-60.0);       
            else if(speed >= 50*2)SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]-50.0);
            else if(speed >= 40*2)SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]-40.0);
            else if(speed >= 20*2)SetVehicleMaxSpeed(vehicle, setting_vehicle[model][V_MAX_SPEED]-20.0);
        }
    }

    return 1;
}


stock CreateTextDrawStage()
{
    stg_TD[0] = TextDrawCreate(487.6665, 150.4369, "txd:brtuning2service"); // пусто
    TextDrawTextSize(stg_TD[0], 144.0000, 170.0000);
    TextDrawAlignment(stg_TD[0], 1);
    TextDrawColor(stg_TD[0], -1);
    TextDrawBackgroundColor(stg_TD[0], 255);
    TextDrawFont(stg_TD[0], 4);
    TextDrawSetProportional(stg_TD[0], 0);
    TextDrawSetShadow(stg_TD[0], 0);
    TextDrawSetSelectable(stg_TD[0], false);

    stg_TD[1] = TextDrawCreate(12.0833, 152.9257, "txd:brtuning4info"); // пусто
    TextDrawTextSize(stg_TD[1], 157.0000, 212.0000);
    TextDrawAlignment(stg_TD[1], 1);
    TextDrawColor(stg_TD[1], -1);
    TextDrawBackgroundColor(stg_TD[1], 255);
    TextDrawFont(stg_TD[1], 4);
    TextDrawSetProportional(stg_TD[1], 0);
    TextDrawSetShadow(stg_TD[1], 0);

    stg_TD[2] = TextDrawCreate(186.3332, 389.7853, "txd:brtuning4cost"); // пусто
    TextDrawTextSize(stg_TD[2], 265.0000, 24.0000);
    TextDrawAlignment(stg_TD[2], 1);
    TextDrawColor(stg_TD[2], -1);
    TextDrawBackgroundColor(stg_TD[2], 255);
    TextDrawFont(stg_TD[2], 4);
    TextDrawSetProportional(stg_TD[2], 0);
    TextDrawSetShadow(stg_TD[2], 0);

    stg_TD[3] = TextDrawCreate(186.9998, 419.6520, "txd:brtuning2buy"); // пусто
    TextDrawTextSize(stg_TD[3], 116.0000, 24.0000);
    TextDrawAlignment(stg_TD[3], 1);
    TextDrawColor(stg_TD[3], -1);
    TextDrawBackgroundColor(stg_TD[3], 255);
    TextDrawFont(stg_TD[3], 4);
    TextDrawSetProportional(stg_TD[3], 0);
    TextDrawSetShadow(stg_TD[3], 0);
    TextDrawSetSelectable(stg_TD[3], true);

    stg_TD[4] = TextDrawCreate(334.6665, 419.6520, "txd:brtuning2exit"); // пусто
    TextDrawTextSize(stg_TD[4], 116.0000, 24.0000);
    TextDrawAlignment(stg_TD[4], 1);
    TextDrawColor(stg_TD[4], -1);
    TextDrawBackgroundColor(stg_TD[4], 255);
    TextDrawFont(stg_TD[4], 4);
    TextDrawSetProportional(stg_TD[4], 0);
    TextDrawSetShadow(stg_TD[4], 0);
    TextDrawSetSelectable(stg_TD[4], true);
}


public OnPlayerConnect(playerid)
{
    CreatePlayerTextDrawStage(playerid);
    #if defined stage_OnPlayerConnect
        return stage_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect stage_OnPlayerConnect
#if defined stage_OnPlayerConnect
    forward stage_OnPlayerConnect(playerid);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == stg_TD[4])
    {
        new vehicleid = GetPlayerOwnableCar(playerid);
        
        SetPlayerPos(playerid,-413.453979,1026.380371,13.042777);
              SetPlayerVirtualWorld(playerid, 0);
              SetPlayerInterior(playerid,0);
              
          SetVehiclePos(vehicleid, -413.453979,1026.380371,12.042777);
          SetVehicleZAngle(vehicleid, 356.280181);
          SetVehicleVirtualWorld(vehicleid, 0);
          LinkVehicleToInterior(vehicleid,0);
          
          PutPlayerInVehicle(playerid, vehicleid, 0);
          
	      SetCameraBehindPlayer(playerid);
	                TogglePlayerControllable(playerid, true);
        ShowHud(playerid);

        if(player_select_stage[playerid]) {for(new i;i <14;i++) PlayerTextDrawHide(playerid, stg_PTD[playerid][i]);
        for(new i;i < sizeof stg_TD;i++) TextDrawHideForPlayer(playerid, stg_TD[i]);}
        else {
            for(new i;i<5;i++) PlayerTextDrawHide(playerid, stg_PTD[playerid][i]);
            
            TextDrawHideForPlayer(playerid, stg_TD[0]);
            TextDrawHideForPlayer(playerid, stg_TD[2]);
            TextDrawHideForPlayer(playerid, stg_TD[3]);
            TextDrawHideForPlayer(playerid, stg_TD[4]);
        }

        player_select_stage[playerid] = 0;
    }
    if(clickedid == stg_TD[3])
    {
        new veh = GetPlayerOwnableCar(playerid), id = GetVehicleData(veh, V_ACTION_ID);

        if(GetPlayerOwnableCar(playerid) != veh) return SendClientMessage(playerid, -1, "Покупать прошивки возможно только в личном транспорте.");
    
        new string[124];

        new price = player_price_stage[playerid];

        switch(player_select_stage[playerid])
        {
            case 0:SendClientMessage(playerid, -1, "Сначало выберите прошивку.");
            case 1:
            {
                if(GetOwnableCarData(id, OC_COMFORT_PL)) return SendClientMessage(playerid, -1, "На транспорте уже установлен Stage 1");

                if(GetPlayerMoneyEx(playerid) >= price)
                {
                    SetOwnableCarData(id, OC_COMFORT_PL, 1);

                    mysql_format(mysql, string, sizeof string, "UPDATE ownable_cars SET comfort = 1 WHERE id = %d", GetOwnableCarData(id, OC_SQL_ID));
                    
                }
                else SendClientMessage(playerid, -1, "У вас не хватает для покупки прошивки");
            }
            case 2:
            {
                if(GetOwnableCarData(id, OC_SPORT)) return SendClientMessage(playerid, -1, "На транспорте уже установлен Stage 2");

                if(GetPlayerMoneyEx(playerid) >= price)
                {
                    SetOwnableCarData(id, OC_SPORT, 1);

                    
                    mysql_format(mysql, string, sizeof string, "UPDATE ownable_cars SET sport = 1 WHERE id = %d", GetOwnableCarData(id, OC_SQL_ID));
                    
                }
                else SendClientMessage(playerid, -1, "У вас не хватает для покупки прошивки");
            }
            case 3:
            {
                if(GetOwnableCarData(id, OC_SPORT_PL)) return SendClientMessage(playerid, -1, "На транспорте уже установлен Stage 3");

                if(GetPlayerMoneyEx(playerid) >= price)
                {
                    SetOwnableCarData(id, OC_SPORT_PL, 1);

                    mysql_format(mysql, string, sizeof string, "UPDATE ownable_cars SET sport_plus = 1 WHERE id = %d", GetOwnableCarData(id, OC_SQL_ID));
                    
                }
                else SendClientMessage(playerid, -1, "У вас не хватает для покупки прошивки");
            }
            case 4:
            {
                if(GetOwnableCarData(id, OC_DRIFT)) return SendClientMessage(playerid, -1, "На транспорте уже установлен Drift");

                if(GetPlayerMoneyEx(playerid) >= price)
                {
                    SetOwnableCarData(id, OC_DRIFT, 1);

                    mysql_format(mysql, string, sizeof string, "UPDATE ownable_cars SET drift = 1 WHERE id = %d", GetOwnableCarData(id, OC_SQL_ID));
                    
                }
                else SendClientMessage(playerid, -1, "У вас не хватает для покупки прошивки");
            }
        }

        if(1 <= player_select_stage[playerid] <= 4) 
        {
            new query[324], price_b = price * 50 / 100;
            if(GetBusinessData(business_stage, B_PRODS) > 0) AddBusinessData(business_stage, B_BALANCE, +, (price_b * 75) / 100);
            format(query, sizeof query, "UPDATE accounts a,business b SET a.money=%d,b.products=%d,b.balance=%d WHERE a.id=%d AND b.id=%d", GetPlayerMoneyEx(playerid)-price_b, GetBusinessData(business_stage, B_PRODS) > 0 ? GetBusinessData(business_stage, B_PRODS)-1 : 0, GetBusinessData(business_stage, B_BALANCE), GetPlayerAccountID(playerid), GetBusinessData(business_stage, B_SQL_ID));
            mysql_query(mysql, query, false);

            if(!mysql_errno())
            {
                GivePlayerMoneyEx(playerid, -price);
                mysql_query(mysql, string);
                if(mysql_errno()) return SendClientMessage(playerid, -1, "Error SQL-query | Update ownable_cars");
                
                mysql_format(mysql, query, sizeof query, "INSERT INTO business_profit (bid,uid,uip,time,money,view) VALUES (%d,%d,'%e',%d,%d,%d)", GetBusinessData(business_stage, B_SQL_ID), GetPlayerAccountID(playerid), GetPlayerIpEx(playerid), gettime(), price_b, IsBusinessOwned(business_stage));
                mysql_query(mysql, query, false);

                //new name_stage[4][9] = {"Comfort+", "Sport", "Sport+", "Drift"};
                format(string, sizeof string, "Вы купили {FFFF00}%s{FFFFFF} за {FFFF00}%d {FFFFFF}рублей. Спасибо за покупку!", 
                name_stage[player_select_stage[playerid]-1], player_price_stage[playerid]);
                SendClientMessage(playerid, -1, string);

                new old = player_select_stage[playerid];
                PlayerTextDrawSetString(playerid, stg_PTD[playerid][old-1], stage_td_select[old-1][0]);
                player_select_stage[playerid] = 0;
                for(new i = 5; i < 14;i++) PlayerTextDrawHide(playerid, stg_PTD[playerid][i]);

                TextDrawHideForPlayer(playerid, stg_TD[1]);
            }
        }
    }
    #if defined stage_OnPlayerClickTextDraw
        return stage_OnPlayerClickTextDraw(playerid, clickedid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw stage_OnPlayerClickTextDraw
#if defined stage_OnPlayerClickTextDraw
    forward stage_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    for(new i;i < 4;i++) {if(playertextid == stg_PTD[playerid][i]){ ShowPanelStage(playerid, i); break; }}
	#if defined stage_OnPlayerClickPlayerTextD
		return stage_OnPlayerClickPlayerTextD(playerid, playertextid);
	#else
	    return 0;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTextD
    #undef OnPlayerClickPlayerTextDraw
#else
    #define _ALS_OnPlayerClickPlayerTextD
#endif
#if defined stage_OnPlayerClickPlayerTextD
	forward stage_OnPlayerClickPlayerTextD(playerid, PlayerText:playertextid);
#endif
#define	OnPlayerClickPlayerTextDraw stage_OnPlayerClickPlayerTextD

new td_param_stage[4][2] =
{
    {5, 11},
    {6, 10},
    {7, 12},
    {8, 13}
};

stock ShowPanelStage(playerid, panel)
{
    if(GetPlayerOwnableCar(playerid) == INVALID_VEHICLE_ID || player_select_stage[playerid] == panel+1) return 1;

    if(player_select_stage[playerid] != 0) PlayerTextDrawSetString(playerid, stg_PTD[playerid][player_select_stage[playerid]-1], stage_td_select[player_select_stage[playerid]-1][0]);
    else{
        for(new i; i < 14;i++) PlayerTextDrawShow(playerid, stg_PTD[playerid][i]);
        TextDrawShowForPlayer(playerid, stg_TD[1]);
    }

    player_select_stage[playerid] = panel+1;
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][panel], stage_td_select[panel][1]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][4], stage_td_p_select[panel]);

    new vehicleid = GetPlayerOwnableCar(playerid), model = GetVehicleModel(vehicleid)-400, rubl[14], price = GetVehicleInfo(model, VI_PRICE), percent;

    switch(panel)
    {
        case 0:percent = price * 6 / 100;
        case 1:percent = price * 12 / 100;
        case 2:percent = price * 24 / 100;
        case 3:percent = price * 5 / 100;
    } 

    format(rubl, sizeof rubl, "%d_РУБ", percent);
    player_price_stage[playerid] = percent;
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][9], rubl);

    new Float:acceleration = setting_vehicle[model][V_ACCELERATION], Float:traction = setting_vehicle[model][V_TRACTION_COEF], 
    Float:brake = setting_vehicle[model][V_BRAKE_COEF], default_c[4] = {1, ...}, after[4] = {1, ...};

    for(new e, Float:c_n;e < 4;e ++)
    {
        switch(e)
        {
            case 0:c_n = acceleration;
            case 1:c_n = traction;
            case 2:c_n = brake;
            case 3:c_n = 0.01;
        }

        for(new i;i < 10;i ++)
        {
            if(count_setting[e][i] <= c_n) default_c[e] = i+1;
            else break;
        }
    }

    for(new i; i < 4;i ++)
    {
        switch(panel)
        {
            case 0:after[i] = 1+default_c[i];
            case 1:after[i] = 2+default_c[i];
            case 2:after[i] = 3+default_c[i];
            case 3:if(default_c[i] >= 2) after[i] = default_c[i] -1;
        }
    }
    
    for(new w, text_after[22], text_default[22];w < 4;w ++)
    {
        if(1 <= default_c[w] <= 10) format(text_default, sizeof text_default, "txd:brtuning2stage%d", default_c[w]);
        else format(text_default, sizeof text_default, "txd:brtuning2stage10");

        if(1 <= after[w] <= 10) format(text_after, sizeof text_after, "txd:brtuning4lstage%d", after[w]);
        else format(text_after, sizeof text_after, "txd:brtuning4lstage10");

        PlayerTextDrawSetString(playerid, stg_PTD[playerid][td_param_stage[w][0]], text_after);
        PlayerTextDrawSetString(playerid, stg_PTD[playerid][td_param_stage[w][1]], text_default);
    }

    return 1;
}
/*stock ShowPanelStage(playerid, panel)
{
    new vehicle = GetPlayerVehicleID(playerid), model = GetVehicleModel(vehicle)-400;
    if(vehicle == INVALID_VEHICLE_ID || vehicle != GetPlayerOwnableCar(playerid)) return 0;

    if(player_select_stage[playerid] &&  player_select_stage[playerid]-1 == panel) return 0;
    new old = player_select_stage[playerid];
    if(old != 0) PlayerTextDrawSetString(playerid, stg_PTD[playerid][old-1], stage_td_select[old-1][0]);

    new Float:acceleration = setting_vehicle[model][V_ACCELERATION], Float:traction = setting_vehicle[model][V_TRACTION_COEF], 
    Float:brake = setting_vehicle[model][V_BRAKE_COEF], text_default[5][24], text_after[5][24];

    for(new e, Float:rabotay_suka, text[24], dotext[24], default_s, after; e < 4; e++)
    {
        default_s = 1;
        after = 1;

        switch(e)
        {
            case 0:rabotay_suka = acceleration;
            case 1:rabotay_suka = traction;
            case 2:rabotay_suka = brake;
            case 3:rabotay_suka = 0.1;
        }

        for(new i;i < 10;i++) { if(count_setting[e][i] <= rabotay_suka) default_s = i+1; }

        if(default_s != 0 && e != 3)
        {
            switch(panel)
            {
                case 0:after = 1+default_s;
                case 1:after = 2+default_s;
                case 2:after = 3+default_s;
                case 3:if(default_s >= 2) after = default_s -1;
            }
        }

        if(1 <= after <= 10) format(text, sizeof text, "txd:brtuning2stage%d", after);
        else format(text, sizeof text, "txd:brtuning2stage10");
        strcat(text_after[e], text);
        if(1 <= default_s <= 10) format(dotext, sizeof dotext, "txd:brtuning4lstage%d", default_s);
        else format(dotext, sizeof dotext, "txd:brtuning4lstage10");
        strcat(text_default[e], dotext);
    }

    player_select_stage[playerid] = panel+1;

    PlayerTextDrawSetString(playerid, stg_PTD[playerid][panel], stage_td_select[panel][1]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][4], stage_td_p_select[panel]);
    new price = GetVehicleInfo(model, VI_PRICE), percent;

    switch(panel)
    {
        case 0:percent = price * 6 / 100;
        case 1:percent = price * 12 / 100;
        case 2:percent = price * 24 / 100;
        case 3:percent = price * 5 / 100;
    } 

    player_price_stage[playerid] = percent;
    new string[18];
    format(string, sizeof string, "%d_РУБ", percent);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][9], string);

    if(old == 0)
    {
        for(new i; i < 4;i++)
        {
            PlayerTextDrawShow(playerid, stg_PTD[playerid][td_param_stage[i][0]]);
            PlayerTextDrawShow(playerid, stg_PTD[playerid][td_param_stage[i][1]]);
        }
        
        TextDrawShowForPlayer(playerid, stg_TD[1]);
    }

    PlayerTextDrawSetString(playerid, stg_PTD[playerid][5], text_default[0]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][6], text_default[1]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][7], text_default[2]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][8], text_default[3]);

    PlayerTextDrawSetString(playerid, stg_PTD[playerid][11], text_after[0]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][10], text_after[1]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][12], text_after[2]);
    PlayerTextDrawSetString(playerid, stg_PTD[playerid][13], text_after[3]);
    
    return 1;
}
*/
   /*for(new e; e < 4; e++) //лень стало делать такую реализацию
    {
        if(e == 2) continue;

        switch(e)
        {
            case 0:rabotay_suka = setting_vehicle[model][V_ACCELERATION];
            case 1:rabotay_suka = setting_vehicle[model][V_TRACTION_COEF];
            case 3:rabotay_suka = setting_vehicle[model][V_BRAKE_COEF];
        }

        for(new i;i < 10;i++)
        {
            if(count_setting[e][i] >= rabotay_suka) continue;
            else if(i == 9)
            {
                format(text, sizeof text, "txd:brtuning2stage10");
                format(dotext, sizeof dotext, "txd:brtuning4lstage10");
            }
            else
            {
                if(rabotay_suka <= count_setting[e][9]) format(text, sizeof text, "txd:brtuning2stage%d", i+1);
                else format(text, sizeof text, "txd:brtuning2stage10");

                if(panel == 3 && e == 1)
                {
                    if(i >= 2) format(dotext, sizeof dotext, "txd:brtuning4lstage%d", i);
                    else format(dotext, sizeof dotext, "txd:brtuning4lstage1");
                }
                else
                {
                    if(i+panel <= 10) format(dotext, sizeof dotext, "txd:brtuning4lstage%d", i+1+panel);
                    else format(dotext, sizeof dotext, "txd:brtuning4lstage10");
                }
            }
        }

        PlayerTextDrawSetString(playerid, stg_PTD[playerid][td_param_stage[e][0]], dotext);
        PlayerTextDrawSetString(playerid, stg_PTD[playerid][td_param_stage[e][1]], text);
    }*/

/*public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
            new vehicleid = GetPlayerVehicleID(playerid), model = GetVehicleModel(vehicleid)-400;

            if(GetPlayerOwnableCar(playerid) == vehicleid)
            {
                new bool:to_area;

                for(new i;i<3;i++) 
                {
                    if(IsPlayerInRangeOfPoint(playerid, 6.5, coord_enter_stage[i][0], coord_enter_stage[i][1], coord_enter_stage[i][2]))
                    {
                        to_area = true;
                        break;
                    }
                }
                if(PRESSED(KEY_CROUCH) && to_area)
                {
                    if(sizeof setting_vehicle <= model || model <= -1)
                    return SendClientMessage(playerid, -1, "На ваш транспорт нельзя поставить прошивку.");
                    new world = playerid + 1000;

                    if(!IsPlayerInVehicle(playerid, GetPlayerOwnableCar(playerid))) return SendClientMessage(playerid, -1, ""USC"Вы должны быть за рулем своего автомобиля");
		  new vehicleID = GetPlayerVehicleID(playerid);
		  for(new i = 0; i < MAX_PLAYERS; i++)
		  {
          if(IsPlayerInVehicle(i, vehicleID))

          SetPlayerVirtualWorld(i, 101);
          SetPlayerInterior(i, 1);
          SetCameraBehindPlayer(i);
          }
          new veh;
          
          veh = GetPlayerOwnableCar(playerid);
          SetVehiclePos(veh, 996.368164,999.465759,1001.141540);
          SetVehicleZAngle(veh, 273.919586);
          SetVehicleVirtualWorld(veh, 101);
          SetPlayerVirtualWorld(playerid, 101);
          
          SetPlayerCameraPos(playerid, 1001.483154,1002.271240,1000.906738);
	  	          SetPlayerCameraLookAt(playerid, 997.090454,999.934204,1001.398864);
          
          LinkVehicleToInterior(veh,1);
          SetPlayerInterior(playerid,1);

                    for(new i; i < 4;i++) PlayerTextDrawSetString(playerid, stg_PTD[playerid][i], stage_td_select[i][0]);
                    
                    for(new i;i<5;i++) PlayerTextDrawShow(playerid, stg_PTD[playerid][i]);
                    
                    TextDrawShowForPlayer(playerid, stg_TD[0]);
                    TextDrawShowForPlayer(playerid, stg_TD[2]);
                    TextDrawShowForPlayer(playerid, stg_TD[3]);
                    TextDrawShowForPlayer(playerid, stg_TD[4]);

                    PlayerTextDrawSetString(playerid, stg_PTD[playerid][9], "0000_РУБ");
                    PlayerTextDrawShow(playerid, stg_PTD[playerid][9]);
                    
                    HideHud(playerid);
                    SelectTextDraw(playerid, -1);

                    SetTimerEx("tpplayertex2", 700, false, "d", playerid);
                    player_select_stage[playerid] = 0;
                    return 1;
                }
            }
        }
    }
    #if defined stage_OnPlayerKeyStateChange
        return stage_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange stage_OnPlayerKeyStateChange
#if defined stage_OnPlayerKeyStateChange
    forward stage_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif
*/
public:CREATE_DATABASE_STAGE()
{
    new string[124];

    mysql_format(mysql, string, sizeof string, "SELECT * FROM ownable_cars WHERE comfort AND sport AND sport_plus AND drift");
    mysql_query(mysql, string, false);

    if(mysql_errno())
    {
        mysql_query(mysql, "ALTER TABLE `ownable_cars` ADD `comfort` INT NOT NULL AFTER `model_id`, ADD `sport` INT NOT NULL AFTER `comfort`, ADD `sport_plus` INT NOT NULL AFTER `sport`, ADD `drift` INT NOT NULL AFTER `sport_plus`", false);

        if(!mysql_errno()) printf("ALTER TABLE 'ownable_cars' complete");
        else for(new i;i < 4;i++) printf("ERROR ALTER TABLE STAGE");
    }

    mysql_format(mysql, string, sizeof string, "SELECT * FROM business WHERE type=20");
    new Cache:cache = mysql_query(mysql, string, true);

    new rows = cache_num_rows();
    if(!rows)
    {
        mysql_query(mysql, "INSERT INTO `business` (`id`, `owner_id`, `name`, `improvements`, `products`, `prod_price`, `balance`, `rent_time`, `price`, `rent_price`, `type`, `interior`, `enter_price`, `enter_music`, `lock`, `x`, `y`, `z`, `exit_x`, `exit_y`, `exit_z`, `exit_angle`, `eviction`) VALUES (NULL, '', 'Техничейский центр', '', '5000', '1000', '0', '0', '10000000', '15000', '20', '0', '0', '0', '0', '-432.157836', '1005.208435', '12.149999', '0.0', '0.0', '0.0', '0.0', '0')", false);

        if(!mysql_errno()) printf("INSERT INTO `business`complete");
        else for(new i;i < 4;i++) printf("ERROR INSERT INTO `business`");
        
        return GameModeExit();
    }
    else{
        for(new i; i < g_business_loaded;i++)
        {
            if(GetBusinessData(i, B_TYPE) != 20) continue;
            business_stage = i;
            break;
        }
    }

    cache_delete(cache);

    return 1;
}

stock CreatePlayerTextDrawStage(playerid)
{
    stg_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 506.0000, 164.1257, "txd:brtuning4stg1"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][0], 114.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][0], 0);
    PlayerTextDrawSetSelectable(playerid, stg_PTD[playerid][0], true);

    stg_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 505.3334, 202.2888, "txd:brtuning4stg2"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][1], 114.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][1], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][1], 0);
    PlayerTextDrawSetSelectable(playerid, stg_PTD[playerid][1], true);

    stg_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 506.0000, 240.0368, "txd:brtuning4stg3"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][2], 114.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][2], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][2], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][2], 0);
    PlayerTextDrawSetSelectable(playerid, stg_PTD[playerid][2], true);

    stg_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 9999.0000, 9999.7850, "txd:brtuning4stg4"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][3], 114.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][3], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][3], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][3], 0);
    PlayerTextDrawSetSelectable(playerid, stg_PTD[playerid][3], true);

    stg_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 9999.3332, 9999.8445, "txd:brtuning4nstage4"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][4], 265.0000, 24.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][4], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][4], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][4], 0);
    //PlayerTextDrawSetSelectable(playerid, stg_PTD[playerid][4], true);

    stg_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 21.6665, 297.0742, "55555555555555555"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][5], 134.0000, 11.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][5], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][5], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][5], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][5], 0);

    stg_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 22.0832, 210.4814, "66666666666666"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][6], 134.0000, 11.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][6], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][6], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][6], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][6], 0);

    stg_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 22.0832, 340.6299, "777777777"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][7], 134.0000, 11.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][7], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][7], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][7], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][7], 0);

    stg_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 22.0832, 253.5186, "88888888888888"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][8], 134.0000, 11.0000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][8], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][8], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][8], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][8], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][8], 0);

    stg_PTD[playerid][9] = CreatePlayerTextDraw(playerid, 385.6665, 395.3333, "0000"); // пусто
    PlayerTextDrawLetterSize(playerid, stg_PTD[playerid][9], 0.2477, 1.1684);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][9], 3);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][9], 8388863);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][9], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][9], 1);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][9], 1);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][9], 0);

    stg_PTD[playerid][10] = CreatePlayerTextDraw(playerid, 22.4998, 211.0000, "1000000000000"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][10], 134.0000, 10.1000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][10], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][10], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][10], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][10], 0);

    stg_PTD[playerid][11] = CreatePlayerTextDraw(playerid, 22.0832, 297.5927, "1111111111111111111"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][11], 134.0000, 10.1000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][11], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][11], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][11], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][11], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][11], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][11], 0);

    stg_PTD[playerid][12] = CreatePlayerTextDraw(playerid, 22.4998, 341.1484, "12222222222222222"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][12], 134.0000, 10.1000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][12], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][12], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][12], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][12], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][12], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][12], 0);

    stg_PTD[playerid][13] = CreatePlayerTextDraw(playerid, 22.4998, 254.0371, "13333333333333333"); // пусто
    PlayerTextDrawTextSize(playerid, stg_PTD[playerid][13], 134.0000, 10.1000);
    PlayerTextDrawAlignment(playerid, stg_PTD[playerid][13], 1);
    PlayerTextDrawColor(playerid, stg_PTD[playerid][13], -1);
    PlayerTextDrawBackgroundColor(playerid, stg_PTD[playerid][13], 255);
    PlayerTextDrawFont(playerid, stg_PTD[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, stg_PTD[playerid][13], 0);
    PlayerTextDrawSetShadow(playerid, stg_PTD[playerid][13], 0);

    return 1;
}

cmd:carpass(playerid, params[])
{
	if(!strlen(params))
		return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /carpass [ID-игрока]");

    if(GetPlayerVehicleID(playerid) != GetPlayerOwnableCar(playerid)) return SendClientMessage(playerid, -1, "Вы должны быть в своём транспорте");

    extract params -> new to_player;

    new string[124];
    format(string, sizeof string, "{0091FF}Игрок %s предлагает показать тех.паспорт на машину", GetPlayerNameEx(playerid));
    SendClientMessage(to_player, -1, string);

    format(string, sizeof string, "{0091FF}Вы предложили %s показать тех.паспорт на машину", GetPlayerNameEx(playerid));
    SendClientMessage(playerid, -1, string);

    ShowNotification(to_player, 4, "Посмотреть тех.паспорт", 5, "/showcar_p_ass", ">>");
    SetPVarInt(to_player, "show_carpass", playerid);
    return 1;
}

cmd:showcar_p_ass(playerid)
{
    new to_player = GetPVarInt(to_player, "show_carpass");

    if(GetPlayerVehicleID(to_player) != GetPlayerOwnableCar(to_player)) return SendClientMessage(playerid, -1, "Игрок должен быть в своём транспорте");

    new string[424], vehicleid = GetPlayerVehicleID(to_player), idx = GetVehicleData(vehicleid, V_ACTION_ID), model = GetVehicleModel(vehicleid) - 400;
    format(string, sizeof string, 
    "{FFFFFF}Владелец: \t\t\t\t\t{FFFF00}%s\n"\
    "{FFFFFF}Транспорт: \t\t\t\t\t{FFFF00}%s\n"\
    "{FFFFFF}Номер: \t\t\t\t\t{FFFF00}%s\n"\
    "{FFFFFF}Пробег: \t\t\t\t\t{FFFF00}%d км.\n"\
    "{FFFFFF}Гос.стоимость: \t\t\t\t\t{FFFF00}%d руб.\n"\
    "{FFFFFF}Прошивка Stage 1: \t\t\t\t\t{FFFF00}%s\n"\
    "{FFFFFF}Прошивка Stage 2: \t\t\t\t\t{FFFF00}%s\n"\
    "{FFFFFF}Прошивка Stage 3: \t\t\t\t\t{FFFF00}%s\n", 
    GetPlayerNameEx(to_player), GetVehicleInfo(model, VI_NAME), GetOwnableCarData(idx, OC_NUMBER), 
    floatround(GetVehicleData(vehicleid, V_MILEAGE), floatround_ceil), GetVehicleInfo(model, VI_PRICE),
    GetOwnableCarData(idx, OC_COMFORT_PL) ? ("Есть") : ("Нет"),
    GetOwnableCarData(idx, OC_SPORT) ? ("Есть") : ("Нет"),
    GetOwnableCarData(idx, OC_SPORT_PL) ? ("Есть") : ("Нет")
    );

    Dialog(playerid, -1, DIALOG_STYLE_LIST, "{FFD900}Тех. паспорт", string, "Закрыть", "");

    return 1;
}