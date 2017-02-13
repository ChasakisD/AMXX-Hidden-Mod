#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <amxmisc>

#define PLUGIN "Hidden Mod"
#define VERSION "3.5"
#define AUTHOR "Oxygen"

// ===============================================================================
// 	Change on what flag you want
// ===============================================================================
#define VIP_FLAG ADMIN_LEVEL_H

// ===============================================================================
// 	Check if Player is valid
// ===============================================================================
#define is_valid_player(%1) (1 <= %1 <= 32)

// ===============================================================================
// 	Integers
// ===============================================================================
new msgScreenFade
new const saychatprefix[] = { "!g[!nHidden-Mod!g]!n" }

// ===============================================================================
// 	Integer / Cvars
// ===============================================================================
//Joker Cvars
new p_jokerhp, p_jokerspeed, p_jokerarmor, p_jokergravity,  p_seconds, p_jokersilent, p_jokerinvis
//Human Cvars
new p_humanhp, p_humanarmor, p_humanspeed, p_humangravity, p_humansilent
//Fog Cvar
new p_fogenable, p_fogr, p_fogg, p_fogb, p_fogdens
//Shop Cvars
//Shop Ammount Cvars
new p_shop, p_shophp, p_shopgravity, p_shoparmor, p_shopmaxjumps, p_shopspeed, p_shopthp
//Shop Prices Cvars
new p_hpcost, p_gravcost, p_armorcost, p_multicost, p_akmcost, p_damcost, p_speedcost ,p_hptcost, p_multitcost, p_damtcost
//Unlock Prices Cvars
new p_unlock, p_unlm4, p_unlak, p_unlgal, p_unlawp, p_unlp90, p_unldgl, p_unldual, p_unlaxe, p_unlstrong, p_unlcombat
//Effects cvars
new p_effects
new p_time
new g_TimerInvisible
new p_huds
new p_vipknife
new p_newinvis
//End of cvars
new timer
new sync_hud1


// ===============================================================================
// 	Booleans
// ===============================================================================
new NRTS[33] //Bool for change team
new HasSpeed[33] //bool for each team speed
new HasShopSpeed[33] //bool for speed in shop
new HasGravity[33] //bool for gravity shop
new HasDamage[33] //bool for double damage shop
new HasMulti[33] //bool for multijump shop
new jumpnum[33] //bool for multijump
new dojump[33] //bool for multijump
new knifes_used[33]
new prima_used[33]
new second_used[33]
new is_joker[33]

//BOOL FOR NEW STYLE OF SHOP
new itemunlocked[33][10]
/*
[0] = M4
[1] = AK47
[2] = Galil
[3] = P90
[4] = AWP
[5] = Deagle
[6] = Dual
[7] = Strong
[8] = Axe
[9] = Combat
*/

// ===============================================================================
// 	Stuff Removing Entities/Buyzone
// ===============================================================================
new g_HostageEnt
new const g_sRemoveEntities[][] =
{
	"func_bomb_target",
	"info_bomb_target",
	"hostage_entity",
	"monster_scientist",
	"func_hostage_rescue",
	"info_hostage_rescue",
	"info_vip_start",
	"func_vip_safetyzone",
	"func_escapezone",
	"armoury_entity"
};

new const MAX_REMOVED_ENTITIES = sizeof(g_sRemoveEntities);

// ===============================================================================
// 	Stuff AutoJoin Team
// ===============================================================================

// Old Style Menus
stock const FIRST_JOIN_MSG[] =		"#Team_Select";
stock const FIRST_JOIN_MSG_SPEC[] =	"#Team_Select_Spect";
stock const INGAME_JOIN_MSG[] =		"#IG_Team_Select";
stock const INGAME_JOIN_MSG_SPEC[] =	"#IG_Team_Select_Spect";
const iMaxLen = sizeof(INGAME_JOIN_MSG_SPEC);

// New VGUI Menus
stock const VGUI_JOIN_TEAM_NUM =		2;

// ===============================================================================
// 	Models/Sounds Stuff (CHANGE IF YOU WANT)
// ===============================================================================
//Sounds for joker's knife
new g_szJokerSlash[][] =
{
	"hidden-mod/joker_slash1.wav",
	"hidden-mod/joker_slash2.wav",
	"hidden-mod/joker_slash3.wav"
}

new g_szJokerHit[][] =
{
	"hidden-mod/joker_slash_hit1.wav",
	"hidden-mod/joker_slash_hit2.wav",
	"hidden-mod/joker_slash_hit3.wav"
}

//Sounds when joker kills human
new g_szJokerKill[][] =
{
	"hidden-mod/joker_laugh1.wav",
	"hidden-mod/joker_laugh2.wav",
	"hidden-mod/joker_laugh3.wav"
}
//Speak Joker Sounds
new g_szJokerSpeak[][] =
{
	"hidden-mod/hidden_speak1.wav",
	"hidden-mod/hidden_speak2.wav",
	"hidden-mod/hidden_speak3.wav",
	"hidden-mod/hidden_speak4.wav",
	"hidden-mod/hidden_speak5.wav",
	"hidden-mod/hidden_speak6.wav",
	"hidden-mod/hidden_speak7.wav"
}
//When Joker Dies Sounds
new g_szJokerDie[][] =
{
	"hidden-mod/joker_death.wav"
}
//Joker Model
new g_szJokerModel[][] =
{
	"models/player/hm_joker/hm_joker.mdl"
}

//Joker Knife Model
new VIEW_MODELT[]	= "models/hidden-mod/v_joker_knife.mdl"
new PLAYER_MODELT[]	= "models/hidden-mod/p_joker_knife.mdl"

// ===============================================================================
// 	Stuff KnifeMod
// ===============================================================================
/* Booleans / Integers */
new menu1
new menu2
new knifes
new axe[33]
new combat[33]
new hammer[33]
new strong[33]
new defaul[33]

/* Cvar Integers */
new knife_hp, knife_grav1, knife_dam, knife_speed, knife_grav2

/* Model / Sounf Stuff (CHANGE IF YOU WANT) */
new VIEW_AXE[]		= "models/hidden-mod/v_axe_knife.mdl"
new PLAYER_AXE[]	= "models/hidden-mod/p_axe_knife.mdl"

new VIEW_COMBAT[]	= "models/hidden-mod/v_combat_knife.mdl"
new PLAYER_COMBAT[]	= "models/hidden-mod/p_combat_knife.mdl"

new VIEW_STRONG[]	= "models/hidden-mod/v_strong_knife.mdl"
new PLAYER_STRONG[]	= "models/hidden-mod/p_strong_knife.mdl"

new VIEW_HAMMER[]	= "models/hidden-mod/v_hammer_knife.mdl"
new PLAYER_HAMMER[]	= "models/hidden-mod/p_hammer_knife.mdl"

new VIEW_DEFAULT[]	= "models/v_knife.mdl"
new PLAYER_DEFAULT[]	= "models/p_knife.mdl"

// ===============================================================================
// 	The Main Brain
// ===============================================================================
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
	RegisterHam(Ham_Touch, "armoury_entity", "FakemetaTouch")
	RegisterHam(Ham_Touch, "weaponbox", "FakemetaTouch")
	RegisterHam(Ham_TakeDamage, "player", "FwdTakeDamage", 0)
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1")
	register_event("DeathMsg", "Event_DeathMsg", "a")
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	
	register_message(get_user_msgid("VGUIMenu"), "message_VGUIMenu")
	
	register_forward(FM_EmitSound, "Forward_EmitSound")
	register_forward(FM_ClientKill, "Forward_ClientKill")
	
	msgScreenFade = get_user_msgid("ScreenFade")
	sync_hud1 = CreateHudSyncObj(6)
	
	//COMMANDS
	register_clcmd("chooseteam", "jointeam")
	register_clcmd("jointeam", "jointeam")
	register_clcmd("joinclass", "jointeam")
	register_clcmd("say /shop", "cmd_shop")
	register_clcmd("say /hidden", "cmd_menu")
	register_clcmd("say /guns", "cmd_knifes")
	register_clcmd("say /fixspawn", "cmd_fixspawn")
	register_clcmd("say_team /shop", "cmd_shop")
	register_clcmd("say_team /hidden", "cmd_menu")
	register_clcmd("say_team /guns", "cmd_knifes")
	register_clcmd("say_team /fixspawn", "cmd_fixspawn")

	//Remove Shadow // Thanks to connormcleod
	set_msg_block(get_user_msgid("ShadowIdx"), BLOCK_SET);

	//CVARS
	//Jokers Cvars
	p_jokerhp = register_cvar("hm_joker_hp", "200")
	p_jokerspeed = register_cvar("hm_joker_speed", "350.0")
	p_jokerarmor = register_cvar("hm_joker_armor", "500.0")
	p_jokergravity = register_cvar("hm_joker_gravity", "0.7")
	p_jokerinvis = register_cvar("hm_joker_invisibility", "30")
	p_seconds = register_cvar("hm_joker_seconds_to_be_full_invisible", "60")
	p_jokersilent = register_cvar("hm_joker_silent_steps", "0")
	//Human Cvars
	p_humanhp = register_cvar("hm_human_hp", "30")
	p_humanarmor = register_cvar("hm_human_armor", "0")
	p_humanspeed = register_cvar("hm_hmuan_speed", "250")
	p_humangravity = register_cvar("hm_human_gravity", "1.0")
	p_humansilent = register_cvar("hm_human_silent_steps", "0")
	//Fog Cvars
	p_fogenable = register_cvar("hm_enable_fog", "0")
	p_fogr = register_cvar("hm_fog_red_color", "255")
	p_fogg = register_cvar("hm_fog_green_color", "255")
	p_fogb = register_cvar("hm_fog_blue_color", "255")
	p_fogdens = register_cvar("hm_fog_density", "2")
	//Shop 	Cavrs
	p_shop = register_cvar("hm_shop", "0")
	p_shophp = register_cvar("hm_shop_hp_ammout", "255")
	p_shopthp = register_cvar("hm_shop_hp_joker_ammount", "600")
	p_shopgravity = register_cvar("hm_shop_gravity_ammount", "0.6")
	p_shoparmor = register_cvar("hm_shop_armor_ammount", "200")
	p_shopmaxjumps = register_cvar("hm_shop_max_jumps", "2")
	p_shopspeed = register_cvar("hm_shop_speed_ammount", "450.0")
	p_hpcost = register_cvar("hm_shop_hp_cost", "4000")
	p_hptcost = register_cvar("hm_shop_hp_joker_cost", "5000")
	p_gravcost = register_cvar("hm_shop_gravity_cost", "7000")
	p_armorcost = register_cvar("hm_shop_armor_cost", "5000")
	p_speedcost = register_cvar("hm_shop_speed_cost", "8000")
	p_multicost = register_cvar("hm_shop_multijump_cost", "8000")
	p_multitcost = register_cvar("hm_shop_multijump_joker_cost", "10000")
	p_akmcost = register_cvar("hm_shop_ak_and_m4_cost", "9000")
	p_damcost = register_cvar("hm_shop_double_damage_cost", "10000")
	p_damtcost = register_cvar("hm_shop_double_damage_joker_cost", "13000")
	//Knife Mod Cvars
	knife_hp = register_cvar("hm_knife_hp_add", "0")
	knife_grav1 = register_cvar("hm_knife_gravity_combat", "1.0")
	knife_grav2 = register_cvar("hm_knife_gravity_default", "1.0")
	knife_speed = register_cvar("hm_knife_speed", "250.0")
	knife_dam = register_cvar("hm_knife_damage_multi", "1.5")
	p_vipknife = register_cvar("hm_vip_knife", "1")
	//Unlock Prices
	p_unlock = register_cvar("hm_unlock_system", "0")
	p_unlm4 = register_cvar("hm_unlock_m4a1", "8000")
	p_unlak = register_cvar("hm_unlock_ak47", "8000")
	p_unlgal = register_cvar("hm_unlock_galil", "6000")
	p_unlawp = register_cvar("hm_unlock_awp", "7000")
	p_unlp90 = register_cvar("hm_unlock_p90", "10000")
	p_unldgl = register_cvar("hm_unlock_deagle", "5000")
	p_unldual = register_cvar("hm_unlock_dualelites", "4000")
	p_unlaxe = register_cvar("hm_unlock_axe_knife", "3000")
	p_unlstrong = register_cvar("hm_unlock_strong_knife", "3500")
	p_unlcombat = register_cvar("hm_unlock_combat_knife", "3500")
	//Weather Effects Cvars
	p_effects = register_cvar("hm_weather_effects", "0") // 0 disabled, 1 earthquake ,2 fade screem, 3 both
	p_time = register_cvar("hm_countdown_time", "7") 
	p_huds = register_cvar("hm_hudmessages", "1")
	p_newinvis = register_cvar("hm_new_invisibility_system", "1")	

	//CONFIGURATION FILE FOR CVARS
	new configsDir[64];
	get_localinfo("amxx_configsdir", configsDir, charsmax(configsDir))
	server_cmd("exec %s/hiddenmod.cfg", configsDir)
}

public plugin_precache()
{
	register_forward(FM_Spawn, "fwdSpawn", 0);
	
	new allocHostageEntity = engfunc(EngFunc_AllocString, "hostage_entity");
	do
	{
		g_HostageEnt = engfunc(EngFunc_CreateNamedEntity, allocHostageEntity);
	}
	while( !pev_valid(g_HostageEnt) );
	
	engfunc(EngFunc_SetOrigin, g_HostageEnt, Float:{0.0, 0.0, -55000.0});
	engfunc(EngFunc_SetSize, g_HostageEnt, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
	dllfunc(DLLFunc_Spawn, g_HostageEnt);
	
	static i
	
	//General Sounds
	//Knife Sounds
	for (i=0; i<sizeof g_szJokerHit; i++) 	precache_sound(g_szJokerHit[i])
	for (i=0; i<sizeof g_szJokerSlash; i++) 	precache_sound(g_szJokerSlash[i])
	//When Joker Kill sounds
	for (i=0; i<sizeof g_szJokerKill; i++) 	precache_sound(g_szJokerKill[i])
	//Player Spawn Sounds
	for (i=0; i<sizeof g_szJokerSpeak; i++) 	precache_sound(g_szJokerSpeak[i])	
	//When Joker Dies sound
	for (i=0; i<sizeof g_szJokerDie; i++) 	precache_sound(g_szJokerDie[i])
	//Joker Model
	for (i=0; i<sizeof g_szJokerModel; i++) 	precache_model(g_szJokerModel[i])
	
	//Models
	//Knife for humans/jokers
	precache_model(VIEW_MODELT)
	precache_model(PLAYER_MODELT)
	precache_model(VIEW_AXE)
	precache_model(PLAYER_AXE)
	precache_model(VIEW_STRONG)
	precache_model(PLAYER_STRONG)
	precache_model(VIEW_COMBAT)
	precache_model(PLAYER_COMBAT)
	precache_model(VIEW_HAMMER)
	precache_model(PLAYER_HAMMER)
	
	precache_sound("hidden-mod/5.wav")
	precache_sound("hidden-mod/4.wav")
	precache_sound("hidden-mod/3.wav")
	precache_sound("hidden-mod/2.wav")
	precache_sound("hidden-mod/1.wav")
	
}

public pfn_keyvalue( iEnt ) 
{
	new szClassName[32], szCrap[2]
	copy_keyvalue(szClassName, charsmax(szClassName), szCrap, charsmax(szCrap), szCrap, charsmax(szCrap)) 
	if( equal(szClassName, "info_map_parameters") )
	{
		remove_entity(iEnt)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
//Remove Entities
public fwdSpawn(ent)
{
	if( !pev_valid(ent) || ent == g_HostageEnt )
	{
		return FMRES_IGNORED;
	}
	
	new sClass[32];
	pev(ent, pev_classname, sClass, 31);
	
	for( new i = 0; i < MAX_REMOVED_ENTITIES; i++ )
	{
		if( equal(sClass, g_sRemoveEntities[i]) )
		{
			engfunc(EngFunc_RemoveEntity, ent);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED
}

public message_VGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != VGUI_JOIN_TEAM_NUM)
	{
		return PLUGIN_CONTINUE;
	}
	set_autojoin_task(id, iMsgid)
	return PLUGIN_HANDLED;
}

public task_Autojoin(iParam[], id)
{
	new iMsgBlock = get_msg_block(iParam[0]);
	set_msg_block(iParam[0], BLOCK_SET);
	new players[32], pnum 
	get_players(players, pnum, "ace", "TERRORIST");
	if(pnum == 0)
	{
		engclient_cmd(id, "jointeam", "1")
		engclient_cmd(id, "joinclass", "1")
		if(is_user_alive(id))
		{	
			user_silentkill(id)
		}
		set_task(3.0, "respawn", id)
		client_printc(id, "%s You will be respawned in 3 seconds", saychatprefix)
	}
	else
	{
		engclient_cmd(id, "jointeam", "2")
		engclient_cmd(id, "joinclass", "2")
		if(is_user_alive(id))
		{	
			user_silentkill(id)
		}
		set_task(3.0, "respawn", id)
		client_printc(id, "%s You will be respawned in 3 seconds", saychatprefix)
	}
	set_msg_block(iParam[0], iMsgBlock)
}

public jointeam(id)
	return PLUGIN_HANDLED	
	
public cmd_fixspawn(id)
{
	if(!is_user_alive(id))
	{
		user_silentkill(id)
		set_task(1.0, "respawn", id)
	}
}

//No Kill
public Forward_ClientKill(id)
{
	if( !is_user_alive(id) )
	return FMRES_IGNORED

	client_printc(id, "%s You !gcan't kill !nyourself!!!", saychatprefix)
	return FMRES_SUPERCEDE
}

public Event_DeathMsg()
{	
	new iKiller = read_data(1)
	new iVictim = read_data(2)
	
	new killername[33], victimname[33]
	get_user_name(iKiller,killername,32)
	get_user_name(iVictim,victimname,32)

	if(iKiller == iVictim)
	{
		set_task(3.0, "respawn", iKiller)
		client_printc(iKiller, "%s You will be respawned in 3 seconds", saychatprefix)
		return PLUGIN_HANDLED
	}	
	
	switch(cs_get_user_team(iKiller))
	{
		case CS_TEAM_T:
		{
			if(get_pcvar_num(p_huds) == 1)
			{
				set_hudmessage(0, 255, 0, 0.05, 0.3, 0, 6.0, 8.0)
				ShowSyncHudMsg(0, sync_hud1, "[Joker] %s - Killed - [Human] %s",killername,victimname)
			}
			
			if(get_pcvar_num(p_effects) == 1 || get_pcvar_num(p_effects) == 3)
			{
				Util_ScreenShake(iKiller, 6.0, 256.0, 16.0)
			}
			
			client_printc(0, "%s !g[Joker] !n%s - Killed - !g[Human] !n%s", saychatprefix, killername, victimname)
			new rand = random_num(1,3)
			switch(rand)
			{
				case 1: client_cmd(0, "spk hidden-mod/joker_laugh1")
				case 2: client_cmd(0, "spk hidden-mod/joker_laugh2")
				case 3: client_cmd(0, "spk hidden-mod/joker_laugh3")
			}
			
			g_TimerInvisible = 0
			invis_count()
			set_task(3.0, "respawn", iVictim)
			client_printc(iVictim, "%s You will be respawned in 3 seconds", saychatprefix)
			set_task(0.1, "give_screenfade", iKiller)
		}
		case CS_TEAM_CT:
		{
			if(get_pcvar_num(p_huds) == 1)
			{
				set_hudmessage(0, 255, 0, 0.05, 0.3, 0, 6.0, 8.0)
				ShowSyncHudMsg(0, sync_hud1, "[Human] %s - Killed - [Joker] %s",killername,victimname)
			}
			
			if(get_pcvar_num(p_effects) == 1)
			{
				Util_ScreenShake(iKiller, 6.0, 256.0, 16.0)
			}
			else if(get_pcvar_num(p_effects) == 2)
			{
				screenfade(iKiller, 255, 0, 0, 25)
			}
			else if(get_pcvar_num(p_effects) == 3)
			{
				Util_ScreenShake(iKiller, 6.0, 256.0, 16.0)
				screenfade(iKiller, 255, 0, 0, 25)
			}
			
			client_printc(0, "%s !g[Human] !n%s - Killed - !g[Joker] !n%s", saychatprefix, killername, victimname)
			NRTS[iKiller] = true;
			NRTS[iVictim] = true;
			set_task(1.0, "Change_Teams", iVictim)
			client_cmd(0, "spk hidden-mod/joker_death")
			timer = get_pcvar_num(p_time)
			countdown()
		}
	}
	return PLUGIN_HANDLED
} 

public countdown() 
{ 
	if( timer == 5 )
		set_task(0.1, "countdown2")	
	if( timer <= 0 ) 
	{ 
		set_hudmessage( 0, 255, 0, -1.0, 0.50, 2, 5.0, 8.0, 0.0, 0.0) 
		show_hudmessage( 0, "The joker is coming!!!")
		new players[32], pnum, tempid 
		get_players(players, pnum, "ace", "CT");  
		for( new i = 0; i<pnum; i++ )  
		{  
			tempid = players[i]
			set_task(1.0, "Change_Teams", tempid)
		}
	} 
	else 
	{ 
		client_print(0, print_center, "The next joker will be in %i seconds", timer)
		timer-- 
		set_task(1.0, "countdown", 6875)	
	} 
}

public countdown2()
{
	set_task(1.0, "five")
	set_task(2.0, "four")
	set_task(3.0, "three")
	set_task(4.0, "two")
	set_task(5.0, "one")
}

public five()
{
	client_cmd(0, "spk hidden-mod/5")
}

public four()
{
	client_cmd(0, "spk hidden-mod/4")
}

public three()
{
	client_cmd(0, "spk hidden-mod/3")
}

public two()
{
	client_cmd(0, "spk hidden-mod/2")
}

public one()
{
	client_cmd(0, "spk hidden-mod/1")
}

public FakemetaTouch(ent, id)
{
	if (is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_T )
		return HAM_SUPERCEDE
	return HAM_IGNORED
} 

public Change_Teams(id)
{
	if(NRTS[id])
	{
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_CT: 
			{
				cs_set_user_team(id, CS_TEAM_T);
				client_printc(id, "%s You are now !tJoker!", saychatprefix)
				set_task(0.1, "respawn", id)
			}
			case CS_TEAM_T: 
			{
				cs_set_user_team(id, CS_TEAM_CT);
				client_printc(id, "%s You are now !tHuman!", saychatprefix)
				set_task(0.1, "respawn", id)
			}
		}
	}
}  

public respawn(id)
{
	if(is_user_connected(id))
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id)
	}
}

public ApplyHumanStuff(id)
{	
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	
	//Primary / Special Features
	set_user_footsteps(id, get_pcvar_num(p_humansilent))
	set_user_health(id, get_pcvar_num(p_humanhp))
	set_user_armor(id, get_pcvar_num(p_humanarmor))
	set_user_maxspeed(id, get_pcvar_float(p_humanspeed))
	set_user_gravity(id, get_pcvar_float(p_humangravity))
	//Reset The Invisibility From Joker
	set_user_rendering(id, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, 255)
	
	HasSpeed[id] = true
	is_joker[id] = false
	
	//Open Guns' Menu
	cmd_knifes(id)
	
	return PLUGIN_HANDLED
}

public ApplyJokerStuff(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	// Primary
	set_lights("f")
	//Set The Joker Model
	cs_set_user_model(id, "hm_joker")
	//Set The Joker's Knife Model 
	set_pev(id, pev_viewmodel2, VIEW_MODELT)
	set_pev(id, pev_weaponmodel2, PLAYER_MODELT)
	//Set Some Special Features
	set_user_health(id, get_pcvar_num(p_jokerhp))
	set_user_gravity(id, get_pcvar_float(p_jokergravity))
	set_user_footsteps(id, get_pcvar_num(p_jokersilent))
	set_user_armor(id, get_pcvar_num(p_jokerarmor))
	//Some Delay About Speed
	set_task(2.0, "set_speed", id)
	HasSpeed[id] = true
	
	//Spawn Sound
	client_cmd(0, "spk %s", g_szJokerSpeak[random(sizeof g_szJokerSpeak - 1)]) 
	
	//Start The Invisible CountDown
	g_TimerInvisible = 0
	invis_count()
	
	// Secondary, ScreenFade(like in CSO)
	set_task(0.1, "give_screenfade", id)
	
	//Save team to an integer to be able to check it on client_disconnect
	is_joker[id] = true
	
	return PLUGIN_HANDLED
}


public give_screenfade(id)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0, 0, 0}, id)
	write_short(~0)
	write_short(~0)
	write_short(0x0004) // stay faded
	write_byte(54)
	write_byte(44)
	write_byte(97)
	write_byte(100)
	message_end()
}

public set_speed(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
	else
		set_user_maxspeed(id, get_pcvar_float(p_jokerspeed))
	
	return PLUGIN_HANDLED
}

/*
Let's explain how this going to work...
First we give 0 to g_TimerIvisible which means will start the countdown.
Second because the invisibility will change each second it will be +4.2%
So As it is 0 the 0 + (g_TimerInvisible*(255/60)) = 0
So it will add 1 to g_TimerInvisible and set_task to 1.0(so the next second the visibility of the joker will add by 4.2%
So as the g_TimerInvisible will be 1 the 0 + (g_TimerInvisible*(255/60)) == 4.2...
*/
public invis_count() 
{ 
	if(g_TimerInvisible >= 60)
	{
		new players[32], pnum, tempid 
		get_players(players, pnum, "ae", "TERRORIST");
		for( new i = 0; i<pnum; i++ )  
		{  
			tempid = players[i];
			if(get_pcvar_num(p_newinvis) == 1)
			{
				set_user_rendering(tempid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255)
			}
			else
			{
				set_user_rendering(tempid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255*get_pcvar_num(p_jokerinvis)/100)
			}
		}
	}
	else
	{
		new players[32], pnum, tempid 
		get_players(players, pnum, "ae", "TERRORIST");
		for( new i = 0; i<pnum; i++ )  
		{  
			tempid = players[i];
			if(get_pcvar_num(p_newinvis) == 1)
			{
				/* We need a first value which is the 0
				After that we will divide the 255(which is the full visibility) with the seconds we want to get the Joker Full Invisible.
				After this we will multiply the previous value with the g_TimerInvisible so the final value will change each second
				*/
				set_user_rendering(tempid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0 + (g_TimerInvisible*(255/get_pcvar_num(p_seconds))))
			}
			else
			{
				set_user_rendering(tempid, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255*get_pcvar_num(p_jokerinvis)/100)
			}
		}
		g_TimerInvisible++
		set_task(1.0, "invis_count", 6875)
	}
}
  	
public FwdTakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{
	if(is_valid_player(attacker) && get_user_weapon(attacker) == CSW_KNIFE)	
	{
		switch(get_user_team(attacker))
		{
			case 1:
			{
				SetHamParamFloat(4, damage * 2);
			}
			case 2:
			{
				if(HasDamage[attacker])
				{    
					SetHamParamFloat(4, damage * 2);
				}
				if(strong[attacker])
				{
					SetHamParamFloat(4, damage * get_pcvar_float(knife_dam))
				}
			}
		}
	}
	return HAM_HANDLED
}

public client_putinserver(id)
{
	jumpnum[id] = 0
	dojump[id] = false
}

public PlayerInfo(id)
{
	if(is_user_alive(id))
	{
		new h = get_user_health(id)
		new s = get_user_armor(id)
		new e = cs_get_user_money(id)
		
		switch(cs_get_user_team(id))
		{	
			case CS_TEAM_CT:
			{
				
				set_hudmessage(0, 0, 255, 0.27, 0.87, 0, 6.0, 1.0)
				show_hudmessage(id, "HP: %i | AP: %i | CLASS: HUMAN | MONEY: %i", h,s,e)
				
			}
			case CS_TEAM_T:
			{
				set_hudmessage(255, 0, 0, 0.27, 0.87, 0, 6.0, 1.0)
				show_hudmessage(id, "HP: %i | AP: %i | CLASS: JOKER | MONEY: %i", h,s,e)
			}
		}
	}
}

public client_disconnect(id)
{
	jumpnum[id] = 0
	dojump[id] = false
	//Check If the Disconnected Player was Joker
	if(is_joker[id])
	{
		client_printc(0, "%s !gJoker !nhas left! !tA random CT Will Replace Him!n!", saychatprefix)
		static g_iPlayer; 
		g_iPlayer = GetRandomCTiPlayer()
		if(g_iPlayer > 0)
		{
			cs_set_user_team(g_iPlayer, CS_TEAM_T)
			set_task(0.1, "respawn", g_iPlayer)
		}
	}
}

GetRandomCTiPlayer() 
{
	static iPlayers[32], iNum;
	get_players(iPlayers, iNum, "ae", "CT"); 
	return iNum ? iPlayers[random(iNum)] : 0;
}

public client_PreThink(id)
{
	if(HasMulti[id] && is_user_alive(id))
	{
		new nbut = get_user_button(id)
		new obut = get_user_oldbutton(id)
		if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
		{
			if(jumpnum[id] < get_pcvar_num(p_shopmaxjumps))
			{
				dojump[id] = true
				jumpnum[id]++
				return PLUGIN_CONTINUE
			}
		}
		if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
		{
			jumpnum[id] = 0
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(HasMulti[id])
	{
		if(dojump[id])
		{
			new Float:velocity[3]	
			entity_get_vector(id,EV_VEC_velocity,velocity)
			velocity[2] = random_float(265.0,285.0)
			entity_set_vector(id,EV_VEC_velocity,velocity)
			dojump[id] = false
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public CurWeapon(id)
{
	new weaponID = read_data(2)

	if(is_user_alive(id))
	{			
		switch(cs_get_user_team(id))
		{
			case CS_TEAM_T:
			{
				if(weaponID == CSW_KNIFE)
				{
					set_pev(id, pev_viewmodel2, VIEW_MODELT)
					set_pev(id, pev_weaponmodel2, PLAYER_MODELT)
				}
				if(HasSpeed[id])
				{	
					set_user_maxspeed(id, get_pcvar_float(p_jokerspeed))
				}
			}
			case CS_TEAM_CT:
			{
				if(weaponID == CSW_KNIFE && strong[id])
				{
					set_pev(id, pev_viewmodel2, VIEW_STRONG)
					set_pev(id, pev_weaponmodel2, PLAYER_STRONG)
				}
				if(weaponID == CSW_KNIFE && combat[id])
				{
					set_pev(id, pev_viewmodel2, VIEW_COMBAT)
					set_pev(id, pev_weaponmodel2, PLAYER_COMBAT)
				}
				if(weaponID == CSW_KNIFE && axe[id])
				{
					set_pev(id, pev_viewmodel2, VIEW_AXE)
					set_pev(id, pev_weaponmodel2, PLAYER_AXE)
				}
				if(weaponID == CSW_KNIFE && defaul[id])
				{
					set_pev(id, pev_viewmodel2, VIEW_DEFAULT)
					set_pev(id, pev_weaponmodel2, PLAYER_DEFAULT)
				}
				if(weaponID == CSW_KNIFE && hammer[id])
				{
					set_pev(id, pev_viewmodel2, VIEW_HAMMER)
					set_pev(id, pev_weaponmodel2, PLAYER_HAMMER)
					set_user_maxspeed(id, get_pcvar_float(knife_speed))
				}
				else if(HasSpeed[id])
				{	
					set_user_maxspeed(id, get_pcvar_float(p_humanspeed))
				}
				else if(HasShopSpeed[id])
				{
					set_user_maxspeed(id, get_pcvar_float(p_shopspeed))
				}
			}
		}
	} 
	return PLUGIN_HANDLED
}

public Forward_EmitSound(id,channel,const sample[],Float:volume,Float:attn,flags,pitch)
{
	if (!is_user_connected(id))
		return FMRES_IGNORED;
	
	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if (equal(sample[8], "kni", 3))
		{
			if (equal(sample[14], "sla", 3)) 
			{
				emit_sound(id,channel,g_szJokerSlash[random(sizeof g_szJokerSlash - 1)],volume,attn,flags,pitch)
				return FMRES_SUPERCEDE;
			}
			if (equal(sample[14], "hit", 3) || equal(sample[14], "sta", 3)) // hit & Stab
			{
				emit_sound(id,channel,g_szJokerHit[random(sizeof g_szJokerHit - 1)],volume,attn,flags,pitch)
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

public PlayerSpawn(id)
{
	if( !is_user_alive( id ) )
	return HAM_IGNORED;
	
	//Firstly Reset The Bools
	NRTS[id] = false
	jumpnum[id] = 0
	dojump[id] = false
	HasDamage[id] = false
	HasGravity[id] = false
	HasMulti[id] = false
	HasShopSpeed[id] = false
	HasSpeed[id] = false
	knifes_used[id] = false
	prima_used[id] = false
	second_used[id] = false
	
	//Secondly Set The HUD Bar
	set_task(0.1, "PlayerInfo", id, _, _, "b")
	
	//Thirdly, Strip All Weapons
	strip_user_weapons(id)
	give_item( id, "weapon_knife" )
	
	//Finally Give Some Special Features
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T: 		
		{
			set_task(0.2, "ApplyJokerStuff", id)
		}
		case CS_TEAM_CT: 	
		{
			set_task(0.2, "ApplyHumanStuff", id)
		}
	}
	
	//Spam Message :P
	client_printc(id, "%s !g****Welcome to Hidden Mod****", saychatprefix)
	
	return HAM_IGNORED;
}

public event_newround()
{
	if(get_pcvar_num(p_fogenable) == 1)
	{
		create_fog(get_pcvar_num(p_fogr), get_pcvar_num(p_fogg), get_pcvar_num(p_fogb), get_pcvar_num(p_fogdens))
	}
}

public cmd_menu(id)
{
	new menu3 = menu_create("[Hidden-Mod] Menu:","cmd_hidden_handler")
	
	if(cs_get_user_team(id) == CS_TEAM_CT) 
	{
		menu_additem(menu3, "Select Guns/Knifes","1",0)
	}
	else 
	{
		menu_additem(menu3, "\dSelect Guns/Knifes","1",0)
	}
	
	menu_additem(menu3, "\rExtra Items","2",0)
	menu_additem(menu3, "\yInformation","3",0)
	
	if(get_user_flags(id) & ADMIN_LEVEL_A)
	{
		menu_additem(menu3, "Transfer Menu","4",0)
	}
	else 
	{
		menu_additem(menu3, "\dTransfer Menu","4",0)
	}
	
	menu_setprop(menu3, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu3, 0)
	return PLUGIN_HANDLED
}

public cmd_hidden_handler(id, menu3, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu3);
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu3, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);
	switch(key)
	{
		case 1:
		{
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				cmd_knifes(id)
			}
			else
			{
				client_printc(id, "%sYou !gmust !nbe !tCT !nto open this menu!", saychatprefix)
			}
		}
		case 2:
		{
			cmd_shop(id)
		}
		case 3:
		{
			show_motd(id, "extras/hidden-mod_help.motd", "[Hidden-Mod]Help Page:");
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_A)
			{
				client_cmd(id, "amx_teammenu")
			}
			else 
			{
				client_printc(id, "%sYou !gmust !nbe an !tAdmin !nto open this menu!", saychatprefix)
			}
		}
	}
	menu_destroy(menu3)
	return PLUGIN_HANDLED
}


public cmd_shop(id)
{
	if(is_user_alive(id))
	{
		if(get_pcvar_num(p_shop) == 1)
		{
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				new shop[101];
	
				new menu = menu_create("\rHidden Mod Shop For Humans:", "humans_handler")
				formatex(shop,100, "%i HP [\r%i\w$]",get_pcvar_num(p_shophp), get_pcvar_num(p_hpcost))
				menu_additem(menu, shop, "1", 0)
				formatex(shop,100, "%i Armor [\r%i\w$]",get_pcvar_num(p_shoparmor), get_pcvar_num(p_armorcost))
				menu_additem(menu, shop, "2", 0)
				formatex(shop,100, "More Speed [\r%i\w$]", get_pcvar_num(p_speedcost))
				menu_additem(menu, shop, "3", 0)
				formatex(shop,100, "Lower Gravity [\r%i\w$]", get_pcvar_num(p_gravcost))
				menu_additem(menu, shop, "4", 0)
				formatex(shop,100, "Multijump [\r%i\w$]", get_pcvar_num(p_multicost))
				menu_additem(menu, shop, "5", 0)
				formatex(shop,100, "M4A1 & AK47 [\r%i\w$]", get_pcvar_num(p_akmcost))
				menu_additem(menu, shop, "6", 0)
				formatex(shop,100, "Double Damage [\r%i\w$]", get_pcvar_num(p_damcost))
				menu_additem(menu, shop, "7", 0)
				menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, menu, 0);
			}
			else if(cs_get_user_team(id) == CS_TEAM_T)
			{
				new shopt[101];
	
				new menu2 = menu_create("\rHidden Mod Shop For Jokers:", "jokers_handler")
				formatex(shopt,100, "%i HP [\r%i\w$]",get_pcvar_num(p_shopthp), get_pcvar_num(p_hptcost))
				menu_additem(menu2, shopt, "1", 0)
				formatex(shopt,100, "Multijump [\r%i\w$]", get_pcvar_num(p_multitcost))
				menu_additem(menu2, shopt, "2", 0)
				formatex(shopt,100, "Double Damage [\r%i\w$]", get_pcvar_num(p_damtcost))
				menu_additem(menu2, shopt, "3", 0)
				menu_setprop(menu2, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, menu2, 0)
			}
		}
		else
		{
			client_printc(id, "%s The !gShop !nhas been !gDisabled", saychatprefix)
		}
	}
}

public jokers_handler(id, menu2, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu2)
		return PLUGIN_HANDLED
	}

	new data[6], szName[64]
	new access, callback
	menu_item_getinfo(menu2, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	switch(key)
	{
		case 1:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_hptcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				set_user_health(id, get_pcvar_num(p_shopthp))
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_hptcost))
				client_printc(id, "%s You bought !gMore HP", saychatprefix)
			}
		}
		case 2:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_multitcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_multitcost))
				HasMulti[id] = true
				client_printc(id, "%s You bought !gMultijump", saychatprefix)
			}
		}
		case 3:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_damtcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_damtcost))
				HasDamage[id] = true
				client_printc(id, "%s You bought !gUnlimited Clip !n on all weapons!", saychatprefix)
			}
		}	
	}
	menu_destroy(menu2)
	return PLUGIN_HANDLED
}

public humans_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], szName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	switch(key)
	{
		case 1:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_hpcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				set_user_health(id, get_pcvar_num(p_shophp))
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_hpcost))
				client_printc(id, "%s You bought !gMore HP", saychatprefix)
			}
		}
		case 2:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_armorcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				set_user_armor(id, get_pcvar_num(p_shoparmor))
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_armorcost))
				client_printc(id, "%s You bought !gMore Armor", saychatprefix)
			}
		}
		case 3:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_speedcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				set_user_maxspeed(id, get_pcvar_float(p_shopspeed))
				HasShopSpeed[id] = true
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_speedcost))
				client_printc(id, "%s You bought !gMore Speed", saychatprefix)
			}
		}
		case 4:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_gravcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				set_user_gravity(id, get_pcvar_float(p_shopgravity))
				HasGravity[id] = true
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_gravcost))
				client_printc(id, "%s You bought !gLower Gravity", saychatprefix)
			}
		}
		case 5:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_multicost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_multicost))
				HasMulti[id] = true
				client_printc(id, "%s You bought !gMultijump", saychatprefix)
			}
		}
		case 6:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_akmcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_akmcost))
				client_printc(id, "%s You bought !gAK47 & M4A1", saychatprefix)
				give_item( id, "weapon_m4a1" );
				cs_set_user_bpammo( id, CSW_M4A1, 90 )
				give_item( id, "weapon_ak47" );
				cs_set_user_bpammo( id, CSW_AK47, 90 )
			}
		}
		case 7:
		{
			if(cs_get_user_money(id) < get_pcvar_num(p_damcost))
			{
				client_printc(id, "%s You have !gnot !n enough money to buy this!", saychatprefix)
			}
			else
			{
				cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_damcost))
				HasDamage[id] = true
				client_printc(id, "%s You bought !gDouble Damage!", saychatprefix)
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public cmd_knifes(id)
{
	if(knifes_used[id])
	{
		client_printc(id, "%s Wait for !tnext round !nto !gopen !nthis menu!", saychatprefix)
		gunsmenu(id)
		return PLUGIN_CONTINUE
	}
	
	knifes = menu_create("[Hidden-Mod] Knifes Menu:","cmd_knifes_handler")
	if(get_pcvar_num(p_unlock) == 1)
	{
		new temp[101]
		if(!itemunlocked[id][8])
		{
			formatex(temp,100, "SkullAxe - HP\y++\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlaxe))
			menu_additem(knifes, temp,"1",0);
		}
		else
		{
			menu_additem(knifes, "SkullAxe - HP\y++","1",0)
		}
	
		if(!itemunlocked[id][9])
		{
			formatex(temp,100, "Combat - Gravity\y--\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlcombat))
			menu_additem(knifes, temp,"2",0)
		}
		else
		{
			menu_additem(knifes, "Combat - Gravity\y--","2",0)
		}
		
		if(!itemunlocked[id][7])
		{
			formatex(temp,100, "Katana - Damage\y++\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlstrong))
			menu_additem(knifes, temp,"3",0);
		}
		else
		{
			menu_additem(knifes, "Katana - Damage\y++","3",0)
		}
	}
	else
	{
		menu_additem(knifes, "SkullAxe - HP\y++","1",0)
		menu_additem(knifes, "Combat - Gravity\y--","2",0)
		menu_additem(knifes, "Katana - Damage\y++","3",0)
	}
	
	if(get_pcvar_num(p_vipknife) == 1)
	{
		
		if(get_user_flags(id) & VIP_FLAG) 
		{
			menu_additem(knifes, "Balisong - Speed\y++","4",0)
		}
		else 
		{
			menu_additem(knifes, "\dBalisong - Speed++ - VIP ONLY","4",0)
		}
	}
	else
	{
		menu_additem(knifes, "Balisong - Speed\y++","4",0)
	}
	
	menu_additem(knifes, "Default Knife - Gravity\y-","5",0)
	menu_setprop(knifes, MPROP_EXIT, MEXIT_ALL)
	
	if(cs_get_user_team(id) == CS_TEAM_CT) 
	{
		menu_display(id, knifes, 0)
	}
	
	return PLUGIN_HANDLED
}

public cmd_knifes_handler(id, knifes, item)
{
	if( item == MENU_EXIT)
	{
		menu_destroy(knifes)
		return PLUGIN_HANDLED
	}
	
	new data[6], szName[64]
	new access, callback
	menu_item_getinfo(knifes, item, access, data,charsmax(data), szName,charsmax(szName), callback)
	new key = str_to_num(data)
	switch(key)
	{
		case 1:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][8])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlaxe))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						cmd_knifes(id)
						
					}
					else
					{
						axe[id] = true
						combat[id] = false
						strong[id] = false
						hammer[id] = false
						defaul[id] = false
						knifes_used[id] = true
						set_pev(id, pev_viewmodel2, VIEW_AXE)
						set_pev(id, pev_weaponmodel2, PLAYER_AXE)
						set_user_health(id, get_user_health(id) + get_pcvar_num(knife_hp))
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlaxe))
						itemunlocked[id][8] = true
						gunsmenu(id)
					}
				}
				else
				{
					axe[id] = true
					combat[id] = false
					strong[id] = false
					hammer[id] = false
					defaul[id] = false
					knifes_used[id] = true
					set_pev(id, pev_viewmodel2, VIEW_AXE)
					set_pev(id, pev_weaponmodel2, PLAYER_AXE)
					set_user_health(id, get_user_health(id) + get_pcvar_num(knife_hp))
					gunsmenu(id)
				}
			}
			else
			{
				axe[id] = true
				combat[id] = false
				strong[id] = false
				hammer[id] = false
				defaul[id] = false
				knifes_used[id] = true
				set_pev(id, pev_viewmodel2, VIEW_AXE)
				set_pev(id, pev_weaponmodel2, PLAYER_AXE)
				set_user_health(id, get_user_health(id) + get_pcvar_num(knife_hp))
				gunsmenu(id)
			}
		}
		case 2:
		{
			if(axe[id])
			{
				set_user_health(id, get_user_health(id) - get_pcvar_num(knife_hp))
			}
			
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][9])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlcombat))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						cmd_knifes(id)
					}
					else
					{
						axe[id] = false
						combat[id] = true
						strong[id] = false
						hammer[id] = false
						defaul[id] = false
						knifes_used[id] = true
						set_pev(id, pev_viewmodel2, VIEW_COMBAT)
						set_pev(id, pev_weaponmodel2, PLAYER_COMBAT)
						set_user_gravity(id, get_pcvar_float(knife_grav1))
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlcombat))
						itemunlocked[id][9] = true
						gunsmenu(id)
					}
				}
				else
				{
					axe[id] = false
					combat[id] = true
					strong[id] = false
					hammer[id] = false
					defaul[id] = false
					knifes_used[id] = true
					set_pev(id, pev_viewmodel2, VIEW_COMBAT)
					set_pev(id, pev_weaponmodel2, PLAYER_COMBAT)
					set_user_gravity(id, get_pcvar_float(knife_grav1))
					gunsmenu(id)
				}
			}
			else
			{
				axe[id] = false
				combat[id] = true
				strong[id] = false
				hammer[id] = false
				defaul[id] = false
				knifes_used[id] = true
				set_pev(id, pev_viewmodel2, VIEW_COMBAT)
				set_pev(id, pev_weaponmodel2, PLAYER_COMBAT)
				set_user_gravity(id, get_pcvar_float(knife_grav1))
				gunsmenu(id)
			}
		}
		case 3:
		{
			if(axe[id])
			{
				set_user_health(id, get_user_health(id) - get_pcvar_num(knife_hp))
			}
			
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][7])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlstrong))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						cmd_knifes(id)
						
					}
					else
					{
						axe[id] = false
						combat[id] = false
						strong[id] = true
						hammer[id] = false
						defaul[id] = false
						knifes_used[id] = true
						set_pev(id, pev_viewmodel2, VIEW_STRONG)
						set_pev(id, pev_weaponmodel2, PLAYER_STRONG)
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlstrong))
						itemunlocked[id][7] = true
						gunsmenu(id)
					}
				}
				else
				{
					axe[id] = false
					combat[id] = false
					strong[id] = true
					hammer[id] = false
					defaul[id] = false
					knifes_used[id] = true
					set_pev(id, pev_viewmodel2, VIEW_STRONG)
					set_pev(id, pev_weaponmodel2, PLAYER_STRONG)
					gunsmenu(id)
				}
			}
			else
			{
				axe[id] = false
				combat[id] = false
				strong[id] = true
				hammer[id] = false
				defaul[id] = false
				knifes_used[id] = true
				set_pev(id, pev_viewmodel2, VIEW_STRONG)
				set_pev(id, pev_weaponmodel2, PLAYER_STRONG)
				gunsmenu(id)
			}	
		}
		case 4:
		{
			if(get_pcvar_num(p_vipknife) != 1 || get_user_flags(id) & VIP_FLAG)
			{	
				if(axe[id])
				{
					set_user_health(id, get_user_health(id) - get_pcvar_num(knife_hp))
				}
				
				axe[id] = false
				combat[id] = false
				strong[id] = false
				hammer[id] = true
				defaul[id] = false
				knifes_used[id] = true
				set_pev(id, pev_viewmodel2, VIEW_HAMMER)
				set_pev(id, pev_weaponmodel2, PLAYER_HAMMER)
				set_user_maxspeed(id, get_pcvar_float(knife_speed))
				gunsmenu(id)
			}
			else
			{
				client_printc(id, "%sYou must be !tVIP !n to select this !gknife", saychatprefix)
			}
		}
		case 5:
		{
			if(axe[id])
			{
				set_user_health(id, get_user_health(id) - get_pcvar_num(knife_hp))
			}
			
			axe[id] = false
			combat[id] = false
			strong[id] = false
			hammer[id] = false
			defaul[id] = true
			knifes_used[id] = true
			set_pev(id, pev_viewmodel2, VIEW_DEFAULT)
			set_pev(id, pev_weaponmodel2, PLAYER_DEFAULT)
			set_user_gravity(id, get_pcvar_float(knife_grav2))
			gunsmenu(id)
		}
	}
	menu_destroy(knifes)
	return PLUGIN_HANDLED
}

public gunsmenu(id) 
{
	if(prima_used[id])
	{
		client_printc(id, "%s Wait for !tnext round !nto !gopen !nthis menu!", saychatprefix)
		pistolsmenu(id)
		return PLUGIN_CONTINUE
	}
	
	menu1 = menu_create("\wHuman's \yGun \wMenu\r:", "gunsmenu_Handle")
	if(get_pcvar_num(p_unlock) == 1)
	{
		new temp[101];
		if(!itemunlocked[id][0])
		{
			formatex(temp,100, "Maverick - \yM4A1\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlm4))
			menu_additem(menu1, temp,"1",0);
		}
		else
		{
			menu_additem(menu1, "Maverick - \yM4A1" , "1", 0)
		}
		
		if(!itemunlocked[id][1])
		{
			formatex(temp,100, "Kalashnikov - \yAK47\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlak))
			menu_additem(menu1, temp,"2",0);
		}
		else
		{
			menu_additem(menu1, "Kalashnikov - \yAK47" , "2", 0)
		}
		
		if(!itemunlocked[id][4])
		{
			formatex(temp,100, "Magnum Sniper - \yAWP\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlawp))
			menu_additem(menu1, temp,"3",0)
		}
		else
		{
			menu_additem(menu1, "Magnum Sniper - \yAWP" , "3", 0)
		}
		
		if(!itemunlocked[id][3])
		{
			formatex(temp,100, "ES C90 - \yP90\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlp90))
			menu_additem(menu1, temp,"4",0)
		}
		else
		{
			menu_additem(menu1, "ES C90 - \yP90" , "4", 0)
		}
		
		if(!itemunlocked[id][2])
		{
			formatex(temp,100, "IDF Defender - \yGalil\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unlgal))
			menu_additem(menu1, temp,"5",0)
		}
		else
		{
			menu_additem(menu1, "IDF Defender - \yGalil" , "5", 0)
		}
	}
	else
	{	
		menu_additem(menu1, "Maverick - \yM4A1" , "1", 0)
		menu_additem(menu1, "Kalashnikov \yAK47", "2", 0)
		menu_additem(menu1, "Magnum Sniper - \yAWP" , "3", 0)
		menu_additem(menu1, "ES C90 \yP90" , "4", 0)
		menu_additem(menu1, "IDF Defender - \yGalil" , "5", 0)
	}
	
	menu_additem(menu1, "Clarion 5.56 \y(\rFamas\y)", "6", 0)
	menu_additem(menu1, "KM Submachine Gun \y(\rMp5 Navy\y)", "7", 0)
	menu_setprop(menu1, MPROP_EXIT, MEXIT_ALL);
	
	if(cs_get_user_team(id) == CS_TEAM_CT) 
	{
		menu_display(id, menu1, 0)
	}
	
	return PLUGIN_HANDLED
}

public gunsmenu_Handle(id, menu1, item)
{
	if (item == MENU_EXIT || cs_get_user_team(id) != CS_TEAM_CT )
	{
		menu_destroy(menu1)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	
	menu_item_getinfo(menu1, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		case 1:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][0])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlm4))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						gunsmenu(id)
					}
					else
					{
						give_item(id, "weapon_m4a1")
						cs_set_user_bpammo( id, CSW_M4A1, 90 )
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlm4))
						itemunlocked[id][0] = true
						prima_used[id] = true
						pistolsmenu(id)
					}
				}
				else
				{
					give_item(id, "weapon_m4a1")
					cs_set_user_bpammo( id, CSW_M4A1, 90 )
					prima_used[id] = true
					pistolsmenu(id)
				}
			}
			else
			{
				give_item(id, "weapon_m4a1")
				cs_set_user_bpammo( id, CSW_M4A1, 90 )
				prima_used[id] = true
				pistolsmenu(id)
			}
		}
		case 2:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][1])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlak))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						gunsmenu(id)
					}
					else
					{
						give_item(id, "weapon_ak47")
						cs_set_user_bpammo( id, CSW_AK47, 90 )
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlak))
						itemunlocked[id][1] = true
						prima_used[id] = true
						pistolsmenu(id)
					}
				}
				else
				{
					give_item(id, "weapon_ak47")
					cs_set_user_bpammo( id, CSW_AK47, 90 )
					prima_used[id] = true
					pistolsmenu(id)
				}
			}
			else
			{
				give_item(id, "weapon_ak47")
				cs_set_user_bpammo( id, CSW_AK47, 90 )
				prima_used[id] = true
				pistolsmenu(id)
			}
		}
		case 3:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][4])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlawp))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						gunsmenu(id)
					}
					else
					{
						give_item(id, "weapon_awp")
						cs_set_user_bpammo( id, CSW_AWP, 30 )
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlawp))
						itemunlocked[id][4] = true
						prima_used[id] = true
						pistolsmenu(id)
					}
				}
				else
				{
					give_item(id, "weapon_awp")
					cs_set_user_bpammo( id, CSW_AWP, 30 )
					prima_used[id] = true
					pistolsmenu(id)
				}
			}
			else
			{
				give_item(id, "weapon_awp")
				cs_set_user_bpammo( id, CSW_AWP, 30 )
				prima_used[id] = true
				pistolsmenu(id)
			}
		}
		case 4:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][3])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlp90))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						gunsmenu(id)
					}
					else
					{
						give_item(id, "weapon_p90")
						cs_set_user_bpammo( id, CSW_P90, 90 )
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlp90))
						itemunlocked[id][3] = true
						prima_used[id] = true
						pistolsmenu(id)
					}
				}
				else
				{
					give_item(id, "weapon_p90")
					cs_set_user_bpammo( id, CSW_P90, 90 )
					prima_used[id] = true
					pistolsmenu(id)
				}
			}
			else
			{
				give_item(id, "weapon_p90")
				cs_set_user_bpammo( id, CSW_P90, 90 )
				prima_used[id] = true
				pistolsmenu(id)
			}
		}
		case 5:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][2])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unlgal))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						gunsmenu(id)
					}
					else
					{
						give_item(id, "weapon_galil")
						cs_set_user_bpammo( id, CSW_GALIL, 90 )
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unlgal))
						itemunlocked[id][2] = true
						prima_used[id] = true
						pistolsmenu(id)
					}
				}
				else
				{
					give_item(id, "weapon_galil")
					cs_set_user_bpammo( id, CSW_GALIL, 90 )
					prima_used[id] = true
					pistolsmenu(id)
				}
			}
			else
			{
				give_item(id, "weapon_galil")
				cs_set_user_bpammo( id, CSW_GALIL, 90 )
				prima_used[id] = true
				pistolsmenu(id)
			}
		}
		case 6:
		{
			give_item(id, "weapon_famas")
			cs_set_user_bpammo( id, CSW_FAMAS, 90 )
			prima_used[id] = true
			pistolsmenu(id)
		}
		case 7:
		{
			give_item(id, "weapon_mp5navy")
			cs_set_user_bpammo( id, CSW_MP5NAVY, 120 )
			prima_used[id] = true
			pistolsmenu(id)
		}
		
	}
	return PLUGIN_HANDLED;
}

public pistolsmenu(id) 
{
	if(second_used[id])
	{
		client_printc(id, "%s Wait for !tnext round !nto !gopen !nthis menu!", saychatprefix)
		return PLUGIN_CONTINUE
	}
	
	menu2 = menu_create("\wHuman's \yPistols \wMenu\r:", "pistolsmenu_Handle")
	if(get_pcvar_num(p_unlock) == 1)
	{
		new temp[101]
		if(!itemunlocked[id][5])
		{
			formatex(temp,100, "Knighthawk .50C - \yDeagle\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unldgl))
			menu_additem(menu2, temp,"1",0);
		}
		else
		{
			menu_additem(menu2, "Knighthawk .50C - \yDeagle" , "1", 0)
		}
		
		if(!itemunlocked[id][6])
		{
			formatex(temp,100, "Dual Elites\w(\rUnlock \w- \r%i)",get_pcvar_num(p_unldual))
			menu_additem(menu2, temp,"2",0);
		}
		else
		{
			menu_additem(menu2, "Dual Elites" , "2", 0)
		}
	}
	else
	{	
		menu_additem(menu2, "Knighthawk .50C - \yDeagle" , "1", 0)
		menu_additem(menu2, "Dual Elites" , "2", 0)
	}
	menu_additem(menu2, "KM .45 Tactical - \yUsp" , "3", 0)
	menu_additem(menu2, "9x19 mm Sidearm - \yGlock", "4", 0)
	menu_additem(menu2, "228 Compact - \yP228", "5", 0)
	menu_additem(menu2, "FiveSeven", "6", 0)
	menu_setprop(menu2, MPROP_EXIT, MEXIT_ALL)
	
	if(cs_get_user_team(id) == CS_TEAM_CT) 
	{
		menu_display(id, menu2, 0)
	}
	
	return PLUGIN_HANDLED

}

public pistolsmenu_Handle(id, menu2, item)
{
	if (item == MENU_EXIT || cs_get_user_team(id) != CS_TEAM_CT )
	{
		menu_destroy(menu2)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	
	menu_item_getinfo(menu2, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	
	switch(key)
	{
		
		case 1:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][5])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unldgl))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						pistolsmenu(id)
					}
					else
					{
						give_item(id, "weapon_deagle")
						cs_set_user_bpammo( id, CSW_DEAGLE, 35 );
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unldgl))
						itemunlocked[id][5] = true
						second_used[id] = true
					}
				}
				else
				{
					give_item(id, "weapon_deagle")
					cs_set_user_bpammo( id, CSW_DEAGLE, 35 )
					second_used[id] = true
				}
			}
			else
			{
				give_item(id, "weapon_deagle")
				cs_set_user_bpammo( id, CSW_DEAGLE, 35 )
				second_used[id] = true
			}
		}
		case 2:
		{
			if(get_pcvar_num(p_unlock) == 1)
			{
				if(!itemunlocked[id][6])
				{
					if(cs_get_user_money(id) < get_pcvar_num(p_unldual))
					{
						client_printc(id, "%s You have !gno money !nto unlock this!", saychatprefix)
						pistolsmenu(id)
					}
					else
					{
						give_item(id, "weapon_elite")
						cs_set_user_bpammo( id, CSW_ELITE, 120 );
						cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(p_unldual))
						itemunlocked[id][6] = true
						second_used[id] = true
					}
				}
				else
				{
					give_item(id, "weapon_elite")
					cs_set_user_bpammo( id, CSW_ELITE, 120 )
					second_used[id] = true
				}
			}
			else
			{
				give_item(id, "weapon_elite")
				cs_set_user_bpammo( id, CSW_ELITE, 120 )
				second_used[id] = true
			}
		}
		case 3:
		{
			give_item(id, "weapon_usp")
			cs_set_user_bpammo( id, CSW_USP, 90 )
			second_used[id] = true
		}
		case 4:
		{
			give_item(id, "weapon_glock18")
			cs_set_user_bpammo( id, CSW_GLOCK18, 120 )
			second_used[id] = true
		}
		case 5:
		{
			give_item(id, "weapon_p228")
			cs_set_user_bpammo( id, CSW_P228, 52 )
			second_used[id] = true
		}
		
		case 6:
		{
			give_item(id, "weapon_fiveseven")
			cs_set_user_bpammo( id, CSW_FIVESEVEN, 100 )
			second_used[id] = true
		}
	}
	give_item(id, "weapon_flashbang")
	give_item(id, "weapon_smokegrenade")
	give_item(id, "weapon_hegrenade")
	return PLUGIN_CONTINUE;
}

//////////////////////////////////////////////////////////////////
///			STOCKS				       ///
//////////////////////////////////////////////////////////////////

//ColorChat stock
stock client_printc(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^x04") // Green Color
	replace_all(msg, 190, "!n", "^x01") // Default Color
	replace_all(msg, 190, "!t", "^x03") // Team Color
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
}

//Fog stock
stock create_fog( iRed, iGreen, iBlue, iDensity )
{
	// Fog density offsets [Thnx to DA]
	new const fog_density[ ] = { 0, 0, 0, 0, 111, 18, 3, 58, 111, 18, 125, 58, 66, 96, 27, 59, 90, 101, 60, 59, 90,
	101, 68, 59, 10, 41, 95, 59, 111, 18, 125, 59, 111, 18, 3, 60, 68, 116, 19, 60 }
	
	// Get the amount of density
	new dens
	dens = ( 4 * iDensity )

	// The fog message
	message_begin( MSG_BROADCAST, get_user_msgid( "Fog" ), { 0,0,0 }, 0 )
	write_byte( iRed ) // Red
	write_byte( iGreen ) // Green
	write_byte( iBlue ) // Blue
	write_byte( fog_density[ dens ] ) // SD
	write_byte( fog_density[ dens + 1 ] ) // ED
	write_byte( fog_density[ dens + 2 ] ) // D1
	write_byte( fog_density[ dens + 3 ] ) // D2
	message_end( )
}

//ScreenFade
stock screenfade(id,red,green,blue,ammount)
{
	if(ammount>255)ammount=255
	if(red>255)red=255
	if(green>255)green=255
	if(blue>255)blue=255
	//FADE OUT
	message_begin(MSG_ONE_UNRELIABLE, msgScreenFade, {0,0,0}, id)
	write_short(ammount * 100)    //Durration
	write_short(0)       //Hold
	write_short(0)       //Type
	write_byte(red)    //R
	write_byte(green)    //G
	write_byte(blue)   //B
	write_byte(ammount)   //B
	message_end()
}  


// ScreenShake
stock Util_ScreenShake(id, Float:duration, Float:frequency, Float:amplitude)
{
	static ScreenShake = 0
	if( !ScreenShake )
	{
		ScreenShake = get_user_msgid("ScreenShake")
	}	
	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, ScreenShake, _, id)
	write_short( FixedUnsigned16( amplitude, 1<<12 ) ) // shake amount
	write_short( FixedUnsigned16( duration, 1<<12 ) )// shake lasts this long
	write_short( FixedUnsigned16( frequency, 1<<8 ) )// shake noise frequency
	message_end()
}


stock FixedUnsigned16( Float:value, scale )
{
	new output

	output = floatround(value * scale)
	if ( output < 0 )
		output = 0
	if ( output > 0xFFFF )
		output = 0xFFFF

	return output
}

stock set_autojoin_task(id, iMsgid)
{
	new iParam[2];
	iParam[0] = iMsgid;
	set_task(0.1, "task_Autojoin", id, iParam, sizeof(iParam));	
}

stock Thunder( start[ 3 ], end[ 3 ] )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY ); 
	write_byte( TE_BEAMPOINTS ); 
	write_coord( start[ 0 ] ); 
	write_coord( start[ 1 ] ); 
	write_coord( start[ 2 ] ); 
	write_coord( end[ 0 ] ); 
	write_coord( end[ 1 ] ); 
	write_coord( end[ 2 ] ); 
	write_short( g_lightning ); 
	write_byte( 1 );
	write_byte( 5 );
	write_byte( 7 );
	write_byte( 20 );
	write_byte( 30 );
	write_byte( 200 ); 
	write_byte( 200 );
	write_byte( 200 );
	write_byte( 200 );
	write_byte( 200 );
	message_end();
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, end );
	write_byte( TE_SPARKS );
	write_coord( end[ 0 ]  );
	write_coord( end[ 1 ]);
	write_coord( end[ 2 ] );
	message_end();
	
	emit_sound( 0 ,CHAN_ITEM, thunder_sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
}

stock Smoke( iorigin[ 3 ], scale, framerate )
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SMOKE );
	write_coord( iorigin[ 0 ] );
	write_coord( iorigin[ 1 ] );
	write_coord( iorigin[ 2 ] );
	write_short( g_smoke );
	write_byte( scale );
	write_byte( framerate );
	message_end();
}

