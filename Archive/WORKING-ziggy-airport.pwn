// Screaming soundid Bank_044 - 10610
/*
{10610, !"Denise", !"(SCREAM)"},
{10611, !"Denise", !"(SCREAM)"},
{10612, !"Denise", !"(SCREAM)"},
{10613, !"Denise", !"(SCREAM)"},
{10614, !"Denise", !"(SCREAM)"},
{10615, !"Denise", !"(SCREAM)"},
{10616, !"Denise", !"(SCREAM)"},
{10617, !"Denise", !"(SCREAM)"},
{10618, !"Denise", !"(SCREAM)"},
{10619, !"Denise", !"(SCREAM)"},




make /sp save players POS in file

add turrets in safe zones. small explosions (maybe sound-only ones) at turrets, largest explosion at offending player pos
turrets use move object to rotate. 360 rotation in one second. onplayerupdate assumed, maybe check isinsafe or whatever it is.

//Add player radio-stations - user can add own URL
Add PRO radio stations - pros can broadcast radio stations
Tubes/Spheres  - change textures, rotation etc
Add turtles,shark
Play w/ tube rotation, then tube skin(s)
Set up /plate {name/number} for custom license plates
Add CrazyBobs CNR - http://cnr-radio.com/listen.m3u
Add check for /magnet so that player isn't swapped between cars if the target is occupied
Add single-player stuff (pickups etc)

/alarm = car alarm if non-owner enters playercar
/lights = car lighs on/off


*/

#include <a_samp>
#include <fixes2>
#include <foreach>
#include <a_vehicles>
#include <core>
#include <float>
#include <streamer>
#include "xadmin/XtremeAdmin.inc"


//   SAMP VERSION!
//-----------------------
#define SAMP03X
//-----------------------

#define TUNE
#if defined TUNE
#include <acuf> //Credits to AirKite (http://forum.sa-mp.com/showthread.php?t=281906)
//#include <zcmd> //Credits to Zeex (http://forum.sa-mp.com/showthread.php?t=91354)
#define TUNEDIALOGID 19000 //change if needed
#define MAX_COMP 40  //maximum number of available components for a vehicle model; I think 40 is enough
new ccount[MAX_PLAYERS];
new componentsid[MAX_PLAYERS][MAX_COMP];

#endif


#define FLYMODE
#if defined FLYMODE
// Players Move Speed
#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03

// Players Mode
#define CAMERA_MODE_NONE    	0
#define CAMERA_MODE_FLY     	1

// Key state definitions
#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8

// Enumeration for storing data about the player
enum noclipenum
{
	cameramode,
	flyobject,
	fmode,
	lrold,
	udold,
	lastmove,
	Float:accelmul
}
new noclipdata[MAX_PLAYERS][noclipenum];
#endif //flymode




#define USE_XADMIN
#if defined USE_XADMIN
	new bool:blnstealth[MAX_PLAYERS];
#endif

#define IRC_ECHO // IRC system
#if defined IRC_ECHO
	#include <sscanf2>
	#include <irc>
#endif


#if defined SAMP03X
#define VEH_THUMBNAILS
#if defined VEH_THUMBNAILS
	#define TOTAL_ITEMS         207
	#define SELECTION_ITEMS 	21
	#define ITEMS_PER_LINE  	7

	#define HEADER_TEXT "Vehicles"
	#define NEXT_TEXT   "Next"
	#define PREV_TEXT   "Prev"

	#define DIALOG_BASE_X   	75.0
	#define DIALOG_BASE_Y   	130.0
	#define DIALOG_WIDTH    	550.0
	#define DIALOG_HEIGHT   	180.0
	#define SPRITE_DIM_X    	60.0
	#define SPRITE_DIM_Y    	70.0

	new gTotalItems = TOTAL_ITEMS;
	new PlayerText:gCurrentPageTextDrawId[MAX_PLAYERS];
	new PlayerText:gHeaderTextDrawId[MAX_PLAYERS];
	new PlayerText:gBackgroundTextDrawId[MAX_PLAYERS];
	new PlayerText:gNextButtonTextDrawId[MAX_PLAYERS];
	new PlayerText:gPrevButtonTextDrawId[MAX_PLAYERS];
	new PlayerText:gSelectionItems[MAX_PLAYERS][SELECTION_ITEMS];
	new gSelectionItemsTag[MAX_PLAYERS][SELECTION_ITEMS];
	new gItemAt[MAX_PLAYERS];

	new gItemList[TOTAL_ITEMS] = {
	400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,
	431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,450,451,452,453,454,455,456,457,458,459,460,461,
	462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,
	493,494,495,496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,
	524,525,526,527,528,529,530,531,532,533,534,535,536,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,
	555,556,557,558,559,560,561,562,563,564,565,566,567,568,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,
	586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611
	};
#endif //VEH_THUMBNAILS
#endif //SAMP03X


//new Text:posTD;
new PlayerText:posTD[MAX_PLAYERS];
new PlayerText:Speedo[MAX_PLAYERS];
new PlayerText:Stats[MAX_PLAYERS];
new PlayerText:VehModel[MAX_PLAYERS];
enum SavePlayerPosEnum
{
	Float:LastX,
	Float:LastY,
	Float:LastZ
}
new SavePlayerPos[MAX_PLAYERS][SavePlayerPosEnum];


#define strCopy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)

// enable/disable individual script modules
#define TOYS
#define ANTICHEAT
#define RACES
#define DM
#define NEON
#define TEXTDRAWS
#define CRASH_POS
//#define COPS_CRIMS //cops and criminals system
//#define ANTI_CARJACK
//#define USE_SPAWN_INFO

#define HELMET_SLOT 1 //helmet object slot

#define WORLD_NORMAL 0
#define WORLD_DM 1
#define WORLD_GANG 2
#define WORLD_RESTREAM 666


#define KEY2_UNBOUND 0
#define KEY2_FLIP 1
#define KEY2_RAMP 2
#define KEY2_SKULLS 3
#define KEY2_STOP 4

#define KEYY_UNBOUND 0
#define KEYY_MENU 1
#define KEYY_DM 2
#define KEYY_CAR 3
#define KEYY_GUN 4

#define KEYN_UNBOUND 0
#define KEYN_STOP 1
#define KEYN_RAMP 2
#define KEYN_MINE 3
#define KEYN_SKULLS 4
#define KEYN_FLIP 5
#define KEYN_EJECT 6

new pcolor[MAX_PLAYERS]; // save players initial/changed color
new PlayerColors[200] = {
0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,0xF4A460FF,
0xEE82EEFF,0xFFD720FF,0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,0x10DC29FF,
0x534081FF,0x0495CDFF,0xEF6CE8FF,0xBD34DAFF,0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,0x65ADEBFF,
0x5C1ACCFF,0xF2F853FF,0x11F891FF,0x7B39AAFF,0x53EB10FF,0x54137DFF,0x275222FF,0xF09F5BFF,0x3D0A4FFF,
0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,0x057F94FF,
0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,0x93AB1CFF,0x95BAF0FF,0x369976FF,0x18F71FFF,
0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,0x3C1C0DFF,0x12D6D4FF,
0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,0x2FD9DEFF,
0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,0x3214AAFF,
0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,0xDCDE3DFF,
0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,0xD8C762FF,
0xD8C762FF,0xFF8C13FF,0xC715FFFF,0x20B2AAFF,0xDC143CFF,0x6495EDFF,0xf0e68cFF,0x778899FF,0xFF1493FF,
0xF4A460FF,0xEE82EEFF,0xFFD720FF,0x8b4513FF,0x4949A0FF,0x148b8bFF,0x14ff7fFF,0x556b2fFF,0x0FD9FAFF,
0x10DC29FF,0x534081FF,0x0495CDFF,0xEF6CE8FF,0xBD34DAFF,0x247C1BFF,0x0C8E5DFF,0x635B03FF,0xCB7ED3FF,
0x65ADEBFF,0x5C1ACCFF,0xF2F853FF,0x11F891FF,0x7B39AAFF,0x53EB10FF,0x54137DFF,0x275222FF,0xF09F5BFF,
0x3D0A4FFF,0x22F767FF,0xD63034FF,0x9A6980FF,0xDFB935FF,0x3793FAFF,0x90239DFF,0xE9AB2FFF,0xAF2FF3FF,
0x057F94FF,0xB98519FF,0x388EEAFF,0x028151FF,0xA55043FF,0x0DE018FF,0x93AB1CFF,0x95BAF0FF,0x369976FF,
0x18F71FFF,0x4B8987FF,0x491B9EFF,0x829DC7FF,0xBCE635FF,0xCEA6DFFF,0x20D4ADFF,0x2D74FDFF,0x3C1C0DFF,
0x12D6D4FF,0x48C000FF,0x2A51E2FF,0xE3AC12FF,0xFC42A8FF,0x2FC827FF,0x1A30BFFF,0xB740C2FF,0x42ACF5FF,
0x2FD9DEFF,0xFAFB71FF,0x05D1CDFF,0xC471BDFF,0x94436EFF,0xC1F7ECFF,0xCE79EEFF,0xBD1EF2FF,0x93B7E4FF,
0x3214AAFF,0x184D3BFF,0xAE4B99FF,0x7E49D7FF,0x4C436EFF,0xFA24CCFF,0xCE76BEFF,0xA04E0AFF,0x9F945CFF,
0xDCDE3DFF,0x10C9C5FF,0x70524DFF,0x0BE472FF,0x8A2CD7FF,0x6152C2FF,0xCF72A9FF,0xE59338FF,0xEEDC2DFF,
0xD8C762FF,0xD8C762FF
};

#define CHICKEN 16776
#define COW 11470
#define MINE 2918
#define RAMP 1634
#define SPECIAL_ACTION_PISSING 68

#define D_TELE 1200
#define D_CAR 1201
#define D_STUNT 1202
#define D_FR 1203
#define D_DM 1204
#define D_GANG 1205
#define D_CASINO 1206
#define D_TRAINS 1207
#define D_BASEJUMP 1208
#define D_FIGHT 1209
#define D_COMMANDS1 1210
#define D_BOATS 1211
#define D_WHEELS 1212
#define D_FASTCARS 1213
#define D_BIKES 1214
#define D_TRUCKS 1215
#define D_LEFTOVERS 1216
#define D_RULES 1217
#define D_WHATEVER 1218
#define D_GUNS 1219
#define D_PLANES 1220
#define D_HELLO 1221
#define D_HELLOS 1222
#define D_WEATHER 1223
#define D_COLOR 1224
#define D_DRUNK 1225
#define D_PAINTJOB 1226
#define D_NEON 1227
#define D_PCOLOR 1228
#define D_SETSPAWN 1229
#define D_KEY2 1230
#define D_AIRPORTS 1231
#define D_STADIUMS 1232
#define D_INTERIORS 1233
#define D_CITIES 1234
#define D_HELP 1235
#define D_HELP2 1236
#define D_KEYY 1237
#define D_KEYN 1238
#define D_MENU 1239
#define D_HELMET 1240
#define D_VRACERS 1241
#define D_VMUSCLELOW 1242
#define D_V2DOOR 1243
#define D_V4DOOR 1244
#define D_VBIKES 1245
#define D_VCIVIL 1246
#define D_VGOVT 1247
#define D_VHTRUCK 1248
#define D_VLTRUCK 1249
#define D_VRCCAR 1250
#define D_VREC 1251
#define D_VSUV 1252
#define D_VTRAILER 1253
#define D_VPLANE 1254
#define D_VBOAT 1255
#define D_SOUNDS 1256
#define D_SOUNDS2 1257
#define D_RADIO 1258
#define D_RADIOPOLICE 1259
#define D_RADIOHAM 1260
#define D_RADIOAIR 1261
#define D_RADIOMUSIC 1262
#define D_TUNED 1265
#define D_CREDITS 1266
#define D_RADIO_PINPUT 1267
#define D_COMMANDS2 1268
#define D_COMMANDS3 1269
#define D_COMMANDS4 1270
#define D_COMMANDS5 1271
#define D_COMMANDS6 1272
#define D_COMMANDS7 1273
#define D_COMMANDS8 1274
#define D_COMMANDS9 1275
#define D_COMMANDS10 1276
#define D_COMMANDS11 1277
#define D_COMMANDS12 1278
#define D_COMMANDS13 1279
#define D_COMMANDS14 1280
#define D_COMMANDS15 1281
#define D_COMMANDS16 1282
#define D_COMMANDS17 1283
#define D_COMMANDS18 1284
#define D_PLATE 1285
#define D_CAROPTIONS 1286
#define D_TUT1 1287
#define D_TUT2 1288
#define D_TUT3 1289
#define D_TUT4 1290
#define D_TUT5 1291
#define D_TUT6 1292
#define D_TUT7 1293



//vehicle bits
#define VEHI_DIS        5.0
#define MIN_VEHI_ID		400
#define MAX_VEHI_ID		611

#define vHUNTER 425 //guns
#define vRHINO  432 //guns
#define vHYDRA  520 //guns
#define vSEASPARROW 447 //guns
#define vRCPLANE    464 // guns
#define vGOBLIN     501 //guns
//#define vBLOODRING  504
#define RC_BANDIT	441
#define RC_BARON    464
#define RC_GOBLIN   501
#define RC_RAIDER   465
#define D_TRAM      449
#define RC_TANK     564
#define RC_CAM      594
#define D_AT400     577
#define D_TRAIN     537
#define D_TRAIN2     538

//vehicleid limits
#define MIN_VEHI_ID		400
#define MAX_VEHI_ID		611

// Colors
#define yellow 0xFFFF00AA
#define green 0x33FF33AA
#define red 0xFF0000AA
#define white 0xFFFFFFAA
#define pink 0xCCFF00FFAA
#define blue 0x00FFFFAA
#define grey 0xC0C0C0AA
#define C_TIP FF66FF
#define C_CONFIRM 33AA33
#define C_ERROR CC0000
#define C_SYSTEM C0C0C0
#define C_RACE 33CCFF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_PURPLE 0x9933CCAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xCC0000AA
#define COLOR_SYSTEM COLOR_GREY
#define COLOR_CONFIRM COLOR_GREEN
#define COLOR_ERROR 0xCC0000AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_PINK 0xFF66FFAA
#define COLOR_BLUE 0x0000BBAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_DARKRED 0x660000AA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_BRIGHTGREEN 0x7CFC00FF
#define COLOR_DARKBLUE 0x000080AFF
#define COLOR_VIOLETRED 0xDB7093FF
#define COLOR_BROWN 0x8B4513FF
#define COLOR_GREENYELLOW 0xADFF2FFF
#define COLOR_THISTLE 0xD8BFD8FF
#define COLOR_TURQUISE 0x48D1CCFF
#define COLOR_MAROON 0x800000FF
#define COLOR_STEELBLUE 0xB0C4DEFF
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_LIGHTGREEN 0x00FF7FFF
#define COLOR_VIOLET 0xEE82EEFF
#define COLOR_SILVER 0xC0C0C0FF
#define COLOR_LIGHTRED 0xFF99AADD
#define COLOR_BLACK 0x000000FF
#define messagecolor 0xAA3333AA


new logintimer[MAX_PLAYERS];


static VehicleLockData[MAX_VEHICLES] = false; 

#define strCopy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)


#define NO_PLAYER_HOME  255

//IRC
#if defined IRC_ECHO

// Name that everyone will see
#if defined SAMP03X
#define BOT_1_NICKNAME "B3x1test"
#else
#define BOT_1_NICKNAME "B1test"
#endif
// Name that will only be visible in a whois
#define BOT_1_REALNAME "SA-MP Bot"
// Name that will be in front of the hostname (username@hostname)
#define BOT_1_USERNAME "bot1test"

#if defined SAMP03X
#define BOT_2_NICKNAME "B3x2test"
#else
#define BOT_2_NICKNAME "B2test"
#endif
#define BOT_2_REALNAME "SA-MP Bottest"
#define BOT_2_USERNAME "bot1test"

#define IRC_SERVER "irc.gamesurge.net"
#define IRC_PORT (6667)
#if defined SAMP03X
#define IRC_CHANNEL "#Everystuff.03e"
#else
#define IRC_CHANNEL "#Everystuff.03e"
#endif

// Maximum number of bots in the filterscript
#define MAX_BOTS (2)

#define PLUGIN_VERSION "1.4.3"

new botIDs[MAX_BOTS], groupID;

/*
	When the filterscript is loaded, two bots will connect and a group will be
	created for them.
*/


#endif //irc_echo

// NUKE Vars
//Global Vars, top of your script
new intNukeDuration = 30;
new Float:NukeOriginX, Float:NukeOriginY, Float:NukeOriginZ;
new NukeObject;
new bool:blnNukeActive;
new bool:blnPlayerRadioactive[MAX_PLAYERS];

//Add to your timer list (top of script): new tenmintimer,fivesectimer,onesectimer,fivemintimer,onemintimer,hidespamtimer;
new tmrNuke;
// END NUKE

#if defined TOYS
#define DIALOG_ATTACH_INDEX             13500
#define DIALOG_ATTACH_INDEX_SELECTION   DIALOG_ATTACH_INDEX+1
#define DIALOG_ATTACH_EDITREPLACE       DIALOG_ATTACH_INDEX+2
#define DIALOG_ATTACH_MODEL_SELECTION   DIALOG_ATTACH_INDEX+3
#define DIALOG_ATTACH_BONE_SELECTION    DIALOG_ATTACH_INDEX+4

enum AttachmentEnum
{
    attachmodel,
    attachname[24]
}

new AttachmentObjects[][AttachmentEnum] = {
{18632, "FishingRod"},
{18633, "GTASAWrench1"},
{18634, "GTASACrowbar1"},
{18635, "GTASAHammer1"},
{18636, "PoliceCap1"},
{18637, "PoliceShield1"},
{18638, "HardHat1"},
{18639, "BlackHat1"},
{18640, "Hair1"},
{18975, "Hair2"},
{19136, "Hair4"},
{19274, "Hair5"},
{18641, "Flashlight1"},
{18642, "Taser1"},
{18643, "LaserPointer1"},
{19080, "LaserPointer2"},
{19081, "LaserPointer3"},
{19082, "LaserPointer4"},
{19083, "LaserPointer5"},
{19084, "LaserPointer6"},
{18644, "Screwdriver1"},
{18645, "MotorcycleHelmet1"},
{18865, "MobilePhone1"},
{18866, "MobilePhone2"},
{18867, "MobilePhone3"},
{18868, "MobilePhone4"},
{18869, "MobilePhone5"},
{18870, "MobilePhone6"},
{18871, "MobilePhone7"},
{18872, "MobilePhone8"},
{18873, "MobilePhone9"},
{18874, "MobilePhone10"},
{18875, "Pager1"},
{18890, "Rake1"},
{18891, "Bandana1"},
{18892, "Bandana2"},
{18893, "Bandana3"},
{18894, "Bandana4"},
{18895, "Bandana5"},
{18896, "Bandana6"},
{18897, "Bandana7"},
{18898, "Bandana8"},
{18899, "Bandana9"},
{18900, "Bandana10"},
{18901, "Bandana11"},
{18902, "Bandana12"},
{18903, "Bandana13"},
{18904, "Bandana14"},
{18905, "Bandana15"},
{18906, "Bandana16"},
{18907, "Bandana17"},
{18908, "Bandana18"},
{18909, "Bandana19"},
{18910, "Bandana20"},
{18911, "Mask1"},
{18912, "Mask2"},
{18913, "Mask3"},
{18914, "Mask4"},
{18915, "Mask5"},
{18916, "Mask6"},
{18917, "Mask7"},
{18918, "Mask8"},
{18919, "Mask9"},
{18920, "Mask10"},
{18921, "Beret1"},
{18922, "Beret2"},
{18923, "Beret3"},
{18924, "Beret4"},
{18925, "Beret5"},
{18926, "Hat1"},
{18927, "Hat2"},
{18928, "Hat3"},
{18929, "Hat4"},
{18930, "Hat5"},
{18931, "Hat6"},
{18932, "Hat7"},
{18933, "Hat8"},
{18934, "Hat9"},
{18935, "Hat10"},
{18936, "Helmet1"},
{18937, "Helmet2"},
{18938, "Helmet3"},
{18939, "CapBack1"},
{18940, "CapBack2"},
{18941, "CapBack3"},
{18942, "CapBack4"},
{18943, "CapBack5"},
{18944, "HatBoater1"},
{18945, "HatBoater2"},
{18946, "HatBoater3"},
{18947, "HatBowler1"},
{18948, "HatBowler2"},
{18949, "HatBowler3"},
{18950, "HatBowler4"},
{18951, "HatBowler5"},
{18952, "BoxingHelmet1"},
{18953, "CapKnit1"},
{18954, "CapKnit2"},
{18955, "CapOverEye1"},
{18956, "CapOverEye2"},
{18957, "CapOverEye3"},
{18958, "CapOverEye4"},
{18959, "CapOverEye5"},
{18960, "CapRimUp1"},
{18961, "CapTrucker1"},
{18962, "CowboyHat2"},
{18963, "CJElvisHead"},
{18964, "SkullyCap1"},
{18965, "SkullyCap2"},
{18966, "SkullyCap3"},
{18967, "HatMan1"},
{18968, "HatMan2"},
{18969, "HatMan3"},
{18970, "HatTiger1"},
{18971, "HatCool1"},
{18972, "HatCool2"},
{18973, "HatCool3"},
{18974, "MaskZorro1"},
{18976, "MotorcycleHelmet2"},
{18977, "MotorcycleHelmet3"},
{18978, "MotorcycleHelmet4"},
{18979, "MotorcycleHelmet5"},
{19006, "GlassesType1"},
{19007, "GlassesType2"},
{19008, "GlassesType3"},
{19009, "GlassesType4"},
{19010, "GlassesType5"},
{19011, "GlassesType6"},
{19012, "GlassesType7"},
{19013, "GlassesType8"},
{19014, "GlassesType9"},
{19015, "GlassesType10"},
{19016, "GlassesType11"},
{19017, "GlassesType12"},
{19018, "GlassesType13"},
{19019, "GlassesType14"},
{19020, "GlassesType15"},
{19021, "GlassesType16"},
{19022, "GlassesType17"},
{19023, "GlassesType18"},
{19024, "GlassesType19"},
{19025, "GlassesType20"},
{19026, "GlassesType21"},
{19027, "GlassesType22"},
{19028, "GlassesType23"},
{19029, "GlassesType24"},
{19030, "GlassesType25"},
{19031, "GlassesType26"},
{19032, "GlassesType27"},
{19033, "GlassesType28"},
{19034, "GlassesType29"},
{19035, "GlassesType30"},
{19036, "HockeyMask1"},
{19037, "HockeyMask2"},
{19038, "HockeyMask3"},
{19039, "WatchType1"},
{19040, "WatchType2"},
{19041, "WatchType3"},
{19042, "WatchType4"},
{19043, "WatchType5"},
{19044, "WatchType6"},
{19045, "WatchType7"},
{19046, "WatchType8"},
{19047, "WatchType9"},
{19048, "WatchType10"},
{19049, "WatchType11"},
{19050, "WatchType12"},
{19051, "WatchType13"},
{19052, "WatchType14"},
{19053, "WatchType15"},
{19085, "EyePatch1"},
{19086, "ChainsawDildo1"},
{19090, "PomPomBlue"},
{19091, "PomPomRed"},
{19092, "PomPomGreen"},
{19093, "HardHat2"},
{19094, "BurgerShotHat1"},
{19095, "CowboyHat1"},
{19096, "CowboyHat3"},
{19097, "CowboyHat4"},
{19098, "CowboyHat5"},
{19099, "PoliceCap2"},
{19100, "PoliceCap3"},
{19101, "ArmyHelmet1"},
{19102, "ArmyHelmet2"},
{19103, "ArmyHelmet3"},
{19104, "ArmyHelmet4"},
{19105, "ArmyHelmet5"},
{19106, "ArmyHelmet6"},
{19107, "ArmyHelmet7"},
{19108, "ArmyHelmet8"},
{19109, "ArmyHelmet9"},
{19110, "ArmyHelmet10"},
{19111, "ArmyHelmet11"},
{19112, "ArmyHelmet12"},
{19113, "SillyHelmet1"},
{19114, "SillyHelmet2"},
{19115, "SillyHelmet3"},
{19116, "PlainHelmet1"},
{19117, "PlainHelmet2"},
{19118, "PlainHelmet3"},
{19119, "PlainHelmet4"},
{19120, "PlainHelmet5"},
{19137, "CluckinBellHat1"},
{19138, "PoliceGlasses1"},
{19139, "PoliceGlasses2"},
{19140, "PoliceGlasses3"},
{19141, "SWATHelmet1"},
{19142, "SWATArmour1"},
{19160, "HardHat3"},
{19161, "PoliceHat1"},
{19162, "PoliceHat2"},
{19163, "GimpMask1"},
{19317, "bassguitar01"},
{19318, "flyingv01"},
{19319, "warlock01"},
{19330, "fire_hat01"},
{19331, "fire_hat02"},
{19346, "hotdog01"},
{19347, "badge01"},
{19348, "cane01"},
{19349, "monocle01"},
{19350, "moustache01"},
{19351, "moustache02"},
{19352, "tophat01"},
{19487, "tophat02"},
{19488, "HatBowler6"},
{19513, "whitephone"},
{19515, "GreySwatArm"}
};

new AttachmentBones[][24] = {
{"Spine"},
{"Head"},
{"Left upper arm"},
{"Right upper arm"},
{"Left hand"},
{"Right hand"},
{"Left thigh"},
{"Right thigh"},
{"Left foot"},
{"Right foot"},
{"Right calf"},
{"Left calf"},
{"Left forearm"},
{"Right forearm"},
{"Left clavicle"},
{"Right clavicle"},
{"Neck"},
{"Jaw"}
};

#endif

new aWeaponNames[][32] = {
	{"Unarmed (Fist)"}, // 0
	{"Brass Knuckles"}, // 1
	{"Golf Club"}, // 2
	{"Night Stick"}, // 3
	{"Knife"}, // 4
	{"Baseball Bat"}, // 5
	{"Shovel"}, // 6
	{"Pool Cue"}, // 7
	{"Katana"}, // 8
	{"Chainsaw"}, // 9
	{"Purple Dildo"}, // 10
	{"Big White Vibrator"}, // 11
	{"Medium White Vibrator"}, // 12
	{"Small White Vibrator"}, // 13
	{"Flowers"}, // 14
	{"Cane"}, // 15
	{"Grenade"}, // 16
	{"Teargas"}, // 17
	{"Molotov"}, // 18
	{" "}, // 19
	{" "}, // 20
	{" "}, // 21
	{"Colt 45"}, // 22
	{"Colt 45 (Silenced)"}, // 23
	{"Desert Eagle"}, // 24
	{"Normal Shotgun"}, // 25
	{"Sawnoff Shotgun"}, // 26
	{"Combat Shotgun"}, // 27
	{"Micro Uzi)"}, // 28
	{"MP5"}, // 29
	{"AK47"}, // 30
	{"M4"}, // 31
	{"Tec9"}, // 32
	{"Country Rifle"}, // 33
	{"Sniper Rifle"}, // 34
	{"RPG Launcher"}, // 35
	{"HS Rocket Launcher"}, // 36
	{"Flamethrower"}, // 37
	{"Minigun"}, // 38
	{"Satchel Charge"}, // 39
	{"Detonator"}, // 40
	{"Spray Can"}, // 41
	{"Fire Extinguisher"}, // 42
	{"Camera"}, // 43
	{"Night Goggles"}, // 44
	{"Infrared Goggles"}, // 45
	{"Parachute"}, // 46
	{"Fake Pistol"} // 47
};


//for dcmd commands
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define GetStringArg(%1,%2) for(new x = 0; getarg(%1,x) != '\0'; x++) %2[x] = getarg(%1,x)

//console chars fix
#define FixConsole(%1) for(new rSt;rSt<strlen(%1);rSt++) if(%1[rSt]>191 && %1[rSt]<240) %1[rSt]-=64; else if(%1[rSt]>239 && %1[rSt]<256) %1[rSt]-=16; else if (%1[rSt] == 168) %1[rSt]+=72; else if (%1[rSt] == 184) %1[rSt]+=57

// holdin key down
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

//==================================================================
//pplayer variables
new pro[MAX_PLAYERS];
new vplate[MAX_VEHICLES][32];
new inonplayerconnect[MAX_PLAYERS]; // is player in onplayerconnect
new reserve[MAX_PLAYERS];
#if defined COPS_CRIMS
new cop[MAX_PLAYERS];
new criminal[MAX_PLAYERS];
#endif
new blockregister[MAX_PLAYERS]; // block player register/login
new frozen[MAX_PLAYERS];
new safe[MAX_PLAYERS];
new carjack[MAX_PLAYERS];
//new chatbubbleshow[MAX_PLAYERS];
new showchattime[MAX_PLAYERS];
new inonplayerrequestclass[MAX_PLAYERS]; // is player in onplayerrequestclass
new pvehicleid[MAX_PLAYERS]; // player vehicles id
new pmodelid[MAX_PLAYERS]; // players vehicles model id
new pmoney[MAX_PLAYERS]; //player money
new lastchat[MAX_PLAYERS][128]; //chat spam support
new lastpm[MAX_PLAYERS][128]; //pm spam support
new quiet[MAX_PLAYERS]; // 1 = dont hear ppl using /s
new hideui[MAX_PLAYERS];  //toggle to display the UI or not
new pstate[MAX_PLAYERS]; // current player state (DRIVER, PASSENGER, ON_FOOT)
new chicken[MAX_PLAYERS]; //assigned to objectid of player spawned chicken
new cow[MAX_PLAYERS]; //assigned to objectid of player spawned cow
new mine[MAX_PLAYERS]; // assigned to player spawn stunt mine
new ramp[MAX_PLAYERS]; // assigned to player spawn ramp
new gTeam[MAX_PLAYERS]; // Tracks the team assignment for each player WAS STATIC
new godtimer[MAX_PLAYERS]; // god command spam timer
new pskin[MAX_PLAYERS]; //player skin
new key2[MAX_PLAYERS]; // 2 key assignment
new keyy[MAX_PLAYERS]; //Y key assignment
new keyn[MAX_PLAYERS]; // N key assignment
new skulls[MAX_PLAYERS]; // car catapult pickup
new godmode[MAX_PLAYERS]; // is player god mode
new cantgod[MAX_PLAYERS]; // cannot enter god mode
new helikills[MAX_PLAYERS]; // number of helikills. 3 = kick
new minutesplayed[MAX_PLAYERS]; // number of mins played total
new gPlayerUsingLoopingAnim[MAX_PLAYERS]; //animation system
new connected[MAX_PLAYERS]; // is player connected
new firstspawn[MAX_PLAYERS]; // is player in first-spawn since connecting
new playticks[MAX_PLAYERS]; // player 'ticks' (seconds, currently)
new horn[MAX_PLAYERS]; // is player using train horn
new hassnos[MAX_PLAYERS]; // is player in snos mode
new setspawn[MAX_PLAYERS]; // set spawn location variable
new saveint[MAX_PLAYERS]; // player interior
new playercar[MAX_PLAYERS]; //player spawned cars
new playertrailer[MAX_PLAYERS]; //player spawned trailer
new jump[MAX_PLAYERS]; // is player in /jump mode
new radio[MAX_PLAYERS]; //is radio on.off
new pname[MAX_PLAYERS][MAX_PLAYER_NAME]; //playername
new stroriginalname[MAX_PLAYERS][MAX_PLAYER_NAME]; // Name before enabling stealth mode
new afk[MAX_PLAYERS]; // is player in afk mode
new storedint[MAX_PLAYERS]; //stored interior for /back command
new pinterior[MAX_PLAYERS]; // current player interior
new pworld[MAX_PLAYERS]; // player world
new tpallow[MAX_PLAYERS]; // allow ppl to tp to them?
new daynight[MAX_PLAYERS]; //daynight cycle
new kills[MAX_PLAYERS]; // number of kills
new helmet[MAX_PLAYERS]; // is player wearing helmet
new RaceParticipant[MAX_PLAYERS]; // is player racing
new firemeobject[MAX_PLAYERS]; //fireme flame object
new bool:blnIllegalWeaponReported[MAX_PLAYERS];

new Float:saveposx[MAX_PLAYERS],Float:saveposy[MAX_PLAYERS],Float:saveposz[MAX_PLAYERS]; // for /sp lp
new Float:storedx[MAX_PLAYERS],Float:storedy[MAX_PLAYERS],Float:storedz[MAX_PLAYERS],Float:storeda[MAX_PLAYERS]; //stored coords for /back command after choosing car

new bool:badcar[MAX_PLAYERS]; // car has guns
new bool:cantrace[MAX_PLAYERS]; //is player banned from races
new bool:aircraft[MAX_PLAYERS]; //is player in aircraft
new bool:policecar[MAX_PLAYERS]; //is player in police vehicle
new bool:firecar[MAX_PLAYERS]; //is player in fire/EMS vehicle
new bool:cancount[MAX_PLAYERS]; //can player use /count command
new bool:gblnCanCount[MAX_PLAYERS]; // can player us /count
new bool:gblnIsMuted[MAX_PLAYERS][MAX_PLAYERS]; //Global array that allows players to mute others

//===============================================================================
new Float:OPTDamt;
new Float:OPTDhealth;
new animation[200]; //animation system
new vobject[MAX_VEHICLES]; // gunship and other vehicle attached objects
new magnet[MAX_PLAYERS]; // cargobob magnet
new attached[MAX_PLAYERS]; // is car attahced to magnet
new occupied[MAX_VEHICLES]; //is someone in car
new dumper[11]; // for dumper rain
new dumptimer;
new tmrCountDown; // 321go count timer for /count command
new automsg; // 10 min autospam chat msg
new params2[1]; // to send null params when using dcmd commands within functions/routines. its a workaround.
new cannon1,cannon2,cannon3,cannon4,cannon5,cannon6,cannon7; // car launcher (skulls) pickups
//new string8[8]; //
new string16[16]; //damage bubbles
new string32[32]; //common 32 stringnew hstnme
new string64[64]; //commonly used 64 string
new string128[128]; // commonly used 128 string
new string256[256]; // commonly used 256 string
new Float:playerx,Float:playery,Float:playerz,Float:playera,Float:carx,Float:cary,Float:carz;


new hstnme; // increment for hostname-change every minute


//               TIMERS!!!!!!!!            //
new tenmintimer,fivesectimer,onesectimer,fivemintimer,onemintimer,hidespamtimer; // timers
//-------------------------------------------
// gang stuff
new zoneFamily,zoneBalla,zoneAzteca,zoneVagos; //gangzones
new gcar[32]; // gang cars
// ------------------------------------------
//safezones
new safezoneLS,safezoneLV,safezoneChiliad,safezoneAA;
//airspaces
new lsairspace,lvairspace,sfairspace;
/*
lsairspace = GangZoneCreate(0, -4133.968, 4425.915, 0);
lvairspace = GangZoneCreate(0, 0, 4098.934, 4344.169);
sfairspace = GangZoneCreate(-3830.343, -3912.088, -443.7593, 2966.18);
*/

new mph,kph; //for speedo
// new Float:pudistance,puvalue; //for speedo

#if defined TEXTDRAWS
new Text:Help; // freq used commands bottom screen
new Text:BottomBanner; // black banner on bottom of screen. radio channel etc
//new Text:Stats;
new Text:ServerIP; // freq used commands bottom screen
new Text:Surfing; // td on when player surfing
new Text:Leave; // '/leave' td when in dm
new Text:God; // god mode status on
new Text:NoGod; // god mode off
new Text:Veh; // 'press 2 for fix etc' msg
new Text:VehAutoFlip; // 'press 2 for fix etc' msg
new Text:VehPutRamp; // 'press 2 for fix etc' msg
new Text:VehPutSkulls; // 'press 2 for fix etc' msg
new Text:VehAutoStop; // 'press 2 for fix etc' msg
new Text:SnosOn; //snos on indicator
new Text:SnosOff; //snos off indicator
new Text:JumpOn,Text:JumpOff;
new Text:RadioOn,Text:RadioOff;
new Text:DMSPAM; // 'player entered etc DM' td when player used dm command

#endif


// alistair's vehicle name code
new vehName[212][24] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxvillde", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratium", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car", "Police Car", "Police Car",
    "Police Ranger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
};

new legalmods[48][22] = { // allowed mods sorted by vehicle
    {400, 1024,1021,1020,1019,1018,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {401, 1145,1144,1143,1142,1020,1019,1017,1013,1007,1006,1005,1004,1003,1001,0000,0000,0000,0000},
    {404, 1021,1020,1019,1017,1016,1013,1007,1002,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {405, 1023,1021,1020,1019,1018,1014,1001,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {410, 1024,1023,1021,1020,1019,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
    {415, 1023,1019,1018,1017,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {418, 1021,1020,1016,1006,1002,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {420, 1021,1019,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {421, 1023,1021,1020,1019,1018,1016,1014,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {422, 1021,1020,1019,1017,1013,1007,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {426, 1021,1019,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {436, 1022,1021,1020,1019,1017,1013,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
    {439, 1145,1144,1143,1142,1023,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
    {477, 1021,1020,1019,1018,1017,1007,1006,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {478, 1024,1022,1021,1020,1013,1012,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {489, 1024,1020,1019,1018,1016,1013,1006,1005,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
    {491, 1145,1144,1143,1142,1023,1021,1020,1019,1018,1017,1014,1007,1003,0000,0000,0000,0000,0000},
    {492, 1016,1006,1005,1004,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {496, 1143,1142,1023,1020,1019,1017,1011,1007,1006,1003,1002,1001,0000,0000,0000,0000,0000,0000},
    {500, 1024,1021,1020,1019,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {516, 1021,1020,1019,1018,1017,1016,1015,1007,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
    {517, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1016,1007,1003,1002,0000,0000,0000,0000,0000},
    {518, 1145,1144,1143,1142,1023,1020,1018,1017,1013,1007,1006,1005,1003,1001,0000,0000,0000,0000},
    {527, 1021,1020,1018,1017,1015,1014,1007,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {529, 1023,1020,1019,1018,1017,1012,1011,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000},
    {534, 1185,1180,1179,1178,1127,1126,1125,1124,1123,1122,1106,1101,1100,0000,0000,0000,0000,0000},
    {535, 1121,1120,1119,1118,1117,1116,1115,1114,1113,1110,1109,0000,0000,0000,0000,0000,0000,0000},
    {536, 1184,1183,1182,1181,1128,1108,1107,1105,1104,1103,0000,0000,0000,0000,0000,0000,0000,0000},
    {540, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1004,1001,0000,0000,0000,0000},
    {542, 1145,1144,1021,1020,1019,1018,1015,1014,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {546, 1145,1144,1143,1142,1024,1023,1019,1018,1017,1007,1006,1004,1002,1001,0000,0000,0000,0000},
    {547, 1143,1142,1021,1020,1019,1018,1016,1003,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {549, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1012,1011,1007,1003,1001,0000,0000,0000,0000},
    {550, 1145,1144,1143,1142,1023,1020,1019,1018,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000},
    {551, 1023,1021,1020,1019,1018,1016,1006,1005,1003,1002,0000,0000,0000,0000,0000,0000,0000,0000},
    {558, 1168,1167,1166,1165,1164,1163,1095,1094,1093,1092,1091,1090,1089,1088,0000,0000,0000,0000},
    {559, 1173,1162,1161,1160,1159,1158,1072,1071,1070,1069,1068,1067,1066,1065,0000,0000,0000,0000},
    {560, 1170,1169,1141,1140,1139,1138,1033,1032,1031,1030,1029,1028,1027,1026,0000,0000,0000,0000},
    {561, 1157,1156,1155,1154,1064,1063,1062,1061,1060,1059,1058,1057,1056,1055,1031,1030,1027,1026},
    {562, 1172,1171,1149,1148,1147,1146,1041,1040,1039,1038,1037,1036,1035,1034,0000,0000,0000,0000},
    {565, 1153,1152,1151,1150,1054,1053,1052,1051,1050,1049,1048,1047,1046,1045,0000,0000,0000,0000},
    {567, 1189,1188,1187,1186,1133,1132,1131,1130,1129,1102,0000,0000,0000,0000,0000,0000,0000,0000},
    {575, 1177,1176,1175,1174,1099,1044,1043,1042,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {576, 1193,1192,1191,1190,1137,1136,1135,1134,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {580, 1023,1020,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {589, 1145,1144,1024,1020,1018,1017,1016,1013,1007,1006,1005,1004,1000,0000,0000,0000,0000,0000},
    {600, 1022,1020,1018,1017,1013,1007,1006,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000},
    {603, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000}
};

new startMusic[4] = {
1062,1068,1183,1097
};

new atcSounds[4] = {
7221,7222,7224,7226
};

new deathSounds[18] = {
42423,42001,41432,41272,41256,41217,41031,41022,39806,39615,39008,39003,39000,38833,38628,38466,37622,37482
};


new ambientSounds[4] = {
32201, //puke
28000, //wheel screech
23400, //building
19403, //truck smashing


};

new Float:gRandomStuntSpawn[6][4] = {
{1899.6129,-2240.0889,13.5469,255.5154}, //lsairport
{-2339.4900,-1675.5247,484.1562,357.8905}, //chiliad
{400.2046,2543.4763,19.7737,106.85}, //aa
{-1658.0809,-414.6946,14.1484,0.0}, //sf
{1632.2267,1630.8087,14.8222,97.5312}, // lv airport
{-323.5591,1526.9297,75.3570,225.4534} //drift

};

#if defined DM //dm zone stuff
new Float:gRandomSniperDM[15][4] = {
{245.2457,1454.9375,43.0946,156.4561},
{202.1618,1451.9221,43.0946,217.0136},
{201.1905,1406.3535,44.6503,295.9510},
{224.9771,1414.5057,29.0093,351.7065},
{167.3860,1426.0980,26.2369,269.0667},
{199.8745,1404.2958,60.1355,321.7490},
{246.7483,1435.1178,23.3703,177.4521},
{171.9032,1482.9506,10.5859,73.7679},
{173.0153,1380.6504,10.5859,265.4044},
{219.9097,1351.5270,10.5859,16.3882},
{222.6999,1374.4329,25.2934,177.6937},
{186.8685,1457.9178,55.5781,198.6689},
{131.7630,1393.0347,26.1517,228.9346},
{205.3834,1445.8939,10.5859,146.1317},
{220.0217,1469.6975,23.7344,145.0651}
};

new Float:gRandomMilitaryDM[6][4] = {
{388.4619,1890.8684,17.6406,57.7399},
{278.9101,1785.4762,17.6406,319.9189},
{386.3756,2077.8464,17.6406,139.1470},
{263.7085,2012.7166,17.6406,102.3822},
{146.7413,1875.8613,17.8359,275.5711},
{210.9024,1811.1292,21.8672,343.9804}
};

new Float:gRandomSawnOffDM[5][4] = {
{-2442.4468,616.0774,30.3419,2.7500},
{-2421.6475,645.6965,34.4742,325.4420},
{-2422.2415,684.0378,35.1570,22.5946},
{-2469.9136,676.9008,34.2858,104.7514},
{-2498.4185,614.9011,26.0944,302.8008}
};

new Float:gRandomSwordDM[6][4] = {
{206.3081,-10.9856,1001.2109,304.7189},
{201.2184,-4.1364,1001.2109,257.4703},
{217.5962,-4.6303,1001.2109,266.2020},
{216.7124,-12.6580,1001.2109,82.0439},
{204.9362,-4.6324,1005.2109,209.8432},
{209.3385,-12.5224,1005.2109,342.0085}
};

new Float:gRandomDeagleDM[9][4] = {
{-2641.5913,1420.1016,906.4609,135.7372},
{-2669.4290,1428.5836,906.4609,186.5395},
{-2674.1355,1400.0565,906.2734,308.7824},
{-2631.3723,1397.0632,906.4609,107.9548},
{-2665.5598,1398.7416,912.4063,102.3983},
{-2658.3435,1391.3290,918.3516,36.9110},
{-2688.5566,1431.4250,906.4609,244.2966},
{-2661.0054,1422.7255,912.4063,186.3503},
{-2673.6501,1423.0334,912.4063,192.7005}
};

new Float:gRandomMinigunDM[9][4] = {
{1413.5502,2157.2302,19.4286,81.1123},
{1393.5474,2104.7124,11.0156,11.4890},
{1378.8374,2213.7690,18.9766,130.2852},
{1368.6378,2194.8867,9.7578,205.4233},
{1393.9669,2164.9509,9.7578,37.9788},
{1306.9668,2108.4163,11.0156,316.7018},
{1301.7860,2202.5928,14.0993,179.3023},
{1419.1334,2116.5552,29.6907,51.3800},
{1399.8579,2100.9795,15.0625,12.7770}
};

new Float:gRandomRocketDM[4][4] = {
{501.8544,-21.3491,1000.6797,61.9754},
{487.7188,-2.7461,1002.3828,178.2440},
{479.7839,-14.1828,1000.6802,275.9006},
{486.8539,-24.4962,1003.5737,8.0423}
};

//shipdm spawns
new Float:gRandomShipSpawns[10][3] = {
{-2308.4480,1546.0233,18.7734}, //ship1
{-2466.1052,1545.4475,23.6641}, //ship2
{-2347.9333,1547.7725,26.0469}, //ship3
{-2375.8469,1541.6355,23.1406}, //ship4
{-2404.3672,1556.3593,26.0469}, //ship5
{-2426.9480,1536.9685,26.0469}, //ship6
{-2437.9360,1556.4310,17.3281}, //ship7
{-2436.9475,1546.6334,8.3984}, //ship8
{-2410.7808,1552.0458,2.1172}, //ship9
{-2389.4875,1554.7893,5.5102} //ship10
};
//housedm spawns
new Float:gRandomHouseDMSpawns[7][4] = {
{238.9096,1029.6703,1084.0078,352.8429},
{226.8895,1037.9360,1084.0129,224.5630},
{254.3157,1035.3165,1084.7378,105.2680},
{231.3406,1024.7582,1088.3125,338.4294},
{240.1803,1039.8242,1088.3073,174.1158},
{235.8277,1033.3933,1088.3125,89.5568},
{239.4288,1028.6603,1088.3085,179.8812}

//{2346.0247,-1186.4976,1027.9766} //housedm 7

};
new Float:gRandomFamilyDM[3][4] = {
{2487.7791,-1656.3292,13.3518,115.9093}, //Family spawn 1
{2505.5796,-1681.9346,13.5469,20.1563}, //Family spawn 2
{2517.1711,-1671.6598,13.9975,66.2794} //Family spawn 3
};
new Float:gRandomBallaDM[3][4] = {
{1993.4073,-1629.9937,13.5469,253.8565}, //Balla spawn 1
{2012.3450,-1645.3604,13.5469,78.9730}, //Balla spawn 2
{1993.0951,-1682.3042,13.5469,146.7163} //Balla spawn 3
};
new Float:gRandomAztecaDM[3][4] = {
{1839.1517,-1887.6753,13.4246,80.2707}, //Azteca spawn 1
{1844.1366,-1868.8591,13.3897,95.6451}, //Azteca spawn 2
{1808.1698,-1870.6755,13.5819,258.6610} //Azteca spawn 3
};
new Float:gRandomVagosDM[3][4] = {
{2752.5688,-1384.1875,39.3686,165.6471}, //Vagos spawn 1
{2750.3350,-1361.1919,41.0119,181.0214}, //Vagos spawn 2
{2714.1174,-1389.8408,37.7660,287.3443} //Vagos spawn 3
};
new Float:gRandomRifaDM[3][4] = {
{-2312.1897,-33.8260,35.3203,165.4539}, //Rifa spawn 1
{-2316.7375,-49.2802,35.3203,234.1581}, //Rifa spawn 2
{-2315.0735,-78.6490,35.3203,338.0787} //Rifa spawn 3
};
new Float:gRandomTriadDM[3][4] = {
{-2277.9023,644.8516,54.5319,286.5270}, //Triad spawn 1
{-2278.3779,630.6471,53.0781,268.8940}, //Triad spawn 2
{-2242.2622,638.5879,60.1797,107.4631} //Triad spawn 3
};
new Float:gRandomDaNangDM[3][4] = {
{-1966.2802,260.3167,35.4688,86.8038}, //DaNang spawn 1
{-1974.5131,308.7462,35.1719,164.1561}, //DaNang spawn 2
{-2037.8024,302.9315,35.1634,276.5812} //DaNang spawn 3
};
new Float:gRandomMafiaDM[3][4] = {
{-1018.4500,-601.3653,32.0126,77.1949}, //Mafia spawn 1
{-1052.2612,-589.3840,32.0078,262.3114}, //Mafia spawn 2
{-1042.1627,-623.0359,32.0078,294.3578} //Mafia spawn 3
};

new FamilySkin[3] = {
105,106,107
};
new BallaSkin[3] = {
102,103,104
};
new AztecaSkin[3] = {
114,115,116
};
new VagosSkin[3] = {
108,109,110
};
new DaNangSkin[3] = {
121,122,123
};
new RifaSkin[3] = {
173,174,175
};
new TriadSkin[3] = {
117,118,120
};
new MafiaSkin[3] = {
111,112,113
};

#endif //dm


// ANTI CAR JACK
#if defined ANTI_CARJACK
enum E_CARJACK_DATA
{
    Float: E_LAST_X,        Float: E_LAST_Y,        Float: E_LAST_Z,
    E_LAST_VEH
}

new
    g_carjackData[ MAX_PLAYERS ] [ E_CARJACK_DATA ]
;
#endif

// --------------

/*
new ValidSounds[] =
{
        1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020,
        1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041,
        1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1064, 1065, 1066, 1067, 1070, 1071, 1072, 1073, 1074, 1075, 1078, 1079, 1080, 1081, 1082, 1083,
        1084, 1085, 1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1099, 1100, 1101, 1102, 1103, 1104,
        1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125,
        1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146,
        1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162, 1163, 1164, 1165, 1166, 1167,
        1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1184, 1186, 1188,
        1189, 1800, 1801, 1802, 1803, 1804, 1805, 1806, 1807, 1808, 1809, 1810, 1811, 1812, 1813, 1814, 1815, 1816, 1817, 1818, 1819,
        1820, 1821, 1822, 1823, 1824, 1825, 1826, 1827, 1828, 1829, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
        2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031,
        2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049, 2050, 2051, 2052,
        2053, 2054, 2055, 2056, 2057, 2058, 2059, 2060, 2061, 2062, 2063, 2064, 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 2073,
        2074, 2075, 2076, 2077, 2078, 2079, 2080, 2081, 2082, 2083, 2084, 2085, 2086, 2087, 2088, 2089, 2090, 2091, 2092, 2093, 2094,
        2095, 2096, 2097, 2098, 2099, 2100, 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109, 2110, 2111, 2112, 2113, 2114, 2115,
        2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2129, 2130, 2131, 2132, 2133, 2134, 2135, 2136,
        2137, 2138, 2139, 2140, 2141, 2142, 2143, 2144, 2145, 2146, 2147, 2148, 2149, 2150, 2151, 2152, 2153, 2154, 2155, 2156, 2157,
        2158, 2159, 2160, 2161, 2162, 2163, 2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214,
        2400, 2401, 2402, 2403, 2404, 2600, 2601, 2602, 2603, 2604, 2605, 2606, 2607, 2608, 2800, 2801, 2802, 2803, 2804, 2805, 2806,
        2807, 2808, 2809, 2810, 2811, 2812, 2813, 3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008, 3009, 3010, 3011, 3012, 3013,
        3014, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3025, 3026, 3027, 3028, 3029, 3030, 3031, 3032, 3033, 3034,
        3035, 3036, 3037, 3038, 3039, 3040, 3041, 3042, 3043, 3044, 3045, 3046, 3047, 3048, 3049, 3050, 3051, 3052, 3053, 3054, 3055,
        3056, 3057, 3200, 3201, 3400, 3401, 3600, 3800, 4000, 4001, 4200, 4201, 4202, 4203, 4400, 4600, 4601, 4602, 4603, 4604, 4800,
        4801, 4802, 4803, 4804, 4805, 4806, 4807, 5000, 5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010, 5011, 5012, 5013,
        5014, 5200, 5201, 5202, 5203, 5204, 5205, 5206, 5400, 5401, 5402, 5403, 5404, 5405, 5406, 5407, 5408, 5409, 5410, 5411, 5412,
        5413, 5414, 5415, 5416, 5417, 5418, 5419, 5420, 5421, 5422, 5423, 5424, 5425, 5426, 5427, 5428, 5429, 5430, 5431, 5432, 5433,
        5434, 5435, 5436, 5437, 5438, 5439, 5440, 5441, 5442, 5443, 5444, 5445, 5446, 5447, 5448, 5449, 5450, 5451, 5452, 5453, 5454,
        5455, 5456, 5457, 5458, 5459, 5460, 5461, 5462, 5463, 5464, 5600, 5601, 5602, 5800, 5801, 5802, 5803, 5804, 5805, 5806, 5807,
        5808, 5809, 5810, 5811, 5812, 5813, 5814, 5815, 5816, 5817, 5818, 5819, 5820, 5821, 5822, 5823, 5824, 5825, 5826, 5827, 5828,
        5829, 5830, 5831, 5832, 5833, 5834, 5835, 5836, 5837, 5838, 5839, 5840, 5841, 5842, 5843, 5844, 5845, 5846, 5847, 5848, 5849,
        5850, 5851, 5852, 5853, 5854, 5855, 5856, 6000, 6001, 6002, 6003, 6200, 6201, 6202, 6203, 6204, 6205, 6400, 6401, 6402, 6600,
        6601, 6602, 6603, 6800, 6801, 6802, 7000, 7001, 7002, 7003, 7004, 7005, 7006, 7007, 7008, 7009, 7010, 7011, 7012, 7013, 7014,
        7015, 7016, 7017, 7018, 7019, 7020, 7021, 7022, 7023, 7024, 7025, 7026, 7027, 7028, 7029, 7030, 7031, 7032, 7033, 7034, 7035,
        7036, 7037, 7038, 7039, 7040, 7041, 7042, 7043, 7044, 7045, 7046, 7047, 7048, 7049, 7050, 7051, 7052, 7053, 7054, 7055, 7056,
        7057, 7058, 7059, 7060, 7061, 7062, 7063, 7064, 7065, 7066, 7200, 7201, 7202, 7203, 7204, 7205, 7206, 7207, 7208, 7209, 7210,
        7211, 7212, 7213, 7214, 7215, 7216, 7217, 7218, 7219, 7220, 7221, 7222, 7223, 7224, 7225, 7226, 7227, 7228, 7229, 7230, 7231,
        7232, 7233, 7234, 7235, 7236, 7237, 7238, 7239, 7400, 7401, 7402, 7403, 7404, 7405, 7406, 7407, 7408, 7409, 7410, 7411, 7412,
        7413, 7414, 7415, 7416, 7417, 7418, 7419, 7420, 7421, 7600, 7601, 7602, 7603, 7604, 7605, 7606, 7607, 7608, 7609, 7610, 7611,
        7612, 7800, 7801, 7802, 7803, 7804, 7805, 7806, 7807, 7808, 7809, 7810, 7811, 7812, 7813, 7814, 7815, 7816, 7817, 7818, 7819,
        7820, 7821, 7822, 7823, 7824, 7825, 7826, 7827, 7828, 7829, 7830, 7831, 7832, 7833, 7834, 7835, 7836, 7837, 7838, 7839, 7840,
        7841, 7842, 7843, 7844, 7845, 7846, 7847, 7848, 7849, 7850, 7851, 7852, 7853, 7854, 7855, 7856, 7857, 7858, 7859, 7860, 7861,
        7862, 7863, 7864, 7865, 7866, 7867, 7868, 7869, 7870, 7871, 7872, 7873, 7874, 7875, 7876, 7877, 7878, 7879, 7880, 7881, 7882,
        7883, 7884, 7885, 7886, 7887, 7888, 7889, 7890, 7891, 7892, 7893, 7894, 7895, 7896, 7897, 7898, 7899, 7900, 7901, 7902, 8000,
        8001, 8002, 8003, 8004, 8005, 8006, 8007, 8008, 8009, 8010, 8011, 8012, 8013, 8014, 8015, 8016, 8017, 8200, 8201, 8202, 8203,
        8204, 8205, 8206, 8207, 8208, 8209, 8210, 8211, 8212, 8213, 8214, 8215, 8216, 8217, 8218, 8219, 8220, 8221, 8222, 8223, 8224,
        8225, 8226, 8227, 8228, 8229, 8230, 8231, 8232, 8233, 8234, 8235, 8236, 8237, 8238, 8239, 8240, 8241, 8242, 8243, 8244, 8245,
        8246, 8247, 8248, 8249, 8250, 8251, 8252, 8253, 8254, 8255, 8256, 8257, 8258, 8259, 8260, 8261, 8262, 8263, 8264, 8265, 8266,
        8267, 8268, 8269, 8270, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8400, 8401, 8402, 8403, 8404, 8405, 8406, 8407, 8408,
        8409, 8410, 8411, 8412, 8600, 8601, 8602, 8603, 8604, 8605, 8606, 8607, 8608, 8609, 8610, 8611, 8612, 8613, 8614, 8615, 8616,
        8617, 8618, 8619, 8620, 8621, 8622, 8623, 8624, 8625, 8626, 8627, 8628, 8629, 8630, 8631, 8632, 8633, 8634, 8635, 8636, 8637,
        8638, 8639, 8640, 8641, 8642, 8643, 8644, 8645, 8646, 8647, 8648, 8649, 8650, 8651, 8652, 8653, 8654, 8655, 8656, 8657, 8658,
        8659, 8660, 8661, 8662, 8663, 8664, 8665, 8666, 8667, 8668, 8669, 8670, 8671, 8672, 8673, 8674, 8675, 8676, 8677, 8678, 8679,
        8680, 8681, 8682, 8683, 8684, 8685, 8686, 8687, 8688, 8689, 8690, 8691, 8692, 8693, 8694, 8695, 8696, 8697, 8698, 8699, 8700,
        8701, 8702, 8703, 8704, 8705, 8706, 8707, 8708, 8709, 8710, 8711, 8712, 8713, 8714, 8715, 8716, 8717, 8718, 8719, 8720, 8721,
        8722, 8723, 8724, 8725, 8726, 8727, 8728, 8729, 8730, 8731, 8732, 8733, 8734, 8735, 8736, 8737, 8738, 8800, 8801, 8802, 8803,
        8804, 8805, 8806, 8807, 8808, 8809, 8810, 8811, 8812, 8813, 8814, 8815, 8816, 8817, 8818, 8819, 8820, 8821, 8822, 8823, 8824,
        8825, 8826, 8827, 8828, 8829, 8830, 8831, 8832, 8833, 8834, 8835, 8836, 8837, 8838, 8839, 8840, 9000, 9001, 9002, 9003, 9004,
        9005, 9006, 9007, 9008, 9009, 9010, 9011, 9012, 9013, 9014, 9015, 9016, 9017, 9018, 9019, 9020, 9021, 9022, 9023, 9024, 9025,
        9026, 9027, 9028, 9029, 9030, 9031, 9200, 9201, 9400, 9401, 9402, 9403, 9404, 9405, 9406, 9407, 9408, 9409, 9410, 9411, 9412,
        9413, 9414, 9415, 9416, 9417, 9418, 9419, 9420, 9421, 9422, 9423, 9424, 9425, 9426, 9427, 9428, 9429, 9430, 9431, 9432, 9433,
        9434, 9435, 9436, 9437, 9438, 9439, 9440, 9441, 9442, 9443, 9444, 9445, 9446, 9447, 9448, 9449, 9450, 9451, 9600, 9601, 9602,
        9603, 9604, 9605, 9606, 9607, 9608, 9609, 9610, 9611, 9612, 9613, 9614, 9615, 9616, 9617, 9618, 9619, 9620, 9621, 9622, 9623,
        9624, 9625, 9626, 9627, 9628, 9629, 9630, 9631, 9632, 9633, 9634, 9635, 9636, 9637, 9638, 9639, 9640, 9641, 9642, 9643, 9644,
        9645, 9646, 9647, 9648, 9649, 9650, 9651, 9652, 9653, 9654, 9655, 9656, 9657, 9658, 9659, 9660, 9661, 9662, 9663, 9664, 9665,
        9666, 9667, 9668, 9669, 9670, 9671, 9672, 9673, 9674, 9675, 9676, 9800, 9801, 9802, 9803, 9804, 9805, 9806, 9807, 9808, 9809,
        9810, 9811, 9812, 9813, 9814, 9815, 9816, 9817, 9818, 9819, 9820, 9821, 9822, 9823, 9824, 9825, 9826, 9827, 9828, 9829, 9830,
        9831, 9832, 9833, 9834, 9835, 9836, 9837, 9838, 9839, 9840, 9841, 9842, 9843, 9844, 9845, 9846, 9847, 9848, 9849, 9850, 9851,
        9852, 9853, 9854, 9855, 9856, 9857, 9858, 9859, 9860, 9861, 9862, 9863, 9864, 9865, 9866, 9867, 9868, 9869, 9870, 9871, 9872,
        9873, 9874, 9875, 9876, 9877, 9878, 9879, 9880, 9881, 9882, 9883, 9884, 9885, 9886, 9887, 9888, 9889, 9890, 9891, 9892, 9893,
        9894, 9895, 9896, 9897, 9898, 9899, 9900, 9901, 9902, 9903, 9904, 9905, 9906, 9907, 9908, 9909, 9910, 9911, 9912, 9913, 9914,
        10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009, 10010, 10011, 10012, 10013, 10014, 10015, 10200, 10201,
        10202, 10203, 10204, 10205, 10206, 10207, 10208, 10209, 10210, 10211, 10212, 10213, 10214, 10400, 10401, 10402, 10403, 10404,
        10405, 10406, 10407, 10408, 10409, 10600, 10601, 10602, 10603, 10604, 10605, 10606, 10607, 10608, 10609, 10610, 10611, 10612,
        10613, 10614, 10615, 10616, 10617, 10618, 10619, 10620, 10621, 10622, 10623, 10624, 10625, 10626, 10627, 10628, 10629, 10630,
        10631, 10632, 10633, 10634, 10635, 10636, 10637, 10638, 10639, 10640, 10641, 10642, 10643, 10644, 10645, 10646, 10647, 10648,
        10649, 10650, 10651, 10652, 10653, 10654, 10655, 10656, 10657, 10658, 10659, 10660, 10661, 10662, 10663, 10800, 10801, 10802,
        10803, 10804, 10805, 10806, 10807, 10808, 10809, 10810, 10811, 10812, 10813, 10814, 10815, 10816, 10817, 10818, 10819, 10820,
        10821, 10822, 10823, 10824, 10825, 10826, 10827, 10828, 10829, 10830, 10831, 10832, 11000, 11001, 11002, 11003, 11004, 11005,
        11006, 11007, 11008, 11009, 11010, 11200, 11400, 11401, 11402, 11403, 11404, 11405, 11406, 11407, 11408, 11409, 11410, 11411,
        11412, 11413, 11414, 11415, 11416, 11417, 11418, 11419, 11420, 11421, 11422, 11423, 11424, 11425, 11426, 11427, 11428, 11429,
        11430, 11431, 11432, 11433, 11434, 11435, 11436, 11437, 11438, 11439, 11440, 11441, 11442, 11443, 11444, 11445, 11446, 11447,
        11448, 11449, 11450, 11451, 11452, 11453, 11454, 11455, 11600, 11601, 11602, 11603, 11604, 11605, 11606, 11607, 11608, 11609,
        11610, 11611, 11612, 11613, 11614, 11615, 11616, 11617, 11618, 11619, 11620, 11621, 11622, 11623, 11624, 11625, 11626, 11627,
        11628, 11629, 11630, 11631, 11632, 11633, 11634, 11635, 11636, 11637, 11638, 11639, 11640, 11641, 11642, 11643, 11644, 11645,
        11646, 11647, 11648, 11649, 11650, 11651, 11652, 11653, 11654, 11655, 11800, 11801, 11802, 11803, 11804, 11805, 11806, 11807,
        11808, 11809, 11810, 11811, 11812, 11813, 11814, 11815, 11816, 11817, 11818, 11819, 11820, 11821, 11822, 11823, 11824, 11825,
        11826, 11827, 11828, 11829, 11830, 11831, 11832, 11833, 11834, 11835, 11836, 11837, 11838, 11839, 11840, 11841, 11842, 11843,
        11844, 11845, 11846, 11847, 11848, 11849, 11850, 11851, 11852, 11853, 11854, 11855, 12000, 12001, 12002, 12003, 12004, 12005,
        12006, 12007, 12008, 12009, 12010, 12011, 12012, 12013, 12014, 12015, 12016, 12017, 12018, 12019, 12020, 12021, 12022, 12023,
        12024, 12025, 12026, 12027, 12028, 12029, 12030, 12031, 12032, 12033, 12034, 12035, 12036, 12037, 12038, 12039, 12040, 12041,
        12042, 12043, 12044, 12045, 12046, 12047, 12048, 12049, 12050, 12051, 12052, 12053, 12054, 12055, 12200, 12201, 12400, 12401,
        12402, 12403, 12404, 12405, 12406, 12407, 12408, 12409, 12410, 12411, 12600, 12601, 12602, 12603, 12604, 12605, 12800, 12801,
        12802, 12803, 12804, 12805, 12806, 12807, 12808, 12809, 12810, 12811, 12812, 12813, 12814, 12815, 12816, 12817, 12818, 12819,
        12820, 12821, 12822, 12823, 12824, 12825, 12826, 12827, 12828, 12829, 12830, 12831, 12832, 13000, 13001, 13002, 13003, 13004,
        13005, 13006, 13007, 13008, 13009, 13010, 13011, 13012, 13013, 13014, 13015, 13016, 13017, 13018, 13019, 13020, 13021, 13022,
        13023, 13024, 13025, 13026, 13027, 13028, 13029, 13030, 13031, 13032, 13033, 13034, 13035, 13036, 13037, 13038, 13200, 13201,
        13202, 13203, 13204, 13205, 13206, 13207, 13208, 13209, 13210, 13211, 13212, 13213, 13214, 13215, 13216, 13400, 13401, 13402,
        13403, 13404, 13405, 13406, 13407, 13408, 13409, 13410, 13411, 13412, 13413, 13414, 13415, 13416, 13417, 13418, 13419, 13600,
        13601, 13602, 13603, 13604, 13605, 13606, 13607, 13608, 13609, 13610, 13611, 13612, 13613, 13614, 13615, 13616, 13617, 13618,
        13619, 13620, 13621, 13622, 13623, 13624, 13625, 13626, 13627, 13628, 13629, 13630, 13631, 13632, 13633, 13634, 13635, 13636,
        13637, 13638, 13639, 13640, 13641, 13642, 13643, 13644, 13645, 13646, 13800, 13801, 13802, 13803, 14000, 14001, 14002, 14003,
        14004, 14005, 14006, 14007, 14008, 14009, 14010, 14011, 14012, 14013, 14014, 14015, 14016, 14017, 14018, 14019, 14020, 14021,
        14022, 14023, 14024, 14025, 14026, 14027, 14028, 14029, 14030, 14031, 14032, 14033, 14034, 14035, 14036, 14037, 14038, 14039,
        14040, 14041, 14200, 14400, 14401, 14402, 14403, 14404, 14405, 14406, 14407, 14408, 14409, 14410, 14600, 14800, 15000, 15001,
        15002, 15003, 15004, 15005, 15006, 15007, 15008, 15009, 15010, 15011, 15012, 15013, 15014, 15015, 15016, 15017, 15018, 15019,
        15020, 15021, 15022, 15023, 15024, 15025, 15026, 15027, 15028, 15200, 15201, 15202, 15203, 15204, 15205, 15206, 15207, 15208,
        15209, 15210, 15211, 15212, 15213, 15214, 15215, 15216, 15217, 15218, 15219, 15220, 15221, 15222, 15223, 15224, 15225, 15226,
        15227, 15228, 15229, 15230, 15231, 15232, 15233, 15234, 15235, 15236, 15237, 15238, 15239, 15240, 15241, 15242, 15243, 15244,
        15245, 15246, 15247, 15248, 15249, 15250, 15251, 15252, 15253, 15254, 15255, 15256, 15257, 15258, 15400, 15401, 15402, 15403,
        15404, 15405, 15406, 15407, 15408, 15600, 15601, 15602, 15603, 15800, 15801, 15802, 15803, 15804, 15805, 15806, 15807, 15808,
        15809, 15810, 15811, 15812, 15813, 15814, 15815, 15816, 15817, 15818, 15819, 15820, 15821, 15822, 15823, 15824, 15825, 15826,
        15827, 15828, 15829, 15830, 15831, 15832, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15841, 15842, 15843, 15844,
        15845, 15846, 15847, 15848, 15849, 15850, 15851, 15852, 15853, 15854, 15855, 15856, 15857, 15858, 15859, 15860, 15861, 15862,
        15863, 15864, 15865, 15866, 15867, 15868, 15869, 15870, 15871, 15872, 15873, 15874, 15875, 15876, 15877, 15878, 15879, 15880,
        15881, 15882, 15883, 15884, 15885, 15886, 15887, 15888, 15889, 15890, 15891, 15892, 15893, 15894, 15895, 15896, 15897, 15898,
        15899, 15900, 15901, 15902, 15903, 15904, 15905, 15906, 15907, 15908, 15909, 15910, 15911, 15912, 15913, 15914, 15915, 15916,
        15917, 15918, 15919, 15920, 15921, 15922, 15923, 15924, 15925, 15926, 15927, 15928, 15929, 15930, 15931, 15932, 15933, 15934,
        15935, 15936, 15937, 15938, 15939, 15940, 15941, 15942, 15943, 15944, 15945, 15946, 15947, 15948, 15949, 15950, 16000, 16001,
        16002, 16003, 16004, 16005, 16006, 16007, 16008, 16009, 16010, 16011, 16012, 16013, 16014, 16015, 16016, 16017, 16018, 16200,
        16400, 16401, 16402, 16403, 16404, 16405, 16406, 16407, 16408, 16409, 16410, 16411, 16412, 16413, 16414, 16415, 16416, 16417,
        16418, 16419, 16420, 16421, 16422, 16423, 16424, 16425, 16426, 16427, 16428, 16429, 16430, 16431, 16432, 16433, 16434, 16435,
        16436, 16437, 16438, 16439, 16440, 16441, 16442, 16443, 16444, 16445, 16446, 16447, 16448, 16449, 16450, 16451, 16452, 16453,
        16454, 16455, 16456, 16457, 16458, 16459, 16460, 16461, 16462, 16463, 16464, 16465, 16466, 16467, 16468, 16469, 16470, 16471,
        16472, 16473, 16474, 16475, 16476, 16477, 16478, 16479, 16480, 16481, 16482, 16483, 16484, 16485, 16486, 16487, 16488, 16489,
        16490, 16491, 16492, 16493, 16494, 16495, 16496, 16497, 16498, 16499, 16500, 16501, 16502, 16503, 16504, 16600, 16601, 16602,
        16603, 16604, 16605, 16606, 16607, 16608, 16609, 16610, 16611, 16612, 16613, 16614, 16800, 16801, 16802, 16803, 17000, 17001,
        17002, 17003, 17004, 17005, 17006, 17200, 17400, 17401, 17402, 17403, 17404, 17405, 17406, 17407, 17408, 17409, 17410, 17411,
        17412, 17413, 17414, 17415, 17416, 17417, 17418, 17419, 17420, 17421, 17422, 17423, 17424, 17425, 17426, 17427, 17428, 17429,
        17430, 17431, 17432, 17433, 17434, 17435, 17436, 17437, 17438, 17439, 17440, 17441, 17442, 17443, 17444, 17445, 17446, 17447,
        17448, 17449, 17450, 17451, 17452, 17453, 17454, 17455, 17600, 17601, 17602, 17603, 17604, 17605, 17606, 17607, 17608, 17609,
        17610, 17611, 17612, 17613, 17614, 17615, 17616, 17617, 17618, 17619, 17620, 17621, 17622, 17800, 17801, 17802, 17803, 17804,
        17805, 17806, 17807, 18000, 18001, 18002, 18003, 18004, 18005, 18006, 18007, 18008, 18009, 18010, 18011, 18012, 18013, 18014,
        18015, 18016, 18017, 18018, 18019, 18020, 18021, 18022, 18023, 18024, 18025, 18200, 18201, 18202, 18203, 18204, 18205, 18206,
        18207, 18208, 18209, 18210, 18211, 18212, 18213, 18214, 18215, 18216, 18400, 18401, 18402, 18403, 18404, 18405, 18406, 18407,
        18408, 18409, 18410, 18411, 18412, 18413, 18414, 18415, 18416, 18417, 18418, 18419, 18420, 18421, 18422, 18423, 18424, 18425,
        18426, 18427, 18428, 18429, 18430, 18431, 18432, 18433, 18434, 18600, 18601, 18602, 18603, 18604, 18605, 18606, 18607, 18608,
        18609, 18610, 18611, 18612, 18613, 18614, 18615, 18616, 18800, 18801, 18802, 18803, 18804, 18805, 18806, 18807, 19000, 19001,
        19002, 19003, 19004, 19005, 19006, 19007, 19008, 19009, 19010, 19011, 19012, 19013, 19014, 19015, 19016, 19017, 19018, 19019,
        19020, 19021, 19022, 19023, 19024, 19025, 19026, 19027, 19028, 19029, 19030, 19031, 19032, 19033, 19034, 19035, 19036, 19037,
        19038, 19039, 19040, 19041, 19042, 19043, 19044, 19045, 19046, 19047, 19048, 19049, 19050, 19051, 19052, 19053, 19054, 19055,
        19056, 19057, 19058, 19059, 19060, 19061, 19062, 19063, 19064, 19065, 19066, 19067, 19068, 19069, 19070, 19071, 19072, 19073,
        19074, 19075, 19076, 19077, 19078, 19079, 19080, 19081, 19082, 19083, 19084, 19085, 19086, 19087, 19088, 19089, 19090, 19091,
        19092, 19093, 19094, 19095, 19096, 19097, 19098, 19099, 19100, 19101, 19102, 19103, 19104, 19105, 19106, 19107, 19108, 19109,
        19110, 19111, 19112, 19113, 19114, 19115, 19116, 19117, 19118, 19119, 19120, 19121, 19122, 19123, 19124, 19125, 19126, 19127,
        19128, 19129, 19130, 19131, 19132, 19133, 19134, 19135, 19200, 19201, 19202, 19203, 19204, 19205, 19206, 19207, 19208, 19209,
        19210, 19211, 19212, 19213, 19214, 19215, 19216, 19217, 19218, 19219, 19400, 19401, 19402, 19403, 19600, 19601, 19602, 19603,
        19604, 19800, 20000, 20001, 20002, 20003, 20004, 20005, 20006, 20007, 20008, 20009, 20010, 20011, 20012, 20013, 20014, 20015,
        20016, 20017, 20018, 20019, 20020, 20021, 20022, 20023, 20024, 20025, 20026, 20027, 20028, 20029, 20030, 20031, 20032, 20033,
        20034, 20035, 20036, 20037, 20038, 20039, 20040, 20041, 20042, 20043, 20044, 20045, 20046, 20047, 20048, 20049, 20050, 20051,
        20052, 20053, 20054, 20055, 20056, 20057, 20058, 20059, 20060, 20061, 20062, 20063, 20064, 20065, 20066, 20067, 20068, 20069,
        20070, 20071, 20072, 20200, 20201, 20202, 20203, 20204, 20205, 20206, 20207, 20208, 20209, 20210, 20211, 20212, 20213, 20214,
        20215, 20216, 20217, 20218, 20219, 20220, 20221, 20222, 20223, 20224, 20225, 20226, 20227, 20228, 20229, 20230, 20231, 20232,
        20233, 20234, 20235, 20236, 20237, 20238, 20239, 20240, 20241, 20242, 20243, 20244, 20245, 20246, 20247, 20248, 20400, 20401,
        20402, 20403, 20404, 20405, 20406, 20407, 20408, 20409, 20410, 20411, 20412, 20413, 20414, 20415, 20416, 20417, 20418, 20419,
        20420, 20421, 20422, 20423, 20424, 20600, 20800, 20801, 20802, 20803, 20804, 21000, 21001, 21002, 21200, 21201, 21202, 21203,
        21204, 21205, 21206, 21207, 21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21408, 21409, 21410, 21411, 21412, 21413,
        21414, 21415, 21416, 21417, 21418, 21419, 21420, 21421, 21422, 21423, 21424, 21425, 21426, 21427, 21428, 21429, 21430, 21431,
        21432, 21433, 21434, 21435, 21436, 21437, 21438, 21439, 21440, 21441, 21442, 21443, 21444, 21445, 21446, 21447, 21448, 21449,
        21450, 21451, 21452, 21453, 21454, 21455, 21456, 21600, 21601, 21602, 21603, 21604, 21605, 21606, 21607, 21608, 21609, 21610,
        21611, 21612, 21613, 21614, 21615, 21616, 21617, 21618, 21619, 21620, 21621, 21622, 21623, 21624, 21625, 21626, 21627, 21628,
        21629, 21630, 21631, 21632, 21633, 21634, 21635, 21636, 21637, 21638, 21639, 21640, 21641, 21642, 21643, 21644, 21645, 21646,
        21647, 21648, 21649, 21650, 21651, 21652, 21653, 21654, 21655, 21656, 21657, 21658, 21659, 21660, 21661, 21662, 21663, 21664,
        21665, 21666, 21800, 21801, 21802, 21803, 21804, 21805, 21806, 21807, 21808, 22000, 22001, 22002, 22003, 22004, 22005, 22006,
        22007, 22008, 22009, 22010, 22011, 22012, 22013, 22014, 22015, 22016, 22017, 22018, 22019, 22020, 22021, 22022, 22023, 22024,
        22025, 22026, 22027, 22028, 22029, 22030, 22031, 22032, 22033, 22034, 22035, 22036, 22037, 22038, 22039, 22200, 22201, 22202,
        22203, 22204, 22205, 22206, 22207, 22208, 22209, 22210, 22211, 22212, 22213, 22214, 22215, 22216, 22217, 22400, 22401, 22402,
        22403, 22404, 22405, 22406, 22600, 22800, 22801, 22802, 22803, 22804, 22805, 22806, 22807, 22808, 22809, 22810, 22811, 22812,
        22813, 22814, 22815, 22816, 22817, 22818, 22819, 22820, 22821, 22822, 22823, 22824, 22825, 22826, 22827, 22828, 22829, 22830,
        22831, 22832, 22833, 22834, 22835, 22836, 22837, 22838, 22839, 23000, 23200, 23201, 23202, 23203, 23204, 23205, 23206, 23207,
        23208, 23209, 23400, 23600, 23800, 23801, 23802, 23803, 23804, 23805, 23806, 23807, 23808, 23809, 23810, 23811, 23812, 23813,
        23814, 23815, 23816, 23817, 23818, 23819, 23820, 23821, 23822, 23823, 23824, 23825, 23826, 23827, 23828, 23829, 23830, 23831,
        23832, 23833, 23834, 23835, 24000, 24001, 24002, 24003, 24004, 24005, 24006, 24007, 24008, 24009, 24010, 24011, 24012, 24013,
        24014, 24015, 24016, 24017, 24018, 24019, 24020, 24021, 24022, 24023, 24024, 24025, 24026, 24027, 24028, 24029, 24030, 24031,
        24032, 24033, 24034, 24035, 24036, 24037, 24038, 24039, 24040, 24041, 24042, 24043, 24044, 24045, 24046, 24047, 24048, 24049,
        24050, 24051, 24052, 24053, 24054, 24055, 24056, 24057, 24058, 24059, 24060, 24061, 24062, 24063, 24200, 24201, 24202, 24203,
        24204, 24205, 24206, 24207, 24208, 24209, 24210, 24211, 24212, 24213, 24214, 24215, 24216, 24217, 24218, 24219, 24400, 24401,
        24402, 24403, 24404, 24405, 24406, 24407, 24408, 24409, 24410, 24411, 24412, 24413, 24414, 24415, 24416, 24417, 24418, 24419,
        24420, 24421, 24422, 24423, 24424, 24425, 24426, 24427, 24428, 24429, 24430, 24431, 24432, 24433, 24600, 24800, 24801, 24802,
        24803, 24804, 24805, 24806, 24807, 24808, 24809, 24810, 24811, 24812, 24813, 24814, 24815, 24816, 24817, 24818, 24819, 24820,
        24821, 24822, 24823, 24824, 24825, 24826, 24827, 24828, 24829, 25000, 25001, 25002, 25003, 25004, 25005, 25006, 25007, 25008,
        25009, 25010, 25011, 25012, 25013, 25014, 25015, 25016, 25017, 25018, 25019, 25020, 25021, 25022, 25023, 25024, 25025, 25026,
        25027, 25028, 25029, 25030, 25031, 25032, 25033, 25034, 25035, 25036, 25037, 25038, 25039, 25040, 25041, 25042, 25043, 25044,
        25045, 25046, 25047, 25200, 25201, 25202, 25203, 25204, 25205, 25206, 25207, 25208, 25209, 25210, 25211, 25212, 25213, 25214,
        25215, 25216, 25217, 25218, 25219, 25220, 25221, 25222, 25223, 25224, 25225, 25226, 25227, 25228, 25229, 25230, 25231, 25232,
        25233, 25234, 25235, 25236, 25237, 25238, 25239, 25240, 25241, 25242, 25243, 25244, 25245, 25246, 25247, 25248, 25249, 25250,
        25251, 25252, 25253, 25254, 25255, 25256, 25257, 25258, 25259, 25260, 25261, 25262, 25263, 25264, 25265, 25266, 25267, 25268,
        25269, 25270, 25271, 25272, 25273, 25274, 25275, 25276, 25277, 25278, 25279, 25280, 25281, 25282, 25283, 25284, 25285, 25286,
        25287, 25288, 25289, 25290, 25291, 25292, 25293, 25294, 25295, 25296, 25297, 25298, 25299, 25300, 25301, 25302, 25303, 25304,
        25305, 25306, 25307, 25308, 25309, 25310, 25311, 25312, 25313, 25314, 25315, 25316, 25317, 25318, 25319, 25400, 25401, 25402,
        25403, 25404, 25405, 25406, 25407, 25408, 25409, 25410, 25411, 25412, 25413, 25414, 25415, 25416, 25417, 25418, 25419, 25420,
        25421, 25422, 25423, 25600, 25601, 25602, 25603, 25604, 25800, 25801, 26000, 26001, 26002, 26003, 26004, 26005, 26006, 26007,
        26008, 26009, 26200, 26201, 26202, 26203, 26204, 26205, 26206, 26207, 26208, 26209, 26210, 26211, 26212, 26213, 26214, 26215,
        26216, 26217, 26218, 26219, 26220, 26221, 26222, 26223, 26400, 26401, 26402, 26403, 26404, 26405, 26406, 26407, 26408, 26409,
        26410, 26411, 26412, 26600, 26601, 26602, 26603, 26604, 26605, 26606, 26607, 26608, 26609, 26610, 26611, 26612, 26613, 26614,
        26615, 26616, 26617, 26618, 26619, 26620, 26621, 26622, 26623, 26624, 26625, 26626, 26627, 26628, 26629, 26630, 26631, 26632,
        26633, 26800, 26801, 26802, 26803, 26804, 26805, 26806, 26807, 26808, 26809, 26810, 26811, 27000, 27001, 27002, 27003, 27004,
        27005, 27006, 27007, 27008, 27009, 27010, 27011, 27012, 27013, 27014, 27015, 27016, 27017, 27018, 27200, 27201, 27202, 27203,
        27204, 27205, 27400, 27401, 27402, 27403, 27404, 27405, 27406, 27407, 27408, 27409, 27410, 27411, 27412, 27413, 27414, 27415,
        27416, 27417, 27418, 27419, 27420, 27421, 27422, 27600, 27601, 27602, 27603, 27604, 27605, 27606, 27607, 27608, 27609, 27610,
        27611, 27612, 27613, 27614, 27615, 27616, 27617, 27618, 27619, 27620, 27621, 27800, 27801, 27802, 27803, 27804, 27805, 27806,
        27807, 27808, 27809, 27810, 27811, 27812, 27813, 27814, 27815, 27816, 27817, 27818, 27819, 27820, 27821, 27822, 27823, 27824,
        27825, 27826, 27827, 27828, 27829, 27830, 27831, 27832, 27833, 28000, 28200, 28201, 28202, 28203, 28204, 28400, 28401, 28402,
        28403, 28404, 28405, 28406, 28407, 28408, 28409, 28410, 28411, 28412, 28413, 28414, 28415, 28416, 28417, 28418, 28419, 28420,
        28421, 28422, 28423, 28424, 28425, 28426, 28427, 28600, 28601, 28602, 28603, 28604, 28605, 28606, 28607, 28608, 28609, 28610,
        28611, 28612, 28613, 28614, 28615, 28616, 28617, 28618, 28619, 28620, 28621, 28622, 28800, 28801, 28802, 28803, 28804, 28805,
        28806, 28807, 28808, 28809, 28810, 28811, 29000, 29001, 29002, 29003, 29004, 29005, 29006, 29007, 29008, 29009, 29010, 29011,
        29012, 29013, 29014, 29015, 29016, 29017, 29018, 29019, 29020, 29021, 29022, 29023, 29024, 29025, 29026, 29027, 29028, 29029,
        29030, 29031, 29032, 29033, 29034, 29035, 29036, 29037, 29038, 29039, 29040, 29041, 29042, 29043, 29044, 29045, 29046, 29047,
        29048, 29049, 29050, 29051, 29052, 29053, 29054, 29055, 29056, 29057, 29058, 29059, 29060, 29061, 29062, 29063, 29064, 29065,
        29066, 29067, 29068, 29069, 29070, 29071, 29072, 29073, 29074, 29075, 29076, 29077, 29078, 29079, 29080, 29081, 29082, 29083,
        29084, 29085, 29086, 29087, 29088, 29089, 29090, 29091, 29092, 29093, 29094, 29095, 29096, 29097, 29098, 29099, 29100, 29101,
        29102, 29103, 29104, 29105, 29106, 29107, 29108, 29109, 29110, 29111, 29112, 29113, 29114, 29115, 29116, 29117, 29118, 29119,
        29120, 29121, 29122, 29123, 29124, 29125, 29126, 29127, 29128, 29129, 29130, 29131, 29132, 29133, 29134, 29135, 29136, 29137,
        29138, 29139, 29140, 29141, 29142, 29143, 29144, 29145, 29146, 29147, 29148, 29149, 29150, 29151, 29152, 29153, 29154, 29155,
        29200, 29201, 29202, 29203, 29204, 29205, 29206, 29207, 29208, 29209, 29210, 29211, 29212, 29213, 29214, 29215, 29216, 29217,
        29400, 29401, 29402, 29403, 29404, 29405, 29406, 29407, 29408, 29409, 29410, 29411, 29412, 29413, 29600, 29601, 29602, 29603,
        29604, 29605, 29606, 29607, 29608, 29609, 29610, 29611, 29612, 29613, 29614, 29615, 29616, 29617, 29618, 29619, 29620, 29621,
        29622, 29623, 29624, 29625, 29626, 29627, 29628, 29629, 29630, 29631, 29632, 29633, 29634, 29635, 29636, 29637, 29638, 29639,
        29640, 29641, 29642, 29643, 29644, 29645, 29646, 29647, 29648, 29649, 29650, 29651, 29652, 29653, 29654, 29655, 29656, 29657,
        29658, 29659, 29660, 29661, 29662, 29663, 29664, 29665, 29800, 29801, 29802, 29803, 29804, 29805, 29806, 29807, 29808, 29809,
        29810, 29811, 29812, 29813, 29814, 29815, 29816, 29817, 29818, 29819, 29820, 29821, 29822, 29823, 29824, 29825, 30000, 30001,
        30002, 30003, 30004, 30005, 30006, 30007, 30008, 30009, 30010, 30011, 30012, 30013, 30014, 30015, 30016, 30017, 30018, 30019,
        30020, 30021, 30022, 30023, 30024, 30025, 30026, 30027, 30028, 30029, 30030, 30031, 30032, 30033, 30034, 30035, 30036, 30037,
        30038, 30039, 30040, 30041, 30042, 30043, 30044, 30045, 30046, 30047, 30048, 30049, 30050, 30051, 30052, 30053, 30054, 30055,
        30056, 30057, 30058, 30059, 30060, 30061, 30062, 30063, 30064, 30065, 30066, 30067, 30068, 30069, 30070, 30071, 30072, 30073,
        30074, 30075, 30076, 30077, 30078, 30079, 30080, 30081, 30082, 30200, 30201, 30202, 30203, 30204, 30205, 30206, 30207, 30208,
        30209, 30210, 30211, 30212, 30213, 30214, 30215, 30216, 30217, 30218, 30219, 30220, 30221, 30400, 30401, 30402, 30403, 30404,
        30405, 30406, 30407, 30408, 30409, 30410, 30411, 30412, 30413, 30414, 30415, 30416, 30600, 30800, 30801, 30802, 30803, 31000,
        31001, 31200, 31201, 31202, 31203, 31204, 31205, 31400, 31600, 31601, 31602, 31603, 31604, 31605, 31800, 31801, 31802, 31803,
        31804, 31805, 31806, 31807, 31808, 31809, 31810, 32000, 32200, 32201, 32400, 32401, 32402, 32600, 32800, 32801, 32802, 32803,
        32804, 32805, 32806, 32807, 32808, 32809, 32810, 32811, 32812, 32813, 32814, 32815, 32816, 32817, 32818, 32819, 32820, 32821,
        32822, 32823, 32824, 32825, 32826, 32827, 32828, 32829, 32830, 32831, 32832, 32833, 32834, 32835, 32836, 32837, 32838, 32839,
        32840, 32841, 32842, 32843, 32844, 32845, 32846, 32847, 33000, 33001, 33002, 33003, 33004, 33005, 33006, 33007, 33008, 33009,
        33010, 33011, 33012, 33013, 33014, 33015, 33016, 33017, 33018, 33019, 33020, 33021, 33022, 33023, 33024, 33025, 33026, 33027,
        33028, 33029, 33030, 33031, 33032, 33033, 33034, 33035, 33036, 33037, 33038, 33039, 33040, 33041, 33042, 33043, 33044, 33045,
        33046, 33047, 33048, 33049, 33050, 33051, 33052, 33053, 33054, 33055, 33056, 33057, 33058, 33059, 33060, 33061, 33062, 33063,
        33064, 33065, 33066, 33067, 33068, 33069, 33070, 33071, 33072, 33073, 33074, 33075, 33076, 33077, 33078, 33079, 33080, 33081,
        33082, 33083, 33084, 33085, 33086, 33087, 33088, 33200, 33201, 33202, 33203, 33204, 33205, 33206, 33207, 33208, 33209, 33210,
        33211, 33212, 33213, 33214, 33215, 33216, 33217, 33218, 33219, 33220, 33221, 33222, 33223, 33224, 33225, 33226, 33227, 33228,
        33229, 33230, 33231, 33232, 33233, 33234, 33235, 33236, 33237, 33238, 33239, 33240, 33241, 33242, 33243, 33244, 33245, 33246,
        33247, 33248, 33249, 33250, 33251, 33252, 33253, 33254, 33255, 33256, 33257, 33258, 33259, 33260, 33261, 33262, 33263, 33264,
        33265, 33266, 33267, 33268, 33269, 33270, 33271, 33272, 33273, 33274, 33275, 33276, 33277, 33278, 33279, 33280, 33281, 33282,
        33283, 33284, 33285, 33286, 33287, 33288, 33289, 33290, 33291, 33292, 33293, 33294, 33295, 33296, 33297, 33298, 33299, 33300,
        33301, 33302, 33303, 33304, 33400, 33401, 33402, 33403, 33600, 33601, 33602, 33603, 33604, 33605, 33606, 33607, 33608, 33609,
        33610, 33611, 33612, 33613, 33614, 33615, 33616, 33617, 33618, 33619, 33620, 33621, 33622, 33623, 33624, 33625, 33626, 33627,
        33628, 33629, 33630, 33631, 33632, 33633, 33634, 33635, 33636, 33637, 33638, 33639, 33640, 33641, 33642, 33643, 33644, 33645,
        33646, 33647, 33648, 33649, 33650, 33651, 33652, 33653, 33654, 33655, 33656, 33657, 33658, 33659, 33660, 33661, 33662, 33663,
        33664, 33665, 33666, 33667, 33668, 33669, 33670, 33671, 33672, 33673, 33674, 33675, 33676, 33800, 33801, 33802, 33803, 33804,
        33805, 33806, 33807, 33808, 33809, 33810, 33811, 33812, 33813, 33814, 33815, 33816, 33817, 33818, 33819, 33820, 33821, 33822,
        33823, 33824, 33825, 33826, 33827, 33828, 33829, 33830, 33831, 33832, 33833, 33834, 33835, 33836, 33837, 33838, 33839, 33840,
        33841, 33842, 33843, 33844, 33845, 33846, 33847, 33848, 33849, 33850, 33851, 33852, 33853, 33854, 33855, 33856, 33857, 33858,
        33859, 33860, 33861, 33862, 33863, 33864, 33865, 33866, 33867, 33868, 33869, 33870, 33871, 33872, 33873, 33874, 33875, 33876,
        33877, 33878, 33879, 33880, 33881, 33882, 33883, 33884, 33885, 33886, 33887, 33888, 33889, 34000, 34001, 34002, 34003, 34004,
        34005, 34006, 34007, 34008, 34009, 34010, 34011, 34012, 34013, 34014, 34015, 34016, 34017, 34018, 34019, 34020, 34021, 34022,
        34023, 34024, 34025, 34026, 34027, 34028, 34029, 34030, 34031, 34032, 34033, 34034, 34035, 34036, 34037, 34038, 34039, 34040,
        34041, 34042, 34043, 34044, 34045, 34046, 34047, 34048, 34049, 34050, 34051, 34052, 34053, 34054, 34055, 34056, 34057, 34058,
        34059, 34060, 34061, 34062, 34063, 34064, 34065, 34066, 34067, 34200, 34201, 34202, 34203, 34204, 34205, 34206, 34207, 34208,
        34209, 34210, 34211, 34212, 34213, 34214, 34215, 34216, 34217, 34218, 34219, 34220, 34221, 34222, 34223, 34224, 34225, 34226,
        34227, 34228, 34229, 34230, 34231, 34232, 34233, 34234, 34235, 34236, 34237, 34238, 34239, 34240, 34241, 34242, 34243, 34244,
        34245, 34246, 34247, 34248, 34249, 34250, 34251, 34252, 34253, 34254, 34255, 34256, 34257, 34258, 34259, 34260, 34261, 34262,
        34263, 34264, 34265, 34266, 34267, 34268, 34269, 34270, 34271, 34272, 34273, 34400, 34401, 34402, 34403, 34404, 34405, 34406,
        34407, 34408, 34409, 34410, 34411, 34412, 34413, 34414, 34415, 34600, 34601, 34602, 34603, 34604, 34605, 34606, 34800, 34801,
        34802, 34803, 34804, 34805, 34806, 34807, 34808, 34809, 34810, 34811, 34812, 34813, 34814, 34815, 34816, 34817, 34818, 34819,
        34820, 34821, 34822, 34823, 34824, 34825, 34826, 34827, 34828, 34829, 34830, 34831, 35000, 35001, 35002, 35003, 35004, 35005,
        35006, 35007, 35008, 35009, 35010, 35011, 35012, 35013, 35014, 35015, 35016, 35017, 35018, 35019, 35020, 35021, 35022, 35023,
        35024, 35025, 35026, 35027, 35028, 35029, 35030, 35031, 35032, 35033, 35034, 35035, 35036, 35037, 35038, 35039, 35040, 35041,
        35042, 35043, 35044, 35045, 35046, 35047, 35048, 35049, 35050, 35051, 35052, 35053, 35054, 35055, 35056, 35057, 35058, 35059,
        35060, 35061, 35062, 35063, 35064, 35065, 35066, 35067, 35068, 35069, 35070, 35071, 35072, 35073, 35074, 35075, 35200, 35201,
        35202, 35203, 35204, 35205, 35206, 35207, 35208, 35209, 35210, 35211, 35212, 35213, 35214, 35215, 35216, 35217, 35218, 35219,
        35220, 35221, 35222, 35223, 35224, 35225, 35226, 35227, 35228, 35229, 35230, 35231, 35232, 35233, 35234, 35235, 35236, 35237,
        35238, 35239, 35240, 35400, 35401, 35402, 35403, 35404, 35405, 35406, 35407, 35408, 35409, 35410, 35411, 35412, 35413, 35414,
        35415, 35416, 35417, 35418, 35419, 35420, 35421, 35422, 35423, 35424, 35425, 35426, 35427, 35428, 35429, 35430, 35431, 35432,
        35433, 35434, 35435, 35436, 35437, 35438, 35439, 35440, 35441, 35442, 35443, 35444, 35445, 35446, 35447, 35448, 35449, 35450,
        35451, 35452, 35453, 35454, 35455, 35456, 35457, 35458, 35459, 35460, 35461, 35462, 35463, 35464, 35465, 35466, 35467, 35468,
        35469, 35470, 35471, 35472, 35473, 35474, 35475, 35476, 35477, 35478, 35479, 35480, 35481, 35482, 35483, 35484, 35485, 35486,
        35487, 35488, 35600, 35601, 35602, 35603, 35604, 35605, 35606, 35607, 35608, 35609, 35610, 35611, 35612, 35613, 35614, 35615,
        35616, 35617, 35618, 35619, 35620, 35621, 35622, 35623, 35624, 35625, 35626, 35627, 35628, 35629, 35630, 35631, 35632, 35633,
        35634, 35635, 35636, 35637, 35638, 35639, 35640, 35641, 35642, 35643, 35644, 35645, 35646, 35647, 35648, 35649, 35650, 35651,
        35652, 35653, 35654, 35655, 35656, 35657, 35658, 35659, 35660, 35661, 35662, 35663, 35664, 35665, 35666, 35667, 35668, 35669,
        35670, 35671, 35672, 35673, 35674, 35675, 35676, 35677, 35678, 35679, 35680, 35681, 35682, 35683, 35684, 35685, 35686, 35687,
        35688, 35689, 35690, 35691, 35692, 35693, 35694, 35695, 35696, 35697, 35698, 35699, 35700, 35701, 35702, 35703, 35704, 35705,
        35706, 35707, 35708, 35709, 35710, 35711, 35712, 35713, 35714, 35715, 35716, 35717, 35718, 35719, 35720, 35721, 35722, 35723,
        35724, 35725, 35726, 35727, 35728, 35729, 35730, 35731, 35732, 35733, 35800, 35801, 35802, 35803, 35804, 35805, 35806, 35807,
        35808, 35809, 35810, 35811, 35812, 35813, 35814, 35815, 35816, 35817, 35818, 35819, 35820, 35821, 35822, 35823, 35824, 35825,
        35826, 35827, 35828, 35829, 35830, 35831, 35832, 35833, 35834, 35835, 35836, 35837, 35838, 35839, 35840, 35841, 35842, 35843,
        35844, 35845, 35846, 35847, 35848, 35849, 35850, 35851, 35852, 35853, 35854, 35855, 35856, 35857, 35858, 35859, 35860, 35861,
        35862, 35863, 35864, 35865, 35866, 35867, 35868, 35869, 35870, 35871, 35872, 35873, 35874, 35875, 35876, 35877, 35878, 35879,
        35880, 35881, 35882, 35883, 36000, 36200, 36201, 36202, 36203, 36204, 36205, 36400, 36401, 36600, 36601, 36602, 36603, 36604,
        36800, 36801, 36802, 36803, 36804, 36805, 36806, 36807, 36808, 36809, 36810, 36811, 36812, 36813, 36814, 36815, 36816, 36817,
        36818, 36819, 36820, 36821, 36822, 36823, 36824, 36825, 36826, 36827, 36828, 36829, 36830, 36831, 36832, 36833, 36834, 36835,
        36836, 36837, 36838, 36839, 36840, 36841, 36842, 36843, 36844, 36845, 36846, 36847, 36848, 36849, 36850, 36851, 36852, 36853,
        36854, 36855, 36856, 36857, 36858, 36859, 36860, 37000, 37001, 37002, 37003, 37004, 37005, 37006, 37007, 37008, 37009, 37010,
        37011, 37012, 37013, 37014, 37015, 37016, 37017, 37018, 37019, 37020, 37021, 37022, 37023, 37024, 37025, 37026, 37027, 37028,
        37029, 37030, 37031, 37032, 37033, 37034, 37035, 37200, 37201, 37202, 37203, 37204, 37205, 37206, 37207, 37208, 37209, 37210,
        37211, 37212, 37213, 37214, 37215, 37216, 37217, 37218, 37219, 37220, 37221, 37222, 37223, 37224, 37225, 37226, 37227, 37228,
        37229, 37230, 37231, 37232, 37233, 37234, 37235, 37236, 37237, 37238, 37239, 37240, 37241, 37242, 37243, 37244, 37245, 37400,
        37401, 37402, 37403, 37404, 37405, 37406, 37407, 37408, 37409, 37410, 37411, 37412, 37413, 37414, 37415, 37416, 37417, 37418,
        37419, 37420, 37421, 37422, 37423, 37424, 37425, 37426, 37427, 37428, 37429, 37430, 37431, 37432, 37433, 37434, 37435, 37436,
        37437, 37438, 37439, 37440, 37441, 37442, 37443, 37444, 37445, 37446, 37447, 37448, 37449, 37450, 37451, 37452, 37453, 37454,
        37455, 37456, 37457, 37458, 37459, 37460, 37461, 37462, 37463, 37464, 37465, 37466, 37467, 37468, 37469, 37470, 37471, 37472,
        37473, 37474, 37475, 37476, 37477, 37478, 37479, 37480, 37481, 37482, 37483, 37484, 37485, 37486, 37487, 37488, 37489, 37490,
        37491, 37492, 37493, 37494, 37600, 37601, 37602, 37603, 37604, 37605, 37606, 37607, 37608, 37609, 37610, 37611, 37612, 37613,
        37614, 37615, 37616, 37617, 37618, 37619, 37620, 37621, 37622, 37623, 37624, 37625, 37626, 37627, 37628, 37629, 37630, 37631,
        37632, 37633, 37634, 37635, 37636, 37637, 37638, 37639, 37640, 37641, 37642, 37643, 37644, 37645, 37646, 37647, 37648, 37649,
        37650, 37651, 37652, 37653, 37654, 37655, 37656, 37657, 37658, 37659, 37660, 37661, 37662, 37663, 37664, 37665, 37666, 37667,
        37668, 37669, 37670, 37671, 37672, 37673, 37674, 37675, 37676, 37677, 37678, 37679, 37680, 37681, 37800, 37801, 37802, 37803,
        37804, 37805, 37806, 37807, 37808, 37809, 37810, 37811, 37812, 37813, 37814, 37815, 37816, 37817, 37818, 37819, 37820, 37821,
        37822, 37823, 37824, 37825, 37826, 37827, 37828, 37829, 37830, 37831, 37832, 37833, 37834, 37835, 37836, 37837, 37838, 37839,
        37840, 37841, 37842, 37843, 37844, 37845, 37846, 37847, 37848, 37849, 37850, 37851, 37852, 37853, 37854, 37855, 37856, 37857,
        37858, 37859, 37860, 37861, 37862, 37863, 37864, 37865, 37866, 37867, 37868, 37869, 37870, 37871, 37872, 37873, 38000, 38001,
        38002, 38003, 38004, 38005, 38006, 38007, 38008, 38009, 38010, 38011, 38012, 38013, 38014, 38015, 38016, 38017, 38018, 38019,
        38020, 38021, 38022, 38023, 38024, 38025, 38026, 38027, 38028, 38029, 38030, 38031, 38032, 38033, 38034, 38035, 38036, 38037,
        38038, 38039, 38040, 38041, 38042, 38043, 38044, 38045, 38046, 38047, 38048, 38049, 38050, 38051, 38052, 38053, 38054, 38055,
        38056, 38057, 38058, 38059, 38060, 38200, 38201, 38202, 38203, 38204, 38205, 38206, 38207, 38208, 38209, 38210, 38211, 38212,
        38213, 38214, 38215, 38216, 38217, 38218, 38219, 38220, 38221, 38222, 38223, 38224, 38225, 38226, 38227, 38228, 38229, 38230,
        38231, 38232, 38233, 38234, 38235, 38236, 38237, 38238, 38400, 38401, 38402, 38403, 38404, 38405, 38406, 38407, 38408, 38409,
        38410, 38411, 38412, 38413, 38414, 38415, 38416, 38417, 38418, 38419, 38420, 38421, 38422, 38423, 38424, 38425, 38426, 38427,
        38428, 38429, 38430, 38431, 38432, 38433, 38434, 38435, 38436, 38437, 38438, 38439, 38440, 38441, 38442, 38443, 38444, 38445,
        38446, 38447, 38448, 38449, 38450, 38451, 38452, 38453, 38454, 38455, 38456, 38457, 38458, 38459, 38460, 38461, 38462, 38463,
        38464, 38465, 38466, 38467, 38468, 38469, 38470, 38471, 38600, 38601, 38602, 38603, 38604, 38605, 38606, 38607, 38608, 38609,
        38610, 38611, 38612, 38613, 38614, 38615, 38616, 38617, 38618, 38619, 38620, 38621, 38622, 38623, 38624, 38625, 38626, 38627,
        38628, 38629, 38630, 38631, 38632, 38633, 38634, 38635, 38636, 38637, 38638, 38639, 38640, 38641, 38642, 38643, 38644, 38800,
        38801, 38802, 38803, 38804, 38805, 38806, 38807, 38808, 38809, 38810, 38811, 38812, 38813, 38814, 38815, 38816, 38817, 38818,
        38819, 38820, 38821, 38822, 38823, 38824, 38825, 38826, 38827, 38828, 38829, 38830, 38831, 38832, 38833, 38834, 38835, 38836,
        38837, 38838, 38839, 38840, 38841, 38842, 38843, 38844, 38845, 38846, 38847, 38848, 38849, 38850, 38851, 38852, 38853, 38854,
        39000, 39001, 39002, 39003, 39004, 39005, 39006, 39007, 39008, 39009, 39010, 39011, 39012, 39013, 39014, 39015, 39016, 39017,
        39018, 39019, 39020, 39021, 39022, 39023, 39024, 39025, 39026, 39027, 39028, 39029, 39030, 39031, 39032, 39033, 39034, 39035,
        39036, 39037, 39038, 39039, 39040, 39041, 39042, 39043, 39044, 39045, 39046, 39047, 39048, 39049, 39050, 39051, 39052, 39053,
        39054, 39055, 39056, 39057, 39058, 39059, 39060, 39061, 39062, 39063, 39064, 39065, 39066, 39067, 39068, 39069, 39070, 39071,
        39072, 39073, 39074, 39075, 39076, 39077, 39078, 39200, 39201, 39202, 39203, 39204, 39205, 39206, 39207, 39208, 39209, 39210,
        39211, 39212, 39213, 39214, 39215, 39216, 39217, 39218, 39219, 39220, 39221, 39222, 39223, 39400, 39401, 39402, 39403, 39404,
        39405, 39406, 39407, 39408, 39409, 39410, 39411, 39412, 39413, 39600, 39601, 39602, 39603, 39604, 39605, 39606, 39607, 39608,
        39609, 39610, 39611, 39612, 39613, 39614, 39615, 39616, 39617, 39618, 39619, 39620, 39621, 39622, 39623, 39624, 39625, 39626,
        39627, 39628, 39629, 39630, 39631, 39632, 39633, 39634, 39635, 39636, 39637, 39638, 39639, 39640, 39641, 39642, 39643, 39644,
        39645, 39646, 39647, 39648, 39649, 39650, 39651, 39652, 39653, 39654, 39655, 39656, 39657, 39658, 39659, 39660, 39661, 39662,
        39663, 39664, 39665, 39666, 39667, 39800, 39801, 39802, 39803, 39804, 39805, 39806, 39807, 39808, 39809, 39810, 39811, 39812,
        39813, 39814, 39815, 40000, 40200, 40201, 40202, 40203, 40204, 40205, 40206, 40207, 40208, 40209, 40210, 40211, 40212, 40213,
        40214, 40215, 40216, 40217, 40218, 40219, 40220, 40221, 40222, 40223, 40224, 40225, 40226, 40227, 40228, 40229, 40230, 40231,
        40232, 40233, 40234, 40235, 40236, 40237, 40238, 40400, 40401, 40402, 40403, 40404, 40405, 40406, 40407, 40408, 40600, 40800,
        40801, 40802, 40803, 40804, 40805, 40806, 40807, 40808, 40809, 40810, 40811, 40812, 40813, 40814, 40815, 40816, 40817, 40818,
        40819, 40820, 41000, 41001, 41002, 41003, 41004, 41005, 41006, 41007, 41008, 41009, 41010, 41011, 41012, 41013, 41014, 41015,
        41016, 41017, 41018, 41019, 41020, 41021, 41022, 41023, 41024, 41025, 41026, 41027, 41028, 41029, 41030, 41031, 41032, 41033,
        41034, 41035, 41036, 41037, 41038, 41039, 41040, 41041, 41042, 41200, 41201, 41202, 41203, 41204, 41205, 41206, 41207, 41208,
        41209, 41210, 41211, 41212, 41213, 41214, 41215, 41216, 41217, 41218, 41219, 41220, 41221, 41222, 41223, 41224, 41225, 41226,
        41227, 41228, 41229, 41230, 41231, 41232, 41233, 41234, 41235, 41236, 41237, 41238, 41239, 41240, 41241, 41242, 41243, 41244,
        41245, 41246, 41247, 41248, 41249, 41250, 41251, 41252, 41253, 41254, 41255, 41256, 41257, 41258, 41259, 41260, 41261, 41262,
        41263, 41264, 41265, 41266, 41267, 41268, 41269, 41270, 41271, 41272, 41400, 41401, 41402, 41403, 41404, 41405, 41406, 41407,
        41408, 41409, 41410, 41411, 41412, 41413, 41414, 41415, 41416, 41417, 41418, 41419, 41420, 41421, 41422, 41423, 41424, 41425,
        41426, 41427, 41428, 41429, 41430, 41431, 41432, 41600, 41601, 41602, 41603, 41604, 41800, 42000, 42001, 42002, 42003, 42004,
        42005, 42006, 42007, 42008, 42009, 42010, 42011, 42200, 42201, 42202, 42203, 42204, 42205, 42206, 42207, 42208, 42400, 42401,
        42402, 42403, 42404, 42405, 42406, 42407, 42408, 42409, 42410, 42411, 42412, 42413, 42414, 42415, 42416, 42417, 42418, 42419,
        42420, 42421, 42422, 42423, 42424, 42600, 42601, 42800, 42801, 42802, 42803, 43000, 43001, 43200, 43201, 43202, 43203, 43204,
        43205, 43206, 43400, 43401, 43402, 43403, 43404, 43405, 43406, 43407, 43600, 43601, 43602, 43603, 43604, 43605, 43606, 43607,
        43608, 43609, 43610, 43611, 43612, 43613, 43614, 43615, 43616, 43617, 43618, 43619, 43620, 43621, 43622, 43623, 43624, 43625,
        43626, 43627, 43628, 43629, 43630, 43631, 43632, 43633, 43634, 43635, 43636, 43637, 43638, 43639, 43640, 43641, 43642, 43643,
        43644, 43645, 43646, 43647, 43648, 43649, 43650, 43651, 43652, 43653, 43654, 43655, 43656, 43657, 43658, 43659, 43660, 43661,
        43662, 43663, 43664, 43800, 43801, 43802, 43803, 43804, 43805, 43806, 43807, 43808, 43809, 43810, 43811, 43812, 43813, 43814,
        43815, 43816, 43817, 43818, 43819, 43820, 43821, 43822, 43823, 43824, 43825, 43826, 43827, 43828, 43829, 43830, 43831, 43832,
        43833, 43834, 43835, 43836, 43837, 43838, 43839, 43840, 43841, 43842, 43843, 43844, 43845, 43846, 43847, 43848, 43849, 43850,
        43851, 43852, 43853, 43854, 43855, 43856, 43857, 43858, 43859, 43860, 43861, 43862, 43863, 43864, 43865, 43866, 43867, 43868,
        43869, 43870, 43871, 43872, 43873, 43874, 43875, 43876, 43877, 43878, 43879, 43880, 43881, 43882, 43883, 43884, 43885, 43886,
        43887, 43888, 43889, 43890, 43891, 43892, 43893, 43894, 43895, 43896, 43897, 43898, 43899, 43900, 43901, 43902, 43903, 43904,
        43905, 44000, 44001, 44002, 44003, 44004, 44005, 44006, 44007, 44008, 44009, 44010, 44011, 44012, 44013, 44014, 44015, 44016,
        44017, 44018, 44019, 44020, 44021, 44022, 44023, 44024, 44025, 44026, 44027, 44028, 44029, 44030, 44031, 44032, 44033, 44034,
        44035, 44036, 44037, 44038, 44039, 44040, 44041, 44042, 44043, 44044, 44045, 44046, 44047, 44048, 44049, 44050, 44051, 44052,
        44053, 44054, 44055, 44056, 44057, 44058, 44059, 44060, 44061, 44062, 44063, 44064, 44065, 44066, 44067, 44068, 44069, 44070,
        44071, 44072, 44073, 44074, 44075, 44076, 44077, 44078, 44079, 44080, 44081, 44082, 44083, 44084, 44085, 44086, 44087, 44088,
        44089, 44090, 44091, 44092, 44093, 44094, 44095, 44096, 44097, 44098, 44099, 44100, 44101, 44102, 44103, 44104, 44105, 44106,
        44107, 44200, 44201, 44202, 44203, 44204, 44205, 44206, 44207, 44208, 44209, 44210, 44211, 44212, 44213, 44214, 44215, 44216,
        44217, 44218, 44219, 44220, 44221, 44222, 44223, 44224, 44225, 44226, 44227, 44228, 44229, 44230, 44231, 44232, 44233, 44234,
        44235, 44236, 44237, 44238, 44239, 44240, 44241, 44242, 44243, 44244, 44245, 44246, 44247, 44400, 44401, 44402, 44403, 44404,
        44405, 44406, 44407, 44408, 44409, 44410, 44411, 44412, 44413, 44414, 44415, 44416, 44417, 44418, 44419, 44420, 44421, 44422,
        44423, 44424, 44425, 44426, 44427, 44428, 44429, 44430, 44431, 44432, 44433, 44434, 44435, 44436, 44437, 44438, 44439, 44440,
        44441, 44442, 44443, 44444, 44600, 44601, 44602, 44603, 44604, 44605, 44606, 44607, 44608, 44609, 44610, 44611, 44612, 44613,
        44614, 44615, 44616, 44617, 44618, 44619, 44620, 44621, 44622, 44623, 44624, 44625, 44626, 44627, 44628, 44629, 44630, 44631,
        44800, 44801, 44802, 44803, 44804, 44805, 44806, 44807, 44808, 44809, 44810, 44811, 44812, 44813, 44814, 44815, 44816, 44817,
        44818, 44819, 44820, 45000, 45001, 45002, 45003, 45004, 45005, 45006, 45007, 45008, 45009, 45010, 45011, 45200, 45201, 45202,
        45203, 45204, 45205, 45206, 45207, 45208, 45209, 45210, 45211, 45212, 45213, 45214, 45215, 45216, 45217, 45218, 45219, 45220,
        45221, 45222, 45223, 45224, 45225, 45226, 45227, 45228, 45229, 45230, 45231, 45232, 45233, 45234, 45235, 45236, 45237, 45238,
        45239, 45240, 45241, 45242, 45243, 45244, 45245, 45246, 45247, 45248, 45249, 45250, 45251, 45252, 45253, 45254, 45255, 45400
};

*/
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ------------------     RACE STUFF     ---------------------------------------
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#if defined RACES//yrace
#define MAX_RACECHECKPOINTS 64 // Change if you want more room for checkpoints than this
#define MAX_BUILDERS 4 // Change if you want more builderslots than this
#define RACEFILE_VERSION 2 // !!! DO NOT CHANGE !!!
#define RACE_MENU // Enable race build/load menus
#define MAX_RACERS 10 //total amt of racers allowed in a race
new rotationtimer;
new race1st[MAX_PLAYERS]; // total races placed 1st
new race2nd[MAX_PLAYERS]; // total races placed 2nd
new race3rd[MAX_PLAYERS]; //total races placed 3rd
new MajorityDelay = 60; // Default delay to wait for other racers once half are ready (can be changed ingame via Admin menu)
new RRotation = 1;      // Is automatic Race Rotation enabled by defaul? (can be changed ingame via Admin menu) (-1 = disabled, 0+ = enabled)
new BuildAdmin = 1; //Require admin privileges for building races? 1)  yes, 0) no. (Can be changed ingame in Admin menu)
new RaceAdmin = 1;  //Require admin privileges for starting races? 1)  yes, 0) no. (Can be changed ingame in Admin menu)
new PrizeMode=0;        //Mode for winnings: 0 - Fixed, 1 - Dynamic, 2 - Entry fee, 3 - EF+F, 4 EF+D [Admin menu ingame]
new Prize=10000;        //Fixed prize sum (15,000$ for winner, 12,5000$ for 2nd and 10,000$ for 3rd) [Admin menu ingame]
new DynaMP=1;           //Dynamic prize multiplier. (Default: 1$/m) [Admin menu ingame]
new JoinFee=100;       //Amount of $ it costs to /join a race      [Admin menu ingame]

#if defined RACE_MENU
forward RefreshMenuHeader(playerid,Menu:menu,text[]);
new Menu:MAdmin, Menu:MPMode, Menu:MPrize, Menu:MDyna, Menu:MBuild, Menu:MLaps;
new Menu:MRace, Menu:MRacemode, Menu:MFee, Menu:MCPsize, Menu:MDelay;
#endif //race_menu

forward RaceRotation();
forward ReadyRefresh();      	  		// Check the /ready status of players and start the race when ready
forward RaceSound(playerid,sound);      // Plays <sound> for <playerid>
forward BActiveCP(playerid,sele);       // Gives the player selected checkpoint
forward endrace();                      // Ends the race, whether it ended normally or by /endrace. Cleans the variables.
forward countdown();                    // Handles the countdown
forward mscountdown();                  //Majority Start countdown handler
forward SetNextCheckpoint(playerid);    // Gives the next checkpoint for the player during race
forward ChangeLap(playerid);            // Change player's lap, print out time and stuff.
forward SetRaceCheckpoint(playerid,target,next);    // Race-mode checkpoint setter
forward SetBRaceCheckpoint(playerid,target,next);   // Builder-mode checkpoint  setter
forward GetBuilderSlot(playerid);   // Get next free builderslot, return 0 if none available
forward b(playerid); 		       // Quick and dirty fix for the BuilderSlots
forward Float:Distance(Float:dx1,Float:dy1,Float:dz1,Float:dx2,Float:dy2,Float:dz2);
forward clearrace(playerid);
forward startrace();
forward LoadRace(tmp[]);
forward CreateRaceMenus();

// isvalidvehicle exists on server but not in includes. line below needed to fix that
native IsValidVehicle(vehicleid);

new RacePreLoaded;
new rcount[MAX_PLAYERS];
new rtimer[MAX_PLAYERS]; //30 sec countdown timer
new raceclear; // orphan race timer
new CBuilder[MAX_PLAYER_NAME], CFile[128], CRaceName[64];        //Creator of the race and the filename, for score changing purposes.
new Ranking;            //Finishing order for prizes
new Countdown;
new cd;                 //Countdown time
new MajStart=0;         //Status of the Majority Start timer
new MajStartTimer;      //Majority Start timer
new mscd;               //Majority Start time
new RaceActive;         //Is a race active?
new RaceStart;          //Has race started?
new Float:RaceCheckpoints[MAX_RACECHECKPOINTS][3];  //Current race CP array
new LCurrentCheckpoint;                             //Current race array pointer
new CurrentCheckpoint[MAX_PLAYERS];                 //Current race array pointer array :V
new CurrentLap[MAX_PLAYERS];                        //Current lap array
//new Participants;                                   //Amount of participants
new ORacelaps, ORacemode;   //Saves the laps/mode from file in case they aren't changed
new Racelaps, Racemode;		//If mode/laps has been changed, the new scores won't be saved.
new TopRacers[6][MAX_PLAYER_NAME]; // Stores 5 top scores, 6th isn't
new TopRacerTimes[6];              // saved to file, used to simplify
new TopLappers[6][MAX_PLAYER_NAME];// for() loops on CheckBestLap and
new TopLapTimes[6];                // CheckBestRace.
new Float:CPsize;                        // Checkpoint size for the race
new Airrace;                       // Is the race airrace?
new Float:RLenght; // race lenght
// Building-related variables
new BCurrentCheckpoints[MAX_BUILDERS];               //Buildrace array pointers
new BSelectedCheckpoint[MAX_BUILDERS];               //Selected checkpoint during building
new RaceBuilders[MAX_PLAYERS];                       //Who is building a race?
new BuilderSlots[MAX_BUILDERS];                      //Stores the racebuilder pids
new Float:BRaceCheckpoints[MAX_BUILDERS][MAX_RACECHECKPOINTS][3]; //Buildrace CP array
new Bracemode[MAX_BUILDERS];
new Blaps[MAX_BUILDERS];
new Float:BCPsize[MAX_BUILDERS];
new BAirrace[MAX_BUILDERS];
new Float:startX, Float:startY, Float:startZ;
new Float:startMod[11][1] = {
{-5.0},
{-4.0},
{-3.0},
{-2.0},
{-1.0},
{0.1},
{1.0},
{2.0},
{3.0},
{4.0},
{5.0}
};
#endif //races
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ------------------     END RACE STUFF     -----------------------------------
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//------------------------------------------------------------------------------

#if !defined USE_XADMIN
forward strtok(const string[],&index);
#endif

main()
{
	print("\n----------------------------------");
	print("  Everystuff (c)2012 kaisersouse\n");
	print("  Contains code snips from spideytram and xadmin\n");
	print("  Contains full integration of Yagu's race FS\n");
	print(" -- Added 09/14/2012- hidespamtimer\n");
	print("----------------------------------\n");
}
//------------------------------------------------------------------------------

public OnGameModeInit()
{
	AllowInteriorWeapons(1);
#if defined IRC_ECHO
// Connect the first bot
	botIDs[0] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_1_NICKNAME, BOT_1_REALNAME, BOT_1_USERNAME);
	// Set the connect delay for the first bot to 20 seconds
	IRC_SetIntData(botIDs[0], E_IRC_CONNECT_DELAY, 20);
	// Connect the second bot
	botIDs[1] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_2_NICKNAME, BOT_2_REALNAME, BOT_2_USERNAME);
	// Set the connect delay for the second bot to 30 seconds
	IRC_SetIntData(botIDs[1], E_IRC_CONNECT_DELAY, 30);
	// Create a group (the bots will be added to it upon connect)
	groupID = IRC_CreateGroup();
#endif //irc_echo
	
	#if defined USE_XADMIN
	print("Checking / creating XAdmin configuration...");
	//Check if all configuration files are present.
	if(!dini_Exists("/xadmin/Configuration/Configuration.ini")) {
	    dini_Create("/xadmin/Configuration/Configuration.ini");
	    dini_Set("/xadmin/Configuration/Configuration.ini","ServerMessage","None");
	}
	print("Creating XAdmin user file variables configuration...");
	// Create the variables to be stored in each user's file.
	CreateLevelConfig(
		"IP","Registered","Level","Kills","Deaths","Password","Wired",
		"WiredWarnings","Jailed","Money","RaceWins","HiddenPackages",
		"Kicks","Skin","PCarModel","PCarPaintJ","PCarColor","Group",
		"Pox","Bounty","House1","House2","House3","Pro","MinsPlayed","Skin"

	);
	// Create Level Config in pattern 'command name, level, command name, level (case is not sensitive):
	print("Creating XAdmin command level configuration...");
	CreateCommandConfig(
		// Time Commands
		"morning",1,"afternoon",1,"evening",1,"midnight",1,"settime",1,
		// Miscellaneous Commands
		"goto",5,"hq",5,"gethere",5,"announce",3,"say",5,"flip",10,"slap",5,"wire",5,"unwire",5,"kick",5,
		"ban",10,"akill",10,"eject",10,"freeze",10,"unfreeze",10,"outside",10,"healall",10,"uconfig",10,
		"setsm",10,"givehealth",10,"sethealth",10,"skinall",10,"giveallweapon",10,"resetallweapons",10,
		"setcash",10,"givecash",10,"remcash",10,"resetcash",10,"setallcash",10,"giveallcash",10,"remallcash",
		10,"resetallcash",10,"ejectall",10,"freezeall",10,"unfreezeall",10,"giveweapon",10,"god",10,
		"resetscores",10,"setlevel",10,"setskin",10,"givearmour",10,"setarmour",10,"armourall",10,
		"setammo",10,"setscore",10,"ip",5,"ping",5,"explode",10,"setname",10,"setalltime",10,
		"force",10,"setallworld",10,"setworld",10,"setgravity",10,"setwanted",5,"setallwanted",5
	);
	CreateCommandConfigEx(
		"xlock",1,"xunlock",1,"carcolor",10,"gmx",10,"carhealth",10,"setping",10,
		"giveme",10,"givecar",10,"xspec",5,"xjail",5,"xunjail",5,"vr",0,"weather",10
	);
	print("Creating XAdmin main configuration files...");
	UpdateConfigurationVariables();
	print("XAdmin Initialization Complete.");
	#endif //use_xadmin

	SetGameModeText("Freeroam DM Stunt Any-Car");
	ShowNameTags(1);
	ShowPlayerMarkers(1);
	SetWorldTime(17);
	SetWeather(10);
	UsePlayerPedAnims();
    for(new i = -1; i < 300; i++) if(IsSkinValid(i)) AddPlayerClass(i,-2667.4729,1594.8196,217.2739,56.19,0,0,0,0,12,1);
    tenmintimer = SetTimer("TenMinutes",600000,1);
    fivesectimer = SetTimer("FiveSeconds",5000,1);
    onesectimer = SetTimer("OneSecond",1000,1);
    fivemintimer = SetTimer("FiveMinutes",300000,1);
    onemintimer = SetTimer("OneMinute",60000,1);

#if defined TEXTDRAWS
//textdraws
	DMSPAM = TextDrawCreate(235.000000, 415.000000, " ");

	Help = TextDrawCreate(4.000000, 431.500000, "~r~/MENU /C /T /DM /GOD /V ~y~/CAR /TUNE /SNOS /JUMP ~r~/RADIO~y~ /HIDEUI /KEY2 /KEYY /KEYN ~w~/DAY /NIGHT /RAIN /SUN");
	TextDrawSetOutline(Help, 1);
	TextDrawFont(Help, 1);
	TextDrawSetProportional(Help, 2);
	TextDrawLetterSize(Help, 0.2, 0.7);
	
	BottomBanner = TextDrawCreate(0.000000, 441.000000, ".  ~n~. ~n~. ~n~. ~n~.~n~.");
	TextDrawUseBox(BottomBanner , 1);
	TextDrawSetOutline(BottomBanner, 1);
	TextDrawFont(BottomBanner, 3);
	TextDrawSetProportional(BottomBanner, 2);
	TextDrawLetterSize(BottomBanner, 0.6, 1.6);
	TextDrawBackgroundColor(BottomBanner ,0x000000FF);
	TextDrawBoxColor(BottomBanner ,0x00000066);
	TextDrawColor(BottomBanner ,0x000000FF);
	
	Leave = TextDrawCreate(550.000000, 423.000000, "~r~/leave");
	TextDrawSetOutline(Leave, 1);
	TextDrawFont(Leave, 3);
	TextDrawSetProportional(Leave, 2);
	TextDrawLetterSize(Leave, 0.4, 0.9);
	
	God = TextDrawCreate(4.000000, 423.000000, "~y~/GOD:~g~ON"); // god mode original  x = 550
	TextDrawSetOutline(God, 1);
	TextDrawFont(God, 1);
	TextDrawSetProportional(God, 2);
	TextDrawLetterSize(God, 0.25, 0.75);
	
	NoGod = TextDrawCreate(4.000000, 423.000000, "~y~/GOD:~r~OFF");
	TextDrawSetOutline(NoGod, 1);
	TextDrawFont(NoGod, 1);
	TextDrawSetProportional(NoGod, 2);
	TextDrawLetterSize(NoGod, 0.25, 0.75);
	
	SnosOn = TextDrawCreate(53.000000, 423.000000, "~y~/SNOS:~g~ON");
	TextDrawSetOutline(SnosOn, 1);
	TextDrawFont(SnosOn, 1);
	TextDrawSetProportional(SnosOn, 2);
	TextDrawLetterSize(SnosOn, 0.25, 0.75);
	
	SnosOff = TextDrawCreate(53.000000, 423.000000, "~y~/SNOS:~r~OFF");
	TextDrawSetOutline(SnosOff, 1);
	TextDrawFont(SnosOff, 1);
	TextDrawSetProportional(SnosOff, 2);
	TextDrawLetterSize(SnosOff, 0.25, 0.75);
	
	JumpOn = TextDrawCreate(110.000000, 423.000000, "~y~/JUMP:~g~ON");
	TextDrawSetOutline(JumpOn, 1);
	TextDrawFont(JumpOn, 1);
	TextDrawSetProportional(JumpOn, 2);
	TextDrawLetterSize(JumpOn, 0.25, 0.75);

	JumpOff = TextDrawCreate(110.000000, 423.000000, "~y~/JUMP:~r~OFF");
	TextDrawSetOutline(JumpOff, 1);
	TextDrawFont(JumpOff, 1);
	TextDrawSetProportional(JumpOff, 2);
	TextDrawLetterSize(JumpOff, 0.25, 0.75);
	
	RadioOn = TextDrawCreate(165.000000, 423.000000, "~y~/RADIO:~g~ON");
	TextDrawSetOutline(RadioOn, 1);
	TextDrawFont(RadioOn, 1);
	TextDrawSetProportional(RadioOn, 2);
	TextDrawLetterSize(RadioOn, 0.25, 0.75);

	RadioOff = TextDrawCreate(165.000000, 423.000000, "~y~/RADIO:~r~OFF");
	TextDrawSetOutline(RadioOff, 1);
	TextDrawFont(RadioOff, 1);
	TextDrawSetProportional(RadioOff, 2);
	TextDrawLetterSize(RadioOff, 0.25, 0.75);
	


	Veh = TextDrawCreate(469.000000, 432.000000, "~y~Press ~r~2~y~ for fix+NOS"); //was 150 422
	TextDrawSetOutline(Veh, 1);
	TextDrawFont(Veh, 3);
	TextDrawSetProportional(Veh, 2);
	TextDrawLetterSize(Veh, 0.3, 0.8);
	
	VehAutoFlip = TextDrawCreate(469.000000, 432.000000, "~y~Press ~r~2~y~ for fix+NOS+Flip"); //was 150 422
	TextDrawSetOutline(VehAutoFlip, 1);
	TextDrawFont(VehAutoFlip, 3);
	TextDrawSetProportional(VehAutoFlip, 2);
	TextDrawLetterSize(VehAutoFlip, 0.3, 0.8);
	
	VehAutoStop = TextDrawCreate(469.000000, 432.000000, "~y~Press ~r~2~y~ for fix+NOS+Stop"); //was 150 422
	TextDrawSetOutline(VehAutoStop, 1);
	TextDrawFont(VehAutoStop, 3);
	TextDrawSetProportional(VehAutoStop, 2);
	TextDrawLetterSize(VehAutoStop, 0.3, 0.8);
	
	VehPutRamp = TextDrawCreate(469.000000, 432.000000, "~y~Press ~r~2~y~ for fix+NOS+Ramp"); //was 150 422
	TextDrawSetOutline(VehPutRamp, 1);
	TextDrawFont(VehPutRamp, 3);
	TextDrawSetProportional(VehPutRamp, 2);
	TextDrawLetterSize(VehPutRamp, 0.3, 0.8);
	
	VehPutSkulls = TextDrawCreate(469.000000, 432.000000, "~y~Press ~r~2~y~ for fix+NOS+Skulls"); //was 150 422
	TextDrawSetOutline(VehPutSkulls, 1);
	TextDrawFont(VehPutSkulls, 3);
	TextDrawSetProportional(VehPutSkulls, 2);
	TextDrawLetterSize(VehPutSkulls, 0.3, 0.8);
	
	#if defined SAMP03X
	ServerIP = TextDrawCreate(486.000000, 1.500000, "~y~everystuff.net:7777~n~ ~y~PRESS ~r~Y~y~ FOR MENU"); //was 150 422
	#else
	ServerIP = TextDrawCreate(445.000000, 1.500000, "~r~03x = 69.60.109.157:7777"); //was 150 422
	#endif
	TextDrawSetOutline(ServerIP, 1);
	TextDrawFont(ServerIP, 1);
	TextDrawSetProportional(ServerIP, 2);
	TextDrawLetterSize(ServerIP, 0.4, 1.0);
	
	Surfing = TextDrawCreate(496.000000, 12.000000, "~g~Surfing!");
	TextDrawSetOutline(Surfing, 1);
	TextDrawFont(Surfing, 1);
	TextDrawSetProportional(Surfing, 2);
	TextDrawLetterSize(Surfing, 0.3, 0.8);
	



#endif //textdraws

#if defined RACES
	rotationtimer = SetTimer("RaceRotation",300000,1); //5 minutes
	RaceActive=0;
	RaceStart=0;
	Ranking=1;
	LCurrentCheckpoint=0;
	for(new i;i<MAX_BUILDERS;i++)
	{
	    BuilderSlots[i]=MAX_PLAYERS+1;
	}
#if defined RACE_MENU
	CreateRaceMenus();
#endif //race_menu
#endif //races

	AddStaticPickup(371, 2, 1574.8966,-1249.2684,277.8787); // basejump1 parachute
	AddStaticPickup(371, 2, 1539.4971,-1371.4875,328.3436); // basejump2 parachute
	AddStaticPickup(371, 2, -225.1428,1393.6865,172.4141); // basejump3 parachute
	AddStaticPickup(371, 2, -2872.1931,2606.3821,271.5319); // basejump4 parachute
	AddStaticPickup(371, 2, -341.6077,1601.4565,164.4840); // basejump5 parachute
	AddStaticPickup(371, 2, 1951.4064,-2436.0005,97.7329); // skydive parachute

	//car launcher pickups
	cannon1 = CreatePickup(1313,14,-2316.4827,-1588.1652,483.3309); //chiliad
	cannon2 = CreatePickup(1313,14,1969.9441,-2229.7705,18.0349); //airport
	cannon3 = CreatePickup(1313,14,-665.3456,2326.0076,138.3917); //ramp
	cannon4 = CreatePickup(1313,14,-539.6153,2593.6086,53.2154); //cannon
	cannon5 = CreatePickup(1313,14,1991.5588,-2365.2231,13.5469); //ls airport bounce
	cannon6 = CreatePickup(1313,14,1469.8853,1166.1282,15.2854); // lv airport
	cannon7 = CreatePickup(1313,14,1668.1339,1605.1578,10.8203); // lv airport bounce

	// gang pickups
		//LS GANGWAR RANDOM PICKUPS
	CreatePickup(356,2, 2257.0659,-1643.5973,20.4958); //1min respawn //
	CreatePickup(352,2, 1984.1392,-1616.3076,15.9688); //1min respawn //
	CreatePickup(358,2, 2081.6182,-1102.7096,24.9570); //1min respawn //
	CreatePickup(349,2, 1928.6709,-1035.1814,24.0279); //1min respawn //
	CreatePickup(348,2, 1835.2075,-1235.8911,15.9689); //1min respawn //
	CreatePickup(352,2, 1791.5042,-1351.6281,16.3966); //1min respawn //
	CreatePickup(355,2, 1787.1077,-1353.8605,16.4747); //1min respawn //
	CreatePickup(349,2, 1851.0425,-1588.2974,31.0500); //1min respawn //
	CreatePickup(348,2, 1794.2280,-1635.4269,14.4970); //1min respawn //
	CreatePickup(358,2, 1762.4552,-1488.0139,13.3982); //1min respawn //
	CreatePickup(355,2, 2081.6182,-1102.7096,24.9570); //1min respawn //

	// gang vehicles
	new i = 0;
	gcar[i] = CreateVehicle(536,2506.1274,-1678.7738,13.2407,312.9259,12,1,300); // family car
	gcar[i++] = CreateVehicle(536,2498.6519,-1651.5813,13.2504,349.9027,12,1,300); // family car
	gcar[i++] = CreateVehicle(534,2480.8149,-1654.1256,13.1513,88.2739,42,42,300); // family car
	gcar[i++] = CreateVehicle(566,2473.0681,-1689.2867,13.2884,174.1131,30,8,300); // family car
	gcar[i++] = CreateVehicle(566,2505.3223,-1686.3381,13.3315,185.1332,30,8,300); // family car
	gcar[i++] = CreateVehicle(566,2390.1411,-1654.4811,13.2451,90.5384,30,8,300); // family car
	gcar[i++] = CreateVehicle(549,2374.3154,-1645.2662,13.2273,319.6436,72,39,300); // family car
	gcar[i++] = CreateVehicle(491,1997.4875,-1679.3516,13.2382,359.0081,71,72,300); // balla car
	gcar[i++] = CreateVehicle(418,2012.4764,-1698.6445,13.6606,91.1968,117,227,300); // balla car
	gcar[i++] = CreateVehicle(439,1982.6771,-1711.4794,15.8606,273.4986,8,17,300); // balla car
	gcar[i++] = CreateVehicle(439,2012.0612,-1740.1113,13.4447,249.2378,8,17,300); // balla car
	gcar[i++] = CreateVehicle(533,1834.7632,-1871.3073,13.0979,0.4091,74,1,300); // azteca car
	gcar[i++] = CreateVehicle(533,1836.9292,-1853.4954,13.0989,177.3144,75,1,300); // azteca car
	gcar[i++] = CreateVehicle(482,1816.2539,-1870.7361,13.6098,181.2551,48,48,300); // azteca car
	gcar[i++] = CreateVehicle(422,1803.8577,-1837.0610,13.4570,267.7320,97,25,300); // azteca car
	gcar[i++] = CreateVehicle(499,2733.3352,-1355.4827,43.9495,54.1016,109,32,300); // vagos car
	gcar[i++] = CreateVehicle(422,2717.9153,-1365.4390,42.1115,178.3071,101,25,300); // vagos car
	gcar[i++] = CreateVehicle(445,2742.5112,-1334.7477,47.5358,1.4025,35,35,300); // vagos car
	gcar[i++] = CreateVehicle(518,2717.4268,-1400.0967,35.5287,175.4460,9,39,300); // vagos car

	//VAGOS
    gcar[i++] = CreateVehicle(535,2135.5000,-1128.5566,25.3067,77.6000,6,0, 300); // vagos slamvan
    gcar[i++] = CreateVehicle(496,2147.6233,-1137.7611,25.2498,268.0142,6,1, 300); // vagos blista
    gcar[i++] = CreateVehicle(567,2161.2749,-1165.3291,23.5429,38.0461,61,1, 300); // vagos savanah
    gcar[i++] = CreateVehicle(522,2118.1223,-1123.9818,24.8943,279.8226,61,8, 300); // vagos nrg 1
	//BALLAS
    gcar[i++] = CreateVehicle(522,1724.5763,-1611.7416,13.1183,2.8229,22,8, 300); // ballas nrg 1
    gcar[i++] = CreateVehicle(522,1722.6476,-1612.0621,13.1185,355.9311,22,8, 300); // balls nrg 2
    gcar[i++] = CreateVehicle(535,1707.7231,-1579.2277,13.2521,175.3064,85,0, 300); // ballas slamvan
    gcar[i++] = CreateVehicle(567,1719.9849,-1580.1190,13.2747,179.5323,85,1, 300); // balla lowrider
    gcar[i++] = CreateVehicle(496,1674.1862,-1599.7043,13.9265,270.7300,22,1, 300); // balla blistac
	for(i = 0; i < sizeof(gcar); i++)
	{
	    SetVehicleVirtualWorld(gcar[i],WORLD_GANG);
	}
	zoneFamily = GangZoneCreate(2303.672, -1745.026, 2611.702, -1196.29);
	zoneBalla = GangZoneCreate(1816.909, -1756.869, 2113.53, -1460.788);
	zoneVagos = GangZoneCreate(2634.519, -1843.719, 2942.549, -1026.537);
	zoneAzteca = GangZoneCreate(1699.021, -2163.486, 2159.164, -1820.033);
	safezoneLS = GangZoneCreate(1319.6, -2732.623, 2242.152, -2125.373);
	safezoneChiliad = GangZoneCreate(-2534.099, -1821.749, -2078.662, -1424.701);
	safezoneLV = GangZoneCreate(1261.211, 1144.432, 1775.037, 1868.46);
	safezoneAA = GangZoneCreate(-163.4902, 2347.253, 490.4708, 2650.878);

	lsairspace = GangZoneCreate(0, -4133.968, 4425.915, 0.0);
	lvairspace = GangZoneCreate(0, 0, 4098.934, 4344.169);
//	safezoneSF = GangZoneCreate(-1738.026, -707.7765, -1448.325, 85.16138);
	
	return 1;
}
//-----------------------------------------------------------
Float:GetXYInFrontOfPlayer(playerid, &Float:xx, &Float:yy, Float:distance) // Created by Y_Less
{
	new Float:a;
	GetPlayerPos(playerid, xx, yy, a);
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) GetVehicleZAngle(pvehicleid[playerid], a);
	else GetPlayerFacingAngle(playerid, a);
	xx += (distance * floatsin(-a, degrees));
	yy += (distance * floatcos(-a, degrees));
	return a;
}

stock Float:GetXYInFrontOfVehicle(vehicleid, &Float:xx, &Float:yy, Float:distance) 	// Created by Y_Less
{
	new Float:a;
	GetVehiclePos(vehicleid, xx, yy, a);
    GetVehicleZAngle(vehicleid, a);
	xx += (distance * floatsin(-a, degrees));
	yy += (distance * floatcos(-a, degrees));
	return a;
}
//------------------------------------------------------------------------------
public OnGameModeExit()
{
#if defined FLYMODE
	for(new x; x<MAX_PLAYERS; x++)
	{
		if(noclipdata[x][cameramode] == CAMERA_MODE_FLY) CancelFlyMode(x);
	}

#endif

#if defined IRC_ECHO
	// Disconnect the first bot
	IRC_Quit(botIDs[0], "Filterscript exiting");
	// Disconnect the second bot
	IRC_Quit(botIDs[1], "Filterscript exiting");
	// Destroy the group
	IRC_DestroyGroup(groupID);
#endif

	foreach(Player,i)
	{
		if(Variables[i][LoggedIn])
	    {
	        new money = GetPlayerMoney(i);
		    SetUserInt(i,"Money",money);
		    SetUserInt(i,"Kills",kills[i]);
		    SetUserInt(i,"RaceWins",race1st[i]);
		    SetUserInt(i,"LoggedIn",0);
		    SetUserInt(i,"MinsPlayed",minutesplayed[i]);
	    }
	}
	KillTimer(rotationtimer);
	KillTimer(tenmintimer);
	KillTimer(fivesectimer);
	KillTimer(fivemintimer);
	KillTimer(onesectimer);
	KillTimer(onemintimer);
	DestroyMenu(MAdmin);
	DestroyMenu(MPMode);
	DestroyMenu(MPrize);
	DestroyMenu(MDyna);
	DestroyMenu(MBuild);
	DestroyMenu(MLaps);
	DestroyMenu(MRace);
	DestroyMenu(MRacemode);
	DestroyMenu(MFee);
	DestroyMenu(MCPsize);
	DestroyMenu(MDelay);
	return 1;
}

stock stringContainsIP(const szStr[])
{
    new
        iDots,
        i
    ;
    while(szStr[i] != EOS)
    {
        if('0' <= szStr[i] <= '9')
        {
            do
            {
                if(szStr[i] == '.')
                    iDots++;

                i++;
            }
            while(('0' <= szStr[i] <= '9') || szStr[i] == '.' || szStr[i] == ':');
        }
        if(iDots > 2)
            return 1;
        else
            iDots = 0;

        i++;
    }
    return 0;
}

public OnPlayerText(playerid,text[])
{
    if(!strlen(text)) return 0;
    
#if defined USE_XADMIN
	if(text[0] == '#' && IsPlayerXAdmin(playerid)) {
	    new name[24]; GetPlayerName(playerid,name,24); format(string128,sizeof(string128),"Admin %s: %s",name,text[1]); SendMessageToAdmins(string128);
	    return 0;
	}
	if(Variables[playerid][Wired]) {
	    Variables[playerid][WiredWarnings]--;
	    new Name[24];
	    if(Variables[playerid][WiredWarnings]) {
	        format(string128,sizeof(string128),"You have been wired thus preventing you from talking or PMing. [Warnings: %d/%d]",Variables[playerid][WiredWarnings],Config[WiredWarnings]);
			SendClientMessage(playerid,white,string128); return 0;
		}
		else {
		    GetPlayerName(playerid,Name,24); format(string128,sizeof(string128),"%s has been kicked from the server. [REASON: Wired]",Name);
		    SendClientMessageToAll(yellow,string128); SetUserInt(playerid,"Wired",0);
		    Kick(playerid); return 0;
		}
	}
#endif

	if(afk[playerid])
	{
	    SetPlayerPosEx(playerid,storedx[playerid],storedy[playerid],storedz[playerid],storeda[playerid],storedint[playerid]);
	    TogglePlayerControllable(playerid,true);
		format(string128,sizeof(string128),"%s has returned to their keyboard!",pname[playerid]);
	    SendClientMessageToAll(COLOR_PINK,string128);
	    afk[playerid] = 0;
	}
	if(!strcmp(text, lastchat[playerid], true, 128)) {
		SendClientMessage(playerid,COLOR_SYSTEM,"Error: Duplicate message not allowed");
		return 0;
	}
	if(containsip(text) && !IsPlayerAdmin(playerid))
	{
	    new pip[16];
	    GetPlayerIp(playerid, pip, sizeof(pip));
	    format(string128,sizeof(string128), "[IP spam] [%i]%s (IP:%s) | SPAM: %s",playerid,pname[playerid],pip,text);
	    printf(string128);
#if defined IRC_ECHO
//		new ircMsg[256];
//		format(ircMsg, sizeof(ircMsg), "02[%d] 07%s: %s", playerid, name, text);
		IRC_GroupSay(groupID, IRC_CHANNEL, string128);
#endif //irc_echo
        return 0;
	}
	for(new i = 0; i < 128; i++) //check for key words and bad words
	{
	
        if(strfind(text[i], "login" , true) == 0)
        {
             SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Oops! You don't want to give out your password! Try logging in again. /login <password>");
			 return 0;
		}
		else if(strfind(text[i], ".login" , true) == 0)
        {
			SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Oops! You don't want to give out your password! Try logging in again. /login <password>");
			return 0;
		}
		else if(strfind(text[i], "t/login" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Oops! You don't want to give out your password! Try logging in again. /login <password>");
			return 0;
		}
		else if(strfind(text[i], "/q" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you want to quit the game, press ESC");
            return 0;
		}
		else if(strfind(text[i], "uif" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you want to quit the game, press ESC");
            return 0;
		}
		else if(strfind(text[i], "UIF" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you want to quit the game, press ESC");
            return 0;
		}
		else if(strfind(text[i], "U I F" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you want to quit the game, press ESC");
            return 0;
		}
		else if(strfind(text[i], "UIF" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you want to quit the game, press ESC");
            return 0;
		}
		else if(strfind(text[i], "rcon" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FFFFFF}[SYSTEM]:{C0C0C0} I'm sorry, I couldn't hear you.");
            return 0;
		}
		else if(strfind(text[i], "niex" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FFFFFF}[SYSTEM]:{C0C0C0} I'm sorry, I couldn't hear you.");
            return 0;
		}
		else if(strfind(text[i], "s0beit" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FFFFFF}[SYSTEM]:{C0C0C0} I'm sorry, I couldn't hear you.");
            return 0;
		}
		else if(strfind(text[i], "sobeit" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FFFFFF}[SYSTEM]:{C0C0C0} I'm sorry, I couldn't hear you.");
            return 0;
		}
		else if(strfind(text[i], "so be it" , true) == 0)
        {
            SendClientMessage(playerid,COLOR_PINK,"{FFFFFF}[SYSTEM]:{C0C0C0} I'm sorry, I couldn't hear you.");
            return 0;
		}
    }
    new textmsg[128];
//   	FixConsole(text);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(gblnIsMuted[playerid][i] == true) continue; //player i has muted the sender --> exit iteration
		else if(gblnIsMuted[playerid][i] == false)
		{
		    if(!Variables[playerid][Pro])
		    {
				format(textmsg,sizeof(textmsg),"{FFFFFF}%i:{%06x}%s{FFFFFF}: %s", playerid,GetPlayerColor(playerid) >>> 8,pname[playerid],text);
			}
			else
			{
                format(textmsg,sizeof(textmsg),"{FFFFFF}%i:{FFFF00}[PRO] {%06x}%s{FFFFFF}: %s", playerid,GetPlayerColor(playerid) >>> 8,pname[playerid],text);
			}
			SendClientMessage(i,COLOR_SYSTEM,textmsg);
		}
	}
#if defined IRC_ECHO
	new ircMsg[256];
	GetPlayerName(playerid, pname[playerid], sizeof(pname));
	format(ircMsg, sizeof(ircMsg), "02[%d] 07%s: %s", playerid, pname[playerid], text);
	IRC_GroupSay(groupID, IRC_CHANNEL, ircMsg);
#endif //irc_echo
	strmid(lastchat[playerid], text, 0, 127,128);
	return 0;
}

//-----------------------------------------------------------------------
//COMMANDS
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(Variables[playerid][Jailed] || frozen[playerid] ) return SendClientMessage(playerid,red,"You can NOT use any commands whilst you are jailed.");
	dcmd(afk,3,cmdtext);
	#if defined NEON
	dcmd(neon,4,cmdtext);
	#endif

	dcmd(insultshouse,12,cmdtext);
	dcmd(prohouse,8,cmdtext);
	dcmd(pm,2,cmdtext);
	dcmd(interiors,9,cmdtext);
	dcmd(airports,8,cmdtext);
	dcmd(stadiums,8,cmdtext);
	dcmd(cities,6,cmdtext);
	dcmd(carson,6,cmdtext);
	dcmd(blueberry,9,cmdtext);
	dcmd(elquebrados,11,cmdtext);
	dcmd(angelpine,9,cmdtext);
	dcmd(palomino,8,cmdtext);
	dcmd(montgomery,10,cmdtext);
	dcmd(dilimore,8,cmdtext);
	dcmd(sfdt,4,cmdtext);
	dcmd(lvdt,4,cmdtext);
	dcmd(pigpen,6,cmdtext);
	dcmd(cracklab,7,cmdtext);
	dcmd(donut,5,cmdtext);
	dcmd(range,5,cmdtext);
	dcmd(jizzys,6,cmdtext);
	dcmd(jefferson,9,cmdtext);
	dcmd(fiabag,6,cmdtext);
	dcmd(key2,4,cmdtext);
	dcmd(keyy,4,cmdtext);
	dcmd(keyn,4,cmdtext);
	dcmd(cow,3,cmdtext);
 	dcmd(chicken,7,cmdtext);
	dcmd(putmine,7,cmdtext);
	dcmd(putramp,7,cmdtext);
	dcmd(putskulls,9,cmdtext);
	dcmd(gun,3,cmdtext);
	dcmd(gunship,7,cmdtext);
	dcmd(magnet,6,cmdtext);
	dcmd(stats,5,cmdtext);
	dcmd(fireme,6,cmdtext);
	dcmd(saveme,6,cmdtext);
	dcmd(savecar,7,cmdtext);
	dcmd(gunship2,8,cmdtext);
	dcmd(horn,4,cmdtext);
	dcmd(helmet,6,cmdtext);
	dcmd(snos,4,cmdtext);
	dcmd(dirtarena,9,cmdtext);
	dcmd(8track,6,cmdtext);
	dcmd(kickstart,9,cmdtext);
	dcmd(bloodbowl,9,cmdtext);
	dcmd(lc,2,cmdtext);
	dcmd(fia,3,cmdtext);
	dcmd(godcar,6,cmdtext);
	dcmd(cloak,5,cmdtext);
	dcmd(god,3,cmdtext);
	dcmd(androm,6,cmdtext);
	dcmd(shamal,6,cmdtext);
	dcmd(otb,3,cmdtext);
	dcmd(sex,3,cmdtext);
	dcmd(atrium,6,cmdtext);
	dcmd(trucker,7,cmdtext);
	dcmd(trailer,7,cmdtext);
	dcmd(c,1,cmdtext);
	dcmd(t,1,cmdtext);
	dcmd(v,1,cmdtext);
	dcmd(help,4,cmdtext);
	dcmd(tut1,4,cmdtext);
	dcmd(tut2,4,cmdtext);
//	dcmd(tut3,4,cmdtext);
//	dcmd(tut4,4,cmdtext);
//	dcmd(tut5,4,cmdtext);
//	dcmd(tut6,4,cmdtext);
//	dcmd(tut7,4,cmdtext);
	dcmd(caroptions,10,cmdtext);
	dcmd(menu,4,cmdtext);
	dcmd(rules,5,cmdtext);
	dcmd(debug,5,cmdtext);
	dcmd(s,1,cmdtext);
	dcmd(s2,2,cmdtext);
	dcmd(quiet,5,cmdtext);
	dcmd(hideui,6,cmdtext);
	dcmd(tele,4,cmdtext);
	dcmd(teles,5,cmdtext);
	dcmd(cc,2,cmdtext);
	dcmd(fight,5,cmdtext);
	dcmd(radio,5,cmdtext);
	dcmd(toys,4,cmdtext);
	dcmd(cmd,3,cmdtext);
	dcmd(cmds,4,cmdtext);
	dcmd(command,7,cmdtext);
	dcmd(commands,8,cmdtext);
	dcmd(dcar,4,cmdtext);
	dcmd(reserve,7,cmdtext);
	dcmd(fix,3,cmdtext);
	dcmd(vr,2,cmdtext);
	dcmd(flip,4,cmdtext);
	dcmd(stop,4,cmdtext);
	dcmd(leave,5,cmdtext);
	dcmd(xmas,4,cmdtext);
	dcmd(sf,2,cmdtext);
	dcmd(sfa,3,cmdtext);
	dcmd(lsa,3,cmdtext);
	dcmd(lva,3,cmdtext);
	dcmd(lv,2,cmdtext);
	dcmd(random,6,cmdtext);
	dcmd(ls,2,cmdtext);
	dcmd(lvstrip,7,cmdtext);
	dcmd(sfd,3,cmdtext);
	dcmd(center,6,cmdtext);
	dcmd(ammu,4,cmdtext);
	dcmd(desert,6,cmdtext);
	dcmd(drift,5,cmdtext);
	dcmd(cannon,6,cmdtext);
	dcmd(derby,5,cmdtext);
	dcmd(sdance,6,cmdtext);
	dcmd(hsmoke,6,cmdtext);
	dcmd(porn,4,cmdtext);
	dcmd(kill,4,cmdtext);
	dcmd(pc,2,cmdtext);
	dcmd(magic,5,cmdtext);
	dcmd(jihad,5,cmdtext);
	dcmd(wrc,3,cmdtext);
	dcmd(nos,3,cmdtext);
	dcmd(jetpack,7,cmdtext);
	dcmd(flymode,7,cmdtext);
	dcmd(tpallow,7,cmdtext);
	dcmd(tpdeny,6,cmdtext);
	dcmd(tp,2,cmdtext);
	dcmd(myworld,7,cmdtext);
	dcmd(carry,5,cmdtext);
	dcmd(beer,4,cmdtext);
	dcmd(wine,4,cmdtext);
	dcmd(blunt,5,cmdtext);
	dcmd(tow,3,cmdtext);
	dcmd(piss,4,cmdtext);
	dcmd(skin,4,cmdtext);
	dcmd(saveskin,8,cmdtext);
	dcmd(credits,7,cmdtext);
	dcmd(count,5,cmdtext);
	dcmd(ignore,6,cmdtext);
	dcmd(unignore,8,cmdtext);
	dcmd(savepos,7,cmdtext);
	dcmd(sp,2,cmdtext);
	dcmd(lp,2,cmdtext);
	dcmd(back,4,cmdtext);
	dcmd(drunk,5,cmdtext);
	dcmd(launch,6,cmdtext);
	dcmd(e,1,cmdtext);
	dcmd(space,5,cmdtext);
	dcmd(jump,4,cmdtext);
	dcmd(wheels,6,cmdtext);
	dcmd(skydive,7,cmdtext);
	dcmd(warehouse,9,cmdtext);
	dcmd(rctrack,7,cmdtext);
	dcmd(bikepark,8,cmdtext);
	dcmd(beach,5,cmdtext);
	dcmd(basejump1,9,cmdtext);
	dcmd(basejump2,9,cmdtext);
	dcmd(basejump3,9,cmdtext);
	dcmd(basejump4,9,cmdtext);
	dcmd(basejump5,9,cmdtext);
	dcmd(chiliad,7,cmdtext);
	dcmd(chilliad,8,cmdtext);
	dcmd(ch,2,cmdtext);
	dcmd(airport,7,cmdtext);
	dcmd(rallyup,7,cmdtext);
	dcmd(boneyard,8,cmdtext);
	dcmd(aa,2,cmdtext);
	dcmd(stuntcity,9,cmdtext);
	dcmd(dirtpit,7,cmdtext);
	dcmd(underwater,10,cmdtext);
	dcmd(pyramid,7,cmdtext);
	dcmd(area69,6,cmdtext);
	dcmd(silodm,6,cmdtext);
	dcmd(boardwalk,9,cmdtext);
	dcmd(funpark,7,cmdtext);
	dcmd(locos,5,cmdtext);
	dcmd(waa,3,cmdtext);
	dcmd(canal,5,cmdtext);
	dcmd(ramp,4,cmdtext);
	dcmd(loopramp,8,cmdtext);
	dcmd(basketcar,9,cmdtext);
	dcmd(halfpipe,8,cmdtext);
	dcmd(roller,6,cmdtext);
	dcmd(skyway,6,cmdtext);
	dcmd(tune,4,cmdtext);
	dcmd(tuner,5,cmdtext);
	dcmd(color,5,cmdtext);
	dcmd(colortest,9,cmdtext);
	dcmd(pcolor,6,cmdtext);
	dcmd(racolor,7,cmdtext);
	dcmd(spawn,5,cmdtext);
	dcmd(setspawn,8,cmdtext);
	dcmd(paintjob,8,cmdtext);
	dcmd(plate,5,cmdtext);
	dcmd(paintj,6,cmdtext);
	dcmd(findcar,7,cmdtext);
	dcmd(getcar,6,cmdtext);
	dcmd(junk,4,cmdtext);
	dcmd(dm,2,cmdtext);
	dcmd(gang,4,cmdtext);
	dcmd(car,3,cmdtext);
//	dcmd(alphacars,9,cmdtext);
	dcmd(nrg,3,cmdtext);
	dcmd(acar,4,cmdtext);
	dcmd(rban,4,cmdtext);
	dcmd(bikes,5,cmdtext);
	dcmd(trucks,6,cmdtext);
	dcmd(leftovers,9,cmdtext);
	dcmd(tuned,5,cmdtext);
	dcmd(fastcars,8,cmdtext);
	dcmd(plane,5,cmdtext);
	dcmd(boat,4,cmdtext);
 	dcmd(casino, 6, cmdtext);
 	dcmd(casino1, 7, cmdtext);
 	dcmd(casino2, 7, cmdtext);
 	dcmd(casino3, 7, cmdtext);
 	dcmd(train,5,cmdtext);
 	dcmd(basejump,8,cmdtext);
 	dcmd(weather,7,cmdtext);
	dcmd(pweather,8,cmdtext);
	dcmd(ptime,5,cmdtext);
	dcmd(time,4,cmdtext);
	dcmd(daynight,8,cmdtext);
	dcmd(day,3,cmdtext);
	dcmd(rain,4,cmdtext);
	dcmd(sun,3,cmdtext);
	dcmd(night,5,cmdtext);
	
#if defined USE_XADMIN
	dcmd(register,8,cmdtext);
	dcmd(login,5,cmdtext);
	dcmd(goto,4,cmdtext);
	dcmd(gethere,7,cmdtext);
	dcmd(logout,6,cmdtext);
	dcmd(lock,4,cmdtext);
	dcmd(unlock,6,cmdtext);
	dcmd(adminhq,7,cmdtext);
	dcmd(announce,8,cmdtext);
	dcmd(say,3,cmdtext);
	dcmd(wire,4,cmdtext);
	dcmd(unwire,6,cmdtext);
	dcmd(kick,4,cmdtext);
	dcmd(ban,3,cmdtext);
	dcmd(report,6,cmdtext);
	dcmd(freeze,6,cmdtext);
	dcmd(unfreeze,8,cmdtext);
	dcmd(ip,2,cmdtext);
	dcmd(spec,4,cmdtext);
	dcmd(xjail,5,cmdtext);
	dcmd(xunjail,7,cmdtext);
	dcmd(admins,6,cmdtext);
	dcmd(xcommands,9,cmdtext);
	dcmd(stealth, 7, cmdtext);
#endif //use_xadmin

#if defined RACES
	dcmd(racehelp,8,cmdtext);	// Racehelp - there's a lot of commands!
	dcmd(buildhelp,9,cmdtext);	// Buildhelp - there's a lot of commands!
	dcmd(buildrace,9,cmdtext);	// Buildrace - Start building a new race (suprising!)
	dcmd(cp,2,cmdtext);		  	// cp - Add a checkpoint
	dcmd(scp,3,cmdtext);		// scp - Select a checkpoint
	dcmd(rcp,3,cmdtext);		// rcp - Replace the current checkpoint with a new one
	dcmd(mcp,3,cmdtext);		// mcp - Move the selected checkpoint
	dcmd(dcp,3,cmdtext);    	// dcp - Delete the selected waypoint
	dcmd(join,4,cmdtext);
	dcmd(clearrace,9,cmdtext);	// clearrace - Clear the current (new) race.
	dcmd(editrace,8,cmdtext);	// editrace - Load an existing race into the builder
	dcmd(saverace,8,cmdtext);	// saverace - Save the current checkpoints to a file
	dcmd(setlaps,7,cmdtext);	// setlaps - Set amount of laps to drive
	dcmd(racemode,8,cmdtext);	// racemode - Set the current racemode
	dcmd(loadrace,8,cmdtext);	// loadrace - Load a race from file and start it
	dcmd(startrace,9,cmdtext);  // starts the loaded race
	dcmd(leaverace,9,cmdtext);		// leave - leave the current race.
	dcmd(endrace,7,cmdtext);	// endrace - Complete the current race, clear tables & variables, stop the timer.
	dcmd(racers,6,cmdtext);
	dcmd(deleterace,10,cmdtext);// deleterace - Remove the race from disk
	dcmd(airrace,7,cmdtext);    // airrace - Changes the checkpoints to air CPs and back
	dcmd(cpsize,6,cmdtext);     // cpsize - changes the checkpoint size
	dcmd(prizemode,9,cmdtext);
	dcmd(setprize,8,cmdtext);
#if defined RACE_MENU
	dcmd(raceadmin,9,cmdtext);
	dcmd(buildmenu,9,cmdtext);
#endif // race_menu
#endif //races
	SendClientMessage(playerid, COLOR_WHITE, "{CC0000}BAD COMMAND!{C0C0C0} Try using /help or /cmd");
	
	if(afk[playerid])
	{
	    SetPlayerPosEx(playerid,storedx[playerid],storedy[playerid],storedz[playerid],storeda[playerid],storedint[playerid]);
	    TogglePlayerControllable(playerid,true);
		format(string128,sizeof(string128),"%s has returned to their keyboard!",pname[playerid]);
	    SendClientMessageToAll(COLOR_PINK,string128);
	    afk[playerid] = 0;
	}
	
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
    if(!success) //If the password was incorrect
    {
        printf("FAILED RCON LOGIN BY IP %s USING PASSWORD %s",ip, password);
        new pip[16];
        for(new i=0; i<MAX_PLAYERS; i++) //Loop through all players
        {
            GetPlayerIp(i, pip, sizeof(pip));
            if(!strcmp(ip, pip, true)) //If a player's IP is the IP that failed the login
            {
                SendClientMessage(i, 0xFFFFFFFF, "Wrong Password. Bye!"); //Send a message
                Kick(i); //They are now banned.
            }
        }
    }
    else
    {
    	printf("SUCCESSFUL RCON LOGIN BY IP %s",ip, password);
    }
    return 1;
}

forward OnPlayerPrivmsg(playerid,recieverid,text[]);
public OnPlayerPrivmsg(playerid,recieverid,text[]) {

#if defined USE_XADMIN
	if(!IsPlayerConnected(playerid)||!IsPlayerConnected(recieverid)) return 1;
	new  ToName[24], Name[24]; GetPlayerName(playerid,Name,24);
	if(Config[ExposePMS]) {
	    GetPlayerName(recieverid,ToName,24);
	    format(string128,sizeof(string128),"PM: %s [%d] -> %s [%d]: %s",Name,playerid,ToName,recieverid,text);
	    SendMessageToAdmins(string128);
	}
    if(Config[WireWithPM] && Variables[playerid][Wired]) {
	    Variables[playerid][WiredWarnings]--;
	    if(Variables[playerid][WiredWarnings]) {
	        format(string128,sizeof(string128),"You have been wired thus preventing you from talking and PMing. [Warnings: %d/%d]",Variables[playerid][WiredWarnings],Config[WiredWarnings]);
			SendClientMessage(playerid,white,string128); return 0;
		}
		else {
  			format(string128,sizeof(string128),"%s has been kicked from the server. [REASON: Wired]",Name);
		    SendClientMessageToAll(yellow,string128); SetUserInt(playerid,"Wired",0);
		    Kick(playerid); return 0;
		}
	}
#endif
	if(!strcmp(text, lastpm[playerid], true, 128)) {
		SendClientMessage(playerid,COLOR_SYSTEM,"Error: Duplicate private message not allowed");
		return 0;
	}
	else strmid(lastpm[playerid], text, 0, 127,128);
	return 1;
}


public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	tpallow[playerid] = 0;
#if defined FLYMODE
	// Reset the data belonging to this player slot
	noclipdata[playerid][cameramode] 	= CAMERA_MODE_NONE;
	noclipdata[playerid][lrold]	   	 	= 0;
	noclipdata[playerid][udold]   		= 0;
	noclipdata[playerid][fmode]   		= 0;
	noclipdata[playerid][lastmove]   	= 0;
	noclipdata[playerid][accelmul]   	= 0.0;
#endif //flymode
	blnPlayerRadioactive[playerid] = false; // nuke script
	blockregister[playerid] = 0;
	carjack[playerid] = 0;
	pro[playerid] = 0;
	SetPlayerTime(playerid,12,0);
    DestroyObject(magnet[playerid]);
	magnet[playerid] = INVALID_OBJECT_ID;
	attached[playerid] = INVALID_VEHICLE_ID;
	
	VehModel[playerid] = CreatePlayerTextDraw(playerid,240.000000, 423.000000, "~w~Veh: ~y~----");
	PlayerTextDrawSetOutline(playerid,VehModel[playerid], 1);
	PlayerTextDrawFont(playerid,VehModel[playerid], 1);
	PlayerTextDrawSetProportional(playerid,VehModel[playerid], 2);
	PlayerTextDrawLetterSize(playerid,VehModel[playerid], 0.25, 0.75);
//	setspawn[playerid] = 0;
	
	
#if defined IRC_ECHO
	new joinMsg[128];
	GetPlayerName(playerid, pname[playerid], sizeof(pname));
	format(joinMsg, sizeof(joinMsg), "02[%d] 03*** %s has joined the server.", playerid, pname[playerid]);
	IRC_GroupSay(groupID, IRC_CHANNEL, joinMsg);
#endif

#if defined USE_XADMIN
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		if(VehicleLockData[i]) SetVehicleParamsForPlayer(i,playerid,false,true);
		else SetVehicleParamsForPlayer(i,playerid,false,false);
	}
	new PlayerName[24],file[256]; file = GetPlayerFile(playerid);
	GetPlayerName(playerid,PlayerName,24);
	if(containsip(PlayerName))
	{
	    SendClientMessage(playerid,COLOR_RED,"INVALID NAME! Please re-join server with a different name");
		Kick(playerid);
	}
	if(!dini_Exists(file)) CreateUserConfigFile(playerid);
	for(new i = 0; i < 100; i++) {
	    if(strfind(PlayerName,ForbidNames[i],true)!=-1 && Config[ForbidData]) {
			switch(Config[ForbidData]) { case 1: Kick(playerid); case 2: Ban(playerid); }
			return 1;
		}
	}
	Variables[playerid][Registered] = GetPlayerFileVar(playerid,"Registered"),
	Variables[playerid][Level] = GetPlayerFileVar(playerid,"Level");
	Variables[playerid][Wired] = GetPlayerFileVar(playerid,"Wired");
	Variables[playerid][Jailed] = GetPlayerFileVar(playerid,"Jailed");
	Variables[playerid][Money] = GetPlayerFileVar(playerid,"Money");
	Variables[playerid][Kills] = GetPlayerFileVar(playerid,"Kills");
	Variables[playerid][RaceWins] = GetPlayerFileVar(playerid,"RaceWins");
	Variables[playerid][HiddenPackages] = GetPlayerFileVar(playerid,"HiddenPackages");
	Variables[playerid][Kicks] = GetPlayerFileVar(playerid,"Kicks");
	Variables[playerid][Skin] = GetPlayerFileVar(playerid,"Skin");
	Variables[playerid][PCarModel] = GetPlayerFileVar(playerid,"PCarModel");
	Variables[playerid][PCarPaintJ] = GetPlayerFileVar(playerid,"PCarPaintJ");
	Variables[playerid][PCarColor] = GetPlayerFileVar(playerid,"PCarColor");
	Variables[playerid][Group] = GetPlayerFileVar(playerid,"Group");
	Variables[playerid][Pox] = GetPlayerFileVar(playerid,"Pox");
	Variables[playerid][Bounty] = GetPlayerFileVar(playerid,"Bounty");
	Variables[playerid][House1] = GetPlayerFileVar(playerid,"House1");
	Variables[playerid][House2] = GetPlayerFileVar(playerid,"House2");
	Variables[playerid][House3] = GetPlayerFileVar(playerid,"House3");
	Variables[playerid][Pro] = GetPlayerFileVar(playerid,"Pro");
	Variables[playerid][MinsPlayed] = GetPlayerFileVar(playerid,"MinsPlayed");
	if(Variables[playerid][Wired]) SetUserInt(playerid,"WiredWarnings",Config[WiredWarnings]);
	if(Variables[playerid][Level] > Config[MaxLevel]) { Variables[playerid][Level] = Config[MaxLevel]; SetUserInt(playerid,"Level",Config[MaxLevel]); }
	if(Variables[playerid][Registered])
	{
	    Variables[playerid][LoggedIn] = false;
	    format(string128,sizeof(string128),"~w~ACCOUNT EXISTS!~n~~r~60 secs~w~ to LOGIN!");
	    GameTextForPlayer(playerid,string128,5000,3);
	    logintimer[playerid] = SetTimerEx("LoginDelay",60000,0,"%i",playerid);
		format(string128,sizeof(string128),"{33AA33}Welcome back, %s!{C0C0C0} To log back into your account, type{FFFFFF} \"/LOGIN <PASSWORD>\".",PlayerName);
	 	SendClientMessage(playerid,yellow,string128);
	 	format(string128,sizeof(string128),"{C0C0C0}--  You have 60 seconds to login before your name is changed by the system. This prevents name-stealing",PlayerName);
	 	SendClientMessage(playerid,yellow,string128);

	}
	else
	{
		format(string128,sizeof(string128),"{33AA33}Hello, %s!{C0C0C0} To register an account to this server, type{FFFFFF} \"/REGISTER <PASSWORD>\".",PlayerName);
	    SendClientMessage(playerid,yellow,string128);
		format(string128,sizeof(string128),"{33AA33}REMEMBER:{C0C0C0} Your stats will NOT save unless you have registered your account here!",PlayerName);
	    SendClientMessage(playerid,yellow,string128);
	    format(string128,sizeof(string128),"~w~TYPE~r~/register <pass>~n~~w~ to register account");
	    GameTextForPlayer(playerid,string128,5000,3);
	    
	}
	
	GetPlayerName(playerid, stroriginalname[playerid], sizeof(stroriginalname));

#endif //xadmin

#if defined VEH_THUMBNAILS
// Init all of the textdraw related globals
    gHeaderTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gBackgroundTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gCurrentPageTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gNextButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gPrevButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;

    for(new x=0; x < SELECTION_ITEMS; x++)
	{
        gSelectionItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
	}

	gItemAt[playerid] = 0;
#endif //veh_thumbnails

	frozen[playerid] = 0;
	strmid(lastchat[playerid], "NULL", 0, 127,128);
    strmid(lastpm[playerid], "NULL", 0, 127,128);
	inonplayerconnect[playerid] = 1;
	GetPlayerName(playerid,pname[playerid],MAX_PLAYER_NAME);
	SetPlayerColor(playerid, PlayerColors[playerid]);
	pcolor[playerid] = PlayerColors[playerid];
	connected[playerid] = 1;
	policecar[playerid] = false;
	aircraft[playerid] = false;
	firecar[playerid] = false;
	format(string128,sizeof(string128)," - ");
	posTD[playerid] = CreatePlayerTextDraw(playerid,548.0, 23.0, string128);
	PlayerTextDrawSetOutline(playerid,posTD[playerid], 1);
	PlayerTextDrawFont(playerid,posTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid,posTD[playerid], 2);
	PlayerTextDrawLetterSize(playerid,posTD[playerid], 0.21, 0.71);
    PlayerTextDrawShow(playerid, posTD[playerid]);
    Speedo[playerid] = CreatePlayerTextDraw(playerid,40.00, 327.00, string128);
    Stats[playerid] = CreatePlayerTextDraw(playerid,450.000000, 440.000000, "~w~Kills:~y~- ~w~Wins:~y~- ~w~Group:~y~- ~w~Played:~r~-~y~mins");
	PlayerTextDrawSetOutline(playerid,Speedo[playerid], 1);
	PlayerTextDrawFont(playerid,Speedo[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Speedo[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Speedo[playerid], 0.35, 0.85);
	PlayerTextDrawShow(playerid, Speedo[playerid]);
	PlayerTextDrawSetOutline(playerid,Stats[playerid], 1);
	PlayerTextDrawFont(playerid,Stats[playerid], 1);
	PlayerTextDrawSetProportional(playerid,Stats[playerid], 2);
	PlayerTextDrawLetterSize(playerid,Stats[playerid], 0.20, 0.70);
	PlayerTextDrawShow(playerid, Stats[playerid]);
	safe[playerid] = 0;
	reserve[playerid] = 0;
	quiet[playerid] = 0;
	race1st[playerid] = 0;
	minutesplayed[playerid] = 0;
	kills[playerid] = 0;
	pmoney[playerid] = 0;
	SendDeathMessage(INVALID_PLAYER_ID,playerid,200);
	pvehicleid[playerid] = INVALID_VEHICLE_ID; // player vehicles id
	pmodelid[playerid] = 0; // players vehicles model id
	pstate[playerid] = 0; // current player state (DRIVER, PASSENGER, ON_FOOT)
	chicken[playerid] = INVALID_OBJECT_ID; //assigned to objectid of player spawned chicken
	cow[playerid] = INVALID_OBJECT_ID; //assigned to objectid of player spawned cow
	mine[playerid] = INVALID_OBJECT_ID; // assigned to player spawn stunt mine
	ramp[playerid] = INVALID_OBJECT_ID; // assigned to player spawn ramp
	firemeobject[playerid] = INVALID_OBJECT_ID; // assigned to player spawn ramp
	gTeam[playerid] = 0; // Tracks the team assignment for each player
	pskin[playerid] = 0; //player skin
	helmet[playerid] = 0; // player not wearing helmet
	key2[playerid] = KEY2_UNBOUND;
	keyy[playerid] = KEYY_MENU;
	keyn[playerid] = KEYN_STOP;
	skulls[playerid] = 0;
	kills[playerid] = 0;
	godmode[playerid] = 1;
	cantgod[playerid] = 0;
	helikills[playerid] = 0;
	gPlayerUsingLoopingAnim[playerid] = 0; //animation system
	gblnIsMuted[playerid][MAX_PLAYERS - 1] = false; // Minus one to prevent overflow exception. Can't figure out why, but it shouldn't cause problems.
	firstspawn[playerid] = 1;
	playticks[playerid] = 0;
	horn[playerid] = 0;
	hassnos[playerid] = 0;
	setspawn[playerid] = 255;
	saveposx[playerid] = 0.0;
	saveposy[playerid] = 0.0;
	saveposz[playerid] = 10.0;
	saveint[playerid] = 0;
	playercar[playerid] = INVALID_VEHICLE_ID; // assigned to current player-spawned vehicle
    playertrailer[playerid] = INVALID_VEHICLE_ID;
	gblnCanCount[playerid] = true;
	jump[playerid] = 0;
	afk[playerid] = 0;
	storedx[playerid] = 0;
	storedy[playerid] = 0;
	storedz[playerid] = 0;
	storeda[playerid] = 0; //stored coords for /back command after choosing car
	storedint[playerid] = 0; //stored interior for /back command
	pinterior[playerid] = 0; // current player interior
	pworld[playerid] = 0; // player world
	RaceParticipant[playerid] = 0;
	badcar[playerid] = false; // car has guns/otherwise disallowed from places
	cantrace[playerid] = false; //is player banned from races
	aircraft[playerid] = false; //is player in aircraft
	cancount[playerid] = false; //can player use /count command
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		gblnIsMuted[i][playerid] = false;
		gblnIsMuted[playerid][i] = false;
	}
	new rand = random(sizeof(startMusic));
	PlayerPlaySound(playerid, startMusic[rand],0.0,0.0,0.0);
    SetSpawnInfo(playerid,0,0,1899.6129,-2240.0889,13.5469,255.5154,1,1,31,200,12,1);
	SendClientMessage(playerid,COLOR_LIGHTBLUE,"{33CCFF}[REPORT]:{C0C0C0} To report a player who is cheating, use the /report command. Ex:  {FFFFFF}/report 4 carjacking");
//	SendClientMessage(playerid,COLOR_LIGHTBLUE,"{33CCFF}[IRC]:{C0C0C0} Join our IRC channel! irc.gamesurge.net:6667 #Everystuff.");
//REMOVE SOME OBJECTS
	// remove ls airport fencing
	RemoveBuildingForPlayer(playerid, 3672, 2112.9375, -2384.6172, 18.8828, 0.25); //removes hangar
	RemoveBuildingForPlayer(playerid, 3629, 2112.9375, -2384.6172, 18.8828, 0.25); // hangar LOD
	RemoveBuildingForPlayer(playerid, 3780, 1381.1172, -2541.3750, 14.2500, 0.25); // airport 3 yellow jumps
	RemoveBuildingForPlayer(playerid, 3665, 1381.1172, -2541.3750, 14.2500, 0.25); //airport 3 yellow jumps LOD
	RemoveBuildingForPlayer(playerid, 5068, 1510.3906, -2677.3906, 16.3984, 0.25); // wide dual chain link
	RemoveBuildingForPlayer(playerid, 5070, 2180.2031, -2416.0625, 16.3984, 0.25); //wide dual curved chain link
	RemoveBuildingForPlayer(playerid, 5071, 2123.5234, -2576.6641, 16.4219, 0.25); // wide dual straight w/ curve chain link
	RemoveBuildingForPlayer(playerid, 5073, 2136.6328, -2348.0859, 16.3984, 0.25); // curving chain link
	RemoveBuildingForPlayer(playerid, 5074, 2101.1953, -2269.1563, 16.3984, 0.25); //curving chain link
	RemoveBuildingForPlayer(playerid, 5076, 1360.6406, -2487.8516, 16.3984, 0.25); // chain link
	RemoveBuildingForPlayer(playerid, 5001, 1789.7891, -2365.9219, 15.4219, 0.25); // tall fence
	RemoveBuildingForPlayer(playerid, 5072, 1996.3047, -2677.5938, 16.3984, 0.25); //wide dual chain link
	RemoveBuildingForPlayer(playerid, 5007, 1826.6094, -2259.9063, 15.4375, 0.25); // curving tall chian link
	RemoveBuildingForPlayer(playerid, 1412, 1949.3438, -2227.5156, 13.6563, 0.25); // small chain section
	RemoveBuildingForPlayer(playerid, 1412, 1975.7266, -2227.4141, 13.7578, 0.25); //small chain section
	RemoveBuildingForPlayer(playerid, 5075, 1391.5781, -2626.4922, 16.3984, 0.25); // curving chain link
	RemoveBuildingForPlayer(playerid, 5030, 1465.0078, -2396.6563, 16.1016, 0.25); //zigzag fence
	RemoveBuildingForPlayer(playerid, 4990, 1646.1953, -2414.0703, 17.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 5010, 1646.1953, -2414.0703, 17.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 2112.9375, -2384.6172, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 1889.6563, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 1822.7344, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 1682.7266, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 1617.2813, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3672, 1754.1719, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1607.0156, -2439.9766, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 1617.2813, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1620.3594, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1620.3594, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1620.3594, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1620.3594, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1649.0625, -2641.4063, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3663, 1664.4531, -2439.8047, 14.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 1682.7266, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1686.4453, -2439.9766, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1705.0391, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1705.0391, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1705.0391, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1705.0391, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 1754.1719, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1789.7188, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1789.7188, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1789.7188, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1789.7188, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 1822.7344, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 3663, 1832.4531, -2388.4375, 14.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1855.7969, -2641.4063, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1874.3984, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 1889.6563, -2666.0078, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1922.2031, -2641.4063, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1874.3984, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1874.3984, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1959.0781, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1959.0781, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1959.0781, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1959.0781, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 2003.4531, -2422.1719, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 1215, 1980.9219, -2413.8750, 13.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1215, 1980.9219, -2355.2109, 13.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 2003.4531, -2350.7344, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2043.7578, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2043.7578, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2043.7578, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2043.7578, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 2088.6094, -2422.1719, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2128.4375, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2128.4375, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1215, 2131.0156, -2608.5234, 13.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 2128.4375, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 2146.0156, -2409.3516, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3629, 2112.9375, -2384.6172, 18.8828, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1899.4219, -2244.5078, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 1215, 1983.8594, -2281.7109, 13.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 2003.4531, -2281.3984, 18.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1471.4844, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1471.4844, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1471.4844, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1471.4844, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1525.0078, -2439.9766, 18.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1535.6797, -2476.8516, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1535.6797, -2511.0781, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1535.6797, -2576.2109, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3666, 1535.6797, -2610.4375, 12.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3663, 1580.0938, -2433.8281, 14.5703, 0.25);
	// remove abandoned airport planewrecks
	RemoveBuildingForPlayer(playerid, 3367, 149.9141, 2614.6172, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 176.7891, 2641.4844, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 284.2656, 2641.4844, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 284.2656, 2587.7422, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 215.5313, 2411.3828, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 134.9141, 2438.2500, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 134.9141, 2438.2500, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 215.5313, 2411.3828, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 284.2656, 2587.7422, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 149.9141, 2614.6172, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 176.7891, 2641.4844, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 284.2656, 2641.4844, 15.4766, 0.25);
	// remove LV airport stuffs
	RemoveBuildingForPlayer(playerid, 8152, 1377.3359, 1173.3281, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8153, 1696.0234, 1317.9922, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 8154, 1610.5781, 1184.9844, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8155, 1657.5078, 1255.5859, 13.6406, 0.25);
	RemoveBuildingForPlayer(playerid, 8165, 1719.4063, 1672.3906, 12.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 8209, 1447.3828, 1863.3594, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8248, 1332.4219, 1756.1250, 13.7500, 0.25);
	RemoveBuildingForPlayer(playerid, 8263, 1647.4219, 1703.5313, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8266, 1719.4063, 1672.3906, 12.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 8267, 1647.4219, 1703.5313, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8269, 1447.3828, 1863.3594, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8276, 1657.5078, 1255.5859, 13.6406, 0.25);
	RemoveBuildingForPlayer(playerid, 8277, 1696.0234, 1317.9922, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 8278, 1377.3359, 1173.3281, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 8279, 1610.5781, 1184.9844, 12.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3489, 1677.2969, 1671.6953, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 3490, 1677.2969, 1671.6953, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 8249, 1332.4219, 1756.1250, 13.7500, 0.25);

#if defined SAMP03X
    SendClientMessage(playerid,COLOR_YELLOW,"Press the 'Y' key on your keyboard (or type /menu) for main menu!!!");
#endif
    inonplayerconnect[playerid] = 0;
    if(!Variables[playerid][Registered])
	{
        format(string128,sizeof(string128),"{%06x}%s{C0C0C0} has joined the server",GetPlayerColor(playerid) >>> 8,pname[playerid]);
        SendClientMessageToAll(COLOR_SYSTEM,string128);
	}
	#if !defined SAMP03X
	SendClientMessage(playerid,COLOR_YELLOW,"Some new 0.3x features may conflict with this version. These bugs will _NOT_ be resolved.");
	SendClientMessage(playerid,COLOR_YELLOW,"This is the OLD 03e server. Our 03X server is 69.60.109.157:7777 - I am NOT maintaining this 0.3e server any longer");
	#endif
	return 1;
}

#if defined USE_XADMIN
forward LoginDelay(playerid);
public LoginDelay(playerid)
{
 	if(Variables[playerid][Registered] && Variables[playerid][LoggedIn] == false )
	{
	    new name[24];
	    GetPlayerName(playerid,name,24);
	    new rand = random(999);
	    format(string128,sizeof(string128),"%sX%i",name,rand);
	    SetPlayerName(playerid,string128);
	    GetPlayerName(playerid,pname[playerid],24);
	    format(string128,sizeof(string128),"{FFFF00}[NAME]: {FFFFFF}Name is registered already. Changed to {C0C0C0}%s{FFFFFF} due to no /login within 60s.",pname[playerid]);
	    SendClientMessage(playerid,COLOR_SYSTEM,string128);
	    blockregister[playerid] = 1;
	    new lstring[128];
	    format(lstring,sizeof(lstring),"~r~NEW NAME:~n~~w~%s",pname[playerid]);
	    GameTextForPlayer(playerid,lstring,4000,3);
	}
	KillTimer(logintimer[playerid]);
	return 1;
}
#endif

public OnPlayerDisconnect(playerid, reason)
{

#if defined IRC_ECHO
	new leaveMsg[128], reasonMsg[8];
	switch(reason)
	{
		case 0: reasonMsg = "Timeout";
		case 1: reasonMsg = "Leaving";
		case 2: reasonMsg = "Kicked";
	}
	GetPlayerName(playerid, pname[playerid], sizeof(pname));
	format(leaveMsg, sizeof(leaveMsg), "02[%d] 03*** %s has left the server. (%s)", playerid, pname[playerid], reasonMsg);
	IRC_GroupSay(groupID, IRC_CHANNEL, leaveMsg);
#endif

#if defined USE_XADMIN
	foreach(Player,i) if(Spec[i][SpectateID] == playerid  && Spec[i][Spectating]) { TogglePlayerSpectating(i,false); Spec[i][Spectating] = false, Spec[i][SpectateID] = INVALID_PLAYER_ID; }
    KillTimer(logintimer[playerid]);
    if(Variables[playerid][LoggedIn])
    {
        new money = GetPlayerMoney(playerid);
	    SetUserInt(playerid,"Money",money);
	    SetUserInt(playerid,"Kills",kills[playerid]);
	    SetUserInt(playerid,"RaceWins",race1st[playerid]);
	    SetUserInt(playerid,"LoggedIn",0);
	    SetUserInt(playerid,"MinsPlayed",minutesplayed[playerid]);
    }
   	blnstealth[playerid] = false;
#endif
	blockregister[playerid] = 0;
	KillTimer(showchattime[playerid]);
//	new Float:x,Float:y,Float:z,Float:a;
	StopAudioStreamForPlayer(playerid); // kill the /radio
	radio[playerid] = 0;
	DestroyObject(firemeobject[playerid]);
	firemeobject[playerid] = INVALID_OBJECT_ID;
	new interior,world;
	GetPlayerPos(playerid,playerx,playery,playerz);
	GetPlayerFacingAngle(playerid,playera);
	interior = GetPlayerInterior(playerid);
	world = GetPlayerVirtualWorld(playerid);
	if(!reason)
	{
#if defined CRASH_POS
	 	printf("[crash] playerid:%i name:%s X:%f Y:%f Z:%f A:%f interior:%i world:%i",playerid,pname[playerid],playerx,playery,playerz,playera,interior,world);
#endif
//		format(string128,sizeof(string128),"[%i]%s timed-out/crashed/didnt pay internet bill",playerid,pname[playerid]);
//		SendClientMessageToAll(COLOR_SYSTEM,string128);
	}
    KillPlayerVehicle(playerid);
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,0);
	playercar[playerid] = INVALID_VEHICLE_ID;
	playertrailer[playerid] = INVALID_VEHICLE_ID;
	pvehicleid[playerid] = INVALID_VEHICLE_ID;
	RemovePlayerAttachedObject(playerid, HELMET_SLOT);
	DestroyObjectEx(playerid);
	hassnos[playerid] = 0;
	gTeam[playerid] = 0;
	pskin[playerid] = 0;
	afk[playerid] = 0;
	storedint[playerid] = 0;
	RaceParticipant[playerid] = 0;
	skulls[playerid] = 0;
	key2[playerid] = KEY2_UNBOUND;
	keyy[playerid] = KEYY_UNBOUND;
	keyn[playerid] = KEYN_UNBOUND;
	badcar[playerid] = false;
	cantrace[playerid] = false;
	aircraft[playerid] = false;
	cancount[playerid] = true;
// #if defined NEON
	DestroyNeon(playerid);
// #endif
	blnIllegalWeaponReported[playerid] = false;
	connected[playerid] = 0;
    return 1;
}


public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
	{
		SendClientMessage(playerid,COLOR_YELLOW,"The system thinks youre an NPC. If youre a human, PLEASE tell us about this: everystuff.net");
		return 1;
	}
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 9999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 9999);
	if(Variables[playerid][Jailed])
	{
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,197.6661,173.8179,1003.0234);
		SetPlayerFacingAngle(playerid,0);
		return 1;
	}
	SetPlayerColor(playerid, pcolor[playerid]);
	SetPlayerDrunkLevel (playerid, 0);
	SetPlayerWorldBounds(playerid, 9999.00, -9999.00, 9999.00, -9999.00);
//	ResetPlayerWeapons(playerid);
	pvehicleid[playerid] = INVALID_VEHICLE_ID;
	pmodelid[playerid] = 0;
	if(RaceParticipant[playerid]) LeaveRace(playerid);
//	KillPlayerVehicle(playerid);
	ShowGodTD(playerid);
	ShowSnosTD(playerid);
	ShowJumpTD(playerid);
	ShowRadioTD(playerid);
	PlayerPlaySound(playerid, 1188,0.0,0.0,0.0); // id 1188 stops ALL music
	if(firstspawn[playerid])
	{
	    
		#if defined TEXTDRAWS
		TextDrawShowForPlayer(playerid, Help);
		TextDrawShowForPlayer(playerid, BottomBanner);
		PlayerTextDrawShow(playerid, Stats[playerid]);
		TextDrawShowForPlayer(playerid, ServerIP);
		#endif //textdraws
	    gTeam[playerid] = 0;
	    firstspawn[playerid] = 0;
//	    dcmd_cmd(playerid,params2);
	    dcmd_help(playerid,params2);
	    
	}
	switch(gTeam[playerid])
	{
		case 0:
	    {
	        GangZoneShowForPlayer(playerid, safezoneLS, 0xFF000096);
	        GangZoneShowForPlayer(playerid, safezoneChiliad, 0xFF000096);
	        GangZoneShowForPlayer(playerid, safezoneLV, 0xFF000096);
	        GangZoneShowForPlayer(playerid, safezoneAA, 0xFF000096);
//	        GangZoneShowForPlayer(playerid, safezoneSF, 0xFF000096);
			GameTextForPlayer(playerid,"~y~PRESS THE ~r~Y ~y~KEY~n~FOR MAIN MENU",5000,3);
			SetPlayerSkin(playerid,pskin[playerid]);
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid,0,1);
			GivePlayerWeapon(playerid,31,99999);
			GivePlayerWeapon(playerid,12,1);
			godmode[playerid] = 1;
			ShowGodTD(playerid);
			SetPlayerWorldBounds(playerid, 9999.00, -9999.00, 9999.00, -9999.00);
//			if(GetPlayerVirtualWorld(playerid) != 0)
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerArmour(playerid,0);
			SetPlayerHealth(playerid,100);
			SetPlayerInterior(playerid,0);
			SetPlayerTeam(playerid,0);
			switch(setspawn[playerid])
			{
			    case 0: dcmd_drift(playerid,params2);
				case 1: dcmd_airport(playerid,params2);//ls airport
		        case 2: dcmd_boneyard(playerid,params2); //aa boneyard
		        case 3: dcmd_chiliad(playerid,params2);
		        case 4: dcmd_sf(playerid,params2); //sf airport
		        case 5: dcmd_lv(playerid,params2); //lv airport
		        case 6: dcmd_ls(playerid,params2); //ls downtown
		        case 7: dcmd_sfd(playerid,params2); //sf downtown
		        case 8: dcmd_lvstrip(playerid,params2); //lv downtown
		        case 9: dcmd_desert(playerid,params2); //desert town
		        case 10: dcmd_sex(playerid,params2); //sex shop
				case 11: dcmd_random(playerid,params2); //random
				case 255: dcmd_random(playerid,params2); //random
				default: dcmd_airport(playerid,params2); //ls airport
			}
			return 1;
	    }
 		case 5: MilitaryDM(playerid);
		case 7: SawnOffDM(playerid);
		case 8: SniperDM(playerid);
		case 9: RocketDM(playerid);
		case 10: MinigunDM(playerid);
		case 13: HouseDM(playerid);
		case 17: GasDM(playerid);
		case 18: ShipDM(playerid);
		case 20: SwordDM(playerid);
		case 21: DeagleDM(playerid);
		case 50: return FamilyDM(playerid);
		case 51: return BallaDM(playerid);
		case 52: return VagosDM(playerid);
		case 53: return AztecaDM(playerid);
		case 54: return RifaDM(playerid);
        case 55: return TriadDM(playerid);
        case 56: return DaNangDM(playerid);
		case 57: return MafiaDM(playerid);
		case 100: //afk
		{
	  		SetPlayerPos(playerid, 2324.33, -1144.79, 1050.71);
	  		SetPlayerInterior(playerid,12);
	  		afk[playerid] = 1;
	  		TogglePlayerControllable(playerid, false);
	    }
	}
	EnableStuntBonusForPlayer(playerid, true);
	return 1;
}

// -----------------------------------------------------------------------------
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
#if defined USE_XADMIN
	foreach(Player,i) if(i != playerid && Spec[i][SpectateID] == playerid  && Spec[i][Spectating]) SetPlayerInterior(i,newinteriorid);
#endif
	return 1;
}


public OnPlayerDeath(playerid, killerid, reason)
{
	SendDeathMessage(killerid,playerid,reason); 
	#if defined USE_XADMIN
	foreach(Player,i) if(Spec[i][SpectateID] == playerid  && Spec[i][Spectating]) { TogglePlayerSpectating(i,false); Spec[i][Spectating] = false, Spec[i][SpectateID] = INVALID_PLAYER_ID; }
	#endif
//	ResetPlayerWeapons(playerid);
	DestroyObjectEx(playerid); // rename DestroyPlayerObjects(playerid)
	DestroyObject(firemeobject[playerid]); //rework into DestroyObjectEx and rename DestroyPlayerObjects(playerid)
	DestroyObject(magnet[playerid]); //rework into DestroyObjectEx and rename DestroyPlayerObjects(playerid)
	firemeobject[playerid] = INVALID_OBJECT_ID; // move into destroyplayerobjects
	if(RaceParticipant[playerid]) LeaveRace(playerid);
	KillPlayerVehicle(playerid);
	//only run things against killerid if there IS a killerid. Otherwise, bad things can happen
	if(killerid == INVALID_PLAYER_ID)
	{
	    return 1;
	}
	else // PvP
	{
	    //make sure they aint fakin it
		if((GetTickCount()-GetPVarInt(killerid, "deathtime")) < 220)
	    {
			SetPVarInt(killerid, "killspam", GetPVarInt(killerid, "killspam")+1);
			if(GetPVarInt(killerid, "killspam") >= 5)
	        {
	            format(string128,sizeof(string128),"[hack][killspam] Kicked [%i]%s for Killspam!",playerid,pname[playerid]);
	            SendClientMessageToAll(COLOR_YELLOW,string128);
	            printf(string128);
	            #if defined IRC_ECHO
                IRC_GroupSay(groupID, IRC_CHANNEL, string128);
                #endif
				return Kick(playerid);
	        }
	  	}
	  	SetPVarInt(killerid, "deathtime", GetTickCount());
	    // actions based on death reason
	    switch(reason)
	    {
			case 12: GivePlayerMoney(killerid,5000); //vibrator = more money
	        case 50,51:
	        {
		        GetPlayerPos(playerid,playerx,playery,playerz);
			    foreach(Player,i)
				{
					PlayerPlaySound(i,10610,playerx,playery,playerz); //scream!!!
				}
				if(reason == 50)
				{
				    helikills[killerid]++;
				    if(helikills[killerid] > 2)
				    {
						format(string128,sizeof(string128),"[helikill] Kicked [%i]%s for too much helikilling (aka: being a dick)",killerid,pname[killerid]);
						SendClientMessageToAll(COLOR_YELLOW,string128);
						printf(string128);
      					#if defined IRC_ECHO
                		IRC_GroupSay(groupID, IRC_CHANNEL, string128);
        				#endif
						return Kick(killerid);
				    }
				    else SendClientMessage(killerid,COLOR_YELLOW,"WARNING: Continued helikills will result in being kicked from the server! ANTIDICK KICKS AFTER 3");
				}
	        }
	    }
		//actions based on team
		if(!gTeam[killerid] && !gTeam[playerid]) //freeroamers killing each other = wanted
		{
		    if(reason == 38 && godmode[playerid])
			{
				printf("killerid [%i]%s killed [GODMODE][%i]%s with a minigun!",killerid,pname[killerid],playerid,pname[playerid]);
			}
			GangZoneHideForPlayer(playerid,lsairspace); // all airspaces can be hidden, because they dont show anyways. This resolves the "symbol is never used" warning on compile
			GangZoneHideForPlayer(playerid,lvairspace); // "
			GangZoneHideForPlayer(playerid,lsairspace); // "
			GangZoneHideForPlayer(playerid,sfairspace); // "
		    if(GetPlayerWantedLevel(playerid) > 5)
			{
				GivePlayerMoney(killerid,2000); //killing wanted = extra money
				SetPlayerWantedLevel(playerid,0); //set dead 6-star person to 0 star
			}
			else //give wanted to killer
			{
				new wanted;
				wanted = GetPlayerWantedLevel(killerid);
			    if(wanted < 6) SetPlayerWantedLevel(killerid,wanted+1); //make sure you dont go over 6-stars
			}
		}
		//gang stuff
		else if(gTeam[killerid] >= 50 && gTeam[killerid] == gTeam[playerid]) SetPlayerHealth(killerid,0.0); // anti-team kill
		else if(gTeam[killerid] >= 50 && gTeam[playerid] >= 50 && gTeam[playerid] != gTeam[killerid])
		{
	 		GivePlayerMoney(killerid,2500); //$2500 bonus per dead gang banger
		}
		//end gang
	  	// player passed the checks and balances. reward them
		kills[killerid]++;
  	    SetPlayerScore(killerid,kills[killerid]);

  	    if(!gTeam[playerid])
  	    {
	  	    GetPlayerPos(playerid,playerx,playery,playerz);
	  	    new rand = random(sizeof(startMusic));
	  	    foreach(Player,i)
	  	    {
	  	    	if(!quiet[i]) PlayerPlaySound(i,deathSounds[rand],playerx,playery,playerz);
	  	    }
		}
		else GivePlayerMoney(playerid,500);
	}
#if defined IRC_ECHO
	new msg[128], reasonMsg[32], playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));

	if (killerid != INVALID_PLAYER_ID)
	{
	    if(reason == 255) return 1;
	    new killerName[MAX_PLAYER_NAME];
	    GetPlayerName(killerid, killerName, sizeof(killerName));
		switch (reason)
		{
			case 0: reasonMsg = "Unarmed";
			case 1: reasonMsg = "Brass Knuckles";
			case 2: reasonMsg = "Golf Club";
			case 3: reasonMsg = "Night Stick";
			case 4: reasonMsg = "Knife";
			case 5: reasonMsg = "Baseball Bat";
			case 6: reasonMsg = "Shovel";
			case 7: reasonMsg = "Pool Cue";
			case 8: reasonMsg = "Katana";
			case 9: reasonMsg = "Chainsaw";
			case 10: reasonMsg = "Dildo";
			case 11: reasonMsg = "Dildo";
			case 12: reasonMsg = "Vibrator";
			case 13: reasonMsg = "Vibrator";
			case 14: reasonMsg = "Flowers";
			case 15: reasonMsg = "Cane";
			case 22: reasonMsg = "Pistol";
			case 23: reasonMsg = "Silenced Pistol";
			case 24: reasonMsg = "Desert Eagle";
			case 25: reasonMsg = "Shotgun";
			case 26: reasonMsg = "Sawn-off Shotgun";
			case 27: reasonMsg = "Combat Shotgun";
			case 28: reasonMsg = "MAC-10";
			case 29: reasonMsg = "MP5";
			case 30: reasonMsg = "AK-47";
			case 31: reasonMsg = "M4";
			case 32: reasonMsg = "TEC-9";
			case 33: reasonMsg = "Country Rifle";
			case 34: reasonMsg = "Sniper Rifle";
			case 37: reasonMsg = "Fire";
			case 38: reasonMsg = "Minigun";
			case 41: reasonMsg = "Spray Can";
			case 42: reasonMsg = "Fire Extinguisher";
			case 49: reasonMsg = "Vehicle Collision";
			case 50: reasonMsg = "Vehicle Collision";
			case 51: reasonMsg = "Explosion";
			default: reasonMsg = "Unknown";
		}
		format(msg, sizeof(msg), "04*** %s killed %s. (%s)", killerName, playerName, reasonMsg);
	}
	else
	{
		switch (reason)
		{
			case 53: format(msg, sizeof(msg), "04*** %s died. (Drowned)", playerName);
			case 54: format(msg, sizeof(msg), "04*** %s died. (Collision)", playerName);
			default: format(msg, sizeof(msg), "04*** %s died.", playerName);
		}
	}
//	if(killerid != INVALID_PLAYER_ID && !gTeam[playerid]) IRC_GroupSay(groupID, IRC_CHANNEL, msg);
#endif //irc_echo
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;
    inonplayerrequestclass[playerid] = 1;
	SetPlayerPos(playerid,-2667.4729,1594.8196,217.2739);
	SetPlayerFacingAngle(playerid, 56.1982);
	SetPlayerCameraPos(playerid,-2671.8096,1596.7000,217.8739);
	SetPlayerCameraLookAt(playerid,-2667.4729,1594.8196,217.2739);
	pskin[playerid] = GetPlayerSkin(playerid);
//	format(string128,sizeof(string128),"~y~skin~w~ %i",pskin[playerid]);
//	GameTextForPlayer(playerid,string128,3000,3);
	inonplayerconnect[playerid] = 0;
	return 1;
}

//forward PlayTimer(playerid);
stock PlayTimer(playerid)
{
	if(connected[playerid])
	{
	    playticks[playerid]++;
	}
	return 1;
}

stock IsLegalWeapon(playerid, weaponid) //ziggy
{
	if(blnIllegalWeaponReported[playerid] == false)
	{
		new illegalweapons[5] = {4, 13, 17, 41, 42};
		new name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof(name));

		for(new i; i<sizeof(illegalweapons); i++)
		{
		    if(weaponid == illegalweapons[i])
		    {
				new string[128], weaponname[32];
				GetWeaponName(weaponid, weaponname, sizeof(weaponname));
				format(string, sizeof(string), "Player %s (ID: %i) is using an illegal weapon: %s", name, playerid, weaponname);
	   			SendMessageToAdmins(string);
	   			printf(string);
	   			blnIllegalWeaponReported[playerid] = true;
		    }
		}
	}
}

public OnPlayerUpdate(playerid) // BE VERY CAREFUL WHAT YOU PUT IN THIS CALLBACK. IT IS CALLED _FREQUENTLY_
{
	IsLegalWeapon(playerid, GetPlayerWeapon(playerid));
#if defined FLYMODE
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);

		if(noclipdata[playerid][fmode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
		{
		    // If the last move was > 100ms ago, process moving the object the players camera is attached to
		    MoveCamera(playerid);
		}

		// Is the players current key state different than their last keystate?
		if(noclipdata[playerid][udold] != ud || noclipdata[playerid][lrold] != lr)
		{
			if((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{   // All keys have been released, stop the object the camera is attached to and reset the acceleration multiplier
				StopPlayerObject(playerid, noclipdata[playerid][flyobject]);
				noclipdata[playerid][fmode]      = 0;
				noclipdata[playerid][accelmul]  = 0.0;
			}
			else
			{   // Indicates a new key has been pressed

			    // Get the direction the player wants to move as indicated by the keys
				noclipdata[playerid][fmode] = GetMoveDirectionFromKeys(ud, lr);

				// Process moving the object the players camera is attached to
				MoveCamera(playerid);
			}
		}
		noclipdata[playerid][udold] = ud; noclipdata[playerid][lrold] = lr; // Store current keys pressed for comparison next update
//		return 0;
	}
#endif //FLYMODE

	switch(pstate[playerid])
	{
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER, PLAYER_STATE_ONFOOT, PLAYER_STATE_SPAWNED:
		{

			GetPlayerPos(playerid,playerx,playery,playerz);
			if(pstate[playerid] == PLAYER_STATE_DRIVER || pstate[playerid] == PLAYER_STATE_PASSENGER) GetVehicleZAngle(pvehicleid[playerid], playera);
			else GetPlayerFacingAngle(playerid,playera);
			format(string128,sizeof(string128),"~w~X:~y~%.0f ~w~Y:~y~%.0f~n~~w~A:~y~%.0f ~w~Z:~y~%.0f~n~~w~Int:~y~%i ~w~World:~y~%i",playerx,playery,playera,playerz,pinterior[playerid],pworld[playerid]);
		    PlayerTextDrawSetString(playerid,posTD[playerid],string128);
		    if(godmode[playerid])
			{
				SetPlayerChatBubble(playerid,"GOD MODE",COLOR_CONFIRM,150.0,1000);
				if(gTeam[playerid] > 0 && gTeam[playerid] != 100)
				{
					godmode[playerid] = 0;
					ShowGodTD(playerid);
			   	}
			}
		    #if defined ANTI_CARJACK
			CheckPlayerRemoteJacking( playerid );
			#endif
			// GOGGLES FIX
			if(pstate[playerid] == PLAYER_STATE_ONFOOT || pstate[playerid] == PLAYER_STATE_SPAWNED)
			{
				new weapon = GetPlayerWeapon(playerid);
				if(weapon == 44 || weapon == 45)
				{
				    new keys, ud, lr;
				    GetPlayerKeys(playerid, keys, ud, lr);
				    if(keys & KEY_FIRE)
				    {
				        return 0;
				    }
				}
			}
			//END GOGGLES FIX
			if(pstate[playerid] == PLAYER_STATE_DRIVER && pmodelid[playerid] == 548)
			{
				if(attached[playerid] != INVALID_VEHICLE_ID)
				{
				    GetVehiclePos(pvehicleid[playerid],playerx,playery,playerz);
				    GetVehicleZAngle(pvehicleid[playerid],playera);
				    PutPlayerInVehicle(playerid,attached[playerid],1);
				    SetVehiclePos(attached[playerid],playerx,playery,playerz-13.0);
				    SetVehicleZAngle(attached[playerid],playera);
				    PutPlayerInVehicle(playerid,pvehicleid[playerid],0);
				}
			}
		}
    }
	return 1;
}





public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	OPTDamt = 0;
	if(issuerid != INVALID_PLAYER_ID)
	{
	    if(godmode[issuerid])
		{
			SetPlayerArmour(issuerid,0);
			//dcmd_god(issuerid,params2);
			godmode[issuerid] = 0;
			
			godtimer[issuerid] = SetTimerEx("GodTimer",120000,0,"i",issuerid);
			cantgod[issuerid] = 1;
			ShowGodTD(issuerid);
			GameTextForPlayer(issuerid,"~n~~y~GOD MODE ~r~DISABLED",6000,3);
			PlayerPlaySound(issuerid,2607,0,0,0);
			
			
		}
        if(!gTeam[playerid]) //freeroam
        {
            if(godmode[playerid])
            {
                GameTextForPlayer(issuerid,"~w~PLAYER IN ~r~/GOD ~w~MODE~n~YAAAY ~r~/GOD~w~ MODE!!",4000,3);
				return 1;
            }
            else // player is vulnerable
            {
				GetPlayerPos(issuerid,playerx,playery,playerz);
				foreach(Player,i)
				{
					if(!gTeam[i] && issuerid < 100) SetPlayerMapIcon(i,issuerid,playerx,playery,playerz,23,0,MAPICON_GLOBAL);
                }
				switch(weaponid)
                {
                    case 10: // double dildo
                    {
                        OPTDamt = 20;

					}
                    case 14: // flowers
					{
						OPTDamt = 15;
						GetPlayerHealth(playerid,OPTDhealth);
						if(OPTDhealth+OPTDamt > 100) SetPlayerHealth(playerid,100);
						else
						{
							SetPlayerHealth(playerid,OPTDhealth+OPTDamt);
						}
						format(string128,sizeof(string128),"You have healed {FFFFFF}[%i]{%06x}%s {FF66FF}for +15 hp!",playerid,GetPlayerColor(playerid) >>> 8,pname[playerid]);
                        SendClientMessage(issuerid,COLOR_PINK, string128);
						format(string16,sizeof(string16),"+15 hp",OPTDamt);
					    SetPlayerChatBubble(playerid,string16,COLOR_GREEN,150.0,3000);
					    format(string32,sizeof(string32),"~n~~g~+15~y~hp");
//					    GameTextForPlayer(playerid,string32,3000,3);
					    return 1;
	                }
                    case 35,36,37,38,39: OPTDamt = amount/3; // heavy weapons = reduce to 1/3
					default: OPTDamt = amount;
                }
            }
        }
        else if(gTeam[playerid] == 100) //afk
        {
            GameTextForPlayer(issuerid,"~w~PLAYER IS ~r~/AFK",3000,3);
			return 1;
        }
        else if(gTeam[playerid] > 0)
        {
            OPTDamt = amount;
            format(string16,sizeof(string16),"-%.0f hp",OPTDamt);
	    	SetPlayerChatBubble(playerid,string16,COLOR_DARKRED,150.0,3000);
            return 1;
        }

		GetPlayerHealth(playerid,OPTDhealth);
		SetPlayerHealth(playerid,OPTDhealth-OPTDamt);
		format(string16,sizeof(string16),"-%.0f hp",OPTDamt);
	    SetPlayerChatBubble(playerid,string16,COLOR_DARKRED,150.0,3000);
	    format(string32,sizeof(string32),"~n~~r~%s",string16);
//	    GameTextForPlayer(playerid,string32,4000,3);
	    return 1;
	}
	else // if issuerid = invalid
	{
	    format(string16,sizeof(string16),"-%.0f hp",amount);
	    SetPlayerChatBubble(playerid,string16,COLOR_DARKRED,150.0,3000);
	    format(string32,sizeof(string32),"~n~~r~%s",string16);
//	    GameTextForPlayer(playerid,string32,4000,3);
	    switch(weaponid)
	    {
			case 50:
			{
				GetPlayerHealth(playerid,OPTDhealth);
				if(OPTDhealth+amount < 100.1) SetPlayerHealth(playerid,OPTDhealth+amount);
				else SetPlayerHealth(playerid,100.0);
				return 1;
			}
		}
		if(jump[playerid] && weaponid != 51 && godmode[playerid])
		{
			GetPlayerHealth(playerid,OPTDhealth);
			if(OPTDhealth+amount < 100.1) SetPlayerHealth(playerid,OPTDhealth+amount);
			else SetPlayerHealth(playerid,100.0);
			return 1;
		}
	}
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid)
{
    if(weaponid == 4)
    {
        if(IsPlayerAdmin(playerid))
        {
        	SetPlayerHealth(damagedid,0);
        	SetPlayerHealth(playerid,100.0);
        	SetPlayerArmour(playerid,100.0);
        	SendClientMessageToAll(COLOR_SYSTEM,"The gods have commited their wrath upon a fellow player.  You have been healed.");
        	foreach(Player,i)
        	{
        	    ApplyAnimation(i, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
        	    PlayerPlaySound(i,7879,0.0,0.0,0.0);
        	    if(i != damagedid)
				{
					SetPlayerHealth(i,100);
					SetPlayerArmour(i,100);
					GivePlayerWeapon(i,14,1);
				}
        	}
	        return 1;
        }
    }
    else if (weaponid == 38 && !gTeam[playerid])
    {

    
    }
    return 1;
}

SendClientError(playerid,color,const msg[])
{
	SendClientMessage(playerid,COLOR_ERROR,msg);
	PlayerPlaySound(playerid,1056,0,0,0);
	return 1;
	#pragma unused color // silences warning, using {color} tags anyways
}


public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(Variables[playerid][Jailed] || frozen[playerid] ) return SendClientMessage(playerid,red,"You can NOT use any commands whilst you are jailed.");

	if(!RaceParticipant[playerid] && !gTeam[playerid])
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
			SetPlayerPosFindZ(playerid, fX, fY, fZ);
		}
		else SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot map-teleport while in a vehicle. Please exit the vehicle and try again.");
	}
	else return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot teleport at this time.  Type {CC0000}/leave{C0C0C0} and then try the map-teleport again.");
    return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(IsPlayerAdmin(playerid))
	{
	    GetPlayerPos(clickedplayerid,playerx,playery,playerz);
	    SetPlayerPos(playerid,playerx-1,playery-2,playerz+1);
	}
	return 1;
}

#if defined VEH_THUMBNAILS
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(GetPVarInt(playerid, "vspawner_active") == 0) return 0;

	new curpage = GetPVarInt(playerid, "vspawner_page");

	// Handle: next button
	if(playertextid == gNextButtonTextDrawId[playerid]) {
	    if(curpage < (GetNumberOfPages() - 1)) {
	        SetPVarInt(playerid, "vspawner_page", curpage + 1);
	        ShowPlayerModelPreviews(playerid);
         	UpdatePageTextDraw(playerid);
         	PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		} else {
		    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}

	// Handle: previous button
	if(playertextid == gPrevButtonTextDrawId[playerid]) {
	    if(curpage > 0) {
	    	SetPVarInt(playerid, "vspawner_page", curpage - 1);
	    	ShowPlayerModelPreviews(playerid);
	    	UpdatePageTextDraw(playerid);
	    	PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
		} else {
		    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}

	// Search in the array of textdraws used for the items
	new x=0;
	while(x != SELECTION_ITEMS) {
	    if(playertextid == gSelectionItems[playerid][x]) {
	        HandlePlayerItemSelection(playerid, x);
	        PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
	        DestroySelectionMenu(playerid);
	        CancelSelectTextDraw(playerid);
        	SetPVarInt(playerid, "vspawner_active", 0);
        	return 1;
		}
		x++;
	}

	return 0;
}

#endif



// HOLDING(keys)
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

public OnPlayerKeyStateChange(playerid,newkeys,oldkeys) //TRY NOT TO ADD CONDITIONS DIRECTLY TO THE newkeys CHECK.
{
	
	if (newkeys & KEY_ACTION)
	{
	    if(pstate[playerid] == PLAYER_STATE_DRIVER)
		{
		 	if(pmodelid[playerid] == 548)
			{
				if(magnet[playerid] != INVALID_OBJECT_ID && attached[playerid] == INVALID_VEHICLE_ID)
				{
				    new Float:zangle;
                    GetPlayerPos(playerid,playerx,playery,playerz);
                    GetVehicleZAngle(pvehicleid[playerid],zangle);
				    for(new i = 0; i < MAX_VEHICLES; i++)
				    {
						if(i != pvehicleid[playerid])
						{
							GetVehiclePos(i,carx,cary,carz);
							new Float: fDistance = GetVehicleDistanceFromPoint(pvehicleid[playerid],carx,cary,carz);
						    if(fDistance < 20 && (playerz - carz) > 10.0 && (playerz - carz) < 20.0)
						    {
							    attached[playerid] = i;
							    GameTextForPlayer(playerid,"~n~~g~VEHICLE ON MAGNET",3000,3);
							    new prevcar = pvehicleid[playerid];
								PutPlayerInVehicle(playerid,i,1);
								SetVehiclePos(i,playerx,playery,playerz-25.0);
								SetVehicleZAngle(i,zangle);
								PutPlayerInVehicle(playerid,prevcar,0);
							    return 1;
						    }
						}
				    }
				}
				else if(attached[playerid] != INVALID_VEHICLE_ID)
				{
				    attached[playerid] = INVALID_VEHICLE_ID;
				    GameTextForPlayer(playerid,"~n~~r~VEHICLE DETACHED",3000,3);
				    return 1;
				}
			}
		    
			else if(IsValidObject(vobject[pvehicleid[playerid]]))
			{
				if(!godmode[playerid])
				{
			    	GetPlayerPos(playerid, playerx, playery, playerz);
					GetXYInFrontOfPlayer(playerid, playerx, playery, 20);
					foreach(Player,i)
					{
						if(godmode[i] && IsPlayerInRangeOfPoint(i,3,playerx,playery,playerz))
						{
							return GameTextForPlayer(playerid,"~w~TARGET IN ~r~/GOD ~w~MODE",2000,3);
						}
					}
					CreateExplosion(playerx, playery, playerz, 12, 2);
				}
				else GameTextForPlayer(playerid,"~w~NO SHOOTING IN ~r~/GOD ~w~MODE",3000,3);
			}
			else if(hassnos[playerid])
			{
				if(gTeam[playerid] || RaceParticipant[playerid]) return 1;
				new Float:v[3];
				GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
				SetVehicleVelocity(pvehicleid[playerid], v[0]*1.5, v[1]*1.5, 0.0);
				if(!badcar[playerid]) SetVehicleHealth(pvehicleid[playerid],1000.0);
			}
		}
		return 1;
	}
	else if(newkeys & KEY_SPRINT)
	{
		if(gPlayerUsingLoopingAnim[playerid] == 1)
		{
			gPlayerUsingLoopingAnim[playerid] = 0;
    		ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0); //breaks them out of animation loop
        	animation[playerid] = 0;
        }
        return 1;
	}
	else if(newkeys & KEY_JUMP)
	{
	    if(!jump[playerid] || gTeam[playerid] || RaceParticipant[playerid]) return 1;
   		else if(!gTeam[playerid] && (pstate[playerid] == PLAYER_STATE_ONFOOT || pstate[playerid] == PLAYER_STATE_SPAWNED))
		{
		    new Float:x,Float:y,Float:z;
			GetPlayerVelocity(playerid,x,y,z);
			if(z >= 0.0) SetPlayerVelocity(playerid,x*1.3,y*1.3,z+10*300.2);
			else SetPlayerVelocity(playerid,x*1.3,y*1.3,z*(-500.2));
		}
	}
 	else if(newkeys & KEY_HANDBRAKE)
 	{
//	 	if(!jump[playerid] || gTeam[playerid] || RaceParticipant[playerid]) return 1;
      	if(!gTeam[playerid] && pstate[playerid] == PLAYER_STATE_DRIVER && jump[playerid] && !RaceParticipant[playerid])
		{
			new Float:x,Float:y,Float:z;
			GetVehicleVelocity(pvehicleid[playerid],x,y,z);
			SetVehicleVelocity(pvehicleid[playerid],x*1.2,y*1.2,z*5.2);
		}
	}
	else if(newkeys & KEY_SUBMISSION)
	{
	    if(pvehicleid[playerid] != INVALID_VEHICLE_ID) //is player in car
	    {
		    if(gTeam[playerid]) return 1;
			dcmd_vr(playerid,params2);
			if(pstate[playerid] == PLAYER_STATE_DRIVER && IsInModVehicle(playerid))
			{
		    	AddNosToVehicle(playerid,pvehicleid[playerid]);
			}
			switch(key2[playerid])
			{
			    case KEY2_UNBOUND: return 1;
				case KEY2_FLIP: dcmd_flip(playerid,params2);
				case KEY2_RAMP: dcmd_putramp(playerid,params2);
				case KEY2_SKULLS: dcmd_putskulls(playerid,params2);
				case KEY2_STOP: dcmd_stop(playerid,params2);
			}
		}
		else //player NOT in car
		{
		
		}
		return 1;
	}
	else if(newkeys & KEY_YES)
	{
	    if(gTeam[playerid]) return 1;
		switch(keyy[playerid])
		{
		    case KEYY_UNBOUND: return 1;
			case KEYY_MENU: dcmd_menu(playerid,params2);
			case KEYY_DM: dcmd_dm(playerid,params2);
			case KEYY_CAR: dcmd_v(playerid,params2);
			case KEYY_GUN: dcmd_gun(playerid,params2);
		}
		return 1;
	}
	else if(newkeys & KEY_NO)
	{
	    if(gTeam[playerid]) return 1;
		switch(keyn[playerid])
		{
		    case KEYN_UNBOUND: return 1;
			case KEYN_STOP: dcmd_stop(playerid,params2);
			case KEYN_RAMP: dcmd_putramp(playerid,params2);
			case KEYN_MINE: dcmd_putmine(playerid,params2);
			case KEYN_SKULLS: dcmd_putskulls(playerid,params2);
			case KEYN_FLIP: dcmd_flip(playerid,params2);
			case KEYN_EJECT: dcmd_e(playerid,params2);
//			case KEYN_JIHAD: dcmd_jihad(playerid,params2);
			
		}
		return 1;
	}
	else if ((newkeys & KEY_CROUCH))
	{
	    if(horn[playerid] && pstate[playerid] == PLAYER_STATE_DRIVER)
	    {
		    GetPlayerPos(playerid,playerx,playery,playerz); //get horn users pos
		    foreach(Player,i)
		    {
			    PlayerPlaySound(i,3200,playerx,playery,playerz); //play sound for everyone, but only at horn users pos
	  		}
	    }
	}
	else if(newkeys & KEY_SECONDARY_ATTACK)
	{
		if(pvehicleid[playerid] == INVALID_VEHICLE_ID)
		{
			GetPlayerPos(playerid, playerx, playery, playerz );
			new vehicle;
			GetVehicleWithinDistance(playerid, playerx, playery, playerz, 25.0, vehicle);
			if(IsVehicleRcTram(vehicle))
			{
			    PutPlayerInVehicle(playerid, vehicle, 0);
			}
		}
		else
		{
			if(IsVehicleRcTram(pvehicleid[playerid]) || pmodelid[playerid] == RC_CAM)
			{
		   	 	GetPlayerPos(playerid, playerx, playery, playerz);
	    		SetPlayerPos(playerid, playerx+0.5, playery, playerz+5.0);
				SetCameraBehindPlayer(playerid);
			}
		}
		return 1;
	}

	else if(newkeys & KEY_FIRE)
	{

		if((cow[playerid] != INVALID_OBJECT_ID)) //cows go boom
		{
		    if(!godmode[playerid])
			{
		    	GetPlayerPos(playerid, playerx, playery, playerz);
				GetXYInFrontOfPlayer(playerid, playerx, playery, 20);
				foreach(Player,i)
				{
					if(godmode[i] && IsPlayerInRangeOfPoint(i,4,playerx,playery,playerz))
					{
						return GameTextForPlayer(playerid,"~w~TARGET IN ~r~/GOD ~w~MODE",2000,3);
					}
				}
				CreateExplosion(playerx, playery, playerz, 12, 2);
			}
		}
	}

	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
    new vehicleide = GetVehicleModel(vehicleid);
    new modok = islegalcarmod(vehicleide, componentid);
    if (!modok)
	{
        Ban(playerid);
        BanEx(playerid,"BANNED - illegal car mods - Appeal at madoshi.net/samp");
        format(string128,sizeof(string128),"[ban] Banned [%i]%s for trying to crash players with illegal car mods",playerid,pname[playerid]);
		printf(string128);
		SendClientMessageToAll(COLOR_YELLOW,string128);
  		#if defined IRC_ECHO
	    IRC_GroupSay(groupID, IRC_CHANNEL, string128);
	    #endif
		
    }
    return 1;
}


public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    #pragma unused playerid

/*
    foreach(Player,i)
    {
        if(pvehicleid[i] == vehicleid && pstate[i] == PLAYER_STATE_DRIVER && godmode[i]) SetVehicleHealth(vehicleid,9999.0);
    }
*/
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(IsValidObject(vobject[vehicleid]) && pstate[playerid] == PLAYER_STATE_DRIVER)
	{
		DestroyObject(vobject[vehicleid]);
		vobject[vehicleid] = INVALID_OBJECT_ID;
	}
	if(VehicleLockData[vehicleid])
	{
		VehicleLockData[vehicleid] = false;
		foreach(Player,i)
		{
			SetVehicleParamsForPlayer(vehicleid,i,false,false);
		}
	}
	foreach(Player,i) if(Spec[i][SpectateID] == playerid  && Spec[i][Spectating]) { TogglePlayerSpectating(i,false); SetPlayerInterior(i,GetPlayerInterior(playerid)); TogglePlayerSpectating(i,true); PlayerSpectatePlayer(i,playerid); }

	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid)
{
	foreach(Player,i)
	{
	    if(vehicleid == playercar[i] && i != playerid && reserve[i] || frozen[playerid] == 1)
	    {
	        GetPlayerPos(playerid,playerx,playery,playerz);
	        SetPlayerPos(playerid,playerx,playery,playerz);
	        if (frozen[playerid] == 0) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} This vehicle is reserved by its creator. You may not enter the vehicle.");
            SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} No. Nice try.");
		}
	}

	return 1;
}

/*

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat)
{
	new
	    Float: fVehicle[3];

	GetVehiclePos(vehicleid, fVehicle[0], fVehicle[1], fVehicle[2]);

	if(!IsPlayerInRangeOfPoint(playerid, 20, fVehicle[0], fVehicle[1], fVehicle[2]))
	{
		new playerip[16];
		GetPlayerIp(playerid,playerip,sizeof(playerip));
		format(string128,sizeof(string128),"BAD VEHICLE UPDATE from %i:%s Player:%f %f %f Veh:%f %f %f IP:%s",playerid,pname[playerid],playerx,playery,playerz,fVehicle[0],fVehicle[1],fVehicle[2],playerip);
		printf(string128);
		foreach(Player,i)
		{
		    if(IsPlayerAdmin(i))
		    {
		        SendClientMessage(i,COLOR_SYSTEM,string128);
		    }
		}
	    return;
	}
}
*/

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid,modelid;
	pstate[playerid] = newstate;
	vehicleid = GetPlayerVehicleID(playerid);
	DestroyNeon(playerid);
	modelid = GetVehicleModel(vehicleid);
	if(pmodelid[playerid] == 548 && attached[playerid] != INVALID_VEHICLE_ID) return 1;
	switch(newstate)
	{
	    case 1,7,8://onfoot wasted spawned
		{
//			horn[playerid] = 0;
			DestroyObject(magnet[playerid]);
			PlayerTextDrawHide(playerid,VehModel[playerid]);
			if(IsValidObject(vobject[vehicleid]) && oldstate == PLAYER_STATE_DRIVER)
			{

				DestroyObject(vobject[vehicleid]);
				vobject[vehicleid] = INVALID_OBJECT_ID;
			}
		    HideVehTD(playerid);
   	   		if(newstate == 1)
  			{
	  			if(!gTeam[playerid]) SetPlayerWorldBounds(playerid, 9999.00, -9999.00, 9999.00, -9999.00);
   	   		    if(oldstate == 2 && pvehicleid[playerid] != INVALID_VEHICLE_ID)
  				{
		   			foreach(Player,i) SetVehicleParamsForPlayer(pvehicleid[playerid],i,false,false);
				}
			}
		    badcar[playerid] = false;
		    cantrace[playerid] = false;
		    aircraft[playerid] = false;
		    pvehicleid[playerid] = INVALID_VEHICLE_ID;
			pmodelid[playerid] = 0;
			return 1;
		}
		case 2: //driver
		{
	        #if defined TEXTDRAWS
		    if(hassnos[playerid])
		    {
				TextDrawShowForPlayer(playerid,SnosOn);
		    }
		    else TextDrawShowForPlayer(playerid,SnosOff);
		    #endif //textdraws
		    
			HideVehTD(playerid);
			pvehicleid[playerid] = vehicleid;
			pmodelid[playerid] = modelid;
			format(string32, sizeof(string32), "~g~%s ~w~%i", vehName[pmodelid[playerid]-400],pmodelid[playerid]);
		//	GameTextForPlayer(playerid, string32, 4000, 1);
			format(string128,sizeof(string128),"~w~Veh Model: ~y~%s~w~",string32);
		    PlayerTextDrawSetString(playerid,VehModel[playerid],string128);
			PlayerTextDrawShow(playerid,VehModel[playerid]);
			foreach(Player,i)
		    {
		        if(vehicleid == playercar[i] && i != playerid)
		        {
		            format(string128,sizeof(string128),"[VEHICLE] {FFFF00}%s {C0C0C0}has entered your vehicle as DRIVER!",pname[playerid]);
		            SendClientMessage(i,COLOR_SYSTEM,string128);
		        }

		    }
			switch(modelid)
			{
				case 417,465,469,487,488,497,548,563,460,476,511,512,513,519,539,553,577,592,593: aircraft[playerid] = true;
				case vHUNTER,vHYDRA,vRHINO,vSEASPARROW: badcar[playerid] = true;
				case 523,427,490,528,596,598,597,599,601: policecar[playerid] = true;
				case 416,407,544: firecar[playerid] = true;
			}
			if(!aircraft[playerid] && !badcar[playerid])
			{
				if(strlen(vplate[vehicleid]) > 0)
				{
					SetVehicleNumberPlate(vehicleid,vplate[vehicleid]);
	//				SetPlayerPos(playerid,0,0,8);
	//				PutPlayerInVehicle(playerid,veh,0);
				}
			}
			if(badcar[playerid])
			{
			    if(godmode[playerid])
			    {
			        godmode[playerid] = 0;
			        ShowGodTD(playerid);
			    }
			}
			if(modelid == 525) GameTextForPlayer(playerid,"Press ACTION or /tow~n~to tow any vehicle",5000,3);
            if(modelid == 548)
			{
				GameTextForPlayer(playerid,"~y~Type ~r~/magnet~n~~y~For Skycrane",4000,3);
				SendClientMessage(playerid,COLOR_SYSTEM,"[VEHICLE] {FFFF00}Type /magnet to activate CargoBob Skycrane!");
			}
			if(aircraft[playerid])
			{
				cantrace[playerid] = true;
			}

			if (policecar[playerid] == true)
			{
                SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Type {FFFFFF}/radio{C0C0C0} and choose a Police department to listen to REAL police radio audio");
			}

			if (firecar[playerid])
			{
                SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Type {FFFFFF}/radio{C0C0C0} and choose a Fire/EMS location to listen to REAL emergency radio audio");
			}

			cancount[playerid] = true;
			if(IsInModVehicle(playerid)) AddNosToVehicle(playerid,pvehicleid[playerid]);
	        #if defined TEXTDRAWS
			switch(key2[playerid])
			{
				case KEY2_UNBOUND: TextDrawShowForPlayer(playerid, Veh);
				case KEY2_FLIP: TextDrawShowForPlayer(playerid, VehAutoFlip);
	            case KEY2_RAMP: TextDrawShowForPlayer(playerid, VehPutRamp);
				case KEY2_SKULLS: TextDrawShowForPlayer(playerid, VehPutSkulls);
				case KEY2_STOP: TextDrawShowForPlayer(playerid, VehAutoStop);
			}
			#endif //textdraws
//			new str[32];
			
			SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{FFFFFF}/tune{C0C0C0} to tune car, {FFFFFF}/fix{C0C0C0} to repair, {FFFFFF}/snos{C0C0C0} for super-NOS, {FFFFFF}/neon{C0C0C0} for adding neon, {FFFFFF}/trailer{C0C0C0} to add a trailer, or press the {FFFFFF}2 key{C0C0C0} for Fix+NOS refill");
		   	return 1;
		}
	    case 3: // passenger
		{
		    horn[playerid] = 0;
	    	pvehicleid[playerid] = vehicleid;
			pmodelid[playerid] = modelid;
			foreach(Player,i)
		    {
		        if(vehicleid == playercar[i] && i != playerid)
		        {
		            format(string128,sizeof(string128),"[VEHICLE] {FFFF00}%s {C0C0C0}has entered your vehicle as PASSENGER! Seat: %i",pname[playerid],GetPlayerVehicleSeat(playerid));
		            SendClientMessage(i,COLOR_SYSTEM,string128);
		        }

		    }
			switch(modelid)
			{
				case 417,465,469,487,488,497,548,563,460,476,511,512,513,519,539,553,577,592,593: aircraft[playerid] = true;
				case vHUNTER,vHYDRA,vRHINO,vSEASPARROW: badcar[playerid] = true;
				case 523,427,490,528,596,598,597,599,601: policecar[playerid] = true;
				case 416,407,544: firecar[playerid] = true;
			}
			if(aircraft[playerid])
			{
                SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Type {FFFFFF}/radio{C0C0C0} and choose an airport to listen to REAL air-traffic-control radio audio");
				new rand = random(sizeof(atcSounds));
				PlayerPlaySound(playerid, atcSounds[rand],0.0,0.0,0.0);
			}
			else if (policecar[playerid])
			{

			}
			cantrace[playerid] = true;
			new str[32];
			format(str, sizeof(str), "~g~%s ~w~%i", vehName[pmodelid[playerid]-400],pmodelid[playerid]);
			GameTextForPlayer(playerid, str, 3000, 1);
			return 1;
		}
	}
	return 1;
}

public OnVehicleDeath(vehicleid)
{
	if(IsValidObject(vobject[vehicleid]))
	{
		DestroyObject(vobject[vehicleid]);
		vobject[vehicleid] = INVALID_OBJECT_ID;
	}
    return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	if(IsValidObject(vobject[vehicleid])) AttachObjectToVehicle(vobject[vehicleid],vehicleid,0.0,0.0,-0.5,0.0,0.0,0.0);
	if(VehicleLockData[vehicleid]) SetVehicleParamsForPlayer(vehicleid,forplayerid,false,true);
	else SetVehicleParamsForPlayer(vehicleid,forplayerid,false,false);
	/*
	if(!strlen(vplate[vehicleid]))
	{
		format(string32,sizeof(string32),"Model:%i",GetVehicleModel(vehicleid));
		SetVehicleNumberPlate(vehicleid,string32);
	}
	else
	{
	    SetVehicleNumberPlate(vehicleid,vplate[vehicleid]);
	}
	*/
	return 1;
}

forward IsComplexVehicle(vehicleid);
public IsComplexVehicle(vehicleid)
{
	new modmodel = GetVehicleModel(vehicleid);
	switch(modmodel)
	{
		case 425,432,520,447,430,590,570,569,538,537,449,611,610,608,607,606,591,584,450,435:
		{
		 	return true; // there are complex vehicles (vehicles w/guns or 2nd function..or generally odd behaving vehicles)
		}
	}
	return false;
}
forward IsInModVehicle(playerid);
public IsInModVehicle(playerid)
{
	if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{
		switch(pmodelid[playerid])
		{
			case 417,425,430,435,441,446,447,448,449,450,452,453,454,460,461,462,463,464,465,468,469,472,473,476,481,484,487,488,493,497,501,509,510,511,512,513,519,520,521,522,523,537,538,539,548,553,563,564,569,570,577,581,584,586,590,591,592,593,594,595,606,607,608,610,611:
			{
			    return false; // these are non moddable vehicles
			}
			default: return true;
		}
	}
    return false;
}
forward AddNosToVehicle(playerid,nosid);
public AddNosToVehicle(playerid,nosid)
{
	if(cantrace[playerid] == true) return 1;
	if(IsInModVehicle(playerid))
	{
		AddVehicleComponent(nosid, 1010);
		PlayerPlaySound(playerid, 1133, 0, 0, 0);
	}
	return 1;
}

forward AddHydroToVehicle(playerid,hydroid);
public AddHydroToVehicle(playerid,hydroid)
{
	if(cantrace[playerid] == true) return 1;
 	if(pstate[playerid] == PLAYER_STATE_DRIVER && IsInModVehicle(playerid))
 	{
		AddVehicleComponent(hydroid, 1087);
		PlayerPlaySound(playerid, 1133, 0, 0, 0);
	}
	return 1;
}

LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    gPlayerUsingLoopingAnim[playerid] = 1;
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
    animation[playerid]++;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
#if defined VEH_THUMBNAILS
	if(GetPVarInt(playerid, "vspawner_active") == 0) return 0;

	// Handle: They cancelled (with ESC)
	if(clickedid == Text:INVALID_TEXT_DRAW)
	{
        DestroySelectionMenu(playerid);
        SetPVarInt(playerid, "vspawner_active", 0);
        PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
        return 1;
	}
#endif
    if(clickedid == SnosOn || clickedid == SnosOff)
    {
        dcmd_snos(playerid,params2);
    }
    else if(clickedid == God || clickedid == NoGod)
    {
        dcmd_god(playerid,params2);
    }
    else if(clickedid == JumpOn || clickedid == JumpOff)
    {
        dcmd_jump(playerid,params2);
    }
    return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
#if defined TOYS
	switch(dialogid)
	{
		case DIALOG_ATTACH_INDEX_SELECTION:
        {
            if(response)
            {
                if(IsPlayerAttachedObjectSlotUsed(playerid, listitem))
                {
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_EDITREPLACE, DIALOG_STYLE_MSGBOX, \
                    "{FF0000}Attachment Modification", "Do you wish to edit the attachment in that slot, or delete it?", "Edit", "Delete");
                }
                else
                {
                    new string[4000+1];
                    for(new x;x<sizeof(AttachmentObjects);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentObjects[x][attachname]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_MODEL_SELECTION, DIALOG_STYLE_LIST, \
                    "{FF0000}Attachment Modification - Model Selection", string, "Select", "Cancel");
                }
                SetPVarInt(playerid, "AttachmentIndexSel", listitem);
            }
            return 1;
        }
        case DIALOG_ATTACH_EDITREPLACE:
        {
            if(response) EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            else RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_MODEL_SELECTION:
        {
            if(response)
            {
                if(GetPVarInt(playerid, "AttachmentUsed") == 1) EditAttachedObject(playerid, listitem);
                else
                {
                    SetPVarInt(playerid, "AttachmentModelSel", AttachmentObjects[listitem][attachmodel]);
                    new string[256+1];
                    for(new x;x<sizeof(AttachmentBones);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentBones[x]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_BONE_SELECTION, DIALOG_STYLE_LIST, \
                    "{FF0000}Attachment Modification - Bone Selection", string, "Select", "Cancel");
                }
            }
            else DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_BONE_SELECTION:
        {
            if(response)
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"), GetPVarInt(playerid, "AttachmentModelSel"), listitem+1);
                EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
                SendClientMessage(playerid, 0xFFFFFFFF, "Hint: Use {FFFF00}~k~~PED_SPRINT~{FFFFFF} to look around.");
            }
            DeletePVar(playerid, "AttachmentIndexSel");
            DeletePVar(playerid, "AttachmentModelSel");
            return 1;
        }
	}
#endif //toys
#if defined TUNE
	if(dialogid == TUNEDIALOGID) if(response)
	{
	    for(new i=0;i<=ccount[playerid];i++)
	    {
			if(listitem == i)
			{
				if(IsVehicleUpgradeCompatible(GetVehicleModel(GetPlayerVehicleID(playerid)),componentsid[playerid][i])) //just a verification
				{
					AddVehicleComponent(GetPlayerVehicleID(playerid), componentsid[playerid][i]);
	  				new string[128];
	  				format(string, sizeof(string),":: Vehicle successfully tuned with component {FF6400}%s", GetComponentName(componentsid[playerid][i]));
					SendClientMessage(playerid,COLOR_YELLOW,string);
					return dcmd_tune(playerid, " ");
				}
				else SendClientMessage(playerid,COLOR_RED,"[ERROR:] Component is not compatible with your current vehicle model!");
			}
		}
	}

#endif
	if(dialogid == D_COMMANDS1 && response)
	{
 	     return ShowPlayerDialog(playerid, D_COMMANDS2, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/casino{FFFFFF}-casino teleports\n{FFFF00}/cc{FFFFFF}-car color. uses 2 colors (primary and secondary). Usage: '/cc 23 178'	\n{FFFF00}/cctv{FFFFFF}-Activate movable CCTV camera system located at MANY locations!	\n{FFFF00}/chicken{FFFFFF}-be a giant chicken\n{FFFF00}/chiliad{FFFFFF}-quick-tele to Mt Chiliad\n{FFFF00}/cities{FFFFFF}-list all inner-city teleports","Next","Exit");
	}
	if(dialogid == D_COMMANDS2 && response)
	{
		ShowPlayerDialog(playerid, D_COMMANDS3, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","	\n{FFFF00}/color	{FFFFFF}-change vechile color\n{FFFF00}/count{FFFFFF}-3-2-1 countdown for players in range\n{FFFF00}/cow{FFFFFF}-be a giant cow\n{FFFF00}/credits{FFFFFF}-server credits (who did what etc)\n{FFFF00}/day{FFFFFF}-make it daytime\n{FFFF00}/daynight{FFFFFF}-cycle day/night with in-game time (normal clock progression)\n{FFFF00}/dcar{FFFFFF}-destroy your spawned vehicle","Next","Exit");
	}
	if(dialogid == D_COMMANDS3 && response)
	{
		ShowPlayerDialog(playerid, D_COMMANDS4, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/dm{FFFFFF}-list all DM arenas/zones (minigun, RPG, hydra, War, etc)\n{FFFF00}/drunk{FFFFFF}-set your drunkeness level\n{FFFF00}/e(ject){FFFFFF}-type /e to eject from vehicle. can be bound to 'N' key\n{FFFF00}/fastcars{FFFFFF}-vehicle spawn menu, all fast cars\n{FFFF00}/fight	{FFFFFF}-change fighting style\n{FFFF00}/findcar{FFFFFF}-teleport to your vehicles location","Next","Exit");
	}
	if(dialogid == D_COMMANDS4 && response)
	{
		ShowPlayerDialog(playerid, D_COMMANDS5, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/fireme{FFFFFF}-light yourself on (harmless) fire\n{FFFF00}/flip{FFFFFF}-flip vehicle over\n{FFFF00}/flymode{FFFFFF}-no-clip camera, go look at anywhere!\n{FFFF00}/gang{FFFFFF}-join gang DM team (family, ballas, etc)\n{FFFF00}/getcar{FFFFFF}-teleport your car to you	\n{FFFF00}/glasses{FFFFFF}-put on some glasses (menu)","Next","Exit");
	}
	if(dialogid == D_COMMANDS5 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS6, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/god{FFFFFF}-enable/disable godmode (invuln) CANCELS if you harm someone\n{FFFF00}/gun{FFFFFF}-open gun menu. choose from any weapon , unlimited ammo...free\n{FFFF00}/gunship{FFFFFF}-mount rocket launchers on vehicle. press your NOS key to fire\n{FFFF00}/helmet{FFFFFF}-wear a helmet\n{FFFF00}/horn{FFFFFF}-air horns for extra attention","Next","Exit");
	}
	if(dialogid == D_COMMANDS6 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS7, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/hsmoke{FFFFFF}-have a smoke break\n{FFFF00}/ignore{FFFFFF}-ignore a player\n{FFFF00}/interiors{FFFFFF}-list ALL in-game interiors\n{FFFF00}/jetpack{FFFFFF}-enable jetpack (aka 'rocketman')\n{FFFF00}/join{FFFFFF}-join a race	\n{FFFF00}/jump{FFFFFF}-enable bunny hop and vehicle up/down warping (kinda like airbrake)\n","Next","Exit");
	}
	if(dialogid == D_COMMANDS7 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS8, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","{FFFF00}/junk{FFFFFF}-junk your vehicle (visual damage only, pops all tires)\n{FFFF00}/key2{FFFFFF}-change action bound to the '2' key (default NOS+fix)\n{FFFF00}/keyn{FFFFFF}-change action bound to the 'N' key (default vehicle insta-stop)\n{FFFF00}/keyy{FFFFFF}-change action bound to the 'Y' key (default All teleport menus)\n{FFFF00}/kill{FFFFFF}-commit suicide	\n","Next","Exit");
	}
	if(dialogid == D_COMMANDS8 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS9, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","{FFFF00}/launch{FFFFFF}-launch self/vehicle high into air\n{FFFF00}/leave{FFFFFF}-leave a DM area\n{FFFF00}/lock{FFFFFF}-lock your vehicle doors\n{FFFF00}/login{FFFFFF}-log in to your registered account\n{FFFF00}/lp{FFFFFF}-teleport to last position save with /sp\n{FFFF00}/ls{FFFFFF}-teleport Los Santos downtown\n{FFFF00}/lv{FFFFFF}-teleport to Las Venturas downtown","Next","Exit");
	}
	if(dialogid == D_COMMANDS9 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS10, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/magnet{FFFFFF}-activate vehicle magnet on cargobob helicopter (skycrane)\n{FFFF00}/menu{FFFFFF}-open main menu	\n{FFFF00}/neon{FFFFFF}-activate neon lights under vehicle\n{FFFF00}/night{FFFFFF}-make it night\n{FFFF00}/nos{FFFFFF}-install NOS on vehicle\n{FFFF00}/nrg{FFFFFF}-quick-spawn an NRG\n{FFFF00}/paintj{FFFFFF}-vehicle paint job","Next","Exit");
	}
	if(dialogid == D_COMMANDS10 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS11, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/pc{FFFFFF}-parachute (handy when falling)\n{FFFF00}/pcolor{FFFFFF}-player color (changes player chat,icon,name color)\n{FFFF00}/piss{FFFFFF}-take a piss\n{FFFF00}/plane{FFFFFF}-spawn any plane (opens menu)	\n{FFFF00}/pm{FFFFFF}-send private message\n{FFFF00}/porn{FFFFFF}- porn\n{FFFF00}/prohouse{FFFFFF}-teleport to mansion for [PRO] players","Next","Exit");
	}
	if(dialogid == D_COMMANDS11 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS12, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/propertyhelp{FFFFFF}-list al property commands\n{FFFF00}/pskin	{FFFFFF}-change player skin\n{FFFF00}/putmine{FFFFFF}-place bouncy stunt mine\n{FFFF00}/putramp{FFFFFF}-place stunt ramp in front of you\n{FFFF00}/putskulls{FFFFFF}-place vehicle slingshot (velocity) dual-skulls icon\n{FFFF00}/radio	{FFFFFF}-open radio (audio stream) system. choose music/audio or paste own URL","Next","Exit");
	}
	if(dialogid == D_COMMANDS12 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS13, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/rain{FFFFFF}-make it rain!\n{FFFF00}/register{FFFFFF}-register your account. usage '/register password' (pls dont really use 'password')\n{FFFF00}/reserve{FFFFFF}-complete lockdown of player vehicle\n{FFFF00}/rules	{FFFFFF}-show servers player conduct rules\n{FFFF00}/saveskin{FFFFFF}-save current skinid to player file. will autoset skin on /login\n","Next","Exit");
	}
	if(dialogid == D_COMMANDS13 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS14, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","{FFFF00}/sf{FFFFFF}-teleport to San Fiero airport\n{FFFF00}/shamal{FFFFFF}-enter shamal interior\n{FFFF00}/skin{FFFFFF}-change player skin\n{FFFF00}/skyway{FFFFFF}-jump on sky-highway\n{FFFF00}/snos{FFFFFF}-enable SUPER-NOS system. Tap/spam NOS key to hit speeds over 1000mph\n{FFFF00}/sp{FFFFFF}-save current position. used in conjunction with /lp (tele to last postion saved wtih /sp)","Next","Exit");
	}
	if(dialogid == D_COMMANDS14 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS15, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/spawn{FFFFFF}-set respawn area\n{FFFF00}/stadiums{FFFFFF}-list all stadium interior teleports\n{FFFF00}/stats{FFFFFF}-get player in-game stats\n{FFFF00}/stop{FFFFFF}-instant-stop vehicle\n{FFFF00}/t{FFFFFF}-list all teleports (menu based)\n{FFFF00}/tele{FFFFFF}-list all teleports\n{FFFF00}/time{FFFFFF}-change current time","Next","Exit");
	}
	if(dialogid == D_COMMANDS15 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS16, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/tow{FFFFFF}-tow vehicle behind you (any vehicle can tow any vehicle)\n{FFFF00}/toys{FFFFFF}-[PRO] feature. attach objects to your body\n{FFFF00}/trailer{FFFFFF}-spawn a trailer. players can spawn 1 vehicle and 1 trailer at same time\n{FFFF00}/trucker{FFFFFF}-teleport to truck stop (big rigs, trailers, etc)\n{FFFF00}/trucks{FFFFFF}-open vehicle spawn menu, shows only trucks","Next","Exit");
	}
	if(dialogid == D_COMMANDS16 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS17, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","\n{FFFF00}/tune{FFFFFF}-add vehicle modificaitons (spoliers, graphics, neon, hydros, etc etc)\n{FFFF00}/unlock{FFFFFF}-unlock your vehicles doors\n{FFFF00}/v{FFFFFF}-spawn any vehicle modelid\n{FFFF00}/vr{FFFFFF}-vehicle repair\n{FFFF00}/weather{FFFFFF}-change weather\n{FFFF00}/wheels{FFFFFF}-change vehicle wheels\n{FFFF00}/wine{FFFFFF}-drink a bottle of wine\n","Next","Exit");
	}
	if(dialogid == D_COMMANDS17 && response)
	{
		return ShowPlayerDialog(playerid, D_COMMANDS18, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","{FFFF00}/wrc{FFFFFF}-spawn Subaru Impreza WRC rally car (well...GTA version anyways 'sultan')\n{FFFF00}/xmas{FFFFFF}-teleport to server christmas tree area\n"," ","Exit");
	}
    else if(dialogid == D_SOUNDS && response)
	{
	    new sound;
	    switch(listitem)
	    {
	        case 0: sound = 4001;
	        case 1: sound = 4803;
	        case 2: sound = 4804;
	        case 3: sound = 5000;
	        case 4: sound = 5003;
	        case 5: sound = 5406;
	        case 6: sound = 5848;
	        case 7: sound = 7001;
	        case 8: sound = 7005;
	        case 9: sound = 7008;
	        case 10: sound = 7009;
	        case 11: sound = 7007;
	        case 12: sound = 7011;
	        case 13: sound = 7023;
	        case 14: sound = 7208;
	        case 15: sound = 7400;
	        case 16: sound = 7410;
	        case 17: sound = 7601;
	        case 18: sound = 7607;
	        case 19: sound = 7810;
	        case 20: sound = 7816;
	        case 21: sound = 7824;
	        case 22: dcmd_s2(playerid,params2);
	    }
	    GetPlayerPos(playerid,playerx,playery,playerz);
	    foreach(Player,i)
	    {
	        if(!quiet[i]) PlayerPlaySound(i,sound,playerx,playery,playerz);
	    }
		return 1;
	}
// 7834,7837,7840,7841,7852,7851,7857,7887,7891,8010,8017,8411,8624,8622,8656,8738,8830,
// 9020,9402,9437,9613,9624,9639,10402,10408,10600,10607,10801,dcmd_s
	else if(dialogid == D_SOUNDS2 && response)
	{
	    new sound;
	    switch(listitem)
	    {
	        case 0: sound = 7834;
	        case 1: sound = 7837;
	        case 2: sound = 7840;
	        case 3: sound = 7841;
	        case 4: sound = 7852;
	        case 5: sound = 7851;
	        case 6: sound = 7857;
	        case 7: sound = 7887;
	        case 8: sound = 7891;
	        case 9: sound = 8010;
	        case 10: sound = 8017;
	        case 11: sound = 8411;
	        case 12: sound = 8624;
	        case 13: sound = 8622;
	        case 14: sound = 8656;
	        case 15: sound = 8738;
	        case 16: sound = 8830;
	        case 17: sound = 9020;
	        case 18: sound = 9402;
	        case 19: sound = 9437;
	        case 20: sound = 9613;
	        case 21: sound = 9624;
	        case 22: sound = 9639;
	        case 23: sound = 10402;
	        case 24: sound = 10408;
	        case 25: sound = 10600;
	        case 26: sound = 10607;
	        case 27: sound = 10801;
	        case 28: dcmd_s(playerid,params2);
	    }
	    GetPlayerPos(playerid,playerx,playery,playerz);
	    foreach(Player,i)
	    {
	        if(!quiet[i]) PlayerPlaySound(i,sound,playerx,playery,playerz);
	    }
		return 1;
	}
	else if(dialogid == D_HELP && response)
	{
	    if(response) dcmd_cmd(playerid,params2);
		return 1;
	}
	else if(dialogid == D_HELP2)
	{
	    if(!response) dcmd_menu(playerid,params2);
		return 1;
	}
	else if(dialogid == D_MENU && response)
	{
	    switch(listitem)
	    {
	        case 0: dcmd_tele(playerid,params2);
	        case 1: dcmd_dm(playerid,params2);
	        case 2: dcmd_v(playerid,params2);
	        case 3: dcmd_caroptions(playerid,params2);
	        case 4: dcmd_radio(playerid,params2);
	        case 5: dcmd_gun(playerid,params2);
	        case 6: dcmd_spawn(playerid,params2);
	        case 7: dcmd_key2(playerid,params2);
	        case 8: dcmd_keyy(playerid,params2);
	        case 9: dcmd_keyn(playerid,params2);
	        case 10: dcmd_weather(playerid,params2);
	        case 11: dcmd_pcolor(playerid,params2);
	        case 12: dcmd_cmd(playerid,params2);
	        case 13: dcmd_help(playerid,params2);
	        case 14: dcmd_flymode(playerid,params2);
	    
	    }
		return 1;
	}
	else if(dialogid == D_CAROPTIONS && response)
//"Repair Vehicle\nActivate SNOS\nActivate Bunny-Hop\nTune Car\nAdd Neon\nAdd Train Horn\nChange Wheels\nChange Car Color\nChange Paintjob\nAdd Gunship\nJunk The Car","Select","Close");
	{
	    switch(listitem)
	    {
	        case 0: dcmd_fix(playerid,params2);
	        case 1: dcmd_snos(playerid,params2);
	        case 2: dcmd_jump(playerid,params2);
	        case 3: dcmd_tune(playerid,params2);
	        case 4: dcmd_neon(playerid,params2);
	        case 5: dcmd_horn(playerid,params2);
	        case 6: dcmd_wheels(playerid,params2);
	        case 7: dcmd_color(playerid,params2);
	        case 8: dcmd_paintj(playerid,params2);
	        case 9: dcmd_gunship(playerid,params2);
	        case 10: dcmd_junk(playerid,params2);
	    }
		return 1;
	}
	else if(dialogid == D_RADIO && response)
	{
	    switch(listitem)
	    {
	        case 0:
					{
						StopAudioStreamForPlayer(playerid);
						radio[playerid] = 0;
						ShowRadioTD(playerid);
						return SendClientMessage(playerid,COLOR_YELLOW,"You may have to exit/re-enter vehicle for stereo to work again");
					}
			case 1: ShowPlayerDialog(playerid, D_RADIO_PINPUT,DIALOG_STYLE_INPUT,"Enter stream URL","If you hear nothing, its a bad URL!","Play URL","Cancel");
		    case 2: ShowPlayerDialog(playerid, D_RADIOPOLICE, DIALOG_STYLE_LIST, "Choose Police Radio","Los Angeles PD\nLas Vegas PD\nSan Francisco PD\nMaine PD\nNew York PD\nNew York Fire/EMS\nChicago PD\nAtlanta PD\nHouston PD\nMiami PD\nToronto PD\nAUS Victoria PD","Listen","Exit");
            case 3: ShowPlayerDialog(playerid, D_RADIOHAM, DIALOG_STYLE_LIST, "Choose Amateur Radio","GB7OK/UK\nUS Hurricane Net\nKB2FAF/NY\nDSTAR Reflector\nK4PIP Reflector\nLinked Repeater System","Listen","Exit");
            case 4: ShowPlayerDialog(playerid, D_RADIOAIR, DIALOG_STYLE_LIST, "Choose Airport Radio","Czech Brno-Turany\nNew York JFK\nSan Francisco SFO ","Listen","Exit");
            case 5: ShowPlayerDialog(playerid, D_RADIOMUSIC, DIALOG_STYLE_LIST, "Choose Music Radio",".977 Hitz\n90s Alternative\nTop 40\nDub Step\nHip Hop\nUnderground Rap\nRock and Roll\nOpera\nClassical\nBlues\nTechno\nTrip Hop\nBollywood\nVideo Game\nMovie\nMetal\nNews\n50s and 60s Oldies\nThe 70s\nThe 80s\nCrazyBob's CnR SAMP Radio\nBeat Basement ","Listen","Exit");
	    }
		return 1;
	}
	else if (dialogid == D_RADIO_PINPUT && response)
	{
		if(strlen(inputtext) > 0)
		{
			PlayAudioStreamForPlayer(playerid,inputtext);
		}
		else
		{
			SendClientMessage(playerid,0xFFFFFFAA,"Your input was too short.");
		}
	    
	}
	else if (dialogid == D_PLATE && response)
	{
		if(strlen(inputtext) > 0 && strlen(inputtext) < 33)
		{
		    new veh = GetPlayerVehicleID(playerid);
//		    new prevworld = GetPlayerVirtualWorld(playerid); // COULD CAUSE BUGS
			SetVehicleNumberPlate(veh,inputtext);
//			SetVehicleVirtualWorld(veh,666);
//			SetVehicleVirtualWorld(veh,prevworld);
			strmid(vplate[veh], inputtext, 0, 31,32);

		}
		else
		{
			SendClientMessage(playerid,0xFFFFFFAA,"Your input must be more than 0 and less than 32, letters and numbers ONLY (a-z 0-9)");
		}

	}
	else if(dialogid == D_RADIOPOLICE && response)
	{
	    switch(listitem)
	    {
		    // D_RADIOPOLICE
	        case 0: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/3711/0-5403112148.m3u"); //LA PD
	        case 1: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/672/0-5400035944.m3u"); //LV PD
	        case 2: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/2765/0-5400035720.m3u"); //SF PD
	        case 3: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/561/0-5400036672.m3u"); // Maine PD
	        case 4: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/12524/0-5400232456.m3u"); // NYPD Brooklyn
	        case 5: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/9358/0-5406894824.m3u"); // NYFD / EMS
	        case 6: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/763/0-5400233396.m3u"); // Chicago PD
	        case 7: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/3572/0-5400233164.m3u"); // Atlanta PD
	        case 8: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/9098/0-5400234080.m3u"); // Houston PD
	        case 9: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/2964/0-5400233660.m3u"); // Miami PD
	        case 10: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/12607/0-5400231076.m3u"); //Toronto PD and EMS
	        case 11: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/7333/0-5400231448.m3u"); // AUS Victoria Police
	    }
		radio[playerid] = 1;
	    ShowRadioTD(playerid);
		return 1;
	}
	else if(dialogid == D_RADIOHAM && response)
	{
	    switch(listitem)
	    {
	        case 0: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/5284/0-5406885148.m3u"); // GB7OK GB3OK UK
	        case 1: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/9559/0-5406885120.m3u"); // US hurricane net
	        case 2: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/11274/0-5406885260.m3u"); // kb2faf NY
	        case 3: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/9420/0-5406885448.m3u"); // dstar reflector
	        case 4: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/6835/0-5406885328.m3u"); // kp4ip
	        case 5: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/8468/487288-5406945172.m3u"); // PAPS repeater
	    }
	    radio[playerid] = 1;
	    ShowRadioTD(playerid);
		return 1;
	}
	else if(dialogid == D_RADIOAIR && response)
	{
	    switch(listitem)
	    {
	        case 0: PlayAudioStreamForPlayer(playerid, "http://www.radioreference.com/scripts/playlists/1/12255/0-5400232432.m3u"); // Czech Brno-Turany Airport
	        case 1: PlayAudioStreamForPlayer(playerid, "http://www.liveatc.net/play/zbw_zny_jfk.pls"); // nyc jfk approach
	        case 2: PlayAudioStreamForPlayer(playerid, "http://www.liveatc.net/play/ksfo_twr.pls"); // sf sfo approach
	    }
	    radio[playerid] = 1;
	    ShowRadioTD(playerid);
		return 1;
	}
	else if(dialogid == D_RADIOMUSIC && response)
	{ // 
	    switch(listitem) //music stations
	    {
	        case 0: PlayAudioStreamForPlayer(playerid,"http://7609.live.streamtheworld.com:80/977_HITS_SC"); //.977 hitz
	        case 1: PlayAudioStreamForPlayer(playerid, "http://7639.live.streamtheworld.com:80/977_ALTERN_SC"); // alternative
	        case 2: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=38370"); // top 40
			case 3: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=319038"); //dubstep
			case 4: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=71829"); // hip-hop / rap
			case 5: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=9054"); // underground rap
			case 6: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=29469"); //rock
			case 7: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=1269951"); //opera
			case 8: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=403280"); //classical
			case 9: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=205177"); //blues
			
			case 10: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=1377200"); // techno
			case 11: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=82343"); //trip hop
			case 12: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=817801"); //bollywood
			case 13: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=15706"); //video game music
			case 14: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=5266"); //movie soundtracks
			case 15: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=318248"); //metal
			case 16: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=1279013"); //world news
			case 17: PlayAudioStreamForPlayer(playerid,"http://7659.live.streamtheworld.com:80/977_OLDIES_SC"); //50s 60s oldies
			case 18: PlayAudioStreamForPlayer(playerid,"http://7649.live.streamtheworld.com:80/977_CLASSROCK_SC"); //70s
			case 19: PlayAudioStreamForPlayer(playerid,"http://7649.live.streamtheworld.com:80/977_80_SC"); //80s
			case 20: PlayAudioStreamForPlayer(playerid,"http://cnr-radio.com/listen.m3u"); //CBs CnR
			case 21: PlayAudioStreamForPlayer(playerid,"http://yp.shoutcast.com/sbin/tunein-station.pls?id=1377877");
	    }
	    radio[playerid] = 1;
	    ShowRadioTD(playerid);
		return 1;
		
	}
	else if(dialogid == D_CAR && response)
	{
	    switch(listitem)
	    {
	        #if defined SAMP03X
	        case 0: dcmd_car(playerid,params2);
	        case 1: dcmd_tuned(playerid,params2);
	        case 2: dcmd_fastcars(playerid,params2);
	        case 3: dcmd_vmusclelow(playerid,params2);
	        case 4: dcmd_v2door(playerid,params2);
	        case 5: dcmd_v4door(playerid,params2);
	        case 6: dcmd_bikes(playerid,params2);
	        case 7: dcmd_vcivil(playerid,params2);
	        case 8: dcmd_vgovt(playerid,params2);
	        case 9: dcmd_vhtruck(playerid,params2);
	        case 10: dcmd_vltruck(playerid,params2);
	        case 11: dcmd_vrccar(playerid,params2);
	        case 12: dcmd_vrec(playerid,params2);
	        case 13: dcmd_vsuv(playerid,params2);
	        case 14: dcmd_vtrailer(playerid,params2);
	        case 15: dcmd_plane(playerid,params2);
	        case 16: dcmd_boat(playerid,params2);
	        case 17: dcmd_dcar(playerid,params2);
			#else // if samp 03e
	        case 0: dcmd_tuned(playerid,params2);
	        case 1: dcmd_fastcars(playerid,params2);
	        case 2: dcmd_vmusclelow(playerid,params2);
	        case 3: dcmd_v2door(playerid,params2);
	        case 4: dcmd_v4door(playerid,params2);
	        case 5: dcmd_bikes(playerid,params2);
	        case 6: dcmd_vcivil(playerid,params2);
	        case 7: dcmd_vgovt(playerid,params2);
	        case 8: dcmd_vhtruck(playerid,params2);
	        case 9: dcmd_vltruck(playerid,params2);
	        case 10: dcmd_vrccar(playerid,params2);
	        case 11: dcmd_vrec(playerid,params2);
	        case 12: dcmd_vsuv(playerid,params2);
	        case 13: dcmd_vtrailer(playerid,params2);
	        case 14: dcmd_plane(playerid,params2);
	        case 15: dcmd_boat(playerid,params2);
	        case 16: dcmd_dcar(playerid,params2);
			#endif //SAMP03X
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_VRACERS && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,429); //banshee
	        case 1: CreatePlayerVehicle(playerid,541); //bullet
	        case 2: CreatePlayerVehicle(playerid,415); //cheetah
	        case 3: CreatePlayerVehicle(playerid,480); //comet
	        case 4: CreatePlayerVehicle(playerid,562); //elegy
	        case 5: CreatePlayerVehicle(playerid,565); //flash
	        case 6: CreatePlayerVehicle(playerid,434); //hotknife
	        case 7: CreatePlayerVehicle(playerid,494); //hotring1
	        case 8: CreatePlayerVehicle(playerid,502); //hotring2
	        case 9: CreatePlayerVehicle(playerid,503); //hotring3
	        case 10: CreatePlayerVehicle(playerid,411); //infernus
	        case 11: CreatePlayerVehicle(playerid,559); //jester
	        case 12: CreatePlayerVehicle(playerid,561); //stratum
	        case 13: CreatePlayerVehicle(playerid,560); //sultan
	        case 14: CreatePlayerVehicle(playerid,506); //supergt
	        case 15: CreatePlayerVehicle(playerid,451); //turismo
	        case 16: CreatePlayerVehicle(playerid,558); //uranus
	        case 17: CreatePlayerVehicle(playerid,555); //windsor
	        case 18: CreatePlayerVehicle(playerid,477); //zr-350
	      
			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_TUNED && response)
	{
	    switch(listitem)
	    {
	        case 0: dcmd_wrc(playerid,params2);
	        case 1:
			{
				CreatePlayerVehicle(playerid,560); //sultan
				ChangeVehiclePaintjob(playercar[playerid], 0); // paint job
			 	AddVehicleComponent(playercar[playerid],1033); // roof vent
			 	AddVehicleComponent(playercar[playerid],1138); // wing
			 	AddVehicleComponent(playercar[playerid],1026); // sideskirt 1
			 	AddVehicleComponent(playercar[playerid],1027); // sideskirt 2
			 	AddVehicleComponent(playercar[playerid],1080); // wheels
			 	AddVehicleComponent(playercar[playerid],1029); // exhaust
			 	AddVehicleComponent(playercar[playerid],1086);
			 	AddVehicleComponent(playercar[playerid], 1010);
			}
			case 2:
			{
				CreatePlayerVehicle(playerid,562); //elegy
				ChangeVehiclePaintjob(playercar[playerid], 1); // paint job
			 	AddVehicleComponent(playercar[playerid],1034); 
			 	AddVehicleComponent(playercar[playerid],1136); 
			 	AddVehicleComponent(playercar[playerid],1038); 
			 	AddVehicleComponent(playercar[playerid],1040); 
			 	AddVehicleComponent(playercar[playerid],1073); 
			 	AddVehicleComponent(playercar[playerid],1016);
				AddVehicleComponent(playercar[playerid],1086);
				AddVehicleComponent(playercar[playerid], 1010);
			}
			case 3:
			{
				CreatePlayerVehicle(playerid,565); //flash
				ChangeVehiclePaintjob(playercar[playerid], 2); // paint job
			 	AddVehicleComponent(playercar[playerid],1045);
			 	AddVehicleComponent(playercar[playerid],1048);
			 	AddVehicleComponent(playercar[playerid],1050);
			 	AddVehicleComponent(playercar[playerid],1052);
			 	AddVehicleComponent(playercar[playerid],1053);
			 	AddVehicleComponent(playercar[playerid],1084);
			 	AddVehicleComponent(playercar[playerid],1086);
			 	AddVehicleComponent(playercar[playerid], 1010);
			}
			case 4:
			{
				CreatePlayerVehicle(playerid,558); //uranus
				ChangeVehiclePaintjob(playercar[playerid], 1); // paint job
			 	AddVehicleComponent(playercar[playerid],1163);
			 	AddVehicleComponent(playercar[playerid],1165);
			 	AddVehicleComponent(playercar[playerid],1167);
			 	AddVehicleComponent(playercar[playerid],1088);
			 	AddVehicleComponent(playercar[playerid],1089);
			 	AddVehicleComponent(playercar[playerid],1090);
			 	AddVehicleComponent(playercar[playerid],1094);
			 	AddVehicleComponent(playercar[playerid],1097);
			 	AddVehicleComponent(playercar[playerid],1086);
			 	AddVehicleComponent(playercar[playerid], 1010);
			}
			case 5:
			{
				CreatePlayerVehicle(playerid,589); //club
				ChangeVehiclePaintjob(playercar[playerid], 1); // paint job
			 	AddVehicleComponent(playercar[playerid],1000);
			 	AddVehicleComponent(playercar[playerid],1004);
			 	AddVehicleComponent(playercar[playerid],1007);
			 	AddVehicleComponent(playercar[playerid],1017);
			 	AddVehicleComponent(playercar[playerid],1024); //fogs
			 	AddVehicleComponent(playercar[playerid],1020);
			 	AddVehicleComponent(playercar[playerid],1144);
			 	AddVehicleComponent(playercar[playerid],1145);
			 	AddVehicleComponent(playercar[playerid],1082);
			 	AddVehicleComponent(playercar[playerid],1086);
			 	AddVehicleComponent(playercar[playerid], 1010);
			}
			case 6:
			{
				CreatePlayerVehicle(playerid,496); //blista
				ChangeVehiclePaintjob(playercar[playerid], 3); // paint job
			 	AddVehicleComponent(playercar[playerid],1000);
			 	AddVehicleComponent(playercar[playerid],1004);
			 	AddVehicleComponent(playercar[playerid],1007);
			 	AddVehicleComponent(playercar[playerid],1017);
			 	AddVehicleComponent(playercar[playerid],1024); //fogs
			 	AddVehicleComponent(playercar[playerid],1020);
			 	AddVehicleComponent(playercar[playerid],1144);
			 	AddVehicleComponent(playercar[playerid],1145);
			 	AddVehicleComponent(playercar[playerid],1081);
			 	AddVehicleComponent(playercar[playerid],1086);
			 	AddVehicleComponent(playercar[playerid], 1010);
			}
			
			case 7:
			{
			    CreatePlayerVehicle(playerid,576); //tornado
			 	ChangeVehiclePaintjob(playercar[playerid], 2);
			 	AddVehicleComponent(playercar[playerid],1191);
			 	AddVehicleComponent(playercar[playerid],1192);
			 	AddVehicleComponent(playercar[playerid],1134);
			 	AddVehicleComponent(playercar[playerid],1137);
			 	AddVehicleComponent(playercar[playerid],1136);
			 	AddVehicleComponent(playercar[playerid],1087); //hydraulics
			 	AddVehicleComponent(playercar[playerid],1096); // wheels
			 	AddVehicleComponent(playercar[playerid], 1010); // nos
			}
		    case 8:
		    {
		        CreatePlayerVehicle(playerid,535); //slamvan
				ChangeVehiclePaintjob(playercar[playerid], 2); // paint job
			 	AddVehicleComponent(playercar[playerid],1116); // front bumper
			 	AddVehicleComponent(playercar[playerid],1117); // frton bull bar
			 	AddVehicleComponent(playercar[playerid],1110); // rear bull bar
			 	AddVehicleComponent(playercar[playerid],1119); // sideskirt 1
			 	AddVehicleComponent(playercar[playerid],1121); // sideskirt 2
			 	AddVehicleComponent(playercar[playerid],1113); // exhaust
			 	AddVehicleComponent(playercar[playerid],1077); // wheels
			 	AddVehicleComponent(playercar[playerid],1087); //hydraulics
			 	AddVehicleComponent(playercar[playerid], 1010); // nos
			}
			
			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VMUSCLELOW && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,536); //blade
	        case 1: CreatePlayerVehicle(playerid,575); //broadway
	        case 2: CreatePlayerVehicle(playerid,534); //remington
	        case 3: CreatePlayerVehicle(playerid,567); //savanna
	        case 4: CreatePlayerVehicle(playerid,535); //slamvan
	        case 5: CreatePlayerVehicle(playerid,576); //tornado
	        case 6: CreatePlayerVehicle(playerid,412); //voodoo
	        case 7: CreatePlayerVehicle(playerid,402); //buffalo
	        case 8: CreatePlayerVehicle(playerid,542); //clover
	        case 9: CreatePlayerVehicle(playerid,603); //phoenix
	        case 10: CreatePlayerVehicle(playerid,475); //sabre

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_V2DOOR && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,602); //alpha
	        case 1: CreatePlayerVehicle(playerid,496); //blista
	        case 2: CreatePlayerVehicle(playerid,401); //bravura
	        case 3: CreatePlayerVehicle(playerid,518); //bucaneer
	        case 4: CreatePlayerVehicle(playerid,527); //cadrona
	        case 5: CreatePlayerVehicle(playerid,589); //club
	        case 6: CreatePlayerVehicle(playerid,419); //esperonto
	        case 7: CreatePlayerVehicle(playerid,533); //feltzer
	        case 8: CreatePlayerVehicle(playerid,526); //fortune
	        case 9: CreatePlayerVehicle(playerid,474); //hermes
	        case 10: CreatePlayerVehicle(playerid,545); //hustler
	        case 11: CreatePlayerVehicle(playerid,517); //majestic
	        case 12: CreatePlayerVehicle(playerid,410); //manana
	        case 13: CreatePlayerVehicle(playerid,600); //picador
	        case 14: CreatePlayerVehicle(playerid,436); //previon
	        case 15: CreatePlayerVehicle(playerid,580); //stafford
	        case 16: CreatePlayerVehicle(playerid,439); //stallion
	        case 17: CreatePlayerVehicle(playerid,549); //tampa
	        case 18: CreatePlayerVehicle(playerid,491); //virgo
	        

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_V4DOOR && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,445); //admiral
	        case 1: CreatePlayerVehicle(playerid,604); //damaged glendale
	        case 2: CreatePlayerVehicle(playerid,507); //elegant
	        case 3: CreatePlayerVehicle(playerid,585); //emporer
	        case 4: CreatePlayerVehicle(playerid,587); //euros
	        case 5: CreatePlayerVehicle(playerid,466); //glendale
	        case 6: CreatePlayerVehicle(playerid,492); //greenwood
	        case 7: CreatePlayerVehicle(playerid,546); //intruder
	        case 8: CreatePlayerVehicle(playerid,551); //merit
	        case 9: CreatePlayerVehicle(playerid,516); //nebula
	        case 10: CreatePlayerVehicle(playerid,467); //oceanic
	        case 11: CreatePlayerVehicle(playerid,426); //premier
	        case 12: CreatePlayerVehicle(playerid,547); //primo
	        case 13: CreatePlayerVehicle(playerid,405); //sentinel
	        case 14: CreatePlayerVehicle(playerid,409); //stretch
	        case 15: CreatePlayerVehicle(playerid,550); //sunrise
	        case 16: CreatePlayerVehicle(playerid,566); //tahoma
	        case 17: CreatePlayerVehicle(playerid,540); //vincent
	        case 18: CreatePlayerVehicle(playerid,421); //washington
	        case 19: CreatePlayerVehicle(playerid,421); //willard

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VBIKES && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,581); //bf-400
	        case 1: CreatePlayerVehicle(playerid,509); //bike
	        case 2: CreatePlayerVehicle(playerid,481); //bmx
	        case 3: CreatePlayerVehicle(playerid,462); //faggio
	        case 4: CreatePlayerVehicle(playerid,521); //fcr-900
	        case 5: CreatePlayerVehicle(playerid,463); //freeway
	        case 6: CreatePlayerVehicle(playerid,510); //mtn bike
	        case 7: CreatePlayerVehicle(playerid,522); //nrg-500
	        case 8: CreatePlayerVehicle(playerid,461); //pcj-600
	        case 9: CreatePlayerVehicle(playerid,448); //pizza
	        case 10: CreatePlayerVehicle(playerid,468); //sanchez
	        case 11: CreatePlayerVehicle(playerid,586); //wayfarer

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VCIVIL && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,485); //baggage
	        case 1: CreatePlayerVehicle(playerid,538); //TRAIN - SHOULD BE REMOVED
	        case 2: CreatePlayerVehicle(playerid,431); //bus
	        case 3: CreatePlayerVehicle(playerid,438); //cabbie
	        case 4: CreatePlayerVehicle(playerid,437); //coach
	        case 5: CreatePlayerVehicle(playerid,537); //freight
	        case 6: CreatePlayerVehicle(playerid,574); //sweeper
	        case 7: CreatePlayerVehicle(playerid,420); //taxi
	        case 8: CreatePlayerVehicle(playerid,525); //towtruck
	        case 9: CreatePlayerVehicle(playerid,408); //trashmaster
	        case 10: CreatePlayerVehicle(playerid,449); //TROLLY - SHOULD BE REMOVED
	        case 11: CreatePlayerVehicle(playerid,552); //utility

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VGOVT && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,416); //ambulance
	        case 1: CreatePlayerVehicle(playerid,433); //barracks
	        case 2: CreatePlayerVehicle(playerid,427); //enforcer
	        case 3: CreatePlayerVehicle(playerid,490); //FBI Rancher
	        case 4: CreatePlayerVehicle(playerid,528); //FBI truck
	        case 5: CreatePlayerVehicle(playerid,407); //fire truck
	        case 6: CreatePlayerVehicle(playerid,544); //fire truck w ladder
	        case 7: CreatePlayerVehicle(playerid,523); //HPV1000
	        case 8: CreatePlayerVehicle(playerid,470); //patriot
	        case 9: CreatePlayerVehicle(playerid,598); //LV police
	        case 10: CreatePlayerVehicle(playerid,596); //LS police
	        case 11: CreatePlayerVehicle(playerid,597); //SF police
	        case 12: CreatePlayerVehicle(playerid,599); //police ranger
	        case 13: CreatePlayerVehicle(playerid,597); //RHINO - SHOULD BE REMOVED
	        case 14: CreatePlayerVehicle(playerid,601); //SWAT
	        case 15: CreatePlayerVehicle(playerid,428); //securicar
	        

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VHTRUCK && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,499); //benson
	        case 1: CreatePlayerVehicle(playerid,609); //black boxville
	        case 2: CreatePlayerVehicle(playerid,498); //boxville
	        case 3: CreatePlayerVehicle(playerid,524); //cement
	        case 4: CreatePlayerVehicle(playerid,532); //combine
	        case 5: CreatePlayerVehicle(playerid,578); //dft-30
	        case 6: CreatePlayerVehicle(playerid,486); //dozer
	        case 7: CreatePlayerVehicle(playerid,406); //dumper
	        case 8: CreatePlayerVehicle(playerid,573); //dune
	        case 9: CreatePlayerVehicle(playerid,455); //flatbed
	        case 10: CreatePlayerVehicle(playerid,588); //hotdog
	        case 11: CreatePlayerVehicle(playerid,403); //linerunner
	        case 12: CreatePlayerVehicle(playerid,514); //linerunner
	        case 13: CreatePlayerVehicle(playerid,423); //whoopee

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VLTRUCK && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,459); //berkley
	        case 1: CreatePlayerVehicle(playerid,422); //bobcat
	        case 2: CreatePlayerVehicle(playerid,482); //burrito
	        case 3: CreatePlayerVehicle(playerid,605); //d sadler
	        case 4: CreatePlayerVehicle(playerid,530); //forklift
	        case 5: CreatePlayerVehicle(playerid,418); //moonbeam
	        case 6: CreatePlayerVehicle(playerid,572); //mower
	        case 7: CreatePlayerVehicle(playerid,582); //news van
	        case 8: CreatePlayerVehicle(playerid,413); //pony
	        case 9: CreatePlayerVehicle(playerid,440); //rumpo
	        case 10: CreatePlayerVehicle(playerid,543); //sadler
	        case 11: CreatePlayerVehicle(playerid,583); //tug
	        case 12: CreatePlayerVehicle(playerid,478); //walton
	        case 13: CreatePlayerVehicle(playerid,554); //yosemite

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VRCCAR && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,441); //rcbandit
	        case 1: CreatePlayerVehicle(playerid,464); //rcbaron
	        case 2: CreatePlayerVehicle(playerid,501); //rcgoblin
	        case 3: CreatePlayerVehicle(playerid,465); //rcraider
	        case 4: CreatePlayerVehicle(playerid,564); //rctiger
	        case 5: CreatePlayerVehicle(playerid,594); //rccam

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VREC && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,568); //bandito
	        case 1: CreatePlayerVehicle(playerid,424); //bf injection
	        case 2: CreatePlayerVehicle(playerid,504); //bloodring
	        case 3: CreatePlayerVehicle(playerid,457); //caddy
	        case 4: CreatePlayerVehicle(playerid,483); //camper
	        case 5: CreatePlayerVehicle(playerid,508); //journey
	        case 6: CreatePlayerVehicle(playerid,571); //kart
	        case 7: CreatePlayerVehicle(playerid,500); //mesa
	        case 8: CreatePlayerVehicle(playerid,444); //monster
	        case 9: CreatePlayerVehicle(playerid,556); //monster 2
	        case 10: CreatePlayerVehicle(playerid,557); //monster 3
	        case 11: CreatePlayerVehicle(playerid,471); //quad
	        case 12: CreatePlayerVehicle(playerid,495); //sandking
	        case 13: CreatePlayerVehicle(playerid,539); //vortex

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VSUV && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,579); //huntley
	        case 1: CreatePlayerVehicle(playerid,400); //landstalker
	        case 2: CreatePlayerVehicle(playerid,404); //perennial
	        case 3: CreatePlayerVehicle(playerid,489); //rancher
	        case 4: CreatePlayerVehicle(playerid,505); //rancher2
	        case 5: CreatePlayerVehicle(playerid,479); //regina
	        case 6: CreatePlayerVehicle(playerid,442); //romero
	        case 7: CreatePlayerVehicle(playerid,458); //solair

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VTRAILER && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerTrailer(playerid,606); //covered baggage
	        case 1: CreatePlayerTrailer(playerid,607); //uncovered baggage
	        case 2: CreatePlayerTrailer(playerid,610); //farm trailer
	        case 3: CreatePlayerTrailer(playerid,590); //FREIGHT BOXCAR
	        case 4: CreatePlayerTrailer(playerid,569); //FREIGHT BOXCAR
	        case 5: CreatePlayerTrailer(playerid,611); //street clean trailer
	        case 6: CreatePlayerTrailer(playerid,608); //tanker commando
	        case 7: CreatePlayerTrailer(playerid,435); //stairs
	        case 8: CreatePlayerTrailer(playerid,450); //trailer 1
	        case 9: CreatePlayerTrailer(playerid,591); //trailer 2
	        case 10: CreatePlayerTrailer(playerid,591); //trailer 3

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VBOAT && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,472); //coastguard
	        case 1: CreatePlayerVehicle(playerid,473); //dinghy
	        case 2: CreatePlayerVehicle(playerid,493); //jetmax
	        case 3: CreatePlayerVehicle(playerid,595); //launch
	        case 4: CreatePlayerVehicle(playerid,484); //marquis
	        case 5: CreatePlayerVehicle(playerid,430); //predator
	        case 6: CreatePlayerVehicle(playerid,453); //reefer
	        case 7: CreatePlayerVehicle(playerid,452); //speeder
	        case 8: CreatePlayerVehicle(playerid,446); //squalo
	        case 9: CreatePlayerVehicle(playerid,454); //tropic

			default: return 1;
	    }
	    return 1;
	}
	//ShowPlayerDialog(playerid, D_VBOAT, DIALOG_STYLE_LIST, "= Boats =","Coastguard 472\nDinghy 473
	//\nJetmax 493\nLaunch 595\nMarquis 484\nPredator 430\nReefer 453\nSpeeder 452\nSqualo 446\nTropic 454","Select","Close");
	else if(dialogid == D_VPLANE && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,592); //andromeda
	        case 1: CreatePlayerVehicle(playerid,577); //at400
	        case 2: CreatePlayerVehicle(playerid,511); //beagle
	        case 3: CreatePlayerVehicle(playerid,548); //cargobob
	        case 4: CreatePlayerVehicle(playerid,512); //crop
	        case 5: CreatePlayerVehicle(playerid,593); //dodo
	        case 6: CreatePlayerVehicle(playerid,425); //HUNTER - REMOVE
	        case 7: CreatePlayerVehicle(playerid,520); //HYDRA - REMOVE
	        case 8: CreatePlayerVehicle(playerid,417); //leviathan
	        case 9: CreatePlayerVehicle(playerid,487); //maverick
	        case 10: CreatePlayerVehicle(playerid,553); //nevada
	        case 11: CreatePlayerVehicle(playerid,488); //news chopper
	        case 12: CreatePlayerVehicle(playerid,497); //police maverick
	        case 13: CreatePlayerVehicle(playerid,563); //raindance
	        case 14: CreatePlayerVehicle(playerid,476); //rustler
	        case 15: CreatePlayerVehicle(playerid,447); //SEASPARROW - REMOVE
	        case 16: CreatePlayerVehicle(playerid,519); //shamal
	        case 17: CreatePlayerVehicle(playerid,460); //skimmer
	        case 18: CreatePlayerVehicle(playerid,469); //sparrow
	        case 19: CreatePlayerVehicle(playerid,513); //stunt

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_VTRAILER && response)
	{
	    switch(listitem)
	    {
	        case 0: CreatePlayerVehicle(playerid,472); //coastguard
	        case 1: CreatePlayerVehicle(playerid,473); //dinghy
	        case 2: CreatePlayerVehicle(playerid,493); //jetmax
	        case 3: CreatePlayerVehicle(playerid,595); //launch
	        case 4: CreatePlayerVehicle(playerid,484); //marquis
	        case 5: CreatePlayerVehicle(playerid,430); //predator
	        case 6: CreatePlayerVehicle(playerid,453); //reefer
	        case 7: CreatePlayerVehicle(playerid,452); //speeder
	        case 8: CreatePlayerVehicle(playerid,446); //squalo
	        case 9: CreatePlayerVehicle(playerid,454); //tropic

			default: return 1;
	    }
	    return 1;
	}
	else if(dialogid == D_DRUNK && response)
	{
	    switch(listitem)
	    {
	        case 0: { SetPlayerDrunkLevel(playerid,1999); SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Drunk Level: 1999"); }
	        case 1: { SetPlayerDrunkLevel(playerid,3000); SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Drunk Level: 3000"); }
	        case 2: { SetPlayerDrunkLevel(playerid,5000); SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Drunk Level: 5000"); }
	        case 3: { SetPlayerDrunkLevel(playerid,10000); SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Drunk Level: 10000"); }
	        case 4: { SetPlayerDrunkLevel(playerid,50000); SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Drunk Level: 50000"); }
	        default: return 1;
	    }
	    return 1;
	}

	else if(dialogid == D_GUNS && response)
	{
	    new id;
	    switch(listitem)
	    {
	        case 0: id = 22;//9mm
	        case 1: id = 23;//silenced
	        case 2: id = 25;//shotgun
	        case 3: id = 28;//uzi
	        case 4: id = 29;//mp5
			case 5: id = 30;//ak47
			case 6: id = 31;//m4
			case 7: id = 32;//tec9
			case 8: id = 33;//rifle
			case 9: id = 1;//knuckles
			case 10: id = 2;//golf club
			case 11: id = 3;//night stick
			case 12: id = 5;//baseball bat
			case 13: id = 6;//shovel
			case 14: id = 7;//pool cue
			case 15: id = 8;//katana
			case 16: id = 9;//chainsaw
			case 17: id = 10;//double dildo
			case 18: id = 11;//dildo
			case 19: id = 12;//vibrator
			case 20: id = 14;//flowers
			case 21: id = 15;//cane
			case 22: id = 34; //sniper
			case 23: id = 26; // sawn off
			case 24: id = 24; //deagle
			case 25: id = 43; //camera
			case 26: id = 38; //minigun
			case 27: id = 35; //rpg
			case 28: id = 36; //hs rocket
			case 29: id = 39; //det packs = 39
			case 30: id = 16; //grenades
			case 31: id = 18; //molotov
			case 32: id = 27; //combat shotgun
			case 33: id = 37; // flamethrower
			case 34: id = 44; //night goggles
			case 35: id = 45;// thermal
			case 36: id = 4;//knife
			default: return 1;
	    }
	    if(IsPlayerInSafeZone(playerid) && !IsPlayerAdmin(playerid))
	    {
	        switch(id)
	        {
	            case 16,18,35,36,37,38,39:  return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You may not spawn heavy-weapons inside Safe Zones");
	        }
	    
	    }
	    if(id == 39) GivePlayerWeapon(playerid,40,99999);
	    GivePlayerWeapon(playerid,id,99999);
	    
	    return 1;
	}
	else if(dialogid == D_DM && response)
	{
	    switch(listitem)
	    {
	        case 0: return dcmd_gang(playerid,params2);
			case 1: return DeagleDM(playerid);
			case 2: return ShipDM(playerid);
			case 3: return MilitaryDM(playerid);
			case 4: return GasDM(playerid);
			case 5: return SawnOffDM(playerid);
	        case 6: return SniperDM(playerid);
            case 7: return RocketDM(playerid);
            case 8: return MinigunDM(playerid);
			case 9: return SwordDM(playerid);
 			case 10: return HouseDM(playerid);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_GANG && response)
	{
	    switch(listitem)
	    {
			case 0: return FamilyDM(playerid);
			case 1: return BallaDM(playerid);
			case 2: return AztecaDM(playerid);
			case 3: return VagosDM(playerid);
			case 4: return RifaDM(playerid);
	        case 5: return TriadDM(playerid);
            case 6: return DaNangDM(playerid);
			case 7: return MafiaDM(playerid);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_COLOR && response)
//	Black\nWhite\nGrey\nBlue\nRed\nYellow\nGreen\nPurple\nBright Green\nBright Red\nKing Blue\nNeon Purple\nBarbie Pink
	{
	    new color,chosen;
	    switch(listitem)
	    {
	        case 0: { color = 0; chosen = 1;}
	        case 1: { color = 1; chosen = 1;}
	        case 2: { color = 157; chosen = 1;}
	        case 3: { color = 79; chosen = 1;}
	        case 4: { color = 3; chosen = 1;}
	        case 5: { color = 6; chosen = 1;}
	        case 6: { color = 86; chosen = 1;}
	        case 7: { color = 134; chosen = 1;}
	        case 8: { color = 128; chosen = 1;}
	        case 9: { color = 181; chosen = 1;}
	        case 10: { color = 162; chosen = 1;}
	        case 11: { color = 167; chosen = 1;}
	        case 12: { color = 136; chosen = 1;}
	    }
	    if(chosen)
	    {
			ChangeVehicleColor(pvehicleid[playerid],color,color);
			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} You can change BOTH car colors (primary and secondary) by using {FFFFFF}/cc");
		}
		return 1;
	}
	else if(dialogid == D_PCOLOR && response)
	{
	    switch(listitem)
	    {
	        case 0: { SetPlayerColor(playerid,COLOR_PINK); pcolor[playerid] = COLOR_PINK; }
	        case 1: { SetPlayerColor(playerid,COLOR_DARKRED); pcolor[playerid] = COLOR_DARKRED; }
	        case 2: { SetPlayerColor(playerid,COLOR_BLUE); pcolor[playerid] = COLOR_BLUE; }
	        case 3: { SetPlayerColor(playerid,COLOR_LIGHTBLUE); pcolor[playerid] = COLOR_LIGHTBLUE; }
	        case 4: { SetPlayerColor(playerid,COLOR_GREEN); pcolor[playerid] = COLOR_GREEN; }
	        case 5: { SetPlayerColor(playerid,COLOR_LIGHTGREEN); pcolor[playerid] = COLOR_LIGHTGREEN; }
	        case 6: { SetPlayerColor(playerid,COLOR_YELLOW); pcolor[playerid] = COLOR_YELLOW; }
	        case 7: { SetPlayerColor(playerid,COLOR_GREENYELLOW); pcolor[playerid] = COLOR_GREENYELLOW; }
	        case 8: { SetPlayerColor(playerid,COLOR_PURPLE); pcolor[playerid] = COLOR_PURPLE; }
	        case 9: { SetPlayerColor(playerid,COLOR_VIOLET); pcolor[playerid] = COLOR_VIOLET; }
	        case 10: { SetPlayerColor(playerid,COLOR_ORANGE); pcolor[playerid] = COLOR_ORANGE; }
	        case 11: { SetPlayerColor(playerid,COLOR_BROWN); pcolor[playerid] = COLOR_BROWN; }
	    }
		return 1;
	}
	else if(dialogid == D_SETSPAWN && response)
	{
	    switch(listitem)
	    {
	        case 0: setspawn[playerid] = 0; //drift
	     	case 1: setspawn[playerid] = 1; //ls airport
	        case 2: setspawn[playerid] = 2; //aa boneyard
	        case 3: setspawn[playerid] = 3; // chiliad
	        case 4: setspawn[playerid] = 4; //sf airport
	        case 5: setspawn[playerid] = 5; //lv airport
	        case 6: setspawn[playerid] = 6; //ls downtown
	        case 7: setspawn[playerid] = 7; //sf downtown
	        case 8: setspawn[playerid] = 8; //lv downtown
	        case 9: setspawn[playerid] = 9; //desert town
	        case 10: setspawn[playerid] = 10; //sex shop
		}
		return 1;
	}
	else if(dialogid == D_HELMET && response)
	{
	    new helm;
	    switch(listitem)
	    {
	     	case 0: helm = 18645; 
	        case 1: helm = 18977; 
	        case 2: helm = 18978; 
	        case 3: helm = 18979; 
	        case 4:
			{
				if(helmet[playerid])
				{
					RemovePlayerAttachedObject(playerid, HELMET_SLOT);
					helmet[playerid] = 0;
				}

			} // remove helmet
		}
		switch(GetPlayerSkin(playerid))
	    {
//	        #define SPAO{%0,%1,%2,%3,%4,%5} SetPlayerAttachedObject(playerid, HELMET_SLOT, 18645, 2, (%0), (%1), (%2), (%3), (%4), (%5));
			#define SPAO{%0,%1,%2,%3,%4,%5,%6} SetPlayerAttachedObject(playerid, HELMET_SLOT, (%0), 2, (%1), (%2), (%3), (%4), (%5), (%6));

	        case 0, 65, 74, 149, 208, 273:  SPAO{helm,0.070000, 0.000000, 0.000000, 88.000000, 75.000000, 0.000000}
	        case 1..6, 8, 14, 16, 22, 27, 29, 33, 41..49, 82..84, 86, 87, 119, 289: SPAO{helm,0.070000, 0.000000, 0.000000, 88.000000, 77.000000, 0.000000}
	        case 7, 10: SPAO{helm,0.090000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
	        case 9: SPAO{helm,0.059999, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
	        case 11..13: SPAO{helm,0.070000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
	        case 15: SPAO{helm,0.059999, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 17..21: SPAO{helm,0.059999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 23..26, 28, 30..32, 34..39, 57, 58, 98, 99, 104..118, 120..131: SPAO{helm,0.079999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 40: SPAO{helm,0.050000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 50, 100..103, 148, 150..189, 222: SPAO{helm,0.070000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 51..54: SPAO{helm,0.100000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 55, 56, 63, 64, 66..73, 75, 76, 78..81, 133..143, 147, 190..207, 209..219, 221, 247..272, 274..288, 290..293: SPAO{helm,0.070000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 59..62: SPAO{helm,0.079999, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 77: SPAO{helm,0.059999, 0.019999, 0.000000, 87.000000, 82.000000, 0.000000}
	        case 85, 88, 89: SPAO{helm,0.070000, 0.039999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 90..97: SPAO{helm,0.050000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 132: SPAO{helm,0.000000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 144..146: SPAO{helm,0.090000, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 220: SPAO{helm,0.029999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 223, 246: SPAO{helm,0.070000, 0.050000, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 224..245: SPAO{helm,0.070000, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 294: SPAO{helm,0.070000, 0.019999, 0.000000, 91.000000, 84.000000, 0.000000}
	        case 295: SPAO{helm,0.050000, 0.019998, 0.000000, 86.000000, 82.000000, 0.000000}
	        case 296..298: SPAO{helm,0.064999, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
	        case 299: SPAO{helm,0.064998, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
	    }
	    helmet[playerid] = 1;
		return 1;
	}

  	else if(dialogid == D_PAINTJOB && response)
	{
	    new job;
	    switch(listitem)
	    {
	        case 0: job = 0;
	        case 1: job = 1;
	        case 2: job = 2;
	        case 3: job = 3;
	        case 4: job = 4;
	    }
		ChangeVehiclePaintjob(pvehicleid[playerid],job);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		return 1;
	}
	else if(dialogid == D_KEYY && response)
	{
	    switch(listitem)
	    {
	        case 0: {
						keyy[playerid] = 0;
					}
	        case 1:	{
						keyy[playerid] = 1;
					}
	        case 2: {
						keyy[playerid] = 2;
					}
	        case 3: {
						keyy[playerid] = 3;
					}
            case 4: {
						keyy[playerid] = 4;
					}
	    }
		SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Y Key extra command modified");
		return 1;
	}
	else if(dialogid == D_KEYN && response)
	{
	    switch(listitem)
	    {
	        case 0: {
						keyn[playerid] = 0;
					}
	        case 1:	{
						keyn[playerid] = 1;
					}
	        case 2: {
						keyn[playerid] = 2;
					}
	        case 3: {
						keyn[playerid] = 3;
					}
            case 4: {
						keyn[playerid] = 4;
					}
			case 5: {
						keyn[playerid] = 5;
					}
			case 6: {
						keyn[playerid] = 6;
					}
	    }
		SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} N Key extra command modified");
		return 1;
	}
	else if(dialogid == D_KEY2 && response)
	{
	    switch(listitem)
	    {
	        case 0: {
						key2[playerid] = 0;
				        #if defined TEXTDRAWS
						if(pstate[playerid] == PLAYER_STATE_DRIVER)
						{
							HideVehTD(playerid);
							TextDrawShowForPlayer(playerid, Veh);
						}
						#endif //td
					}
	        case 1:	{
						key2[playerid] = 1;
						#if defined TEXTDRAWS
						if(pstate[playerid] == PLAYER_STATE_DRIVER)
						{
							HideVehTD(playerid);
							TextDrawShowForPlayer(playerid, VehAutoFlip);
						}
						#endif //td
					}
	        case 2: {
						key2[playerid] = 2;
						#if defined TEXTDRAWS
						if(pstate[playerid] == PLAYER_STATE_DRIVER)
						{
							HideVehTD(playerid);
							TextDrawShowForPlayer(playerid, VehPutRamp);
						}
						#endif //td
					}
	        case 3: {
						key2[playerid] = 3;
						#if defined TEXTDRAWS
						if(pstate[playerid] == PLAYER_STATE_DRIVER)
						{
							HideVehTD(playerid);
							TextDrawShowForPlayer(playerid, VehPutSkulls);
						}
						#endif //td
					}
 			case 4: {
						key2[playerid] = 4;
						#if defined TEXTDRAWS
						if(pstate[playerid] == PLAYER_STATE_DRIVER)
						{
							HideVehTD(playerid);
							TextDrawShowForPlayer(playerid, VehAutoStop);
						}
						#endif //td
					}
	    }
		SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} 2 Key extra command modified");
		return 1;
	}
	else if(dialogid == D_HELLO && response)
	{
		return 1;
	}
	else if(dialogid == D_TELE && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_airports(playerid,params2);
			case 1:	dcmd_stadiums(playerid,params2); 
			case 2: dcmd_interiors(playerid,params2);
			case 3: dcmd_dm(playerid,params2);
			case 4: dcmd_casino(playerid,params2);
			case 5: dcmd_train(playerid,params2);
			case 6: dcmd_cities(playerid,params2);
			case 7: dcmd_chiliad(playerid,params2);
			case 8: dcmd_cannon(playerid,params2);
			case 9: dcmd_stuntcity(playerid,params2);
			case 10: dcmd_drift(playerid,params2);
			case 11: dcmd_skyway(playerid,params2);
			case 12: dcmd_derby(playerid,params2);
			case 13: dcmd_ramp(playerid,params2);
			case 14: dcmd_basejump(playerid,params2);
			case 15: dcmd_dirtpit(playerid,params2);
			case 16: dcmd_pyramid(playerid,params2);
			case 17: dcmd_desert(playerid,params2);
			case 18: dcmd_bikepark(playerid,params2);
			case 19: dcmd_beach(playerid,params2);
			case 20: dcmd_tuner(playerid,params2);
			case 21: dcmd_underwater(playerid,params2);
			case 22: dcmd_trucker(playerid,params2);
			case 23: dcmd_center(playerid,params2);
			case 24: dcmd_space(playerid,params2);
			case 25: dcmd_halfpipe(playerid,params2);
			case 26: dcmd_basketcar(playerid,params2);
			case 27: dcmd_loopramp(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_AIRPORTS && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_airport(playerid,params2);
			case 1:	dcmd_sf(playerid,params2);
			case 2: dcmd_lv(playerid,params2);
			case 3: dcmd_boneyard(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_AIRPORTS && !response)
	{
		dcmd_tele(playerid,params2);
		return 1;
	}
	else if(dialogid == D_STADIUMS && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_dirtarena(playerid,params2);
			case 1:	dcmd_8track(playerid,params2);
			case 2: dcmd_kickstart(playerid,params2);
			case 3: dcmd_bloodbowl(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_STADIUMS && !response)
	{
		dcmd_tele(playerid,params2);
		return 1;
	}
	else if(dialogid == D_INTERIORS && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_sex(playerid,params2);
			case 1:	dcmd_androm(playerid,params2);
			case 2: dcmd_shamal(playerid,params2);
			case 3: dcmd_otb(playerid,params2);
			case 4: dcmd_rctrack(playerid,params2);
			case 5: dcmd_ammu(playerid,params2);
			case 6: dcmd_dirtarena(playerid,params2);
			case 7: dcmd_8track(playerid,params2);
			case 8: dcmd_lc(playerid,params2);
			case 9: dcmd_fia(playerid,params2);
			case 10: dcmd_atrium(playerid,params2);
			case 11: dcmd_kickstart(playerid,params2);
			case 12: dcmd_bloodbowl(playerid,params2);

			case 13: dcmd_fiabag(playerid,params2);
			case 14: dcmd_cracklab(playerid,params2);
			case 15: dcmd_range(playerid,params2);
			case 16: dcmd_donut(playerid,params2);
			case 17: dcmd_jefferson(playerid,params2);
			case 18: dcmd_jizzys(playerid,params2);
			case 19: dcmd_pigpen(playerid,params2);
			case 20: dcmd_pump(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_INTERIORS && !response)
	{
		dcmd_tele(playerid,params2);
		return 1;
	}
	else if(dialogid == D_CITIES && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_ls(playerid,params2);
			case 1:	dcmd_sfdt(playerid,params2);
			case 2: dcmd_lvdt(playerid,params2);
			case 3: dcmd_blueberry(playerid,params2);
			case 4: dcmd_carson(playerid,params2);
			case 5: dcmd_elquebrados(playerid,params2);
			case 6: dcmd_angelpine(playerid,params2);
			case 7: dcmd_palomino(playerid,params2);
			case 8: dcmd_montgomery(playerid,params2);
			case 9: dcmd_dilimore(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_CITIES && !response)
	{
		dcmd_tele(playerid,params2);
		return 1;
	}
	else if(dialogid == D_CASINO && response)
	{
		if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: dcmd_casino1(playerid,params2);// Caligulas
			case 1:	dcmd_casino2(playerid,params2); // Four Dragons
			case 2: dcmd_casino3(playerid,params2);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_CASINO && !response)
	{
		dcmd_tele(playerid,params2);
		return 1;
	}
	else if(dialogid == D_WHEELS && response)
	{
	    new wheelid;
  		switch(listitem)
  		{
  			case 0: wheelid = 1025;
			case 1: wheelid = 1073;
			case 2: wheelid = 1074;
		 	case 3: wheelid = 1075;
		 	case 4: wheelid = 1076;
		 	case 5: wheelid = 1077;
		 	case 6: wheelid = 1078;
		 	case 7: wheelid = 1079;
		 	case 8: wheelid = 1080;
			case 9: wheelid = 1081;
			case 10: wheelid = 1082;
			case 11: wheelid = 1083;
		 	case 12: wheelid = 1084;
		 	case 13: wheelid = 1085;
		 	case 14: wheelid = 1096;
		 	case 15: wheelid = 1097;
		 	case 16: wheelid = 1098;
		}
		if(wheelid) AddVehicleComponent(pvehicleid[playerid],wheelid);
		return 1;
	}
	else if(dialogid == D_TRAINS && response)
	{
		if(RaceParticipant[playerid] > 0) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	    switch(listitem)
	    {
			case 0: SetPlayerPosEx(playerid, -1958.1073,147.5540,27.6875);
			case 1: SetPlayerPosEx(playerid, 2858.4727,1292.0011,11.3906);
			case 2: SetPlayerPosEx(playerid, 1721.0686,-1969.8986,14.1172);
		  	case 3:	SetPlayerPosEx(playerid, 637.2217,1288.1804,11.7188,60.0);
		  	case 4:
		  	{
		  	    new occupiedtrain = 0;
		  	    for(new i; i < MAX_VEHICLES; i++)
		  	    {
		  	        if(GetVehicleModel(i) == 537)
		  	        {
		  	            foreach(Player,j)
						{
						    if(IsPlayerInVehicle(j,i)) occupiedtrain = 1;
						}
						if(!occupiedtrain)
						{
			  	            GetVehiclePos(i,playerx,playery,playerz);
			  	            SetPlayerPosEx(playerid,playerx,playery,playerz+5);
			  	            return 1;
						}
						else continue;
		  	        }
				}
		  	}
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_BASEJUMP && response)
	{
		if(RaceParticipant[playerid] > 0) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
		GivePlayerWeapon(playerid,46,1);
	    switch(listitem)
	    {
			case 0: SetPlayerPosEx(playerid, 1574.8966,-1249.2684,277.8787);
			case 1: SetPlayerPosEx(playerid, 1539.4971,-1371.4875,328.3436);
			case 2: SetPlayerPosEx(playerid, -225.1428,1393.6865,172.4141);
		  	case 3: SetPlayerPosEx(playerid, -2872.1931,2606.3821,271.5319);
		 	case 4: SetPlayerPosEx(playerid, -341.6077,1601.4565,164.4840);
		 	case 5: SetPlayerPosEx(playerid, -2671.7253,1594.8706,217.2739);
		 	case 6: SetPlayerPosEx(playerid, -1282.2144,51.9589,70.4453);
		 	case 7: SetPlayerPosEx(playerid, -1791.7642,558.0606,234.8906);
		 	case 8: SetPlayerPosEx(playerid, -1753.6783,885.3945,295.8750);
		 	case 9: SetPlayerPosEx(playerid, -372.9020,2125.8528,132.8034);
	        default: return 1;
		}
		return 1;
	}
	else if(dialogid == D_FIGHT && response)
	{
	    new fstyle = 0;
  		switch(listitem)
 		{
	  		case 0: fstyle = FIGHT_STYLE_NORMAL; // normal
		 	case 1: fstyle = FIGHT_STYLE_BOXING; // boxing
		 	case 2: fstyle = FIGHT_STYLE_KUNGFU; // kungfu
	        case 3: fstyle = FIGHT_STYLE_KNEEHEAD;
	        case 4: fstyle = FIGHT_STYLE_GRABKICK;
	        case 5: fstyle = FIGHT_STYLE_ELBOW;
		}
		SetPlayerFightingStyle(playerid, fstyle);
		SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Fighting style changed. Type /fight again to choose a different one.");
		return 1;
	}
	else if(dialogid == D_WEATHER && response)
	{
	    new id=15;
		new time=12; // id weather -  time time of day
	    switch(listitem)
		{
	      case 0: {id = 10; time = 12; }//sunny DAY
	      case 1: {id = 10; time = 23; }//sunny NIGHT
	      case 2: {id = 16; time = 12; }//rain DAY
	      case 3: {id = 16; time = 23; } //rain NIGHT
	      case 4: {id = 9; time = 12; }//foggy DAY
	      case 5: {id = 9; time = 23; } //foggy NIGHT
	      case 6: {id = 17; time = 12; }//hot DAY
	      case 7: {id = 19; time = 12; }//sandstorm DAY
	      case 8: {id = 19; time = 23; } //sandstorm NIGHT
	      case 9: {id = 35; time = 12; }//polluted DAY
	      case 10: {id = 35; time = 23; } //polluted NIGHT
	    }
	    SetPlayerWeather(playerid,id);
	    SetPlayerTime(playerid,time,0);
        return 1;
	}
	#if defined NEON
	else if(dialogid == D_NEON)
    {
        if(response)
        {
        	if(listitem == 0)
         	{
            	SetPVarInt(playerid, "Status", 1);
        		SetPVarInt(playerid, "neon", CreateObject(18648,0,0,0,0,0,0));
       			SetPVarInt(playerid, "neon1", CreateObject(18648,0,0,0,0,0,0));
        		AttachObjectToVehicle(GetPVarInt(playerid, "neon"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
        		AttachObjectToVehicle(GetPVarInt(playerid, "neon1"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
        		SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
        		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
            }
            if(listitem == 1)
            {
            	SetPVarInt(playerid, "Status", 1);
            	SetPVarInt(playerid, "neon2", CreateObject(18647,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon3", CreateObject(18647,0,0,0,0,0,0));
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon2"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon3"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

    		}
            if(listitem == 2)
      		{
                SetPVarInt(playerid, "Status", 1);
      			SetPVarInt(playerid, "neon4", CreateObject(18649,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon5", CreateObject(18649,0,0,0,0,0,0));
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon4"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
           		AttachObjectToVehicle(GetPVarInt(playerid, "neon5"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
            }
            if(listitem == 3)
            {
                SetPVarInt(playerid, "Status", 1);
                SetPVarInt(playerid, "neon6", CreateObject(18652,0,0,0,0,0,0));
	            SetPVarInt(playerid, "neon7", CreateObject(18652,0,0,0,0,0,0));
    	        AttachObjectToVehicle(GetPVarInt(playerid, "neon6"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
        	    AttachObjectToVehicle(GetPVarInt(playerid, "neon7"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
      			SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
      			PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

    		}
            if(listitem == 4)
            {
           		SetPVarInt(playerid, "Status", 1);
            	SetPVarInt(playerid, "neon8", CreateObject(18651,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon9", CreateObject(18651,0,0,0,0,0,0));
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon8"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon9"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
            }
            if(listitem == 5)
            {
	            SetPVarInt(playerid, "Status", 1);
    	        SetPVarInt(playerid, "neon10", CreateObject(18650,0,0,0,0,0,0));
        	    SetPVarInt(playerid, "neon11", CreateObject(18650,0,0,0,0,0,0));
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon10"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	AttachObjectToVehicle(GetPVarInt(playerid, "neon11"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
            	SendClientMessage(playerid, 0xFFFFFFAA,  "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
            	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
	        if(listitem == 6)
            {
    	        SetPVarInt(playerid, "Status", 1);
        	    SetPVarInt(playerid, "neon12", CreateObject(18648,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon13", CreateObject(18648,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon14", CreateObject(18649,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon15", CreateObject(18649,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon12"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon13"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon14"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon15"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

        	}
         	if(listitem == 7)
            {
            	SetPVarInt(playerid, "Status", 1);
            	SetPVarInt(playerid, "neon16", CreateObject(18648,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon17", CreateObject(18648,0,0,0,0,0,0));
            	SetPVarInt(playerid, "neon18", CreateObject(18652,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon19", CreateObject(18652,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon16"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon17"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon18"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon19"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
            if(listitem == 8)
            {
                SetPVarInt(playerid, "Status", 1);
                SetPVarInt(playerid, "neon20", CreateObject(18647,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon21", CreateObject(18647,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon22", CreateObject(18652,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon23", CreateObject(18652,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon20"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon21"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon22"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon23"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
            if(listitem == 9)
            {
                SetPVarInt(playerid, "Status", 1);
                SetPVarInt(playerid, "neon24", CreateObject(18647,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon25", CreateObject(18647,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon26", CreateObject(18650,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon27", CreateObject(18650,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon24"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon25"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon26"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon27"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
            if(listitem == 10)
            {
                SetPVarInt(playerid, "Status", 1);
                SetPVarInt(playerid, "neon28", CreateObject(18649,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon29", CreateObject(18649,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon30", CreateObject(18652,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon31", CreateObject(18652,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon28"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon29"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon30"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon31"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
            if(listitem == 11)
            {
                SetPVarInt(playerid, "Status", 1);
                SetPVarInt(playerid, "neon32", CreateObject(18652,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon33", CreateObject(18652,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon34", CreateObject(18650,0,0,0,0,0,0));
                SetPVarInt(playerid, "neon35", CreateObject(18650,0,0,0,0,0,0));
                AttachObjectToVehicle(GetPVarInt(playerid, "neon32"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon33"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon34"), GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                AttachObjectToVehicle(GetPVarInt(playerid, "neon35"), GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
                SendClientMessage(playerid, 0xFFFFFFAA, "{FFFFFF}[SYSTEM]:{C0C0C0} Neon installed");
                PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);

            }
		   	if(listitem == 12)
		   	{
				DestroyNeon(playerid);
				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
			}
		}
	}
	#endif
	
	return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{

	if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{
	    if(pickupid == cannon1) //chiliad
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], v[0], 20, v[2]+7);
//		    SetVehicleHealth(pvehicleid[playerid],2000);
		    return 1;
	    }
	    else if(pickupid == cannon2) //airport
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], v[0], 40, v[2]+13);
//		    SetVehicleHealth(pvehicleid[playerid],2000);
		    return 1;
	    }
	    else if(pickupid == cannon3) //ramp
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], 25, v[1], v[2]+5);
//		    SetVehicleHealth(pvehicleid[playerid],2000);
		    return 1;
	    }
	    else if(pickupid == cannon4) //         /cannon
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], 3, v[1], v[2]);
//		    SetVehicleHealth(pvehicleid[playerid],2000);
		    return 1;
	    }
	    else if(pickupid == cannon5) //ls airport bounce
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], v[0], v[1], 5);
//		    SetVehicleHealth(pvehicleid[playerid],1000);
		    return 1;
	    }
	    else if(pickupid == cannon6) //lv airport
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], v[0], -75, 15);
//		    SetVehicleHealth(pvehicleid[playerid],4000);
		    return 1;
	    }
	  	else if(pickupid == cannon7) //ls airport bounce
	    {
		    new Float:v[3];
		    GetVehicleVelocity(pvehicleid[playerid], v[0], v[1], v[2]);
		    SetVehicleVelocity(pvehicleid[playerid], v[0], v[1], 20);
//		    SetVehicleHealth(pvehicleid[playerid],1000);
		    return 1;
	    }
	    else
	   	{
			foreach(Player,i)
			{
			    if(pickupid == skulls[i] && pstate[playerid] == PLAYER_STATE_DRIVER)
			    {
	//		        new Float:v[3];
			    	GetVehicleVelocity(pvehicleid[playerid], playerx, playery, playerz);
					SetVehicleVelocity(pvehicleid[playerid], playerx*15.5, playery*10.5, 0.0);
			    }

			}
		}
    }
    return 1;
}

//------------------------------------------------------------------------------

forward GameModeExitFunc();
public GameModeExitFunc()
{
	GameModeExit();
	return 1;
}

//------------------------------------------------------------------------------


// ===========          COMMANDS            ============
dcmd_pm(const playerid,const params[])
{
	if(Variables[playerid][Wired])
	{
	    Variables[playerid][WiredWarnings]--;
	    new Name[24];
	    if(Variables[playerid][WiredWarnings])
		{
	        format(string128,sizeof(string128),"You have been wired thus preventing you from talking or PMing. [Warnings: %d/%d]",Variables[playerid][WiredWarnings],Config[WiredWarnings]);
			SendClientMessage(playerid,white,string128); return 1;
		}
		else
		{
		    GetPlayerName(playerid,Name,24); format(string128,sizeof(string128),"%s has been kicked from the server. [REASON: Wired]",Name);
		    SendClientMessageToAll(yellow,string128); SetUserInt(playerid,"Wired",0);
		    Kick(playerid); return 1;
		}
	}
	new	idx;
	new	tmp[128];
	new Message[256];
	new gMessage[128];
	tmp = strtok(params,idx);
	if(!strlen(tmp) || strlen(tmp) > 5)
	{
		SendClientMessage(playerid,COLOR_SYSTEM,"{FFFFFF}[SYSTEM]:{C0C0C0} Usage: /pm (id) (message)");
		return 1;
	}
	new id = strval(tmp);
    gMessage = strrest(params,idx);
	if(!strlen(gMessage))
	{
		SendClientMessage(playerid,COLOR_SYSTEM,"{FFFFFF}[SYSTEM]:{C0C0C0} Usage: /pm (id) (message)");
		return 1;
	}

	if(!IsPlayerConnected(id))
	{
		SendClientMessage(playerid,COLOR_ERROR,"{FFFFFF}[SYSTEM]:{C0C0C0} /pm :{CC0000} Bad player ID");
		return 1;
	}
	if(playerid != id)
	{
		if(containsip(gMessage) && !IsPlayerAdmin(playerid))
		{
			printf("[IP PM spam] [%i]%s | PM SPAM %i->%i: %s",playerid,pname[playerid],playerid,id,gMessage);
	        return 0;
		}
		if(gblnIsMuted[playerid][id] == true) return 1; //player i has ignored sender
		format(Message,sizeof(Message),">> %s(%d): %s",pname[id],id,gMessage);
		SendClientMessage(playerid,COLOR_YELLOW,Message);
		format(Message,sizeof(Message),"** %s(%d): %s",pname[playerid],playerid,gMessage);
		SendClientMessage(id,COLOR_YELLOW,Message);
		PlayerPlaySound(id,1085,0.0,0.0,0.0);

		printf("[pm] [%i]%s -> [%i]%s: '%s'",playerid,pname[playerid],id,pname[id],Message);

	}
	else
	{
		SendClientMessage(playerid,COLOR_ERROR,"You cannot PM yourself");
	}
	return 1;
}

dcmd_c(const playerid, const params[])
{
	dcmd_cmd(playerid,params);
	return 1;
}
dcmd_command(const playerid, const params[])
{
	dcmd_cmd(playerid,params);
	return 1;
}
dcmd_commands(const playerid, const params[])
{
	dcmd_cmd(playerid,params);
	return 1;
}
dcmd_cmds(const playerid, const params[])
{
	dcmd_cmd(playerid,params);
	return 1;
}
dcmd_cmd(const playerid, const params[])
{
//	ShowPlayerDialog(playerid, D_COMMANDS, DIALOG_STYLE_LIST, "Commands | See chat for ALL","god\nregister\nlogin\nignore\npm\nspawn\ntele\ndm\ncar\npropertyhelp\nglasses\nsp\nlp\nkey2\nkeyy\nkeyn\nlock\nunlock\nvr\nflip\nnos\nsnos\nneon\ntune\ncolor\npaintj\nwheels\nhorn\nputmine\nputramp\nputskulls\nfindcar\ngetcar\ngunship\njump\njoin\nkill\nskin\npcolor\nwrc\ncount\njetpack\npc\ngun\nfight\ndrunk\ntime\nweather\ns\nanims\nchicken\ncow\nporn\nhsmoke\ntow\njunk\nrules\nradio\ntrailer","Read","Exit");
    SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}ospawner,interiors,ignore,pm,radio,magnet,spawn,tele,trailer,propertyhelp,glasses,sp,lp,key2,keyy,keyn,lock,unlock,reserve,lsa,sfa");
	SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}kill,toys,day,night,rain,radio,tow,flip,nos,snos,neon,tune,color,paintj,wheels,horn,putmine,putramp,putskulls,findcar,getcar,flymode");
	SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}cctv,beer,wine,blunt,vr,e(ject),gunship,jump,join,skin,pskin,pcolor,wrc,count,jetpack,pc,gun,fight,drunk,time,weather,piss,anims,afk"); // longest line allowed
	SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}spec,cc,carry,stats,leave,menu,airports,stadiums,tele,v,cmd,cities,drunk,launch,trucks,leftovers,trucker,casino,skyway,chiliad,ls,lv,sf ");
	SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}tpallow,tpdeny,tp,plate,saveskin,prohouse,fireme,dcar,stop,helmet,shamal,plane,boat,nrg,bikes,fastcars,gang,chicken,cow,porn,hsmoke,junk");
    SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FFFF00}register,login,c,v,t,s,dm,car,credits,god,rules,lvstrip,rallyup,ramp,pweather,day,night,daynight,lc,kickstart,bloodbowl,8track,androm");
    SendClientMessage(playerid,COLOR_BRIGHTGREEN,"{FF0000}HOUSING:{FFFF00} /buyhouse /house /[un]lockdoor /knock /enter /exit /myhouse /hupgrade /hcardeposit /hcarwithdrawl");
	ShowPlayerDialog(playerid, D_COMMANDS1, DIALOG_STYLE_MSGBOX, "Commands | See chat for ALL","{FFFF00}/afk{FFFFFF} - away from keyboard (yoga)\n{FFFF00}/airports{FFFFFF} - list all airport teleports\n{FFFF00}/anims{FFFFFF} - list all anims\n{FFFF00}/beer{FFFFFF} - have a beer!	\n{FFFF00}/bikes{FFFFFF} - spawn a bike	\n{FFFF00}/blunt{FFFFFF} - smoke a blunt	\n{FFFF00}/boat{FFFFFF} - spawn a boat\n{FFFF00}/c{FFFFFF} - list ccommands	\n{FFFF00}/car{FFFFFF} - spawn a car (any car!)","Next","Exit");
	return 1;
	#pragma unused params
}
dcmd_t(const playerid, const params[])
{
	dcmd_tele(playerid,params);
	return 1;
}
dcmd_teles(const playerid, const params[])
{
	dcmd_tele(playerid,params);
	return 1;
}
dcmd_radio(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_RADIO, DIALOG_STYLE_LIST, "Choose Radio Feed","-- TURN OFF RADIO --\n{33AA33}++Add Your URL{FFFFFF}\nPolice/Fire/EMS Radio\nHam/Amateur Radio\nAirport/plane Radio\nMusic/News Radio","Listen","Exit");
// ShowPlayerDialog(playerid, D_RADIO1, DIALOG_STYLE_LIST, "Choose Category","-- TURN OFF RADIO --\nMusic\nNews\nPolice\nFire/EMS\nAircraft\nHam Radio","Listen","Exit");
	return 1;
	#pragma unused params
}

#if defined TOYS
dcmd_toys(const playerid, const params[])
{
	if(!pro[playerid]) return SendClientError(playerid,COLOR_ERROR,"This command is for PRO (donator) players.");
    new string[128];
    for(new x;x<MAX_PLAYER_ATTACHED_OBJECTS;x++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, x)) format(string, sizeof(string), "%s%d (Used)\n", string, x);
        else format(string, sizeof(string), "%s%d\n", string, x);
    }
    ShowPlayerDialog(playerid, DIALOG_ATTACH_INDEX_SELECTION, DIALOG_STYLE_LIST, \
    "{FF0000}Attachment Modification - Index Selection", string, "Select", "Cancel");
    return 1;
	#pragma unused params
}
#endif


dcmd_airports(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_AIRPORTS, DIALOG_STYLE_LIST, "Choose Airport","Los Santos Int'l (LS)\nEaster Bay Int'l (SF)\nLas Venturas Regional (LV)\nAbandoned Airport (LV)","Select","Back");
	return 1;
	#pragma unused params
}
dcmd_stadiums(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_STADIUMS, DIALOG_STYLE_LIST, "Choose Stadium","Dirt Arena\n8-Track\nKickstart\nBloodbowl","Select","Back");
	return 1;
	#pragma unused params
}
dcmd_interiors(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_INTERIORS, DIALOG_STYLE_LIST, "Choose Interior","Sex Shop\nAndromeda\nShamal\nOTB\nRC Track\nAmmu\nDirt Arena\n8-Track\nLiberty City\nPlane Tickets\nAtrium\nKickstart\nBloodbowl\nFIA Baggage\nCrack Lab\nShooting Range\nDonut Shop\nJefferson Hotel\nJizzys\nPigpens\nWelcome Pump","Select","Back");
	return 1;
	#pragma unused params
}
dcmd_cities(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_CITIES, DIALOG_STYLE_LIST, "Choose City/Town","LS Downtown\nSF Downtown\nLV Downtown\nBlueberry\nFort Carson\nEl Quebrados\nAngel Pine\nPalomino Creek\nMontgomery\nDilimore","Select","Back");
	return 1;
	#pragma unused params
}
dcmd_tele(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_TELE, DIALOG_STYLE_LIST, "Choose Teleport","{FFFF00}Airports\n{FFFF00}Stadiums\n{FFFF00}Interiors\n{FFFF00}Deathmatch {FF0000}(DM)\n{FFFF00}Casinos\n{FFFF00}Train Stations\n{FFFF00}Cities and Towns{C0C0C0}\n\nChiliad\nCar Cannon\nStunt City\nDrift Area\nSky Highway\nDemo Derby\nDesert Ramp\nBasejump\nBig Dig\nPyramid\nOld Town\nBike Park\nBeach\nMod Shop\nUnderwater\nTrucker\nCenter\nSpace Platform\nGiant Halfpipe\nPlay BasketCar\nGiant Loop-Ramp","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_menu(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_MENU, DIALOG_STYLE_LIST, "Choose Menu","{FFFF00}Teleport Menu\n{FFFF00}Deathmatch Menu\n{FFFF00}Spawn Vehicle\n{33CCFF}Vehicle Commands\n{FFFFFF}Radio Stream Select\nGun Menu\nSet Spawn Location\nConfig 2 Key\nConfig Y Key\nConfig N Key\nChange Weather\nChange Color\n{33AA33}Commands\n{FFFFFF}Help\nEnter Fly-mode","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_caroptions(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_CAROPTIONS, DIALOG_STYLE_LIST, "BE IN A CAR BFORE USING","Repair Vehicle\nActivate SNOS\nActivate Bunny-Hop\nTune Car\nAdd Neon\nAdd Train Horn\nChange Wheels\nChange Car Color\nChange Paintjob\nAdd Gunship\nJunk The Car","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_help(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_HELP2, DIALOG_STYLE_MSGBOX, "Everystuff Tips","\n{FFFF00}For all commands type /cmd{FFFFFF}\n\n{33AA33}Type /rules for server rules{FFFFFF}\n{FFFF00}Press Y to open teleport menu{FFFFFF}\nTo send pm, use /pm\nType /v or /car to make car\nTo super-jump, type /jump\nType /ignore to ignore player\nType /kill to respawn\nFor deathmatch type /dm\nType /key2, /keyy,or /keyn to set special keymapping\n\n{FFFF00}/SNOS AND /JUMP LOOK LIKE CHEATS (they're NOT!)\n","Play!!","Menu");
 	return 1;
	#pragma unused params
}

dcmd_tut1(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_TUT1, DIALOG_STYLE_MSGBOX, "Page 1: The Basics","{FFFF00}Getting Started:{FFFFFF}\nPress the Y key to open main menu\n\nYou will respawn at random places unless\nyou use /setspawn to bind somewhere\n\nDMing is allowed anywhere. If you don't want to DM, \nstay in /god mode\n\nYou will lose /god protection if you shoot \nsomeone while /god is on.\n\nYou can spawn any car, almost anywhere using\nthe /v and /car commands, or choosing 'Spawn Vehicle'","Close","Next");
 	return 1;
	#pragma unused params
}
dcmd_tut2(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_TUT2, DIALOG_STYLE_MSGBOX, "Page 2: Vehicles","{FFFF00}Making a car:{FFFFFF}\nUse /v or open /menu and choose 'Spawn Vehicle' to make your own car.\n\nUse /tune to mod car including wheels,hydros,paint,etc\n\nPress the '2' key to refill NOS and repair vehicle whilst driving\n\nUse /findcar to tp to your car. Use /getcar to bring to you\n\nLook in the main /menu or hit Y key and check 'Vehicle Commands' for more functions!","Back","Next");
 	return 1;
	#pragma unused params
}

dcmd_debug(const playerid, const params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new players,cars,objects,i;
	players = Iter_Count(Player);
	for(i = 0; i < MAX_VEHICLES; i++)
	{
	    new modelid = GetVehicleModel(i);
		if(modelid >= MIN_VEHI_ID && modelid <= MAX_VEHI_ID) cars++;
	}
	for(i = 0; i < MAX_OBJECTS; i++)
	{
	    if(IsValidObject(i)) objects++;
	}
	format(string128,sizeof(string128),"Players:_%i Cars:_%i Objects:_%i",players,cars,objects);
	SendClientMessage(playerid,COLOR_GREY,string128);
	return 1;
	#pragma unused params
}
dcmd_s(const playerid, const params[])
{
// 4001,4803,4804,5000,5003,5406,5848,7001,7005,7008,7009,7007,7011,7023,7208,7400,7410,7601,7607,7810,7816,7824,dcmd_s2
	ShowPlayerDialog(playerid, D_SOUNDS, DIALOG_STYLE_LIST, "Choose sound","Fuck Grove\nWanna Go\nPay attention\nBig and manful\nBigger than the gear shift\nNot enough funds\nYou win\nHere for ages\nYou know who I am?\nYou ain't in no position\nWho are you?\nYou're a dead man\nHave it your way\nFuck you\nPrivate function\nCan't come down here\nCall security\nWarn the boss\nWhos this prick\nDon't make me slap you\nLots of snakes\nBouncy tits\nMore Sounds","Select","Close");
	return 1;
	#pragma unused params
}

dcmd_s2(const playerid, const params[])
{
// 7834,7837,7840,7841,7852,7851,7857,7887,7891,8010,8017,8411,8624,8622,8656,8738,8830,9020,9402,9437,9613,9624,9639,10402,10408,10600,10607,10801,dcmd_s
	ShowPlayerDialog(playerid, D_SOUNDS2, DIALOG_STYLE_LIST, "Choose sound","Slap you silly\nRun like fuck\nWant to come too\nDon't leave me\nWe're screwed\nHave to piss\nIn my eye\nStop touching yourself\nHe started it\nFuck you x3\nDeath wish\nCome out\nIdiota\nAint listening\nCrazy Bitch\nGoodbye\nStop shooting\nFucking sloth\nFuck off\nI'm gonna die\nGames up\nDon't even think\nYou pushing me\nAll aboard\nHold up\nHelp!\nCall 911\nBeat it\nMore Sounds","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_quiet(const playerid, const params[])
{
    PlayerPlaySound(playerid, 1188,0.0,0.0,0.0); // id 1188 stops ALL music
	if(!quiet[playerid])
	{
	    quiet[playerid] = 1;
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} You will no longer hear death sounds or players using /s");
	}
	else
	{
	    quiet[playerid] = 0;
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} You will hear death sounds and players using /s again");
	}
	return 1;
	#pragma unused params


}
dcmd_hideui(const playerid, const params[])
{
	if(!hideui[playerid]) // hide all applicable TDs from player
	{
		TextDrawHideForPlayer(playerid,Help);
//		TextDrawHideForPlayer(playerid,ServerIP);
		TextDrawHideForPlayer(playerid,God); // god
		TextDrawHideForPlayer(playerid,SnosOn); //snos
		TextDrawHideForPlayer(playerid,JumpOn); // jump
		TextDrawHideForPlayer(playerid,RadioOn); //radio
		TextDrawHideForPlayer(playerid,NoGod); // god
		TextDrawHideForPlayer(playerid,SnosOff); //snos
		TextDrawHideForPlayer(playerid,JumpOff); // jump
		TextDrawHideForPlayer(playerid,RadioOff); //radio
		PlayerTextDrawHide(playerid,posTD[playerid]); // pos td PLAYER TD
		PlayerTextDrawHide(playerid,Speedo[playerid]); // speedo PLAYER TD
		TextDrawHideForPlayer(playerid,VehAutoFlip); // 'press 2 for fix etc' msg
		TextDrawHideForPlayer(playerid,VehPutRamp); // 'press 2 for fix etc' msg
		TextDrawHideForPlayer(playerid,VehPutSkulls); // 'press 2 for fix etc' msg
		TextDrawHideForPlayer(playerid,VehAutoStop); // 'press 2 for fix etc' msg
		TextDrawHideForPlayer(playerid,Veh); // Veh
		TextDrawHideForPlayer(playerid,Leave); // Leave
		PlayerTextDrawHide(playerid,Stats[playerid]); // Leave
		PlayerTextDrawHide(playerid,VehModel[playerid]); // Leave
		TextDrawHideForPlayer(playerid,BottomBanner); // Leave
		hideui[playerid] = 1;
		GameTextForPlayer(playerid,"~w~Type ~y~/hideui ~w~again~n~To show Textdraws",3000,3);
	}
	else // show all applicable TDs to player
	{
	    TextDrawShowForPlayer(playerid, Help);
		TextDrawShowForPlayer(playerid, ServerIP);
		PlayerTextDrawShow(playerid, posTD[playerid]);
		PlayerTextDrawShow(playerid, Speedo[playerid]);
		PlayerTextDrawShow(playerid, Stats[playerid]);
		TextDrawShowForPlayer(playerid, BottomBanner);
		ShowGodTD(playerid);
		ShowSnosTD(playerid);
		ShowJumpTD(playerid);
		ShowRadioTD(playerid);
		hideui[playerid] = 0;
	}
	return 1;
	#pragma unused params
}
dcmd_afk(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot use /afk at this time. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(afk[playerid])
	{
	    SetPlayerPosEx(playerid,storedx[playerid],storedy[playerid],storedz[playerid],storeda[playerid],storedint[playerid]);
	    TogglePlayerControllable(playerid,true);
		format(string128,sizeof(string128),"%s has returned to their keyboard!",pname[playerid]);
	    SendClientMessageToAll(COLOR_PINK,string128);
	    afk[playerid] = 0;
	}
	else
	{
		if(gTeam[playerid]) dcmd_leave(playerid,params2);
		GetPlayerPos(playerid, storedx[playerid], storedy[playerid],storedz[playerid]);
		GetPlayerFacingAngle(playerid, storeda[playerid]);
		storedint[playerid] = GetPlayerInterior(playerid);
		SetPlayerPosEx(playerid, 2324.33, -1144.79, 1050.71,0.0,12);
		TogglePlayerControllable(playerid,false);
	    afk[playerid] = 1;
	    format(string128,sizeof(string128),"%s is /afk",pname[playerid]);
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} You are now AFK. Type /afk again to return!");
	    SendClientMessageToAll(COLOR_PINK,string128);
	    LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
	}
	return 1;
	#pragma unused params
}
dcmd_drunk(const playerid, const params[])
{
	if(!strlen(params)) ShowPlayerDialog(playerid, D_DRUNK, DIALOG_STYLE_LIST,"Choose Drunk Level", "Buzz On\nLil Tipsy\nHobo Drunk\nWasted+Mad\nCollege Student","Select","Close");
	else
	{
		new idx = strval(params);
		new drunk = GetPlayerDrunkLevel(playerid);
		if((idx+drunk) > 49999) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} Sorry, that would put you over the maximum drunk level of 50000. Try again.");
		if(GetPlayerDrunkLevel(playerid) < 50000) SetPlayerDrunkLevel(playerid,idx);
		format(string128, sizeof(string128), "{33AA33}[CONFIRM]:{C0C0C0} New Drunk Level: %i", idx);
		SendClientMessage(playerid,COLOR_CONFIRM,string128);
	}
	return 1;
	#pragma unused params
}
dcmd_e(const playerid, const params[])
{
	format(string128, sizeof(string128), "{33AA33}[EJECT]:{C0C0C0} WATCH THE CANOPY!!");
	SendClientMessage(playerid,COLOR_CONFIRM,string128);
	GetPlayerPos(playerid,playerx,playery,playerz);
	SetPlayerPos(playerid,playerx,playery,playerz+5);
	dcmd_pc(playerid,params2);
	return 1;
	#pragma unused params
}


dcmd_launch(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new Float:x, Float:y, Float:z;
	if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{
	    GetVehiclePos(pvehicleid[playerid],x,y,z);
	    SetVehiclePos(pvehicleid[playerid],x,y,z+1000);
	}
	else
	{
		GetPlayerPos(playerid,x,y,z);
		SetPlayerPosEx(playerid,x,y,z+1000);
	}
	return 1;
	#pragma unused params
}
dcmd_space(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	else
	{
		 SetPlayerPosEx(playerid,1900.4696,-2328.0867,99993.5469);
		 SetPlayerTime(playerid,23,00);
		 SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Welcome to the /space platform. Z ~ 100,000. Its going to take a while to come down...");
	}

	return 1;
	#pragma unused params
}

dcmd_piss(const playerid, const params[])
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_PISSING) SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
	else SetPlayerSpecialAction(playerid,SPECIAL_ACTION_PISSING);

	return 1;
	#pragma unused params
}

dcmd_jump(const playerid, const params[])
{
   	if((gTeam[playerid] || RaceParticipant[playerid]) && !jump[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!jump[playerid])
	{
	    jump[playerid] = 1;
	    GameTextForPlayer(playerid,"~n~~w~TAP ~r~JUMP~w~ TO BUNNY HOP~n~TYPE /JUMP TO TURN OFF",5000,4);
	    ShowJumpTD(playerid);
 	}
	else
	{	jump[playerid] = 0;
	    GameTextForPlayer(playerid,"~n~~w~BUNNY HOP (/JUMP)~n~~r~DISABLED!~w~",5000,4);
	    ShowJumpTD(playerid);
	}
	return 1;
	#pragma unused params
}

dcmd_jetpack(playerid,params[])
{
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	GetPlayerPos(playerid, playerx, playery, playerz);
	if(GetPlayerSpecialAction(playerid) == 2) {
		GetPlayerPos(playerid, playerx, playery, playerz);
		SetPlayerPos(playerid, playerx, playery, playerz);
		return 1;
	}
    return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    #pragma unused params
}

dcmd_flymode(playerid,params[])
{
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");

    // Place the player in and out of edit mode
	if(GetPVarType(playerid, "FlyMode")) CancelFlyMode(playerid);
	else FlyMode(playerid);
	return 1;
	#pragma unused params
}

dcmd_carry(playerid,params[])
{
	#if defined SAMP03X
    return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    #else
    return SendClientMessage(playerid,COLOR_YELLOW,"Everystuff SAMP 0.3x server IP:everystuff.net:7777 -or- 69.60.109.157:7777");
    #endif
    #pragma unused params
}
//Unused function
/*dcmd_nuke(playerid,params[])
{
    if(IsPlayerCommandLevel(playerid,"ban"))
    {
        if(blnNukeActive == true) return SendClientMessage(playerid, COLOR_ERROR, "Less nukes, more peace!");
		foreach(Player, i)
		{
			SendClientMessage(i, 0x77CC77FF, "Tactical nuke incoming!");
			PlayAudioStreamForPlayer(i, "http://65.111.172.126/Madoshi/NukeCountdown.mp3"); //Enable audiomsgoff in config
		}
		GetPlayerPos(playerid, NukeOriginX, NukeOriginY, NukeOriginZ);
		NukeObject = CreateObject(1636, NukeOriginX, NukeOriginY, NukeOriginZ, 0.0, 0.0, 0.0);
		tmrNuke = SetTimer("NukeCountdown", 1000, true);
		blnNukeActive = true;
	}
	return 1;
	#pragma unused params
}*/
dcmd_beer(playerid,params[])
{
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    SetPlayerDrunkLevel (playerid, 3000);
	return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
    #pragma unused params
}
dcmd_blunt(playerid,params[])
{
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
    #pragma unused params
}
dcmd_wine(playerid,params[])
{
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    SetPlayerDrunkLevel (playerid, 6000);
    return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
    #pragma unused params
}
dcmd_racolor(playerid,params[])
{
	if(IsPlayerXAdmin(playerid))
	{
    	SetPlayerColor(playerid, 0xFF0000AA);
    }
    return 1;
    #pragma unused params
}



dcmd_cloak(playerid,params[])
{
	if(IsPlayerXAdmin(playerid))
	{
    	SetPlayerMarkerForPlayer( playerid, 1, ( GetPlayerColor( 1 ) & 0xFFFFFF00 ) );
    }
    return 1;
    #pragma unused params
}

dcmd_tow(playerid, params[])
{
    if  (IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid))) SendClientMessage(playerid, COLOR_GREY, "You are already towing a vehicle.");
    new Float:PPPX,Float:PPPY,Float:PPPZ;
    GetPlayerPos(playerid,PPPX,PPPY,PPPZ);
    new Float:VVVX,Float:VVVY,Float:VVVZ;
    new Found=0;
    new vid=0;
    while((vid<MAX_VEHICLES)&&(!Found))
    {
        vid++;
        GetVehiclePos(vid,VVVX,VVVY,VVVZ);
        if  ((floatabs(PPPX-VVVX)<7.0)&&(floatabs(PPPY-VVVY)<7.0)&&(floatabs(PPPZ-VVVZ)<7.0)&&(vid!=GetPlayerVehicleID(playerid)))
        {
            Found=1;
            AttachTrailerToVehicle(vid,GetPlayerVehicleID(playerid));
            SendClientMessage(playerid,COLOR_GREY,"Towing!!  - This Server uses Tow Vehicle by Gaurav_Rawat");
        }

    }
    if  (!Found)
    {
                SendClientMessage(playerid,COLOR_GREY,"There is no vehicle in range to tow!.");
    }
    return 1;
    #pragma unused params
}
dcmd_gun(playerid,params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	else if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid, D_GUNS, DIALOG_STYLE_LIST, "Choose Weapon","9mm Pistol\nSilenced 9mm\nShotgun\nUzi\nMP5\nAK-47\nM4\nTec-9\nRifle\nBrass Knuckles\nGolf Club\nNight Stick\nBaseball Bat\nShovel\nPool Cue\nKatana\nChainsaw\nDouble Dildo\nDildo\nVibrator\nFlowers\nCane\nSniper Rifle\nSawn-Off\nDesert Eagle\nCamera\nMinigun - ADMIN\nRPG - ADMIN\nHS Rocket - ADMIN\nDet Packs - ADMIN\nSuper Knife - ADMIN","Select","Close");
	}
	else
	{
	/*
	    if(godmode[playerid])
	    {
	        godmode[playerid] = 0;
	        ShowGodTD(playerid);
	    }
	*/
		ShowPlayerDialog(playerid, D_GUNS, DIALOG_STYLE_LIST, "Choose Weapon","9mm Pistol\nSilenced 9mm\nShotgun\nUzi\nMP5\nAK-47\nM4\nTec-9\nRifle\nBrass Knuckles\nGolf Club\nNight Stick\nBaseball Bat\nShovel\nPool Cue\nKatana\nChainsaw\nDouble Dildo\nDildo\nVibrator\nFlowers\nCane\nSniper Rifle\nSawn-Off\nDesert Eagle\nCamera\nMinigun\nRPGs\nHS Rockets\nDet Packs\nGrenades\nMolotov Cocktails\nCombat Shotgun\nFlameThrower\nNight Goggles\nThermal Goggles","Select","Close");
	}
	return 1;
    #pragma unused params
}
dcmd_magnet(playerid,params[])
{
 	if(GetVehicleModel(pvehicleid[playerid]) == 548)
 	{
		DestroyObject(magnet[playerid]);
 	    magnet[playerid] = CreateObject(18886,0.0,0.0,0.0,0.0,0.0,0.0,300.0); //red magnet = 3056
	    AttachObjectToVehicle(magnet[playerid],pvehicleid[playerid],0.0,0.0,-10.0,0.0,0.0,0.0);
	    GameTextForPlayer(playerid,"~n~~w~PRESS ~r~~k~~VEHICLE_FIREWEAPON_ALT~ ~w~~n~WHEN OVER CAR~n~TO ATTACH",6000,3);

 	}
 	else SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are NOT in a CargoBob helicopter (modelid 548)");
	return 1;
	#pragma unused params
}

dcmd_gunship(playerid,params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	else if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(pvehicleid[playerid] != INVALID_VEHICLE_ID && pstate[playerid] == PLAYER_STATE_DRIVER)
	{

	    if(IsValidObject(vobject[pvehicleid[playerid]]))
		{
			DestroyObject(vobject[pvehicleid[playerid]]);
		 	vobject[pvehicleid[playerid]] = INVALID_OBJECT_ID;
	 	}
	    GetVehiclePos(pvehicleid[playerid],playerx,playery,playerz);
	    GetVehicleZAngle(pvehicleid[playerid],playera);
	    vobject[pvehicleid[playerid]] = CreateObject(3267,playerx,playery,playerz,0.0,0.0,0.0,200.0); //mounted minigun = 2985, sam = 3267
	    AttachObjectToVehicle(vobject[pvehicleid[playerid]],pvehicleid[playerid],0.0,0.0,-0.5,0.0,0.0,0.0);
	}
	else return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} Unable to use command. Make sure you are driving a vehicle before using /gunship");
	
	return 1;
    #pragma unused params
}

dcmd_stats(playerid,params[])
{
	new id;
	if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
	if(!strlen(params))
	{
		id = playerid;
		SendClientMessage(playerid,COLOR_SYSTEM,"{FFFFFF}[STATS]: {C0C0C0} Type a player id after /stats to see their info! ex: {FFFFFF}/stats 23");
	}
	if(!IsPlayerConnected(id))
	{
		SendClientMessage(playerid,COLOR_ERROR,"{FFFFFF}[SYSTEM]:{C0C0C0} /stats :{CC0000} Bad player ID");
		return 1;
	}
	else
	{

		
	    new Float:health, Float:armor;
	    new money;
		money = GetPlayerMoney(id);
	    GetPlayerHealth(id,health);
	    GetPlayerArmour(id,armor);
		new weap = GetPlayerWeapon(playerid);
		format(string256,sizeof(string256),"{FF0000}%s{C0C0C0}'s stats: Weapon: %s Kills:%i Wins:%i Money:%i Health%.0f Armor:%.0f DM:%i",pname[id],aWeaponNames[weap],kills[id],race1st[id],money,health,armor,gTeam[id]);
		SendClientMessage(playerid,COLOR_YELLOW,string256);
		/*
		new slot[13];
	    new ammo[13];
	    for(new i; i < 13; i++)
		{
		    GetPlayerWeaponData(playerid,i,slot[i],ammo[i]);
		    if(!slot[i]) slot[i] = 19; //19 is blank in aWeaponNames
		    if(ammo[i] < 0) ammo[i] = 999;
		}
		format(string128,sizeof(string128),"(0):%s:%i (1):%s:%i (2):%s:%i (3):%s:%i (4):%s:%i (5):%s:%i (6):%s:%i ",aWeaponNames[slot[0]],ammo[0],aWeaponNames[slot[1]],ammo[1],aWeaponNames[slot[2]],ammo[2],aWeaponNames[slot[3]],ammo[3],aWeaponNames[slot[4]],ammo[4],aWeaponNames[slot[5]],ammo[5],aWeaponNames[slot[6]],ammo[6]);
		SendClientMessage(playerid,COLOR_SYSTEM,string128);
		format(string128,sizeof(string128),"(7):%s:%i (8):%s:%i (9):%s:%i (10):%s:%i (11):%s:%i (12):%s:%i",aWeaponNames[slot[7]],ammo[7],aWeaponNames[slot[8]],ammo[8],aWeaponNames[slot[9]],ammo[9],aWeaponNames[slot[10]],ammo[10],aWeaponNames[slot[11]],ammo[11],aWeaponNames[slot[12]],ammo[12]);
        SendClientMessage(playerid,COLOR_SYSTEM,string128);
        */
	}
	return 1;
	#pragma unused params
}


dcmd_saveme(playerid,params[])
{
    new file[256]; file = GetPlayerFile(playerid);
    new money = GetPlayerMoney(playerid);
    if(Variables[playerid][LoggedIn])
    {
	    SetUserInt(playerid,"Money",money);
	    SetUserInt(playerid,"Kills",kills[playerid]);
	    SetUserInt(playerid,"RacesWon",race1st[playerid]);
    }
	return 1;
	#pragma unused params
}
dcmd_savecar(playerid,params[])
{
	if(pvehicleid[playerid] == INVALID_VEHICLE_ID) return SendClientError(playerid,COLOR_RED,"You must be in a car to use this command");
    new file[256]; file = GetPlayerFile(playerid);
    new model = GetVehicleModel(GetPlayerVehicleID(playerid));
    if(Variables[playerid][LoggedIn])
    {
	    SetUserInt(playerid,"PCarModel",model);
    }
	return 1;
	#pragma unused params
}
dcmd_fireme(playerid,params[])
{
//	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
//	else if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(IsValidObject(firemeobject[playerid]))
	{
		DestroyObject(firemeobject[playerid]);
	 	firemeobject[playerid] = INVALID_OBJECT_ID;
	 	SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} You have been extinguished!");
	 	return 1;
 	}
 	else
 	{
 	    GetPlayerPos(playerid,playerx,playery,playerz);
	    firemeobject[playerid] = CreateObject(18691,playerx,playery,playerz,0.0,0.0,0.0,200.0);
		AttachObjectToPlayer(firemeobject[playerid],playerid,0.0,0.0,-2.5,0.0,0.0,0.0);
		SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} You have been lit on fire!!!");
	}
	return 1;
    #pragma unused params
}
dcmd_gunship2(playerid,params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	else if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type {CC0000}/afk{C0C0C0} to leave.");
	if(pvehicleid[playerid] != INVALID_VEHICLE_ID && pstate[playerid] == PLAYER_STATE_DRIVER)
	{

	    if(IsValidObject(vobject[pvehicleid[playerid]]))
		{
			DestroyObject(vobject[pvehicleid[playerid]]);
		 	vobject[pvehicleid[playerid]] = INVALID_OBJECT_ID;
	 	}
	    GetVehiclePos(pvehicleid[playerid],playerx,playery,playerz);
	    GetVehicleZAngle(pvehicleid[playerid],playera);
	    vobject[pvehicleid[playerid]] = CreateObject(362,playerx,playery,playerz,0.0,0.0,0.0,200.0); //mounted minigun = 2985, sam = 3267
	    AttachObjectToVehicle(vobject[pvehicleid[playerid]],pvehicleid[playerid],0.0,0.0,-0.5,0.0,0.0,0.0);
	}
	else return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} Unable to use command. Make sure you are driving a vehicle before using /gunship");

	return 1;
    #pragma unused params
}

dcmd_ignore(playerid, params[])
{
	new target; //ignore target

	target = strval(params);
	if (IsPlayerConnected(target) && target != playerid)
	{
		gblnIsMuted[target][playerid] = true;
		format(string128,sizeof(string128),"{33AA33}[CONFIRM]:{C0C0C0} You are ignoring [%i]%s. Type /unignore %i to hear them again.",target,pname[target],target);
		SendClientMessage(playerid,COLOR_CONFIRM,string128);
		//Message
	}
	else
	{
		format(string128,sizeof(string128),"{CC0000}[ERROR]:{C0C0C0} That player is an invalid target, or does not exist!");
		SendClientMessage(playerid,COLOR_CONFIRM,string128);
	}
	return 1;
	#pragma unused params
}

dcmd_unignore(playerid, params[])
{
	new target; //unignore target

	target = strval(params);
	if (IsPlayerConnected(target) && target != playerid)
	{
		gblnIsMuted[target][playerid] = false;
		format(string128,sizeof(string128),"{33AA33}[CONFIRM]:{C0C0C0} You have unignored [%i]%s, and you will be able to hear them again.",target,pname[target]);
		SendClientMessage(playerid,COLOR_CONFIRM,string128);
	}
	else
	{
		format(string128,sizeof(string128),"{CC0000}[ERROR]:{C0C0C0} That player is an invalid target, or does not exist!");
		SendClientMessage(playerid,COLOR_ERROR,string128);
	}
	return 1;
	#pragma unused params
}

dcmd_god(const playerid, const params[]) {
    switch(godmode[playerid])
	{
	    case 0:
	    {
			if(!gTeam[playerid])
			{
				if(cantgod[playerid] == 0)
				{
					godmode[playerid] = 1;
					godtimer[playerid] = SetTimerEx("GodTimer",120000,0,"i",playerid);
					cantgod[playerid] = 1;
					GameTextForPlayer(playerid,"~n~~n~~y~GOD MODE ~g~ENABLED",4000,3);
				}
				else return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot use /god at this time. 2 min cooldown in effect");
				
			}
			else godmode[playerid] = 0;
	    }
	    case 1:
	    {
	        godmode[playerid] = 0;
	        GameTextForPlayer(playerid,"~n~~n~~y~GOD MODE ~r~DISABLED",4000,3);
	    }
    }
    ShowGodTD(playerid);
	return 1;
	#pragma unused params
}
dcmd_credits(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_CREDITS, DIALOG_STYLE_MSGBOX, "Everystuff Credtis","{FFFFFF}Main Script: {C0C0C0}kaisersouse,ziggy\n\n{FFFFFF}Filterscripts: {C0C0C0}h02,Y_Less,Kye,JernejL,Kane_Phoenix,Riccor,Sandra,Gagi,CyNiC,wizzi\n\n{FFFFFF}Plugins:{C0C0C0}Y_Less,BlueG,Incognito\n\n{FFFFFF}Maps:{C0C0C0}kaisersouse,ziggy,V1ceC1ty,Satan,Kaiser,cmg4life\n\n{FFFFFF}Founders:{C0C0C0}Jackson Lab Desktop Support Department,NASIOC.com SAMP crew\n\n{FFFFFF}Owners:{C0C0C0} kaisersouse + ziggy","Close","");
	return 1;
	#pragma unused params
}

dcmd_count(playerid, params[])
{
	return SendClientMessage(playerid, 0x77CC77FF, "{CC0000}[ERROR]:{C0C0C0} This command temporarily disabled");
/*
	if(!gTeam[playerid] && !RaceParticipant[playerid] && gblnCanCount[playerid] == true) // && more checks including: Is in a static race? Is a player in proximity already counting? ...
	{
		tmrCountDown = SetTimerEx("PCountDown", 1000, true, "i",playerid); // Timer will repeat every second.
		gblnCanCount[playerid] = false;
	}
	else SendClientMessage(playerid, 0x77CC77FF, "{CC0000}[ERROR]:{C0C0C0} You can't use /count at this time. Please wait or type {CC0000}/leave{C0C0C0} and try again.");
	return 1;
*/
	#pragma unused params

}

dcmd_skin(const playerid, const params[])
 {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new skin = strval(params);
    if(!strlen(params)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must provide a skinid ex: '/skin 299'. To choose by picture, type {CC0000}/pskin");
	if(!IsSkinValid(skin)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} Invalid skinid. Get the list here http://wiki.sa-mp.com/wiki/Skins:All");
//   	if(!IsSkinValid(skin)) return 1;
	else {
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
		{
			SetPlayerSkin(playerid,skin);
			pskin[playerid] = skin;
		}
		else SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be  on-foot to change skin");
	}

	return 1;
	#pragma unused params
}

dcmd_saveskin(const playerid, const params[])
 {
    if(Variables[playerid][LoggedIn])
    {
		SetUserInt(playerid,"Skin",pskin[playerid]);
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Your skin has been saved and will load when you /login");
	}
	else SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be logged in to save your skin");
	return 1;
	#pragma unused params
}

dcmd_key2(const playerid, const params[])
 {
	ShowPlayerDialog(playerid, D_KEY2, DIALOG_STYLE_LIST, "Choose extra cmd for 2 key","Remove extra command\n/flip\n/putramp\n/putskulls\nInsta-Stop","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_keyy(const playerid, const params[])
 {
	ShowPlayerDialog(playerid, D_KEYY, DIALOG_STYLE_LIST, "Choose extra cmd for Y key","Remove extra command\nTeleport Menu\nDM Menu\nCar Menu\nGun Menu","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_keyn(const playerid, const params[])
 {
	ShowPlayerDialog(playerid, D_KEYN, DIALOG_STYLE_LIST, "Choose extra cmd for N key","Remove extra command\nInsta-Stop Vehicle\nSpawn Stunt Ramp\nSpawn Bounce Mine\nSpawn Skulls Launcher\nFlip Vehicle\nEject From Vehicle","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_pcolor(const playerid, const params[])
 {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    ShowPlayerDialog(playerid, D_PCOLOR, DIALOG_STYLE_LIST, "Choose Name Color","{FF66FF}Pink\n{660000}Dark Red\n{0000BB}Blue\n{33CCFF}Light Blue\n{33AA33}Green\n{00FF7F}Light Green\n{FFFF00}Yellow\n{ADFF2F}Light Yellow\n{9933CC}Purple\n{EE82EE}Light Purple\n{FF9900}Orange\n{8B4513}Brown","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_setspawn(const playerid, const params[])
 {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    ShowPlayerDialog(playerid, D_SETSPAWN, DIALOG_STYLE_LIST, "Choose Default Respawn Location","Drift Area\nLS Airport\nAbandoned Airport\nMt Chililad\nSF Airport\nLV Airport\nLS Downtown\nSF Downtown\nLV Downtown\nDesert Town\nSex Shop\nRandom","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_spawn(const playerid, const params[])
 {
	dcmd_setspawn(playerid,params2);
	return 1;
	#pragma unused params
}

dcmd_nos(const playerid, const params[])
{
	if(IsInModVehicle(playerid))
	{
	    AddNosToVehicle(playerid,pvehicleid[playerid]);
	    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
    }
	
	return 1;
	#pragma unused params
}
dcmd_neon(const playerid, const params[])
{
	#if defined NEON
	if(IsInModVehicle(playerid))
	{
	    if(IsPlayerInAnyVehicle(playerid))
		{
			ShowPlayerDialog(playerid, D_NEON, DIALOG_STYLE_LIST, "Choose Neon Color - Neon (c)wizzi", "DarkBlue\nRed\nGreen\nWhite\nViolet\nYellow\nCyan\nLightBlue\nPink\nOrange\nLightGreen\nLightYellow\nDelete Neon", "Select", "Cancel");
			DestroyNeon(playerid);
		}
		else SendClientMessage(playerid,COLOR_RED,"{CC0000}[ERROR]:{C0C0C0} You must be in a vehicle to use this command!");
    }
	#else
	SendClientMessage(playerid,COLOR_RED,"{CC0000}[ERROR]:{C0C0C0} NEON SYSTEM TEMPORARILY DISABLED");
	#endif
	#pragma unused params
	return 1;
}

dcmd_horn(const playerid, const params[])
{
	if(horn[playerid])
	{
	    horn[playerid] = 0;
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Train horn is __OFF__");
	}
	else
	{
		horn[playerid] = 1;
	    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Train horn is ++ ON ++");
	}
	return 1;
	#pragma unused params
}

dcmd_helmet(const playerid, const params[])
{
    ShowPlayerDialog(playerid, D_HELMET, DIALOG_STYLE_LIST, "Choose Helmet", "{FFFFFF}Helmet 1\nHelmet 2\nHelmet 3\nHelmet 4\n - Remove Helmet", "Select", "Cancel");
    return 1;
    #pragma unused params
}
dcmd_snos(const playerid, const params[])
{
	if(hassnos[playerid])
	{
	    hassnos[playerid] = 0;
	    #if defined TEXTDRAWS
	    ShowSnosTD(playerid);
	    #endif //td
	    GameTextForPlayer(playerid,"~n~~w~SUPER NOS (SNOS)~n~~r~DISABLED!~w~",5000,4);
	    return 1;
	}
	else
	{
    	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
		GameTextForPlayer(playerid,"~n~~w~THE FASTER YOU TAP ~r~~k~~VEHICLE_FIREWEAPON_ALT~ ~w~~n~THE FASTER YOU GO!",5000,3);
		hassnos[playerid] = 1;
		#if defined TEXTDRAWS
		ShowSnosTD(playerid);
	    #endif //td
    	return 1;
//    	else return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You must be driving a vehicle to enable SUPER NOS");
	 }
	#pragma unused params
}
dcmd_chicken(const playerid, const params[])
{
	if(pinterior[playerid]) return SendClientMessage(playerid, COLOR_ERROR, "No room for chickens inside!");
	if(gTeam[playerid]) return SendClientMessage(playerid, COLOR_PINK, "{FF66FF}[TIP]:{C0C0C0} Chickens are a more peaceful type, mm hmmm.");
 	if(HasPlayerObject(playerid)) return DestroyObjectEx(playerid);
 	else CreateObjectEx(playerid,CHICKEN);
	return 1;
	#pragma unused params
}
dcmd_cow(const playerid, const params[])
{
	if(pinterior[playerid]) return SendClientMessage(playerid, COLOR_ERROR, "No room for cows inside!");
	if(gTeam[playerid] > 0) return SendClientMessage(playerid, COLOR_PINK, "{FF66FF}[TIP]:{C0C0C0} Cows are too lazy to DM. Besides, they tip easy.");
	if(HasPlayerObject(playerid)) return DestroyObjectEx(playerid);
 	else CreateObjectEx(playerid,COW);
	return 1;
	#pragma unused params
}
dcmd_putmine(const playerid, const params[])
{
	if(gTeam[playerid] > 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You're in a DM zone. Stop screwing with stunts and FIGHT!");
	if(HasPlayerObject(playerid)) return DestroyObjectEx(playerid);
 	else CreateObjectEx(playerid,MINE);
	return 1;
	#pragma unused params
}
dcmd_putramp(const playerid, const params[])
{
	if(gTeam[playerid] > 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You're in a DM zone. Stop screwing with stunts and FIGHT!");
	if(HasPlayerObject(playerid)) return DestroyObjectEx(playerid);
 	else CreateObjectEx(playerid,RAMP);
	return 1;
	#pragma unused params
}
dcmd_putskulls(const playerid, const params[])
{
	if(gTeam[playerid] > 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You're in a DM zone. Stop screwing with stunts and FIGHT!");
	DestroyPickup(skulls[playerid]);
	new Float:face;
	if(pstate[playerid] == PLAYER_STATE_ONFOOT)
	{
	    GetPlayerPos(playerid, playerx, playery, playerz);
	    GetPlayerFacingAngle(playerid,face);
	    GetXYInFrontOfPlayer(playerid, playerx, playery, 5);
	}
	else if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{
		GetVehiclePos(pvehicleid[playerid], playerx, playery, playerz);
	    GetVehicleZAngle(pvehicleid[playerid],face);
	    GetXYInFrontOfVehicle(pvehicleid[playerid], playerx, playery, 10);
	}
	skulls[playerid] = CreatePickup(1313,14,playerx,playery,playerz,0);
	return 1;
	#pragma unused params
}
dcmd_fight(const playerid, const params[])
{

	ShowPlayerDialog(playerid, D_FIGHT, DIALOG_STYLE_LIST, "Choose Fighting Style","Normal\nBoxing\nKung-Fu\nKnee+Head\nCaptain Kirk\nThrowin Elbows","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_wheels(const playerid, const params[])
{
	if(pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be driving a vehicle to use this command!");
	else ShowPlayerDialog(playerid, D_WHEELS, DIALOG_STYLE_LIST, "Upgrade Wheels","Off Road\nShadow\nMega\nRimshine\nWires\nClassic\nTwist\nCutter\nSwitch\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAccess","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_leave(const playerid, const params[])
{
    if(gTeam[playerid] >= 50 && gTeam[playerid] < 60)
    {
        GangZoneHideForPlayer(playerid,zoneFamily);
        GangZoneHideForPlayer(playerid,zoneBalla);
        GangZoneHideForPlayer(playerid,zoneVagos);
        GangZoneHideForPlayer(playerid,zoneAzteca);
    }
    SetPlayerTeam(playerid,0);
	gTeam[playerid] = 0;
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	if(pvehicleid[playerid] != INVALID_VEHICLE_ID) RemovePlayerFromVehicle(playerid);
	SetPlayerWorldBounds(playerid, 9999.00, -9999.00, 9999.00, -9999.00);
	DestroyObjectEx(playerid);
	if(afk[playerid]) afk[playerid] = 0;
	TogglePlayerControllable(playerid,true);
	#if defined RACES
	if(RaceParticipant[playerid]) LeaveRace(playerid);
	#endif // races
	ShowGodTD(playerid);
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,1,1);
	GivePlayerWeapon(playerid,31,99999);
	GivePlayerWeapon(playerid,12,1);
	SetPlayerSkin(playerid,pskin[playerid]);
	dcmd_airport(playerid,params2);
	return 1;
	#pragma unused params
}

dcmd_flip(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	#pragma unused params
    if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{ 
		new Float:X,Float:Y,Float:Z,Float:Angle;
		GetVehiclePos(pvehicleid[playerid],X,Y,Z);
		GetVehicleZAngle(pvehicleid[playerid],Angle);
		SetVehiclePos(pvehicleid[playerid],X,Y,Z+2); // NEVER EVER EVER USE SetVehiclePos>EX< for this. It will make ppl leave race + dm just for flipping car over
		SetVehicleZAngle(pvehicleid[playerid],Angle);
		return 1;
	} else return 1;
}
dcmd_stop(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	#pragma unused params
    if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{ 
		new Float:X,Float:Y,Float:Z,Float:Angle;
		GetVehiclePos(pvehicleid[playerid],X,Y,Z);
		GetVehicleZAngle(pvehicleid[playerid],Angle);
		SetVehiclePos(pvehicleid[playerid],X,Y,Z); // NEVER EVER EVER USE SetVehiclePos>EX< for this. It will make ppl leave race + dm just for flipping car over
		SetVehicleZAngle(pvehicleid[playerid],Angle);
		return 1;
	} else if((pstate[playerid] == PLAYER_STATE_ONFOOT || pstate[playerid] == PLAYER_STATE_SPAWNED) && jump[playerid] && IsPlayerAdmin(playerid))
	{
	    GetPlayerPos(playerid,playerx,playery,playerz);
		CreateObject(14,playerx,playery,playerz-1.0,0.0,0.0,0.0,100.0);

	}
	return 1;
}
dcmd_godcar(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	#pragma unused params
    if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID && !badcar[playerid])
	{ 
		SetVehicleHealth(pvehicleid[playerid],10000);
		return 1;
	}
	else return 1;
}

dcmd_fix(const playerid, const params[])
{
	dcmd_vr(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_vr(const playerid, const params[])
{
	if(pstate[playerid] != PLAYER_STATE_DRIVER && pstate[playerid] != PLAYER_STATE_PASSENGER) return 1;
	if(IsComplexVehicle(pvehicleid[playerid]))
	{
//		SendClientMessage(playerid, COLOR_RED, "VEHICLE REPAIR {CC0000}[ERROR]:{C0C0C0} You do not have a left-handed screwdriver.");
		return 1;
	}
	else if(pvehicleid[playerid] != INVALID_VEHICLE_ID)
	{
		RepairVehicle(pvehicleid[playerid]);
		
	}
	return 1;
	#pragma unused params
}
dcmd_acar(const playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new Float:x, Float:y, Float:z, Float:a;
	new idx,acar;
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid,a);
	string128 = strtok(params, idx);
	idx = GetVehicleModelIDFromName(params[1]);
	if(idx == -1) idx = strval(string128);
	acar = CreateVehicle(idx,x,y,z,a,-1,-1,300);
	SetVehicleVirtualWorld(acar,GetPlayerVirtualWorld(playerid));

	return 1;
	#pragma unused params
}

dcmd_rban(const playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} rban is for rcon admins only!");
	if(!strlen(params)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} I need a playerid to ban");
	else
	{
	    new idx;
		idx = strval(string128);
		if(IsPlayerNPC(idx)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can't ban NPCs!");
		if(IsPlayerConnected(idx) && idx != playerid && !IsPlayerAdmin(idx))
		{
		    Ban(idx);
		    format(string128,sizeof(string128),"RCON BAN - Banned %s playerid %i",pname[idx],idx);
		    printf(string128);
		}
	}
	return 1;
	#pragma unused params
}
dcmd_trucks(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_TRUCKS, DIALOG_STYLE_LIST, "Select Truck","Bobcat\nYosemite\nPatriot\nMonster\nJeep Wrangler\nSlamvan\nTow Truck\nRoadtrain\nWalton\nPacker\nMoonbeam\nBarracks\nFlatbed\nRancher\nSand King\nDakkar Truck\nCement Truck\nFire Truck\nFlatbed Truck\nDump Truck\nBulldozer\nCement Truck\nTrash Truck\nFlatbed Carrier", "Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_leftovers(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_LEFTOVERS, DIALOG_STYLE_LIST, "Select Whatever","Campers\nIce Cream\nHot Dog\nSecuriCar\nCity Bus\nAmbulance\nForklift\nCamper\nTractor\nCombine Harvester\nTow Truck\nGolf Kart\nKart\nVortex\nStairs\nBaggage\nMower\nSweeper\nVortex\nTug\nRomero\nStretch Limo\nArticle Trailer A\nArticle Trailer B\nArticle Trailer C", "Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_tuned(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_TUNED, DIALOG_STYLE_LIST, "Select Tuned Car","WRC Impreza\nAlien Sultan\nAccess Elegy\nX-Flo Flash\nAlien Uranus\nModded Club\nModded Blista\nTornado Lowrider\nSlamvan Lowrider", "Select", "Close");
	return 1;
	#pragma unused params
}

dcmd_car(const playerid, params[])
{
#if defined VEH_THUMBNAILS
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] && gTeam[playerid] < 50 && gTeam[playerid] > 56) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params))
	{
		DestroySelectionMenu(playerid);
	    SetPVarInt(playerid, "vspawner_active", 1);
	    //SetPVarInt(playerid, "vspawner_page", 0); // will reset the page back to the first
	    CreateSelectionMenu(playerid);
	    SelectTextDraw(playerid, 0xACCBF1FF);
    }
    else
	{
		new idx;
		string128 = strtok(params, idx);
		idx = GetVehicleModelIDFromName(params[1]);
		if(idx == -1) idx = strval(string128);
		CreatePlayerVehicle(playerid,idx);
	}
#else
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params))
	{
        ShowPlayerDialog(playerid, D_CAR, DIALOG_STYLE_LIST, "Select Vehicle Class","{FFFF00}Pre-Tuned Cars{FFFFFF}\nFast Cars\nMuscle Cars & Lowriders\n2-Door/Compact Cars\n4-Door/Luxury Cars\nBikes & Motorcycles\nCivil Servant & Transportation\nGovernment Vehicles\nHeavy Trucks & Utility\nLight Trucks & Vans\nRC Vehicles\nRecreational\nSUVs & Wagons\nTrailers\nPlanes & Helicopters\nBoats\nDestroy Current Vehicle ", "Select", "Close");
//		ShowPlayerDialog(playerid, D_CAR, DIALOG_STYLE_LIST, "Select Vehicle Class","Cars\nBikes\nTrucks\nLeftovers\nPlanes\nBoats\nDestroy Car ", "Select", "Close");
		SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} You can add the car name or id to spawn it directly. Ex: {FFFFFF}/car sultan{C0C0C0} or {FFFFFF} /car 522{C0C0C0}. List of ids at wiki.sa-mp.com/wiki/Category:Vehicle");
	}
	else
	{
		new idx;
		string128 = strtok(params, idx);
		idx = GetVehicleModelIDFromName(params[1]);
		if(idx == -1) idx = strval(string128);
		CreatePlayerVehicle(playerid,idx);
	}
#endif //veh_thumbnails
	return 1;
	#pragma unused params
}

dcmd_v(const playerid, params[])
{
	if((gTeam[playerid] && gTeam[playerid] < 50 && gTeam[playerid] > 56) ||afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params))
	{
        ShowPlayerDialog(playerid, D_CAR, DIALOG_STYLE_LIST, "Select Vehicle Class","{FFFF00}Browse by Thumbnail Image{FFFFFF}\n{FFFF00}Pre-Tuned Cars{FFFFFF}\nFast Cars\nMuscle Cars & Lowriders\n2-Door/Compact Cars\n4-Door/Luxury Cars\nBikes & Motorcycles\nCivil Servant & Transportation\nGovernment Vehicles\nHeavy Trucks & Utility\nLight Trucks & Vans\nRC Vehicles\nRecreational\nSUVs & Wagons\nTrailers\nPlanes & Helicopters\nBoats\nDestroy Current Vehicle ", "Select", "Close");
//		ShowPlayerDialog(playerid, D_CAR, DIALOG_STYLE_LIST, "Select Vehicle Class","Cars\nBikes\nTrucks\nLeftovers\nPlanes\nBoats\nDestroy Car ", "Select", "Close");
		SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} You can add the car name or id to spawn it directly. Ex: {FFFFFF}/car sultan{C0C0C0} or {FFFFFF} /car 522{C0C0C0}. List of ids at wiki.sa-mp.com/wiki/Category:Vehicle");
	}
	else
	{
		new idx;
		string128 = strtok(params, idx);
		idx = GetVehicleModelIDFromName(params[1]);
		if(idx == -1) idx = strval(string128);
		CreatePlayerVehicle(playerid,idx);
	}
	return 1;
	#pragma unused params
}
dcmd_fastcars(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VRACERS, DIALOG_STYLE_LIST, "= Street Racers =","Banshee 429\nBullet 541\nCheetah 415\nComet 480\nElegy 562\nFlash 565\nHotknife 434\nHotring Racer 494\nHotring Racer 2 502\nHotring Racer 3 503\nInfernus 411\nJester 559\nStratum 561\nSultan 560\nSuper GT 506\nTurismo 451\nUranus 558\nWindsor 555\nZR-350 477","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vmusclelow(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VMUSCLELOW, DIALOG_STYLE_LIST, "= Muscle Cars & Lowriders =","Blade 536\nBroadway 575\nRemington 534\nSavanna 567\nSlamvan 535\nTornado 576\nVoodoo 412\nBuffalo 402\nClover 542\nPhoenix 603\nSabre 475","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_v2door(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_V2DOOR, DIALOG_STYLE_LIST, "= 2-Door & Compact =","Alpha 602\nBlista Compact 496\nBravura 401\nBuccaneer 518\nCadrona 527\nClub 589\nEsperanto 419\nFeltzer 533\nFortune 526\nHermes 474\nHustler 545\nMajestic 517\nManana 410\nPicador 600\nPrevion 436\nStafford 580\nStallion 439\nTampa 549\nVirgo 491","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_v4door(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_V4DOOR, DIALOG_STYLE_LIST, "= 4-Door & Luxury =","Admiral 445\nDamaged Glendale 604\nElegant 507\nEmperor 585\nEuros 587\nGlendale 466\nGreenwood 492\nIntruder 546\nMerit 551\nNebula 516\nOceanic 467\nPremier 426\nPrimo 547\nSentinel 405\nStretch 409\nSunrise 550\nTahoma 566\nVincent 540\nWashington 421\nWillard 529","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_bikes(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VBIKES, DIALOG_STYLE_LIST, "= Bikes =","BF-400 581\nBike 509\nBMX 481\nFaggio 462\nFCR-900 521\nFreeway 463\nMountain Bike 510\nNRG-500 522\nPCJ-600 461\nPizza Boy 448\nSanchez 468\nWayfarer 586","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vcivil(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VCIVIL, DIALOG_STYLE_LIST, "= Civil Servant & Transportation =","Baggage 485\nBrown Streak 538\nBus 431\nCabbie 438\nCoach 437\nFreight 537\nSweeper 574\nTaxi 420\nTowtruck 525\nTrashmaster 408\nUtility Van 552","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vgovt(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VGOVT, DIALOG_STYLE_LIST, "= Government =","Ambulance 416\nBarracks 433\nEnforcer 427\nFBI Rancher 490\nFBI Truck 528\nFire Truck 407\nFire Truck (Ladder) 544\nHPV1000 523\nPatriot 470\nPolice Car (Las Venturas) 598\nPolice Car (Los Santos) 596\nPolice Car (San Fierro) 597\nPolice Ranger 599\nRhino 432\nS.W.A.T. 601\nSecuricar 428","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vhtruck(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VHTRUCK, DIALOG_STYLE_LIST, "= Heavy Trucks & Utility =","Benson 499\nBlack Boxville 609\nBoxville 498\nCement Truck 524\nCombine Harvester 532\nDFT-30 578\nDozer 486\nDumper 406\nDune 573\nFlatbed 455\nHotdog 588\nLinerunner 403\nLinerunner (From \"Tanker Commando\") 514\nMr. Whoopee 423\nMule 414\nPacker 443\nRoadtrain 515\nTractor 531\nYankee 456","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vltruck(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VLTRUCK, DIALOG_STYLE_LIST, "= Light Trucks & Vans =","Berkley's RC Van 459\nBobcat 422\nBurrito 482\nDamaged Sadler 605\nForklift 530\nMoonbeam 418\nMower 572\nNews Van 582\nPony 413\nRumpo 440\nSadler 543\nTug 583\nWalton 478\nYosemite 554","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vrccar(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VRCCAR, DIALOG_STYLE_LIST, "= RC Vehicles =","RC Bandit 441\nRC Baron 464\nRC Goblin 501\nRC Raider 465\nRC Tiger 564\nRC Cam 594","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vrec(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VREC, DIALOG_STYLE_LIST, "= Recreational =","Bandito 568\nBF Injection 424\nBloodring Banger 504\nCaddy 457\nCamper 483\nJourney 508\nKart 570\nMesa 500\nMonster 444\nMonster 2 556\nMonster 3 557\nQuadbike 471\nSandking 495\nVortex 539","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_vsuv(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VSUV, DIALOG_STYLE_LIST, "= SUVs & Wagons =","Huntley 579\nLandstalker 400\nPerennial 404\nRancher 489\nRancher (From \"Lure\") 505\nRegina 479\nRomero 442\nSolair 458","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_trailer(const playerid, params[])
{
	dcmd_vtrailer(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_vtrailer(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VTRAILER, DIALOG_STYLE_LIST, "= Trailers =","Baggage Trailer (covered) 606\nBaggage Trailer (Uncovered) 607\nFarm Trailer 610\n\"Street Clean\" Trailer 611\nTrailer (From \"Tanker Commando\") 608\nTrailer (Stairs) 435\nTrailer 1 450\nTrailer 2 591\nTrailer 3 591","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_plane(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VPLANE, DIALOG_STYLE_LIST, "= Aircraft =","Andromada 592\nAT-400 577\nBeagle 511\nCargobob 548\nCropduster 512\nDodo 593\nHunter 425\nHydra 520\nLeviathan 417\nMaverick 487\nNevada 553\nNews Chopper 488\nPolice Maverick 497\nRaindance 563\nRustler 476\nSeasparrow 447\nhamal 519\nSkimmer 460\nSparrow 469\nStuntplane 513","Select","Close");
	return 1;
	#pragma unused params
}
dcmd_boat(const playerid, params[])
{
	ShowPlayerDialog(playerid, D_VBOAT, DIALOG_STYLE_LIST, "= Boats =","Coastguard 472\nDinghy 473\nJetmax 493\nLaunch 595\nMarquis 484\nPredator 430\nReefer 453\nSpeeder 452\nSqualo 446\nTropic 454","Select","Close");
	return 1;
	#pragma unused params
}


//	Admiral,Alpha,Ambulance,Andromada,AT-400,Baggage,Baggage Trailer,Baggage Trailer 2,Bandito,Banshee,Barracks,Beagle,Benson,Berkley,BF Injection,BF-400,Bike,Boxville,Blade,Blista Compact,Bloodring,BMX,Bobcat,Boxville,Bravura,Broadway,Buccaneer,Buffalo,Bullet,Burrito,Bus,Cabbie,Caddy,Cadrona,Camper,Cargobob,Cement,
//  Cheetah,Clover,Club,Coach,Coastguard,Combine Harvester,Comet,Cropduster,Damaged Glendale,Damaged Sadler,DFT-30,Dinghy,Dodo,Dozer,Dumper,Dune,Elegant,Elegy,Emperor,Enforcer,Esperanto,Euros,Faggio,Farm Trailer,FBI Rancher,FBI Truck,FCR-900,Feltzer,Fire Truck,Fire Truck 2,Flash,Flatbed,Forklift,Fortune,Freeway,
//  Freight,Glendale,Greenwood,Hermes,Hotdog,Hotknife,Hotring,Hotring 2,Hotring 3,HPV1000,Huntley,Hustler,Infernus,Intruder,Jester,Jetmax,Journey,Kart,Landstalker,Launch,Leviathan,Linerunner,Linerunner 2,Majestic,Manana,Marquis,Maverick,Merit,Mesa,Monster,Monster 2,Monster 3,Moonbeam,Mountain Bike,Mower,Whoopee,Mule,
//  Nebula,Nevada,News Chopper,News Van,NRG-500,Oceanic,Packer,Patriot,PCJ-600,Perennial,Phoenix,Picador,Pizza Boy,Police LS,Police LV,PoliceSF,Police Maverick,Police Ranger,Pony,Predator,Premier,Previon,Primo,Quad,Raindance,Rancher,Rancher 2,RC Bandit,RC Baron,RC Cam,RC Goblin,RC Raider,RC Tiger,Reefer,Regina,
//  Remington,Rhino,Roadtrain,Romero,Rumpo,Rustler,S.W.A.T.,Sabre,Sadler,Sanchez,Sandking,Savanna,Securicar,Sentinel,Shamal,Skimmer,Slamvan,Solair,Sparrow,Speeder,Squalo,Stafford,Stairs,
//  Stallion,Stratum,StreetClean Trailer,Stretch,Stuntplane,Sultan,Sunrise,Super GT,Sweeper,Tahoma,Tampa,Taxi,Tornado,Towtruck,Tractor,Trailer 1,Trailer 2,Trailer 3,Trailer 4,Trashmaster,Tropic,Tug,Turismo,Uranus,Utility,Vincent,Virgo,Voodoo,Vortex,Walton,Washington,Wayfarer,Willard,Windsor,Yankee,Yosemite,ZR-35







dcmd_nrg(const playerid, params[])
{
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	else
	{
		CreatePlayerVehicle(playerid,522);
	}
	return 1;
	#pragma unused params
}

dcmd_weather(const playerid, const params[])
{
	dcmd_pweather(playerid,params2);

	return 1;
	#pragma unused params
}
dcmd_pweather(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} Please include a weather ID from 1 - 45 ex. '/pweather 8' You can use any number below 9999 at your own risk");
	else
	{
		new weather = strval(params);
		if(weather < 9999)
		{
			SetPlayerWeather(playerid,weather);
			SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Weather changed! Use '/pweather 10' to go back to original (sunny/dry) weather.");
		}
		else SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} That weather id invalid, or has not been tested for compatibility.");
	}
	#pragma unused params
	return 1;
}
dcmd_daynight(const playerid, const params[])
{
	if(daynight[playerid])
	{
		GameTextForPlayer(playerid,"Day/NIGHT CYCLE~n~~r~OFF",2000,3);
		daynight[playerid] = 0;
	}
	else
	{
		GameTextForPlayer(playerid,"Day/NIGHT CYCLE~n~~g~ON",2000,3);
		daynight[playerid] = 1;
	}
	#pragma unused params
	return 1;
}




dcmd_time(const playerid, const params[])
{
	dcmd_ptime(playerid,params2);
	#pragma unused params
	return 1;
}
dcmd_day(const playerid, const params[])
{
	SetPlayerTime(playerid,12,0);
	#pragma unused params
	return 1;
}
dcmd_rain(const playerid, const params[])
{
	SetPlayerWeather(playerid,8);
	#pragma unused params
	return 1;
}
dcmd_sun(const playerid, const params[])
{
	SetPlayerWeather(playerid,10);
	#pragma unused params
	return 1;
}
dcmd_night(const playerid, const params[])
{
	SetPlayerTime(playerid,23,0);
	#pragma unused params
	return 1;
}
dcmd_ptime(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_WEATHER, DIALOG_STYLE_LIST, "Choose Weather/Time","Sunny Day\nClear Night\nRainy Day\nRainy Night\nFoggy Day\nFoggy Night\nHOT Day\nSandstorm Day\nSandstorm Night\nPolluted Day\nPolluted Night","Select","Close");
	#pragma unused params
    return 1;
}
dcmd_dcar(const playerid, const params[])
{
	if(playercar[playerid] == INVALID_VEHICLE_ID && playertrailer[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You do not have a car to destroy. Type /car if you want a vehicle.");
	else KillPlayerVehicle(playerid);
	if(playercar[playerid] == INVALID_VEHICLE_ID) SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Your vehicle has been destroyed. You can spawn a new one using /car.");
	return 1;
#pragma unused params
}
dcmd_reserve(const playerid, const params[])
{
	if(playercar[playerid] == INVALID_VEHICLE_ID && playertrailer[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You do not have a car to reserve. Type /car if you want a vehicle.");
	else if(!reserve[playerid])
	{
	    reserve[playerid] = 1;
	    SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Your vehicle has been reserved and nobody can enter. Use /reserve again to unlock");
	}
	else
	{
		reserve[playerid] = 0;
		SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Your vehicle has been unlocked and people can enter. Use /reserve again to lock the vehicle");
	}
	return 1;
#pragma unused params
}
dcmd_wrc(const playerid, const params[])
{
    if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(afk[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type /afk to leave.");
  	CreatePlayerVehicle(playerid,560);
  	SendClientMessage(playerid,COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If you do not get a Subaru WRC Rally car, type /wrc again !!!");
  	if(playercar[playerid] != INVALID_VEHICLE_ID && pmodelid[playerid] == 560)
  	{
//	 	ChangeVehicleColor(playercar[playerid], 103, 103);
	 	ChangeVehiclePaintjob(playercar[playerid], 1); // "subaru wrc -ish sort-of" paint job
	 	AddVehicleComponent(playercar[playerid],1166); // alien front bumper
	 	AddVehicleComponent(playercar[playerid],1140); // xflo rear bumper
	 	AddVehicleComponent(playercar[playerid],1032); //alien roof vent
	 	AddVehicleComponent(playercar[playerid],1139); // xflow wing
	 	AddVehicleComponent(playercar[playerid],1030); // xflow sideskirt 1
	 	AddVehicleComponent(playercar[playerid],1031); //xflow sideskirt 2
	 	AddVehicleComponent(playercar[playerid],1080); // wheels 'switch'
	// 	AddVehicleComponent(playercar[playerid],1029); //xflow exhaust
		AddVehicleComponent(playercar[playerid],1086);
	 	SendClientMessage(playerid, COLOR_CONFIRM, "http://swrt.com");
	}
	return 1;
	#pragma unused params
}

dcmd_pc(const playerid, const params[]) {
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Parachutes! Don't leave home without them!");
	return 1;
	#pragma unused params
}

dcmd_sdance(const playerid, params[]) {
	if(!params[0]) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} To change dance style type '/sdance <0-4>'.{FFFFFF} Example: /sdance 1");
   	new id = strval(params);
	switch(id) {
		case 1: SetPlayerSpecialAction(playerid,5);
		case 2: SetPlayerSpecialAction(playerid,6);
		case 3: SetPlayerSpecialAction(playerid,7);
		case 4:	SetPlayerSpecialAction(playerid,8);
		default: SendClientMessage(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} dance type must be 1 - 4");
	}
	return 1;
}
dcmd_hsmoke(const playerid, const params[]) {
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
		LoopingAnim(playerid,"SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); //female
	}
	return 1;
	#pragma unused params
}
dcmd_porn(const playerid, const params[]) {
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		SetPlayerSkin(playerid,87);
		LoopingAnim(playerid,"CAR", "Fixn_Car_Loop", 4.0, 1, 0, 0, 0, 0);
	}
	return 1;
	#pragma unused params
}
dcmd_kill(const playerid, const params[]) {
//	if(pstate[playerid] == PLAYER_STATE_WASTED) return 1;
//	RemovePlayerFromVehicle(playerid);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
	SetPlayerHealth(playerid, 0);
	SetPlayerVirtualWorld(playerid,0);
	return 1;
	#pragma unused params
}
dcmd_magic(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	GetPlayerPos(playerid,playerx,playery,playerz);
	GetXYInFrontOfPlayer(playerid, playerx, playery, 25);
	CreateExplosion(playerx,playery,playerz,11,10);
	return 1;
	#pragma unused params
}

dcmd_jihad(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(playercar[playerid] != INVALID_VEHICLE_ID)
	{
		godmode[playerid] = 0;
		ShowGodTD(playerid);
		GetVehiclePos(playercar[playerid],playerx,playery,playerz);
		CreateExplosion(playerx,playery,playerz,2,15);
		CreateExplosion(playerx+1,playery-1,playerz,2,15);
		CreateExplosion(playerx-1,playery+1,playerz,2,15);
		if(IsPlayerInVehicle(playerid,playercar[playerid])) SetPlayerHealth(playerid,0);
		dcmd_dcar(playerid,params2);
	}
	else return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You may only blow-up cars you've created.");
	
	return 1;
	#pragma unused params
}
dcmd_findcar(const playerid, const params[])
{
	if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    if(!playercar[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You do not have a car to teleport to. Use /car or /v to create a vehicle");
	else
	{
		new Float:x, Float:y, Float:z;
	    GetVehiclePos(playercar[playerid],x,y,z);
	    SetPlayerPosEx(playerid,x,y,z+5);

	}
	return 1;
	#pragma unused params
}

dcmd_getcar(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER)
	{
		if(pvehicleid[playerid] != playercar[playerid])	RemovePlayerFromVehicle(pvehicleid[playerid]);
	}
	if(playercar[playerid] != INVALID_VEHICLE_ID)
	{
		new Float:x,Float:y,Float:z,Float:a;
		foreach(Player,i)
		{
		    if(IsPlayerInVehicle(i,playercar[playerid]) && i != playerid)
		    {
				RemovePlayerFromVehicle(i);
				GetPlayerPos(i,playerx,playery,playerz);
				SetPlayerPos(i,playerx,playery,playerz);
			}
		}
		GetPlayerPos(playerid,x,y,z);
		GetPlayerFacingAngle(playerid,a);
		GetXYInFrontOfPlayer(playerid, x, y, 3);
		SetVehiclePos(playercar[playerid],x,y,z);
		SetVehicleZAngle(playercar[playerid],a+45.0);
		new model = GetVehicleModel(playercar[playerid]);
		new trailer;
		switch(model)
		{
			case 435,450,584,591,606,607,608,610,611: trailer = 1; //trailer
		}
		if(trailer) PutPlayerInVehicle(playerid,playercar[playerid],0);
	}
	return 1;
	#pragma unused params
}

dcmd_color(const playerid, const params[])
{
	if(pvehicleid[playerid] == INVALID_VEHICLE_ID || pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be in a vehicle to use this command");
	else
	{
		ShowPlayerDialog(playerid, D_COLOR, DIALOG_STYLE_LIST, "Vehicle Quick Color","Black\nWhite\nGrey\nBlue\nRed\nYellow\nGreen\nPurple\nBright Green\nBright Red\nKing Blue\nNeon Purple\nBarbie Pink", "Select", "Close");
		SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} You can change BOTH car colors (primary and secondary) by using {FFFFFF}/cc");
	}
	return 1;
	#pragma unused params
}
dcmd_cc(playerid,params[])
{
//	if(!strlen(params)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must specify TWO color codes! ex: '/cc 3 200'");

	new c1,c2;
	if (sscanf(params, "ii", c1, c2)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must specify TWO color codes! ex: '/cc 3 200'");
	else if(pvehicleid[playerid] == INVALID_VEHICLE_ID) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can only use this command while driving a vehicle!");
	else if((c1 < 0 || c1 > 255) || (c2 < 0 || c2 > 255)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can only use color codes 0 thru 255");
	else
	{
		ChangeVehicleColor(pvehicleid[playerid],c1,c2);
	}
	return 1;
	#pragma unused params
}



dcmd_colortest(const playerid, const params[])
{
	SendClientMessage(playerid,COLOR_SYSTEM,"{C0C0C0} This is GREY text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{9933CC} This is PURPLE text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{33AA33} This is GREEN text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{CC0000} This is RED text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{FFFF00} This is YELLOW text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{FF66FF} This is PINK text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{0000BB} This is BLUE text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{33CCFF} This is LIGHTBLUE text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{660000} This is DARKRED text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{FF9900} This is ORANGE text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{FF00FF} This is MAGENTA text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{7CFC00} This is BRIGHTGREEN text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{000080} This is DARKBLUE text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{DB7093} This is VIOLETRED text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{8B4513} This is BROWN text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{ADFF2F} This is GREENYELLOW text! lower case UPPER CASE [12345]");
	SendClientMessage(playerid,COLOR_SYSTEM,"{C0C0C0} This is SILVER text! lower case UPPER CASE [12345]");

	return 1;
	#pragma unused params
}



dcmd_paintjob(const playerid, const params[])
{
	if(pvehicleid[playerid] == INVALID_VEHICLE_ID || pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be in a vehicle to use this command");
	else if(pstate[playerid] == PLAYER_STATE_DRIVER) ShowPlayerDialog(playerid, D_PAINTJOB, DIALOG_STYLE_LIST, "Select Paint Job","Paint Job 1\nPaint Job 2\nPaint Job 3\nPaint Job 4 (certain cars)\nPaint Job 5 (certain cars)","Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_plate(const playerid, const params[])
{
	if(pvehicleid[playerid] == INVALID_VEHICLE_ID || pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be in a vehicle to use this command");
	else if(pstate[playerid] == PLAYER_STATE_DRIVER) ShowPlayerDialog(playerid, D_PLATE,DIALOG_STYLE_INPUT,"Enter stream URL","License plate string limits:\n\n{FF0000}32 characters, A-Z a-z 0-9{FFFFFF}","Set Plate Text","Cancel");
	return 1;
	#pragma unused params
}
dcmd_paintj(const playerid, const params[])
{
	dcmd_paintjob(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_rules(const playerid, const params[])
{
	ShowPlayerDialog(playerid, D_RULES, DIALOG_STYLE_MSGBOX, "Everystuff Rules","-You dont need hacks here, trust us \n-No spamming+No server advertising (permaban)\n-You will get shot at. THIS IS GTA! Whining sucks.\n-Just have fun! If you're not, tell us at everystuff.net","Play!", "");
	return 1;
	#pragma unused params
}
dcmd_junk(const playerid, const params[])
{
	new panels,doors,lights,tires;
	GetVehicleDamageStatus(pvehicleid[playerid],panels,doors,lights,tires);
	format(string128,sizeof(string128),"panels:_%d doors:_%d lights:_%d tires:_%d",panels,doors,lights,tires);
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid]  != INVALID_VEHICLE_ID) UpdateVehicleDamageStatus(pvehicleid[playerid],322372134,67371524,67371524,15);
	return 1;
	#pragma unused params

}





//==============================================================================
//-----------------------------  TELEPORTS  ------------------------------------
//dcmd commands
//==============================================================================


dcmd_savepos(const playerid, const params[])
{
	if(afk[playerid])
	{
		//dcmd_random(playerid,params2);
		return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type /afk to leave.");
	}
	else if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	GetPlayerPos(playerid,saveposx[playerid],saveposy[playerid],saveposz[playerid]);
	saveint[playerid] = GetPlayerInterior(playerid);
	SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Position saved. Please use /back to return here!");
	GameTextForPlayer(playerid,"~w~USE /BACK TO RETURN HERE",3000,3);
	return 1;
	#pragma unused params
}
dcmd_back(const playerid, const params[])
{
	if(afk[playerid])
	{
		dcmd_random(playerid,params2);
		return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in AFK mode. Type /afk to leave.");
	}
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	SetPlayerPos(playerid,saveposx[playerid],saveposy[playerid],saveposz[playerid]);
	SetPlayerInterior(playerid,saveint[playerid]);
	return 1;
	#pragma unused params
}
dcmd_dm(const playerid, const params[])
{
	if(HasPlayerObject(playerid)) DestroyObjectEx(playerid);
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(pstate[playerid] == PLAYER_STATE_DRIVER) RemovePlayerFromVehicle(playerid);
	new gang,de,ship,war,flame,sawn,snipe,rpg,mini,kat,home;
	foreach(Player,i)
	{
		switch(gTeam[i])
		{
			case 5: war++;
			case 7: sawn++;
			case 8: snipe++;
			case 9: rpg++;
			case 10: mini++;
			case 13: home++;
			case 17: flame++;
			case 18: ship++;
			case 20: kat++;
			case 21: de++;
			case 50,51,52,53,54,55,56,57: gang++;
		}
	
	}
	format(string256,sizeof(string256),"Gang War (%i)\nDesert Eagle (%i)\nContainer Ship (%i)\nMilitary War (%i)\nFlamethrower (%i)\nSawnOff (%i)\nSniper (%i)\nRPG Arena (%i)\nMinigun (%i)\nKatana (%i)\nHome Invasion (%i)",gang,de,ship,war,flame,sawn,snipe,rpg,mini,kat,home);
	ShowPlayerDialog(playerid, D_DM, DIALOG_STYLE_LIST, "DM Areas (type /leave to exit DM)",string256, "Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_gang(const playerid, const params[])
{
	if(HasPlayerObject(playerid)) DestroyObjectEx(playerid);
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(pstate[playerid] == PLAYER_STATE_DRIVER) RemovePlayerFromVehicle(playerid);
//	if(!strlen(params)) ShowPlayerDialog(playerid, D_GANG, DIALOG_STYLE_LIST, "Choose Gang", "Grove St Families\nThe Ballas\nVarios Los Aztecas\nLos Santos Vagos\nSan Fierro Rifa\nTriads\nDa Nang Boys\nThe Mafia */","Select", "Close");
	new family,balla,azteca,vagos,rifa,triad,danang,mafia;
	foreach(Player,i)
	{
	    if(gTeam[i] == 50) family++;
	    else if(gTeam[i] == 51) balla++;
	    else if(gTeam[i] == 52) vagos++;
	    else if(gTeam[i] == 53) azteca++;
	    else if(gTeam[i] == 54) rifa++;
	    else if(gTeam[i] == 55) triad++;
	    else if(gTeam[i] == 56) danang++;
	    else if(gTeam[i] == 57) mafia++;
	}
	format(string256,sizeof(string256),"Grove St (LS) - ( %i )\nBalla (LS) - ( %i )\nAztecas (LS) - ( %i )\nVagos (LS) - ( %i )\nRifa (SF) - ( %i )\nTriad (SF) - ( %i )\nDaNang (SF) - ( %i )\nMafia (SF) - ( %i )",family,balla,azteca,vagos,rifa,triad,danang,mafia);
	ShowPlayerDialog(playerid, D_GANG, DIALOG_STYLE_LIST, "Choose Gang", string256,"Select", "Close");
//	ShowPlayerDialog(playerid, D_GANG, DIALOG_STYLE_LIST, "Choose Gang", "Grove St Families (LS)\nThe Ballas (LS)\nVarios Los Aztecas (LS)\nLos Santos Vagos (LS)","Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_sp(const playerid, const params[])
{
	dcmd_savepos(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_lp(const playerid, const params[])
{
	dcmd_back(playerid,params2);
	return 1;
	#pragma unused params
}

dcmd_basejump(const playerid, const params[])
{
    if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params)) ShowPlayerDialog(playerid, D_BASEJUMP, DIALOG_STYLE_LIST, "Select Basejump","Jump 1\nJump 2\nJump 3\nJump 4\nJump 5\nJump 6\nJump 7\nJump 8\nJump 9\nJump 10", "Select", "Close");
	return 1;
	#pragma unused params
}
dcmd_casino(const playerid, const params[])
{
    if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(!strlen(params)) ShowPlayerDialog(playerid, D_CASINO, DIALOG_STYLE_LIST, "Select Casino","Caligula's\nFour Dragons\nSmall Casino", "Select", "Close");
	return 1;
	#pragma unused params
}


dcmd_train(const playerid, const params[]) {
    if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) RemovePlayerFromVehicle(playerid);
	if(!strlen(params)) ShowPlayerDialog(playerid, D_TRAINS, DIALOG_STYLE_LIST, "Select Train Station","Cranberry Station\nSobell Rail Yards\nUnity Station\nDesert Trams\nFind nearest train", "Select", "Close");
	return 1;
	#pragma unused params
}

dcmd_casino1(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    SetPlayerPosEx(playerid, 2235.1851,1677.9374,1008.3594,0.0,1);
    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0}Welcome to the /casino");
	return 1;
	#pragma unused params
}
dcmd_casino2(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    SetPlayerPosEx(playerid, 1994.7236,1017.8349,994.8906,0.0,10);
    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0}Wlecome to the /casino");
	return 1;
	#pragma unused params
}
dcmd_casino3(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    SetPlayerPosEx(playerid, 1118.8878,-10.2737,1002.0859,0.0,12);
    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0}Welcome to the /casino");
	return 1;
	#pragma unused params
}
dcmd_derby(const playerid, const params[])
{
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],-2057.7366,-171.0241,35.3203,181.1907,0);
	else SetPlayerPosEx(playerid,-2066.5347,-108.9558,40.3674,180.0);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} SF Demolition Derby. (/derby)");
	SendClientMessage(playerid, COLOR_PINK, "{FF66FF}[TIP]:{C0C0C0} Type /car or /v to get a vehicle if you need one.");
	return 1;
	#pragma unused params
}
dcmd_cannon(const playerid, const params[]) {
	if(afk[playerid]) dcmd_afk(playerid,params2);
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePos(pvehicleid[playerid],-499.3635,2578.3311,53.2842);
	else SetPlayerPosEx(playerid,-516.7750,2596.8813,53.4154);
	SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Welcome to /cannon");
	GameTextForPlayer(playerid,"\n\n\n\n\n~w~Back into the pipe!!",5000,4);
	return 1;
	#pragma unused params
}
dcmd_ammu(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid,2332.9482,61.5840,26.7058);
	return 1;
	#pragma unused params
}
dcmd_center(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if((pstate[playerid] == PLAYER_STATE_DRIVER) && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],0.0,0.0,12.0469,0.0,0);
	else SetPlayerPosEx(playerid,0.0,0.0, 13.1484,0.0,0);
	return 1;
	#pragma unused params
}
dcmd_random(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	new rand = random(sizeof(gRandomStuntSpawn));
	SetPlayerPos(playerid,gRandomStuntSpawn[rand][0], gRandomStuntSpawn[rand][1], gRandomStuntSpawn[rand][2]);
	SetPlayerFacingAngle(playerid,gRandomStuntSpawn[rand][3]);
	SetPlayerVirtualWorld(playerid,0);
	return 1;
	#pragma unused params
}
dcmd_jizzys(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-2637.69,1404.24,906.46,0.0,3);
	return 1;
	#pragma unused params
}
dcmd_jefferson(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,2220.26,-1148.01,1025.80,0.0,15);
	return 1;
	#pragma unused params
}
dcmd_range(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,280.795104,-135.203353,1004.062500,0.0,7);
	return 1;
	#pragma unused params
}

dcmd_cracklab(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,2567.52,-1294.59,1063.25,0.0,2);
	return 1;
	#pragma unused params
}
	
dcmd_fiabag(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-1855.568725,41.263156,1061.143554,0.0,14);
	return 1;
	#pragma unused params
}


dcmd_donut(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,376.99,-191.21,1000.63,0.0,17);
	return 1;
	#pragma unused params
}
dcmd_pigpen(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,1211.3499,-14.2418,1000.9219,347.1840,2);
	return 1;
	#pragma unused params
}


dcmd_sfdt(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-1657.7234,1208.3746,7.2500,324.7836,0);
	return 1;
	#pragma unused params
}
dcmd_lvdt(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if((pstate[playerid] == PLAYER_STATE_DRIVER) && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],2136.4712,1518.0931,10.5450,39.5438,0);
	else SetPlayerPosEx(playerid,2000.3947,1521.6113,17.0682,306.8160,0);
	return 1;
	#pragma unused params
}

dcmd_carson(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-118.9516,1135.8514,19.7422,27.3856,0);
	return 1;
	#pragma unused params
}

dcmd_blueberry(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,246.2927,-120.9116,2.1790,115.7882,0);
	return 1;
	#pragma unused params
}

dcmd_elquebrados(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-1479.0807,2638.8364,58.7879,357.5977,0);
	return 1;
	#pragma unused params
}

dcmd_angelpine(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,-2154.7009,-2394.1423,30.6250,85.3763,0);
	return 1;
	#pragma unused params
}

dcmd_palomino(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,2351.2925,65.6519,26.4844,85.3763,0);
	return 1;
	#pragma unused params
}
dcmd_montgomery(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,1300.3727,253.7891,19.5547,59.4320,0);
	return 1;
	#pragma unused params
}
dcmd_dilimore(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	else SetPlayerPosEx(playerid,655.5323,-575.0356,16.3359,109.3987,0);
	return 1;
	#pragma unused params
}

dcmd_ls(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if((pstate[playerid] == PLAYER_STATE_DRIVER) && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],1511.2477,-1701.0334,14.0469,0.0,0);
	else SetPlayerPosEx(playerid,1480.1976,-1640.7338, 14.1484,0.0,0);
	return 1;
	#pragma unused params
}


dcmd_sfa(const playerid, const params[])
{
	dcmd_sf(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_sf(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],-1686.5302,-420.0526,16.1402,0.0,0);
    else SetPlayerPosEx(playerid,-1658.0809,-414.6946,14.1484,0.0,0);
	return 1;
	#pragma unused params
}
dcmd_lva(const playerid, const params[])
{
	dcmd_lv(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_lv(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],1636.5375,1528.9907,10.6588,37.2188,0);
	else SetPlayerPosEx(playerid,1632.2267,1630.8087,14.8222,97.5312,0);
	return 1;
	#pragma unused params
}
dcmd_desert(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],-396.8278,2236.2295,42.4297,0.0,0);
	else SetPlayerPosEx(playerid,-374.2741,2242.7312,48.0599,0.0,0);
	return 1;
	#pragma unused params
}
dcmd_sfd(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid,-1931.2686,1113.1986,49.9238,317.0492,0);
	return 1;
	#pragma unused params
}
dcmd_lvstrip(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid,2109.2886,1699.4972,10.8203,78.4591,0);
	return 1;
	#pragma unused params
}
dcmd_drift(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],-298.7027,1531.9520,75.3594,179.8108,0);
	else SetPlayerPosEx(playerid, -323.5591,1526.9297,75.3570,225.4534,0);
	return 1;
	#pragma unused params
}
dcmd_skydive(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 1951.4064,-2436.0005,1000.0000);
	SendClientMessage(playerid, 0xFFFF00AA, "You brought the parachute, right?");
	return 1;
	#pragma unused params
}
dcmd_warehouse(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 2131.1143,-2280.1877,20.6643);
	return 1;
	#pragma unused params
}
dcmd_rctrack(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -972.4957,1060.9830,1345.6693,0.0,10);
	return 1;
	#pragma unused params
}
dcmd_bikepark(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    SetPlayerPosEx(playerid, 1920.5529,-1356.7454,14.8103);
	return 1;
	#pragma unused params
}
dcmd_beach(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
  	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],-2644.2087,-2320.5828,9.0734,129.7213,0);
    else SetPlayerPosEx(playerid, -2644.2087,-2320.5828,9.0734,129.7213,0);
    PlayerPlaySound(playerid,6200,0.0,0.0,0.0);
	return 1;
	#pragma unused params
}
dcmd_basejump1(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
  	SetPlayerPosEx(playerid, 1574.8966,-1249.2684,277.8787);
	return 1;
	#pragma unused params
}
dcmd_basejump2(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 1539.4971,-1371.4875,328.3436);
	return 1;
	#pragma unused params
}
dcmd_basejump3(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -225.1428,1393.6865,172.4141);
	return 1;
	#pragma unused params
}
dcmd_basejump4(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -2872.1931,2606.3821,271.5319);
	return 1;
	#pragma unused params
}
dcmd_basejump5(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -341.6077,1601.4565,164.4840);
	return 1;
	#pragma unused params
}
dcmd_xmas(const playerid, const params[])
{
	SetPlayerPosEx(playerid,-193.8122,0.4493,4.5877,169.4548,0);
	return 1;
	#pragma unused params
}
dcmd_chiliad(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -2338.4250,-1642.5349,485.7031,271.1169,0);
	else SetPlayerPosEx(playerid, -2339.4900,-1675.5247,484.1562,357.8905,0);
	SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Mt. Chiliad - Au Natural area. Use /putramp to spawn a ramp wherever you want");
	return 1;
	#pragma unused params
}
dcmd_chilliad(const playerid, const params[]) {
	dcmd_chiliad(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_ch(const playerid, const params[]) {
	dcmd_chiliad(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_lsa(const playerid, const params[])
{
	dcmd_airport(playerid,params2);
	return 1;
	#pragma unused params
}
dcmd_airport(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],1995.7456,-2274.1943,13.5469,88.7995,0);
    else SetPlayerPosEx(playerid, 1899.6129,-2240.0889,13.5469,255.5154,0);
    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Los Santos Airport");
	return 1;
	#pragma unused params
}
dcmd_tpallow(const playerid, const params[]) {
//	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(tpallow[playerid] == 0) // dont allow
	{
		tpallow[playerid] = 1;
        SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[TP OPEN]:{C0C0C0} Players can teleport to you using the /tp command. Use /tpdeny to disable");

	} 
    else //OPEN
	{
        SendClientMessage(playerid,COLOR_CONFIRM,"{FFFF00}You are already allowing teleport. Type /tpdeny to STOP people from teleporting to you.");

	} 
    
	return 1;
	#pragma unused params
}
dcmd_tpdeny(const playerid, const params[]) {
//	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(tpallow[playerid] == 0) // dont allow
	{
		return SendClientMessage(playerid,COLOR_CONFIRM,"{FFFF00}You are already denying teleport. Type /tpallow to allow other players to teleport to you.");

	}
    else //OPEN
	{
        tpallow[playerid] = 0;
        SendClientMessage(playerid,COLOR_CONFIRM,"{FFFF00}[TP CLOSED]:{C0C0C0} Players can no longer teleport to you.  Use /tpallow to allow other people to teleport to your location");

	}

	return 1;
	#pragma unused params
}
dcmd_tp(const playerid, params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
   	new id = strval(params);
	if(!strlen(params)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must include a playerid to teleport to. ex: '/tp 32'");
	if(!tpallow[id]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0} That player isn't allowing teleport. They must type /tpallow before you can teleport to them");
	if(gTeam[id] || RaceParticipant[id]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0} That player is currently in a DM/Race area and cannot be teleported to. They must use /leave first.");
	if(id == playerid) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0} You can't teleport to yourself or you'll grow hair on your palms and go blind!");
	GetPlayerPos(id,playerx,playery,playerz);
	new w = GetPlayerVirtualWorld(id);
	new in = GetPlayerInterior(id);
	SetPlayerPosEx(playerid,playerx,playery+2,playerz,0.0,in);
	SetPlayerVirtualWorld(playerid,w);
	SendClientMessage(id,COLOR_CONFIRM,"{FFFF00}SURPRISE BUTSECKS!{C0C0C0} Someone has teleported to your position!");
	return 1;
	#pragma unused params
}
dcmd_myworld(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehicleVirtualWorld(pvehicleid[playerid],playerid);
    SetPlayerVirtualWorld(playerid,playerid);
    SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Welcome to your own little world! Type /kill to leave it. Joining DM may spit you back to main world");
	return 1;
	#pragma unused params
}
dcmd_rallyup(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -2409.2947,-2190.0410,34.0391,0);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Can I kick the tiiiires??");
	return 1;
	#pragma unused params
}

dcmd_trucker(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid,90.9267,-253.6381,8.2663,142.4283,0);
	return 1;
	#pragma unused params

}
dcmd_boneyard(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], 416.5591,2552.4424,15.9077,21.2,0);
	else SetPlayerPosEx(playerid, 400.2046,2543.4763,19.7737,107.685,0);
	SendClientMessage(playerid,COLOR_CONFIRM,"{33AA33}[CONFIRM]:{C0C0C0} Everystuff Airplane Boneyard");
	return 1;
	#pragma unused params
}
dcmd_aa(const playerid, const params[]) {
	dcmd_boneyard(playerid,params2);
	return 1;
	#pragma unused params
}

dcmd_stuntcity(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
   	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid]) SetVehiclePosEx(playerid,pvehicleid[playerid], 4364.5054,-1852.0548,4.0630,87.8386,0);
	else SetPlayerPosEx(playerid, 4416.9390,-1875.7889,7.0548,0);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Stunt City by cmg4life");
 	return 1;
	#pragma unused params
}

dcmd_dirtpit(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 563.2621,914.0405,-42.9609);
	return 1;
	#pragma unused params
}
dcmd_underwater(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
//	if(pvehicleid[playerid] == INVALID_VEHICLE_ID || pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be in a vehicle to use this command");
	if(pstate[playerid] == PLAYER_STATE_ONFOOT) SetPlayerPosEx(playerid,-398.3980,472.3730,-37.7293,115.9318,0);
	else
	{
		SetVehiclePos(pvehicleid[playerid], -398.3980,472.3730,-37.7293);
	}
	return 1;
	#pragma unused params
}
dcmd_pyramid(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 2355.9192,1512.0405,42.8203);
	return 1;
	#pragma unused params
}
dcmd_area69(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	SetPlayerPosEx(playerid, 213.9076,1895.2288,16.3227);
	return 1;
	#pragma unused params
}
dcmd_silodm(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");

	SetPlayerPosEx(playerid, 270.0655,1883.5199,-30.0938);
	return 1;
	#pragma unused params
}

dcmd_boardwalk(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 850.5974,-1841.2968,12.6037);
	return 1;
	#pragma unused params
}
dcmd_funpark(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 381.4741,-2051.8933,7.8359);
	return 1;
	#pragma unused params
}
dcmd_locos(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 2645.3501,-2014.5208,13.5579);
	return 1;
	#pragma unused params
}
dcmd_waa(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, -2689.2144,217.7596,4.1797);
	return 1;
	#pragma unused params
}
dcmd_canal(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 2559.4148,-2169.0544,-0.2188,226.7265);
	return 1;
	#pragma unused params
}


dcmd_basketcar(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	SetPlayerPosEx(playerid, 3168.371826, -2002.693847, 229.971847);
	return 1;
	#pragma unused params
}
dcmd_loopramp(const playerid, const params[]) {
    if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid]) return SetVehiclePosEx(playerid,pvehicleid[playerid],-476.3935,255.4290,3077.3452,314.1741);
    else SetPlayerPosEx(playerid, -450.770,293.395,3077.877,90.0);
    return 1;
    #pragma unused params
}
dcmd_ramp(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if (IsPlayerInAnyVehicle(playerid))
	{
		SetPlayerInterior(playerid,0);
    	SetPlayerVirtualWorld(playerid,0);
    	SetVehiclePos(pvehicleid[playerid], -695.9377,2349.9016,127.6754);
    	SetVehicleZAngle(pvehicleid[playerid], 155.0886);
    	return 1;
	}
	else
	{
		SetPlayerPosEx(playerid, -658.0438,2300.2881,135.8234);
		return 1;
		#pragma unused params
	}
}
dcmd_halfpipe(const playerid, const params[]) {
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if (IsPlayerInAnyVehicle(playerid))
	{
		SetPlayerInterior(playerid,0);
    	SetPlayerVirtualWorld(playerid,0);
    	SetVehiclePos(pvehicleid[playerid], 764.4882,1465.5038,125.5416);
    	SetVehicleZAngle(pvehicleid[playerid], 269.2);
    	return 1;
	}
	else
	{
		SetPlayerPosEx(playerid, 789.6534,1477.1600,125.5416,269.2067);
		return 1;
		#pragma unused params
	}
}
dcmd_skyway(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER) SetVehiclePosEx(playerid,pvehicleid[playerid],1180.8701,-554.2407,265.9353);
	else SetPlayerPosEx(playerid, 1180.8701,-554.2407,265.9353,69.3);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Skyway by Kaiser (nasioc.com) Type /car or /v to get a vehicle if you need one.");
	return 1;
	#pragma unused params
}

dcmd_roller(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -2350.730713, 915.038147, 519.016357,93.0);
	else SetPlayerPosEx(playerid,-2350.730713, 915.038147, 519.016357,270.0);
	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Stunt Roller Coaster by cmg4life. Type /car or /v to get a vehicle if you need one.");
	return 1;
	#pragma unused params
}

dcmd_tuner(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        SendClientMessage(playerid, 0xFFFF00AA, "You must be in a vehicle!");
        return 1;
    }
    new vehicleid = GetPlayerVehicleID(playerid);
    new modelid = GetVehicleModel(vehicleid);
    new modplace;
    switch (modelid)
    {
        case 432,425,520,447:         modplace = 1; // War Vehicles
        case 560,562,561,558,565,559: modplace = 2; // WAA
        case 534,535,536,567,575,576: modplace = 3; // LLC
        case 401,402,404,405,
             409,410,411,412,415,418,
             419,420,421,422,426,429,
             436,438,439,442,445,451,
             458,466,467,474,475,477,
             478,479,480,489,491,492,
             496,500,506,507,516,517,
             518,526,527,529,533,540,
             541,542,545,546,547,549,
             550,551,555,566,579,580,
             585,587,589,600,602,603: modplace = 4; // TF
        default:modplace = 0;
    }
    switch (modplace)
    {
        case 1:GameTextForPlayer(playerid,"\n\n\n\n\n~w~I can't let you do that Dave.",5000,4);
        case 2:
        {
            SetVehiclePos(vehicleid, -2689.2144,217.7596,4.1797);
            SetVehicleZAngle(vehicleid, 90.0000);
//            SetPlayerInterior(playerid,0);
            GameTextForPlayer(playerid,"Wheel Arch Angels",5000,5);
        }
        case 3:
        {
            SetVehiclePos(vehicleid, 2645.3501,-2014.5208,13.5579);
            SetVehicleZAngle(vehicleid, 169.2511);
 //           SetPlayerInterior(playerid,0);
            GameTextForPlayer(playerid,"Locos Low",5000,5);
        }
        case 4:
        {
            SetVehiclePos(vehicleid, -1917.6486,222.2715,35.0352);
            SetVehicleZAngle(vehicleid, 50.3251);
//            SetPlayerInterior(playerid,0);
            GameTextForPlayer(playerid,"Transfender",5000,5);
        }
        default:SendClientMessage(playerid, 0xFFFF00AA, "No Mod Shop will touch this piece of shit. Are you kidding me?");
    }
    return 1;
    #pragma unused params
}

//      _______________________________
//   INTERIORS
//      -------------------------------
dcmd_8track(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -1405.9402,-255.2577,1043.3710,349.1007,7);
	else SetPlayerPosEx(playerid, -1397.9353,-257.8540,1043.6819,12.6353,7);
	return 1;
	#pragma unused params
}
dcmd_dirtarena(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -1509.8901,-653.5889,1050.3011,164.7514,4);
 	else SetPlayerPosEx(playerid, -1516.4597,-609.0445,1056.4772,171.8474,4);
	return 1;
	#pragma unused params
}

dcmd_kickstart(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -1410.72,1591.16,1052.53 ,0.0,14);
	else SetPlayerPosEx(playerid,-1410.72,1591.16,1052.53 ,0.0,14);
	return 1;
	#pragma unused params
}
dcmd_bloodbowl(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid],-1394.20,987.62,1023.96,0.0,15);
 	else SetPlayerPosEx(playerid, -1358.5686,934.7971,1036.3649,305.2288,15);
	return 1;
	#pragma unused params
}
dcmd_lc(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
   	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -750.8, 491.0, 1371.7,0.0,1);
	else SetPlayerPosEx(playerid, -750.8, 491.0, 1371.7,263.0,1);
	return 1;
	#pragma unused params

}
dcmd_pump(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid, 681.66, -453.32, -25.61,0.0,1);
	return 1;
	#pragma unused params

}
dcmd_fia(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
   	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid] != INVALID_VEHICLE_ID) SetVehiclePosEx(playerid,pvehicleid[playerid], -1830.81, 16.83, 1061.14,0.0,14);
	else SetPlayerPosEx(playerid, -1830.81, 16.83, 1061.14,263.0,14);
	return 1;
	#pragma unused params

}
dcmd_androm(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else
	SetPlayerPosEx(playerid, 315.745086,984.969299,1958.919067,263.0,9);
	return 1;
	#pragma unused params

}
dcmd_shamal(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid, 1.808619,32.384357,1199.593750,263.0,1);
	return 1;
	#pragma unused params

}
dcmd_otb(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid, 833.269775,10.588416,1004.179687,263.0,3);
	return 1;
	#pragma unused params

}
dcmd_sex(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid, -103.559165,-24.225606,1000.718750,263.0,3);
	return 1;
	#pragma unused params

}
dcmd_atrium(const playerid, const params[])
{
	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
	else SetPlayerPosEx(playerid,1726.18,-1641.00,20.23,263.0,18);
	return 1;
	#pragma unused params

}
dcmd_insultshouse(const playerid, const params[])
{
//	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    if(IsPlayerAdmin(playerid) || !strcmp("insultman911", pname[playerid], false, 128))
	{
		SetPlayerPosEx(playerid,2559.5566,-1289.4639,1060.9844,84.0345,2);
    }
	else return SendClientError(playerid,COLOR_ERROR,"You are not insultman911 :( " );
	return 1;
	#pragma unused params

}
dcmd_prohouse(const playerid, const params[])
{
//	if(gTeam[playerid] || RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}ERROR: {C0C0C0}You must type {CC0000}/leave{C0C0C0} to exit the race/DM before you can use this command.");
    if(IsPlayerAdmin(playerid) || Variables[playerid][Pro])
	{
		SetPlayerPosEx(playerid,238.9096,1029.6703,1084.0078,99.4304,7);
    }
	else return SendClientError(playerid,COLOR_ERROR,"You may acquire PRO status by donating! http://everystuff.net/donate" );
	return 1;
	#pragma unused params

}



//#if defined USE_XADMIN
//========================[REGISTRATION SYSTEM v2.1]============================
dcmd_register(playerid,params[]) {
		if(blockregister[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} This is a temporary name and you CAN NOT register it. Please re-log w/ a different name!");
        if(!strlen(params)) { format(string128,sizeof(string128),"Syntax Error: \"/REGISTER <PASSWORD>\" [Password must be %d+].",Config[MinimumPasswordLength]); return SendClientMessage(playerid,red,string128); }
        new index = 0,Password[128],PlayerFile[256]; Password = strtok(params,index); PlayerFile = GetPlayerFile(playerid);
        new filename[128];
        GetPlayerName(playerid, pname[playerid], 24);
        format(filename, 128, "/xadmin/Users/%s.ini", udb_encode(pname[playerid]));
        //This is the name check-up
        if(dini_Int(filename, "Registered") == 1)return SendClientMessage(playerid, red, "Error: That playername is already registered. Try another one");
        if(!(Variables[playerid][Registered] && Variables[playerid][LoggedIn])) {
            if(strlen(Password) >= Config[MinimumPasswordLength]) {
                format(string128,sizeof(string128),"You have registered your account with the password \"%s\" and automatically been logged in.",Password);
                SetUserInt(playerid,"Password",udb_hash(Password));
                SetUserInt(playerid,"Registered",1);
                SetUserInt(playerid,"LoggedIn",1);
                Variables[playerid][LoggedIn] = true, Variables[playerid][Registered] = true;
                SendClientMessage(playerid,blue,string128);
                SetUserInt(playerid,"Level", 0);
      		    GivePlayerMoney(playerid, 10000);
                new tmp3[100]; GetPlayerIp(playerid,tmp3,100); SetUserString(playerid,"IP",tmp3); OnPlayerRegister(playerid);
            } else SendClientMessage(playerid,red,"Syntax Error: \"/REGISTER <PASSWORD>\" [Password must be 3+].");
        } else SendClientMessage(playerid,red,"Error: Make sure that you have not registered and are logged out.");
        return 1;
}
dcmd_login(playerid,params[]) {
	if(blockregister[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} This is a temporary name and you CAN NOT register it. Please re-log w/ a different name!");
    if(!strlen(params)) { SendClientMessage(playerid,red,"Syntax Error: \"/LOGIN <PASSWORD>\"."); return 1; }
	new index = 0;
	new Password[128]; Password = strtok(params,index);
	new PlayerFile[256]; PlayerFile = GetPlayerFile(playerid);
    if(Variables[playerid][Registered] && !Variables[playerid][LoggedIn]) {
        if(udb_hash(Password) == dini_Int(PlayerFile,"Password")) {
            switch(Variables[playerid][Level]) {
                case 0: format(string128,sizeof(string128),"You have logged into your account. [Status Level: Member]");
                default: {
					format(string128,sizeof(string128),"You have logged into your account. [Status Level: Administrator Lv. %d]",Variables[playerid][Level]);
					SetPlayerWorldBounds(playerid, 9999.00, -9999.00, 9999.00, -9999.00);
				}
			}
            SendClientMessage(playerid,blue,string128);
	        SetUserInt(playerid,"LoggedIn",1);
			Variables[playerid][LoggedIn] = true;
	        new tmp3[100]; GetPlayerIp(playerid,tmp3,100); SetUserString(playerid,"IP",tmp3);
	        new currmoney = GetPlayerMoney(playerid);
	        GivePlayerMoney(playerid,-currmoney);
			GivePlayerMoney(playerid,Variables[playerid][Money]);
			kills[playerid] = Variables[playerid][Kills];
			race1st[playerid] = Variables[playerid][RaceWins];
			minutesplayed[playerid] = Variables[playerid][MinsPlayed];
			pskin[playerid] = Variables[playerid][Skin];
			SetPlayerSkin(playerid,pskin[playerid]);
			format(string256,sizeof(string256),"{FFFFFF}[LOGIN]: {%06x}%s {FFFFFF}has logged in successfully! {C0C0C0}Kills:{FF66FF}%i {C0C0C0}Wins:{FF66FF}%i {C0C0C0}Money:{FF66FF}$%i",GetPlayerColor(playerid) >>> 8,pname[playerid],Variables[playerid][Kills],Variables[playerid][RaceWins],Variables[playerid][Money]);
			SendClientMessageToAll(COLOR_GREY,string256);
	        OnPlayerLogin(playerid,true);
	        if(Variables[playerid][Pro]) pro[playerid] = 1;
        }
		else // no password entered
	 	{
		 	OnPlayerLogin(playerid,false);
		 	return SendClientMessage(playerid,red,"Syntax Error: \"/LOGIN <PASSWORD>\".");
	 	}
		
	} else return SendClientMessage(playerid,red,"Error: You must be registered to log in; if you have make sure you haven't already logged in."); // not registered
	if(Variables[playerid][LoggedIn] == true)
	{
//		format(string256,sizeof(string256),"{FFFFFF}[LOGIN]: {%06x}%s {FFFFFF}has logged in successfully! {C0C0C0}Kills:{FF66FF}%i {C0C0C0}Wins:{FF66FF}%i {C0C0C0}Money:{FF66FF}$%i",GetPlayerColor(playerid) >>> 8,pname[playerid],Variables[playerid][Kills],Variables[playerid][RaceWins],Variables[playerid][Money]);
//		SendClientMessage(playerid,COLOR_GREY,"login message test");
	}
	return 1;
}
dcmd_logout(playerid,params[]) {
	#pragma unused params
	new PlayerFile[256]; PlayerFile = GetPlayerFile(playerid);
    if(Variables[playerid][Registered] && Variables[playerid][LoggedIn]) {
		SendClientMessage(playerid,blue,"You have logged out of your account. You may log back in later by typing \"/LOGIN <PASSWORD>\".");
	 	SetUserInt(playerid,"LoggedIn",0); Variables[playerid][LoggedIn] = false; OnPlayerLogout(playerid);
	} else SendClientMessage(playerid,red,"Error: You must be registered and logged into your account first.");
	return 1;
}

dcmd_lock(playerid,params[])
{
	#pragma unused params

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new v = GetPlayerVehicleID(playerid);
		    foreach(Player, i) SetVehicleParamsForPlayer(v,i,false,true);
			VehicleLockData[v] = true;
			SendClientMessage(playerid,red,"{33AA33}[CONFIRM]:{C0C0C0} You have LOCKED your vehicle doors");
		}
		else SendClientMessage(playerid,red,"{CC0000}[ERROR]:{C0C0C0} You must be DRIVING a vehicle to lock.");
		return 1;

}
dcmd_unlock(playerid,params[])
{
	#pragma unused params

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
		    new v = GetPlayerVehicleID(playerid);
		    foreach(Player, i) SetVehicleParamsForPlayer(v,i,false,false);
			VehicleLockData[v] = false;
			SendClientMessage(playerid,red,"{33AA33}[CONFIRM]:{C0C0C0} You have UNLOCKED your vehicle doors");
		}
		else SendClientMessage(playerid,red,"{CC0000}[ERROR]:{C0C0C0} You must be DRIVING a vehicle to lock.");
		return 1;

}

dcmd_adminhq(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"kick"))
	{
	    SetPlayerPos(playerid,-2051,157,28);
	    SetPlayerInterior(playerid,1);
	    SendClientMessage(playerid,COLOR_CONFIRM,"{FF66FF}Welcome to the Everystuff Admin Headquarters!");
	}
	else SendLevelErrorMessage(playerid,"goto");
	return 1;
	#pragma unused params
}


dcmd_goto(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"goto")) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/GOTO <NICK OR ID>\".");
        new id;
		if(!IsNumeric(params)) id = ReturnPlayerID(params);
		else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    SendCommandMessageToAdmins(playerid,"GOTO");
			new PlayerName[24],ActionName[24],Float:X,Float:Y,Float:Z; GetPlayerName(playerid,PlayerName,24); GetPlayerName(id,ActionName,24);
			new Interior = GetPlayerInterior(id); SetPlayerInterior(playerid,Interior); SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id)); GetPlayerPos(id,X,Y,Z); if(IsPlayerInAnyVehicle(playerid)) { SetVehiclePos(GetPlayerVehicleID(playerid),X+Config[TeleportXOffset],Y+Config[TeleportYOffset],Z+Config[TeleportZOffset]); LinkVehicleToInterior(GetPlayerVehicleID(playerid),Interior); } else SetPlayerPos(playerid,X+Config[TeleportXOffset],Y+Config[TeleportYOffset],Z+Config[TeleportZOffset]);
//			format(string128,sizeof(string128),"\"%s\" has teleported to your location.",PlayerName); SendClientMessage(id,yellow,string128);
			format(string128,sizeof(string128),"You have teleported to \"%s's\" location.",ActionName); return SendClientMessage(playerid,yellow,string128);
  		} else return SendClientMessage(playerid,red,"ERROR: You can not teleport to yourself or disconnected players.");
	} else return SendLevelErrorMessage(playerid,"goto");
}
dcmd_gethere(playerid,params[])
{
	if(IsPlayerCommandLevel(playerid,"gethere"))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/GETHERE <NICK OR ID>\".");
        new id;
		if(!IsNumeric(params)) id = ReturnPlayerID(params);
		else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
			SendCommandMessageToAdmins(playerid,"GETHERE");
			new PlayerName[24],ActionName[24],Float:X,Float:Y,Float:Z; GetPlayerName(playerid,PlayerName,24); GetPlayerName(id,ActionName,24);
			new Interior = GetPlayerInterior(playerid); SetPlayerInterior(id,Interior); SetPlayerVirtualWorld(id,GetPlayerVirtualWorld(playerid)); GetPlayerPos(playerid,X,Y,Z); if(IsPlayerInAnyVehicle(id)) { SetVehiclePos(GetPlayerVehicleID(id),X+Config[TeleportXOffset],Y+Config[TeleportYOffset],Z+Config[TeleportZOffset]); LinkVehicleToInterior(GetPlayerVehicleID(id),Interior); } else SetPlayerPos(id,X+Config[TeleportXOffset],Y+Config[TeleportYOffset],Z+Config[TeleportZOffset]);
   			format(string128,sizeof(string128),"You have teleported \"%s\" to your location.",ActionName); SendClientMessage(playerid,yellow,string128);
			if(!blnstealth[playerid])
			{
				format(string128,sizeof(string128),"You have been teleported to \"%s's\" location.",PlayerName);
				return SendClientMessage(id,yellow,string128);
			}
			else return SendClientMessage(id,yellow,"You have been teleported to a stranger.");
		  }
	  	else return SendClientMessage(playerid,red,"ERROR: You can not teleport yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid,"gethere");
}
dcmd_announce(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"announce")) {
        SendCommandMessageToAdmins(playerid,"ANNOUNCE");
    	if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/ANNOUNCE <TEXT>\".");
		new name[24];
		GetPlayerName(playerid,name,24);
    	printf("[announce] [%i]%s Announced: %s",playerid,name,params);
#if defined IRC_ECHO
		format(string128, sizeof(string128), "07[ANNOUNCE] %s", params);
		IRC_GroupSay(groupID, IRC_CHANNEL, string128);
#endif
		return GameTextForAll(params,4000,3);
    } else return SendLevelErrorMessage(playerid,"announce");
}
dcmd_say(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"say"))
	{
        SendCommandMessageToAdmins(playerid,"SAY");
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/SAY <TEXT>\".");

		if(!blnstealth[playerid])
		{
			new name[24];
			GetPlayerName(playerid,name,24);
			format(string128,sizeof(string128),"** Admin %s: %s",name,params);
		}
		else format(string128,sizeof(string128),"** Admin: %s",params);

		printf(string128);
		return SendClientMessageToAll(pink,string128);
	}
	else return SendLevelErrorMessage(playerid,"say");
}



dcmd_wire(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"wire")) {
   		if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/WIRE <NICK OR ID> (<REASON>)\".");
        new tmp[128],Index; tmp = strtok(params,Index);
	   	new id; if(!IsNumeric(tmp)) id = ReturnPlayerID(tmp); else id = strval(tmp);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    if(!Variables[id][Wired]) {
		        SendCommandMessageToAdmins(playerid,"WIRE");

				new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
			    if(!strlen(params[strlen(tmp)+1]))
				{
				    if(!blnstealth[playerid]) format(string128,sizeof(string128),"\"%s\" has been wired by Administrator \"%s\".",ActionName,name);
					else format(string128,sizeof(string128),"\"%s\" has been wired by an Administrator.",ActionName);
				}
				else
				{
					if(!blnstealth[playerid]) format(string128,sizeof(string128),"\"%s\" has been wired by Administrator \"%s\". (Reason: %s)",ActionName,name,params[strlen(tmp)+1]);
					else format(string128,sizeof(string128),"\"%s\" has been wired by an Administrator. (Reason: %s)",ActionName,params[strlen(tmp)+1]);
				}
				printf(string128);

				Variables[id][Wired] = true, Variables[id][WiredWarnings] = Config[WiredWarnings];
		    	return SendClientMessageToAll(yellow,string128);
			} else return SendClientMessage(playerid,red,"ERROR: This player has already been wired.");
		} else return SendClientMessage(playerid,red,"ERROR: You can not wire yourself or a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"wire");
}

dcmd_unwire(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"unwire")) {
   		if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/UNWIRE <NICK OR ID>\".");
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID) {
		    if(Variables[id][Wired]) {
		        SendCommandMessageToAdmins(playerid,"UNWIRE");

				new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
				Variables[id][Wired] = false, Variables[id][WiredWarnings] = Config[WiredWarnings];
			    if(id != playerid)
				{
					if(!blnstealth[playerid]) format(string128,sizeof(string128),"\"%s\" has been unwired by Administrator \"%s\".",ActionName,name);
					else format(string128,sizeof(string128),"\"%s\" has been unwired by an Administrator.",ActionName);
					printf(string128);
					return SendClientMessageToAll(yellow,string128);
				}
				else return SendClientMessage(playerid,yellow,"You have successfully unwired yourself.");

			} else return SendClientMessage(playerid,red,"ERROR: This player is not wired.");
		} else return SendClientMessage(playerid,red,"ERROR: You can not unwire a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"unwire");
}
dcmd_kick(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"kick")) {
   		if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/KICK <NICK OR ID> (<REASON>)\".");
   		new tmp[128],Index; tmp = strtok(params,Index);
	   	new id; if(!IsNumeric(tmp)) id = ReturnPlayerID(tmp); else id = strval(tmp);
	   	if(IsPlayerNPC(id)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can't ban NPCs!");
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    SendCommandMessageToAdmins(playerid,"KICK");
		    new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
	    	if(!strlen(params[strlen(tmp)+1])) format(string128,sizeof(string128),"[kick] [%i]%s has been Kicked from the game.",id,ActionName);
			else format(string128,sizeof(string128),"[kick] [%i]%s has been Kicked from the game. (Reason: %s)",id,ActionName,params[strlen(tmp)+1]);
			SendClientMessageToAll(yellow,string128);
  			#if defined IRC_ECHO
     		IRC_GroupSay(groupID, IRC_CHANNEL, string128);
     		#endif
			format(string128,sizeof(string128),"[kick] [%i]%s has been Kicked from the game by %s. (Reason: %s)",id,ActionName,name,params[strlen(tmp)+1]);
            printf(string128);
			return Kick(id);
		}
		else return SendClientMessage(playerid,red,"ERROR: You can not kick yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid,"kick");
}

dcmd_report(playerid,params[]) {
   		if(!strlen(params)) return SendClientMessage(playerid,red,"{CC0000}[ERROR]:{C0C0C0} \"/REPORT <NICK OR ID> (<REASON>)\". {FFFFFF}Ex: /report 4");
   		new tmp[128],Index; tmp = strtok(params,Index);
	   	new id; if(!IsNumeric(tmp)) id = ReturnPlayerID(tmp); else id = strval(tmp);
	   	if(IsPlayerNPC(id)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can't report NPCs!");
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
			format(string128,sizeof(string128),"[REPORT] {FFFFFF}[%i]%s{C0C0C0} has been reported by [%i]%s. (Reason:{FFFFFF} %s)",id,ActionName,playerid,name,params[strlen(tmp)+1]);
			new admins =0;
			foreach(Player,i)
			{
				if(IsPlayerCommandLevel(i,"kick"))
				{
					SendClientMessage(i,COLOR_LIGHTBLUE,string128);
					admins++;
				}
			}
			new ip[32];
			GetPlayerIp(id,ip,32);
			format(string128,sizeof(string128),"[REPORT] [%i]%s has been reported by [%i]%s. (Reason: %s) IP:%s Admins:%i",id,ActionName,playerid,name,params[strlen(tmp)+1],ip,admins);
			printf(string128);
#if defined IRC_ECHO
		new ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "07 [REPORT] [%i]%s has been reported by [%i]%s. (Reason: %s)", id,ActionName,playerid,name,params[strlen(tmp)+1]);
		IRC_GroupSay(groupID, IRC_CHANNEL, ircMsg);
#endif //irc_echo
			SendClientMessage(playerid,red,"{33AA33}[CONFIRM]:{C0C0C0} You have successfully reported that player. A message was sent to admins, and written to server log.");
			return 1;
		}
		else return SendClientMessage(playerid,red,"{CC0000}[ERROR]:{C0C0C0} You can not report yourself or a disconnected player.");
}
dcmd_ban(playerid,params[]) {
    if(IsPlayerCommandLevel(playerid,"ban")) {
   		if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/BAN <NICK OR ID> (<REASON>)\".");
   		new tmp[128],Index; tmp = strtok(params,Index);
	   	new id; if(!IsNumeric(tmp)) id = ReturnPlayerID(tmp); else id = strval(tmp);
	   	if(IsPlayerNPC(id)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You can't ban NPCs!");
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    SendCommandMessageToAdmins(playerid,"BAN");
		    new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
		    if(!strlen(params[strlen(tmp)+1])) format(string128,sizeof(string128),"[ban] [%i]%s has been Banned.",id,ActionName);
			else format(string128,sizeof(string128),"[ban] [%i]%s has been Banned. (Reason: %s)",id,ActionName,params[strlen(tmp)+1]);
			SendClientMessageToAll(yellow,string128);
   			#if defined IRC_ECHO
            IRC_GroupSay(groupID, IRC_CHANNEL, string128);
            #endif
            format(string128,sizeof(string128),"[ban] [%i]%s has been Banned by %s. (Reason: %s)",id,ActionName,name,params[strlen(tmp)+1]);
			printf(string128);
			return Ban(id);

		} else return SendClientMessage(playerid,red,"ERROR: You can not ban yourself or a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"ban");
}

dcmd_freeze(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"freeze")) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/FREEZE <NICK OR ID>\".");
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    SendCommandMessageToAdmins(playerid,"FREEZE");
		    frozen[id] = 1;
		    new name[24],ActionName[24];
			GetPlayerName(playerid,name,24);
			GetPlayerName(id,ActionName,24);
		    TogglePlayerControllable(id,false);
			format(string128,sizeof(string128),"Admin Chat: Admnistrator \"%s\" has frozen \"%s\".",name,ActionName);
   			printf(string128);
			return SendMessageToAdmins(string128);
		}
		else return SendClientMessage(playerid,red,"ERROR: You can not freeze yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid,"freeze");
}
dcmd_unfreeze(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"unfreeze")) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/UNFREEZE <NICK OR ID>\".");
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID) {
		    SendCommandMessageToAdmins(playerid,"UNFREEZE");
		    frozen[id] = 0;
		    new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
		    TogglePlayerControllable(id,true); format(string128,sizeof(string128),"Admin Chat: Admnistrator \"%s\" has unfrozen \"%s\".",name,ActionName);
			if(id != playerid) return SendMessageToAdmins(string128); else return SendClientMessage(playerid,yellow,"You have unfrozen yourself.");
		} else return SendClientMessage(playerid,red,"ERROR: You can not unfreeze a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"unfreeze");
}

dcmd_ip(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"ip")) {
	    SendCommandMessageToAdmins(playerid,"IP");
	    if(!strlen(params)) { new IP[128]; GetPlayerIp(playerid,IP,128); format(string128,sizeof(string128),"Your IP: \'%s\'",IP); return SendClientMessage(playerid,yellow,string128); }
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID) {
		    new ActionName[24],IP[128]; GetPlayerName(id,ActionName,24); GetPlayerIp(id,IP,128);
		    format(string128,sizeof(string128),"\"%s\'s\" IP: \'%s\'",ActionName,IP); return SendClientMessage(playerid,yellow,string128);
		} else return SendClientMessage(playerid,red,"ERROR: You can not get the ip of a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"ip");
}


dcmd_spec(playerid,params[]) {

		if(gTeam[playerid]) return SendClientError(playerid,COLOR_RED,"You are currently in a DM and cannot spy on your enemies like a little bitch.");
	    if(!strlen(params)) return SendClientError(playerid,COLOR_RED,"Type '/spec id' to spectate that id, or '/spec off' to return. Ex: '/spec 32' '/spec off'");
        new id;
		if(!IsNumeric(params)) {
		    if(!strcmp(params,"off",true)) {
		        if(!Spec[playerid][Spectating]) return SendClientMessage(playerid,red,"ERROR: You must be spectating.");
//		        SendCommandMessageToAdmins(playerid,"SPEC");
		        TogglePlayerSpectating(playerid,false);
		        Spec[playerid][Spectating] = false;
		        return SendClientMessage(playerid,yellow,"You have turned your spectator mode off.");
		    }
		  	id = ReturnPlayerID(params);
		}
		else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    if(!IsPlayerXAdmin(playerid) && IsPlayerXAdmin(id)) return SendClientError(playerid,COLOR_ERROR,"You cannot spectate this player!");
//		    if(gTeam[id]) return SendClientError(playerid,COLOR_ERROR,"You cannot spectate this player until they leave DM");
	//	    SendCommandMessageToAdmins(playerid,"SPEC");
		    new name[24]; GetPlayerName(id,name,24);
		    if(Spec[id][Spectating]) return SendClientMessage(playerid,red,"Error: You can not spectate a player already spectating.");
	        if(Spec[playerid][Spectating] && Spec[playerid][SpectateID] == id) return SendClientMessage(playerid,red,"ERROR: You are already spectating this player.");
			Spec[playerid][Spectating] = true, Spec[playerid][SpectateID] = id;
	        SetPlayerInterior(playerid,GetPlayerInterior(id));
	        TogglePlayerSpectating(playerid,true);
			if(!IsPlayerInAnyVehicle(id)) PlayerSpectatePlayer(playerid,id);
			else PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
	    	format(string128,sizeof(string128),"You are now spectating player \"%s\".",name); return SendClientMessage(playerid,yellow,string128);
		} else return SendClientMessage(playerid,red,"ERROR: You can not spectate yourself or a disconnected player.");
}
dcmd_xjail(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"xjail")) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/XJAIL <NICK OR ID>\".");
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid) {
		    if(Variables[id][Jailed]) return SendClientMessage(playerid,red,"ERROR: This player has already been jailed.");
		    SendCommandMessageToAdmins(playerid,"XJAIL");

			new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
			if(!blnstealth[playerid])format(string128,sizeof(string128),"Administrator \"%s\" has jailed you.",name);
			else format(string128,sizeof(string128),"An Administrator has jailed you.");
			SendClientMessage(id,yellow,string128);
			format(string128,sizeof(string128),"You have jailed \"%s\".",ActionName);
			SendClientMessage(playerid,yellow,string128);

			SetUserInt(id,"Jailed",1); Variables[id][Jailed] = true; SetPlayerInterior(id,3); SetPlayerPos(id,197.6661,173.8179,1003.0234); return SetPlayerFacingAngle(id,0);
		} return SendClientMessage(playerid,red,"ERROR: You can not jail yourself or a disconnected player.");
	} else return SendLevelErrorMessage(playerid,"xjail");
}
dcmd_xunjail(playerid,params[]) {
	if(IsPlayerCommandLevel(playerid,"xunjail"))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,red,"Syntax Error: \"/XUNJAIL <NICK OR ID>\".");
   		new id; if(!IsNumeric(params)) id = ReturnPlayerID(params); else id = strval(params);
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
            if(!Variables[id][Jailed]) return SendClientMessage(playerid,red,"ERROR: This player has already been unjailed.");
			SendCommandMessageToAdmins(playerid,"XUNJAIL");

			new name[24],ActionName[24]; GetPlayerName(playerid,name,24); GetPlayerName(id,ActionName,24);
			if(id != playerid)
			{
				if(!blnstealth[playerid])format(string128,sizeof(string128),"Administrator \"%s\" has unjailed you.",name);
				else format(string128,sizeof(string128),"An Administrator has unjailed you.");
				SendClientMessage(id,yellow,string128);
				format(string128,sizeof(string128),"You have unjailed \"%s\".",ActionName);
				SendClientMessage(playerid,yellow,string128);
			}
			else SendClientMessage(playerid,yellow,"You have unjailed yourself.");

			SetUserInt(id,"Jailed",0); Variables[id][Jailed] = false; return SpawnPlayer(id);
		}
		return SendClientMessage(playerid,red,"ERROR: You can not unjail a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid,"xunjail");
}

dcmd_admins(playerid,params[]) {
	#pragma unused params
	new Count,i,name[24];
	for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerXAdmin(i)) Count++;
	if(!Count) return SendClientMessage(playerid,green,"Admins travel single-file...to hide their numbers!");
	if(Count == 1) {
	    for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerXAdmin(i)) break;
	    GetPlayerName(i,name,24); format(string128,sizeof(string128),"Admins Online: %s (%d)",name,Variables[i][Level]);
	    return SendClientMessage(playerid,green,"Admins travel single-file...to hide their numbers!");
	}
	if(Count >= 1) {
	    new bool:First = false;
	    for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerXAdmin(i)) {
     		GetPlayerName(i,name,24);
			if(!First) { format(string128,sizeof(string128),"Admins Online: %s (%d),",name,Variables[i][Level]); First = true; }
	        else format(string128,sizeof(string128),"%s %s (%d)",string128,name,Variables[i][Level]);
	    }
	    return SendClientMessage(playerid,green,"Admins travel single-file...to hide their numbers!");
	}
	return 1;
}

dcmd_stealth(playerid, params[])
{
    if(IsPlayerCommandLevel(playerid,"stealth"))
	{
		if(blnstealth[playerid] == true)
		{
		    SetPlayerName(playerid, stroriginalname[playerid]);
		    
			blnstealth[playerid] = false;
			SetPlayerScore(playerid, 0);
			SendClientMessage(playerid, COLOR_CONFIRM, "Cloak disengaged");
		}
		else
		{
		    //Fake quit message
	     	/*
		    new leaveMsg[128];
		    GetPlayerName(playerid, pname[playerid], sizeof(pname));
			format(leaveMsg, sizeof(leaveMsg), "02[%d] 03*** %s has left the server. (Leaving)", playerid, pname[playerid]);
	  		*/
	  		
			new strstealthplayername[][] =
			{
			    "Eulah","Salome","Marica","Eloisa","Kym","Elma","Toney","Vickey","Latrina","Sina","Judith","Levi","Bennett","Rickey",
			    "Pete","Marguerite","Sadye","Randa","Karly","Caroll","Kayla","Catherine","Micah","Jere","Rozella","Wally","Chantay",
				"Latonya","Quyen","Dannielle","Rosina","Wade","Elfrieda","Shawanna""Lupe","Meridith","Cindie","Sherika","Justina",
				"Flo","Susann","Grazyna","Pei","Petrina", "Shantelle","Eileen","Deeann","Gaylene","Arcelia","Garnet"
			};
			GetPlayerName(playerid, stroriginalname[playerid], sizeof(stroriginalname));
			SetPlayerName(playerid, strstealthplayername[random(sizeof(strstealthplayername))]);
			
			blnstealth[playerid] = true;
			SendClientMessage(playerid, COLOR_CONFIRM, "Cloak engaged");
		}
	}
	#pragma unused params
}
dcmd_xcommands(playerid,params[]) {
    #pragma unused params
	if(!IsPlayerXAdmin(playerid)) return SendClientMessage(playerid,red,"ERROR: You must be an administrator to view these commands.");
	SendClientMessage(playerid,yellow,"adminhq,announce,(un)freeze,gethere,goto,spec,ip,kick,ban,setwanted,wire,xjail,xunjail,nuke"); //   settime,goto,gethere,say,asay,aslap,(un)wire,awire,kick,akick,ban,aban,xspec,giveweapon,giveallweapon,xcommands,weather,eject,explode,setwanted,setallwanted");
	SendClientMessage(playerid,red,"NOTE: NOT ALL COMMANDS MAY BE AVAILABLE TO YOU. THEY ARE BASED ON YOUR ADMIN LEVEL.");
	return 1;
}


//#endif


// =============================================================================
//------------------------   YRACE Commands   ----------------------------------
// =============================================================================




#if defined RACES
dcmd_racehelp(const playerid, const params[]) {
    #pragma unused params
    if(IsPlayerAdmin(playerid)) {
		SendClientMessage(playerid, COLOR_GREEN, "Yagu's race script racing help:");
		SendClientMessage(playerid, COLOR_WHITE, "/loadrace [name] to load a track and start it. Use /join (while in vehicle) to join, and /ready");
		SendClientMessage(playerid, COLOR_WHITE, "once at start to begin the race once others are ready as well. /leave to leave");
		SendClientMessage(playerid, COLOR_WHITE, "the race./endrace to aborts the race. /bestlap and /bestrace can be used to");
		SendClientMessage(playerid, COLOR_WHITE, "display record times for the races, you can also specify a race to see the");
		SendClientMessage(playerid, COLOR_WHITE, "times for it. For info on building races, see /buildhelp. For additional");
		SendClientMessage(playerid, COLOR_WHITE, "settings, see /raceadmin.");
	}
	return 1;
}

dcmd_buildhelp(const playerid, const params[]) {
    #pragma unused params
	SendClientMessage(playerid, COLOR_GREEN, "Yagu's race script building help:");
	SendClientMessage(playerid, COLOR_WHITE, "/buildrace to start building, /cp for new a checkpoint, /scp to select an old");
	SendClientMessage(playerid, COLOR_WHITE, "checkpoint, /dcp to delete, /mcp to move and /rcp to replace with a new one.");
	SendClientMessage(playerid, COLOR_WHITE, "/editrace to load a race to editor. /saverace [name] to save the race and");
	SendClientMessage(playerid, COLOR_WHITE, "/buildmenu to set racemode/laps/etc. For info on racing itself, see /racehelp");
	SendClientMessage(playerid, COLOR_WHITE, "For additional settings, see /raceadmin.");
	return 1;
}


dcmd_buildrace(const playerid, const params[]) {
    #pragma unused params
	if(BuildAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceBuilders[playerid] != 0) {
		SendClientMessage(playerid, COLOR_YELLOW, "You are already building a race, dork.");
	}
	else if(RaceParticipant[playerid]>0) {
	    SendClientMessage(playerid, COLOR_YELLOW, "You are participating in a race, can't build a race.");
	}
	else {
		new slot;
		slot=GetBuilderSlot(playerid);
		if(slot == 0) {
			SendClientMessage(playerid, COLOR_YELLOW, "No builderslots available!");
			return 1;
		}
		format(string128,sizeof(string128),"You are now building a race (Slot: %d)",slot);
		SendClientMessage(playerid, COLOR_GREEN, string128);
		RaceBuilders[playerid]=slot;
		BCurrentCheckpoints[b(playerid)]=0;
		Bracemode[b(playerid)]=0;
		Blaps[b(playerid)]=0;
		BAirrace[b(playerid)] = 0;
		BCPsize[b(playerid)] = 8.0;
	}
	return 1;
}

dcmd_cp(const playerid, const params[]) {
	#pragma unused params
	if(RaceBuilders[playerid] != 0 && BCurrentCheckpoints[b(playerid)] < MAX_RACECHECKPOINTS) {
		GetPlayerPos(playerid,playerx,playery,playerz);
		format(string128,sizeof(string128),"Checkpoint %d created: %f,%f,%f.",BCurrentCheckpoints[b(playerid)],playerx,playery,playerz);
		SendClientMessage(playerid, COLOR_GREEN, string128);
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][0]=playerx;
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][1]=playery;
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][2]=playerz;
		BSelectedCheckpoint[b(playerid)]=BCurrentCheckpoints[b(playerid)];
		SetBRaceCheckpoint(playerid,BCurrentCheckpoints[b(playerid)],-1);
		BCurrentCheckpoints[b(playerid)]++;
	}
	else if(RaceBuilders[playerid] != 0 && BCurrentCheckpoints[b(playerid)] == MAX_RACECHECKPOINTS)	{
		format(string128,sizeof(string128),"Sorry, maximum amount of checkpoints reached (%d).",MAX_RACECHECKPOINTS);
		SendClientMessage(playerid, COLOR_YELLOW, string128);
	}
	else SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
	return 1;
}

dcmd_scp(const playerid, const params[]) {
	new sele, tmp[128], idx;
    tmp = strtok(params, idx);
    if(!tmp[0]) {
		SendClientMessage(playerid, COLOR_WHITE, "USAGE: /scp [checkpoint]");
		return 1;
    }
    sele = strval(tmp);
	if(RaceBuilders[playerid] != 0)	{
		if(sele>BCurrentCheckpoints[b(playerid)]-1 || BCurrentCheckpoints[b(playerid)] < 1 || sele < 0)	{
			SendClientMessage(playerid, COLOR_YELLOW, "Invalid checkpoint!");
			return 1;
		}
		format(string128,sizeof(string128),"Selected checkpoint %d.",sele);
		SendClientMessage(playerid, COLOR_GREEN, string128);
		BActiveCP(playerid,sele);
		BSelectedCheckpoint[b(playerid)]=sele;
	}
	else {
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
	}
	return 1;
}

dcmd_rcp(const playerid, const params[]) {
	#pragma unused params
	if(RaceBuilders[playerid] == 0)	{
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
		return 1;
	}
	else if(BCurrentCheckpoints[b(playerid)] < 1) {
		SendClientMessage(playerid, COLOR_YELLOW, "No checkpoint to replace!");
		return 1;
	}
	GetPlayerPos(playerid,playerx,playery,playerz);
	format(string128,sizeof(string128),"Checkpoint %d replaced: %f,%f,%f.",BSelectedCheckpoint[b(playerid)],playerx,playery,playerz);
	SendClientMessage(playerid, COLOR_GREEN, string128);
	BRaceCheckpoints[b(playerid)][BSelectedCheckpoint[b(playerid)]][0]=playerx;
	BRaceCheckpoints[b(playerid)][BSelectedCheckpoint[b(playerid)]][1]=playery;
	BRaceCheckpoints[b(playerid)][BSelectedCheckpoint[b(playerid)]][2]=playerz;
	BActiveCP(playerid,BSelectedCheckpoint[b(playerid)]);
    return 1;
}

dcmd_mcp(const playerid, const params[]) {
	if(RaceBuilders[playerid] == 0)	{
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
		return 1;
	}
	else if(BCurrentCheckpoints[b(playerid)] < 1) {
		SendClientMessage(playerid, COLOR_YELLOW, "No checkpoint to move!");
		return 1;
	}
	new idx, direction, dir[64];
	dir=strtok(params, idx);
	new Float:amount=floatstr(strtok(params,idx));
	if(amount == 0.0 || (dir[0] != 'x' && dir[0]!='y' && dir[0]!='z')) {
		SendClientMessage(playerid, COLOR_WHITE, "USAGE: /mcp [x,y or z] [amount]");
		return 1;
	}
    if(dir[0] == 'x') direction=0;
    else if(dir[0] == 'y') direction=1;
    else if(dir[0] == 'z') direction=2;
    BRaceCheckpoints[b(playerid)][BSelectedCheckpoint[b(playerid)]][direction]=BRaceCheckpoints[b(playerid)][BSelectedCheckpoint[b(playerid)]][direction]+amount;
	BActiveCP(playerid,BSelectedCheckpoint[b(playerid)]);
	return 1;
}

dcmd_dcp(const playerid, const params[]) {
	#pragma unused params
	if(RaceBuilders[playerid] == 0)	{
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
		return 1;
	}
	else if(BCurrentCheckpoints[b(playerid)] < 1) {
		SendClientMessage(playerid, COLOR_YELLOW, "No checkpoint to delete!");
		return 1;
	}
	for(new i=BSelectedCheckpoint[b(playerid)];i<BCurrentCheckpoints[b(playerid)];i++) {
		BRaceCheckpoints[b(playerid)][i][0]=BRaceCheckpoints[b(playerid)][i+1][0];
		BRaceCheckpoints[b(playerid)][i][1]=BRaceCheckpoints[b(playerid)][i+1][1];
		BRaceCheckpoints[b(playerid)][i][2]=BRaceCheckpoints[b(playerid)][i+1][2];

	}
	BCurrentCheckpoints[b(playerid)]--;
	BSelectedCheckpoint[b(playerid)]--;
	if(BCurrentCheckpoints[b(playerid)] < 1) {
	    DisablePlayerRaceCheckpoint(playerid);
	    BSelectedCheckpoint[b(playerid)]=0;
		return 1;
	}
	else if(BSelectedCheckpoint[b(playerid)] < 0) {
	    BSelectedCheckpoint[b(playerid)]=0;
	}
	BActiveCP(playerid,BSelectedCheckpoint[b(playerid)]);
	SendClientMessage(playerid,COLOR_GREEN,"Checkpoint deleted!");
	return 1;
}
dcmd_clearrace(const playerid, const params[]) {
	#pragma unused params
	if(RaceBuilders[playerid] != 0) clearrace(playerid);
	else SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
	return 1;
}
dcmd_editrace(const playerid, const params[]) {
	if(RaceBuilders[playerid] == 0) {
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
		return 1;
	}
	if(BCurrentCheckpoints[b(playerid)]>0) {
		for(new i=0;i<BCurrentCheckpoints[b(playerid)];i++)	{
			BRaceCheckpoints[b(playerid)][i][0]=0.0;
			BRaceCheckpoints[b(playerid)][i][1]=0.0;
			BRaceCheckpoints[b(playerid)][i][2]=0.0;

		}
		BCurrentCheckpoints[b(playerid)]=0;
	}
	new tmp[64],idx;
    tmp = strtok(params, idx);
    if(!tmp[0])	{
		SendClientMessage(playerid, COLOR_WHITE, "USAGE: /editrace [name]");
		return 1;
    }
	new race_name[32],templine[42];
	format(race_name,sizeof(race_name), "/race/%s.yr",tmp);
	if(!fexist(race_name)) {
		format(string128,sizeof(string128), "The race \"%s\" doesn't exist.",tmp);
		SendClientMessage(playerid, COLOR_RED, string128);
		return 1;
	}
    BCurrentCheckpoints[b(playerid)]=-1;
	new File:f, i;
	f = fopen(race_name, io_read);
	fread(f,templine,sizeof(templine));
	if(templine[0] == 'Y') { //Checking if the racefile is v0.2+
		new fileversion;
	    strtok(templine,i); // read off YRACE
		fileversion = strval(strtok(templine,i)); // read off the file version
		if(fileversion > RACEFILE_VERSION) {
		    format(string128,sizeof(string128),"Race \'%s\' is created with a newer version of YRACE, unable to load.",tmp);
		    SendClientMessage(playerid,COLOR_RED,string128);
		    return 1;
		}
		strtok(templine,i); // read off RACEBUILDER
		Bracemode[b(playerid)] = strval(strtok(templine,i)); // read off racemode
		Blaps[b(playerid)] = strval(strtok(templine,i)); // read off amount of laps
		if(fileversion >= 2) {
		    BAirrace[b(playerid)] = strval(strtok(templine,i));
		    BCPsize[b(playerid)] = floatstr(strtok(templine,i));
		}
		else {
			BAirrace[b(playerid)] = 0;
			BCPsize[b(playerid)] = 8.0;
		}
		fread(f,templine,sizeof(templine)); // read off best race times, not saved due to editing the track
		fread(f,templine,sizeof(templine)); // read off best lap times,          -||-
	}
	else {//Otherwise add the lines as checkpoints, the file is made with v0.1 (or older) version of the script.
		BCurrentCheckpoints[b(playerid)]++;
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][0] = floatstr(strtok(templine,i));
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][1] = floatstr(strtok(templine,i));
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][2] = floatstr(strtok(templine,i));
	}
	while(fread(f,templine,sizeof(templine),false))	{
		BCurrentCheckpoints[b(playerid)]++;
		i=0;
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][0] = floatstr(strtok(templine,i));
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][1] = floatstr(strtok(templine,i));
		BRaceCheckpoints[b(playerid)][BCurrentCheckpoints[b(playerid)]][2] = floatstr(strtok(templine,i));
	}
	fclose(f);
	BCurrentCheckpoints[b(playerid)]++; // # of next CP to be created
	format(string128,sizeof(string128),"Race \"%s\" has been loaded for editing. (%d checkpoints)",tmp,BCurrentCheckpoints[b(playerid)]);
	SendClientMessage(playerid, COLOR_GREEN,string128);
    return 1;
}

dcmd_saverace(const playerid, const params[]) {
	if(RaceBuilders[playerid] != 0)	{
		new tmp[64], idx;
	    tmp = strtok(params, idx);
	    if(!tmp[0]) {
			SendClientMessage(playerid, COLOR_WHITE, "USAGE: /saverace [name]");
			return 1;
	    }
	    if(BCurrentCheckpoints[b(playerid)] < 2) {
	        SendClientMessage(playerid, COLOR_YELLOW, "You need atleast 2 checkpoints to save!");
	        return 1;
	    }
		new race_name[32],templine[42];
		format(race_name, sizeof(race_name), "/race/%s.yr",tmp);
		if(fexist(race_name)) {
			format(string128,sizeof(string128), "Race \"%s\" already exists.",tmp);
			SendClientMessage(playerid, COLOR_RED, string128);
			return 1;
		}
		new File:f, Bcreator[MAX_PLAYER_NAME];
		GetPlayerName(playerid, Bcreator, MAX_PLAYER_NAME);
		f = fopen(race_name,io_write);
		format(templine,sizeof(templine),"YRACE %d %s %d %d %d %f\n", RACEFILE_VERSION, Bcreator, Bracemode[b(playerid)], Blaps[b(playerid)], BAirrace[b(playerid)], BCPsize[b(playerid)]);
		fwrite(f,templine);
		format(templine,sizeof(templine),"A 0 A 0 A 0 A 0 A 0\n"); //Best complete race times
		fwrite(f,templine);
		format(templine,sizeof(templine),"A 0 A 0 A 0 A 0 A 0\n"); //Best lap times
		fwrite(f,templine);
		for(new i = 0; i < BCurrentCheckpoints[b(playerid)];i++) {
			playerx=BRaceCheckpoints[b(playerid)][i][0];
			playery=BRaceCheckpoints[b(playerid)][i][1];
			playerz=BRaceCheckpoints[b(playerid)][i][2];
			format(templine,sizeof(templine),"%f %f %f\n",playerx,playery,playerz);
			fwrite(f,templine);
  		}
		fclose(f);
		format(string128,sizeof(string128),"Your race \"%s\" has been saved.",tmp);
   		SendClientMessage(playerid, COLOR_GREEN, string128);
	}
	else {
		SendClientMessage(playerid, COLOR_RED, "You are not building a race!");
	}
	return 1;
}

dcmd_setlaps(const playerid, const params[]) {
	new tmp[128], idx;
    tmp = strtok(params, idx);
    if(!tmp[0] || strval(tmp) <= 0)	{
		SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setlaps [amount of laps (min: 1)]");
		return 1;
   	}
	if(RaceBuilders[playerid] != 0) {
		Blaps[b(playerid)] = strval(tmp);
		format(tmp,sizeof(tmp),"Amount of laps set to %d.", Blaps[b(playerid)]);
		SendClientMessage(playerid, COLOR_GREEN, tmp);
        return 1;
    }
	if(RaceAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceActive == 1 || RaceStart == 1) SendClientMessage(playerid, COLOR_RED, "Race already in progress!");
	else if(LCurrentCheckpoint == 0) SendClientMessage(playerid, COLOR_YELLOW, "No race loaded.");
	else {
	    Racelaps=strval(tmp);
		format(tmp,sizeof(tmp),"Amount of laps set to %d for current race.", Racelaps);
		SendClientMessage(playerid, COLOR_GREEN, tmp);
	}
	return 1;
}

dcmd_racemode(const playerid, const params[]) {
	new tmp[64], idx, tempmode;
    tmp = strtok(params, idx);
    if(!tmp[0])	{
		SendClientMessage(playerid, COLOR_WHITE, "USAGE: /racemode [0/1/2/3]");
		return 1;
   	}
	if(tmp[0] == 'd') tempmode=0;
	else if(tmp[0] == 'r') tempmode=1;
	else if(tmp[0] == 'y') tempmode=2;
	else if(tmp[0] == 'm') tempmode=3;
	else tempmode=strval(tmp);
	if(0 > tempmode || tempmode > 3) {
   	    SendClientMessage(playerid, COLOR_YELLOW, "Invalid racemode!");
		return 1;
   	}
	if(RaceBuilders[playerid] != 0) {
		if(tempmode == 2 && BCurrentCheckpoints[b(playerid)] < 3) {
		    SendClientMessage(playerid, COLOR_YELLOW, "Can't set racemode 2 on races with only 2 CPs. Changing to mode 1 instead.");
		    Bracemode[b(playerid)] = 1;
		    return 1;
		}
		Bracemode[b(playerid)] = tempmode;
		format(tmp,sizeof(tmp),"Racemode set to %d.", Bracemode[b(playerid)]);
		SendClientMessage(playerid, COLOR_GREEN, tmp);
        return 1;
    }
	if(RaceAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceActive == 1 || RaceStart == 1) SendClientMessage(playerid, COLOR_RED, "Race already in progress!");
	else if(LCurrentCheckpoint == 0) SendClientMessage(playerid, COLOR_YELLOW, "No race loaded.");
	else {
		if(tempmode == 2 && LCurrentCheckpoint < 2)	{
		    SendClientMessage(playerid, COLOR_YELLOW, "Can't set racemode 2 on races with only 2 CPs. Changing to mode 1 instead.");
		    Racemode = 1;
		    return 1;
		}
	    Racemode=tempmode;
		format(tmp,sizeof(tmp),"Racemode set to %d.", Racemode);
		SendClientMessage(playerid, COLOR_GREEN, tmp);
	}
	return 1;
}

dcmd_loadrace(const playerid, const params[]) {
	if(!IsPlayerAdmin(playerid) && RacePreLoaded == 1) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} A race is already loaded. Please wait for it to be started.");
    if(RaceActive == 1) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} A race is already active! Please wait until you see the 'race finish' message to try again.");
	Racemode = 0; Racelaps = 1;
	new tmp[64], idx, fback;
    tmp = strtok(params, idx);
    if(!tmp[0]) {
		SendClientMessage(playerid, COLOR_SYSTEM, "{FFFFFF}[SYSTEM]:{C0C0C0} USAGE: /loadrace [name]. A list of races can be found at http://madoshi.net/samp/race");
		return 1;
    }

	fback=LoadRace(tmp);
	if(fback == -1) format(string128,sizeof(string128),"Race doesn't exist! Check race list at madoshi.org/samp Everystuff forum",tmp);
	else if(fback == -2) format(string128,sizeof(string128),"Race \'%s\' is created with a newer version of YRACE, cannot load.",tmp);
	if(fback < 0) {
	    SendClientMessage(playerid,COLOR_ERROR,string128);
	    return 1;
	}
	format(string128,sizeof(string128),"{33CCFF}[RACE]{FFFFFF}[SYSTEM]:{C0C0C0} Race \'%s\' loaded, /startrace to start it.",CRaceName);
	SendClientMessage(playerid,COLOR_SYSTEM,string128);
	printf(string128);
	if(LCurrentCheckpoint<2 && Racemode == 2) {
	    Racemode = 1; // Racemode 2 doesn't work well with only 2CPs, and mode 1 is just the same when playing with 2 CPs.
	}                 // Setting racemode 2 is prevented from racebuilder so this shouldn't happen anyways.
	#if defined RACE_MENU
	if(IsPlayerAdmin(playerid)) {
		if(!IsValidMenu(MRace)) CreateRaceMenus();
		if(Airrace == 0) SetMenuColumnHeader(MRace,0,"Air race: off");
		else SetMenuColumnHeader(MRace,0,"Air race: ON");
		ShowMenuForPlayerEx(MRace,playerid);
	}
	#endif
	return 1;
}

dcmd_startrace(const playerid, const params[]) {
	#pragma unused params
	if(LCurrentCheckpoint == 0) SendClientMessage(playerid,COLOR_YELLOW,"No race loaded!");
	else if(RaceActive == 1) SendClientMessage(playerid,COLOR_YELLOW,"Race is already active!");
	else {
	    format(string128,sizeof(string128),"<ID:%i> %s has started a race!",playerid,pname[playerid]);
	    SendClientMessageToAll(COLOR_LIGHTBLUE,string128);
		startrace();
	}
	return 1;
}

dcmd_deleterace(const playerid, const params[]) {
	if((RaceAdmin == 1 || BuildAdmin == 1) && !IsPlayerAdmin(playerid)) return 1;
	new filename[64], idx;
	filename = strtok(params,idx);
	if(!(strlen(filename)))	{
	    SendClientMessage(playerid, COLOR_WHITE, "USAGE: /deleterace [race]");
	    return 1;
	}
	format(filename,sizeof(filename),"%s.yr",filename);
	if(!fexist(filename)) {
		format(string128,sizeof(string128), "The race \"%s\" doesn't exist.",filename);
		SendClientMessage(playerid, COLOR_RED, string128);
		return 1;
	}
	fremove(filename);
	format(string128,sizeof(string128), "The race \"%s\" has been deleted.",filename);
	SendClientMessage(playerid, COLOR_GREEN, string128);
	return 1;
}

dcmd_join(const playerid, const params[]) {

	if(RaceActive == 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} There is no race you can join.");
	else if(RaceStart==1) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} The race has already started, can't join.");
	else if(pstate[playerid] != PLAYER_STATE_DRIVER) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You must be driving a vehicle in order to join a race");
	else if(cantrace[playerid] == true || aircraft[playerid] == true) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot join the race with your current vehicle. Please choose a different type.");
	else if(gTeam[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot join a race until you have left the DM area. Type /leave first.");
//   	else if(!Airrace && aircraft[playerid] == true) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You may only use aircraft in air-races");
	else if(RaceBuilders[playerid] != 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You are currently building a race, can't join. Use /clearrace to exit build mode.");
    else if(RaceParticipant[playerid] > 0) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You have already joined this race!");
	else {
		new vehicleid = pvehicleid[playerid];
 		if(RaceActive==1 && RaceStart==0) {
			CurrentCheckpoint[playerid]=0;
			if(Racemode == 3) {
				SetRaceCheckpoint(playerid,LCurrentCheckpoint,LCurrentCheckpoint-1);
				CurrentCheckpoint[playerid]=LCurrentCheckpoint;
			}
			else SetRaceCheckpoint(playerid,0,1);
			new randx = random(sizeof(startMod));
			new randy = random(sizeof(startMod));
			SetVehiclePos(vehicleid,startX+startMod[randx][0], startY+startMod[randy][0], startZ+5);
			if(pmodelid[playerid] == 522) RemovePlayerFromVehicle(playerid);
	 		RaceParticipant[playerid]=1;
			CurrentLap[playerid]=0;
//  			Participants++;
//			if(Participants == MAX_RACERS) GameTextForAll("~r~RACE IS FULL!!",2000,3);
			format(string128, sizeof(string128), "{33CCFF}[RACE]{C0C0C0} [%i]%s{33AA33} has joined the race! To enter the race, type {FFFFFF}/join{C0C0C0}!", playerid, pname[playerid], playerid);
			SendClientMessageToAll(COLOR_WHITE, string128);
			SendClientMessage(playerid, COLOR_SYSTEM, "{33CCFF}[RACE]{33AA33}[CONFIRM]:{C0C0C0} You have joined the race. please make room for others in the starting checkpoint!");
			printf("[race] [%i]%s has joined the race!", playerid,pname[playerid]);
			rcount[playerid] = 30;
			rtimer[playerid] = SetTimerEx("ReadyTimer", 1000, 1, "i", playerid);
//			ResetPlayerWeapons(playerid);
		}
	}
	return 1;
	#pragma unused params
}

dcmd_leaverace(const playerid, const params[])
{
	LeaveRace(playerid);
    return 1;
    #pragma unused params
}

dcmd_endrace(const playerid, const params[]) {
	if(IsPlayerAdmin(playerid)) {
	    if(RaceActive==0) {
	        SendClientMessage(playerid, COLOR_YELLOW, "There is no race active.");
			return 1;
	    }
	    else endrace();
	}
	return 1;
	#pragma unused params
}

dcmd_racers(const playerid, const params[]) {
	foreach(Player,i) {
	    if(RaceParticipant[i])
		{
	        format(string128, sizeof(string128),"<ID:%i> %s is currently racing",i,pname[i]);
			SendClientMessage(playerid,COLOR_CONFIRM,string128);
		}
	}
	return 1;
	#pragma unused params
}

dcmd_airrace(const playerid, const params[]) {
	#pragma unused params
	if(RaceBuilders[playerid] != 0)	{
	    if(BAirrace[b(playerid)] == 0) {
	        SendClientMessage(playerid,COLOR_GREEN,"Air race enabled.");
			BAirrace[b(playerid)]=1;
	    }
	    else {
	        SendClientMessage(playerid,COLOR_GREEN,"Air race disabled.");
			BAirrace[b(playerid)]=0;
	    }
		return 1;
	}
	if(RaceAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceActive == 1 || RaceStart == 1) SendClientMessage(playerid, COLOR_YELLOW, "Race is already in progress!");
	else if(LCurrentCheckpoint == 0) SendClientMessage(playerid, COLOR_YELLOW, "No race loaded!");
	else if(Airrace == 0) {
        SendClientMessage(playerid,COLOR_GREEN,"Air race enabled.");
		Airrace = 1;
    }
    else if(Airrace == 1) {
        SendClientMessage(playerid,COLOR_GREEN,"Air race disabled.");
		Airrace = 0;
    }
    else printf("Error in /airrace detected. RaceActive: %d, RaceStart: %d LCurrentCheckpoint: %d, Airrace: %d", RaceActive,RaceStart,LCurrentCheckpoint,Airrace);
	return 1;
}

dcmd_cpsize(const playerid, const params[]) {
	new idx, tmp[64];
	tmp = strtok(params,idx);
	if(!(strlen(tmp)) || floatstr(tmp) <= 0.0) {
	    SendClientMessage(playerid,COLOR_WHITE,"USAGE: /cpsize [size]");
	    return 1;
	}
	if(RaceBuilders[playerid] != 0)	{
	    BCPsize[b(playerid)] = floatstr(tmp);
	    format(string128,sizeof(string128),"Checkpoint size set to %f",floatstr(tmp));
		SendClientMessage(playerid,COLOR_GREEN,string128);
	    return 1;
	}
	if(RaceAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceActive == 1) SendClientMessage(playerid, COLOR_YELLOW, "Race has already been activated!");
	else if(LCurrentCheckpoint == 0) SendClientMessage(playerid, COLOR_YELLOW, "No race loaded!");
	else {
	    CPsize = floatstr(tmp);
	    format(string128,sizeof(string128),"Checkpoint size set to %f",floatstr(tmp));
		SendClientMessage(playerid,COLOR_GREEN,string128);
	}
	return 1;
}

dcmd_prizemode(const playerid, const params[]) {
	if(!IsPlayerAdmin(playerid)) return 1;
	new idx, tmp;
	tmp=strval(strtok(params,idx));
    if(tmp < 0 || tmp > 4) SendClientMessage(playerid,COLOR_WHITE,"USAGE: /prizemode [0-4]");
	else if(RaceActive == 1) SendClientMessage(playerid,COLOR_YELLOW,"Race is already active!");
    else {
        PrizeMode = tmp;
        format(string128,sizeof(string128),"Prizemode set to %d",PrizeMode);
		SendClientMessage(playerid,COLOR_GREEN,string128);
    }
	return 1;
}

dcmd_setprize(const playerid, const params[]) {
	if(!IsPlayerAdmin(playerid)) return 1;
	new idx, tmp;
    tmp = strval(strtok(params, idx));
    if(0 >= tmp) SendClientMessage(playerid,COLOR_WHITE,"USAGE: /setprize [amount]");
	else if(RaceActive == 1) SendClientMessage(playerid,COLOR_YELLOW,"Race is already active!");
    else
    {
        Prize = tmp;
        format(string128,sizeof(string128),"Prize set to %d",Prize);
		SendClientMessage(playerid,COLOR_GREEN,string128);
    }
	return 1;
}

#if defined RACE_MENU
dcmd_raceadmin(const playerid, const params[]) {
	#pragma unused params
	if(!IsPlayerAdmin(playerid)) return 1;
	if(!IsValidMenu(MAdmin)) CreateRaceMenus();
	ShowMenuForPlayerEx(MAdmin,playerid);
	return 1;
}

dcmd_buildmenu(const playerid, const params[]) {
	#pragma unused params
	if(BuildAdmin == 1 && !IsPlayerAdmin(playerid)) return 1;
	if(RaceBuilders[playerid] == 0)	{
		SendClientMessage(playerid,COLOR_YELLOW,"You are not building a race!");
		return 1;
	}
	if(BAirrace[b(playerid)] == 0) SetMenuColumnHeader(MBuild,0,"Air race: off");
	else SetMenuColumnHeader(MBuild,0,"Air race: on");
	if(!IsValidMenu(MBuild)) CreateRaceMenus();
	ShowMenuForPlayerEx(MBuild,playerid);
	return 1;
}
#endif

public countdown() {
	if(cd>0) {
		format(string64, sizeof(string64), "%d...",cd);
	    foreach(Player,i) {
			if(RaceParticipant[i]>1) {
				RaceSound(i,1056);
			    GameTextForPlayer(i,string64,1000,3);
			    TogglePlayerControllable(i,false);
		    }
		}
	}
	else if(cd == 0) {
		RaceStart=1;
	    KillTimer(Countdown);
   		raceclear = SetTimer("racecleartimer", 3600000, 0); //1 hour race auto-restart
	    foreach(Player,i) {
			if(RaceParticipant[i]>1){
			    if(rtimer[i]) {
					KillTimer(rtimer[i]);
			    	rtimer[i] = 0;
					rcount[i] = 0;
				}
				TogglePlayerControllable(i,true);
				RaceSound(i,1057);
			    GameTextForPlayer(i,"~g~GO!",3000,3);
			    PlayerPlaySound(i,41018,0.0,0.0,0.0); // "looks like we got a chase"
				RaceParticipant[i]=4;
				CurrentLap[i]=1;
				if(Racemode == 3) SetRaceCheckpoint(i,LCurrentCheckpoint,LCurrentCheckpoint-1);
				else SetRaceCheckpoint(i,0,1);
			}
		}
	}
	cd--;
}

public SetNextCheckpoint(playerid) {
	if(Racemode == 0) {
		CurrentCheckpoint[playerid]++;
		if(CurrentCheckpoint[playerid] == LCurrentCheckpoint) {
			SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],-1);
			RaceParticipant[playerid]=6;
		}
		else SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]+1);
	}
	else if(Racemode == 1) {
		CurrentCheckpoint[playerid]++;
		if(CurrentCheckpoint[playerid] == LCurrentCheckpoint+1 && CurrentLap[playerid] == Racelaps)	{
			SetRaceCheckpoint(playerid,0,-1);
			RaceParticipant[playerid]=6;
		}
		else if (CurrentCheckpoint[playerid] == LCurrentCheckpoint+1 && CurrentLap[playerid] != Racelaps) {
			CurrentCheckpoint[playerid]=0;
			SetRaceCheckpoint(playerid,0,1);
			RaceParticipant[playerid]=5;
		}
		else if(CurrentCheckpoint[playerid] == 1 && RaceParticipant[playerid]==5) {
			ChangeLap(playerid);
			if(LCurrentCheckpoint==1) {
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],0);
			}
			else {
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],2);
            }
  		    RaceParticipant[playerid]=4;
		}
		else {
			if(LCurrentCheckpoint==1 || CurrentCheckpoint[playerid] == LCurrentCheckpoint) SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],0);
			else SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]+1);
		}
	}
	else if(Racemode == 2) {
		if(RaceParticipant[playerid]==4) {
			if(CurrentCheckpoint[playerid] == LCurrentCheckpoint) {// @ Last CP, trigger last-1
			    RaceParticipant[playerid]=5;
				CurrentCheckpoint[playerid]=LCurrentCheckpoint-1;
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]-1);
			}
			else if(CurrentCheckpoint[playerid] == LCurrentCheckpoint-1) { // Second last CP, set next accordingly
				CurrentCheckpoint[playerid]++;
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]-1);
			}
			else {
				CurrentCheckpoint[playerid]++;
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]+1);
			}
		}
		else if(RaceParticipant[playerid]==5) {
			if(CurrentCheckpoint[playerid] == 1 && CurrentLap[playerid] == Racelaps) {//Set the finish line
				SetRaceCheckpoint(playerid,0,-1);
				RaceParticipant[playerid]=6;
			}
			else if(CurrentCheckpoint[playerid] == 0) {//At finish line, change lap.
				ChangeLap(playerid);
				if(LCurrentCheckpoint==1) SetRaceCheckpoint(playerid,1,0);
				else SetRaceCheckpoint(playerid,1,2);
	  		    RaceParticipant[playerid]=4;
			}
			else if(CurrentCheckpoint[playerid] == 1) {
				CurrentCheckpoint[playerid]--;
				SetRaceCheckpoint(playerid,0,1);
			}
			else {
				CurrentCheckpoint[playerid]--;
				SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]-1);
			}
		}
	}
	else if(Racemode == 3) {// Mirror Mode
		CurrentCheckpoint[playerid]--;
		if(CurrentCheckpoint[playerid] == 0) {
			SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],-1);
			RaceParticipant[playerid]=6;
		}
		else SetRaceCheckpoint(playerid,CurrentCheckpoint[playerid],CurrentCheckpoint[playerid]-1);
	}
}

public SetRaceCheckpoint(playerid,target,next) {
	if(next == -1 && Airrace == 0) SetPlayerRaceCheckpoint(playerid,1,RaceCheckpoints[target][0],RaceCheckpoints[target][1],RaceCheckpoints[target][2],0.0,0.0,0.0,CPsize);
	else if(next == -1 && Airrace == 1) SetPlayerRaceCheckpoint(playerid,4,RaceCheckpoints[target][0],RaceCheckpoints[target][1],RaceCheckpoints[target][2],0.0,0.0,0.0,CPsize);
	else if(Airrace == 1) SetPlayerRaceCheckpoint(playerid,3,RaceCheckpoints[target][0],RaceCheckpoints[target][1],RaceCheckpoints[target][2],RaceCheckpoints[next][0],
							RaceCheckpoints[next][1],RaceCheckpoints[next][2],CPsize);
	else SetPlayerRaceCheckpoint(playerid,0,RaceCheckpoints[target][0],RaceCheckpoints[target][1],RaceCheckpoints[target][2],RaceCheckpoints[next][0],RaceCheckpoints[next][1],
							RaceCheckpoints[next][2],CPsize);

}
public SetBRaceCheckpoint(playerid,target,next) {
	new ar = BAirrace[b(playerid)];
	if(next == -1 && ar == 0) SetPlayerRaceCheckpoint(playerid,1,BRaceCheckpoints[b(playerid)][target][0],BRaceCheckpoints[b(playerid)][target][1],
								BRaceCheckpoints[b(playerid)][target][2],0.0,0.0,0.0,BCPsize[b(playerid)]);
	else if(next == -1 && ar == 1) SetPlayerRaceCheckpoint(playerid,4,BRaceCheckpoints[b(playerid)][target][0],
				BRaceCheckpoints[b(playerid)][target][1],BRaceCheckpoints[b(playerid)][target][2],0.0,0.0,0.0,
				BCPsize[b(playerid)]);
	else if(ar == 1) SetPlayerRaceCheckpoint(playerid,3,BRaceCheckpoints[b(playerid)][target][0],BRaceCheckpoints[b(playerid)][target][1],BRaceCheckpoints[b(playerid)][target][2],
						BRaceCheckpoints[b(playerid)][next][0],BRaceCheckpoints[b(playerid)][next][1],BRaceCheckpoints[b(playerid)][next][2],BCPsize[b(playerid)]);
	else SetPlayerRaceCheckpoint(playerid,0,BRaceCheckpoints[b(playerid)][target][0],BRaceCheckpoints[b(playerid)][target][1],BRaceCheckpoints[b(playerid)][target][2],
			BRaceCheckpoints[b(playerid)][next][0],BRaceCheckpoints[b(playerid)][next][1],BRaceCheckpoints[b(playerid)][next][2],BCPsize[b(playerid)]);

}

public OnPlayerEnterRaceCheckpoint(playerid) {
	if(RaceParticipant[playerid]>0) {// See if the player is participating in a race, allows race builders to do their stuff in peace.
		if(RaceParticipant[playerid] == 6) { // Player reaches the checkered flag.
			RaceSound(playerid,1139);
			if(Ranking<4)	{
				switch(Ranking) {
				    case 1:
					{
						new ppl;
						foreach(Player,i)
						{
						    if(RaceParticipant[i]) ppl++;
						}
						if(ppl > 1)
						{
							race1st[playerid]++;
							GivePlayerMoney(playerid,10000);

						}
						else GivePlayerMoney(playerid,1000);
					}
				    case 2:
					{
						race2nd[playerid]++;
						GivePlayerMoney(playerid,5000);
					}
				    
				    case 3:
					{
						race3rd[playerid]++;
						GivePlayerMoney(playerid,2500);
					}
					default: GivePlayerMoney(playerid,1000);
				    
				    
				}
				format(string128,sizeof(string128),"Total Wins: 1st: %i 2nd: %i 3rd: %i - Note: single-person races are not counted in stats", race1st[playerid],race2nd[playerid],race3rd[playerid]);
				SendClientMessage(playerid,COLOR_YELLOW,string128);
				if(Ranking == 1) format(string128,sizeof(string128),"{33CCFF}[RACE]{33AA33} %s has finished the race, position: %d. Wins: %i",pname[playerid],Ranking,race1st[playerid]);
				else format(string128,sizeof(string128),"{33CCFF}[RACE]{33AA33} %s has finished the race, position: %d.",pname[playerid],Ranking);
				SendClientMessageToAll(COLOR_SYSTEM,string128);
				if(Ranking== 3) {
				    foreach(Player,i) {
				        if(RaceParticipant[i]>0) {
				            LeaveRace(i);
						}
					}
				}
			}
			Ranking++;
			LeaveRace(playerid);
			return 1;
	    }
	    else if (RaceStart==1) { // Otherwise switch to the next race CP.
			RaceSound(playerid,1138);
			SetNextCheckpoint(playerid);
	    }
	    else if (RaceStart == 0 && RaceParticipant[playerid]==1) { // Player arrives to the start CP for 1st time
			SendClientMessage(playerid,COLOR_YELLOW,"NOTE: Your controls will be locked once the race countdown starts.");
			RaceParticipant[playerid]=2;
	    }
	}
	return 1;
}

forward LeaveRace(playerid);
public LeaveRace(playerid) {
	if(RaceParticipant[playerid] > 0)
	{
		SendClientMessage(playerid,COLOR_YELLOW,"You have left the race!");
		if(rtimer[playerid]) KillTimer(rtimer[playerid]);
 		rcount[playerid] = 0;
		rtimer[playerid] = 0;
		RaceParticipant[playerid]=0;
		DisablePlayerRaceCheckpoint(playerid);
		TogglePlayerControllable(playerid,true);
		new ppl = 0;
		foreach(Player,i)
		{
		    if(RaceParticipant[i]) ppl++;
		}
//        Participants--;
  		if(RaceStart == 0 && ppl > 0) ReadyRefresh();
  		else if(!ppl) endrace();
	}
	return 1;
}

public endrace() {
   	RaceActive=0;
	RaceStart=0;
	KillTimer(raceclear);
	raceclear = 0;
	for(new i=0;i<LCurrentCheckpoint;i++) {
	    RaceCheckpoints[i][0]=0.0;
	    RaceCheckpoints[i][1]=0.0;
	    RaceCheckpoints[i][2]=0.0;
	}
	LCurrentCheckpoint=0;
	foreach(Player,i) if(RaceParticipant[i]) LeaveRace(i);
	RacePreLoaded = 0;
//	Participants=0;
    SendClientMessageToAll(COLOR_YELLOW, "[RACE FINISH] The current race has been finished. Another race will start in a few minutes!");
	return 1;
 }

public BActiveCP(playerid,sele) {
	if(BCurrentCheckpoints[b(playerid)]-1 == sele) SetBRaceCheckpoint(playerid,sele,-1);
	else SetBRaceCheckpoint(playerid,sele,sele+1);
}

public RaceSound(playerid,sound) {
	GetPlayerPos(playerid,playerx,playery,playerz);
	PlayerPlaySound(playerid,sound,playerx,playery,playerz);
}

public ReadyRefresh() {
	if(RaceActive==1) {
		new Waiting=0, Ready=0;
		foreach(Player,i) {
			if((RaceParticipant[i] == 1 || RaceParticipant[i] == 2) && rcount[i]) Waiting++;
			else if(RaceParticipant[i] == 3 && rcount[i] == 1) Ready++;
		}
		if(Waiting==0) {
			foreach(Player,i) {
				if(RaceParticipant[i]) {
           			SendClientMessage(i, COLOR_GREEN,"Everyone is ready, the race begins!");
				   	if(rtimer[i]) KillTimer(rtimer[i]);
			    	rcount[i] = 0;
	               	rtimer[i] = 0;
				}
			}
			cd=5;
			Countdown = SetTimer("countdown",1000,1);
			print("[RACE START] The race has started!");
		}
		else if(Ready >= Waiting && MajorityDelay > 0 && MajStart == 0)	{
			MajStart=1;
			format(string128,sizeof(string128),"Half of the racers are ready, race starts in %d seconds!", MajorityDelay);
			SendClientMessageToAll(COLOR_GREEN,string128);
			MajStartTimer = SetTimer("mscountdown",10000,1);
			mscd= MajorityDelay;
		}
	}
}

public mscountdown() {
	if(RaceStart == 1 || MajStart == 0)	{
		MajStart=0;
		KillTimer(MajStartTimer);
	}
	else {
		mscd-=10;
		if(mscd <= 0) {
			foreach(Player,i) {
				if(RaceParticipant[i] == 3) {
			 		SendClientMessage(i,COLOR_GREEN,"Pre-race countdown done, the race beings!");
				    if(!rcount[i]) {
				        if(rtimer[i]) KillTimer(rtimer[i]);
						rtimer[i] = 0;
					}
				}
			}
			KillTimer(MajStartTimer);
			cd=5;
			Countdown = SetTimer("countdown",1000,1);
		}
		else {
			format(string128,sizeof(string128),"~y~Race starting in ~w~%d~y~ seconds!",mscd);
			SendClientMessageToAll(COLOR_ERROR, string128);
		}
	}
	return 1;
}



public ChangeLap(playerid) {
	format(string128,sizeof(string128),"~w~Lap %d/%d", CurrentLap[playerid], Racelaps);
	CurrentLap[playerid]++;
	if(CurrentLap[playerid] == Racelaps) format(string128,sizeof(string128),"%s~n~~g~Final lap!",string128);
	GameTextForPlayer(playerid,string128,6000,3);
}


public GetBuilderSlot(playerid) {
	for(new i;i < MAX_BUILDERS; i++)
	{
	    if(!(BuilderSlots[i] < MAX_PLAYERS+1))
	    {
	        BuilderSlots[i] = playerid;
	        RaceBuilders[playerid] = i+1;
			return i+1;
	    }
	}
	return 0;
}

public b(playerid) return RaceBuilders[playerid]-1;

public Float:Distance(Float:dx1,Float:dy1,Float:dz1,Float:dx2,Float:dy2,Float:dz2) {
	new Float:temp=floatsqroot((dx1-dx2) * (dx1-dx2) + (dy1-dy2) * (dy1-dy2) + (dz1-dz2) * (dz1-dz2));
	if(temp < 0) temp=temp*(-1);
	return temp;
}

public clearrace(playerid) {
	for(new i=0;i<BCurrentCheckpoints[b(playerid)];i++)
	{
		BRaceCheckpoints[b(playerid)][i][0]=0.0;
		BRaceCheckpoints[b(playerid)][i][1]=0.0;
		BRaceCheckpoints[b(playerid)][i][2]=0.0;
		// continue;
	}
	BCurrentCheckpoints[b(playerid)]=0;
	DisablePlayerRaceCheckpoint(playerid);
	SendClientMessage(playerid, COLOR_GREEN, "Your race has been cleared! Use /buildrace to start a new one.");
	BuilderSlots[b(playerid)] = MAX_PLAYERS+1;
	RaceBuilders[playerid]=0;
}

public startrace() {
	format(string128,sizeof(string128),"{33CCFF}[RACE]{C0C0C0} \"%s\" race is {33AA33}starting{C0C0C0}! To join the race get in a car and type /join",CRaceName);
	SendClientMessageToAll(COLOR_GREENYELLOW,string128);
	RaceStart=0;
	RaceActive=1;
	Ranking=1;
}

ReturnModeName(mode) {
	new modename[8];
	if(mode == 0) modename="Default";
	else if(mode == 1) modename="Ring";
	else if(mode == 2) modename="Yoyo";
	else if(mode == 3) modename="Mirror";
	return modename;
}

public LoadRace(tmp[]) {
	new race_name[32],templine[512];
	format(CRaceName,sizeof(CRaceName), "%s",tmp);
	format(race_name,sizeof(race_name), "/race/%s.yr",tmp);
	if(!fexist(race_name)) return -1; // File doesn't exist
	CFile=race_name;
    LCurrentCheckpoint=-1; RLenght=0; RLenght=0;
	new File:f, i;
	f = fopen(race_name, io_read);
	fread(f,templine,sizeof(templine));
	if(templine[0] == 'Y')  {//Checking if the racefile is v0.2+
		new fileversion;
	    strtok(templine,i); // read off YRACE
		fileversion = strval(strtok(templine,i)); // read off the file version
		if(fileversion > RACEFILE_VERSION) return -2; // Check if the race is made with a newer version of the racefile format
		CBuilder=strtok(templine,i); // read off RACEBUILDER
		ORacemode = strval(strtok(templine,i)); // read off racemode
		ORacelaps = strval(strtok(templine,i)); // read off amount of laps
		if(fileversion > 1)	{
			Airrace = strval(strtok(templine,i));   // read off airrace
			CPsize = floatstr(strtok(templine,i));    // read off CP size
		}
		else { // v1 file format, set to default
			Airrace = 0;
			CPsize = 8.0;
		}
		Racemode=ORacemode; Racelaps=ORacelaps; //Allows changing the modes, but disables highscores if they've been changed.
		fread(f,templine,sizeof(templine)); // read off best race times
		i=0;
		for(new j=0;j<5;j++) {
		    TopRacers[j]=strtok(templine,i);
		    TopRacerTimes[j]=strval(strtok(templine,i));
		}
		fread(f,templine,sizeof(templine)); // read off best lap times
		i=0;
		for(new j=0;j<5;j++) {
		    TopLappers[j]=strtok(templine,i);
		    TopLapTimes[j]=strval(strtok(templine,i));
		}
		RacePreLoaded = true;
	}
	else {//Otherwise add the lines as checkpoints, the file is made with v0.1 (or older) version of the script.
		LCurrentCheckpoint++;
		RaceCheckpoints[LCurrentCheckpoint][0] = floatstr(strtok(templine,i));
		RaceCheckpoints[LCurrentCheckpoint][1] = floatstr(strtok(templine,i));
		RaceCheckpoints[LCurrentCheckpoint][2] = floatstr(strtok(templine,i));
		startX = RaceCheckpoints[0][0];
		startY = RaceCheckpoints[0][1];
		startZ = RaceCheckpoints[0][2];
		Racemode=0; ORacemode=0; Racelaps=0; ORacelaps=0;   //Enables converting old files to new versions
		CPsize = 8.0; Airrace = 0;  			// v2 additions
		CBuilder="UNKNOWN";
		for(new j;j<5;j++) {
		    TopLappers[j]="A"; TopLapTimes[j]=0; TopRacers[j]="A"; TopRacerTimes[j]=0;
		    // continue;
		}
	}
	while(fread(f,templine,sizeof(templine),false))	{
		LCurrentCheckpoint++;
		i=0;
		RaceCheckpoints[LCurrentCheckpoint][0] = floatstr(strtok(templine,i));
		RaceCheckpoints[LCurrentCheckpoint][1] = floatstr(strtok(templine,i));
		RaceCheckpoints[LCurrentCheckpoint][2] = floatstr(strtok(templine,i));
		startX = RaceCheckpoints[0][0];
		startY = RaceCheckpoints[0][1];
		startZ = RaceCheckpoints[0][2];
		if(LCurrentCheckpoint >= 1)	{
		    RLenght+=Distance(RaceCheckpoints[LCurrentCheckpoint][0],RaceCheckpoints[LCurrentCheckpoint][1],
								RaceCheckpoints[LCurrentCheckpoint][2],RaceCheckpoints[LCurrentCheckpoint-1][0],
								RaceCheckpoints[LCurrentCheckpoint-1][1],RaceCheckpoints[LCurrentCheckpoint-1][2]);
		}
	}
	RacePreLoaded = true;
	fclose(f);
	return 1;
}

public RaceRotation() {
	if(!fexist("/race/yrace.rr"))	{
	    print("ERROR in  YRACE's Race Rotation (yrace.rr): yrace.rr doesn't exist!");
	    return -1;
	}
	if(RRotation == -1)	{
		return -1; // RRotation has been disabled
	}
	foreach(Player,i)
	{
		if(RaceParticipant[i]) return -1; // A race is still active.
	}
	new File:f, templine[32], rotfile[]="/race/yrace.rr", rraces=-1, idx, fback;
	new rracenames[102][32];
	f = fopen(rotfile, io_read);
	while(fread(f,templine,sizeof(templine),false))	{
		idx = 0;
		rraces++;
		rracenames[rraces]=strtok(templine,idx);
	}
	fclose(f);
	RRotation++;
	if(RRotation > rraces) RRotation = 0;
	fback = LoadRace(rracenames[RRotation]);
	if(fback == -1) printf("ERROR in YRACE's Race Rotation (yrace.rr): Race \'%s\' doesn't exist!",rracenames[RRotation]);
	else if (fback == -2) printf("ERROR in YRACE's Race Rotation (yrace.rr): Race \'%s\' is created with a newer version of YRACE",rracenames[RRotation]);
	else if(fback > -1) {
//		printf("[RACE] Race \'%s\' Loaded",rracenames[RRotation]);
		startrace();
	}
 	return 1;
}


#if defined RACE_MENU

public RefreshMenuHeader(playerid,Menu:menu,text[]) {
	SetMenuColumnHeader(menu,0,text);
	ShowMenuForPlayerEx(menu,playerid);
}

public CreateRaceMenus() {
	//Admin menu
	MAdmin = CreateMenu("Admin menu", 1, 25, 170, 220, 25);
	if(IsValidMenu(MAdmin)) {
		AddMenuItem(MAdmin,0,"Set prizemode...");
		AddMenuItem(MAdmin,0,"Set fixed prize...");
		AddMenuItem(MAdmin,0,"Set dynamic prize...");
		AddMenuItem(MAdmin,0,"Set entry fees...");
		AddMenuItem(MAdmin,0,"Majority delay...");
		AddMenuItem(MAdmin,0,"End current race");
		AddMenuItem(MAdmin,0,"Toggle Race Admin [RA]");
		AddMenuItem(MAdmin,0,"Toggle Build Admin [BA]");
		AddMenuItem(MAdmin,0,"Toggle Race Rotation [RR]");
		AddMenuItem(MAdmin,0,"Leave");
		if(RaceAdmin == 1) format(string128,sizeof(string128),"RA: ON");
		else format(string128,sizeof(string128),"RA: off");
		if(BuildAdmin == 1) format(string128,sizeof(string128),"%s BA: ON",string128);
		else format(string128,sizeof(string128),"%s BA: off",string128);
		if(RRotation >= 0) format(string128,sizeof(string128),"%s RR: ON",string128);
		else format(string128,sizeof(string128),"%s RR: off",string128);
		SetMenuColumnHeader(MAdmin,0,string128);
	}
	//Prizemode menu [Admin submenu]
	MPMode = CreateMenu("Set prizemode:", 1, 25, 170, 220, 25);
	if(IsValidMenu(MPMode)) {
		AddMenuItem(MPMode,0,"Fixed");
		AddMenuItem(MPMode,0,"Dynamic");
		AddMenuItem(MPMode,0,"Entry Fee");
		AddMenuItem(MPMode,0,"Entry Fee + Fixed");
		AddMenuItem(MPMode,0,"Entry Fee + Dynamic");
		AddMenuItem(MPMode,0,"Back");
		SetMenuColumnHeader(MPMode,0,"Mode: Fixed");
	}
	//Fixed prize menu
	MPrize = CreateMenu("Fixed prize:", 1, 25, 170, 220, 25);
	if(IsValidMenu(MPrize)) {
		AddMenuItem(MPrize,0,"+100$");
		AddMenuItem(MPrize,0,"+1000$");
		AddMenuItem(MPrize,0,"+10000$");
		AddMenuItem(MPrize,0,"-100$");
		AddMenuItem(MPrize,0,"-1000$");
		AddMenuItem(MPrize,0,"-10000$");
		AddMenuItem(MPrize,0,"Back");
		format(string128,sizeof(string128),"Amount: %d",Prize);
		SetMenuColumnHeader(MPrize,0,string128);
	}
	//Dynamic prize menu
	MDyna = CreateMenu("Dynamic Prize:", 1, 25, 170, 220, 25);
	if(IsValidMenu(MDyna)) {
		AddMenuItem(MDyna,0,"+1x");
		AddMenuItem(MDyna,0,"+5x");
		AddMenuItem(MDyna,0,"-1x");
		AddMenuItem(MDyna,0,"-5x");
		AddMenuItem(MDyna,0,"Leave");
		format(string128,sizeof(string128),"Multiplier: %dx",DynaMP);
		SetMenuColumnHeader(MDyna,0,string128);
	}
	//Build Menu
	MBuild = CreateMenu("Build Menu", 1, 25, 170, 220, 25);
	if(IsValidMenu(MBuild)) {
		AddMenuItem(MBuild,0,"Set laps...");
		AddMenuItem(MBuild,0,"Set racemode...");
		AddMenuItem(MBuild,0,"Checkpoint size...");
		AddMenuItem(MBuild,0,"Toggle air race");
		AddMenuItem(MBuild,0,"Clear the race and exit");
		AddMenuItem(MBuild,0,"Leave");
		SetMenuColumnHeader(MBuild,0,"Air race: off");
	}
	//Laps menu
	MLaps = CreateMenu("Set laps", 1, 25, 170, 220, 25);
	if(IsValidMenu(MLaps)) {
		AddMenuItem(MLaps,0,"+1");
		AddMenuItem(MLaps,0,"+5");
		AddMenuItem(MLaps,0,"+10");
		AddMenuItem(MLaps,0,"-1");
		AddMenuItem(MLaps,0,"-5");
		AddMenuItem(MLaps,0,"-10");
		AddMenuItem(MLaps,0,"Back");
	}
	//Racemode menu
	MRacemode = CreateMenu("Racemode", 1, 25, 170, 220, 25);
	if(IsValidMenu(MRacemode)) {
		AddMenuItem(MRacemode,0,"Default");
		AddMenuItem(MRacemode,0,"Ring");
		AddMenuItem(MRacemode,0,"Yoyo");
		AddMenuItem(MRacemode,0,"Mirror");
		AddMenuItem(MRacemode,0,"Back");
	}
	//Race menu
	MRace = CreateMenu("Race Menu", 1, 25, 170, 220, 25);
	if(IsValidMenu(MRace)) {
		AddMenuItem(MRace,0,"Set laps...");
		AddMenuItem(MRace,0,"Set racemode...");
		AddMenuItem(MRace,0,"Set checkpoint size...");
		AddMenuItem(MRace,0,"Toggle air race");
		AddMenuItem(MRace,0,"Start race");
		AddMenuItem(MRace,0,"Abort new race");
	}
	//Entry fee menu
	MFee = CreateMenu("Entry fees", 1, 25, 170, 220, 25);
	if(IsValidMenu(MFee)) {
		AddMenuItem(MFee,0,"+100");
		AddMenuItem(MFee,0,"+1000");
		AddMenuItem(MFee,0,"+10000");
		AddMenuItem(MFee,0,"-100");
		AddMenuItem(MFee,0,"-1000");
		AddMenuItem(MFee,0,"-10000");
		AddMenuItem(MFee,0,"Back");
		format(string128,sizeof(string128),"Fee: %d$",JoinFee);
		SetMenuColumnHeader(MFee,0,string128);
	}
	//CP size menu
	MCPsize = CreateMenu("CP size", 1, 25, 170, 220, 25);
	if(IsValidMenu(MCPsize)) {
		AddMenuItem(MCPsize,0,"+0.1");
		AddMenuItem(MCPsize,0,"+1");
		AddMenuItem(MCPsize,0,"+10");
		AddMenuItem(MCPsize,0,"-0.1");
		AddMenuItem(MCPsize,0,"-1");
		AddMenuItem(MCPsize,0,"-10");
		AddMenuItem(MCPsize,0,"Back");
	}
	//Majority Delay menu
	MDelay = CreateMenu("Majority Delay", 1, 25, 170, 220, 25);
	if(IsValidMenu(MDelay)) {
		AddMenuItem(MDelay,0,"+10s");
		AddMenuItem(MDelay,0,"+60s");
		AddMenuItem(MDelay,0,"-10s");
		AddMenuItem(MDelay,0,"-60s");
		AddMenuItem(MDelay,0,"Back");
		if(MajorityDelay == 0) format(string128,sizeof(string128),"Delay: disabled");
		else format(string128,sizeof(string128),"Delay: %ds",MajorityDelay);
		SetMenuColumnHeader(MDelay,0,string128);
	}
}

#endif //racemenus


forward ReadyTimer(playerid);
public ReadyTimer(playerid) {
	new rtimermsg[128];
	format(rtimermsg, sizeof(rtimermsg), "You have %i seconds~n~to get into position", rcount[playerid]);
	GameTextForPlayer(playerid, rtimermsg, 1000, 3);
	rcount[playerid]--;
	if(rcount[playerid] == 0) {
		GameTextForPlayer(playerid, "You are now ready. Please wait for the other racers to finish taking position.", 5000, 3);
   		RaceParticipant[playerid]=3;
   		KillTimer(rtimer[playerid]);
   		rtimer[playerid] = 0;
		ReadyRefresh();
	}
	return 1;
}

forward racecleartimer();
public racecleartimer() {
	KillTimer(raceclear);
	raceclear = 0;
	SendClientMessageToAll(COLOR_RED, "I think the last race was abandoned. A new one will start soon.");
	endrace();
	print("[ABANDONED RACE] A race was ended automatically.");
	return 1;
}

	

	// Needed by Yrace stuff

//----------------------------------------------------------------
/*
strtok(const string[], &index) {
	new length = strlen(string128);
	while ((index < length) && (string[index] <= ' ')) {
		index++;
	}
	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1))) {
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
*/

//---------------------------------------------------------------

//forward IsPlayerInProx(playerid, targetid, distance = 5);
stock IsPlayerInProx(playerid, targetid, distance = 5) {
	new dist = distance;
	new Float:targetx,Float:targety,Float:targetz;
	GetPlayerPos(playerid, playerx, playery, playerz);
	GetPlayerPos(targetid, targetx, targety, targetz);
	if((playerx > targetx-dist && playerx < targetx+dist) && (playery > targety-dist && playery < targety+dist)) return 1;
	else return 0;
}
#endif //races



//------------------------------------------------------------------------------
public OnPlayerSelectedMenuRow(playerid, row)
{
	TogglePlayerControllable(playerid,true);
	new Menu:Current = GetPlayerMenu(playerid);
	if(Current == MAdmin)
	{
		if(row <=4 && RaceActive == 1)
		{
		    SendClientMessage(playerid,COLOR_RED,"{CC0000}[ERROR]:{C0C0C0} Race active, cannot change this setting!");
			if(IsValidMenu(MAdmin)) ShowMenuForPlayerEx(MAdmin,playerid);
		    return 1;
		}
		if(row == 0) ShowMenuForPlayerEx(MPMode,playerid);
		else if(row == 1) ShowMenuForPlayerEx(MPrize,playerid);
		else if(row == 2) ShowMenuForPlayerEx(MDyna,playerid);
		else if(row == 3) ShowMenuForPlayerEx(MFee,playerid);
		else if(row == 4) ShowMenuForPlayerEx(MDelay,playerid);
		else if(row == 5)
		{
		    if(RaceActive == 1) endrace();
		    else SendClientMessage(playerid,COLOR_YELLOW,"No race active!");
		    ShowMenuForPlayerEx(MAdmin,playerid);
		}
		else if(row == 9) HideMenuForPlayer(MAdmin,playerid);
		else
		{
			if(row == 6 && RaceAdmin == 1) RaceAdmin=0;
			else if(row == 6 && RaceAdmin == 0) RaceAdmin=1;
			else if(row == 7 && BuildAdmin == 1) BuildAdmin=0;
			else if(row == 7 && BuildAdmin == 0) BuildAdmin=1;
			else if(row == 8 && RRotation >= 0) RRotation = -1;
			else RRotation = 0;
			if(RaceAdmin == 1) format(string128,sizeof(string128),"RA: ON");
			else format(string128,sizeof(string128),"RA: off");
			if(BuildAdmin == 1) format(string128,sizeof(string128),"%s BA: ON",string128);
			else format(string128,sizeof(string128),"%s BA: off",string128);
			if(RRotation >= 0) format(string128,sizeof(string128),"%s RR: ON",string128);
			else format(string128,sizeof(string128),"%s RR: off",string128);
			RefreshMenuHeader(playerid,MAdmin,string128);
		}
		return 1;
	}
	else if(Current == MPMode)
	{
		if(row == 5)
		{
			 ShowMenuForPlayerEx(MAdmin,playerid);
			 return 1;
		}
		PrizeMode = row;
		if     (PrizeMode == 0) string128 = "Fixed";
		else if(PrizeMode == 1) string128 = "Dynamic";
		else if(PrizeMode == 2) string128 = "Join Fee";
		else if(PrizeMode == 3) string128 = "Join Fee + Fixed";
		else if(PrizeMode == 4) string128 = "Join Fee + Dynamic";
		format(string128,sizeof(string128),"Mode: %s",string128);
		RefreshMenuHeader(playerid,MPMode,string128);
		return 1;
	}
	else if(Current == MPrize)
	{
	    if(row == 6)
		{
	        ShowMenuForPlayerEx(MAdmin,playerid);
	        return 1;
	    }
	    if     (row == 0) Prize += 100;
	    else if(row == 1) Prize += 1000;
	    else if(row == 2) Prize += 10000;
	    else if(row == 3) Prize -= 100;
	    else if(row == 4) Prize -= 1000;
	    else if(row == 5) Prize -= 10000;
	    if(Prize < 0) Prize = 0;
		format(string128,sizeof(string128),"Amount: %d",Prize);
		RefreshMenuHeader(playerid,MPrize,string128);
		return 1;
	}
	else if(Current == MDyna)
	{
		if(row == 4)
		{
		    ShowMenuForPlayerEx(MAdmin,playerid);
		    return 1;
		}
		if     (row == 0) DynaMP++;
		else if(row == 1) DynaMP+=5;
		else if(row == 2) DynaMP--;
		else if(row == 3) DynaMP-=5;
		else if(DynaMP < 1) DynaMP = 1;
		format(string128,sizeof(string128),"Multiplier: %dx",DynaMP);
		RefreshMenuHeader(playerid,MDyna,string128);
		return 1;
	}
	else if(Current == MBuild)
	{
	    if(row == 0)
		{
			format(string128,sizeof(string128),"Laps: %d",Blaps[b(playerid)]);
			SetMenuColumnHeader(MLaps,0,string128);
			ShowMenuForPlayerEx(MLaps,playerid);
		}
	    else if(row == 1)
		{
			format(string128,sizeof(string128),"Mode: %s",ReturnModeName(Bracemode[b(playerid)]));
			SetMenuColumnHeader(MRacemode,0,string128);
			ShowMenuForPlayerEx(MRacemode,playerid);
		}
		else if(row == 2)
		{
		    format(string128,sizeof(string128),"Size: %0.2f",BCPsize[b(playerid)]);
		    SetMenuColumnHeader(MCPsize,0,string128);
		    ShowMenuForPlayerEx(MCPsize,playerid);
		}
	    else if(row == 3)
		{
	        if(BAirrace[b(playerid)] == 0)
			{
				BAirrace[b(playerid)] = 1;
				format(string128,sizeof(string128),"Air race: ON");
			}
   	        else if(BAirrace[b(playerid)] == 1)
   			{
				BAirrace[b(playerid)] = 0;
				format(string128,sizeof(string128),"Air race: off");
			}
   	        RefreshMenuHeader(playerid,MBuild,string128);
	    }
	    else if(row == 4)
		{
	        clearrace(playerid);
	        HideMenuForPlayer(MBuild,playerid);
			return 1;
	    }
	    else if(row == 5)
		{
	        HideMenuForPlayer(MBuild,playerid);
	    }
	    return 1;
	}
	else if(Current == MLaps)
	{
	    if(row == 6)
		{
	        if(RaceBuilders[playerid] != 0) ShowMenuForPlayerEx(MBuild,playerid);
	        else ShowMenuForPlayerEx(MRace,playerid);
	        return 1;
		}
		new change=0;
	    if     (row == 0) change++;
		else if(row == 1) change+=5;
		else if(row == 2) change+=10;
		else if(row == 3) change--;
		else if(row == 4) change-=5;
		else if(row == 5) change-=10;
		if(RaceBuilders[playerid] != 0) {
		    Blaps[b(playerid)] += change;
			if(Blaps[b(playerid)] < 1) Blaps[b(playerid)] = 1;
			format(string128,sizeof(string128),"Laps: %d",Blaps[b(playerid)]);
			RefreshMenuHeader(playerid,MLaps,string128);
		}
		else
		{
			Racelaps += change;
			if(Racelaps < 1) Racelaps = 1;
			format(string128,sizeof(string128),"Laps: %d",Racelaps);
			RefreshMenuHeader(playerid,MLaps,string128);
		}
		return 1;
	}
	else if(Current == MRacemode)
	{
		if(row == 4)
		{
		    if(RaceBuilders[playerid] != 0) ShowMenuForPlayerEx(MBuild,playerid);
		    else ShowMenuForPlayerEx(MRace,playerid);
		    return 1;
		}
		if(RaceBuilders[playerid] != 0)
		{
		    Bracemode[b(playerid)]=row;
			if(Bracemode[b(playerid)] == 2 && BCurrentCheckpoints[b(playerid)] < 3)
			{
				SendClientMessage(playerid,COLOR_YELLOW,"Cannot set racemode 2 with only 2 CPs!");
				Bracemode[b(playerid)] = 1;
			}
			format(string128,sizeof(string128),"Mode: %s",ReturnModeName(Bracemode[b(playerid)]));
			RefreshMenuHeader(playerid,MRacemode,string128);
			return 1;
		}
		else
		{
		    Racemode = row;
			if(Racemode == 2 && LCurrentCheckpoint < 2)
			{
				SendClientMessage(playerid,COLOR_YELLOW,"Cannot set racemode 2 with only 2 CPs!");
				Racemode = 1;
			}
			format(string128,sizeof(string128),"Mode: %s",ReturnModeName(Racemode));
			RefreshMenuHeader(playerid,MRacemode,string128);
		}
		return 1;
	}
	else if(Current == MRace)
	{
	    if(row == 0)
		{
			format(string128,sizeof(string128),"Laps: %d",Racelaps);
			SetMenuColumnHeader(MLaps,0,string128);
			ShowMenuForPlayerEx(MLaps,playerid);
		}
	    else if(row == 1)
		{
			format(string128,sizeof(string128),"Mode: %s",ReturnModeName(Racemode));
			SetMenuColumnHeader(MRacemode,0,string128);
            ShowMenuForPlayerEx(MRacemode,playerid);
		}
		else if(row == 2)
		{
		    format(string128,sizeof(string128),"Size: %0.2f",CPsize);
		    SetMenuColumnHeader(MCPsize,0,string128);
		    ShowMenuForPlayerEx(MCPsize,playerid);
		}
	    else if(row == 3)
		{
	        if(Airrace == 0)
			{
				Airrace = 1;
				format(string128,sizeof(string128),"Air race: ON");
			}
			else if(Airrace == 1)
			{
				Airrace = 0;
				format(string128,sizeof(string128),"Air race: off");
			}
			RefreshMenuHeader(playerid,MRace,string128);
	    }
		else if(row == 4)
		{
			if(RaceActive == 0)
			{
				startrace();
		        HideMenuForPlayer(MRace,playerid);
			}
			else SendClientMessage(playerid,COLOR_YELLOW,"Race is already active!");
		}
		else if(row == 5) HideMenuForPlayer(MRace,playerid);
		return 1;
	}
	else if(Current == MFee)
	{
	    if(row == 6)
		{
	        ShowMenuForPlayerEx(MAdmin,playerid);
	        return 1;
	    }
	    if(row == 0) JoinFee +=100;
	    if(row == 1) JoinFee +=1000;
	    if(row == 2) JoinFee +=10000;
	    if(row == 3) JoinFee -=100;
	    if(row == 4) JoinFee -=1000;
	    if(row == 5) JoinFee -=10000;
	    if(JoinFee < 0) JoinFee = 0;
		format(string128,sizeof(string128),"Fee: %d$",JoinFee);
	    RefreshMenuHeader(playerid,MFee,string128);
	    return 1;
	}
	else if(Current == MCPsize)
	{
	    if(row == 6)
		{
			if(RaceBuilders[playerid] != 0) ShowMenuForPlayerEx(MBuild,playerid);
			else ShowMenuForPlayerEx(MRace,playerid);
	        return 1;
	    }
		new Float:change;
	    if(row == 0) change +=0.1;
	    if(row == 1) change +=1.0;
	    if(row == 2) change +=10.0;
		if(row == 3) change -=0.1;
		if(row == 4) change -=1.0;
		if(row == 5) change -=10.0;
		if(RaceBuilders[playerid] != 0)
		{
		    BCPsize[b(playerid)] += change;
			if(BCPsize[b(playerid)] < 1.0) BCPsize[b(playerid)] = 1.0;
			if(BCPsize[b(playerid)] > 32.0) BCPsize[b(playerid)] = 32.0;
			format(string128,sizeof(string128),"Size %0.2f",BCPsize[b(playerid)]);
			RefreshMenuHeader(playerid,MCPsize,string128);
		}
		else
		{
		    CPsize += change;
		    if(CPsize < 1.0) CPsize = 1.0;
		    if(CPsize > 32.0) CPsize = 32.0;
		    format(string128,sizeof(string128),"Size %0.2f",CPsize);
		    RefreshMenuHeader(playerid,MCPsize,string128);
		}
		return 1;
	}
	else if(Current == MDelay)
	{
	    if(row == 4)
		{
	        ShowMenuForPlayerEx(MAdmin,playerid);
	        return 1;
	    }
		if     (row == 0) MajorityDelay+=10;
		else if(row == 1) MajorityDelay+=60;
		else if(row == 2) MajorityDelay-=10;
		else if(row == 3) MajorityDelay-=60;
		if(MajorityDelay <= 0)
		{
			MajorityDelay=0;
			format(string128,sizeof(string128),"Delay: disabled");
		}
		else format(string128,sizeof(string128),"Delay: %ds",MajorityDelay);
		RefreshMenuHeader(playerid,MDelay,string128);
		return 1;
	}
 	return 1;
}
//------------------------------------------------------------------------------

public OnPlayerExitedMenu(playerid)
{
	new Menu:Current = GetPlayerMenu(playerid);
	HideMenuForPlayer(Current, playerid);
	TogglePlayerControllable(playerid,true);
	return 1;
}
//----------------------------------------------------------------------------



//
//          ____________________________________________________
//       	|                                                  |
//			|                   CUSTOM FUNCTIONS               |
//          | 	                                               |
//          ____________________________________________________
//


forward CreatePlayerVehicle(playerid, modelid);
public CreatePlayerVehicle(playerid, modelid) {

	if(gTeam[playerid] && gTeam[playerid] < 50 && gTeam[playerid] > 56) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You are in a DM of AFK area and cannot spawn a vehicle. Type /leave");
	RemovePlayerFromVehicle(playerid);
	new Float:a;
	GetPlayerFacingAngle(playerid, a);
	GetPlayerPos(playerid, playerx, playery, playerz);
	SetPlayerPos(playerid,playerx,playery,playerz);
	if(modelid < MIN_VEHI_ID || modelid > MAX_VEHI_ID) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} Invalid Vehicle MODELID/NAME. Check http://wiki.sa-mp.com/wiki/Vehicle_Model_ID_List");
//	if(modelid == 569 || modelid == 570) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} Models 569 and 570 are buggy and cannot be spawned by players at this time");
	new bad,trailer,plane,boat,train;
	switch(modelid)
	{
	    case vHUNTER, vHYDRA, vRHINO, vSEASPARROW: bad = 1; // gun vehicles
		case 430,446,452,453,454,472,473,484,493,595: boat = 1; //boat
		case 435,450,584,591,606,607,608,610,611: trailer = 1; //trailer
		case 449,537,538,569,570,590: train = 1; //train
		case 417,465,469,487,488,497,548,563,460,476,511,512,513,519,539,553,577,592,593: plane = 1; //plane
  	}
  	if(boat) {}
  	if(plane && RaceParticipant[playerid]) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You cannot spawn an airplane/helicopter while in a race.");
  	else if(train) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} At this time, players cannot spawn trains. Please use the /train command to teleport to a train station.");
  	else if(bad && safe[playerid]) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} Sorry homie, you can't spawn that vehicle in safe zones. Try again outside of the RED area on map!");
	else if((bad || train || plane) && gTeam[playerid] > 49 && gTeam[playerid] < 57) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} Sorry homie, you can't spawn that vehicle in DM. ");
	if(RaceParticipant[playerid] && (bad || trailer || plane)) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You cannot spawn this vehicle during a race. Type /leave to leave the race.");
	if(playercar[playerid] != INVALID_VEHICLE_ID)
	{
		DestroyVehicle(playercar[playerid]);
		playercar[playerid] = INVALID_VEHICLE_ID;
	}
	playercar[playerid] = CreateVehicle(modelid,-5000.00,5000.00,100.0,a,-1,-1,1500);
    SetVehiclePos(playercar[playerid],playerx,playery,playerz+2);
	LinkVehicleToInterior(playercar[playerid], GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(playercar[playerid], GetPlayerVirtualWorld(playerid));
	PutPlayerInPlayerCar(playerid);
	GameTextForPlayer(playerid,"~w~YOU MUST TYPE ~r~/UNLOCK~n~~w~TO ALLOW PPL IN CAR",5000,3);
	format(string32, sizeof(string32), "~g~%s ~w~%i", vehName[pmodelid[playerid]-400],pmodelid[playerid]);
	format(string128,sizeof(string128),"~w~Veh Model: ~y~%s~w~",string32);
	PlayerTextDrawSetString(playerid,VehModel[playerid],string128);
	DestroyNeon(playerid);
	/*
	if(IsValidObject(vobject[pvehicleid[playerid]]))
	{
		DestroyObject(vobject[pvehicleid[playerid]]);
	 	vobject[pvehicleid[playerid]] = INVALID_OBJECT_ID;
 	}
 	*/
	if(modelid == 438) ChangeVehiclePaintjob(playercar[playerid],0);
	return playercar[playerid];
}

forward CreatePlayerTrailer(playerid, modelid);
public CreatePlayerTrailer(playerid, modelid)
{
	if(gTeam[playerid]) return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You are in a DM of AFK area and cannot spawn a vehicle. Type /leave");
	if(playertrailer[playerid] != INVALID_VEHICLE_ID)
	{
	    DestroyVehicle(playertrailer[playerid]);
	    playertrailer[playerid] = INVALID_VEHICLE_ID;
	}
	new Float:a;
	GetPlayerFacingAngle(playerid, a);
	GetPlayerPos(playerid, playerx, playery, playerz);
	switch(modelid)
	{
		case 435,450,584,591,606,607,608,610,611:
		{
		    playertrailer[playerid] = CreateVehicle(modelid,-5000.00,5000.00,100.0,a,-1,-1,1500);
		    SetVehiclePos(playertrailer[playerid],playerx,playery-4,playerz+2);
		    SetVehicleZAngle(playertrailer[playerid],a);
			LinkVehicleToInterior(playertrailer[playerid], GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(playertrailer[playerid], GetPlayerVirtualWorld(playerid));
			return playertrailer[playerid];
		}
		default: return SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} Sorry! An invalid modelid was passed to CreatePlayerTrailer!");
  	}
	return 1;
}


forward KillPlayerVehicle(playerid);
public KillPlayerVehicle(playerid)
{
	if(playercar[playerid] == INVALID_VEHICLE_ID && playertrailer[playerid] == INVALID_VEHICLE_ID) return 1;
	else
	{
		if(IsValidObject(vobject[playercar[playerid]]))
		{
			DestroyObject(vobject[playercar[playerid]]);
			vobject[playercar[playerid]] = INVALID_OBJECT_ID;
		}
		if(playercar[playerid] != INVALID_VEHICLE_ID)
		{
			DestroyVehicle(playercar[playerid]);
			playercar[playerid] = INVALID_VEHICLE_ID;

		}
		if(playertrailer[playerid] != INVALID_VEHICLE_ID)
		{
			DestroyVehicle(playertrailer[playerid]);
			playertrailer[playerid] = INVALID_VEHICLE_ID;
		}
		if(IsPlayerConnected(playerid)) pvehicleid[playerid] = GetPlayerVehicleID(playerid); //isplayerconnected = intentional script lag
	}
	return 1;
}

forward PutPlayerInPlayerCar(playerid);
public PutPlayerInPlayerCar(playerid)
{
	PutPlayerInVehicle(playerid,playercar[playerid],0);
	TogglePlayerControllable(playerid,true);
	if(IsPlayerConnected(playerid))
	{
		pvehicleid[playerid] = playercar[playerid];
		pmodelid[playerid] = GetVehicleModel(playercar[playerid]);
//		new str[32];
//		format(str, sizeof(str), "~g~%s ~w~%i", vehName[pmodelid[playerid]-400],pmodelid[playerid]);
//		GameTextForPlayer(playerid, str, 3000, 1);
	}
	return 1;
}

forward ShowMenuForPlayerEx(Menu:menuid, playerid);
public ShowMenuForPlayerEx(Menu:menuid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(pvehicleid[playerid] != INVALID_VEHICLE_ID) SendClientMessage(playerid, COLOR_YELLOW, "To make selection please use the ACCELERATE or SPACEBAR key! Press ENTER to close.");
		else if(pstate[playerid] == PLAYER_STATE_ONFOOT) SendClientMessage(playerid, COLOR_YELLOW, "To make selection please use the SPACEBAR key! Press ENTER to close.");
		TogglePlayerControllable(playerid,false);
	 	ShowMenuForPlayer(Menu:menuid,playerid);
	}
	return 1;
}



//forward IsSkinValid(skinid);
stock IsSkinValid(skinid)
{
	if (skinid < 0 || skinid > 299) return false;
    else return true;
}



#if defined DM
// DEATHMATCH ROUTINES *********   USING STANDARD WARP    **************

forward MilitaryDM(playerid);
public MilitaryDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomMilitaryDM));
    SetPlayerPosEx(playerid, gRandomMilitaryDM[rand][0], gRandomMilitaryDM[rand][1], gRandomMilitaryDM[rand][2]+2);
    SetPlayerArmour(playerid,0);
   	SetPlayerWorldBounds(playerid, 537.1823, -128.4566, 2370.609, 1576.513);
   	ResetPlayerWeapons(playerid);
	gTeam[playerid] = 5;
   	// SetPlayerVirtualWorld(playerid,WORLD_DM);
	GivePlayerWeapon(playerid,16,99999);
    GivePlayerWeapon(playerid,31,99999);
    GivePlayerWeapon(playerid,35,99999);
    SetPlayerArmour(playerid, 100);
	SetPlayerSkin(playerid,287);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	DMSpam(playerid);
    return 1;
}
forward SawnOffDM(playerid);
public SawnOffDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    SetPlayerInterior(playerid, 0);
    SetPlayerArmour(playerid,0);
    new rand = random(sizeof(gRandomSawnOffDM));
	SetPlayerPosEx(playerid, gRandomSawnOffDM[rand][0], gRandomSawnOffDM[rand][1], gRandomSawnOffDM[rand][2],gRandomSawnOffDM[rand][3]);
   	SetPlayerWorldBounds(playerid, -2394.683, -2502.838, 716.3557, 598.0067);
   	ResetPlayerWeapons(playerid);
	gTeam[playerid] = 7;
   	SetPlayerVirtualWorld(playerid,WORLD_DM);
	GivePlayerWeapon(playerid, 26, 99999);
	SetPlayerArmour(playerid, 100);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
    return 1;
}
forward SniperDM(playerid);
public SniperDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomSniperDM));
	SetPlayerArmour(playerid,0);
	SetPlayerPosEx(playerid, gRandomSniperDM[rand][0], gRandomSniperDM[rand][1], gRandomSniperDM[rand][2],gRandomSniperDM[rand][3]);
	SetPlayerWorldBounds(playerid, 362.0141, 46.7115, 1529.802, 1272.888);
    SetPlayerVirtualWorld(playerid,WORLD_DM);
	ResetPlayerWeapons(playerid);
	gTeam[playerid] = 8;
	GivePlayerWeapon(playerid, 34, 99999);
	SetPlayerArmour(playerid, 100);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
	return 1;
}
forward RocketDM(playerid);
public RocketDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomRocketDM));
	SetPlayerArmour(playerid,0);
	gTeam[playerid] = 9;
	SetPlayerPosEx(playerid, gRandomRocketDM[rand][0], gRandomRocketDM[rand][1], gRandomRocketDM[rand][2],gRandomRocketDM[rand][3],17);
	SetPlayerWorldBounds(playerid, 887.5186, 116.7788, 385.3699, -326.9805);
    SetPlayerVirtualWorld(playerid,WORLD_DM);
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 35, 99999);
	SetPlayerArmour(playerid, 100);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
	return 1;
}
forward MinigunDM(playerid);
public MinigunDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	gTeam[playerid] = 10;
    new rand = random(sizeof(gRandomMinigunDM));
    SetPlayerArmour(playerid,0);
    SetPlayerPosEx(playerid, gRandomMinigunDM[rand][0], gRandomMinigunDM[rand][1], gRandomMinigunDM[rand][2]+2,gRandomMinigunDM[rand][3]);
 	SetPlayerWorldBounds(playerid, 1422.014, 1269.725, 2233.659, 2098.277);
 	SetPlayerVirtualWorld(playerid,WORLD_DM);
 	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,38,99999);
	SetPlayerArmour(playerid, 100);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
	return 1;
}
forward HouseDM(playerid);
public HouseDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomHouseDMSpawns));
	SetPlayerArmour(playerid,0);
	SetPlayerPosEx(playerid, gRandomHouseDMSpawns[rand][0], gRandomHouseDMSpawns[rand][1], gRandomHouseDMSpawns[rand][2], gRandomHouseDMSpawns[rand][3], 7);
//	SetPlayerWorldBounds(playerid, 2493.814, 2204.798, -1062.067, -1417.363);
	SetPlayerVirtualWorld(playerid,WORLD_DM);
	ResetPlayerWeapons(playerid);
 	gTeam[playerid] = 13;
	GivePlayerWeapon(playerid, 25, 99999);
	GivePlayerWeapon(playerid, 24, 99999);
    GivePlayerWeapon(playerid, 29, 99999);
    GivePlayerWeapon(playerid, 31, 99999);
    GivePlayerWeapon(playerid, 32, 99999);
    SetPlayerArmour(playerid, 100);
 	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
    return 1;
}

forward GasDM(playerid);
public GasDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	SetPlayerPosEx(playerid, -1324.4618,2676.7446,49.6320,86.5);
	SetPlayerWorldBounds(playerid, -1144.432, -1401.345, 2802.69, 2545.777);
	SetPlayerVirtualWorld(playerid,WORLD_DM);
	SetPlayerArmour(playerid,0);
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 37, 99999);
	SetPlayerArmour(playerid, 100);
	gTeam[playerid] = 17;
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
	return 1;
}
forward ShipDM(playerid);
public ShipDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomShipSpawns));
	SetPlayerArmour(playerid,0);
	SetPlayerPosEx(playerid, gRandomShipSpawns[rand][0], gRandomShipSpawns[rand][1], gRandomShipSpawns[rand][2]);
	SetPlayerWorldBounds(playerid, -2195.441, -2580.811, 1658.258, 1448.057);
	SetPlayerVirtualWorld(playerid,WORLD_DM);
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 25, 99999);
	GivePlayerWeapon(playerid, 24, 99999);
    GivePlayerWeapon(playerid, 29, 99999);
    GivePlayerWeapon(playerid, 31, 99999);
    GivePlayerWeapon(playerid, 32, 99999);
    SetPlayerArmour(playerid, 100);
	gTeam[playerid] = 18;
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
    return 1;
}
forward SwordDM(playerid);
public SwordDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomSwordDM));
	SetPlayerArmour(playerid,0);
	SetPlayerPosEx(playerid, gRandomSwordDM[rand][0], gRandomSwordDM[rand][1], gRandomSwordDM[rand][2], gRandomSwordDM[rand][3],5);
 	gTeam[playerid] = 20;
 	SetPlayerVirtualWorld(playerid,WORLD_DM);
 	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 8,1);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
    return 1;
}
forward DeagleDM(playerid);
public DeagleDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
	new rand = random(sizeof(gRandomDeagleDM));
	SetPlayerArmour(playerid,0);
	SetPlayerPosEx(playerid, gRandomDeagleDM[rand][0], gRandomDeagleDM[rand][1], gRandomDeagleDM[rand][2], gRandomDeagleDM[rand][3],3);
	SetPlayerArmour(playerid,100.0);
// 	SetPlayerHealth(playerid,100.0);
 	gTeam[playerid] = 21;
 	SetPlayerVirtualWorld(playerid,WORLD_DM);
 	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 24,99999);
	godmode[playerid] = 0;
	ShowGodTD(playerid);
    TextDrawShowForPlayer(playerid,Leave);
    DMSpam(playerid);
    return 1;
}

// ===============================
//              GANGS
// ===============================


forward FamilyDM(playerid);
public FamilyDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomFamilyDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomFamilyDM[rand][0], gRandomFamilyDM[rand][1], gRandomFamilyDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerArmour(playerid,0);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
   	SetPlayerWorldBounds(playerid, 2977.858, 688.9946, -980.9415, -2172.085);
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    GivePlayerWeapon(playerid,25,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(FamilySkin)); // generate random gang skin
	SetPlayerSkin(playerid,FamilySkin[rand]);
    gTeam[playerid] = 50; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_GREEN);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}
forward BallaDM(playerid);
public BallaDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomBallaDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomBallaDM[rand][0], gRandomBallaDM[rand][1], gRandomBallaDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerArmour(playerid,0);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
   	SetPlayerWorldBounds(playerid, 2977.858, 688.9946, -980.9415, -2172.085);
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    GivePlayerWeapon(playerid,25,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(BallaSkin)); // generate random gang skin
	SetPlayerSkin(playerid,BallaSkin[rand]);
    gTeam[playerid] = 51; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_PURPLE);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}
forward VagosDM(playerid);
public VagosDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomVagosDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomVagosDM[rand][0], gRandomVagosDM[rand][1], gRandomVagosDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
   	SetPlayerWorldBounds(playerid, 2977.858, 688.9946, -980.9415, -2172.085);
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    GivePlayerWeapon(playerid,25,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(VagosSkin)); // generate random gang skin
	SetPlayerSkin(playerid,VagosSkin[rand]);
    gTeam[playerid] = 52; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_YELLOW);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}
forward AztecaDM(playerid);
public AztecaDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomAztecaDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomAztecaDM[rand][0], gRandomAztecaDM[rand][1], gRandomAztecaDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
   	SetPlayerWorldBounds(playerid, 2977.858, 688.9946, -980.9415, -2172.085);
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    GivePlayerWeapon(playerid,25,99999);
    SetPlayerArmour(playerid, 100);
   	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	rand = random(sizeof(AztecaSkin)); // generate random gang skin
	SetPlayerSkin(playerid,AztecaSkin[rand]);
    gTeam[playerid] = 53; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_TURQUISE);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	DMSpam(playerid);
    return 1;
}

forward RifaDM(playerid);
public RifaDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomRifaDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomRifaDM[rand][0], gRandomRifaDM[rand][1], gRandomRifaDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(RifaSkin)); // generate random gang skin
	SetPlayerSkin(playerid,RifaSkin[rand]);
    gTeam[playerid] = 54; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_LIGHTBLUE);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}
forward TriadDM(playerid);
public TriadDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomTriadDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomTriadDM[rand][0], gRandomTriadDM[rand][1], gRandomTriadDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(TriadSkin)); // generate random gang skin
	SetPlayerSkin(playerid,TriadSkin[rand]);
    gTeam[playerid] = 55; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_RED);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}
forward DaNangDM(playerid);
public DaNangDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomDaNangDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomDaNangDM[rand][0], gRandomDaNangDM[rand][1], gRandomDaNangDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(DaNangSkin)); // generate random gang skin
	SetPlayerSkin(playerid,DaNangSkin[rand]);
    gTeam[playerid] = 56; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_ORANGE);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	DMSpam(playerid);
    return 1;
}
forward MafiaDM(playerid);
public MafiaDM(playerid) {
    if(RaceParticipant[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} You are in a DM or AFK, or you are in a race. Type {FFFF00}/leave{C0C0C0} and then try your command again.");
    new rand = random(sizeof(gRandomMafiaDM)); // generate random DM spawn coords
    SetPlayerPosEx(playerid, gRandomMafiaDM[rand][0], gRandomMafiaDM[rand][1], gRandomMafiaDM[rand][2]+2);
   	ResetPlayerWeapons(playerid);
   	SetPlayerVirtualWorld(playerid,WORLD_GANG); //put player away from freeroam
	GivePlayerWeapon(playerid,5,1);
    GivePlayerWeapon(playerid,24,99999);
    GivePlayerWeapon(playerid,30,99999);
    SetPlayerArmour(playerid, 100);
	rand = random(sizeof(MafiaSkin)); // generate random gang skin
	SetPlayerSkin(playerid,MafiaSkin[rand]);
    gTeam[playerid] = 57; // gteam 50 = gang team
    SetPlayerColor(playerid,COLOR_BROWN);
    godmode[playerid] = 0;
	ShowGodTD(playerid);
	TextDrawShowForPlayer(playerid,Leave);
	SendClientMessage(playerid,COLOR_YELLOW,"!!!    You are allowed to use /v in this DM (limitations apply)");
	DMSpam(playerid);
    return 1;
}

forward DMSpam(playerid);
public DMSpam(playerid)
{
	SetPlayerTeam(playerid,playerid);
#if defined TEXTDRAWS
	TextDrawHideForAll(DMSPAM);
	switch(gTeam[playerid])
	{
	    case 5: format(string128,sizeof(string128),"~y~%s joined Military War. ~r~/dm",pname[playerid]);
	    case 7: format(string128,sizeof(string128),"~y~%s joined Sawn-Off DM. ~r~/dm",pname[playerid]);
	    case 8: format(string128,sizeof(string128),"~y~%s joined Sniper DM. ~r~/dm",pname[playerid]);
	    case 9: format(string128,sizeof(string128),"~y~%s joined RPG DM. ~r~/dm",pname[playerid]);
	    case 10: format(string128,sizeof(string128),"~y~%s joined Minigun DM. ~r~/dm",pname[playerid]);
	    case 13: format(string128,sizeof(string128),"~y~%s joined Home Invasion DM. ~r~/dm",pname[playerid]);
	    case 17: format(string128,sizeof(string128),"~y~%s joined Flamethrower DM. ~r~/dm",pname[playerid]);
	    case 18: format(string128,sizeof(string128),"~y~%s joined Container DM. ~r~/dm",pname[playerid]);
	    case 20: format(string128,sizeof(string128),"~y~%s joined Katana DM. ~r~/dm",pname[playerid]);
	    case 21: format(string128,sizeof(string128),"~y~%s joined Desert Eagle DM. ~r~/dm",pname[playerid]);
	    case 50..58:
		{
			format(string128,sizeof(string128),"~y~%s joined Gang DM. ~r~/gang",pname[playerid]);
			GangZoneShowForPlayer(playerid, zoneFamily, 0x00FF0096);
     		GangZoneShowForPlayer(playerid, zoneBalla, 0x80008096);
			GangZoneShowForPlayer(playerid, zoneVagos, 0xFFFF0096);
			GangZoneShowForPlayer(playerid, zoneAzteca, 0x00FFFF96);
		}
	}
	TextDrawSetString(DMSPAM,string128);
	TextDrawSetOutline(DMSPAM, 1);
	TextDrawFont(DMSPAM, 3);
	TextDrawSetProportional(DMSPAM, 2);
	TextDrawLetterSize(DMSPAM, 0.30, 0.80);
//	TextDrawShowForAll(DMSPAM);
	foreach(Player,i)
	{
		if(!hideui[i]) TextDrawShowForPlayer(i,DMSPAM);
	}
	hidespamtimer = SetTimer("HideSpam",10000,0);
#endif
	return 1;
}

forward HideSpam();
public HideSpam()
{
	KillTimer(hidespamtimer);
	TextDrawHideForAll(DMSPAM);
	return 1;
}
#endif //dm

SetPlayerPosEx(playerid, Float:x, Float:y, Float:z, Float:a=0.0, Interior=0)
{
	if(chicken[playerid] != INVALID_OBJECT_ID) ChickenDestroy(playerid);
	if(cow[playerid] != INVALID_OBJECT_ID) CowDestroy(playerid);
	if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
	CancelFlyMode(playerid);
    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, a);
    SetPlayerInterior(playerid, Interior);
//    SetPlayerVirtualWorld(playerid,World);
    SetCameraBehindPlayer(playerid);
    if(gTeam[playerid] && godmode[playerid])
    {
  		godmode[playerid] = 0;
  		ShowGodTD(playerid);
    }
    if(IsPlayerAdmin(playerid))
	{
		format(string128,sizeof(string128),"{C0C0C0}[DEBUG]:{C0C0C0} World %i",GetPlayerVirtualWorld(playerid));
		SendClientMessage(playerid,COLOR_SYSTEM,string128);
	}
	return 1;
}

SetVehiclePosEx(playerid, vehicleid, Float:x, Float:y, Float:z, Float:a=0.0, Interior=0)
{
	if(badcar[playerid]) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} This vehcile unable to teleport!");
	if(pstate[playerid] == PLAYER_STATE_DRIVER && pvehicleid[playerid]  != INVALID_VEHICLE_ID)
	{
	    EnableStuntBonusForPlayer(playerid, false);
	    if((pmodelid[playerid] != 406 && (cantrace[playerid]) || aircraft[playerid])) return SendClientError(playerid,COLOR_ERROR,"{CC0000}[ERROR]:{C0C0C0} This vehicle type is not allowed to teleport.");
		new trailer2;
		if(IsTrailerAttachedToVehicle(vehicleid))
	    {
	        trailer2 = GetVehicleTrailer(vehicleid);
		}
	    SetPlayerInterior(playerid, Interior);
	    SetVehiclePos(vehicleid, x, y, z);
	    SetVehicleZAngle(vehicleid, a);
	    LinkVehicleToInterior(vehicleid, Interior);
		if(trailer2)
		{
			LinkVehicleToInterior(trailer2, Interior);
			AttachTrailerToVehicle(trailer2,vehicleid);
		}
  	    SetCameraBehindPlayer(playerid);
  	    EnableStuntBonusForPlayer(playerid, true);
	}
	return 1;
}

GetVehicleModelIDFromName(vname[]) {
	for(new i = 0; i < 211; i++) {
		if (strfind(vehName[i], vname, true) != -1) {
			return i + MIN_VEHI_ID;
		}
	}
	return -1;
}

GetVehicleWithinDistance( playerid, Float:x1, Float:y1, Float:z1, Float:dist, &veh)
{
	for(new i = 1; i < MAX_VEHICLES; i++)
	{
		if(pvehicleid[playerid] != i )
		{
	    	new Float:x, Float:y, Float:z;
	    	new Float:x2, Float:y2, Float:z2;
			GetVehiclePos(i, x, y, z);
			x2 = x1 - x; y2 = y1 - y; z2 = z1 - z;
			new Float:vDist = (x2*x2+y2*y2+z2*z2);
			if( vDist < dist){
				veh = i;
				dist = vDist;
			}
		}

	}
	#pragma unused playerid
}

IsVehicleRcTram( vehicleid )
{
    new model = GetVehicleModel(vehicleid);
   	switch(model)
	{
		case D_TRAM, RC_GOBLIN, RC_BARON, RC_BANDIT, RC_RAIDER, RC_TANK, D_AT400, D_TRAIN,D_TRAIN2: return 1;
		default: return 0;
	}
	return 0;
}

CreateObjectEx(playerid,modelid)
{
	if(gTeam[playerid] || RaceParticipant[playerid])
	{
		SendClientMessage(playerid, COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} You cannot spawn objects while in DM or Race.");
		return INVALID_OBJECT_ID;
	}
	new object;
	DestroyObjectEx(playerid);
	/*
	new x = 0;
	foreach(Player,i)
	{
    	if(chicken[i] != INVALID_OBJECT_ID || cow[i] != INVALID_OBJECT_ID) x++;
	}
	*/
	switch(modelid)
	{
	    case CHICKEN:
		{
  	//		if(x > 20) return SendClientError(playerid,COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} There are a lot of other chickens and cows right now. Please try again when its less crowded");
		    SendClientMessage(playerid, COLOR_PINK, "{FF66FF}[TIP]:{C0C0C0} Your chicken will disappear if you use a command. Sorry...we had to.");
		    GetPlayerPos(playerid, playerx, playery, playerz);
			format(string128, sizeof(string128), "{FFFFFF}[SYSTEM]:{C0C0C0} %s is /CHICKEN!!", pname[playerid]);
			SendClientMessageToAll(COLOR_SYSTEM, string128);
			SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Type /chicken again to get out of the chicken suit! Press fire to make explosions.");
			chicken[playerid] = CreateObject(CHICKEN,playerx,playery,playerz-4,0.0,0.0,0.0);
			AttachObjectToPlayer(chicken[playerid], playerid, 0.0, 0.0, -1.3, 0.0, 0.0, 180.0);
			object = chicken[playerid];
		}
	    case COW:
		{
	//		if(x > 20) return SendClientError(playerid,COLOR_ERROR, "{CC0000}[ERROR]:{C0C0C0} There are a lot of other chickens and cows right now. Please try again when its less crowded");
	  	    SendClientMessage(playerid, COLOR_PINK, "{FF66FF}[TIP]:{C0C0C0} Your cow will disappear if you use a command. Sorry...we had to.");
		    GetPlayerPos(playerid, playerx, playery, playerz);
			format(string128, sizeof(string128), "{FFFFFF}[SYSTEM]:{C0C0C0} %s is having a /cow!!", pname[playerid]);
			SendClientMessageToAll(COLOR_SYSTEM, string128);
			SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} Type /cow again to get out of the cow suit! Press fire to make explosions.");
			cow[playerid] = CreateObject(COW,playerx,playery,playerz-4,0.0,0.0,0.0);
			AttachObjectToPlayer(cow[playerid], playerid, 0.0, 0.0, -1.3/*-0.1*/, 0.0, 0.0, 0.0);
			object = cow[playerid];
		}
	    case MINE:
		{
//			SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]:{C0C0C0} You have placed a bounce mine. Crash into it at full+ speed. Is funny w/ SNOS!");
		    GetPlayerPos(playerid, playerx, playery, playerz);
			mine[playerid] = CreateObject(MINE,playerx,playery,playerz,0.0,0.0,0.0);
			object = mine[playerid];
		}
	    case RAMP:
		{
//	    	SendClientMessage(playerid, COLOR_CONFIRM, "{33AA33}[CONFIRM]: {C0C0C0} You have placed a stunt ramp.");
		    new Float:face;
		    if(pstate[playerid] == PLAYER_STATE_ONFOOT)
			{
			    GetPlayerPos(playerid, playerx, playery, playerz);
			    GetPlayerFacingAngle(playerid,face);
			    GetXYInFrontOfPlayer(playerid, playerx, playery, 5);
			}
			else if(pstate[playerid] == PLAYER_STATE_DRIVER)
			{
				GetVehiclePos(pvehicleid[playerid], playerx, playery, playerz);
			    GetVehicleZAngle(pvehicleid[playerid],face);
			    GetXYInFrontOfVehicle(pvehicleid[playerid], playerx, playery, 10);
			}
			ramp[playerid] = CreateObject(RAMP,playerx,playery,playerz,0.0,0.0,face);
			object = ramp[playerid];
		}
	}
	return object;
}

forward DestroyObjectEx(playerid);
public DestroyObjectEx(playerid)
{
//	if(!HasPlayerObject(playerid)) return 1;
	if(chicken[playerid] != INVALID_OBJECT_ID)
	{
		ChickenDestroy(playerid);
	}
	if(cow[playerid] != INVALID_OBJECT_ID)
	{
		CowDestroy(playerid);
	}
	if(mine[playerid] != INVALID_OBJECT_ID)
	{
		MineDestroy(playerid);
	}
	if(ramp[playerid] != INVALID_OBJECT_ID)
	{
		RampDestroy(playerid);
	}
	return 1;
}

forward HasPlayerObject(playerid);
public HasPlayerObject(playerid)
{
	if(chicken[playerid] != INVALID_OBJECT_ID || cow[playerid] != INVALID_OBJECT_ID || mine[playerid] != INVALID_OBJECT_ID || ramp[playerid] != INVALID_OBJECT_ID) return true;
	else return false;
}

forward MineDestroy(playerid);
public MineDestroy(playerid)
{
	if(mine[playerid] != INVALID_OBJECT_ID)
	{ 
	    DestroyObject(mine[playerid]);
	    mine[playerid] = INVALID_OBJECT_ID;
	    GameTextForPlayer(playerid,"~w~STUNT MINE ~r~DESTROYED~n~~y~YOU CAN SPAWN ANOTHER OBJECT NOW",3000,3);
	}
}
forward RampDestroy(playerid);
public RampDestroy(playerid) {
	if(ramp[playerid] != INVALID_OBJECT_ID)
	{ 
	    DestroyObject(ramp[playerid]);
	    ramp[playerid] = INVALID_OBJECT_ID;
	    GameTextForPlayer(playerid,"~w~STUNT RAMP ~r~DESTROYED~n~~y~YOU CAN SPAWN ANOTHER OBJECT NOW",3000,3);
	}
}
forward ChickenDestroy(playerid);
public ChickenDestroy(playerid)
{
	if(chicken[playerid] != INVALID_OBJECT_ID)
	{ 
	    DestroyObject(chicken[playerid]);
	    chicken[playerid] = INVALID_OBJECT_ID;
	    GameTextForPlayer(playerid,"~w~CHICKEN OBJECT ~r~DESTROYED~n~~y~YOU CAN SPAWN ANOTHER OBJECT NOW",3000,3);
	}
}
forward CowDestroy(playerid);
public CowDestroy(playerid)
{
	if(cow[playerid] != INVALID_OBJECT_ID)
	{
	    DestroyObject(cow[playerid]);
	    cow[playerid] = INVALID_OBJECT_ID;
    	GameTextForPlayer(playerid,"~w~COW OBJECT ~r~DESTROYED~n~~y~YOU CAN SPAWN ANOTHER OBJECT NOW",3000,3);
	}
}
forward OneMinute();
public OneMinute()
{
	new rand = random(sizeof(gRandomStuntSpawn));
	new rand2 = random(sizeof(ambientSounds));
	foreach(Player,i)
	{
		foreach(Player,x)
		{
			if(x < 100) RemovePlayerMapIcon(i,x);
		}
		if(!afk[i]) minutesplayed[i]++;
		PlayerPlaySound(i,ambientSounds[rand2],gRandomStuntSpawn[rand][0], gRandomStuntSpawn[rand][1], gRandomStuntSpawn[rand][2]);
	}
	
	return 1;
}


forward FiveMinutes();
public FiveMinutes()
{
	new p = 0;
	foreach(Player,i)
	{
	    p++;
	  	if(Variables[i][LoggedIn])
	    {
	        new money = GetPlayerMoney(i);
		    SetUserInt(i,"Money",money);
		    SetUserInt(i,"Kills",kills[i]);
		    SetUserInt(i,"RaceWins",race1st[i]);
		    SetUserInt(i,"LoggedIn",0);
		    SetUserInt(i,"MinsPlayed",minutesplayed[i]);
		    SendClientMessage(i,COLOR_SYSTEM,"[STATS]: Your player-stats have been saved.");
	    }
 	}
 	printf("------------   Current Server Population: %i");
	return 1;
}

stock IsVehicleInRangeOfPoint(vehicleid, Float:radi, Float:x, Float:y, Float:z)
{
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetVehiclePos(vehicleid, oldposx, oldposy, oldposz);
        tempposx = (oldposx -x);
        tempposy = (oldposy -y);
        tempposz = (oldposz -z);
        if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
        {
                return 1;
        }
        return 0;
}


forward TenMinutes();
public TenMinutes()
{
	new weap,ammo;
	new obj = 0,veh = 0, ppl = 0;
	
	for(new veh2; veh2 < MAX_VEHICLES; veh2++)
	{
	    occupied[veh2] = 0;
	    if(IsVehicleInRangeOfPoint(veh2,100,0.0,0.0,0.0))
	    {
		    foreach(Player,i)
		    {
		        if(IsPlayerInVehicle(i,veh2) || playercar[i] == veh2) occupied[veh2] = 1;
		    }
		    if(!occupied[veh2]) SetVehicleToRespawn(veh2);
	    }
	}
	foreach(Player, i)
	{
	    if(!IsPlayerNPC(i))
        {
	        if(!Variables[i][LoggedIn]) SendClientMessage(i,COLOR_SYSTEM,"[STATS]: You are not logged into your account, so your stats are NOT saving!");
			ppl++;
			if(!gTeam[i])
			{
				weap = GetPlayerWeapon(i);
				ammo = GetPlayerAmmo(i);
				GivePlayerWeapon(i,35,1); //give 1 rpg
				GivePlayerWeapon(i,weap,ammo);
			}
			GivePlayerMoney(i,2000);
			if(daynight[i])
			{
			    new hour,minute;
				GetPlayerTime(i,hour,minute);
				if(hour == 23) SetPlayerTime(i,0,minute);
				else SetPlayerTime(i,hour++,minute);
			}
		}
		blnIllegalWeaponReported[i] = false;
	}

	SendClientMessageToAll(COLOR_PINK,"{FF66FF}[2nd Place]:{C0C0C0} You win 2nd place in beauty contest! Collect $10000+1x RPG.");
	for(new i = 0; i < MAX_OBJECTS; i++)
	{
	    if(IsValidObject(i)) obj++;
 	}
 	for(new i = 0; i < MAX_VEHICLES; i++)
	{
	    if(IsValidVehicle(i)) veh++;
 	}
	if(obj > 900) printf("*****  +_+_+_+_+   WARNING: Number of __objects__ ABOVE SAFE LEVELS !!");
	if(veh > 1800) printf("*****  +_+_+_+_+   WARNING: Number of __vehicles__ ABOVE SAFE LEVELS !!");
	format(string128,sizeof(string128),"[status] Players: %i Objects: %i Vehicles: %i",ppl,obj,veh);
	printf(string128);
 	automsg++;
	if(automsg == 10) automsg = 0;
	switch(automsg)
	{
	    #if defined SAMP03X
	    case 0: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Use /lock to lock your car doors and keep people from jacking you!");
	    case 1: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Register at http://everystuff.net and give a shout on the forums! PM \"kaiser souse\" there if you don't get email confirmation");
	    case 2: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} If your client restarts, says you're banned, and you do NOT get a ban {FFFFFF}REASON{C0C0C0}, its the SAMP fake-ban bug. Just rejoin and you\'ll get in!");
		case 3: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} For super-jump, use {FFFFFF}/jump{C0C0C0}. For super-NOS, use {FFFFFF}/snos{C0C0C0}. For list of all commands type {FFFFFF}/cmd{C0C0C0}.");
		case 4: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} We have many great deathmatch areas! Type {FFFFFF}/dm{C0C0C0} for a menu of them all!");
		case 5: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Lost the car that you spawned? Type {FFFFFF}/findcar{C0C0C0} to teleport back to it, or {FFFFFF}/getcar{C0C0C0} to bring it to you");
        case 6: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} We have a lot of properties you can buy, and we're always adding more. Stand in a green house icon and type {FFFFFF}/buyproperty");
        case 7: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Join our IRC channel! irc.gamesurge.net:6667 #Everystuff - Free web-client at gamesurge.net");
        case 8: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Make a fashion statement with {FFFFFF}/helmet{C0C0C0} or {FFFFFF}/glasses{C0C0C0}");
        case 9: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{C0C0C0} Wish there was a ramp there? use {FFFFFF}/putramp{C0C0C0}! For a car catapult, type {FFFFFF}/putskulls{C0C0C0} ");
		#else // samp03e
		case 0: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
	    case 1: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
	    case 2: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
		case 3: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
		case 4: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
		case 5: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
        case 6: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
        case 7: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
        case 8: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
        case 9: SendClientMessageToAll(COLOR_PINK,"{FF66FF}[TIP]:{FFFF00} This server will no longer be maintained. New server: 69.60.109.157:7777 | Get 0.3x at sa-mp.com or everystuff.net");
		#endif
	}
	#if defined IRC_ECHO
//	format(string128, sizeof(string128), "05*** News: You can now spawn Hydras");
//	IRC_GroupSay(groupID, IRC_CHANNEL, string128);
	#endif

//  End server status debug information collecting
	return 1;
}



forward OneSecond();
public OneSecond()
{
	new Float:x,Float:y,Float:z;
	new Float:distance,value;
	new weap;
	foreach(Player,i)
	{
        if(!IsPlayerNPC(i))
        {
			GetPlayerPos(i,playerx,playery,playerz);
			
		    if(pstate[i] == PLAYER_STATE_DRIVER || pstate[i] == PLAYER_STATE_PASSENGER || pstate[i] == PLAYER_STATE_ONFOOT || pstate[i] == PLAYER_STATE_SPAWNED)
		    {

				if(pstate[i] == PLAYER_STATE_DRIVER || pstate[i] == PLAYER_STATE_PASSENGER)
				{
					x = playerx, y = playery, z = playerz;
					distance = floatsqroot(floatpower(floatabs(floatsub(x,SavePlayerPos[i][LastX])),2)+floatpower(floatabs(floatsub(y,SavePlayerPos[i][LastY])),2)+floatpower(floatabs(floatsub(z,SavePlayerPos[i][LastZ])),2));
					value = floatround(distance * 5000);
					mph = floatround(value/1600);
					kph = floatround(value/1000);
					if(mph > 5000) format(string64,sizeof(string64),"~w~OMFG ~r~MpH ~w~ROFL ~b~KpH");
					else format(string64,sizeof(string64),"~w~%d~r~MpH ~w~%d~b~KpH",mph,kph);
			        PlayerTextDrawSetString(i,Speedo[i],string64);
			        /*
			        if(RaceParticipant[i] >= 4 && mph > 350)
			        {
			            new veh = GetPlayerVehicleID(i);
			            SetVehicleHealth(veh,0);
			            CreateExplosion(x,y,z,6,10);
			            GameTextForPlayer(i,"~n~~n~~r~NO CHEATING DURING RACES",5000,3);
			        }
			        */
		        }
		        else
		        {
		            format(string64,sizeof(string64),"~w~--~r~MpH ~w~--~b~KpH",floatround(value/1600),floatround(value/1000));
			        PlayerTextDrawSetString(i,Speedo[i],string64);
		        }
				SavePlayerPos[i][LastX] = x;
				SavePlayerPos[i][LastY] = y;
				SavePlayerPos[i][LastZ] = z;

			}
		    if(IsPlayerInSafeZone(i))
		    {
		        weap = GetPlayerWeapon(i);
		        if(!IsPlayerAdmin(i))
		        {
			        switch(weap)
			        {
				   		case 16,18,35,36,37,38,39:
				   		{
				   		    GivePlayerWeapon(i,14,1); //flowers
				   		    SetPlayerArmedWeapon(i,14);
				   		    GameTextForPlayer(i,"~n~~r~THAT WEAPON NOT ALLOWED~n~~r~IN SAFE ZONE",3000,3);
						}
			        }
		        }
				switch(pmodelid[i])
				{
				    case 425,432,447,520,464:
				    {
				        GameTextForPlayer(i,"~r~VEHICLE NOT ALLOWED~n~IN SAFE ZONE",4000,3);
				        SetVehicleHealth(pvehicleid[i],0.0);
						GetPlayerPos(i,playerx,playery,playerz);
						CreateExplosion(playerx,playery,playerz,7,20); //huge, red afterglow
						return 1;
				    }
				}
		    }
	  		SetPlayerScore(i,kills[i]);
  			format(string128,sizeof(string128),"~w~Kills:~y~%i ~w~Wins:~y~%i ~w~Group:~y~- ~w~Played:~r~%i~y~mins",kills[i],race1st[i],minutesplayed[i]);
    		PlayerTextDrawSetString(i,Stats[i],string128);
	  		pmoney[i] = GetPlayerMoney(i);
		    GetPlayerName(i,pname[i],24);
		    if(godmode[i])
			{
			 	if(pstate[i] == PLAYER_STATE_DRIVER && !gTeam[i] && !badcar[i])
				{
					RepairVehicle(pvehicleid[i]);
				 	SetVehicleHealth(pvehicleid[i],9999.00);
				}
			}
		}
	}
	return 1;
}


forward FiveSeconds();
public FiveSeconds()
{
	// WAS UNDER !IsPlayerNPOC
	new area; // gang zone
    new Float:armour, Float:health;
    //nuke script
	new Float:fltTargetHP;
	// END WAS-UNDER
	foreach(Player,i)
	{
	    if(!IsPlayerNPC(i))
        {
			GetPlayerHealth(i,health);
			fltTargetHP = health - 2;
			if(blnPlayerRadioactive[i] == true) SetPlayerHealth(i, fltTargetHP);
			GetPlayerArmour(i,armour);
			if(health > 105 || armour > 105)
			{
				format(string128,sizeof(string128),"[hack][killspam] Kicked [%i]%s for possible health hacks!",i,pname[i]);
	            SendClientMessageToAll(COLOR_YELLOW,string128);
	            printf(string128);
                #if defined IRC_ECHO
                IRC_GroupSay(groupID, IRC_CHANNEL, string128);
                #endif
				Kick(i);
				continue;
			
			}
		    if(pmodelid[i] == 416 && health < 95) SetPlayerHealth(i,health+5);
			if(gTeam[i] >= 50 && gTeam[i] < 60)
			{
			    GangZoneStopFlashForPlayer(i,zoneFamily);
			    GangZoneStopFlashForPlayer(i,zoneBalla);
			    GangZoneStopFlashForPlayer(i,zoneVagos);
			    GangZoneStopFlashForPlayer(i,zoneAzteca);
				area = GetPlayerGangArea(i);
				if(area && area != gTeam[i])
				{
					foreach(Player,j)
					{
						if((gTeam[j] >= 50 && gTeam[j] < 60))
						{
						    switch(area)
						    {
								case 50: GangZoneFlashForPlayer(j,zoneFamily,0);
								case 51: GangZoneFlashForPlayer(j,zoneBalla,0);
								case 52: GangZoneFlashForPlayer(j,zoneVagos,0);
								case 53: GangZoneFlashForPlayer(j,zoneAzteca,0);
						    }
						}
					}
				}
				return 1;
			}
		}
	}
	return 1;
}

forward GetPlayerGangArea(playerid);
public GetPlayerGangArea(playerid)
{
	if(gTeam[playerid] >= 50 && gTeam[playerid] < 60)
	{
		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
		if (x <= 2611.702 && x >= 2303.672 && y <= -1196.29 && y >= -1745.026) return 50; //family
		else if (x <= 2113.53 && x >= 1816.909 && y <=  -1460.788 && y >=  -1756.869) return 51; //balla
		else if (x <=  2942.549 && x >= 2634.519 && y <= -1026.537 && y >= -1843.719) return 52; //vagos
		else if (x <=  2159.164 && x >= 1699.021 && y <= -1820.033 && y >=  -2163.486) return 53; //azteca
		else return 0;
	}
	else return 0;
}
forward IsPlayerInSafeZone(playerid);
public IsPlayerInSafeZone(playerid)
{
	if(!gTeam[playerid])
	{
		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
		if ((x <= 2242.152 && x >= 1319.6 && y <=  -2125.373 && y >=  -2732.623) || //LS
		(x <= -2078.662 && x >= -2534.099 && y <=   -1424.701 && y >=  -1821.749) || //chiliad
		(x <=  1775.037 && x >= 1261.211 && y <= 1868.46 && y >= 1144.432) || //lv
//		(x <=   -1448.325 && x >= -1738.026 && y <= -707.7765 && y >= 85.16138) || //sf 3124
		(x <=   490.4708 && x >= -163.490 && y <= 2650.878 && y >=  2347.253)) //aa
		{
			safe[playerid] = 1;
			return 1; 
		}
	}
    safe[playerid] = 0;
	return 0;
}
   
#if defined NEON
forward DestroyNeon(playerid);
public DestroyNeon(playerid)
{
	DestroyObject(GetPVarInt(playerid, "neon"));
	DestroyObject(GetPVarInt(playerid, "neon1"));
	DestroyObject(GetPVarInt(playerid, "neon2"));
	DestroyObject(GetPVarInt(playerid, "neon3"));
	DestroyObject(GetPVarInt(playerid, "neon4"));
	DestroyObject(GetPVarInt(playerid, "neon5"));
	DestroyObject(GetPVarInt(playerid, "neon6"));
	DestroyObject(GetPVarInt(playerid, "neon7"));
	DestroyObject(GetPVarInt(playerid, "neon8"));
	DestroyObject(GetPVarInt(playerid, "neon9")); 
	DestroyObject(GetPVarInt(playerid, "neon10"));
	DestroyObject(GetPVarInt(playerid, "neon11"));
	DestroyObject(GetPVarInt(playerid, "neon12"));
	DestroyObject(GetPVarInt(playerid, "neon13"));
	DestroyObject(GetPVarInt(playerid, "neon14"));
	DestroyObject(GetPVarInt(playerid, "neon15"));
	DestroyObject(GetPVarInt(playerid, "neon16"));
	DestroyObject(GetPVarInt(playerid, "neon17"));
	DestroyObject(GetPVarInt(playerid, "neon18"));
	DestroyObject(GetPVarInt(playerid, "neon19"));
	DestroyObject(GetPVarInt(playerid, "neon20"));
	DestroyObject(GetPVarInt(playerid, "neon21"));
	DestroyObject(GetPVarInt(playerid, "neon22"));
	DestroyObject(GetPVarInt(playerid, "neon23"));
	DestroyObject(GetPVarInt(playerid, "neon24"));
	DestroyObject(GetPVarInt(playerid, "neon25")); 
	DestroyObject(GetPVarInt(playerid, "neon26"));
	DestroyObject(GetPVarInt(playerid, "neon27"));
	DestroyObject(GetPVarInt(playerid, "neon28"));
	DestroyObject(GetPVarInt(playerid, "neon29"));
	DestroyObject(GetPVarInt(playerid, "neon30")); 
	DestroyObject(GetPVarInt(playerid, "neon31"));
	DestroyObject(GetPVarInt(playerid, "neon32"));
	DestroyObject(GetPVarInt(playerid, "neon33"));
	DestroyObject(GetPVarInt(playerid, "neon34"));
	DestroyObject(GetPVarInt(playerid, "neon35"));
	DeletePVar(playerid, "Status");
	DeletePVar(playerid, "neon");
	DeletePVar(playerid, "neon1");
	DeletePVar(playerid, "neon2");
	DeletePVar(playerid, "neon3");
	DeletePVar(playerid, "neon4");
	DeletePVar(playerid, "neon5");
	DeletePVar(playerid, "neon6");
	DeletePVar(playerid, "neon7");
	DeletePVar(playerid, "neon8");
	DeletePVar(playerid, "neon9");
	DeletePVar(playerid, "neon10");
	DeletePVar(playerid, "neon11");
	DeletePVar(playerid, "neon12");
	DeletePVar(playerid, "neon13");
	DeletePVar(playerid, "neon14");
	DeletePVar(playerid, "neon15");
	DeletePVar(playerid, "neon16");
	DeletePVar(playerid, "neon17");
	DeletePVar(playerid, "neon18");
	DeletePVar(playerid, "neon19");
	DeletePVar(playerid, "neon20");
	DeletePVar(playerid, "neon21");
	DeletePVar(playerid, "neon22");
	DeletePVar(playerid, "neon23");
	DeletePVar(playerid, "neon24");
	DeletePVar(playerid, "neon25");
	DeletePVar(playerid, "neon26");
	DeletePVar(playerid, "neon27");
	DeletePVar(playerid, "neon28");
	DeletePVar(playerid, "neon29");
	DeletePVar(playerid, "neon30");
	DeletePVar(playerid, "neon31");
	DeletePVar(playerid, "neon32");
	DeletePVar(playerid, "neon33");
	DeletePVar(playerid, "neon34");
	DeletePVar(playerid, "neon35");
}
#endif


stock containsip(text[]) {

        new numbers[255] = {0, 0, ... };
        new adding_at_arr_idx = 0;

        new tstate = 0;
        new starting = -1;
        new longnums = 0;
        //new possible_port = false;
        //new good_port_candidate = -1;
        new i;
        new slen;
        slen = strlen(text);

        for (i = 0; i <= slen; i++) {

               new news = 0;
               new check_it = false;

               if (i == slen) { // last one

                       // TODO: should only do it if last char was a numeric one!

                       check_it = true;
               } else {

                       new onechar[2]; onechar[0] = text[i]; // get just 1 character
                       onechar[1] = 0;

                       if ((onechar[0] == '0') || (strval(onechar[0]) > 0)) { // is a numeric character
                               news = 1;

                               //printf("found a numeric char %s (%d) at %d", onechar, strval(onechar), i);

                               if (tstate != news) // switched into numbers
                                      starting = i;

                       } else {

                               //printf("%s - %s is not very numeric.", onechar[0]);

                               check_it = true;
                       }
               }

               if (check_it) {
                       news = 2;

                       if (tstate != news) { // hit text again

                               new numeric[255];
                               new numasnum;

                               if (starting == -1)
                                      continue; // WTF? no starting position?

                               strCopy(numeric, text[starting], i - starting + 1);

                               numasnum = strval(numeric);

                               // 1..255 or 1000..9999
                               if (((numasnum > 0) && (numasnum < 255)) || ((numasnum > 999) && (numasnum < 10000))) {
                                      numbers[adding_at_arr_idx] = numasnum;
                                      adding_at_arr_idx++;

                                      if (numasnum > 9) // see how many are 2 or more chars so we filter out shitty leetspeak
                                              longnums++;

                               }
                       }

               }

               tstate = news;
        }

        if ((longnums < 2) || (adding_at_arr_idx < 4)) // need at least 4 parts.
               return false;

        return true;
}


stock iswheelmodel(modelid)
{

    new wheelmodels[17] = {1025,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1096,1097,1098};
    for(new i; i < sizeof(wheelmodels); i++)
	{
        if (modelid == wheelmodels[i]) return true;
    }
    return false;
}

stock IllegalCarNitroIde(carmodel)
{

    new illegalvehs[29] = { 581, 523, 462, 521, 463, 522, 461, 448, 468, 586, 509, 481, 510, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454, 590, 569, 537, 538, 570, 449 };
    for(new i; i < sizeof(illegalvehs); i++)
	{
        if (carmodel == illegalvehs[i]) return true;
    }
    return false;
}

// assumes player is in a car - make sure it is.
stock illegal_nos_vehicle(PlayerID)
{
    new carid = GetPlayerVehicleID(PlayerID);
    new playercarmodel = GetVehicleModel(carid);
    return IllegalCarNitroIde(playercarmodel);
}

stock islegalcarmod(vehicleide, componentid) {

    new modok = false;

    // stereo, hydraulics & nos (1x 2x 3x) are special.
    if ( (iswheelmodel(componentid)) || (componentid == 1086) || (componentid == 1087) || ((componentid >= 1008) && (componentid <= 1010))) {

        new nosblocker = IllegalCarNitroIde(vehicleide);

        if (!nosblocker)
            modok = true;

    } else {

        // check if the specified model CAN use this particular mod.
		for(new i; i < sizeof(legalmods); i++)
		{
			if (legalmods[i][0] == vehicleide)
		   	{ // first is car IDE
	           	for(new J = 1; J < 22; J++)
			   	{ // start with 1
                    if (legalmods[i][J] == componentid)
                        modok = true;
				}
            }
        }
    }
    return modok;
}

forward HideVehTD(playerid);
public HideVehTD(playerid)
{
#if defined TEXTDRAWS
    TextDrawHideForPlayer(playerid,Veh);
    TextDrawHideForPlayer(playerid,VehAutoFlip);
    TextDrawHideForPlayer(playerid,VehPutRamp);
    TextDrawHideForPlayer(playerid,VehPutSkulls);
    TextDrawHideForPlayer(playerid,VehAutoStop);
#endif //td
	return 1;
}

forward PCountDown(playerid);
public PCountDown(playerid)
{
	static intCount = 3; // Start counting down from 3
	new strCountMessage[64];
	new strCountMessageHUD[32];

    format(strCountMessage, sizeof(strCountMessage), "Player race starts in: %i seconds", intCount);
    format(strCountMessageHUD, sizeof(strCountMessageHUD), "~r~Race in: ~y~%i", intCount);
	new Float:x, Float:y, Float:z;
	if(intCount != 0)
 	{
		GetPlayerPos(playerid,x,y,z);
		foreach(Player,i)
		{
		    if(IsPlayerInRangeOfPoint(i,7,x,y,z) && pvehicleid[i])
		    {
		    	SendClientMessage(playerid, 0x77CC77FF, strCountMessage);
				GameTextForPlayer(playerid, strCountMessageHUD, 1000, 6);
				PlayerPlaySound(playerid, 1058, 0, 0, 0); // beep
		    }
		}

		intCount--; //Subtracts the variable by one every time this function is called
	}
	else // Zero is reached
	{
	    //Messages are for players in prox! Implement your proximity function here please
	    GetPlayerPos(playerid,x,y,z);
		foreach(Player,i)
		{
		    if(IsPlayerInRangeOfPoint(i,10,x,y,z) && IsPlayerInAnyVehicle(i))
		    {
		    	SendClientMessage(playerid, 0x77CC77FF, "Go go go!");
				GameTextForPlayer(playerid, "~g~GO! GO! GO!", 1500, 6);
				PlayerPlaySound(playerid, 1147, 0, 0, 0); // Car horn
		    }
		}
		KillTimer(tmrCountDown); //Stops the timer
		gblnCanCount[playerid] = true; // Countdown has stopped. Can count again.
		intCount = 3; // Reset the count variable
	}
}

forward GodTimer(playerid);
public GodTimer(playerid)
{
	cantgod[playerid] = 0;
	KillTimer(godtimer[playerid]);
	return 1;
}

forward HideGodTD(playerid);
public HideGodTD(playerid)
{
#if defined TEXTDRAWS
	TextDrawHideForPlayer(playerid,God);
	TextDrawHideForPlayer(playerid,NoGod);
	TextDrawHideForPlayer(playerid,Leave);
#endif //td
	return 1;
}

forward ShowSnosTD(playerid);
public ShowSnosTD(playerid)
{
	TextDrawHideForPlayer(playerid,SnosOn);
	TextDrawHideForPlayer(playerid,SnosOff);
	if(hassnos[playerid]) TextDrawShowForPlayer(playerid,SnosOn);
	else TextDrawShowForPlayer(playerid,SnosOff);
	return 1;
}

forward ShowJumpTD(playerid);
public ShowJumpTD(playerid)
{
	TextDrawHideForPlayer(playerid,JumpOn);
	TextDrawHideForPlayer(playerid,JumpOff);
	if(jump[playerid]) TextDrawShowForPlayer(playerid,JumpOn);
	else TextDrawShowForPlayer(playerid,JumpOff);
	return 1;
}
forward ShowRadioTD(playerid);
public ShowRadioTD(playerid)
{
	TextDrawHideForPlayer(playerid,RadioOn);
	TextDrawHideForPlayer(playerid,RadioOff);
	if(radio[playerid]) TextDrawShowForPlayer(playerid,RadioOn);
	else TextDrawShowForPlayer(playerid,RadioOff);
	return 1;
}



forward ShowGodTD(playerid);
public ShowGodTD(playerid)
{
	HideGodTD(playerid);
	switch(godmode[playerid])
	{
	    case 0:
		{
			if(!gTeam[playerid])
			{
				TextDrawShowForPlayer(playerid,NoGod);
//				GameTextForPlayer(playerid,"~w~GOD-MODE IS ~r~OFF~w~!",2000,3);
			}
			else
			{
				TextDrawShowForPlayer(playerid,Leave);
				TextDrawShowForPlayer(playerid,NoGod);
//				GameTextForPlayer(playerid,"~w~GOD-MODE IS ~r~OFF~w~!",2000,3);
			}
		}
	    case 1:
		{
			TextDrawShowForPlayer(playerid,God);
//			GameTextForPlayer(playerid,"~w~GOD-MODE IS ~r~ON~w~!",2000,3);
		}
    }
	return 1;
}

#if !defined USE_XADMIN
stock strtok(const string[], &index)
{
	new length = strlen(string128);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
#endif
//------------------------------------------------

stock strrest(const string[], &index)
{
	new length = strlen(string128);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}
	new offset = index;
	new result[128];
	while ((index < length) && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}



stock CheckPlayerRemoteJacking( playerid )
{
    new iVehicle = GetPlayerVehicleID( playerid );
	if(iVehicle == playercar[playerid]) return 1;
    if( !IsPlayerInAnyVehicle( playerid ) )
        GetPlayerPos( playerid, g_carjackData[ playerid ] [ E_LAST_X ], g_carjackData[ playerid ] [ E_LAST_Y ], g_carjackData[ playerid ] [ E_LAST_Z ] );

    if( ( iVehicle != g_carjackData[ playerid ] [ E_LAST_VEH ] ) && ( iVehicle != 0 ) && ( GetPlayerState( playerid ) == PLAYER_STATE_DRIVER ) )
    {
        new
            Float: fDistance = GetVehicleDistanceFromPoint( iVehicle, g_carjackData[ playerid ] [ E_LAST_X ], g_carjackData[ playerid ] [ E_LAST_Y ], g_carjackData[ playerid ] [ E_LAST_Z ] ),
            Float: fOffset = 15.0
        ;

        if( ( GetVehicleModel( iVehicle ) == 577 ) || ( GetVehicleModel( iVehicle ) == 592 )) fOffset = 25.0; // Andromanda | AT-400

        if( fDistance > fOffset) {

            /*
                INSERT WHAT YOU WANT TO DO TO A CAR JACKER HERE!

                WARNING: THIS IS NOT ACCURATE IMHO!
            */
			carjack[playerid]++;
			if(carjack[playerid] == 4)
			{
	            format(string128,sizeof(string128),"[hack][carjack] Kicked [%i]%s for remote car jacking!!",playerid,pname[playerid]);
	            SendClientMessageToAll(COLOR_YELLOW,string128);
                IRC_GroupSay(groupID, IRC_CHANNEL, string128);
	            SendClientMessage(playerid,COLOR_YELLOW,"If you received this kick in error, please report it on madoshi.net/samp ");
	            printf(string128);
	            return Kick(playerid);
            }
        }

        GetPlayerPos( playerid, g_carjackData[ playerid ] [ E_LAST_X ], g_carjackData[ playerid ] [ E_LAST_Y ], g_carjackData[ playerid ] [ E_LAST_Z ] );
        g_carjackData[ playerid ] [ E_LAST_VEH ] = iVehicle;
    }
    return 1;
}

/*
forward IsValidSound(soundid);
public IsValidSound(soundid)
{
	for(new i; i < sizeof(ValidSounds); i++)
	{
	    if(soundid == i) return 1;
	}
	return 0;
}

*/
/*
forward PingKick();
public PingKick() {
	if(Config[MaxPing]) {
	    for(new i = 0,name[24]; i < MAX_PLAYERS; i++)
	    if(IsPlayerConnected(i) && (GetPlayerPing(i) > Config[MaxPing])) {
	        if(!IsPlayerXAdmin(i) || (IsPlayerXAdmin(i) && !Config[AdminImmunity])) {
	        	GetPlayerName(i,name,24); format(string128,sizeof(string128),"\"%s\" has been kicked from the server. (Reason: High Ping || Max Allowed: %d)",name,Config[MaxPing]);
	        	printf(string128); SendClientMessageToAll(yellow,string128); Kick(i);
	        }
	    }
	}
}

*/

// --------             IRC FS       ----------------
#if defined IRC_ECHO
public IRC_OnConnect(botid, ip[], port)
{
	printf("*** IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);
	// Join the channel
	IRC_JoinChannel(botid, IRC_CHANNEL);
	// Add the bot to the group
	IRC_AddToGroup(groupID, botid);
	return 1;
}

/*
	This callback is executed whenever a current connection is closed. The
	plugin may automatically attempt to reconnect per user settings. IRC_Quit
	may be called at any time to stop the reconnection process.
*/

public IRC_OnDisconnect(botid, ip[], port, reason[])
{
	printf("*** IRC_OnDisconnect: Bot ID %d disconnected from %s:%d (%s)", botid, ip, port, reason);
	// Remove the bot from the group
	IRC_RemoveFromGroup(groupID, botid);
	return 1;
}

/*
	This callback is executed whenever a connection attempt begins. IRC_Quit may
	be called at any time to stop the reconnection process.
*/

public IRC_OnConnectAttempt(botid, ip[], port)
{
	printf("*** IRC_OnConnectAttempt: Bot ID %d attempting to connect to %s:%d...", botid, ip, port);
	return 1;
}

/*
	This callback is executed whenever a connection attempt fails. IRC_Quit may
	be called at any time to stop the reconnection process.
*/

public IRC_OnConnectAttemptFail(botid, ip[], port, reason[])
{
	printf("*** IRC_OnConnectAttemptFail: Bot ID %d failed to connect to %s:%d (%s)", botid, ip, port, reason);
	return 1;
}

/*
	This callback is executed whenever a bot joins a channel.
*/

public IRC_OnJoinChannel(botid, channel[])
{
//	printf("*** IRC_OnJoinChannel: Bot ID %d joined channel %s", botid, channel);
	return 1;
}

/*
	This callback is executed whenevever a bot leaves a channel.
*/

public IRC_OnLeaveChannel(botid, channel[], message[])
{
//	printf("*** IRC_OnLeaveChannel: Bot ID %d left channel %s (%s)", botid, channel, message);
	return 1;
}

/*
	This callback is executed whenevever a bot is invited to a channel.
*/

public IRC_OnInvitedToChannel(botid, channel[], invitinguser[], invitinghost[])
{
//	printf("*** IRC_OnInvitedToChannel: Bot ID %d invited to channel %s by %s (%s)", botid, channel, invitinguser, invitinghost);
	IRC_JoinChannel(botid, channel);
	return 1;
}

/*
	This callback is executed whenevever a bot is kicked from a channel. If the
	bot cannot immediately rejoin the channel (in the event, for example, that
	the bot is kicked and then banned), you might want to set up a timer here
	for rejoin attempts.
*/

public IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnKickedFromChannel: Bot ID %d kicked by %s (%s) from channel %s (%s)", botid, oppeduser, oppedhost, channel, message);
	IRC_JoinChannel(botid, channel);
	return 1;
}

public IRC_OnUserDisconnect(botid, user[], host[], message[])
{
//	printf("*** IRC_OnUserDisconnect (Bot ID %d): User %s (%s) disconnected (%s)", botid, user, host, message);
	return 1;
}

public IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
//	printf("*** IRC_OnUserJoinChannel (Bot ID %d): User %s (%s) joined channel %s", botid, user, host, channel);
	return 1;
}

public IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[])
{
//	printf("*** IRC_OnUserLeaveChannel (Bot ID %d): User %s (%s) left channel %s (%s)", botid, user, host, channel, message);
	return 1;
}

public IRC_OnUserKickedFromChannel(botid, channel[], kickeduser[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnUserKickedFromChannel (Bot ID %d): User %s kicked by %s (%s) from channel %s (%s)", botid, kickeduser, oppeduser, oppedhost, channel, message);
}

public IRC_OnUserNickChange(botid, oldnick[], newnick[], host[])
{
//	printf("*** IRC_OnUserNickChange (Bot ID %d): User %s (%s) changed his/her nick to %s", botid, oldnick, host, newnick);
	return 1;
}

public IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[])
{
//	printf("*** IRC_OnUserSetChannelMode (Bot ID %d): User %s (%s) on %s set mode: %s", botid, user, host, channel, mode);
	return 1;
}

public IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[])
{
//	printf("*** IRC_OnUserSetChannelTopic (Bot ID %d): User %s (%s) on %s set topic: %s", botid, user, host, channel, topic);
	return 1;
}

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
//	printf("*** IRC_OnUserSay (Bot ID %d): User %s (%s) sent message to %s: %s", botid, user, host, recipient, message);
	// Someone sent the first bot a private message
	if (!strcmp(recipient, BOT_1_NICKNAME))
	{
		IRC_Say(botid, user, "You sent me a PM!");
	}
	return 1;
}

public IRC_OnUserNotice(botid, recipient[], user[], host[], message[])
{
//	printf("*** IRC_OnUserNotice (Bot ID %d): User %s (%s) sent notice to %s: %s", botid, user, host, recipient, message);
	// Someone sent the second bot a notice (probably a network service)
	if (!strcmp(recipient, BOT_2_NICKNAME))
	{
		IRC_Notice(botid, user, "You sent me a notice!");
	}
	return 1;
}

public IRC_OnUserRequestCTCP(botid, user[], host[], message[])
{
//	printf("*** IRC_OnUserRequestCTCP (Bot ID %d): User %s (%s) sent CTCP request: %s", botid, user, host, message);
	// Someone sent a CTCP VERSION request
	if (!strcmp(message, "VERSION"))
	{
		IRC_ReplyCTCP(botid, user, "VERSION SA-MP IRC Plugin v" #PLUGIN_VERSION "");
	}
	return 1;
}

public IRC_OnUserReplyCTCP(botid, user[], host[], message[])
{
//	printf("*** IRC_OnUserReplyCTCP (Bot ID %d): User %s (%s) sent CTCP reply: %s", botid, user, host, message);
	return 1;
}

/*
	This callback is useful for logging, debugging, or catching error messages
	sent by the IRC server.
*/

public IRC_OnReceiveRaw(botid, message[])
{
	new File:file;
	if (!fexist("irc_log.txt"))
	{
		file = fopen("irc_log.txt", io_write);
	}
	else
	{
		file = fopen("irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}

/*
	Some examples of channel commands are here. You can add more very easily;
	their implementation is identical to that of ZeeX's zcmd.
*/

IRCCMD:isay(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsVoice(botid, channel, user))
	{
		// Check if the user entered any text
		if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			format(msg, sizeof(msg), "{FFFFFF}***{7CFC00}[IRC] - %s:{FFFFFF} %s", user, params);
			SendClientMessageToAll(COLOR_BRIGHTGREEN, msg);
		}
	}
	return 1;
}
IRCCMD:idebug(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
		new players,cars,i;
		players = Iter_Count(Player);
		for(i = 0; i < MAX_VEHICLES; i++)
		{
		    new modelid = GetVehicleModel(i);
			if(modelid >= MIN_VEHI_ID && modelid <= MAX_VEHI_ID) cars++;
		}
		format(string128,sizeof(string128),"Players:_%i Cars:_%i",players,cars);
		new msg[128];
		// Echo the formatted message
		format(msg, sizeof(msg), "05*** [DEBUG] %s", string128);
		IRC_GroupSay(groupID, channel, msg);

	}
	return 1;
}
IRCCMD:inuke(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsOp(botid, channel, user))
	{
	    new msg[128];
		format(msg, sizeof(msg), "05*** LSA Nuke Initisted!", string128);
		IRC_GroupSay(groupID, channel, msg);
		if(blnNukeActive == true)
		{
		    format(msg, sizeof(msg), "05*** Server Nuke Canceled! Nuke already in progress!", string128);
			IRC_GroupSay(groupID, channel, msg);
			return 1;
		}
		foreach(Player, i)
		{
			SendClientMessage(i, 0x77CC77FF, "Tactical nuke incoming!");
			PlayAudioStreamForPlayer(i, "http://65.111.172.126/Madoshi/NukeCountdown.mp3"); //Enable audiomsgoff in config
		}
		NukeObject = CreateObject(1636, 1899.6129,-2240.0889,43.5469, 0.0, 0.0, 0.0);
		tmrNuke = SetTimer("NukeCountdown", 1000, true);
		blnNukeActive = true;

	}
	return 1;
}
IRCCMD:isun(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
	    foreach(Player,i)
	    {
	        SetPlayerWeather(i,10);
	    }

	}
	return 1;
}
IRCCMD:iday(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
	    foreach(Player,i)
	    {
	        SetPlayerTime(i,12,0);
	    }

	}
	return 1;
}
IRCCMD:inight(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
	    foreach(Player,i)
	    {
	        SetPlayerTime(i,23,0);
	    }

	}
	return 1;
}
IRCCMD:irain(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
	    foreach(Player,i)
	    {
	        SetPlayerWeather(i,8);
	    }

	}
	return 1;
}
IRCCMD:iwhoson(botid, channel[], user[], host[], params[])
{
	if (IRC_IsHalfop(botid, channel, user))
	{
		new players;
		new pip[16];
		players = Iter_Count(Player);
		foreach(Player,i)
		{
			GetPlayerIp(i, pip, sizeof(pip));
		    format(string128, sizeof(string128), "[%i]%s - %s",i,pname[i],pip);
		    IRC_GroupSay(groupID, channel, string128);
		}
		format(string32, sizeof(string32), "Total Players: %i", players);
  		IRC_GroupSay(groupID, channel, string32);
	}
	else if (IRC_IsVoice(botid, channel, user))
	{
		new players;
		players = Iter_Count(Player);
		foreach(Player,i)
		{
		    format(string64, sizeof(string64), "[%i]%s", i,pname[i]);
		    IRC_GroupSay(groupID, channel, string64);
		}
		format(string32, sizeof(string32), "Total Players: %i", players);
  		IRC_GroupSay(groupID, channel, string32);
	}
	return 1;
}
IRCCMD:istats(botid, channel[], user[], host[], params[])
{
	if (IRC_IsHalfop(botid, channel, user))
	{
		new playerid;
    	if (sscanf(params, "d", playerid))
		{
			return 1;
		}
		if (IsPlayerConnected(playerid))
		{
		    new weap;
		    new Float:health, Float:armor;
		    new slot[13];
		    new ammo[13];
		    
		    GetPlayerHealth(playerid,health);
		    GetPlayerArmour(playerid,armor);
		    weap = GetPlayerWeapon(playerid);
		    new money = GetPlayerMoney(playerid);
			new ip[16];
			GetPlayerIp(playerid, ip, sizeof(ip));
//		    format(string128,sizeof(string128),"[%i]%s Health:%0.1f Armor:%0.1f Weapon:%s",playerid,pname[playerid],health,armor,aWeaponNames[weap]);
            format(string256,sizeof(string256),"[%i]%s stats: Weap:%s Score:%i RaceWins:%i Money:%i Health%.0f Armor:%.0f DM:%i",playerid,pname[playerid],aWeaponNames[weap],kills[playerid],race1st[playerid],money,health,armor,gTeam[playerid]);
			IRC_GroupSay(groupID, channel, string256);
			for(new i; i < 13; i++)
			{
			    GetPlayerWeaponData(playerid,i,slot[i],ammo[i]);
			    if(!slot[i]) slot[i] = 19; //19 is blank in aWeaponNames
			    if(ammo[i] < 0) ammo[i] = 999;
			}
			format(string128,sizeof(string128),"(0):%s:%i (1):%s:%i (2):%s:%i (3):%s:%i (4):%s:%i (5):%s:%i (6):%s:%i ",aWeaponNames[slot[0]],ammo[0],aWeaponNames[slot[1]],ammo[1],aWeaponNames[slot[2]],ammo[2],aWeaponNames[slot[3]],ammo[3],aWeaponNames[slot[4]],ammo[4],aWeaponNames[slot[5]],ammo[5],aWeaponNames[slot[6]],ammo[6]);
			IRC_GroupSay(groupID, channel, string128);
			format(string128,sizeof(string128),"(7):%s:%i (8):%s:%i (9):%s:%i (10):%s:%i (11):%s:%i (12):%s:%i",aWeaponNames[slot[7]],ammo[7],aWeaponNames[slot[8]],ammo[8],aWeaponNames[slot[9]],ammo[9],aWeaponNames[slot[10]],ammo[10],aWeaponNames[slot[11]],ammo[11],aWeaponNames[slot[12]],ammo[12]);
	        IRC_GroupSay(groupID, channel, string128);
	        format(string128,sizeof(string128),"IP: %s", ip);
	        IRC_GroupSay(groupID, channel, string128);
			
		    
		}
	}
	return 1;
}
IRCCMD:idump(botid, channel[], user[], host[], params[])
{
	if (IRC_IsOp(botid, channel, user))
	{
		new playerid;
    	if (sscanf(params, "d", playerid))
		{
			return 1;
		}
		if (IsPlayerConnected(playerid))
		{
		    GetPlayerPos(playerid,playerx,playery,playerz);
			for(new i; i < 10; i++)
			{
			    DestroyVehicle(dumper[i]);
			    dumper[i] = CreateVehicle(406,playerx,playery,playerz+15,0.0,-1,-1,300);
			}
			dumptimer = SetTimer("DumpTimer",15000,0);
	        IRC_GroupSay(groupID, channel, "Makin it RAAIINN BIITTTCH");


		}
	}
	return 1;
}

forward DumpTimer();
public DumpTimer()
{
	KillTimer(dumptimer);
	for(new i; i < 10; i++)
	{
	    DestroyVehicle(dumper[i]);
	}
	return 1;
}
IRCCMD:icmd(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsVoice(botid, channel, user))
	{
		format(string128, sizeof(string128), "05*** [IRC CMDS] !isay,!ikick,!iban,!idebug, !iwhoson, !istats, !isun, !irain, !inuke");
		IRC_GroupSay(groupID, channel, string128);

	}
	return 1;
}
IRCCMD:ikick(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least a halfop in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
		new playerid, reason[64];
		// Check if the user at least entered a player ID
		if (sscanf(params, "dS(No reason)[64]", playerid, reason))
		{
			return 1;
		}
		// Check if the player is connected
		if (IsPlayerConnected(playerid))
		{
			// Echo the formatted message
			format(string128, sizeof(string128), "02*** %s has been kicked by %s on IRC. (%s)", pname[playerid], user, reason);
			IRC_GroupSay(groupID, channel, string128);
			format(string128, sizeof(string128), "*** %s has been kicked by %s on IRC. (%s)", pname[playerid], user, reason);
			SendClientMessageToAll(0x0000FFFF, string128);
			// Kick the player
			Kick(playerid);
		}
	}
	return 1;
}
IRCCMD:imute(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least a halfop in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
		new playerid, reason[64];
		// Check if the user at least entered a player ID
		if (sscanf(params, "dS(No reason)[64]", playerid, reason))
		{
			return 1;
		}
		// Check if the player is connected
		if (IsPlayerConnected(playerid))
		{
			// Echo the formatted message
			format(string128, sizeof(string128), "02*** %s has been muted by %s on IRC. (%s)", pname[playerid], user, reason);
			IRC_GroupSay(groupID, channel, string128);
			format(string128, sizeof(string128), "*** %s has been muted by %s on IRC. (%s)", pname[playerid], user, reason);
			SendClientMessageToAll(0x0000FFFF, string128);
			// Kick the player
			Variables[playerid][Wired] = true, Variables[playerid][WiredWarnings] = Config[WiredWarnings];
		}
	}
	return 1;
}
IRCCMD:iunmute(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least a halfop in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
		new playerid;
		// Check if the user at least entered a player ID
		if (sscanf(params, "d", playerid))
		{
			return 1;
		}
		// Check if the player is connected
		if (IsPlayerConnected(playerid))
		{
			// Echo the formatted message
			format(string128, sizeof(string128), "02*** %s has been unmuted by %s on IRC.", pname[playerid], user);
			IRC_GroupSay(groupID, channel, string128);
			format(string128, sizeof(string128), "*** %s has been unmuted by %s on IRC.", pname[playerid], user);
			SendClientMessageToAll(0x0000FFFF, string128);
			Variables[playerid][Wired] = false, Variables[playerid][WiredWarnings] = Config[WiredWarnings];
		}
 }
	return 1;
}
IRCCMD:iban(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least an op in the channel
	if (IRC_IsOp(botid, channel, user))
	{
		new playerid, reason[64];
		// Check if the user at least entered a player ID
		if (sscanf(params, "dS(No reason)[64]", playerid, reason))
		{
			return 1;
		}
		// Check if the player is connected
		if (IsPlayerConnected(playerid))
		{
			// Echo the formatted message
			format(string128, sizeof(string128), "02*** %s has been banned by %s on IRC. (%s)", pname[playerid], user, reason);
			IRC_GroupSay(groupID, channel, string128);
			format(string128, sizeof(string128), "*** %s has been banned by %s on IRC. (%s)", pname[playerid], user, reason);
			SendClientMessageToAll(0x0000FFFF, string128);
			// Ban the player
			BanEx(playerid, reason);
		}
	}
	return 1;
}
IRCCMD:ireloadbans(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least an op in the channel
	if (IRC_IsOp(botid, channel, user))SendRconCommand("reloadbans");
	return 1;
}

#endif //irc_echo
// END IRC FS

#if defined TOYS
public OnPlayerEditAttachedObject( playerid, response, index, modelid, boneid,
                                   Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,
                                   Float:fRotX, Float:fRotY, Float:fRotZ,
                                   Float:fScaleX, Float:fScaleY, Float:fScaleZ )
{
    new debug_string[256+1];
	format(debug_string,256,"SetPlayerAttachedObject(playerid,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f)",
        index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);

	print(debug_string);
    //SendClientMessage(playerid, 0xFFFFFFFF, debug_string);

    SetPlayerAttachedObject(playerid,index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);
    SendClientMessage(playerid, 0xFFFFFFFF, "You finished editing an attached object");

    return 1;
}

#endif //toys

#if defined VEH_THUMBNAILS
//------------------------------------------------

GetNumberOfPages()
{
	if((gTotalItems >= SELECTION_ITEMS) && (gTotalItems % SELECTION_ITEMS) == 0)
	{
		return (gTotalItems / SELECTION_ITEMS);
	}
	else return (gTotalItems / SELECTION_ITEMS) + 1;
}

//------------------------------------------------

PlayerText:CreateCurrentPageTextDraw(playerid, Float:Xpos, Float:Ypos)
{
	new PlayerText:txtInit;
   	txtInit = CreatePlayerTextDraw(playerid, Xpos, Ypos, "0/0");
   	PlayerTextDrawUseBox(playerid, txtInit, 0);
	PlayerTextDrawLetterSize(playerid, txtInit, 0.4, 1.1);
	PlayerTextDrawFont(playerid, txtInit, 1);
	PlayerTextDrawSetShadow(playerid, txtInit, 0);
    PlayerTextDrawSetOutline(playerid, txtInit, 1);
    PlayerTextDrawColor(playerid, txtInit, 0xACCBF1FF);
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

//------------------------------------------------
// Creates a button textdraw and returns the textdraw ID.

PlayerText:CreatePlayerDialogButton(playerid, Float:Xpos, Float:Ypos, Float:Width, Float:Height, button_text[])
{
 	new PlayerText:txtInit;
   	txtInit = CreatePlayerTextDraw(playerid, Xpos, Ypos, button_text);
   	PlayerTextDrawUseBox(playerid, txtInit, 1);
   	PlayerTextDrawBoxColor(playerid, txtInit, 0x000000FF);
   	PlayerTextDrawBackgroundColor(playerid, txtInit, 0x000000FF);
	PlayerTextDrawLetterSize(playerid, txtInit, 0.4, 1.1);
	PlayerTextDrawFont(playerid, txtInit, 1);
	PlayerTextDrawSetShadow(playerid, txtInit, 0); // no shadow
    PlayerTextDrawSetOutline(playerid, txtInit, 0);
    PlayerTextDrawColor(playerid, txtInit, 0x4A5A6BFF);
    PlayerTextDrawSetSelectable(playerid, txtInit, 1);
    PlayerTextDrawAlignment(playerid, txtInit, 2);
    PlayerTextDrawTextSize(playerid, txtInit, Height, Width); // The width and height are reversed for centering.. something the game does <g>
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

//------------------------------------------------

PlayerText:CreatePlayerHeaderTextDraw(playerid, Float:Xpos, Float:Ypos, header_text[])
{
	new PlayerText:txtInit;
   	txtInit = CreatePlayerTextDraw(playerid, Xpos, Ypos, header_text);
   	PlayerTextDrawUseBox(playerid, txtInit, 0);
	PlayerTextDrawLetterSize(playerid, txtInit, 1.25, 3.0);
	PlayerTextDrawFont(playerid, txtInit, 3);
	PlayerTextDrawSetShadow(playerid, txtInit, 0);
    PlayerTextDrawSetOutline(playerid, txtInit, 1);
    PlayerTextDrawColor(playerid, txtInit, 0xACCBF1FF);
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

//------------------------------------------------

PlayerText:CreatePlayerBackgroundTextDraw(playerid, Float:Xpos, Float:Ypos, Float:Width, Float:Height)
{
	new PlayerText:txtBackground = CreatePlayerTextDraw(playerid, Xpos, Ypos,
	"                                            ~n~"); // enough space for everyone
    PlayerTextDrawUseBox(playerid, txtBackground, 1);
    PlayerTextDrawBoxColor(playerid, txtBackground, 0x00000099);
	PlayerTextDrawLetterSize(playerid, txtBackground, 5.0, 5.0);
	PlayerTextDrawFont(playerid, txtBackground, 0);
	PlayerTextDrawSetShadow(playerid, txtBackground, 0);
    PlayerTextDrawSetOutline(playerid, txtBackground, 0);
    PlayerTextDrawColor(playerid, txtBackground,0x000000FF);
    PlayerTextDrawTextSize(playerid, txtBackground, Width, Height);
   	PlayerTextDrawBackgroundColor(playerid, txtBackground, 0x00000099);
    PlayerTextDrawShow(playerid, txtBackground);
    return txtBackground;
}

//------------------------------------------------
// Creates a model preview sprite

PlayerText:CreateModelPreviewTextDraw(playerid, modelindex, Float:Xpos, Float:Ypos, Float:width, Float:height)
{
    new PlayerText:txtPlayerSprite = CreatePlayerTextDraw(playerid, Xpos, Ypos, ""); // it has to be set with SetText later
    PlayerTextDrawFont(playerid, txtPlayerSprite, TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawColor(playerid, txtPlayerSprite, 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, txtPlayerSprite, 0x000000EE);
    PlayerTextDrawTextSize(playerid, txtPlayerSprite, width, height); // Text size is the Width:Height
    PlayerTextDrawSetPreviewModel(playerid, txtPlayerSprite, modelindex);
    PlayerTextDrawSetPreviewRot(playerid,txtPlayerSprite, -16.0, 0.0, -55.0);
    PlayerTextDrawSetSelectable(playerid, txtPlayerSprite, 1);
    PlayerTextDrawShow(playerid,txtPlayerSprite);
    return txtPlayerSprite;
}

//------------------------------------------------

DestroyPlayerModelPreviews(playerid)
{
	new x=0;
	while(x != SELECTION_ITEMS) {
	    if(gSelectionItems[playerid][x] != PlayerText:INVALID_TEXT_DRAW) {
			PlayerTextDrawDestroy(playerid, gSelectionItems[playerid][x]);
			gSelectionItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
		}
		x++;
	}
}

//------------------------------------------------

ShowPlayerModelPreviews(playerid)
{
    new x=0;
	new Float:BaseX = DIALOG_BASE_X;
	new Float:BaseY = DIALOG_BASE_Y - (SPRITE_DIM_Y * 0.33); // down a bit
	new linetracker = 0;

	new itemat = GetPVarInt(playerid, "vspawner_page") * SELECTION_ITEMS;

	// Destroy any previous ones created
	DestroyPlayerModelPreviews(playerid);

	while(x != SELECTION_ITEMS && itemat < gTotalItems) {
	    if(linetracker == 0) {
	        BaseX = DIALOG_BASE_X + 25.0; // in a bit from the box
	        BaseY += SPRITE_DIM_Y + 1.0; // move on the Y for the next line
		}
  		gSelectionItems[playerid][x] = CreateModelPreviewTextDraw(playerid, gItemList[itemat], BaseX, BaseY, SPRITE_DIM_X, SPRITE_DIM_Y);
  		gSelectionItemsTag[playerid][x] = gItemList[itemat];
		BaseX += SPRITE_DIM_X + 1.0; // move on the X for the next sprite
		linetracker++;
		if(linetracker == ITEMS_PER_LINE) linetracker = 0;
		itemat++;
		x++;
	}
}

//------------------------------------------------

UpdatePageTextDraw(playerid)
{
	new PageText[64+1];
	format(PageText, 64, "%d/%d", GetPVarInt(playerid,"vspawner_page") + 1, GetNumberOfPages());
	PlayerTextDrawSetString(playerid, gCurrentPageTextDrawId[playerid], PageText);
}

//------------------------------------------------

CreateSelectionMenu(playerid)
{
    gBackgroundTextDrawId[playerid] = CreatePlayerBackgroundTextDraw(playerid, DIALOG_BASE_X, DIALOG_BASE_Y + 20.0, DIALOG_WIDTH, DIALOG_HEIGHT);
    gHeaderTextDrawId[playerid] = CreatePlayerHeaderTextDraw(playerid, DIALOG_BASE_X, DIALOG_BASE_Y, HEADER_TEXT);
    gCurrentPageTextDrawId[playerid] = CreateCurrentPageTextDraw(playerid, DIALOG_WIDTH - 30.0, DIALOG_BASE_Y + 15.0);
    gNextButtonTextDrawId[playerid] = CreatePlayerDialogButton(playerid, DIALOG_WIDTH - 30.0, DIALOG_BASE_Y+DIALOG_HEIGHT+100.0, 50.0, 16.0, NEXT_TEXT);
    gPrevButtonTextDrawId[playerid] = CreatePlayerDialogButton(playerid, DIALOG_WIDTH - 90.0, DIALOG_BASE_Y+DIALOG_HEIGHT+100.0, 50.0, 16.0, PREV_TEXT);

    ShowPlayerModelPreviews(playerid);
    UpdatePageTextDraw(playerid);
}

//------------------------------------------------

DestroySelectionMenu(playerid)
{
	DestroyPlayerModelPreviews(playerid);

	PlayerTextDrawDestroy(playerid, gHeaderTextDrawId[playerid]);
	PlayerTextDrawDestroy(playerid, gBackgroundTextDrawId[playerid]);
	PlayerTextDrawDestroy(playerid, gCurrentPageTextDrawId[playerid]);
	PlayerTextDrawDestroy(playerid, gNextButtonTextDrawId[playerid]);
	PlayerTextDrawDestroy(playerid, gPrevButtonTextDrawId[playerid]);

	gHeaderTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gBackgroundTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gCurrentPageTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gNextButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gPrevButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
}

//------------------------------------------------

SpawnVehicle_InfrontOfPlayer(playerid, vehiclemodel, color1, color2)
{
	new Float:x,Float:y,Float:z;
	new Float:facing;
	new Float:distance;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, facing);

    new Float:size_x,Float:size_y,Float:size_z;
	GetVehicleModelInfo(vehiclemodel, VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);

	distance = size_x + 0.5;

  	x += (distance * floatsin(-facing, degrees));
    y += (distance * floatcos(-facing, degrees));

	facing += 90.0;
	if(facing > 360.0) facing -= 360.0;
	CreatePlayerVehicle(playerid,vehiclemodel);
	#pragma unused color1,color2
	return 1;
}

//------------------------------------------------

HandlePlayerItemSelection(playerid, selecteditem)
{
 	// In this case we're spawning a vehicle for them
    SpawnVehicle_InfrontOfPlayer(playerid, gSelectionItemsTag[playerid][selecteditem], -1, -1);
}

//------------------------------------------------



#endif //veh_thumbnails

// NUKE script
forward NukeCountdown();
public NukeCountdown()
{
	if(intNukeDuration != 0)
	{
		new strMessage[64];
		format(strMessage, sizeof(strMessage), "~r~Tactical Nuke in:~g~ %i ~r~seconds!!!", intNukeDuration);
		GameTextForAll(strMessage, 1000, 4);

 		intNukeDuration--;
	}
	else
	{
		foreach(Player,i)
		{
	        StopAudioStreamForPlayer(i);
	    	SendClientMessage(i, COLOR_RED, "Bzzzzzkghhhzzznnnnnn");
			SetPlayerWeather(i, 19);
			SetPlayerDrunkLevel(i, 7000);
			blnPlayerRadioactive[i] = true;
    	}

		KillTimer(tmrNuke);
		CreateExplosion(NukeOriginX, NukeOriginY, NukeOriginZ, 7, 10.0);
		CreateExplosion(NukeOriginX-10, NukeOriginY, NukeOriginZ, 7, 10.0);
		CreateExplosion(NukeOriginX+10, NukeOriginY, NukeOriginZ, 7, 10.0);
		CreateExplosion(NukeOriginX, NukeOriginY-10, NukeOriginZ, 7, 10.0);
		CreateExplosion(NukeOriginX, NukeOriginY+10, NukeOriginZ, 7, 10.0);
		CreateExplosion(NukeOriginX, NukeOriginY, NukeOriginZ+5, 7, 10.0);
		CreateExplosion(NukeOriginX, NukeOriginY, NukeOriginZ+10, 7, 10.0);
		DestroyObject(NukeObject);
		intNukeDuration = 30; //Reset the timer
		blnNukeActive = false;
	}
}
//end nuke
#pragma unused hstnme

#if defined MAINMENU



#endif //MAINMENU

#if defined FLYMODE

//--------------------------------------------------

stock GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;

    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT; 	// Up & Left key pressed
		else if(ud > 0) direction = MOVE_BACK_LEFT; 	// Back & Left key pressed
		else            direction = MOVE_LEFT;          // Left key pressed
	}
	else if(lr > 0) 	// Right pressed
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;  // Up & Right key pressed
		else if(ud > 0) direction = MOVE_BACK_RIGHT;     // Back & Right key pressed
		else			direction = MOVE_RIGHT;          // Right key pressed
	}
	else if(ud < 0) 	direction = MOVE_FORWARD; 	// Up key pressed
	else if(ud > 0) 	direction = MOVE_BACK;		// Down key pressed

	return direction;
}

//--------------------------------------------------

stock MoveCamera(playerid)
{
	new Float:FV[3], Float:CP[3];
	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);          // 	Cameras position in space
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);  //  Where the camera is looking at

	// Increases the acceleration multiplier the longer the key is held
	if(noclipdata[playerid][accelmul] <= 1) noclipdata[playerid][accelmul] += ACCEL_RATE;

	// Determine the speed to move the camera based on the acceleration multiplier
	new Float:speed = MOVE_SPEED * noclipdata[playerid][accelmul];

	// Calculate the cameras next position based on their current position and the direction their camera is facing
	new Float:X, Float:Y, Float:Z;
	GetNextCameraPosition(noclipdata[playerid][fmode], CP, FV, X, Y, Z);
	MovePlayerObject(playerid, noclipdata[playerid][flyobject], X, Y, Z, speed);

	// Store the last time the camera was moved as now
	noclipdata[playerid][lastmove] = GetTickCount();
	return 1;
}

//--------------------------------------------------

stock GetNextCameraPosition(move_mode, Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    // Calculate the cameras next position based on their current position and the direction their camera is facing
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}
//--------------------------------------------------

stock CancelFlyMode(playerid)
{
	DeletePVar(playerid, "FlyMode");
	CancelEdit(playerid);
	TogglePlayerSpectating(playerid, false);

	DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);
	noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;
	return 1;
}

//--------------------------------------------------

stock FlyMode(playerid)
{
	// Create an invisible object for the players camera to be attached to
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);

	// Place the player in spectating mode so objects will be streamed based on camera location
	TogglePlayerSpectating(playerid, true);
	// Attach the players camera to the created object
	AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);

	SetPVarInt(playerid, "FlyMode", 1);
	noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;
	SendClientMessage(playerid,COLOR_YELLOW,"Type /flymode to exit fly  mode and return to the game");
	return 1;
}

//--------------------------------------------------
#endif

#if defined TUNE
dcmd_tune(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR:] You must be driving to use this command.");
	new vehiclemodel = GetVehicleModel(GetPlayerVehicleID(playerid));
	if(vehiclemodel < 400 || vehiclemodel > 611) return SendClientMessage(playerid, COLOR_RED, "[ERROR:] You can't tune your current vehicle!");
	new string[2048]; //enough?
    new component;
 	ccount[playerid] = 1;
    while(GetVehicleCompatibleUpgrades(vehiclemodel, ccount[playerid], component))
    {
		if(ccount[playerid] <= MAX_COMP)
		{
			if(ccount[playerid] == 1) format(string, sizeof(string), "%s", GetComponentName(component));
			else format(string, sizeof(string), "%s\n%s", string, GetComponentName(component));
			componentsid[playerid][ccount[playerid]-1] = component;
			ccount[playerid]++;
		}
		else break; //in case that MAX_COMP gets passed
    }
	new title[80];
	format(title, sizeof(title), ":: Available Tuning Components for Vehicle Model {FF6400}%d", vehiclemodel);
	ShowPlayerDialog(playerid, TUNEDIALOGID, DIALOG_STYLE_LIST, title, string, "Tune it!", "Cancel");
    return 1;
    #pragma unused params
}
#endif //tune
