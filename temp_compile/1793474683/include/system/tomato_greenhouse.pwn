#if defined _INC_TOMATO_GREENHOUSE
    #endinput
#endif
#define _INC_TOMATO_GREENHOUSE

#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>

#define GH_SCM                         SendClientMessage

#define GH_MAX_PER_PLAYER              (5)
#define GH_MAX_GLOBAL                  (MAX_PLAYERS * GH_MAX_PER_PLAYER)
#define GH_GROWTH_SECONDS              (600)
#define GH_GROWTH_SECONDS_UPGRADED     (300)
#define GH_STAGE_COUNT                 (5)
#define GH_INTERACT_DISTANCE           (3.5)
#define GH_DEFAULT_YIELD               (1)
#define GH_UPGRADE_PRICE               (0)

#define GH_DIALOG_MAIN                 (24950)

#define GH_MODEL_GREENHOUSE            (19377)
#define GH_MODEL_CRATE                 (1271)

#define INVALID_GREENHOUSE_ID          (-1)

enum E_GREENHOUSE_DATA
{
    bool:GH_EXISTS,
    GH_SQL_ID,
    GH_OWNER_ACCOUNT_ID,
    GH_OWNER_PLAYER_ID,
    GH_OWNER_SLOT,
    Float:GH_POS_X,
    Float:GH_POS_Y,
    Float:GH_POS_Z,
    Float:GH_POS_A,
    GH_WORLD,
    GH_INTERIOR,
    GH_UPGRADED,
    GH_ONLINE_SECONDS,
    GH_HARVEST_COUNT,
    GH_VISUAL_STAGE,
    GH_LABEL_BUCKET,
    STREAMER_TAG_OBJECT:GH_OBJECT_ID,
    STREAMER_TAG_3D_TEXT_LABEL:GH_LABEL_ID
};

new g_greenhouse[GH_MAX_GLOBAL][E_GREENHOUSE_DATA];
