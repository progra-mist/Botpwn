























new AttachedObjectBones[][20] = {
	"Спина",
	"Голова",
	"Левая рука",
	"Правая рука",
	"Левая нога",
	"Правая нога",
	"Левое бедро",
	"Правое бедро",
	"Левая стопа",
	"Правая стопа",
	"Правая икра",
	"Левая икра",
	"Левое предплечье",
	"Правое предплечье",
	"Левая ключица",
	"Правая ключица",
	"Шея",
	"Челюсть"
};

new
	PlayerText:pTD_AttachEditor[MAX_PLAYERS][8],
	Text:gTD_AttachEditor[24];

new
	gPlayerAttachedObjectBone[MAX_PLAYERS + 1][MAX_PLAYER_ATTACHED_OBJECTS],
	gPlayerAttachedObjectModel[MAX_PLAYERS + 1][MAX_PLAYER_ATTACHED_OBJECTS],
	Float:gPlayerAttachedObjectPos[MAX_PLAYERS + 1][MAX_PLAYER_ATTACHED_OBJECTS][9],
	Float:gPlayerEditObjectTD[MAX_PLAYERS + 1][MAX_PLAYER_ATTACHED_OBJECTS][9],
	bool:gPlayerUsesEditor[MAX_PLAYERS char],
	/*upd37 - fix*/
	Float:gPlayerEditorScale[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS] = {{0.0, ...}, ...},
	/*upd37 - fix*/
	Float:gPlayerEditorStep[MAX_PLAYERS] = {0.1, ...},
	gPlayerChooseIndex[MAX_PLAYERS char],

	aoe_str[900];