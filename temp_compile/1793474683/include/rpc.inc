


//by KBAS's  t.me/kbasstudio 
stock SetPlayerCleanChat(playerid, clean)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 0); 
	 
	BS_WriteValue(bitstream, PR_UINT8, clean);   

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

stock ShowPlayerBackground(playerid, showtime, waittime, hidetime)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 13); 
	
	BS_WriteValue(bitstream, PR_UINT32, showtime);  
	BS_WriteValue(bitstream, PR_UINT32, waittime);  
	BS_WriteValue(bitstream, PR_UINT32, hidetime);  

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
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

stock TogglePlayerServerIcon(playerid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 25); 
	
	BS_WriteValue(bitstream, PR_UINT8, value); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock TogglePlayerChat(playerid, toggle)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 27); 
	
	BS_WriteValue(bitstream, PR_UINT8, toggle); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SendPlayerFireCarValue(playerid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 30); 
	
	BS_WriteValue(bitstream, PR_UINT8, value); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SendPlayerTreesWork(playerid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 32); 
	
	BS_WriteValue(bitstream, PR_UINT8, value); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SendPlayerHudFone(playerid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 33); 
	
	BS_WriteValue(bitstream, PR_UINT8, value); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SendFamilyInfoPackage(playerid, isFamily)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 34); 
	
	BS_WriteValue(bitstream, PR_UINT8, isFamily); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}

stock SendPlayerHaloweenMed(playerid, value)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 38); 
	
	BS_WriteValue(bitstream, PR_UINT8, value); 

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream); 
}