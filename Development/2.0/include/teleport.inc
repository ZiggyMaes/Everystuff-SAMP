//==============================================================================
// GameStar teleportkezelõ rendszer
//  A fejlesztés indult:  		2009. december 28.
//  Legutoljára frissítve:      2011. augusztus 1-24.
//  Készítõ:                    GameStar
//  Verzió:                     3.0
//  Kompatibilis:               SA-MP 0.3c+
//
//  Köszönet:
//      Incognito (GVar), Betamaster (színek)
//  Megjegyzés:
//      A rendszer szabadon fejleszthetõ. Ha be akarod küldeni az általad készített
//      dolgokat, akkor keress fel engem (nevezetesen GameStart) / töltsd fel
//      a munkád egy fórumi témába.
//==============================================================================

#if defined _teleport_included
	#endinput
#endif
#define _teleport_included

#include <a_samp>

#define DEFAULT_3DTEXT_FORMAT "{0522FF}Name: {FFFFFF}{NAME}{NEWLINE}{0522FF}Command: {FFFFFF}{COMMAND}{NEWLINE}{0522FF}Price: {FFFFFF}{PRICE}"

//==============================================================================
// A tesztelõ mód engedélyezése(1)/letiltása(0)
// Ez csupán a konzolba ír ki dolgokat, nem muszáj vele törõdni
// Ajánlott érték: KI
//==============================================================================
#define TELEPORT_DEBUG 0

//==============================================================================
// Konstans értékek
// FONTOS! A kezelendõ teleportok (MAX_TELEPORTS) száma szabadon átírható,
// de NE ADJ MEG NAGY ÉRTÉKET AZÉRT MERT AZ JÓL NÉZ KI, mert akkor csökken
// a sebesség, és nõ a méret, ami felesleges!
//==============================================================================
#define MAX_TELEPORTS 1000
#define NO_TELEPORT -1
#define INVALID_TELEPORT_ID NO_TELEPORT
#define MAX_TELEPORT_NAMELEN 32
#define MAX_TELEPORT_CMDLEN 32
#define TELEPORT_VERSION "3.0"

//==============================================================================
// Itt beállíthatod a 3 dimenziós szöveg alapértelmezett színét, valamint
// látótávolságát
//==============================================================================
#define TELEPORT_3D_DEFAULT_COLOR (0x008080FF) //Zöld
//#define TELEPORT_3D_DEFAULT_COLOR (0xDC143CFF) //Piros
//#define TELEPORT_3D_DEFAULT_COLOR (0x6495EDFF) //Kék

#define TELEPORT_3D_DEFAULT_DRAWD 40.0

//==============================================================================
//                              	FIGYELEM!
// Innentõl csak akkor nyúlj a kódba, ha tudod, hogy mit csinálsz.
// Akik fejlesztenek > Egyes függvényekhez van leírás
//==============================================================================
#define TELEPORT_VAR_ACTIVE "teleport_active"
#define TELEPORT_VAR_NAME "teleport_name"
#define TELEPORT_VAR_COMMAND "teleport_command"

#define TELEPORT_VAR_PRICE "teleport_price"
#define TELEPORT_VAR_INTERIOR "teleport_interior"
#define TELEPORT_VAR_WORLDID "teleport_worldid"

#define TELEPORT_VAR_POS_X "teleport_pos_x"
#define TELEPORT_VAR_POS_Y "teleport_pos_y"
#define TELEPORT_VAR_POS_Z "teleport_pos_z"
#define TELEPORT_VAR_POS_ANG "teleport_pos_ang"

#define TELEPORT_VAR_3DTEXT "teleport_3d"
#define TELEPORT_VAR_3DTEXTCOLOR_R "teleport_3dcolor_r"
#define TELEPORT_VAR_3DTEXTCOLOR_G "teleport_3dcolor_g"
#define TELEPORT_VAR_3DTEXTCOLOR_B "teleport_3dcolor_b"
#define TELEPORT_VAR_3DTEXTCOLOR_A "teleport_3dcolor_a"
#define TELEPORT_VAR_3DTEXTDISTANCE "teleport_3ddistance"
#define TELEPORT_VAR_3DTEXTID "teleport_3did"
#define TELEPORT_VAR_3DTEXTFORMAT "teleport_3dtextformat"

#define TELEPORT_VAR_ADMINONLY "teleport_adminonly"
#define TELEPORT_VAR_DRIVERMODE "teleport_drivermode"
#define TELEPORT_VAR_FOOT "teleport_foot"
#define TELEPORT_VAR_VEHICLE "teleport_vehicle"

#define TELEPORT_VAR_OBJECTLOADER "teleport_objectloader"
#define TELEPORT_VAR_LOADERTIME "teleport_loadertime"

//==============================================================================
// GVar plugin by Incognito
// Ez ahhoz kell, hogy a rendszer globálisan használható legyen
//==============================================================================

#define GLOBAL_VARTYPE_NONE (0)
#define GLOBAL_VARTYPE_INT (1)
#define GLOBAL_VARTYPE_STRING (2)
#define GLOBAL_VARTYPE_FLOAT (3)

native SetGVarInt(const name[], {Text3D,_}:value, id = 0);
native GetGVarInt(const name[], id = 0);
native SetGVarString(const name[], const value[], id = 0);
native GetGVarString(const name[], dest[], maxlength = sizeof dest, id = 0);
native SetGVarFloat(const name[], Float:value, id = 0);
native Float:GetGVarFloat(const name[], id = 0);
native DeleteGVar(const name[], id = 0);
native GetGVarsUpperIndex(id = 0);
native GetGVarNameAtIndex(index, dest[], maxlength = sizeof dest, id = 0);
native GetGVarType(const name[], id = 0);

//==============================================================================
// Ha nem tud elteleportálni a játékos (FailedTeleport), akkor az alábbi hibaüzenetek
// alapján behatárolható, hogy miért nem.
//==============================================================================
#define TELE_NOT_SPAWNED	(0)	// Nincs leszületve
#define TELE_NOT_ADMIN      (1)	// Nem RCON admin
#define TELE_LOW_MONEY      (2)	// Kevés a pénze
#define TELE_FAIL_CALLING   (3)	// A meghívás 0-val tér vissza
#define TELE_NOT_DRIVER     (4)	// Nem sofõr
#define TELE_NOT_ONFOOT     (5)	// Nem gyalog van
#define TELE_NOT_INVEHICLE  (6)	// Nincs jármûben

//==============================================================================
// Egy SA-MP elírás(?) javítása
//==============================================================================
#if defined INVALID_3DTEXT_ID
	#undef INVALID_3DTEXT_ID
#endif
#define INVALID_3DTEXT_ID Text3D:-1

//==============================================================================
// Prototípusok létrehozása
//==============================================================================
forward OnPlayerTeleport(playerid,teleportid);
forward OnPlayerCallingTeleport(playerid,teleportid);
forward OnPlayerFailedTeleport(playerid,teleportid,reason);
forward OnPlayerStartingObjectLoad(playerid,time,teleportid);
forward OnPlayerEndingObjectLoad(playerid);
forward Teleport_UnfreezePlayer(playerid);

//==============================================================================
// Név:			Teleport_CheckValid
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     Ha a teleport nem létezik, akkor a megadott értékkel térít vissza
//==============================================================================
#define Teleport_CheckValid(%1,%2) \
	if(!Teleport_IsValid(%1)) return %2

//==============================================================================
// Név:			Teleport_GetFailReasonAsString
// Frissítve:   2011/AUGUSZTUS/2
// Készítõ:     GameStar
// Jegyzet:     A sikertelen teleportáláskor visszaadott hibaüzenetet szöveges
//              formában beleírja egy célkarakterláncba
//==============================================================================
stock Teleport_GetFailReasonAsString(reason,dest[],size = sizeof(dest))
{
	new s_Reason[][]={"Nem spawnolt","Nem admin","Nincs pénze","Egyéb","Nem sofõr","Nincs gyalog", "Nincs jármûben"};
	format(dest,size,"%s",s_Reason[reason]);
	return 1;
}

//==============================================================================
// Név:			Teleport_SetActive (lokális)
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
static
	stock Teleport_SetActive(teleportid,set)
	{
	    // Ha igaz érték
	    if(set) SetGVarInt(TELEPORT_VAR_ACTIVE, 1, teleportid);
		else SetGVarInt(TELEPORT_VAR_ACTIVE, 0, teleportid);
	}

//==============================================================================
// Név:			Teleport_IsActive
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsActive(teleportid)
{
	// Visszatérés
    return GetGVarInt(TELEPORT_VAR_ACTIVE, teleportid);
}

//==============================================================================
// Név:			Teleport_IsActive
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsAdminOnly(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    return GetGVarInt(TELEPORT_VAR_ADMINONLY, teleportid);
}

//==============================================================================
// Név:			Teleport_IsValid
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsValid(teleportid)
{
	// Ha érvényes az azonosító
	if(teleportid >= 1 && teleportid < MAX_TELEPORTS)
	{
	    // És aktív
	    if(Teleport_IsActive(teleportid))
	    {
	        // Igaz visszatérés
	        return true;
		}
	}
	return false;
}

//==============================================================================
// Név:			Teleport_Create
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     Ez hoz létre egy teleportot
//==============================================================================
stock Teleport_New(tname[], cmd[], Float:x,Float:y,Float:z,Float:angle,interior=0,worldid=0,price=0, bool:text3d = true,text3dcolor = TELEPORT_3D_DEFAULT_COLOR, Float:text3ddrawd = TELEPORT_3D_DEFAULT_DRAWD,bool:objectloader = false, objectltime = 2500, bool:foot = true, bool:vehicle = true,bool:drivermode = true, bool:adminonly = false)
{
	// Tároló létrehozása
	new teleportid;
	
	// Duplaparancs-tiltás
	if(Teleport_IsValid(GetGVarInt(cmd)))
	{
	    printf("%i",GetGVarInt(cmd));
		#if TELEPORT_DEBUG == 1
        	printf("Már van ilyen parancs: %s",cmd);
		#endif
	 	return MAX_TELEPORTS;
	}
	// Legközelebbi szabad azonosító megkeresése
	for(teleportid = 1; teleportid < MAX_TELEPORTS; teleportid++)
	{
	    // Ha már foglalt a parancs, akkor nem hozzuk létre
	    //if(!strcmp(TeleportData[teleportid][TELEPORT_COMMAND],cmd,false)) return MAX_TELEPORTS;

		if(!Teleport_IsActive(teleportid)) break;
	}
	// Ha nem találtunk szabad azonosítót, visszatérünk
	// a MAX_TELEPORTS értékével
	if(teleportid == MAX_TELEPORTS) return MAX_TELEPORTS;

	SetGVarInt(TELEPORT_VAR_3DTEXT, 0, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTID, INVALID_3DTEXT_ID, teleportid);
	
	new r, g, b, a;
	HexToRGBA(TELEPORT_3D_DEFAULT_COLOR, r, g, b, a);
	
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_R, r, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_G, g, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_B, b, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_A, a, teleportid);
	
	SetGVarFloat(TELEPORT_VAR_3DTEXTDISTANCE, TELEPORT_3D_DEFAULT_DRAWD, teleportid);
	
  	// Megjegyezzük, hogy az azonosító foglalt
    Teleport_SetActive(teleportid,1);
    
   	// Név beállítása
    Teleport_SetName(teleportid,tname);

    // Parancs beállítása
    Teleport_SetCommand(teleportid,cmd);
    
	// Koorináták beállítása
	Teleport_SetPos(teleportid,x,y,z,angle);
	
	// Céldimenzió beállítása
	Teleport_SetInterior(teleportid,interior);

	// Céldimenzió 2 beállítása
    Teleport_SetVirtualWorld(teleportid,worldid);
    
    // Ár beállítása
    Teleport_SetPrice(teleportid,price);
    
    // 3D text formátumának beállítása
    Teleport_Set3DTextFormat(teleportid, DEFAULT_3DTEXT_FORMAT);
    
	// 3Dtext
    Teleport_Toggle3Dtext(teleportid, text3d);
    
    // 3Dtext szín
    Teleport_SetText3Dcolor(teleportid,text3dcolor);
    
	// Látótávolság
	Teleport_Set3DtextDrawDistance(teleportid,text3ddrawd);
	
    // Betöltés beállítása
    Teleport_ToggleObjectLoader(teleportid,objectloader);
    
    // Betöltési idõ beállítása
    Teleport_SetLoaderTime(teleportid, objectltime);
    
    // Gyalogkezelés beállítása
    Teleport_ToggleFoot(teleportid,foot);
    
    // Jármûkezelés beállítása
    Teleport_ToggleVehicle(teleportid,vehicle);
    
    // Sofõrmód beállítása
    Teleport_ToggleDriverMode(teleportid, drivermode);
    
    // Adminmód beállítása
    Teleport_ToggleAdminOnly(teleportid, adminonly);
    
	// Debug
    #if TELEPORT_DEBUG == 1
        printf("Egy új teleport jött létre: %s (AZONOSÍTÓ: %i)",cmd,teleportid);
	#endif
	
	// A legnagyobb teleport azonosító
	SetGVarInt("teleport_highestid", teleportid);
	
	// Visszaadjuk az azonosítót
    return teleportid;
}

//==============================================================================
// Név:			Teleport_CountAll
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_CountAll()
{
	// Változók létrehozása
	new teleportid,tele_count = 0;
		
	// Elszámolunk MAX_TELEPORTS-1 ig, és ha az aktuális teleport
	// azonosító foglalt(aktív), növeljük a számláló értékét
	for(teleportid=1; teleportid<MAX_TELEPORTS; teleportid++)if(Teleport_IsActive(teleportid))tele_count++;

	// Visszaadjuk a megszámolt értéket
	return tele_count;
}

//==============================================================================
// Név:			Teleport_LittleID
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_LittleID()
{
    // Változó létrehozása
    new teleportid;
        
	// Ciklus indítása
	for(teleportid = 1; teleportid < GetGVarInt("teleport_highestid"); teleportid++) if(Teleport_IsActive(teleportid)) break;
	
	// Visszatérés
	return teleportid;
}

//==============================================================================
// Név:			Teleport_LittleID
// Frissítve:   2011/AUGUSZTUS/17
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_HighestID()
{
    /*// Változó létrehozása
    new teleportid, highest = NO_TELEPORT;

	// Ciklus indítása
	for(teleportid = 0; teleportid < MAX_TELEPORTS; teleportid++) if(Teleport_IsActive(teleportid)) highest = teleportid;

	// Visszatérés
	return highest;*/
	return GetGVarInt("teleport_highestid");
}

//==============================================================================
// Név:			Teleport_IsValid3Dtext
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsValid3Dtext(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha érvénytelen
	if(GetGVarInt(TELEPORT_VAR_3DTEXTID, teleportid) != _:INVALID_3DTEXT_ID) return 1;
	else return 0;
}

//==============================================================================
// Név:			Teleport_ToggleDriverMode
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_ToggleDriverMode(teleportid,toggle)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igen
 	if(toggle) SetGVarInt(TELEPORT_VAR_DRIVERMODE, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_DRIVERMODE, 0, teleportid);

	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_IsUsingDriverMode
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsUsingDriverMode(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Visszatérés
	return GetGVarInt(TELEPORT_VAR_DRIVERMODE, teleportid);
}

//==============================================================================
// Név:			Teleport_Set3DTextFormat
// Frissítve:   2011/AUGUSZTUS/24
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_Set3DTextFormat(teleportid, sformat[])
{
    Teleport_CheckValid(teleportid, MAX_TELEPORTS);
	SetGVarString(TELEPORT_VAR_3DTEXTFORMAT, sformat, teleportid);
	Teleport_Update3dText(teleportid);
	return 1;
}

//==============================================================================
// Név:			Teleport_Toggle3Dtext
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_Toggle3Dtext(teleportid,toggle)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igaz érték
 	if(toggle) SetGVarInt(TELEPORT_VAR_3DTEXT, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_3DTEXT, 0, teleportid);

	// Frissítés
	Teleport_Update3dText(teleportid);
		
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_IsUsing3Dtext
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsUsing3Dtext(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

 	return GetGVarInt(TELEPORT_VAR_3DTEXT, teleportid);
}

//==============================================================================
// Név:			Teleport_SetText3Dcolor
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetText3Dcolor(teleportid, color)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    new r, g, b, a;
    HexToRGBA(color, r, g, b, a);

	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_R, r, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_G, g, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_B, b, teleportid);
	SetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_A, a, teleportid);
	
	// Frissítés
	Teleport_Update3dText(teleportid);
	
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_GetText3Dcolor
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetText3Dcolor(teleportid)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    new r, g, b, a;
  
    r = GetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_R, teleportid);
	g = GetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_G, teleportid);
	b = GetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_B, teleportid);
	a = GetGVarInt(TELEPORT_VAR_3DTEXTCOLOR_A, teleportid);
	
	// Visszatérés
	return RGBAToHex(r, g, b, a);
}

//==============================================================================
// Név:			Teleport_Set3DtextDrawDistance
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_Set3DtextDrawDistance(teleportid, Float:distance)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	SetGVarFloat(TELEPORT_VAR_3DTEXTDISTANCE, distance, teleportid);

	// Frissítjük
	Teleport_Update3dText(teleportid);

	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_Get3DtextDeawDistance
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_Get3DtextDeawDistance(teleportid, &Float:dis)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Visszatérés
	dis = GetGVarFloat(TELEPORT_VAR_3DTEXTDISTANCE, teleportid);
	return 1;
}

//==============================================================================
// Név:			Teleport_Update3dText (helyi)
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
static
	stock Teleport_Update3dText(teleportid)
	{
	    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
		Teleport_CheckValid(teleportid, MAX_TELEPORTS);
        
		// Ha használ 3dTextet
        if (Teleport_IsUsing3Dtext(teleportid))
	    {
	        // Segédváltozó
	        //new string[256];
	        
	        // Ha érvényes a 3dtext
	   		if(Teleport_IsValid3Dtext(teleportid))
			{
			   	Delete3DTextLabel(Text3D:GetGVarInt(TELEPORT_VAR_3DTEXTID, teleportid));
			   	SetGVarInt(TELEPORT_VAR_3DTEXTID,INVALID_3DTEXT_ID,teleportid);
			}
			#if TELEPORT_DEBUG == 1
				printf("Teleport_Update3dText: 3Dtext frissítve #ID %i", teleportid);
			#endif
			
			// Formázás
			/*new name[MAX_TELEPORT_NAMELEN],
			    command[MAX_TELEPORT_CMDLEN];
			    
            Teleport_GetName(teleportid, name, sizeof(name));
            Teleport_GetCommand(teleportid, command, sizeof(command));
			format(string, sizeof(string), "%s\n%s",name, command);

            new Float:x, Float:y, Float:z, Float:dis, worldid;
            Teleport_GetPos(teleportid, x,y,z);
         
			Teleport_Get3DtextDeawDistance(teleportid, dis);

			worldid = Teleport_GetVirtualWorld(teleportid);
			*/
			/*
			    {RRGGBB} - Egyéni szín
			    {NAME} - Név
			    {COMMAND} - Parancs
			    {PRICE} - Ár
			    {NEWLINE} - Új sor
			    példa: {FFFF00}{NAME}{NEWLINE}{COMMAND}{NEWLINE}${PRICE}
			        ->
				sárga színnel:
					Teleport
					/parancs
					$ár
			*/
			new sformat[256];
			GetGVarString(TELEPORT_VAR_3DTEXTFORMAT, sformat, sizeof(sformat), teleportid);
 			//print(sformat);
			new name[MAX_TELEPORT_NAMELEN],
			    command[MAX_TELEPORT_CMDLEN],
			    price;
			    
            Teleport_GetName(teleportid, name, sizeof(name));
            Teleport_GetCommand(teleportid, command, sizeof(command));
            price = Teleport_GetPrice(teleportid);
            
            new Float:x, Float:y, Float:z, Float:dis, worldid;
            Teleport_GetPos(teleportid, x,y,z);

			Teleport_Get3DtextDeawDistance(teleportid, dis);

			worldid = Teleport_GetVirtualWorld(teleportid);

			#define strreplace2(%1,%2) \
			    while(strfind(sformat,%1)>-1) sformat = strreplace(%1, %2, sformat)

            strreplace2("{NAME}", name);
            strreplace2("{COMMAND}", command);
            new str_price[12];
			valstr(str_price, price);
            strreplace2("{PRICE}", str_price);
            strreplace2("{NEWLINE}", "\n");
	
			// Létrehozzuk az újat
			new Text3D:id = Create3DTextLabel(sformat,Teleport_GetText3Dcolor(teleportid), x, y, z, dis, worldid);
			SetGVarInt(TELEPORT_VAR_3DTEXTID,id,teleportid);
			// Visszatérés
			return true;
		}
		// Ha nem használ 3dTextet
		else
		{
		    // De érvényes a 3dtext
			if(Teleport_IsValid3Dtext(teleportid))
			{
                #if TELEPORT_DEBUG == 1
					printf("Teleport_Update3dText: 3Dtext törölve #ID %i", teleportid);
				#endif

                // Töröljük
                Delete3DTextLabel(Text3D:GetGVarInt(TELEPORT_VAR_3DTEXTID, teleportid));
				
                // Érvénytelenítjük
                SetGVarInt(TELEPORT_VAR_3DTEXTID,INVALID_3DTEXT_ID, teleportid);
			}
		}
		// Visszatérés
		return true;
	}

//==============================================================================
// Név:			strreplace
// Frissítve:   -
// Készítõ:     Westie
// Jegyzet:     -
//==============================================================================
stock strreplace(sSearch[], sReplace[], const sSubject[], &iCount = 0)
{
	new
		iLengthTarget = strlen(sSearch),
		iLengthReplace = strlen(sReplace),
		iLengthSource = strlen(sSubject),
		iItterations = (iLengthSource - iLengthTarget) + 1;

	new
		sTemp[128],
		sReturn[256];

	strcat(sReturn, sSubject, sizeof(sReturn));
	iCount = 0;

	for(new iIndex; iIndex < iItterations; ++iIndex)
	{
		strmid(sTemp, sReturn, iIndex, (iIndex + iLengthTarget), (iLengthTarget + 1));

		if(!strcmp(sTemp, sSearch, false))
		{
			strdel(sReturn, iIndex, (iIndex + iLengthTarget));
			strins(sReturn, sReplace, iIndex, iLengthReplace);

			iIndex += iLengthTarget;
			iCount++;
		}
	}
	return sReturn;
}

//==============================================================================
// Név:			Teleport_ToggleAdminOnly
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_ToggleAdminOnly(teleportid,toggle)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igaz
	if(toggle) SetGVarInt(TELEPORT_VAR_ADMINONLY, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_ADMINONLY, 0, teleportid);

	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_SetLoaderTime
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetLoaderTime(teleportid, ms)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Mentés
	SetGVarInt(TELEPORT_VAR_LOADERTIME, ms, teleportid);

    // Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_GetLoaderTime
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetLoaderTime(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Visszatérés
	return GetGVarInt(TELEPORT_VAR_LOADERTIME, teleportid);
}

//==============================================================================
// Név:			Teleport_ToggleFoot
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_ToggleFoot(teleportid,toggle)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igaz
	if(toggle) SetGVarInt(TELEPORT_VAR_FOOT, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_FOOT, 0, teleportid);

	// Visszatérés
	return 1;
}
//==============================================================================
// Név:			Teleport_IsUsingFoot
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsUsingFoot(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
  
    // Visszatérés
	return GetGVarInt(TELEPORT_VAR_FOOT, teleportid);
}

//==============================================================================
// Név:			Teleport_ToggleVehicle
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_ToggleVehicle(teleportid,toggle)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igaz
	if(toggle) SetGVarInt(TELEPORT_VAR_VEHICLE, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_VEHICLE, 0, teleportid);

	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_IsUsingVehicle
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsUsingVehicle(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Visszatérés
	return GetGVarInt(TELEPORT_VAR_VEHICLE, teleportid);
}

//==============================================================================
// Név:			Teleport_ToggleObjectLoader
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_ToggleObjectLoader(teleportid,toggle)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Ha igaz
	if(toggle) SetGVarInt(TELEPORT_VAR_OBJECTLOADER, 1, teleportid);
	else SetGVarInt(TELEPORT_VAR_OBJECTLOADER, 0, teleportid);

	// Visszatérés
	return 1;
}


//==============================================================================
// Név:			Teleport_IsUsingObjectLoader
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_IsUsingObjectLoader(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Visszatérés
	return GetGVarInt(TELEPORT_VAR_OBJECTLOADER, teleportid);
}

//==============================================================================
// Név:			Teleport_SetPrice
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetPrice(teleportid,price)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
	// Mentés
    SetGVarInt(TELEPORT_VAR_PRICE, price, teleportid);
    
    // Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_GetPrice
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetPrice(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
 
    // Visszatérés
	return GetGVarInt(TELEPORT_VAR_PRICE, teleportid);
}

//==============================================================================
// Név:			Teleport_SetPos
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetPos(teleportid,Float:x,Float:y,Float:z,Float:angle = 0.0)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
	    
	SetGVarFloat(TELEPORT_VAR_POS_X, x, teleportid);
	SetGVarFloat(TELEPORT_VAR_POS_Y, y, teleportid);
	SetGVarFloat(TELEPORT_VAR_POS_Z, z, teleportid);
	SetGVarFloat(TELEPORT_VAR_POS_ANG, angle, teleportid);

	// 3D text
	if(Teleport_IsUsing3Dtext(teleportid)) Teleport_Update3dText(teleportid);
	
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_GetPos
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetPos(teleportid,&Float:x,&Float:y,&Float:z,&Float:angle = 0.0)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
	
	x = GetGVarFloat(TELEPORT_VAR_POS_X, teleportid);
	y = GetGVarFloat(TELEPORT_VAR_POS_Y, teleportid);
	z = GetGVarFloat(TELEPORT_VAR_POS_Z, teleportid);
	angle = GetGVarFloat(TELEPORT_VAR_POS_ANG, teleportid);
	
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_SetInterior
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetInterior(teleportid,interiorid)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Érték módosítása
    SetGVarInt(TELEPORT_VAR_INTERIOR,interiorid,teleportid);
	return 1;
}

//==============================================================================
// Név:			Teleport_GetInterior
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetInterior(teleportid)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	return GetGVarInt(TELEPORT_VAR_INTERIOR, teleportid);
}

//==============================================================================
// Név:			Teleport_SetVirtualWorld
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetVirtualWorld(teleportid,worldid)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Érték módosítása
	SetGVarInt(TELEPORT_VAR_WORLDID, worldid, teleportid);
	
    // 3D text
	Teleport_Update3dText(teleportid);
	
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			Teleport_GetVirtualWorld
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetVirtualWorld(teleportid)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

    // Visszatérés az értékkel
	return GetGVarInt(TELEPORT_VAR_WORLDID, teleportid);
}

//==============================================================================
// Név:			Teleport_SetName
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetName(teleportid,tname[])
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Név módosítása
	SetGVarString(TELEPORT_VAR_NAME, tname, teleportid);
	
	// Frissítés
	Teleport_Update3dText(teleportid);
	
	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_GetName
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetName(teleportid,tname[],len)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// Név tárolása
	GetGVarString(TELEPORT_VAR_NAME, tname, len, teleportid);

	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_SetCommand
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_SetCommand(teleportid,cmd[])
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	if(Teleport_IsValid(GetGVarInt(cmd)))
	{
		#if TELEPORT_DEBUG == 1
        	printf("Már van ilyen parancs: %s",cmd);
		#endif
	 	return MAX_TELEPORTS;
	}
	new old_command[MAX_TELEPORT_CMDLEN];
	GetGVarString(TELEPORT_VAR_COMMAND, old_command, sizeof(old_command), teleportid);
	SetGVarInt(old_command, 0);
	DeleteGVar(old_command, teleportid);
    SetGVarInt(cmd, teleportid);
    SetGVarString(TELEPORT_VAR_COMMAND, cmd, teleportid);

	// Frissítés
	Teleport_Update3dText(teleportid);

	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_GetCommand
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetCommand(teleportid,cmd[],len)
{
	// Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);
	
	// Név tárolása
	GetGVarString(TELEPORT_VAR_COMMAND, cmd, len, teleportid);

	// Visszatérés
	return 1;
}

//==============================================================================
// Név:			Teleport_Remove
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_Remove(teleportid)
{
    // Ha a teleport nem érvényes, visszatérünk MAX_TELEPORTS értékkel
	Teleport_CheckValid(teleportid, MAX_TELEPORTS);

	// 3 dimenziós szöveg "törlése"
    Teleport_Toggle3Dtext(teleportid,0);
    
	// Azonosító szabaddátétele
    Teleport_SetActive(teleportid,0);
    
    // Visszatérés
    return 1;
}

//==============================================================================
// Név:			Teleport_RemoveAll
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_RemoveAll()
{
	for(new i = 1; i < Teleport_HighestID(); i++) Teleport_Remove(i);
  
    // Visszatérés
    return 1;
}

//==============================================================================
// Név:			Teleport_GetIDByCommand
// Frissítve:   2010/AUGUSZTUS/17
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
stock Teleport_GetIDByCommand(command[])
{
	/*new tmp[MAX_TELEPORT_CMDLEN];
	for(new i = 0; i < Teleport_HighestID()+1; i++){
	    GetGVarString(TELEPORT_VAR_COMMAND, tmp, sizeof(tmp), teleportid);
	    if(!strcmp(tmp, command)) return i;
	}*/
	new result = GetGVarInt(command);
	if(Teleport_IsValid(result)) return result;
	return NO_TELEPORT;
}

//==============================================================================
// Név:			Teleport_UnfreezePlayer
// Frissítve:   2011/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     -
//==============================================================================
public Teleport_UnfreezePlayer(playerid)
{
	// Ha csatlakozva van
	if(IsPlayerConnected(playerid))
	{
		// Kiolvasztás
		TogglePlayerControllable(playerid,1);

        // OnPlayerEndingObjectLoad meghívása
		if(funcidx("OnPlayerEndingObjectLoad") != -1)
		{
  			CallRemoteFunction("OnPlayerEndingObjectLoad","i",playerid);
		}
	}
	// Visszatérés
	return true;
}

//==============================================================================
// Név:			TeleportPlayer
// Frissítve:   2010/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     Egy megadott teleport azonosítóra teleportálja a játékost.
//              Parancs alapján a TeleportPlayerEx függvényt kell használni
//==============================================================================
stock TeleportPlayer(playerid,teleportid)
{
    Teleport_CheckValid(teleportid, false);
    new pstate = GetPlayerState(playerid);
	if(pstate == PLAYER_STATE_NONE || pstate == PLAYER_STATE_WASTED || pstate == PLAYER_STATE_SPECTATING)
	{
		CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid, TELE_NOT_SPAWNED);
		return true;
	}
	if(Teleport_IsAdminOnly(teleportid) && !IsPlayerAdmin(playerid))
	{
		CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid, TELE_NOT_ADMIN);
		return true;
	}
	if(Teleport_GetPrice(teleportid)>GetPlayerMoney(playerid))
	{
 		CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid, TELE_LOW_MONEY);
		return true;
	} else GivePlayerMoney(playerid, -Teleport_GetPrice(teleportid));
 	if(funcidx("OnPlayerCallingTeleport"))
 	{
		if(CallLocalFunction("OnPlayerCallingTeleport","ii",playerid,teleportid))
		{
			CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid,TELE_FAIL_CALLING);
			return true;
		}
	}
	new Float:x,Float:y,Float:z,Float:angle;
	Teleport_GetPos(teleportid,x,y,z,angle);
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(Teleport_IsUsingVehicle(teleportid))
		{
   			if(Teleport_IsUsingDriverMode(teleportid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
  			{
       			CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid,TELE_NOT_DRIVER);
				return true;
			}
			new VID = GetPlayerVehicleID(playerid);
	   		SetVehiclePos(VID,x,y,z);
	   		SetVehicleZAngle(VID,angle);
	   		LinkVehicleToInterior(VID,Teleport_GetInterior(teleportid));
  		 	SetVehicleVirtualWorld(VID,Teleport_GetVirtualWorld(teleportid));
			SetPlayerInterior(playerid,Teleport_GetInterior(teleportid));
			SetPlayerVirtualWorld(playerid,Teleport_GetVirtualWorld(teleportid));
		}
		else
		{
			CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid,TELE_NOT_ONFOOT);
			return true;
		}
	}
	else
	{
		if(Teleport_IsUsingFoot(teleportid))
		{
			SetPlayerPos(playerid,x,y,z);
			SetPlayerFacingAngle(playerid,angle);
			SetPlayerInterior(playerid,Teleport_GetInterior(teleportid));
			SetPlayerVirtualWorld(playerid,Teleport_GetVirtualWorld(teleportid));
		}
		else
		{
			CallRemoteFunction( "OnPlayerFailedTeleport", "iii", playerid, teleportid,TELE_NOT_INVEHICLE);
			return true;
		}
	}
	SetCameraBehindPlayer(playerid);
	if(Teleport_IsUsingObjectLoader(teleportid))
	{
	    if(funcidx("OnPlayerStartingObjectLoad"))CallRemoteFunction("OnPlayerStartingObjectLoad","iii",playerid,Teleport_GetLoaderTime(teleportid),teleportid);
	    TogglePlayerControllable(playerid,0);
	   	SetTimerEx("Teleport_UnfreezePlayer",Teleport_GetLoaderTime(teleportid),false,"i",playerid);
	}
 	CallRemoteFunction("OnPlayerTeleport","ii",playerid,teleportid);
 	#if TELEPORT_DEBUG == 1
 		printf("Teleportálva: JÁTÉKOS(#%i) TELEPORT(#%i)",playerid,teleportid);
	#endif
	return true;
}

public OnPlayerCommandText(playerid,cmdtext[])
{
	if(TeleportPlayerEx(playerid,cmdtext)) return 1;
	if(funcidx("Teleport_OnPlayerCommandText")) return CallLocalFunction("Teleport_OnPlayerCommandText", "is", playerid, cmdtext);
	return 0;
}

#if defined _ALS_OnPlayerCommandText
	#undef OnPlayerCommandText
#else
	#define _ALS_OnPlayerCommandText
#endif
#define OnPlayerCommandText Teleport_OnPlayerCommandText
forward Teleport_OnPlayerCommandText(playerid,cmdtext[]);

//==============================================================================
// Név:			TeleportPlayerEx
// Frissítve:   2010/AUGUSZTUS/3
// Készítõ:     GameStar
// Jegyzet:     Parancs alapján teleportál valakit teleporttal
//==============================================================================
stock TeleportPlayerEx(playerid,cmd[])
{
	// Lekérjük az azonosítót, ami a parancshoz elvileg tartozik
    new teleid = Teleport_GetIDByCommand(cmd);
    
    // Ha nem érvényes, akkor továbblépünk
	Teleport_CheckValid(teleid, false);
	
	// Ha érvényes, akkor kezeljük...
	return TeleportPlayer(playerid,teleid);
}

//==============================================================================
// Név:			HexToRGBA
// Frissítve:   -
// Készítõ:     Betamaster
// Jegyzet:     -
//==============================================================================
stock HexToRGBA(colour, &r, &g, &b, &a)
{
	r = (colour >> 24) & 0xFF;
	g = (colour >> 16) & 0xFF;
	b = (colour >> 8) & 0xFF;
	a = colour & 0xFF;
}

//==============================================================================
// Név:			RGBAToHex
// Frissítve:   -
// Készítõ:     Betamaster
// Jegyzet:     -
//==============================================================================
stock RGBAToHex(r, g, b, a)
{
	return (r<<24 | g<<16 | b<<8 | a);
}

//  Ezek az új funkciónevek
#define CreateTeleport Teleport_New
#define DestroyTeleport Teleport_Remove
#define CountTeleports Teleport_CountAll
#define GetLittleTeleportID Teleport_LittleID
#define GetHighestTeleportID Teleport_HighestID
#define IsActiveTeleport Teleport_IsActive
#define IsValidTeleport Teleport_IsValid
#define IsTeleportIsValid3D Teleport_IsValid3Dtext
#define ToggleTeleport3D Teleport_Toggle3Dtext
#define TeleportIsUse3D Teleport_IsUsing3Dtext
#define SetTeleport3DColor Teleport_SetText3Dcolor
#define GetTeleport3DColor Teleport_GetText3Dcolor
#define SetTeleport3DDrawDistance Teleport_Set3DtextDrawDistance
#define GetTeleport3DDrawDistance Teleport_Get3DtextDeawDistance
/*#define LoadTeleportFile Teleport_LoadFromFile
#define SaveTeleportsToFile Teleport_SaveToFile
#define SaveTeleportToFile Teleport_SaveToFileEx*/
#define ToggleTeleportDriverMode Teleport_ToggleDriverMode
#define IsTeleportDriverMode Teleport_IsUsingDriverMode
#define ToggleTeleportAdminOnly Teleport_ToggleAdminOnly
#define IsTeleportAdminOnly Teleport_IsAdminOnly
#define SetTeleportLoaderTime Teleport_SetLoaderTime
#define GetTeleportLoaderTime Teleport_GetLoaderTime
#define ToggleTeleportOnFoot Teleport_ToggleFoot
#define IsTeleportOnFoot Teleport_IsUsingFoot
#define ToggleTeleportVehicle Teleport_ToggleVehicle
#define IsTeleportVehicle Teleport_IsUsingVehicle
#define ToggleTeleportObjectLoader Teleport_ToggleObjectLoader
#define IsTeleportObjectLoader Teleport_IsUsingObjectLoader
#define SetTeleportPrice Teleport_SetPrice
#define GetTeleportPrice Teleport_GetPrice
#define SetTeleportPos Teleport_SetPos
#define GetTeleportPos Teleport_GetPos
#define SetTeleportInterior Teleport_SetInterior
#define GetTeleportInterior Teleport_GetInterior
#define SetTeleportVirtualWorld Teleport_SetVirtualWorld
#define GetTeleportVirtualWorld Teleport_GetVirtualWorld
#define SetTeleportName Teleport_SetName
#define GetTeleportName Teleport_GetName
#define SetTeleportCommand Teleport_SetCommand
#define GetTeleportCommand Teleport_GetCommand
#define DestroyAllTeleport Teleport_RemoveAll

//==============================================================================
// Név:			Teleport_Foreach
// Frissítve:   2010/AUGUSZTUS/18
// Készítõ:     GameStar
// Jegyzet:     
//==============================================================================
#define Teleport_Foreach(%1) \
    for(new %1 = 1; %1 < Teleport_HighestID()+1; %1++) if(Teleport_IsValid(%1))

