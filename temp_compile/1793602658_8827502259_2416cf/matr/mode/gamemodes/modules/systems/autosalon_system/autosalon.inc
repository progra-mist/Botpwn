stock pickup_autosalon()
{
    p_autosalon[0] = CreateDynamicPickup( 19132, 1, 2327.91, -1783.62, 22.4531);
    pick_info[p_autosalon[0]][pick_type] = pick_type_server;

    p_autosalon[1] = CreateDynamicPickup( 19132, 1, 447.857, 378.295, 12.0296);
    pick_info[p_autosalon[1]][pick_type] = pick_type_server;
    
    p_autosalon[2] = CreateDynamicPickup( 19132, 1, 2475.78, -717.005, 12.4369);
    pick_info[p_autosalon[2]][pick_type] = pick_type_server;

    p_autosalon[3] = CreateDynamicPickup( 19132, 1, 1851.25, 206.13, 7.8906);
    pick_info[p_autosalon[3]][pick_type] = pick_type_server;
    
    return 1;
}

stock ShowAutosalon(playerid)
{
    if(p_info[playerid][drive_lic] == 0) return SendClientMessage(playerid, -1, !"{afafaf}�� �� ������ ������������ �������������.");
    
    if(IsPlayerInRangeOfPoint(playerid,5.0, 2327.9102,-1783.6237,22.4531))
    {
        SetPVarInt(playerid,"AutoShop",1);
        SetPVarInt(playerid,"CarShop",0);
        return ShowBuyCar(playerid);
    }
    else if(IsPlayerInRangeOfPoint(playerid,5.0, 447.8569,378.2949,12.0296))
    {
        SetPVarInt(playerid,"AutoShop",2);
        SetPVarInt(playerid,"CarShop",1);
        return ShowBuyCar(playerid);
    }
    else if(IsPlayerInRangeOfPoint(playerid,5.0,2475.7834,-717.0051,12.4369))
    {
        SetPVarInt(playerid,"AutoShop",3);
        SetPVarInt(playerid,"CarShop",2);
        return ShowBuyCar(playerid);
    }
    else if(IsPlayerInRangeOfPoint(playerid,5.0, 1851.2474,206.1299,7.8906))
    {
        SetPVarInt(playerid,"AutoShop",4);
        SetPVarInt(playerid,"CarShop",3);
        return ShowBuyCar(playerid);
    }
    else SendClientMessage(playerid,-1,"�� �� � ����� ������� �����������!");
    return 1;
}

stock NextCar(playerid)
{
    if(p_info[playerid][SalonTime] > gettime()) return GameTextForPlayer(playerid,"Loading...",1000,3);

    SetPVarInt(playerid, "CvetAvto", 0);
    TogglePlayerControllable(playerid, false);

    SetPVarInt(playerid, "SelectAvto", GetPVarInt(playerid, "SelectAvto") +1);

    switch(GetPVarInt(playerid,"CarShop"))
    {
        case 0: if(GetPVarInt(playerid, "SelectAvto") > 11) SetPVarInt(playerid, "SelectAvto", 0);//��� �����
        case 1: if(GetPVarInt(playerid, "SelectAvto") > 25) SetPVarInt(playerid, "SelectAvto", 12);//������� �����
        case 2: if(GetPVarInt(playerid, "SelectAvto") > 46) SetPVarInt(playerid, "SelectAvto", 25);//������� �����
        case 3: if(GetPVarInt(playerid, "SelectAvto") > 52) SetPVarInt(playerid, "SelectAvto", 27);//������� �����
    }
    return ShowingCar(playerid);
}
stock BackCar(playerid)
{
    if(p_info[playerid][SalonTime] > gettime()) return GameTextForPlayer(playerid,"Loading...",1000,3);
    TogglePlayerControllable(playerid, false);
    SetPVarInt(playerid, "SelectAvto", GetPVarInt(playerid, "SelectAvto")-1);

    switch(GetPVarInt(playerid,"CarShop"))
    {
        case 0:if(GetPVarInt(playerid, "SelectAvto") < 0) SetPVarInt(playerid, "SelectAvto", 11);//���
        case 1:if(GetPVarInt(playerid, "SelectAvto") < 12) SetPVarInt(playerid, "SelectAvto", 25);//�������
        case 2:if(GetPVarInt(playerid, "SelectAvto") < 25) SetPVarInt(playerid, "SelectAvto", 44);//�������
        case 3:if(GetPVarInt(playerid, "SelectAvto") > 48) SetPVarInt(playerid, "SelectAvto", 27);//������� �����
    }
    return ShowingCar(playerid);
}
stock ShowingCar(playerid) //���������
{
    if(p_info[playerid][SalonCar] != INVALID_VEHICLE_ID) DestroyVehicle(p_info[playerid][SalonCar]);
    p_info[playerid][SalonCar] = CreateVehicle(car_autosalon[GetPVarInt(playerid, "SelectAvto")][0], -11.8209, 804.2191, 501.1797 + 0.5, 270.0,0,0,-1,0);
    
    carsaloncolor[p_info[playerid][SalonCar]] = 0;
    
    SetPlayerInterior(playerid, 0);
    LinkVehicleToInterior(p_info[playerid][SalonCar], 0);
    SetPlayerVirtualWorld(playerid, playerid + 1);
    SetVehicleVirtualWorld(p_info[playerid][SalonCar], playerid+1);
    
    veh_info[p_info[playerid][SalonCar]][v_health] = 1000.0;
    veh_info[p_info[playerid][SalonCar]][v_fuel] = 100.0;
    
    PutPlayerInVehicle(playerid, p_info[playerid][SalonCar], 0);

    SetPlayerPos(playerid, -11.8209,804.2191,501.1797 - 5.0);
    SetPlayerCameraPos(playerid, -6.4041,807.7175,502.3228);
    SetPlayerCameraLookAt(playerid, -10.8209, 804.2191,501.1797);

    SetPVarInt(playerid,"BuyColor",1);
    SetPVarInt(playerid,"BuyColor1",1);

    new string[128];
    GameTextForPlayer(playerid,string, 5000, 3);
    format(string,sizeof(string),"Model: %s~n~Cost: %d",g_vehicle_info[car_autosalon[GetPVarInt(playerid, "SelectAvto")][0]-400],car_autosalon[GetPVarInt(playerid, "SelectAvto")][1]);
    
    new model[128];
    format(model, sizeof(model), "%s", g_vehicle_info[car_autosalon[GetPVarInt(playerid, "SelectAvto")][0]-400]);
    SetCarJavaSalon(playerid, car_autosalon[GetPVarInt(playerid, "SelectAvto")][1], model);
    
    p_info[playerid][SalonTime] = gettime()+1;
    TogglePlayerControllable(playerid, false);
    return 1;
}
stock ShowBuyCar(playerid)
{
    SetPVarInt(playerid, "HideSpeed", 1);
	SetPVarInt(playerid, "SelectAvto", 0);
	switch(GetPVarInt(playerid,"CarShop"))
	{
		case 0: SetPVarInt(playerid, "SelectAvto", 1);//���
		case 1: SetPVarInt(playerid, "SelectAvto", 20);//�������
		case 2: SetPVarInt(playerid, "SelectAvto", 30);//�������
		case 3: SetPVarInt(playerid, "SelectAvto", 40);//�������
	}
    
    ShowJavaSalon(playerid, 1);
 	new str_avtobuy[200], str_avtobuyy[200];
 	format(str_avtobuy, sizeof str_avtobuy, "%d py�", car_autosalon[GetPVarInt(playerid, "SelectAvto")][1]);
    
 	format(str_avtobuyy, sizeof str_avtobuyy, "%d k�/�", random(200)+50);
    
 	SelectTextDraw(playerid, 0xFFFFFF20);
	SetPlayerVirtualWorld(playerid, 1);
	SetPVarInt(playerid, "SelectTextDraw", 1);
 	return ShowingCar(playerid);
}

stock ExitCar(playerid)
{
	if(p_info[playerid][SalonCar] != INVALID_VEHICLE_ID) DestroyVehicle(p_info[playerid][SalonCar]);
	p_info[playerid][SalonCar] = INVALID_VEHICLE_ID;
	DeletePVar(playerid, "SelectTextDraw");
	CancelSelectTextDraw(playerid);
	if(GetPVarInt(playerid,"AutoShop") != -1)
	{
		switch(GetPVarInt(playerid,"AutoShop"))
		{
			case 1: SetPlayerPos(playerid, 2327.9102,-1783.6237,22.4531);
			case 2: SetPlayerPos(playerid, 447.8569,378.2949,12.0296);
			case 3: SetPlayerPos(playerid, 2475.7834,-717.0051,12.4369);
			case 4: SetPlayerPos(playerid, 1851.2474,206.1299,7.8906);
		}
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
  		SetPlayerFacingAngle(playerid,0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DeletePVar(playerid,"CarShop");
		SetPVarInt(playerid,"AutoShop",-1);
		DeletePVar(playerid,"BuyColor");
	    DeletePVar(playerid,"BuyColor1");
		SetPVarInt(playerid, "SelectAvto",-1);
		ShowJavaSalon(playerid, 0);
		return true;
	}
	SetPVarInt(playerid, "HideSpeed", 0);
	return true;
}

stock autosalon_dialogs (playerid, dialogid, response)
{
    switch(dialogid)
    {
        case d_autosalon_1:
        {
            if(!response) return ExitCar(playerid);

            if(p_info[playerid][money] < car_autosalon[GetPVarInt(playerid, "SelectAvto")][1])
            {
                SendClientMessage(playerid,-1,"� ��� ������������ �����!");
                ExitCar(playerid);
                return 1;
            }

            if(get_player_veh_count(playerid) >= p_info[playerid][max_veh]) 
            {
                SendClientMessage(playerid, col_white, !""scm_error"��� ������ ����� ������� ���� �� �������� ������������ �������.");
                ExitCar(playerid);
                return 1;
            }

            p_info[playerid][money] -= car_autosalon[GetPVarInt(playerid, "SelectAvto")][1];
            buy_ownable_car(playerid, GetPVarInt(playerid,"AutoShop") - 1, car_autosalon[GetPVarInt(playerid, "SelectAvto")][0], carsaloncolor[p_info[playerid][SalonCar]]);

            ExitCar(playerid);
            return 1;
        }
    }
    return 1;
}
stock buy_ownable_car(playerid, marketid, modelid, color)
{
    new buy_cars_count = cars_after_purchase_count[marketid]++;

    if(buy_cars_count >= 19) cars_after_purchase_count[marketid] = 0;

    // ----------------------------------------------------------------------------------------

    new Float:pos_x = cars_pos_after_purchase[marketid][buy_cars_count][0];
    new Float:pos_y = cars_pos_after_purchase[marketid][buy_cars_count][1];
    new Float:pos_z = cars_pos_after_purchase[marketid][buy_cars_count][2];
    new Float:angle = cars_pos_after_purchase[marketid][buy_cars_count][3];

    new	veh_id = CreateVehicle(modelid, pos_x, pos_y, pos_z, angle, color, color, -1);

    // ----------------------------------------------------------------------------------------
	
    new query_string[226];
	mysql_format(sql_connection, query_string, sizeof(query_string), "INSERT INTO `users_vehicles`(`v_model`,`v_owner`,`v_color_1`,`v_color_2`,`v_pos_x`,`v_pos_y`,`v_pos_z`,`v_pos_a`,`v_buydate`) VALUES('%d','%d','%d','%d','%f','%f','%f','%f',NOW())", 
	modelid, p_info[playerid][id], color, color, pos_x, pos_y, pos_z, angle);
	mysql_tquery(sql_connection, query_string, "create_vehicle_callback", "dd", veh_id, playerid);
	
    // ----------------------------------------------------------------------------------------

	veh_info[veh_id - 1][v_type] = vehicle_type_player;
	veh_info[veh_id - 1][v_owner] = p_info[playerid][id];
	veh_info[veh_id - 1][v_vehicle] = veh_id;
	veh_info[veh_id - 1][v_model] = modelid;
	format(veh_info[veh_id - 1][v_plate], 12, "Transit");
	veh_info[veh_id - 1][v_pos][0] = pos_x;
	veh_info[veh_id - 1][v_pos][1] = pos_y;
	veh_info[veh_id - 1][v_pos][2] = pos_z;
	veh_info[veh_id - 1][v_pos][3] = angle;
    veh_info[veh_id - 1][v_fuel] = 90.0;
	veh_info[veh_id - 1][v_millage] = 0.0;
	veh_info[veh_id - 1][v_fine] = 3;
	veh_info[veh_id - 1][v_locked] = true;

    // ----------------------------------------------------------------------------------------

    if(veh_id != INVALID_VEHICLE_ID)
    {
        CreateVehicleLabel(veh_info[veh_id - 1][v_vehicle], veh_info[veh_id - 1][v_plate], 0x6666CCEE, 0.0, 0.0, 1.3, 20.0);
        SetVehicleNumberPlate(veh_info[veh_id - 1][v_vehicle], veh_info[veh_id - 1][v_plate]);
    }

    SendClientMessage(playerid, -1, !""c_server"����������� � �������� ������ ����������! {afafaf}(���������� ��� ��������� � ����������)");
    SendClientMessage(playerid, -1, !""c_server"��������� ����� ������������ � ����� ��������� �����. {afafaf}(������� -> /park)");

    // ----------------------------------------------------------------------------------------

	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(veh_id, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(veh_id, engine, lights, alarm, true, bonnet, boot, objective);

	Iter_Add(player_vehicles[playerid], veh_info[veh_id - 1][v_vehicle]);

    // ----------------------------------------------------------------------------------------
	
    return 1;
}
CMD:autosalon(playerid, params[])
{
    new veh_id = p_info[playerid][SalonCar];
    new color = carsaloncolor[veh_id];
    switch(strval(params[0])) 
    {
        case 0: 
        {
            show_dialog(playerid, d_autosalon_1, 0, !""c_server"������������� ������� ����������", !"{FFFFFF}�� ������������� ������ ���������� ���� ����������?", !"����������", !"������");
        }
        case 1: 
        {
            NextCar(playerid);
        }
        case 2: 
        {
            BackCar(playerid);
        }
        case 3: 
        {
            if(color < 7) 
            {
               carsaloncolor[veh_id]++;
		       ChangeVehicleColor(veh_id, carsaloncolor[veh_id], carsaloncolor[veh_id]);
		    }
		    else SendClientMessage (playerid, -1, "�� ������ �� ��������� �����!");
        }
        case 4: 
        {
            if(color > 0) 
            {
               carsaloncolor[veh_id]--;
		       ChangeVehicleColor(veh_id, carsaloncolor[veh_id], carsaloncolor[veh_id]);
		    }
		    else SendClientMessage (playerid, -1, "�� ������ �� ������ �����!");
        }
        case 5: 
        {
           ExitCar(playerid);
        }
    }
    return;
}
stock CreateVehicleLabel(vehicleid, text[], color, Float:x, Float:y, Float:z, Float:drawdistance, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_3D_TEXT_LABEL_SD)
{
    if(IsValidVehicle(vehicleid + 2000))
    {
        veh_info[vehicleid][v_label] = CreateDynamic3DTextLabel(text, color, x, y, z, drawdistance, INVALID_PLAYER_ID, vehicleid, testlos, worldid, interiorid, playerid, streamdistance);
    }
    return 1;
}
stock DestroyVehicleLabel(vehicleid)
{
   if(IsValidVehicleID(vehicleid + 2000))
    {
        if(IsValidDynamic3DTextLabel(veh_info[vehicleid][v_label]))
        {
            DestroyDynamic3DTextLabel(veh_info[vehicleid][v_label]);
            veh_info[vehicleid][v_label] = Text3D: -1;
        }
    }
   return 1;
}

stock ShowJavaSalon(playerid, isShow)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
    BS_WriteValue(bitstream, PR_UINT32, 0x40);

    BS_WriteValue(bitstream, PR_INT32, isShow);

    PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);

	return true;
}

stock SetCarJavaSalon(playerid, numberr, const namee[])
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, PACKET_CUSTOMRPC);
    BS_WriteValue(bitstream, PR_UINT32, 0x41);

    BS_WriteValue(bitstream, PR_INT32, numberr);
    
    BS_WriteValue(bitstream, PR_UINT16, strlen(namee));
    BS_WriteValue(bitstream, PR_STRING, namee);

    PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);

	return true;
}
