stock ShowTuneShowPlayerDialog(playerid)
{
	show_dialog(playerid, D_ATUNE, DIALOG_STYLE_LIST, !""c_server"Автосервис {afafaf}[Тюнинг]", !"1. Перекрасить элементы\n2. Установить нитро\n3. Винилы\n4. Неон\n5. Страбоскопы\n6. Смена цвета фар\n7. Тонировка", !"Далее", !"Выехать");
    return 1;
}

stock SaveVehicleTuning(playerid)
{
    new index = GetPlayerVehicleID(playerid) - 1;

    new tunning[150];

    format(tunning, sizeof(tunning), "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
    veh_info[index][v_tuning][0], 
    veh_info[index][v_tuning][1], veh_info[index][v_tuning][2],
    veh_info[index][v_tuning][3], veh_info[index][v_tuning][4],
    veh_info[index][v_tuning][5], veh_info[index][v_tuning][6], 
    veh_info[index][v_tuning][7], veh_info[index][v_tuning][8],
    veh_info[index][v_tuning][9], veh_info[index][v_tuning][10], 
    veh_info[index][v_tuning][11], veh_info[index][v_tuning][12], 
    veh_info[index][v_tuning][13], veh_info[index][v_tuning][13],
    veh_info[index][v_tuning][14]);

    format(stringer, sizeof(stringer), "UPDATE `users_vehicles` SET `v_tuning` = '%s' WHERE `v_id` = '%d'", tunning, veh_info[index][v_id]);
    print(stringer);

    return mysql_function_query(sql_connection, stringer, false, "", "");
}
stock ChangeVinil(playerid, numberr)
{
    new vehId = GetPlayerVehicleID(playerid) - 1;
    
    vinylid[vehId] = numberr;
    
    SetVinylOnCar(playerid, vehId, numberr);
    
    ChangeVehicleColor(vehId, 1, 1);
    
    return 1;
}

stock DeleteVinil(playerid)
{
    new vehId = GetPlayerVehicleID(playerid) - 1;
    
    vinylid[vehId] = 0;
    
    SetVinylOnCar(playerid, vehId, 0);
    
    ChangeVehicleColor(vehId, veh_info[GetPlayerVehicleID(playerid) - 1][v_color][0], veh_info[GetPlayerVehicleID(playerid) - 1][v_color][1]);
    
    return 1;
}
CMD:ptune(playerid)
{
    if((IsPlayerInRangeOfPoint(playerid, 2.5, pos_tuning [ 0 ] [ 0 ], pos_tuning [ 0 ] [ 1 ], pos_tuning [ 0 ] [ 2 ])
    || IsPlayerInRangeOfPoint(playerid, 2.5, pos_tuning [ 1 ] [ 0 ], pos_tuning [ 1 ] [ 1 ], pos_tuning [ 1 ] [ 2 ])
    || IsPlayerInRangeOfPoint(playerid, 2.5, pos_tuning [ 2 ] [ 0 ], pos_tuning [ 2 ] [ 1 ], pos_tuning [ 2 ] [ 2 ])
    || IsPlayerInRangeOfPoint(playerid, 2.5, pos_tuning [ 3 ] [ 0 ], pos_tuning [ 3 ] [ 1 ], pos_tuning [ 3 ] [ 2 ])) && GetPlayerState(playerid) == 2) // Заехать в тюнинг
    {
        if(GetVehicleFreeSeat(GetPlayerVehicleID(playerid) - 1) == -1) return SendClientMessage(playerid, -1, !"{afafaf}Для начала высадите всех пассажиров.");

        SetPVarInt(playerid, "playerTune", 0);
        SetVehiclePos(GetPlayerVehicleID(playerid) - 1, -201.4523,165.3822,1201.0000);
        SetVehicleZAngle(GetPlayerVehicleID(playerid) - 1, 269.3929);
        SetPlayerVirtualWorld(playerid, playerid + 1);

        SetCameraBehindPlayer(playerid);
        SetVehicleVirtualWorld(GetPlayerVehicleID(playerid) - 1, playerid + 1);

        ShowTuneShowPlayerDialog(playerid);

        TogglePlayerControllable(playerid, false);
    }
    else SendClientMessage(playerid, -1, !"{afafaf}Вы находитесь далеко от бокса.");
    return 1;
}

stock load_tuning()
{
    for(new i = 0; i < 4; i ++)
    {
        CreateDynamicPickup ( 1239, 23, pos_tuning [ i ] [ 0 ], pos_tuning [ i ] [ 1 ], pos_tuning [ i ] [ 2 ], -1, -1 ) ;
        CreateDynamic3DTextLabel(""c_server"Тюнинг\n{FFFFFF}Посигнальте {afafaf}[или введите: /ptune]", -1, pos_tuning [ i ] [ 0 ], pos_tuning [ i ] [ 1 ], pos_tuning [ i ] [ 2 ], 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1);
    }
}
stock Tuning_dialogs (playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case D_ATUNE:
        {
            new vehicleid = GetPlayerVehicleID(playerid) - 1;

            if(vehicleid == INVALID_VEHICLE_ID)
            {
                return -1;
            }

            if(response)
            {
                switch(listitem)
                {
	                case 0: show_dialog(playerid, d_tuning_1, DIALOG_STYLE_LIST, !""c_server"Перекраска элементов", !"1. Перекрасить кузов\n2. Перекрасить колёса", !"Далее", !"Назад");
	                case 1: show_dialog(playerid, d_tuning_2, DIALOG_STYLE_LIST, !""c_server"Установка нитро", !"1. Nitro X2\n2. Nitro X5\n3. Nitro X10", !"Установить", !"Назад");
					case 2: show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
					case 3: show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
					case 4: show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
					case 5: ShowMenuLightsColor(playerid);
                    case 6: show_dialog(playerid, d_tuning_6, DIALOG_STYLE_LIST, !""c_server"Тонировка",  !"1. Лобовое стекло\n2. Средние стекла\n3. Заднее стекло", !"Выбрать", !"Назад" ) ;
                }
            }
            else
            {
                if(GetPlayerVehicleID(playerid) - 1 == INVALID_VEHICLE_ID) return SpawnPlayer(playerid);
                new Randomc = RandomEx(0, 4);
                switch(Randomc)
                {
                    case 0:
                    {
                        SetVehiclePos(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 0 ] [ 0 ], pos_tuning [ 0 ] [ 1 ], pos_tuning [ 0 ] [ 2 ]);
                        SetVehicleZAngle(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 0 ] [ 3 ]);
                    }
                    case 1:
                    {
                        SetVehiclePos(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 1 ] [ 0 ], pos_tuning [ 1 ] [ 1 ], pos_tuning [ 1 ] [ 2 ]);
                        SetVehicleZAngle(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 1 ] [ 3 ]);
                    }
                        case 2:
                    {
                        SetVehiclePos(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 2 ] [ 0 ], pos_tuning [ 2 ] [ 1 ], pos_tuning [ 2 ] [ 2 ]);
                        SetVehicleZAngle(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 2 ] [ 3 ]);
                    }
                        case 3:
                    {
                        SetVehiclePos(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 3 ] [ 0 ], pos_tuning [ 3 ] [ 1 ], pos_tuning [ 3 ] [ 2 ]);
                        SetVehicleZAngle(GetPlayerVehicleID(playerid) - 1, pos_tuning [ 3 ] [ 3 ]);
                    }
                }
                SetCameraBehindPlayer(playerid);
                LinkVehicleToInterior(GetPlayerVehicleID(playerid) - 1, 0);
                SetVehicleVirtualWorld(GetPlayerVehicleID(playerid) - 1, 0);
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SaveVehicleTuning(playerid);
                TogglePlayerControllable(playerid, true);
                DeletePVar(playerid, "playerTune");
            }

        }
        case d_tuning_1:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);
            switch(listitem)
            {
                case 0:
                {
                    stringer1 [ 0 ] = EOS;
                    stringer [ 0 ] = EOS;

                    for(new idx; idx < 128; idx ++)
                    {
                        format(stringer1, 15, "{%06x}%d | ", VehicleColoursTableRGBA[idx]>>> 8, idx);
                        strcat(stringer, stringer1);
                        if(!(idx % 10)) strcat(stringer, "\n");
                    }
                    strcat(stringer,"\n{FFFFFF}Введите число в окошко ниже \nПример: 10");
                    show_dialog(playerid, d_tuning_7, DIALOG_STYLE_INPUT, ""c_server"Перекраска кузова", stringer, "Покрасить", "Отмена");
                }
                case 1:
                {
                    stringer1 [ 0 ] = EOS;
                    stringer [ 0 ] = EOS;

                    for(new idx; idx < 128; idx ++)
                    {
                    format(stringer1, 15, "{%06x}%d | ", VehicleColoursTableRGBA[idx]>>> 8, idx);
                    strcat(stringer, stringer1);
                    if(!(idx % 10)) strcat(stringer, "\n");
                    }
                    strcat(stringer,"\n{FFFFFF}Введите число в окошко ниже \nПример: 10");
                    show_dialog(playerid, d_tuning_8, DIALOG_STYLE_INPUT, ""c_server"Перекраска колёс",
                    stringer,
                    "Покрасить", "Отмена");
                }
            }
        }
        case d_tuning_7:
        {
            if(!response)
            {
                SetCameraBehindPlayer(playerid);
                ShowTuneShowPlayerDialog(playerid);
                return 1;
            }
            if(p_info[playerid][money] >= 30_000)
            {
                new color1 = strval(inputtext), fmt_text[256],
                idx = GetPVarInt(playerid, "ownablecar_id");

                if(!(-1 <= color1 <= 128))
                {
                    SendClientMessage(playerid, 0xCECECEFF, "Цвет транспорт от 0 до 255");
                    new all_colors_str[1808], color_str[15];

                    for(new idxx; idxx < 128; idxx ++)
                    {
                        format(color_str, sizeof color_str, "{%06x}%d | ", VehicleColoursTableRGBA[idxx]>>> 8, idxx);
                        strcat(all_colors_str, color_str);
                        if(!(idxx % 10)) strcat(all_colors_str, "\n");
                    }
                    strcat(all_colors_str,"\n{FFFFFF}Введите число в окошко ниже \nПример: 10");
                    show_dialog(playerid, d_tuning_7, DIALOG_STYLE_INPUT,""c_server"Перекраска кузова",
                    all_colors_str,
                    "Покрасить", "Отмена");

                    return 1;
                }

                veh_info[GetPlayerVehicleID(playerid) - 1][v_color][0] = color1;
                ChangeVehicleColor(GetPlayerVehicleID(playerid) - 1, veh_info[GetPlayerVehicleID(playerid) - 1][v_color][0], veh_info[GetPlayerVehicleID(playerid) - 1][v_color][1]);

                p_info[playerid][money] -= 30000;

                mysql_format(sql_connection, fmt_text, sizeof fmt_text, "UPDATE `users_vehicles` SET `v_color_1` = '%d' WHERE `v_id` = '%d' LIMIT 1", color1, idx);
                mysql_tquery(sql_connection, fmt_text);

                SetCameraBehindPlayer(playerid);
                ShowTuneShowPlayerDialog(playerid);
            }
            else
            {
                SendClientMessage(playerid, 0xCECECEFF, "У Вас нет столько денег: 30000 $.");
                ShowTuneShowPlayerDialog(playerid);
            }
        }
        case d_tuning_8:
        {
            if(!response)
            {
                SetCameraBehindPlayer(playerid);
                ShowTuneShowPlayerDialog(playerid);
                return 1;
            }
            if(p_info[playerid][money] >= 30_000)
            {
                new color2 = strval(inputtext), fmt_text[256],
                idx = GetPVarInt(playerid, "ownablecar_id");

                if(!(-1 <= color2 <= 128))
                {
                    SendClientMessage(playerid, 0xCECECEFF, "Цвет транспорт от 0 до 255");
                    new all_colors_str[1808], color_str[15];

                    for(new idxx; idxx < 128; idxx ++)
                    {
                        format(color_str, sizeof color_str, "{%06x}%d | ", VehicleColoursTableRGBA[idxx]>>> 8, idxx);
                        strcat(all_colors_str, color_str);
                        if(!(idxx % 10)) strcat(all_colors_str, "\n");
                    }
                    strcat(all_colors_str,"\n{FFFFFF}Введите число в окошко ниже \nПример: 10");
                    show_dialog(playerid, d_tuning_8, DIALOG_STYLE_INPUT,""c_server"Перекраска колёс",
                    all_colors_str,
                    "Покрасить", "Отмена");

                    return 1;
                }
                veh_info[GetPlayerVehicleID(playerid) - 1][v_color][1] = color2;
                ChangeVehicleColor(GetPlayerVehicleID(playerid) - 1, veh_info[GetPlayerVehicleID(playerid) - 1][v_color][0], veh_info[GetPlayerVehicleID(playerid) - 1][v_color][1]);
                p_info[playerid][money] -= 30000;

                mysql_format(sql_connection, fmt_text, sizeof fmt_text, "UPDATE `users_vehicles` SET `v_color_2` = '%d' WHERE `v_id` = '%d' LIMIT 1", color2, idx);
                mysql_tquery(sql_connection, fmt_text);

                SetCameraBehindPlayer(playerid);
                ShowTuneShowPlayerDialog(playerid);
            }
            else
            {
                SendClientMessage(playerid, 0xCECECEFF, "У Вас нет столько денег: 30000 $.");
                ShowTuneShowPlayerDialog(playerid);
            }
        }
        case d_tuning_2:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);
            switch(listitem)
            {
                case 0: AddVehicleComponent(GetPlayerVehicleID(playerid) - 1, Nitro[0][0]), SendClientMessage(playerid, -1, !"{afafaf}Нитро X2 успешно установлено");
                case 1: AddVehicleComponent(GetPlayerVehicleID(playerid) - 1, Nitro[1][0]), SendClientMessage(playerid, -1, !"{afafaf}Нитро X5 успешно установлено");
                case 2: AddVehicleComponent(GetPlayerVehicleID(playerid) - 1, Nitro[2][0]), SendClientMessage(playerid, -1, !"{afafaf}Нитро X10 успешно установлено");
            }
            ShowTuneShowPlayerDialog(playerid);
        }
        case d_tuning_3:
		{
		    if(response)
		    {
				switch(listitem)
				{
				    case 0:
				    {
						if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_vinil) != 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас уже установлен винил, удалите его!");

						    return show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
						}

						show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");
						SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Выберите подходящий винил!");

						SetPVarInt(playerid, "VINILL", 0);
						ChangeVinil(playerid, GetPVarInt(playerid, "VINILL"));
				    }
				    case 1:
				    {
				        if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_vinil) == 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы не устанавливали винилы!");

						    return show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
						}

						show_dialog(playerid, d_tuning_10, DIALOG_STYLE_MSGBOX, !""c_server"Снос винилов", !"{ffffff}Вы точно хотите снести винилы с вашего ТС?\n\nВернуть данное действие будет невозможно", !"Выбрать", !"Назад");
				    }
				}
		    }
		    else ShowTuneShowPlayerDialog(playerid);
		}
	    case d_tuning_9:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    if(GetPVarInt(playerid, "VINILL") >= 55)
	                    {
	                        SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы просмотрели последний винил!");

	                        return show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");
	                    }

	                    show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");

	                    SetPVarInt(playerid, "VINILL", GetPVarInt(playerid, "VINILL")+1);
	                }
					case 1:
					{
	                    if(GetPVarInt(playerid, "VINILL") <= 1)
	                    {
	                        SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы находитесь на первом виниле!");

	                        return show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");
	                    }

	                    show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");

	                    SetPVarInt(playerid, "VINILL", GetPVarInt(playerid, "VINILL")-1);
					}
					case 2:
					{
						new str_for[140];

						format(str_for, sizeof str_for, "{ffffff}Вы действительно хотите потратить "c_server"4.000.000 $. {ffffff}\nна винил под номером: %i№?", GetPVarInt(playerid, "VINILL"));
						show_dialog(playerid, d_tuning_11, DIALOG_STYLE_MSGBOX, !""c_server"Покупка винила", str_for, !"Купить", !"Назад");
					}
	            }
	            ChangeVinil(playerid, GetPVarInt(playerid, "VINILL"));
	        }
			else show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
	    }
	    case d_tuning_11:
	    {
	        if(response)
	        {
	            if(p_info[playerid][money] < 4000000)
				{
					new str_for[140];

					format(str_for, sizeof str_for, "{ffffff}Вы действительно хотите потратить "c_server"4.000.000 $. {ffffff}\nна винил под номером: %i№?", GetPVarInt(playerid, "VINILL"));
					show_dialog(playerid, d_tuning_11, DIALOG_STYLE_MSGBOX, !""c_server"Покупка винила", str_for, !"Купить", !"Назад");

					return SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас не хватает на данную услугу!");
				}
                veh_info[GetPlayerVehicleID(playerid) - 1][v_vinil] = GetPVarInt(playerid, "VINILL")+1;

	            give_money(playerid, -4000000);
	            SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно купили новый винил!");

                save_vinil(playerid);

	            show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
	        }
	        else show_dialog(playerid, d_tuning_9, DIALOG_STYLE_LIST, !""c_server"Установка винилов", !"{ffffff}1. Следующий винил\n2. Предыдущий винил\n3. Выбрать винил", !"Выбрать", !"Назад");
	    }
	    case d_tuning_10:
	    {
			if(response)
			{
                veh_info[GetPlayerVehicleID(playerid) - 1][v_vinil] = 0;

			    show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");

			    DeleteVinil(playerid);
			    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно снесли винилы!");
                save_vinil(playerid);
			}
			else show_dialog(playerid, d_tuning_3, DIALOG_STYLE_LIST, !""c_server"Винилы", !"{ffffff}1. Установить винилы\n2. Убрать винилы", !"Выбрать", !"Назад");
	    }
        case d_tuning_4:
	    {
	        if(response)
	        {
				switch(listitem)
				{
					case 0:
					{
						if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_neon) != 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас уже установлен неон, удалите его!");

						    return show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
						}

						show_dialog(playerid, d_tuning_12, DIALOG_STYLE_LIST, !""c_server"Выбор цвета", !"{ffffff}1. Голубой\n2. Красный\n3. Зелёный\n4. Белый\n5. Розовый\n6. Жёлтый", !"Выбрать", !"Назад");
					}
					case 1:
					{
						if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_neon) == 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас не установлен неон, установите его перед удалением!");

						    return show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
						}

						show_dialog(playerid, d_tuning_13, DIALOG_STYLE_MSGBOX, !""c_server"Удаление неона", !"{ffffff}Вы действительно хотите удалить неон?\n\nДанное действие необратимое!", !"Выбрать", !"Назад");
					}
				}
	        }
			else ShowTuneShowPlayerDialog(playerid);
	    }
	    case d_tuning_12:
	    {
	        if(response)
	        {
	            SetPVarInt(playerid, "LastItem", listitem);

	            show_dialog(playerid, d_tuning_14, DIALOG_STYLE_MSGBOX, !""c_server"Покупка неона", !"{ffffff}Вы действительно хотите потратить "c_server"2.000.000 $?", !"Купить", !"Назад");
	        }
	        else show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
	    }
	    case d_tuning_14:
	    {
	        if(response)
	        {
         		if(p_info[playerid][money] < 2000000)
				{
                    show_dialog(playerid, d_tuning_14, DIALOG_STYLE_MSGBOX, !""c_server"Покупка неона", !"{ffffff}Вы действительно хотите потратить "c_server"2.000.000 $?", !"Купить", !"Назад");

					return SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас не хватает на данную услугу!");
				}

				give_money(playerid, -2000000);
				
                show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
				SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно приобрели неон!");

				SetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_neon, GetPVarInt(playerid, "LastItem"));
                save_neon(playerid);

	            switch(GetPVarInt(playerid, "LastItem"))
	            {
	                case 0:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 0);
                    }
                    case 1:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 1);
                    }
                    case 2:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 2);
                    }
                    case 3:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 3);
                    }
                    case 4:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 4);
                    }
                    case 5:
                    {
                        CreateNeonVehicle(GetPlayerVehicleID(playerid) - 1, 5);
                    }
	            }
	        }
			else show_dialog(playerid, d_tuning_12, DIALOG_STYLE_LIST, !""c_server"Выбор цвета", !"{ffffff}1. Голубой\n2. Красный\n3. Зелёный\n4. Белый\n5. Розовый\n6. Жёлтый", !"Выбрать", !"Назад");
	    }
	    case d_tuning_13:
	    {
			if(response)
			{
                DestroyNeonVehicle(GetPlayerVehicleID(playerid) - 1);

			    show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");

			    SetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_neon, 0);
			    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно снесли неон с вашего автомобиля!");
                DeleteVehicleTune(playerid, GetPlayerVehicleID(playerid) - 1, 1);
                save_neon(playerid);
			}
			else show_dialog(playerid, d_tuning_4, DIALOG_STYLE_LIST, !""c_server"Неон", !"{ffffff}1. Установить неон\n2. Убрать неон", !"Выбрать", !"Назад");
	    }
        case d_tuning_5:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
						if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_strab) != 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас уже установлен страбоскоб, удалите его!");

						    return show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
						}

						if (!IsACar(GetPlayerVehicleID(playerid) - 1)) return SendClientMessage(playerid, -1, !"{afafaf}Данный тип транспорта не поддерживает стробоскопы.");

						show_dialog(playerid, d_tuning_15, DIALOG_STYLE_MSGBOX, !""c_server"Установка страбоскопа", !"{ffffff}Вы точно хотите установить страбоскоп на ваш транспорт?\n\nСтоимость страбоскопа: "c_server"5.000.000 долларов!", !"Купить", !"Назад");
	                }
					case 1:
					{
						if(GetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_strab) == 0)
						{
						    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас не установлен страбоскоп, установите его!");

						    return show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
						}

						show_dialog(playerid, d_tuning_16, DIALOG_STYLE_MSGBOX, !""c_server"Удаление страбоскопа", !"{ffffff}Вы точно хотите удалить страбоскоп с вашего транспорта?\n\nСтоимость данной услуги: "c_server"0 долларов!", !"Удалить", !"Назад");
					}
	            }
	        }
	        else ShowTuneShowPlayerDialog(playerid);
	    }
	    case d_tuning_15:
		{
			if(response)
			{
                if(p_info[playerid][money] < 5000000)
                {
                    SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}У Вас не достаточно денег для покупки страбоскопа!");

                    return show_dialog(playerid, d_tuning_15, DIALOG_STYLE_MSGBOX, !""c_server"Установка страбоскопа", !"{ffffff}Вы точно хотите установить страбоскоп на ваш транспорт?\n\nСтоимость страбоскопа: "c_server"5.000.000 долларов!", !"Купить", !"Назад");
                }

                give_money(playerid, -5000000);

                SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно приобрели страбоскоп! Чтобы включить его введите: /lights!");
                SetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_strab, 1);

                save_strobs(playerid);

                show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
			}
			else show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
		}
	    case d_tuning_16:
	    {
	        if(response)
	        {
                SendClientMessage(playerid, -1, !""c_server"[ Информация ] {ffffff}Вы успешно удалили страбоскоп с вашего транспорта!");
                SetOwnableCarData(GetPlayerVehicleID(playerid) - 1, v_strab, 0);

                save_strobs(playerid);

                show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
	        }
	        else show_dialog(playerid, d_tuning_5, DIALOG_STYLE_LIST, !""c_server"Страбоскопы", !"1. Установить страбоскоп\n2.Убрать страбоскоп", !"Выбрать", !"Назад");
	    }
        case d_tuning_20:
        {
            ShowTuneShowPlayerDialog(playerid);
            if(response)
            {
                new vehid = GetPlayerVehicleID(playerid) - 1;
                switch(listitem) 
                {
                    case 0: 
                    {
                        veh_info[vehid][v_lights][0] = 255;
                        veh_info[vehid][v_lights][1] = 0;
                        veh_info[vehid][v_lights][2] = 0;
                        
                    }
                    case 1:
                    {
                        veh_info[vehid][v_lights][0] = 0;
                        veh_info[vehid][v_lights][1] = 255;
                        veh_info[vehid][v_lights][2] = 0;
                    }
                    case 2: 
                    {
                        veh_info[vehid][v_lights][0] = 0;
                        veh_info[vehid][v_lights][1] = 0;
                        veh_info[vehid][v_lights][2] = 255;
                    }
                }
                
                SetHeadlightsColor(playerid, vehid, veh_info[vehid][v_lights][0], veh_info[vehid][v_lights][1], veh_info[vehid][v_lights][2]);
                veh_info[vehid][v_is_lights] = 1;
                save_lights(playerid);
            }
        }
        case d_tuning_6:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);

            switch(listitem)
            {
                case 0:
                {
                    show_dialog(playerid, d_tuning_17, DIALOG_STYLE_INPUT, "Тонировка переднего стекла", "Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;
                }
                case 1:
                {
                    show_dialog(playerid, d_tuning_18, DIALOG_STYLE_INPUT, "Тонировка средних стекл", "Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;
                }
                case 2:
                {
                    show_dialog(playerid, d_tuning_19, DIALOG_STYLE_INPUT, "Тонировка заднего стекла", "Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;
                }
            }
        }
        case d_tuning_17:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);
            
            if(!IsNumeric1(inputtext)) return show_dialog(playerid, d_tuning_17, DIALOG_STYLE_INPUT, "Тонировка переднего стекла", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;

            new colorid = strval(inputtext);

            if(colorid < 1 || colorid > 35) return show_dialog(playerid, d_tuning_17, DIALOG_STYLE_INPUT, "Тонировка переднего стекла", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;

            new vehicleid = GetPlayerVehicleID(playerid) - 1;

            SetVehicleToner(vehicleid, 0, colorid);
            SendClientMessage(playerid, -1, "Вы поставили тонировку на переднее стекло");

            veh_info[vehicleid][v_toner][0] = colorid;
            save_toner(playerid);
            
            return ShowTuneShowPlayerDialog(playerid);
        }
        case d_tuning_18:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);
            
            if(!IsNumeric1(inputtext)) return show_dialog(playerid, d_tuning_18, DIALOG_STYLE_INPUT, "Тонировка средних стекл", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;
            
            new colorid = strval(inputtext);

            if(colorid < 1 || colorid > 35) return show_dialog(playerid, d_tuning_18, DIALOG_STYLE_INPUT, "Тонировка средних стекл", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;

            new vehicleid = GetPlayerVehicleID(playerid) - 1;

            SetVehicleToner(vehicleid, 1, colorid);
            SendClientMessage(playerid, -1, "Вы поставили тонировку на среднее стекло");

            veh_info[vehicleid][v_toner][1] = colorid;
            save_toner(playerid);

            return ShowTuneShowPlayerDialog(playerid);
        }
        case d_tuning_19:
        {
            if(!response) return ShowTuneShowPlayerDialog(playerid);
            
            if(!IsNumeric1(inputtext)) return show_dialog(playerid, d_tuning_19, DIALOG_STYLE_INPUT, "Тонировка заднего стекла", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;
            
            new colorid = strval(inputtext);

            if(colorid < 1 || colorid > 35) return show_dialog(playerid, d_tuning_19, DIALOG_STYLE_INPUT, "Тонировка заднего стекла", "Вы ввели неправильный ид\n*Введите ид тонера от 1 до 35", "Далее", "Назад" ) ;

            new vehicleid = GetPlayerVehicleID(playerid) - 1;

            SetVehicleToner(vehicleid, 2, colorid);
            SendClientMessage(playerid, -1, "Вы поставили тонировку на задние стекло");

            veh_info[vehicleid][v_toner][2] = colorid;
            save_toner(playerid);

            return ShowTuneShowPlayerDialog(playerid);
        }
    }
    return true;
}
stock IsNumeric1(dest[], pos=0)
{
    new is_numeric1 = true;
    do
    {
        switch(dest[pos])
        {
        case '0'..'9': continue;
        default:
            {
                is_numeric1 = false;
                break;
            }
        }
    }
    while(dest[++pos]);

    return is_numeric1;
}
stock save_toner(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid) - 1;

    new sql_string [ 98 ] ;
    mysql_format(sql_connection, sql_string, sizeof sql_string, "UPDATE `users_vehicles` SET `c_toner` = '%d|%d|%d' WHERE `v_id` = '%d' LIMIT 1", 
    veh_info[vehicleid][v_toner][0], veh_info[vehicleid][v_toner][1], veh_info[vehicleid][v_toner][2], veh_info[vehicleid][v_id]);
    mysql_tquery(sql_connection, sql_string);
    return 1;
}
stock save_vinil(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid) - 1;

    new sql_string [ 98 ] ;
    mysql_format(sql_connection, sql_string, sizeof sql_string, "UPDATE `users_vehicles` SET `c_vinil` = '%d' WHERE `v_id` = '%d' LIMIT 1", 
    veh_info[vehicleid][v_vinil], veh_info[vehicleid][v_id]);
    mysql_tquery(sql_connection, sql_string);
    return 1;
}
stock save_strobs(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid) - 1;

    new sql_string [ 98 ] ;
    mysql_format(sql_connection, sql_string, sizeof sql_string, "UPDATE `users_vehicles` SET `c_strobs` = '%d' WHERE `v_id` = '%d' LIMIT 1", 
    veh_info[vehicleid][v_strab], veh_info[vehicleid][v_id]);
    mysql_tquery(sql_connection, sql_string);
    return 1;
}
stock save_lights(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid) - 1;

    new sql_string [ 124 ] ;
    mysql_format(sql_connection, sql_string, sizeof sql_string, "UPDATE `users_vehicles` SET `c_lights` = '%d|%d|%d', `c_is_lights` = '%d' WHERE `v_id` = '%d' LIMIT 1", 
    veh_info[vehicleid][v_lights][0], veh_info[vehicleid][v_lights][1], veh_info[vehicleid][v_lights][2], veh_info[vehicleid][v_is_lights], 
    veh_info[vehicleid][v_id]);
    mysql_tquery(sql_connection, sql_string);
    return 1;
}
stock save_neon(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid) - 1;

    new sql_string [ 124 ] ;
    mysql_format(sql_connection, sql_string, sizeof sql_string, "UPDATE `users_vehicles` SET `c_neon` = '%d' WHERE `v_id` = '%d' LIMIT 1", 
    veh_info[vehicleid][v_neon], veh_info[vehicleid][v_id]);
    mysql_tquery(sql_connection, sql_string);
    return 1;
}

stock DeleteVehicleTune(playerid, carnumber, sql = 0)
{
    if(veh_info[carnumber][v_tuning][0] != -1)
    {
        ChangeVehiclePaintjob(GetPlayerVehicleID(playerid) - 1, 3);
        veh_info[carnumber][v_tuning][0] = -1;
    }
    for(new i = 1; i <= 14; i++)
    {
        if(veh_info[carnumber][v_tuning][i] != 0)
        {
            RemoveVehicleComponent(GetPlayerVehicleID(playerid) - 1, veh_info[carnumber][v_tuning][i]);
            veh_info[carnumber][v_tuning][i] = 0;
        }
    }

    if(sql)
    {
        format(stringer, sizeof(stringer), "UPDATE `users_vehicle` SET `v_tuning` = '-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0' WHERE `v_id` = '%d'",veh_info[carnumber][v_id]);
        mysql_function_query(sql_connection, stringer, false, "", "");
    }

    return 1;
}
stock GetNeonType(vehicleid)
{
    return VehicleNeon[vehicleid][NEON_TYPE] - 1;
} 
stock SetNeonType(vehicleid, neontype) 
{
    if(neontype < sizeof(neon_data) && neontype >= NEON_NONE) 
    {
        return VehicleNeon[vehicleid][NEON_TYPE] = neontype + 1; 
    }
    else 
    {
        return 0;
    }
}
stock DestroyNeonVehicle(vehicleid)
{
    DestroyDynamicObject(VehicleNeon[vehicleid][NEON_LEFT]);
    DestroyDynamicObject(VehicleNeon[vehicleid][NEON_RIGHT]);

    VehicleNeon[vehicleid][NEON_LEFT] = 0;
    VehicleNeon[vehicleid][NEON_RIGHT] = 0;

    SetNeonType(vehicleid, NEON_NONE);
}

stock CreateNeonVehicle(vehicleid, neontype)
{
    VehicleNeon[vehicleid][NEON_LEFT] = CreateDynamicObject(neon_data[neontype][neon_objectid], 0, 0, 0, 0, 0, 0);
    VehicleNeon[vehicleid][NEON_RIGHT] = CreateDynamicObject(neon_data[neontype][neon_objectid], 0, 0, 0, 0, 0, 0);

    AttachDynamicObjectToVehicle(VehicleNeon[vehicleid][NEON_LEFT], vehicleid, -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
    AttachDynamicObjectToVehicle(VehicleNeon[vehicleid][NEON_RIGHT], vehicleid, 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);

    SetNeonType(vehicleid, neontype);

    return 1;
}

stock ShowMenuLightsColor(playerid)
{
    new fmt_str[256];
    format(fmt_str, 256, "{ff0000}1. Красный\n{00ff00}2. Зелёный\n{0000ff}3. Синий\n");
    show_dialog(playerid, d_tuning_20, DIALOG_STYLE_LIST, "Выбор цвета фар", fmt_str, "Выбрать", "Назад");
    return;
}
stock SetVinylOnCar(playerid, vehId, numberr)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
    BS_WriteValue(bitstream, PR_UINT32, 0x39);

    BS_WriteValue(bitstream, PR_INT32, numberr);
    BS_WriteValue(bitstream, PR_INT32, vehId);  

    PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);

	return true;
}
stock SetHeadlightsColor(playerid, vehId, r, g, b)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
    BS_WriteValue(bitstream, PR_UINT32, 0x38);

    BS_WriteValue(bitstream, PR_INT32, vehId);
    BS_WriteValue(bitstream, PR_INT32, r);
    BS_WriteValue(bitstream, PR_INT32, g);
    BS_WriteValue(bitstream, PR_INT32, b);

    PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);

	return true;
}