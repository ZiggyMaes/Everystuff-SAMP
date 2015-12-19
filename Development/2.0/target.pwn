/* ====================================
Naming conventions:

-Local variables: full lowercase (foobar)
-Global variables: full uppercase (FOOBAR)
-Static: preceded with 's_' (s_foobar[])
-Enum: preceded with 'e_' (e_foobar)

-Defines: full uppercase (FOOBAR)
	
-Functions: capital letter for each word (FooBar())

==================================== */

//===================================Includes===================================
#include <a_samp>
#include <fixes2>
#include <foreach>
#include <a_vehicles>
#include <float>
#include <streamer>
#include <a_mysql>

//===================================Defines====================================
//Database
//not using variables to prevent security leak upon a decompilation by script kiddies
#define DATABASE_HOST "us2.smartbyteshosting.com"
#define DATABASE_USER "kaiser_samptest"
#define DATABASE_PASSWORD "deX7cma~JrFT"
#define DATABASE_DB "kaiser_samptestdb"

//DCMD
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

//console chars fix
#define FixConsole(%1) for(new rSt;rSt<strlen(%1);rSt++) if(%1[rSt]>191 && %1[rSt]<240) %1[rSt]-=64; else if(%1[rSt]>239 && %1[rSt]<256) %1[rSt]-=16; else if (%1[rSt] == 168) %1[rSt]+=72; else if (%1[rSt] == 184) %1[rSt]+=57

//===============================Global Variables===============================
//Server Configuration
enum e_SERVERCONFIG //enum for global config array
{
	ServerMessage[256],
	Float:TeleportXOffset,
	Float:TeleportYOffset,
	Float:TeleportZOffset,
	MinimumPasswordLength,
	bool:DisplayServerMessage,
	MaxPing
}
new SERVERCONFIG[e_SERVERCONFIG]; //Global config array

//Database
new DATABASE; //SQL connection handle

//Timers
new TENMINUTESTIMER, FIVEMINUTESTIMER, ONEMINUTETIMER, FIVESECONDSTIMER, ONESECONDTIMER;

//==============================Default Callbacks===============================
main()
{
}

public OnGameModeInit()
{
	//Global settings
	SetGameModeText("Freeroam DM Stunt Any-Car");
	ShowNameTags(true);
	ShowPlayerMarkers(true);
	SetWorldTime(17);
	SetWeather(10);
	UsePlayerPedAnims();
	for(new i = -1; i < 300; i++) if(IsSkinValid(i)) AddPlayerClass(i,-2667.4729,1594.8196,217.2739,56.19,0,0,0,0,12,1);
	    
	//Global server config
	DATABASE = mysql_connect(DATABASE_HOST, DATABASE_USER, DATABASE_DB, DATABASE_PASSWORD); // connect to the database using defined values
	mysql_function_query(DATABASE, "SELECT * FROM `config`", true, "LoadConfig", ""); //Pull the config from the DB and call LoadConfig() to put them in an array

	//Interval timers
	TENMINUTESTIMER = SetTimer("TenMinutesPassed",600000,true);
    FIVEMINUTESTIMER = SetTimer("FiveMinutesPassed",300000,true);
    ONEMINUTETIMER = SetTimer("OneMinutePassed",60000,true);
    FIVESECONDSTIMER = SetTimer("FiveSeccondsPassed",5000,true);
    ONESECONDTIMER = SetTimer("OneSecondPassed",1000,true);

	return 1;
}

public OnGameModeExit()
{
	//Kill all interval timers
	KillTimer(TENMINUTESTIMER);
	KillTimer(FIVEMINUTESTIMER);
	KillTimer(ONEMINUTETIMER);
	KillTimer(FIVESECONDSTIMER);
	KillTimer(ONESECONDTIMER);
	
	mysql_close(DATABASE); //Close the DB connection
	return 1;
}

//==================================Functions===================================
IsSkinValid(skinid)
{
	if (skinid < 0 || skinid > 299) return false;
    else return true;
}

//For queries that do not return a result
forward ExecuteQuery();
public ExecuteQuery()
{
	return 1;
}

//Pulls the config from the query cache and places it in a global array: SERVERCONFIG
forward LoadConfig();
public LoadConfig()
{
    cache_get_row(0, 4, SERVERCONFIG[ServerMessage], DATABASE, 512);
	SERVERCONFIG[TeleportXOffset] = cache_get_row_float(1, 3);
	SERVERCONFIG[TeleportYOffset] = cache_get_row_float(2,3);
	SERVERCONFIG[TeleportZOffset] = cache_get_row_float(3,3);
	SERVERCONFIG[MinimumPasswordLength] = cache_get_row_int(4,2);
 	SERVERCONFIG[DisplayServerMessage]	= cache_get_row_int(5,5) ? true : false;
	
	return 1;
}

//10 minute timer
forward TenMinutesPassed();
public TenMinutesPassed()
{
	return 1;
}

//5 minute timer
forward FiveMinutesPassed();
public FiveMinutesPassed()
{
	return 1;
}

//1 minute timer
forward OneMinutesPassed();
public OneMinutesPassed()
{
	return 1;
}

//5 seconds timer
forward FiveSecondsPassed();
public FiveSecondsPassed()
{
	return 1;
}

//1 second timer
forward OneSecondPassed();
public OneSecondPassed()
{
	return 1;
}
