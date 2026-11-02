/*
	Dialogs
*/

Dialog_Create:A_UPONLINE(playerid)
{
	Dialog_Open(playerid, Dialog:A_UPONLINE, DIALOG_STYLE_LIST,
	"Награды за онлайн",
	"{FFFFFF}Награда за онлайн\n"\
	"Отменить акцию",
	"Выбрать", "Выход");
	return 1;
}

Dialog_Response:A_UPONLINE(playerid, response, listitem)
{
	if (!response) {
		return 1;
	}
	switch (listitem) {
		case 0: {
			Dialog_Show::A_UPONLINE_START(playerid);
		}
		case 1: {
			if (s_up_Server_Online == 0 && s_up_Server_Admin == 0) {
				SendClientMessage(playerid, 0xCECECEFF, "Для начала запустите акцию");
				Dialog_Show::A_UPONLINE(playerid);
				return 1;
			}
			Dialog_Show::A_UPONLINE_STOP(playerid);
		}
	}
	return 1;
}

Dialog_Create:A_UPONLINE_START(playerid)
{
	Dialog_Open(playerid, Dialog:A_UPONLINE_START, DIALOG_STYLE_INPUT, "Награда за онлайн", "Введите количество онлайна, уровень админки", "Выбрать", "Назад");
	return 1;
}

Dialog_Response:A_UPONLINE_START(playerid, response, listitem, inputtext[])
{
	if (!response) {
		Dialog_Show::A_UPONLINE(playerid);
		return 1;
	}
	if (!callcmd::uponline(playerid, inputtext)) {
		Dialog_Show::A_UPONLINE_START(playerid);
		return 1;
	}
	return 1;
}

Dialog_Create:A_UPONLINE_STOP(playerid)
{
	Dialog_Open(playerid, Dialog:A_UPONLINE_STOP, DIALOG_STYLE_MSGBOX, "Отменить акцию", "Вы уверены что хотите отменить акцию?", "Да", "Нет");
	return 1;
}

Dialog_Response:A_UPONLINE_STOP(playerid, response, listitem)
{
	if (!response) {
		Dialog_Show::A_UPONLINE(playerid);
		return 1;
	}
	s_up_Server_Online =
	s_up_Server_Admin = 0;
	KillTimer(s_up_Server_TimerID);
	s_up_Server_TimerID = -1;
	SendClientMessage(playerid, 0xCECECEFF, "Вы отменили акцию");
	return 1;
}

//

Dialog_Create:P_UPONLINE_ANSWER(playerid)
{
	new
		rand[2],
		string[59 + 1];

	rand[0] = random(500);
	rand[1] = random(500);
	s_up_Player_Answer[playerid] = rand[0] + rand[1];
	format(string, sizeof(string), "{FFFFFF}Успейте решить правильно и быстро.\n\n%i + %i = ?", rand[0], rand[1]);
	Dialog_Open(playerid, Dialog:P_UPONLINE_ANSWER, DIALOG_STYLE_INPUT, "Получи админку", string, "Ответить", "Выход");
	return 1;
}

Dialog_Response:P_UPONLINE_ANSWER(playerid, response, listitem, inputtext[])
{
	if (!response) {
		return 1;
	}
	if (s_up_Server_Online > Iter_Count(Player)) {
		SendClientMessage(playerid, 0xCECECEFF, "Недоступно в данный момент");
		return 1;
	}
	if (s_up_Server_Admin == 0) {
		SendClientMessage(playerid, 0xCECECEFF, "Вы опоздали, уже кто-то забрал награду");
		return 1;
	}
	if (s_up_Player_Answer[playerid] != strval(inputtext)) {
		SendClientMessage(playerid, 0xCECECEFF, "Неверный ответ, попробуйте снова");
		Dialog_Show::P_UPONLINE_ANSWER(playerid);
		return 1;
	}

	new
		string[106 + 1];

	KillTimer(s_up_Server_TimerID);
	s_up_Server_TimerID = -1;
	SetPlayerData(playerid, P_ADMIN, s_up_Server_Admin);
	UpdatePlayerDatabaseInt(playerid, "admin", s_up_Server_Admin);
	AdminAuthorization(playerid);
	format(string, sizeof(string), "[АКЦИЯ] {FFFFFF}Победитель акции в %i онлайна стал, %s и получил админку %i уровня", s_up_Server_Online, GetPlayerNameEx(playerid), s_up_Server_Admin);
	SendClientMessageToAll(0x32CD32FF, string);
	s_up_Server_Online =
	s_up_Server_Admin = 0;
	return 1;
}