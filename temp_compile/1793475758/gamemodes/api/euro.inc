/*

if(dialogid == DIALOG_EURO_EXCHANGE)
	{
		if(!response) return 1;
		new amount;
		if(sscanf(inputtext, "d", amount))
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "Введите корректное число");
			return 1;
		}
		if(amount < EURO_EXCHANGE_MIN || amount > EURO_EXCHANGE_MAX)
		{
			new string[128];
			format(string, sizeof(string), "Количество должно быть от %d до %d Евро", EURO_EXCHANGE_MIN, EURO_EXCHANGE_MAX);
			SendClientMessage(playerid, 0xFFFFFFFF, string);
			return 1;
		}
		if(!Euro_HasEnough(playerid, amount))
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "У вас недостаточно Евро");
			return 1;
		}
		Euro_ExchangeToRubles(playerid, amount);
		new rubles = Euro_ToRubles(amount);
		new string[160];
		format(string, sizeof(string), "Вы обменяли %d Евро на %d рублей", amount, rubles);
		SendClientMessage(playerid, 0xFFFFFFFF, string);
		return 1;
   }
   
   В ONDIALOGRESPONSE
   
   автор меллисс
*/

#define EURO_TO_RUBLES_RATE (1000)
#define EURO_EXCHANGE_MIN (50)
#define EURO_EXCHANGE_MAX (10000)
#define EURO_MAX_BALANCE (1000000)
#define DIALOG_EURO_EXCHANGE (48291)

new PlayerEuroBalance[MAX_PLAYERS];

stock Euro_GetBalance(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	return PlayerEuroBalance[playerid];
}

stock Euro_HasEnough(playerid, amount)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(amount < 1) return 0;
	return (PlayerEuroBalance[playerid] >= amount);
}

stock Euro_Set(playerid, amount)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(amount < 0) amount = 0;
	if(amount > EURO_MAX_BALANCE) amount = EURO_MAX_BALANCE;
	PlayerEuroBalance[playerid] = amount;
	return 1;
}

stock Euro_Reset(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	PlayerEuroBalance[playerid] = 0;
	return 1;
}

stock Euro_Give(playerid, amount)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(amount < 1) return 0;
	new newbalance = PlayerEuroBalance[playerid] + amount;
	if(newbalance > EURO_MAX_BALANCE) newbalance = EURO_MAX_BALANCE;
	PlayerEuroBalance[playerid] = newbalance;
	return 1;
}

stock Euro_Take(playerid, amount)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(amount < 1) return 0;
	if(!Euro_HasEnough(playerid, amount)) return 0;
	PlayerEuroBalance[playerid] -= amount;
	return 1;
}

stock Euro_ToRubles(amount)
{
	return (amount * EURO_TO_RUBLES_RATE);
}

stock Euro_ExchangeToRubles(playerid, amount)
{
	if(!(0 <= playerid < MAX_PLAYERS)) return 0;
	if(amount < EURO_EXCHANGE_MIN || amount > EURO_EXCHANGE_MAX) return 0;
	if(!Euro_HasEnough(playerid, amount)) return 0;
	if(!Euro_Take(playerid, amount)) return 0;
	new rubles = Euro_ToRubles(amount);
	GivePlayerMoney(playerid, rubles);
	return 1;
}

CMD:myeuro(playerid, params[])
{
	new balance = Euro_GetBalance(playerid);
	new string[128];
	format(string, sizeof(string), "У вас на счету %d Евро", balance);
	SendClientMessage(playerid, 0xFFFFFFFF, string);
	return 1;
}

CMD:exchangeeuro(playerid, params[])
{
	new balance = Euro_GetBalance(playerid);
	new string[256];
	format(string, sizeof(string), "Ваш баланс: %d Евро\nВведите количество {FFFF00}Евро{FFFFFF} для{FFFF00} обмена\nМинимум {FFFF00}%d{FFFFFF}, максимум {FFFF00}%d\nКурс обмена: {FFFF00}1 Евро = %d рублей", balance, EURO_EXCHANGE_MIN, EURO_EXCHANGE_MAX, EURO_TO_RUBLES_RATE);
	ShowPlayerDialog(playerid, DIALOG_EURO_EXCHANGE, DIALOG_STYLE_INPUT, "Обмен Евро", string, "Обменять", "Отмена");
	return 1;
}

CMD:testgiveeuro(playerid, params[])
{
	new amount;
	if(sscanf(params, "d", amount))
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "Использование: /testgiveeuro [количество]");
		return 1;
	}
	if(amount < 1)
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "Количество должно быть больше нуля");
		return 1;
	}
	Euro_Give(playerid, amount);
	new string[128];
	format(string, sizeof(string), "Вам выдано %d Евро", amount);
	SendClientMessage(playerid, 0xFFFFFFFF, string);
	return 1;
}