//by vk.com/b.weikton


stock ShowNewNotification(playerid, type, duration, id, subId, caption[], btnCaption[])
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, 251);
    BS_WriteValue(bitstream, PR_UINT32, 102);
    
    BS_WriteValue(bitstream, PR_INT16, type);
	BS_WriteValue(bitstream, PR_INT16, duration);
	BS_WriteValue(bitstream, PR_INT16, id);
	BS_WriteValue(bitstream, PR_INT16, subId);

	BS_WriteValue(bitstream, PR_INT16, strlen(btnCaption));
	BS_WriteValue(bitstream, PR_STRING, btnCaption);
	
	BS_WriteValue(bitstream, PR_INT16, strlen(caption));
	BS_WriteValue(bitstream, PR_STRING, caption);
    
    BS_Send(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);
    BS_Delete(bitstream);

	return true;
}
IPacket:251(playerid, BitStream:bitstream)
{
	new header, rpcid;

	BS_ReadValue(bitstream, PR_UINT8, header);
	BS_ReadValue(bitstream, PR_UINT32, rpcid);

	switch(rpcid) {
		case 28: {
			new sub_id, type;
			BS_ReadValue(bitstream, PR_UINT16, sub_id);
			BS_ReadValue(bitstream, PR_UINT16, type);

			switch(type) {
				case 0: { // когда на уведомлении нажали кнопку (согласие)
					switch(sub_id) { // получаеем уведомление по айди
						case 1: {
							new str[256];
							format(str, sizeof(str), "{FFFF00}| {FFFFFF}Нажато на кнопку, на уведолмнии под ID, под ID: {FFFF00}%d", sub_id);
							SendClientMessage(playerid, -1, str);
							return;
						}
					}
				}
				case 1: { // когда уведолмения скрылось при окончании времени или на него нажали (отказ)
					switch(sub_id) { // получаеем уведомление по айди
						case 1: {
							new str[256];
							format(str, sizeof(str), "{FFFF00}| {FFFFFF}Скрыто уведомление, под ID: {FFFF00}%d", sub_id);
							SendClientMessage(playerid, -1, str);
							return;
						}
					}
				}
			}
		}
	}
}

CMD:test_notif(playerid)
{
ShowNewNotification(playerid, 4, 10, 1, 1, "Тест уведомление, by Blydik(@io_blydik)", "");
}



stock ShowNotification(playerid, type, const text[], duration, const actionforBtn[], const textBtn[])
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, 251);
    BS_WriteValue(bitstream, PR_UINT32, 0x32);
    
    BS_WriteValue(bitstream, PR_INT32, type);
    
    BS_WriteValue(bitstream, PR_UINT16, strlen(text));
    BS_WriteValue(bitstream, PR_STRING, text);
    
    BS_WriteValue(bitstream, PR_INT32, duration);
    
    BS_WriteValue(bitstream, PR_UINT16, strlen(actionforBtn));
    BS_WriteValue(bitstream, PR_STRING, actionforBtn);
    
    BS_WriteValue(bitstream, PR_UINT16, strlen(textBtn));
    BS_WriteValue(bitstream, PR_STRING, textBtn);
    
    BS_Send(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);

    BS_Delete(bitstream);

	return true;
} 