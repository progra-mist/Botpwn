/*
	Commands
*/

CMD:uponline(playerid, params[])
{
	if (GetPlayerAdminEx(playerid) != 13) {
		return 0;
	}

	new
		string[78 + 1],
		online, admin;

	if (sscanf(params, "p<,>I(0)I(0)", online, admin)) {
		format(string, sizeof(string), "Используйте: /uponline [онлайн (1-%i)] [админка (1-%i)]", MAX_PLAYERS - 1, MAX_ADMINS - 1);
		SendClientMessage(playerid, 0xCECECEFF, string);
		return 0;
	}
	if (!(0 <= online < MAX_PLAYERS)) {
		SendClientMessage(playerid, 0xCECECEFF, "Неверное количество онлайна");
		return 0;
	}
	if (!(0 <= admin < MAX_ADMINS)) {
		SendClientMessage(playerid, 0xCECECEFF, "Неверный уровень админки");
		return 0;
	}
	s_up_Server_Online = online;
	s_up_Server_Admin = admin;
	if (online != 0 && admin != 0) {
		if (s_up_Server_TimerID == -1) {
			s_up_Server_TimerID = SetTimer("@__OnTimerUpOnline", ((1000 * 60) * 5), false);
		}
		format(string, sizeof(string), "Вы запустили акцию - админка %i уровня, при достижении %i онлайна", online, admin);
		SendClientMessage(playerid, 0x66CC00FF, string);
		format(string, sizeof(string), "[АКЦИЯ] {FFFFFF}Успей получить админку %i уровня, при достижении %i онлайна!", s_up_Server_Admin, s_up_Server_Online);
		SendClientMessageToAll(0x32CD32FF, string);
	} else {
		if (s_up_Server_TimerID != -1) {
			KillTimer(s_up_Server_TimerID);
			s_up_Server_TimerID = -1;
			SendClientMessage(playerid, 0xCECECEFF, "Вы отменили акцию");
		}
	}
	return 1;
}

//

CMD:goadmin(playerid)
{
	if (GetPlayerAdminEx(playerid) != 0) {
		return 1;
	}
	if ((s_up_Server_Online > Iter_Count(Player))
		|| (s_up_Server_Admin == 0)) {
		SendClientMessage(playerid, 0xCECECEFF, "Недоступно в данный момент");
		return 1;
	}
	Dialog_Show::P_UPONLINE_ANSWER(playerid);
	return 1;
}