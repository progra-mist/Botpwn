#if defined _INC_RPC
	#endinput
#endif
#define _INC_RPC

#define PlatesGuiFragment                   1
#define GUIFuelFill                         2
#define BrDialogDiner                       3
#define BrDialogHack                        4
#define BrDialogRobbery                     5
#define RentGuiFragment                     6
#define BrDialogWires                       7
#define BrDialogPipes                       8
#define BrAudioDialog                       9
#define BrDialogWindow                      10
#define ChooseServerGuiFragment             11
#define BrFingerPrintDialog                 12
#define GUINotificationNewStyle             13
#define MenuComposeGUIFragment              14
#define BrDialogDance                       15
#define TaxiFragment                        16
#define TaxiOrderFragment                   17
#define TaxiRatingFragment                  18
#define TaxiMapFragment                     21
#define GUIDonate                           22
#define BrDialogSawmill                     23
#define GUISmiEditor                        24
#define GUIPlayersList                      25
#define BrNewCaptcha                        26
#define GUIRadialMenuForCar                 27
#define GUITuning                           28
#define HolidayEventsGuiFragment            30
#define GUIMiniGameEventsGame               31
#define HudManager 							32
#define GUIUsersInventory                   33
#define GUICarsTrunkOrCloset                34
#define BlackPassBannerComposeGUIFragment   35
#define GUISocialInteraction                36
#define GUIDrivingSchool                    37
#define GUIRegistration                     38
#define TutorialGuiFragment                 39
#define GUIWoundSystem                      40  // Система ранений/смерти
#define GUIVipAccount                       41
#define GUIEntertainmentSystem              42
#define GUIEntertainmentSystemFinalWindow   43
#define GUIFamilySystem                     45
#define GUIFractionSystem                   46
#define MenuSettingMainUiFragment           47
#define CraftGuiFragment                    49
#define GUISpawnLocation                    50
#define GUISocialNetworkLink                52
#define ElectricGuiFragment                 56
#define CatchStreamerGUIFragment            57
#define GUIGasmanGame                       58
#define FishingGUIFragment                  59
#define YotubePlayerFragment                61
#define InteractionWithNpcGUIFragment       63
#define HalloweenAwardGuiFragment           64
#define ActiveTaskGuiFragment               65
#define AdminToolsGuiFragment               66
#define BrSimBannerComposeGUIFragment       67
#define UpgradeObjectEventGuiFragment       68
#define GiftsGuiFragment                    69
#define PanelInfoGuiFragment                70
#define CalendarGUIFragment                 71
#define RateAppComposeGUIFragment           72
#define CasesGUIFragment                    73
#define BpRewardsGuiFragment                74
#define TanpinBannerGuiFragment             75
#define VideoPlayerGuiFragment              76
#define MarketplaceGuiFragment              77
#define ClickerGuiFragment                  79
#define ChatGuiFragment                     80
#define ModuleDialogGuiFragment             81
#define RatingGuiFragment                   82

#define PACKET_BLACKRRPC                    252

stock SetVehicleTonerr(vehicleid, front, rear, front_side, back_side, setvalue=0)
{
    if(setvalue)
    {
        vInfo[vehicleid][vTonerFront]      = front;
        vInfo[vehicleid][vTonerRear]       = rear;
        vInfo[vehicleid][vTonerFrontSide]  = front_side;
        vInfo[vehicleid][vTonerRearSide]   = back_side;
    }

    new playerid;
    foreach(playerid : Player)
    {
        if(IsPlayerConnected(playerid))
            SetVehicleTonerForPlayer(playerid, vehicleid, front, rear, front_side, back_side);
    }
}

stock SetVehicleTonerForPlayer(playerid, vehicleid, front, rear, front_side, back_side)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT16, vehicleid);
    BS_WriteValue(bitstream, PR_UINT8, 0); // тип тюна (тонер)

    BS_WriteValue(bitstream, PR_UINT32, front);
    BS_WriteValue(bitstream, PR_UINT32, rear);
    BS_WriteValue(bitstream, PR_UINT32, front_side);
    BS_WriteValue(bitstream, PR_UINT32, back_side);

    PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bitstream);
}

stock SetVehicleHydraulics(vehicleid, type, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vHydraulics] = type;
	foreach(new playerid: Player) SetVehicleHydraulicsForPlayer(playerid, vehicleid, type);
}

stock SetVehicleHydraulicsForPlayer(playerid, vehicleid, type)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 21);

	BS_WriteValue(bitstream, PR_UINT8, type);

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}

stock PlayAudioStreamURL(playerid, const url[])
{
    new BitStream:bs = BS_New();
    new len = strlen(url);

    printf("PlayAudioStreamURL: Player %d, URL length: %d, URL: %s", playerid, len, url);

    BS_WriteValue(bs, PR_INT32, 1);
    BS_WriteValue(bs, PR_UINT8, len);
    BS_WriteValue(bs, PR_STRING, url);
    BS_WriteValue(bs, PR_INT32, 0);
    BS_WriteValue(bs, PR_FLOAT, 1.0);
    BS_WriteValue(bs, PR_UINT8, 0);

    PR_SendRPC(bs, playerid, 41, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
    printf("PlayAudioStreamURL: RPC sent for player %d", playerid);
}

// Сток для остановки аудио
stock StopAudioStream(playerid)
{
    new BitStream:bs = BS_New();

    printf("StopAudioStream: Attempting to stop audio for player %d", playerid);

    BS_WriteValue(bs, PR_INT32, 1);    // ID потока
    BS_WriteValue(bs, PR_UINT8, 0);    // Длина строки = 0
    BS_WriteValue(bs, PR_INT32, 0);    // Позиция
    BS_WriteValue(bs, PR_FLOAT, 0.0);  // Громкость 0
    BS_WriteValue(bs, PR_UINT8, 1);    // Флаг остановки

    PR_SendRPC(bs, playerid, 41, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    printf("StopAudioStream: RPC sent for player %d", playerid);
    BS_Delete(bs);
}

stock SetVehicleNumberPlateEx(vehicleid, type, number[], region[])
{
 vInfo[vehicleid][vNumber][Type] = type;
 format(vInfo[vehicleid][vNumber][Number], 9, number);
 format(vInfo[vehicleid][vNumber][Region], 4, region);
 foreach(new playerid: Player)
 {
  SetVehicleNumberPlateForPlayer(playerid, vehicleid, type, number, region);
 }
}

stock SetVehicleNumberPlateForPlayer(playerid, vehicleid, type, number[], region[])
{
 new BitStream:bitstream = BS_New();
 BS_WriteValue(bitstream, PR_UINT8, 7);

 BS_WriteValue(bitstream, PR_UINT16, vehicleid);

 BS_WriteValue(bitstream, PR_UINT8, type);

 BS_WriteValue(bitstream, PR_UINT8, strlen(number));
 BS_WriteValue(bitstream, PR_STRING, number);

 BS_WriteValue(bitstream, PR_UINT8, strlen(region));
 BS_WriteValue(bitstream, PR_STRING, region);

 PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
 BS_Delete(bitstream);
}

stock SetVehicleLaunchControl(vehicleid, type, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vLaunchControl] = type;
	foreach(new playerid: Player) SetVehicleLaunchControlFP(playerid, vehicleid, type);
}

stock SetVehicleLaunchControlFP(playerid, vehicleid, type)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 23);

	BS_WriteValue(bitstream, PR_UINT8, type);

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}

stock SetVehicleHighLight(vehicleid, type, setvalue=0)
{
  if(setvalue) vInfo[vehicleid][vHighLights] = type;
  foreach(new playerid: Player) SetVehicleHighLightForPlayer(playerid, vehicleid, type);
}

stock SetVehicleHighLightForPlayer(playerid, vehicleid, type)
{
  new BitStream:bitstream = BS_New();
  BS_WriteValue(bitstream, PR_UINT16, vehicleid);
  BS_WriteValue(bitstream, PR_UINT8, 22);

  BS_WriteValue(bitstream, PR_UINT8, type);

  PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
  BS_Delete(bitstream);
}

stock SetVehicleSpeedometerInfo(vehicleid, Float:fuel = 52.0, Float:mileage = 1488.0)
{
	vInfo[vehicleid][vFuel] = fuel;
	vInfo[vehicleid][vMileage] = mileage;

	foreach(new playerid: Player)
	{
		if(GetPlayerVehicleID(playerid) == vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehicleSpeedometerInfoFP(playerid, vehicleid, fuel, mileage);
		else continue;
	}
}

stock SetVehicleSpeedometerInfoFP(playerid, vehicleid, Float:fuel = 52.0, Float:mileage = 1488.0)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 14);

	BS_WriteValue(bitstream, PR_UINT32, fuel);
	BS_WriteValue(bitstream, PR_UINT32, mileage);

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}

stock SetVehicleLightingColor(vehicleid, center, right, left, setvalue=0)
{
  if(setvalue)
  {
    vInfo[vehicleid][vNeon][0] = center;
    vInfo[vehicleid][vNeon][1] = right;
    vInfo[vehicleid][vNeon][2] = left;
  }

  foreach(new playerid : streamed_players_in_veh[vehicleid]) SetVehicleLightingForPlayer(playerid, vehicleid, RGBA_to_ARGB(center), RGBA_to_ARGB(right), RGBA_to_ARGB(left));
}

stock SetVehicleLightingForPlayer(playerid, vehicleid, center, right, left)
{
  new BitStream:bitstream = BS_New();
  BS_WriteValue(bitstream, PR_UINT16, vehicleid);
  BS_WriteValue(bitstream, PR_UINT8, 9);

  BS_WriteValue(bitstream, PR_UINT32, center);
  BS_WriteValue(bitstream, PR_UINT32, right);
  BS_WriteValue(bitstream, PR_UINT32, left);

  PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
  BS_Delete(bitstream);
}
stock RGBA_to_ARGB(color)
{
    return ((color & 0xffff00 ) >> 24) | (color & 0xffffff);
}
stock SetPlayerX2(playerid, value, tovalue)
{
	new BitStream:bitstream = BS_New();
 	BS_WriteValue(bitstream, PR_UINT8, 24);

	BS_WriteValue(bitstream, PR_UINT8, value);
 	BS_WriteValue(bitstream, PR_UINT8, tovalue);

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
 	BS_Delete(bitstream);
}

stock SetVehicleDriftForPlayer(playerid, vehicleid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 5); 
	
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);  
	BS_WriteValue(bitstream, PR_UINT8, value);   

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SetVehicleDifferential(vehicleid, type, setvalue=0)
{
    if(setvalue) vInfo[vehicleid][vDifferential] = type;
    foreach(new playerid: Player) SetVehicleDifferentialFP(playerid, vehicleid, type);
}

stock SetVehicleDifferentialFP(playerid, vehicleid, type)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT16, vehicleid);
    BS_WriteValue(bitstream, PR_UINT8, 15); // type = дифференциал

    BS_WriteValue(bitstream, PR_UINT8, type); // 0 = COMFORT, 1 = SPORT

    PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bitstream);
}

stock SetVehicleTint(vehicleid, level, setvalue=0)
{
    if(setvalue)
    {
        vInfo[vehicleid][vTint] = level;
    }
    foreach(new playerid: Player) SetVehicleTintForPlayer(playerid, vehicleid, level);
}

stock SetVehicleTintForPlayer(playerid, vehicleid, level)
{
    new BitStream:bs = BS_New();
    BS_WriteValue(bs, PR_UINT16, vehicleid);
    BS_WriteValue(bs, PR_UINT8, 10);   // тип тюна (тонировка)

    BS_WriteValue(bs, PR_UINT8, level); // уровень тонировки

    PR_SendRPC(bs, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
}

stock SetVehicleVinyl(vehicleid, newvinylid, setvalue=0)
{
    if(setvalue)
    {
        vInfo[vehicleid][vVinyl] = newvinylid;
    }
    foreach(new playerid: Player) SetVehicleVinylForPlayer(playerid, vehicleid, newvinylid);
}

stock SetVehicleVinylForPlayer(playerid, vehicleid, newvinylid)
{
    new BitStream:bs = BS_New();
    BS_WriteValue(bs, PR_UINT16, vehicleid);
    BS_WriteValue(bs, PR_UINT8, 12);   // тип тюна (винил)

    BS_WriteValue(bs, PR_UINT8, newvinylid); // ID винила

    PR_SendRPC(bs, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
}

stock SetVehicleStroboscopee(vehicleid, type, setvalue=0)
{
  if(setvalue) vInfo[vehicleid][vStrob] = type;
  foreach(new playerid: Player) SetVehicleStroboscopeForPlayer(playerid, vehicleid, type);
}

stock SetVehicleStroboscopeForPlayere(playerid, vehicleid, type)
{
  new BitStream:bitstream = BS_New();
  BS_WriteValue(bitstream, PR_UINT16, vehicleid);
  BS_WriteValue(bitstream, PR_UINT8, 19);

  BS_WriteValue(bitstream, PR_UINT32, type);

  PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
  BS_Delete(bitstream);
}


stock SetVehicleStroboscope(vehicleid, type, setvalue=0)
{
  if(setvalue) vInfo[vehicleid][vStrob] = type;
  foreach(new playerid: Player) SetVehicleStroboscopeForPlayer(playerid, vehicleid, type);
}

stock SetVehicleStroboscopeForPlayer(playerid, vehicleid, type)
{
  new BitStream:bitstream = BS_New();
  BS_WriteValue(bitstream, PR_UINT16, vehicleid);
  BS_WriteValue(bitstream, PR_UINT8, 19);

  BS_WriteValue(bitstream, PR_UINT32, type);

  PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
  BS_Delete(bitstream);
}

stock SetVehicleExhaust(vehicleid, type, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vExhaustSound] = type;
	foreach(new playerid: Player) SetVehicleExhaustForPlayer(playerid, vehicleid, type); 
} 

stock SetVehicleExhaustForPlayer(playerid, vehicleid, type)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 24);

	BS_WriteValue(bitstream, PR_UINT16, type); 

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}

stock SetPlayerIntera7(playerid, rpcid, value)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, rpcid);

    BS_WriteValue(bitstream, PR_UINT8, value);

    PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bitstream);
}

// ===== Хендлинг-предустановки =====
new Float:PresetMaxSpeed[4]       = {220.0, 250.0, 200.0, 180.0};
new Float:PresetAcceleration[4]   = {1.0, 1.2, 0.9, 0.7};
new Float:PresetBrake[4]          = {0.8, 0.9, 0.7, 0.9};
new Float:PresetSuspension[4]     = {0.8, 0.85, 0.7, 0.6};
new Float:PresetSuspensionBias[4] = {0.5, 0.55, 0.6, 0.5};
new Float:PresetSteering[4]       = {35.0, 38.0, 45.0, 30.0};

// ===== Стоки для отправки хендлинга =====
stock ApplyVehicleHandlingForPlayer(playerid, vehicleid, presetid)
{
    new BitStream:bs = BS_New();
    BS_WriteValue(bs, PR_UINT16, vehicleid);

    // RPC ID 167
    BS_WriteValue(bs, PR_UINT8, 1); // Suspension Force
    BS_WriteValue(bs, PR_FLOAT, PresetSuspension[presetid]);

    BS_WriteValue(bs, PR_UINT8, 2); // Suspension Bias
    BS_WriteValue(bs, PR_FLOAT, PresetSuspensionBias[presetid]);

    BS_WriteValue(bs, PR_UINT8, 4); // Max Speed
    BS_WriteValue(bs, PR_FLOAT, PresetMaxSpeed[presetid]);

    BS_WriteValue(bs, PR_UINT8, 5); // Engine Acceleration
    BS_WriteValue(bs, PR_FLOAT, PresetAcceleration[presetid]);

    BS_WriteValue(bs, PR_UINT8, 6); // Brake
    BS_WriteValue(bs, PR_FLOAT, PresetBrake[presetid]);

    BS_WriteValue(bs, PR_UINT8, 7); // Steering Lock
    BS_WriteValue(bs, PR_FLOAT, PresetSteering[presetid]);

    PR_SendRPC(bs, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
}


stock ApplyVehicleHandling(vehicleid, presetid)
{
    new playerid;
    for(playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if(IsPlayerConnected(playerid) && IsPlayerInVehicle(playerid, vehicleid))
            ApplyVehicleHandlingForPlayer(playerid, vehicleid, presetid);
    }
}

stock SetVehicleSportForPlayer(playerid, vehicleid, value)
{
 new BitStream:bitstream = BS_New();
 BS_WriteValue(bitstream, PR_UINT8, 6);

 BS_WriteValue(bitstream, PR_UINT16, vehicleid);
 BS_WriteValue(bitstream, PR_UINT8, value);

 PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
 BS_Delete(bitstream);
}

stock SetVehicleHornSound(vehicleid, horn_id, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vHornSound] = horn_id;
	foreach(new playerid: Player) SetVehicleHornSoundForPlayer(playerid, vehicleid, horn_id); 
} 

stock SetVehicleHornSoundForPlayer(playerid, vehicleid, horn_id)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 15);

	BS_WriteValue(bitstream, PR_UINT8, horn_id); 

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}

stock SetVehicleLightColor(vehicleid, color, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vLightColor] = color; 
	foreach(new playerid : streamed_players_in_veh[vehicleid])  SetVehicleLightColorForPlayer(playerid, vehicleid, RGBA_to_ARGB(color)); 
} 

stock SetVehicleLightColorForPlayer(playerid, vehicleid, color)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 8);

	BS_WriteValue(bitstream, PR_UINT32, color);  

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
} 

stock UpdateVehicleVisualForPlayer(playerid, vehicleid)
{  
 if(vInfo[vehicleid][vNumber][Type] == 0) vInfo[vehicleid][vNumber][Type] = 6;
 SetVehicleNumberPlateForPlayer (playerid, vehicleid, vInfo[vehicleid][vNumber][Type], vInfo[vehicleid][vNumber][Number], vInfo[vehicleid][vNumber][Region]);
 SetVehicleTonerForPlayer  (playerid, vehicleid, vInfo[vehicleid][vTonerFront], vInfo[vehicleid][vTonerRear], vInfo[vehicleid][vTonerFrontSide], vInfo[vehicleid][vTonerRearSide]); 
 SetVehicleLightColorForPlayer (playerid, vehicleid, RGBA_to_ARGB(vInfo[vehicleid][vLightColor]));
 SetVehicleLightingForPlayer  (playerid, vehicleid, RGBA_to_ARGB(vInfo[vehicleid][vNeon][0]), RGBA_to_ARGB(vInfo[vehicleid][vNeon][1]), RGBA_to_ARGB(vInfo[vehicleid][vNeon][2]));
 SetVehicleVinylForPlayer  (playerid, vehicleid, vInfo[vehicleid][vVinylTexture]);
 SetVehicleColorForPlayer  (playerid, vehicleid, RGBA_to_ARGB(vInfo[vehicleid][vColorBody]), RGBA_to_ARGB(vInfo[vehicleid][vColorWheels]));
 SetVehicleStroboscopeForPlayer (playerid, vehicleid, vInfo[vehicleid][vStrob]-1);
 SetVehicleHighLightForPlayer (playerid, vehicleid, 1);
 SetVehicleEnableSirenForPlayer (playerid, vehicleid, 1); 
 SetVehicleSirenForPlayer  (playerid, vehicleid, vInfo[vehicleid][vSiren]);
}
stock SetVehicleColor(vehicleid, body, wheel, setvalue=0)
{
	if(setvalue)
	{
		vInfo[vehicleid][vColorBody] = body;
		vInfo[vehicleid][vColorWheels] = wheel;
	}
	foreach(new playerid: Player) SetVehicleColorForPlayer(playerid, vehicleid, RGBA_to_ARGB(body), RGBA_to_ARGB(wheel)); 
} 

stock SetVehicleColorForPlayer(playerid, vehicleid, body, wheel)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 18);

	BS_WriteValue(bitstream, PR_UINT32, body);
	BS_WriteValue(bitstream, PR_UINT32, wheel);
	BS_WriteValue(bitstream, PR_UINT32, wheel);
	BS_WriteValue(bitstream, PR_UINT32, body); 

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}
stock SetVehicleEnableSiren(vehicleid, type) //синхронизация включенной сирены
{
	//vInfo[vehicleid][vEnableSiren] = type;
	foreach(new playerid: Player) SetVehicleEnableSirenForPlayer(playerid, vehicleid, type); 
} 

stock SetVehicleEnableSirenForPlayer(playerid, vehicleid, type)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 27);

	BS_WriteValue(bitstream, PR_UINT8, type); 

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}
stock SetVehicleSiren(vehicleid, type, setvalue=0)
{
	if(setvalue) vInfo[vehicleid][vSiren] = type;
	foreach(new playerid: Player) SetVehicleSirenForPlayer(playerid, vehicleid, type); 
} 

stock SetVehicleSirenForPlayer(playerid, vehicleid, type)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, 26);

	BS_WriteValue(bitstream, PR_UINT8, type); 

	PR_SendRPC(bitstream, playerid, 167, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
}
