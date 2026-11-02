CMD:aoe(playerid)
{
	show_dialog(playerid, AOED, DIALOG_STYLE_LIST, "{D35400}Редактор", "1. Редактировать объект\n2. Информация", "Далее", "Отмена");

	return 1;

}
stock AOE_SavePlayerAttachedObject(playerid, index)
{
    format(global_string, sizeof global_string, "%d,%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f", gPlayerAttachedObjectModel[playerid][index], gPlayerAttachedObjectBone[playerid][index],

	gPlayerAttachedObjectPos[playerid][index][0],
	gPlayerAttachedObjectPos[playerid][index][1],
	gPlayerAttachedObjectPos[playerid][index][2],

	gPlayerAttachedObjectPos[playerid][index][3],
	gPlayerAttachedObjectPos[playerid][index][4],
	gPlayerAttachedObjectPos[playerid][index][5],

	gPlayerAttachedObjectPos[playerid][index][6],
	gPlayerAttachedObjectPos[playerid][index][7],
	gPlayerAttachedObjectPos[playerid][index][8],
	gPlayerEditorScale[playerid][index]);

	format(global_string, sizeof global_string, "UPDATE `user_attach_coords` SET `Slot%d` = '%s' WHERE `UserID` = %d", index, global_string, p_info[playerid][id]);
	mysql_tquery(sql_connection, global_string);
	return 1;
}
stock hook_SetPlayerAttachedObject(playerid, index, modelid, bone, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0, bool:editor = false)
{
	// send_me_f(playerid, -1, "1 INDEX %d, modelid %d, bone %d, editor %d", index, modelid, bone, editor);
	/*new idex2;

	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
	    if(gPlayerAttachedObjectModel[playerid][i] != 0 && modelid != 0)
	    {
		    if(gPlayerAttachedObjectModel[playerid][i] == modelid)
		    {
		        idex2 = i;
		    }
	  	}
	}

	index = idex2;

	send_me_f(playerid, -1, "2 INDEX %d, modelid %d, bone %d, editor %d", index, modelid, bone, editor);*/

	if(editor == false && gPlayerAttachedObjectModel [ playerid ] [ index ] == modelid ) // && gPlayerAttachedObjectModel[playerid][index] == modelid && (gPlayerAttachedObjectPos[playerid][index][0] + gPlayerAttachedObjectPos[playerid][index][1]) != 0.000
    {
        gPlayerAttachedObjectModel [ playerid ] [ index ] = modelid ; // 05.04.2021
        SetPlayerAttachedObject(playerid, index, modelid, gPlayerAttachedObjectBone[playerid][index], gPlayerAttachedObjectPos[playerid][index][0], gPlayerAttachedObjectPos[playerid][index][1], gPlayerAttachedObjectPos[playerid][index][2], gPlayerAttachedObjectPos[playerid][index][3], gPlayerAttachedObjectPos[playerid][index][4], gPlayerAttachedObjectPos[playerid][index][5], gPlayerAttachedObjectPos[playerid][index][6], gPlayerAttachedObjectPos[playerid][index][7], gPlayerAttachedObjectPos[playerid][index][8]);
        return 1;
    }

	gPlayerAttachedObjectModel[playerid][index] 	= modelid;
	gPlayerAttachedObjectBone[playerid][index]		= bone;

	gPlayerEditObjectTD[playerid][index][0]			=
	gPlayerAttachedObjectPos[playerid][index][0] 	= fOffsetX;

	gPlayerEditObjectTD[playerid][index][1]			=
	gPlayerAttachedObjectPos[playerid][index][1] 	= fOffsetY;

	gPlayerEditObjectTD[playerid][index][2]			=
	gPlayerAttachedObjectPos[playerid][index][2] 	= fOffsetZ;

	gPlayerEditObjectTD[playerid][index][3]			=
	gPlayerAttachedObjectPos[playerid][index][3]	= fRotX;

	gPlayerEditObjectTD[playerid][index][4]			=
	gPlayerAttachedObjectPos[playerid][index][4]	= fRotY;

	gPlayerEditObjectTD[playerid][index][5]			=
	gPlayerAttachedObjectPos[playerid][index][5]	= fRotZ;

	gPlayerEditObjectTD[playerid][index][6]			=
	gPlayerAttachedObjectPos[playerid][index][6]	= fScaleX;

	gPlayerEditObjectTD[playerid][index][7]			=
	gPlayerAttachedObjectPos[playerid][index][7]	= fScaleY;

	gPlayerEditObjectTD[playerid][index][8]			=
	gPlayerAttachedObjectPos[playerid][index][8]	= fScaleZ;

	SetPlayerAttachedObject(playerid, index, modelid, bone, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ, materialcolor1, materialcolor2);

	return 1;
}
ClearAttachData(playerid, index)
{
	gPlayerAttachedObjectModel[playerid][index] 	=
	gPlayerAttachedObjectBone[playerid][index]		= 0;

	gPlayerEditObjectTD[playerid][index][0]			=
	gPlayerAttachedObjectPos[playerid][index][0] 	=

	gPlayerEditObjectTD[playerid][index][1]			=
	gPlayerAttachedObjectPos[playerid][index][1] 	=

	gPlayerEditObjectTD[playerid][index][2]			=
	gPlayerAttachedObjectPos[playerid][index][2] 	=

	gPlayerEditObjectTD[playerid][index][3]			=
	gPlayerAttachedObjectPos[playerid][index][3]	=

	gPlayerEditObjectTD[playerid][index][4]			=
	gPlayerAttachedObjectPos[playerid][index][4]	=

	gPlayerEditObjectTD[playerid][index][5]			=
	gPlayerAttachedObjectPos[playerid][index][5]	=

	gPlayerEditObjectTD[playerid][index][6]			=
	gPlayerAttachedObjectPos[playerid][index][6]	=

	gPlayerEditObjectTD[playerid][index][7]			=
	gPlayerAttachedObjectPos[playerid][index][7]	=

	gPlayerEditObjectTD[playerid][index][8]			=
	gPlayerAttachedObjectPos[playerid][index][8]	=

	/*upd37 - fix*/
	gPlayerEditorScale[playerid][index]				= 0.000;
	/*upd37 - fix*/

	return 1;
}
@__LoadPlayerAttachData(playerid, userID);
@__LoadPlayerAttachData(playerid, userID)
{
	if(!cache_num_rows() && userID != 0)
	{
		format(global_string, sizeof global_string, "INSERT INTO `user_attach_coords` (`UserID`) VALUES (%d)", userID);
		mysql_tquery(sql_connection, global_string);

		return 1;
	}

	new
		field[7],
		slotString[100];

	new
		modelid,
		bone,
		Float:fOffsetX,
		Float:fOffsetY,
		Float:fOffsetZ,
		Float:fRotX,
		Float:fRotY,
		Float:fRotZ,
		Float:fScaleX,
		Float:fScaleY,
		Float:fScaleZ;

	for(new index; index < MAX_PLAYER_ATTACHED_OBJECTS; index++)
	{
		format(field, sizeof field, "Slot%d", index);
		cache_get_field_content(0, field, slotString, sql_connection, sizeof slotString);

		sscanf(slotString, "p<,>ddffffffffff", modelid, bone, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ, gPlayerEditorScale[playerid][index]);

		gPlayerAttachedObjectModel[playerid][index] 	= modelid;
		gPlayerAttachedObjectBone[playerid][index]		= bone;

		gPlayerEditObjectTD[playerid][index][0]			=
		gPlayerAttachedObjectPos[playerid][index][0] 	= fOffsetX;

		gPlayerEditObjectTD[playerid][index][1]			=
		gPlayerAttachedObjectPos[playerid][index][1] 	= fOffsetY;

		gPlayerEditObjectTD[playerid][index][2]			=
		gPlayerAttachedObjectPos[playerid][index][2] 	= fOffsetZ;

		gPlayerEditObjectTD[playerid][index][3]			=
		gPlayerAttachedObjectPos[playerid][index][3]	= fRotX;

		gPlayerEditObjectTD[playerid][index][4]			=
		gPlayerAttachedObjectPos[playerid][index][4]	= fRotY;

		gPlayerEditObjectTD[playerid][index][5]			=
		gPlayerAttachedObjectPos[playerid][index][5]	= fRotZ;

		gPlayerEditObjectTD[playerid][index][6]			=
		gPlayerAttachedObjectPos[playerid][index][6]	= fScaleX;

		gPlayerEditObjectTD[playerid][index][7]			=
		gPlayerAttachedObjectPos[playerid][index][7]	= fScaleY;

		gPlayerEditObjectTD[playerid][index][8]			=
		gPlayerAttachedObjectPos[playerid][index][8]	= fScaleZ;

		slotString[0] = '\0';
	}

	return 1;
}
stock acsedit_dialogs (playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case AOED:
	    {
	    	if(!response) return 1;

	       	switch(listitem)
			{
                case 0:
                {
                	aoe_str[0] = '\0';

                	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
					{
					    if(!IsPlayerAttachedObjectSlotUsed(playerid, i) || !gPlayerAttachedObjectModel[playerid][i])
					    	format(aoe_str, sizeof aoe_str, "%s{D35400}%d.{FFFFFF} | Объекта нет\n", aoe_str, i);

					    else format(aoe_str, sizeof aoe_str, "%s{D35400}%d.{FFFFFF} | %d | %s | Используется\n", aoe_str, i, gPlayerAttachedObjectModel[playerid][i], AttachedObjectBones[gPlayerAttachedObjectBone[playerid][i] - 1]);
					}
					show_dialog(playerid, AOED_EDIT_OBJECT, DIALOG_STYLE_LIST, "Список аксессуаров", aoe_str, "Выбор", "X");

					return 1;
                }
                case 1:
                {
                	show_dialog(playerid, AOED_EDITOR_INFO, DIALOG_STYLE_MSGBOX, "{66CC00}Информация", "{FFFFFF}Добро пожаловать в {66CC00}редактор аксессуаров{fFFFFF}.\nДля редактирования Вам доступно {66CC00}6{fFFFFF} координат:\n\n\
			    	{66CC00}-{FFFFFF} X, Y, Z: Редактирование позициии объекта;\n\
			    	{66CC00}-{FFFFFF} RX, RY, RZ: Редактирование угла объекта;\n\
			    	{66CC00}-{FFFFFF} Step: Изменяет шаг при редактировании объекта{66CC00}*{FFFFFF}.\n\
			    	Если Вы хотитет отменить либо сохранить изменение, нажмите {66CC00}Exit{FFFFFF}.\n\n\
			    	{66CC00}*{fFFFFF} К примеру у Вас шаг равен {66CC00}0.5{fFFFFF}. Тогда при нажатии на кнопки редактора, координата\nВашего акссесуара будет меняться на {66CC00}+/-0.5{fFFFFF}.", "Закрыть", "");
                	return 1;
                }
			}
	    }
        case AOED_EDIT_OBJECT:
	    {
	    	if(!response) return 1;

	    	if(!IsPlayerAttachedObjectSlotUsed(playerid, listitem) || !gPlayerAttachedObjectModel[playerid][listitem])
				return SendClientMessage(playerid, 0xD35400FF, "> {FFFFFF}В данном слоте у Вас нет объекта!");


			gPlayerChooseIndex{playerid} 	= listitem;
			gPlayerUsesEditor{playerid}		= true;

	    	show_dialog(playerid, AOED_EDITOR_INFO, DIALOG_STYLE_MSGBOX, "{66CC00}Информация", "{FFFFFF}Добро пожаловать в {66CC00}редактор аксессуаров{fFFFFF}.\nДля редактирования Вам доступно {66CC00}6{fFFFFF} координат:\n\n\
	    	{66CC00}-{FFFFFF} X, Y, Z: Редактирование позициии объекта;\n\
	    	{66CC00}-{FFFFFF} RX, RY, RZ: Редактирование угла объекта;\n\
	    	{66CC00}-{FFFFFF} Step: Изменяет шаг при редактировании объекта{66CC00}*{FFFFFF}.\n\
	    	Если Вы хотитет отменить либо сохранить изменение, нажмите {66CC00}Exit{FFFFFF}.\n\n\
	    	{66CC00}*{fFFFFF} К примеру у Вас шаг равен {66CC00}0.5{fFFFFF}. Тогда при нажатии на кнопки редактора, координата\nВашего акссесуара будет меняться на {66CC00}+/-0.5{fFFFFF}.", "Закрыть", "");

	    	for(new i = 0; i < sizeof gTD_AttachEditor; i++)
				TextDrawShowForPlayer(playerid, gTD_AttachEditor[i]);

			format(aoe_str, sizeof aoe_str, "Step:_%.2f", gPlayerEditorStep[playerid]);
			PlayerTextDrawSetString(playerid, pTD_AttachEditor[playerid][6], aoe_str);
			PlayerTextDrawShow(playerid, pTD_AttachEditor[playerid][6]);

			format(aoe_str, sizeof aoe_str, "size:_%.2f", gPlayerEditorScale[playerid][listitem]);
			PlayerTextDrawSetString(playerid, pTD_AttachEditor[playerid][7], aoe_str);
			PlayerTextDrawShow(playerid, pTD_AttachEditor[playerid][7]);

			for(new i = 0; i < 6; i++)
			{
				format(aoe_str, sizeof aoe_str, "%s: %.2f", CordName[i], gPlayerEditObjectTD[playerid][listitem][i]);
				PlayerTextDrawSetString(playerid, pTD_AttachEditor[playerid][i], aoe_str);

				PlayerTextDrawShow(playerid, pTD_AttachEditor[playerid][i]);
			}

	    	return 1;
	    }
	    case AOED_EDITOR_INFO: 
        {
            return show_dialog(playerid, d_change_bone, DIALOG_STYLE_LIST, "{66CC00}Изменить кость", "{66CC00}1.{fFFFFF} Позвоночник\n{66CC00}2.{fFFFFF} Голова\n{66CC00}3.{fFFFFF} Левое плечо\n{66CC00}4.{fFFFFF} Правое плечо\n{66CC00}5.{fFFFFF} Левая рука\n{66CC00}6.{fFFFFF} Правая рука\n{66CC00}7.{fFFFFF} Левое предплечье\n{66CC00}8.{fFFFFF} Правое предплечье", "Далее", "Отмена");
        }
        case d_changes:
	    {
	    	if(!response)
	    		return 1;

	    	new
	    		index 	= gPlayerChooseIndex{playerid},
	    		model 	= gPlayerAttachedObjectModel[playerid][index],
	    		bone 	= gPlayerAttachedObjectBone[playerid][index];


	    	if(IsPlayerAttachedObjectSlotUsed(playerid, index))
				RemovePlayerAttachedObject(playerid, index);

			for(new i; i < sizeof gTD_AttachEditor; i++)
				TextDrawHideForPlayer(playerid, gTD_AttachEditor[i]);


			for(new i; i < 8; i++)
				PlayerTextDrawHide(playerid, pTD_AttachEditor[playerid][i]);

	    	switch(listitem)
	    	{
	    		case 0:
	    		{
	    			SendClientMessage(playerid, 0xD35400FF, ">{FFFFFF} Прикреплённый объект успешно сохранён!");

	    			hook_SetPlayerAttachedObject(playerid, index, model, bone, gPlayerEditObjectTD[playerid][index][0], gPlayerEditObjectTD[playerid][index][1], gPlayerEditObjectTD[playerid][index][2], gPlayerEditObjectTD[playerid][index][3], gPlayerEditObjectTD[playerid][index][4], gPlayerEditObjectTD[playerid][index][5], gPlayerEditObjectTD[playerid][index][6], gPlayerEditObjectTD[playerid][index][7], gPlayerEditObjectTD[playerid][index][8], .editor = true);

	    			AOE_SavePlayerAttachedObject(playerid, index);

	    			return 1;
	    		}
	    		case 1:
	    		{
	    			SendClientMessage(playerid, 0xD35400FF, ">{FFFFFF} Параметры были успешно сброшены!");

	    			new _item_id = GetDefaultAttach ( model ) ;

	    			ClearAttachData(playerid, index); // 04.04.2021

	    			if ( _item_id != -1 )
	    			{
		    			gPlayerAttachedObjectPos[playerid][index][0] = default_attach[_item_id][EA_CORD][0] ;
						gPlayerAttachedObjectPos[playerid][index][1] = default_attach[_item_id][EA_CORD][1] ;
						gPlayerAttachedObjectPos[playerid][index][2] = default_attach[_item_id][EA_CORD][2] ;
						gPlayerAttachedObjectPos[playerid][index][3] = default_attach[_item_id][EA_CORD][3] ;
						gPlayerAttachedObjectPos[playerid][index][4] = default_attach[_item_id][EA_CORD][4] ;
						gPlayerAttachedObjectPos[playerid][index][5] = default_attach[_item_id][EA_CORD][5] ;
						gPlayerAttachedObjectPos[playerid][index][6] = default_attach[_item_id][EA_CORD][6] ;
						gPlayerAttachedObjectPos[playerid][index][7] = default_attach[_item_id][EA_CORD][7] ;
						gPlayerAttachedObjectPos[playerid][index][8] = default_attach[_item_id][EA_CORD][8] ;
					}

					AOE_SavePlayerAttachedObject(playerid, index); // 04.04.2021
					hook_SetPlayerAttachedObject(playerid, index, model, bone, gPlayerAttachedObjectPos[playerid][index][0], gPlayerAttachedObjectPos[playerid][index][1], gPlayerAttachedObjectPos[playerid][index][2], gPlayerAttachedObjectPos[playerid][index][3], gPlayerAttachedObjectPos[playerid][index][4], gPlayerAttachedObjectPos[playerid][index][5], gPlayerAttachedObjectPos[playerid][index][6], gPlayerAttachedObjectPos[playerid][index][7], gPlayerAttachedObjectPos[playerid][index][8], .editor = true);

					return 1;
	    		}
	    	}

	    	return 1;
	    }
	    case d_change_step:
	    {
	    	if(!response)
	    		return 1;

	    	new
	    		Float:value = floatstr(inputtext);

	    	if(!(0.01 <= value <= 1.0))
	    	{
	    		SendClientMessage(playerid, 0xD35400FF, ">{FFFFFF} Шаг должен быть в диапазоне от {D35400}0.01{FFFFFF} до {D35400}1.0{ffffff}!");
	    		show_dialog(playerid, d_change_step, DIALOG_STYLE_INPUT, "{D35400}Изменить шаг", "{FFFFFF}В строку ниже введите желаемый шаг для изменения коордниты.\nПример: {D35400}0.5", "Далее", "Отмена");

	    		return 1;
	    	}

	    	gPlayerEditorStep[playerid] = value;

	    	format(aoe_str, sizeof aoe_str, "Step:_%.2f", gPlayerEditorStep[playerid]);
			PlayerTextDrawSetString(playerid, pTD_AttachEditor[playerid][6], aoe_str);
			PlayerTextDrawShow(playerid, pTD_AttachEditor[playerid][6]);

	    	return 1;
	    }
        case d_change_bone:
		{
			if(!response)
				return SelectTextDraw(playerid, 0xCCCCCCFF);

			new
				index = gPlayerChooseIndex{playerid};

			switch(listitem)
			{
				case 0..5:
				{
					gPlayerAttachedObjectBone[playerid][index] = listitem + 1;

					SetPlayerAttachedObject(playerid, index, gPlayerAttachedObjectModel[playerid][index], gPlayerAttachedObjectBone[playerid][index], gPlayerEditObjectTD[playerid][index][0], gPlayerEditObjectTD[playerid][index][1], gPlayerEditObjectTD[playerid][index][2], gPlayerEditObjectTD[playerid][index][3], gPlayerEditObjectTD[playerid][index][4], gPlayerEditObjectTD[playerid][index][5], gPlayerEditObjectTD[playerid][index][6], gPlayerEditObjectTD[playerid][index][7], gPlayerEditObjectTD[playerid][index][8]);

					SelectTextDraw(playerid, 0xCCCCCCFF);

					return 1;

				}
				case 6, 7:
				{

					gPlayerAttachedObjectBone[playerid][index] = listitem + 9;

					SetPlayerAttachedObject(playerid, index, gPlayerAttachedObjectModel[playerid][index], gPlayerAttachedObjectBone[playerid][index], gPlayerEditObjectTD[playerid][index][0], gPlayerEditObjectTD[playerid][index][1], gPlayerEditObjectTD[playerid][index][2], gPlayerEditObjectTD[playerid][index][3], gPlayerEditObjectTD[playerid][index][4], gPlayerEditObjectTD[playerid][index][5], gPlayerEditObjectTD[playerid][index][6], gPlayerEditObjectTD[playerid][index][7], gPlayerEditObjectTD[playerid][index][8]);

					SelectTextDraw(playerid, 0xCCCCCCFF);

					return 1;
				}
			}

			return 1;
		}
    }
    return 1;
}