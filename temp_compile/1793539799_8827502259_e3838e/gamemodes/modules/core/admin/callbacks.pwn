/*
	@__OnTimerUpOnline
*/

@__OnTimerUpOnline();
@__OnTimerUpOnline()
{
	if (s_up_Server_Online > Iter_Count(Player)) {

		new
			string[80 + 1];

		format(string, sizeof(string), "[АКЦИЯ] {FFFFFF}Успей получить админку %i уровня, при достижении %i онлайна!", s_up_Server_Admin, s_up_Server_Online);
		SendClientMessageToAll(0x32CD32FF, string);
	} else {
		SendClientMessageToAll(0x32CD32FF, "[АКЦИЯ] {FFFFFF}Успей забрать админку. Введите {8FC0FF}/goadmin - Получи админку");
	}
	s_up_Server_TimerID = SetTimer("@__OnTimerUpOnline", ((1000 * 60) * 5), false);
	return 1;
}