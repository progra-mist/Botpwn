#define DSI DIALOG_STYLE_INPUT
#define DSL DIALOG_STYLE_LIST  
#define H_T_OBJECT 1
#define H_T_3DTEXT 2
#define H_T_ACTOR  3
#define H_T_PICKUP 4
#define H_T_SHPERE 5
#define MAX_CREATE 75
enum HELP_CREATE
{
   H_TYPE,
   H_ID_NET,
   H_ID_OBJ,
   Text3D:H_ID_NET_3D,
   H_STRING[24],
   Float:H_X,
   Float:H_Y,
   Float:H_Z,
   Float:H_S    
}

new type_create[5][9] = {"Объект","3D Текст","Актер","Пикап","Сфера"};

new l_create[MAX_CREATE][HELP_CREATE];
new set_timer_create[MAX_PLAYERS];

cmd:create(playerid)
{
    if(id_cr() >= MAX_CREATE) SCM(playerid,-1,"Объектов больше чем ограничение");
    
    Dialog
    (
     playerid, 5011, DSL,
     "Помощник в создании | Меню",
     "Создать\n"\
     "Удалить\n"\
     "Список созданных",
     "Далее","Выйти"
    );
}

stock id_cr()
{
   new n;

   for(new w; w < MAX_CREATE;w++)
   {
      if(l_create[w][H_TYPE] == 0) 
      {
         n = w;
         break;
      }
   }

   return n;
}
public OnGameModeInit()
{
   print("[LAIRD_SYSTEM] Помощник в создании загружен");
    #if defined create_OnGameModeInit
        return create_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit create_OnGameModeInit
#if defined create_OnGameModeInit
    forward create_OnGameModeInit();
#endif

public OnPlayerEnterDynamicArea(playerid, areaid)
{
   if(l_create[0][H_ID_NET] <= areaid <= l_create[sizeof l_create - 1][H_ID_NET])
   {
      new text[35], id;
      for(new i;i < sizeof l_create;i++)
      {
         if(l_create[i][H_ID_NET] != areaid) continue;
         id = areaid;
         break;
      }
      format(text, sizeof text, "Ты вошел в сферу | ID: %d", l_create[id][H_ID_NET]);
      SendClientMessage(playerid, -1, text);
   }
    #if defined cr_OnPlayerEnterDynamicArea
        return cr_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea cr_OnPlayerEnterDynamicArea
#if defined cr_OnPlayerEnterDynamicArea
    forward cr_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
   if(dialogid == 5011)
   {
      if(response)
      {
          switch(listitem)
          {
            case 0:
            {
              Dialog
              (
                 playerid,5012,DSL,
                 "Помощник в создании | Создание",
                 "Объект\n"\
                 "3D текст\n"\
                 "Актер\n"\
                 "Пикап\n"\
                 "Сфера",
                 "Создать","Назад"
              );
            }
            case 1:
            {
              Dialog
              (
                 playerid,5013,DSL,
                 "Помощник в создании | Удалить",
                 "Объект\n"\
                 "3D текст\n"\
                 "Актер\n"\
                 "Пикап\n"\
                 "Сфера",
                 "Создать","Назад"
              );
            }
            case 2:
            {
              new Float:dist, count, text[256], loading[sizeof (text)+ 25] = {"{FFFFFF}Номер\tServer Id\tТип\tРасстояние\n"};

              for(new s;s < MAX_CREATE;s++)
              {
                 if(l_create[s][H_TYPE] == 0) continue;
                 dist = GetPlayerDistanceFromPoint(playerid, l_create[s][H_X],l_create[s][H_Y],l_create[s][H_Z]);

                 format
                 (
                     text,sizeof text,
                     "{FFFFFF}%d\t{FFFFFF}%d\t{FFFFFF}%s\t{FFFFFF}%.2f\n",
                     s + 1,
                     l_create[s][H_ID_NET],
                     type_create[l_create[s][H_TYPE] - 1],
                     dist
                 );

                 strcat(loading, text);
                 SetPlayerListitemValue(playerid, count ++, s);
              }
              if(!count) return SCM(playerid, -1, "Нет созданных");

              DialogCreate
              (
                 playerid,5014, DIALOG_STYLE_TABLIST_HEADERS,
                 "Помощник в создании | Список созданных",
                 loading,
                 "Создать","Назад"
              );  
            }         
         }
      }
   }
   if(dialogid == 5013)
   {
      if(response)
      {
         switch(listitem)
         {
             case 0:
             {
                new text[256], count, loading[sizeof (text)+ 15] = {"{FFFFFF}Номер\tServer Id\tModel Id\n"};
                for(new n;n < MAX_CREATE;n ++)
                {
                  if(l_create[n][H_TYPE] != H_T_OBJECT) continue;
                  format(text, sizeof text, "{FFFFFF}Объект %d\t{FFFFFF}%d\t{FFFFFF}%d\n", n, l_create[n][H_ID_NET], l_create[n][H_ID_OBJ]);
                  strcat(loading, text);
                  SetPlayerListitemValue(playerid, count, n);
                  count++;
                }
                if(!count) return SCM(playerid, -1, ""USC" Нету созданных объектов");
                DialogCreate
                (
                   playerid, 5020, DIALOG_STYLE_TABLIST_HEADERS,
                   "Помощник | Список объектов",
                   loading,
                   "Удалить", "Назад"
                );
             }
             case 1:
             {
                new text[256], count, loading[sizeof (text)+ 15] = {"{FFFFFF}Номер\tServer Id\tОписание\n"};

                for(new n;n < MAX_CREATE;n ++)
                {
                  if(l_create[n][H_TYPE] != H_T_3DTEXT) continue;
                  format(text, sizeof text, "{FFFFFF}Текст %d\t{FFFFFF}%d\t{FFFFFF}%s\n", n, l_create[n][H_ID_NET], l_create[n][H_STRING]);
                  strcat(loading, text);
                  SetPlayerListitemValue(playerid, count, n);
                  count++;
                }
                  if(!count) return SCM(playerid, -1, ""USC" Нету созданных 3D Текстов");
                DialogCreate
                (
                   playerid, 5021, DIALOG_STYLE_TABLIST_HEADERS,
                   "Помощник | Список 3D текстов",
                   loading,
                   "Удалить", "Назад"
                );
             }
             case 2:
             {
                new text[256], count, loading[sizeof (text)+ 15] = {"{FFFFFF}Номер\tServer Id\tОписание\n"};

                for(new n;n < MAX_CREATE;n ++)
                {
                  if(l_create[n][H_TYPE] != H_T_ACTOR) continue;
                  format(text, sizeof text, "{FFFFFF}Актер %d\t{FFFFFF}%d\t{FFFFFF}%s\n", n, l_create[n][H_ID_NET], l_create[n][H_STRING]);
                  strcat(loading, text);
                  SetPlayerListitemValue(playerid, count, n);
                  count++;
                }
                   if(!count) return SCM(playerid, -1, ""USC" Нету созданных актеров");
                DialogCreate
                (
                   playerid, 5022, DIALOG_STYLE_TABLIST_HEADERS,
                   "Помощник | Список Актеров",
                   loading,
                   "Удалить", "Назад"
                );
             }
             case 3:
             {
                new text[256], count, loading[sizeof (text)+ 15] = {"{FFFFFF}Номер\tServer Id\tModel Id\n"};
                for(new n;n < MAX_CREATE;n ++)
                {
                  if(l_create[n][H_TYPE] != H_T_PICKUP) continue;
                  format(text, sizeof text, "{FFFFFF}Пикап %d\t{FFFFFF}%d\t{FFFFFF}%d\n", n, l_create[n][H_ID_NET], l_create[n][H_ID_OBJ]);
                  strcat(loading, text);
                  SetPlayerListitemValue(playerid, count, n);
                  count++;
                }
                if(!count) return SCM(playerid, -1, ""USC" Нету созданных пикапов");

                DialogCreate
                (
                   playerid, 5023, DIALOG_STYLE_TABLIST_HEADERS,
                   "Помощник | Список пикапов",
                   loading,
                   "Удалить", "Назад"
                );
             }
             case 4:
             {
                new text[256], count, loading[sizeof (text)+ 15] = {"{FFFFFF}Номер\tServer Id\n"};

                for(new n;n < MAX_CREATE;n ++)
                {
                  if(l_create[n][H_TYPE] != H_T_SHPERE) continue;
                  format(text, sizeof text, "{FFFFFF}Сфера %d\t{FFFFFF}%d\n", n, l_create[n][H_ID_NET]);
                  strcat(loading, text);
                  SetPlayerListitemValue(playerid, count, n);
                  count++;
                }

                if(!count) return SCM(playerid, -1, ""USC" Нету созданных сфер");

                DialogCreate
                (
                   playerid, 5024, DIALOG_STYLE_TABLIST_HEADERS,
                   "Помощник | Список сфер",
                   loading,
                   "Удалить", "Назад"
                );
             }
         }
      }
   }
   if(dialogid == 5014)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem);

         EnablePlayerGPS(playerid, 55, l_create[id][H_X],l_create[id][H_Y],l_create[id][H_Z], "Отмечено на вашей карте");
      }
   }
   if(dialogid == 5020)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem), string[64];

         DestroyObject(l_create[id][H_ID_NET]);
         l_create[id][H_TYPE] = 0;
         l_create[id][H_ID_NET] = 0;
         l_create[id][H_ID_OBJ] = 0;
         l_create[id][H_X] = 0.0;
         l_create[id][H_Y] = 0.0;
         l_create[id][H_Z] = 0.0;

         format(string, sizeof string, "Объект %d был успешно удален");
         SCM(playerid, -1, string);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5021)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem), string[64];

         l_create[id][H_TYPE] = 0;
         l_create[id][H_ID_NET] = 0;
         l_create[id][H_ID_OBJ] = 0;
         l_create[id][H_X] = 0.0;
         l_create[id][H_Y] = 0.0;
         l_create[id][H_Z] = 0.0;
         DestroyDynamic3DTextLabel(l_create[id][H_ID_NET_3D]);
         l_create[id][H_ID_NET_3D] = Text3D:0;
         format(string, sizeof string, "3D Текст %d был успешно удален");
         SCM(playerid, -1, string);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5022)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem), string[64];
         DestroyActor(l_create[id][H_ID_NET]);
         l_create[id][H_TYPE] = 0;
         l_create[id][H_ID_NET] = 0;
         l_create[id][H_ID_OBJ] = 0;
         l_create[id][H_STRING] = 0;
         l_create[id][H_X] = 0.0;
         l_create[id][H_Y] = 0.0;
         l_create[id][H_Z] = 0.0;
         format(string, sizeof string, "Актер %d был успешно удален");
         SCM(playerid, -1, string);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5023)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem), string[64];
         DestroyPickup(l_create[id][H_ID_NET]);
         l_create[id][H_TYPE] = 0;
         l_create[id][H_ID_NET] = 0;
         l_create[id][H_ID_OBJ] = 0;
         l_create[id][H_X] = 0.0;
         l_create[id][H_Y] = 0.0;
         l_create[id][H_Z] = 0.0;
         format(string, sizeof string, "Пикап %d был успешно удален");
         SCM(playerid, -1, string);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5024)
   {
      if(response)
      {
         new id = GetPlayerListitemValue(playerid, listitem), string[64];
         DestroyDynamicArea(l_create[id][H_ID_NET]);
         l_create[id][H_TYPE] = 0;
         l_create[id][H_ID_NET] = 0;
         l_create[id][H_ID_OBJ] = 0;
         l_create[id][H_X] = 0.0;
         l_create[id][H_Y] = 0.0;
         l_create[id][H_Z] = 0.0;

         format(string, sizeof string, "Cфера %d был успешно удален");
         SCM(playerid, -1, string);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5012)
   {
      if(response)
      {
         switch(listitem)
         {
            case 0:
            {
               Dialog
               (
                  playerid, 5015, DSI,
                  "Помощник в создании | ID Объекта",
                  "Введите ID объекта которого нужно создать\n"\
                  "{FF0000}!{FFFFFF} Будьте осторожно есть объекты из-за которых может\n"\
                  "произойти краш",
                  "Создать", "Назад"
               );
            }
            case 1:
            {
               Dialog
               (
                  playerid, 5016, DSI,
                  "Помощник в создании | Описания 3D текста",
                  "Введите описание для 3D текста",
                  "Создать", "Назад"
               );
            }
            case 2:
            {
               Dialog
               (
                  playerid, 5017, DSI,
                  "Помощник в создании | Создание Актера",
                  "Введите имя для Актера и модель скина\n"\
                  "{FF0000}!{FFFFFF} Пример:Welsi_Studio, 122",\
                  "Создать", "Назад"
               );
            }
            case 3:
            {
               Dialog
               (
                  playerid, 5018, DSI,
                  "Помощник в создании | ID Модели",
                  "Введите ID модели для пикапа которого нужно создать\n"\
                  "{FF0000}!{FFFFFF} Если вы не знаете какие есть модели найдите в инетрнете,\n"\
                  "при не правильной модели произойдет краш",
                  "Создать", "Назад"
               );
            }
            case 4:
            {
               Dialog
               (
                  playerid, 5019, DSI,
                  "Помощник в создании | Размер сферы",
                  "Введите размер сферы\n"\
                  "{FF0000}!{FFFFFF} Пишите только целое число",
                  "Создать", "Назад"
               );
            }
         }
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5015)
   {
      if(response)
      {
         new id = strval(inputtext), Float:x, Float:y, Float:z;
         if(!strval(inputtext)) return SCM(playerid, -1, ""USC" Ошибка! Некорректный ввод");
         GetPlayerPos(playerid, x, y, z);
         SCM(playerid, -1, ""SC" Через 3 секунды появиться объект");
         set_timer_create[playerid] = SetTimerEx("CreateWelsi", 3000, false, "dddfff", playerid, H_T_OBJECT, id, x, y, z);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5016)
   {
      if(response)
      {
         new id[24], Float:x, Float:y, Float:z;

         if(sscanf(inputtext, "s[24]", id))
         {
            SendClientMessage(playerid, -1, ""USC" Неккорентый ввод");
         }
         printf("id = %s, input = %s", id, inputtext);
         GetPlayerPos(playerid, x, y, z);
         CreateWelsi(playerid, H_T_3DTEXT, 0, x, y, z, inputtext);
         //set_timer_create[playerid] = SetTimerEx("CreateWelsi", 3000, false, "dddfffs", playerid, H_T_3DTEXT, 0, x, y, z, inputtext);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5017)
   {
      if(response)
      {
         
         new id, name[24], Float:x, Float:y, Float:z;

         if(sscanf(inputtext, "P<,>s[24]d", name, id))
         {
            SendClientMessage(playerid, -1, ""USC" Неккорентый ввод");
            return 1;
         }
         printf("name = %s, input = %s", name, inputtext);
         GetPlayerPos(playerid, x, y, z);
         CreateWelsi(playerid, H_T_ACTOR, id, x, y, z, name);
         //set_timer_create[playerid] = SetTimerEx("CreateWelsi", 3000, false, "dddfffs", playerid, H_T_ACTOR, id, x, y, z, inputtext);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5018)
   {
      if(response)
      {
         new id = strval(inputtext), Float:x, Float:y, Float:z;
         if(954 <= id >= 19832) return SCM(playerid, -1, ""USC" Ошибка! Некорректный ввод");
         GetPlayerPos(playerid, x, y, z);
         SCM(playerid, -1, ""SC" Через 3 секунды появиться пикап");
         set_timer_create[playerid] = SetTimerEx("CreateWelsi", 3000, false, "dddfff", playerid, H_T_PICKUP, id, x, y, z);
      }
      else callcmd::create(playerid);
   }
   if(dialogid == 5019)
   {

      if(response)
      {
         new id = strval(inputtext), Float:x, Float:y, Float:z;
         if(0.1 <= id >= 500.0) return SCM(playerid, -1, ""USC" Ошибка! Некорректный ввод");
         GetPlayerPos(playerid, x, y, z);
         SCM(playerid, -1, ""SC" Через 3 секунды появиться сфера");
         set_timer_create[playerid] = SetTimerEx("CreateWelsi", 3000, false, "dddfff", playerid, H_T_SHPERE, id, x, y, z);
      }
      else callcmd::create(playerid);
   }

#if defined cr_OnDialogResponse
return cr_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse cr_OnDialogResponse
#if defined cr_OnDialogResponse
forward cr_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public:CreateWelsi(playerid, type, id, Float:x, Float:y, Float:z, const string[])
{
   new net_id;

   new Text3D:id_3D, id_n = id_cr();

   switch(type)
   {
      case H_T_OBJECT:
      {
         net_id = CreateObject(id, x, y, z, 0.0, 0.0, 0.0);

         l_create[id_n][H_TYPE] = H_T_OBJECT;
         l_create[id_n][H_ID_NET] = net_id;
         l_create[id_n][H_ID_OBJ] = id;
         l_create[id_n][H_X] = x;
         l_create[id_n][H_Y] = y;
         l_create[id_n][H_Z] = z;

         new File:file_create,info[128];

         file_create = fopen("createhelp.txt", io_append);

         format(info,sizeof(info),"CreateObject(%d, %.2f, %.2f, %.2f, 0.0, 0.0, 0.0, 0.0);\r", id, x, y, z);
  		   fwrite(file_create, info);
    	   fclose(file_create);

     	   SendClientMessage(playerid,-1,"Сохранено в createhelp.txt");
         print("[LAIRD_SYSTEM] createhelp.txt: update!");
      }
      case H_T_3DTEXT:
      {
         l_create[id_n][H_STRING] = '\0';

         strcat(l_create[id_n][H_STRING], string);

         id_3D = CreateDynamic3DTextLabel(l_create[id_n][H_STRING], 0xFFFFFFFF, x, y, z, 10.0);
         
         net_id = _: id_3D;
         l_create[id_n][H_TYPE] = H_T_3DTEXT;
         l_create[id_n][H_ID_NET] = net_id;
         l_create[id_n][H_ID_NET_3D] = id_3D;
         l_create[id_n][H_X] = x;
         l_create[id_n][H_Y] = y;
         l_create[id_n][H_Z] = z;
         new File:file_create,info[128];

         file_create = fopen("createhelp.txt", io_append);

         format(info,sizeof(info),"CreateDynamic3DTextLabel(%s, -1, %.2f, %.2f, %.2f, 10.0, 0);\r", l_create[id_n][H_STRING], x, y, z);
  		   fwrite(file_create, info);
    	   fclose(file_create);

     	   SendClientMessage(playerid,-1,"Сохранено в createhelp.txt");
         print("[LAIRD_SYSTEM] createhelp.txt: update!");
      }
      case H_T_ACTOR:
      {
         l_create[id_n][H_STRING] = '\0';
         strcat(l_create[id_n][H_STRING], string);

         net_id = CreateActorEx(l_create[id_n][H_STRING], "", id, x, y, z, 0.0);

         l_create[id_n][H_TYPE] = H_T_ACTOR;
         l_create[id_n][H_ID_NET] = net_id;
         l_create[id_n][H_ID_OBJ] = id;
         l_create[id_n][H_X] = x;
         l_create[id_n][H_Y] = y;
         l_create[id_n][H_Z] = z;

         new File:file_create,info[128];

         file_create = fopen("createhelp.txt", io_append);

         format(info,sizeof(info),"CreateActorEx(%s, "", %d, %.2f, %.2f, %.2f, 0.0);\r",l_create[id_n][H_STRING], id, x, y, z);
  		   fwrite(file_create, info);
    	   fclose(file_create);

     	   SendClientMessage(playerid,-1,"Сохранено в createhelp.txt");
         print("[LAIRD_SYSTEM] createhelp.txt: update!");
      }
      case H_T_PICKUP:
      {
         net_id = CreatePickup(id, 23, x, y, z, 0);

         l_create[id_n][H_TYPE] = H_T_PICKUP;
         l_create[id_n][H_ID_NET] = net_id;
         l_create[id_n][H_ID_OBJ] = id;
         l_create[id_n][H_X] = x;
         l_create[id_n][H_Y] = y;
         l_create[id_n][H_Z] = z;

         new File:file_create,info[128];

         file_create = fopen("createhelp.txt", io_append);

         format(info,sizeof(info),"CreatePickup(%d, 23, %.2f, %.2f, %.2f);\r", id, x, y, z);
  		   fwrite(file_create, info);
    	   fclose(file_create);

     	   SendClientMessage(playerid,-1,"Сохранено в createhelp.txt");
         print("[LAIRD_SYSTEM] createhelp.txt: update!");
      }
      case H_T_SHPERE:
      {
         net_id = CreateDynamicSphere(x, y, z, float(id));

         l_create[id_n][H_TYPE] = H_T_SHPERE;
         l_create[id_n][H_ID_NET] = net_id;
         l_create[id_n][H_ID_OBJ] = 0;
         l_create[id_n][H_X] = x;
         l_create[id_n][H_Y] = y;
         l_create[id_n][H_Z] = z;

         new File:file_create,info[128];

         file_create = fopen("createhelp.txt", io_append);

         format(info,sizeof(info),"CreateDynamicSphere(%.2f, %.2f, %.2f, %f);\r", x, y, z, float(id));
  		   fwrite(file_create, info);
    	   fclose(file_create);

     	   SendClientMessage(playerid,-1,"Сохранено в createhelp.txt");
         print("[LAIRD_SYSTEM] createhelp.txt: update!");
      }
   }
}
stock DialogCreate(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;//егор ссбонус
}