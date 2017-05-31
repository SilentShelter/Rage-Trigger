-- Copyright © 2017 
-- Scriptwriters Shutnik, AdamQQQ, Arizona Fauzie, Furious Puppy.
-- AdamQQQ 36 hero basic AI \ Warding AI \ Complex scipts for logical decisions
-- Arizona Fauzie  43 hero basic AI \ Rune AI \ ItemBuilds AI \ Complex scripts for Meepo and Invoker
-- Furious Puppy 12 hero basic AI \ Glyph AI \ Retreat logic
-- Shutnik 22 hero basic AI \ Laning behavior \ Map awarness logic \ Skill preferences \ Code adaptation

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local role = require(GetScriptDirectory() .. "/RoleLogic");
local hero_roles = role["hero_roles"];
local utils = require( GetScriptDirectory()..'/shutnik' )

function GetBotNames ()
	return  {
	"shadow", "bLink", "Faith_bian", "iceiceice", "n0tail", "ana", "s4", "JerAx", "Fly", "7ckngMad",
	"Madara", "ThuG", "SkyLark", "Maybe Next Time", "SsaSpartan", "MATUMBAMAN", "Miracle-",
	"MinD_ContRoL", "KuroKy", "Arteezy", "Suma1L", "UNiVeRsE", "zai", "Cr1t-", "Fear",
	"Resolut1on", "w33", "MoonMeander", "MiSeRy", "Saksa", "Faith", "EGM",
	"Agressif", "Freeze", "rOtk", "fy", "Fenrir", "Nota1l", "Abed", "BuLba", "qojqva", "DeMoN", "kingR", "MidOne", "Khezu", "Puppey", "pieliedie", "RAMZES666",
	"No[o]ne", "9pasha", "Lil", "Solo", "Artstyle", "Paparazi", "Sakata", "InJuly", "super",
	"dogf1ghts", "BurNIng", "Xxs", "BoBoKa", "Black^", "Admiral Bulldog", "xy-",
	"Dendi", "Raven", "Dread", "v1lat", "CaspeRRR", "Capitalist", "SirActionSlacks", "Sheever", "ODPixel", "GodHunt", "PGG",
	}
end

local quickMode = false;
local testMode = false;
local requiredHeroes = {
};
local UnImplementedHeroes = {
};

local Pos_1_Pool = {
    'npc_dota_hero_drow_ranger',
    'npc_dota_hero_phantom_assassin',
    'npc_dota_hero_antimage',
    'npc_dota_hero_sniper',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_terrorblade',
	'npc_dota_hero_morphling',
	'npc_dota_hero_weaver',
	'npc_dota_hero_alchemist',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_life_stealer',
	'npc_dota_hero_luna',
	'npc_dota_hero_phantom_lancer',
	'npc_dota_hero_slark',
	'npc_dota_hero_sven',
	'npc_dota_hero_tiny',
	'npc_dota_hero_ursa',
};
local Pos_2_Pool = {
    'npc_dota_hero_invoker',
    'npc_dota_hero_lina',
	'npc_dota_hero_shredder',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_tinker',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_medusa',
	'npc_dota_hero_spectre',
	'npc_dota_hero_clinkz',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_storm_spirit',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_doom_bringer',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_invoker',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_lina',
	'npc_dota_hero_magnataur',
	'npc_dota_hero_meepo',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_puck',
	'npc_dota_hero_pudge',
	'npc_dota_hero_windrunner',
};
local Pos_3_Pool = {
    'npc_dota_hero_spirit_breaker',
    'npc_dota_hero_viper',
	'npc_dota_hero_broodmother',
	'npc_dota_hero_lone_druid',
	'npc_dota_hero_techies',
	'npc_dota_hero_nyx_assassin',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_axe',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_brewmaster',
	'npc_dota_hero_centaur',
	'npc_dota_hero_huskar',
	'npc_dota_hero_monkey_king',
	'npc_dota_hero_night_stalker',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_rattletrap',
	'npc_dota_hero_razor',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_undying',
	'npc_dota_hero_zuus',
};
local Pos_4_Pool = {
    'npc_dota_hero_venomancer',
	'npc_dota_hero_phoenix',
	'npc_dota_hero_batrider',
	'npc_dota_hero_riki',
	'npc_dota_hero_winter_wyvern',
	'npc_dota_hero_pugna',
	'npc_dota_hero_silencer',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_beastmaster',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_gyrocopter',
	'npc_dota_hero_lion',
	'npc_dota_hero_naga_siren',
	'npc_dota_hero_sand_king',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_shadow_shaman',
	'npc_dota_hero_tusk',
	'npc_dota_hero_vengefulspirit',
};
local Pos_5_Pool = {
	'npc_dota_hero_earth_spirit',
    'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_rubick',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_visage',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_bane',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_jakiro',
	'npc_dota_hero_lich',
	'npc_dota_hero_oracle',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_treant',
	'npc_dota_hero_warlock',
	'npc_dota_hero_witch_doctor',
};
local Pos_X_Pool = {
    'npc_dota_hero_legion_commander',
    'npc_dota_hero_bloodseeker',
	'npc_dota_hero_dark_seer',
	'npc_dota_hero_furion',
	'npc_dota_hero_mirana',
	'npc_dota_hero_enigma',
	'npc_dota_hero_lycan',
	'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_earthshaker',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_slardar',
};
local BotPool = {
    Pos_1_Pool,
    Pos_5_Pool,
    Pos_4_Pool,
	Pos_X_Pool,
    Pos_2_Pool,
    Pos_3_Pool,
};
local allBotHeroes = { 
			'npc_dota_hero_ember_spirit',
			'npc_dota_hero_earth_spirit',
			'npc_dota_hero_phoenix',
			'npc_dota_hero_terrorblade',
			'npc_dota_hero_alchemist',
			'npc_dota_hero_morphling',
			'npc_dota_hero_shredder',
			'npc_dota_hero_broodmother',
			'npc_dota_hero_antimage',
			'npc_dota_hero_dark_seer',
			'npc_dota_hero_weaver',
			'npc_dota_hero_obsidian_destroyer',
			'npc_dota_hero_batrider',
			'npc_dota_hero_lone_druid',
			'npc_dota_hero_troll_warlord',
			'npc_dota_hero_tinker',
			'npc_dota_hero_furion',
			'npc_dota_hero_templar_assassin',
			'npc_dota_hero_rubick',
			'npc_dota_hero_keeper_of_the_light',
			'npc_dota_hero_ancient_apparition',
			'npc_dota_hero_mirana',
			'npc_dota_hero_medusa',
			'npc_dota_hero_spectre',
			'npc_dota_hero_enigma',
			'npc_dota_hero_visage',
			'npc_dota_hero_riki',
			'npc_dota_hero_lycan',
			'npc_dota_hero_clinkz',
			'npc_dota_hero_techies',
			'npc_dota_hero_winter_wyvern',
			'npc_dota_hero_pugna',
			'npc_dota_hero_queenofpain',
			'npc_dota_hero_silencer',
			'npc_dota_hero_leshrac',
			'npc_dota_hero_enchantress',
			'npc_dota_hero_nyx_assassin',
			'npc_dota_hero_storm_spirit',
			'npc_dota_hero_abaddon',
			'npc_dota_hero_abyssal_underlord',
			'npc_dota_hero_arc_warden',
			'npc_dota_hero_spirit_breaker',
			'npc_dota_hero_axe',
			'npc_dota_hero_bane',
			'npc_dota_hero_beastmaster',
			'npc_dota_hero_bloodseeker',
			'npc_dota_hero_bounty_hunter',
			'npc_dota_hero_brewmaster',
			'npc_dota_hero_bristleback',
			'npc_dota_hero_centaur',
			'npc_dota_hero_chaos_knight',
			'npc_dota_hero_crystal_maiden',
			'npc_dota_hero_dazzle',
			'npc_dota_hero_death_prophet',
			'npc_dota_hero_disruptor',
			'npc_dota_hero_doom_bringer',
			'npc_dota_hero_dragon_knight',
			'npc_dota_hero_drow_ranger',
			'npc_dota_hero_earthshaker',
			'npc_dota_hero_faceless_void',
			'npc_dota_hero_gyrocopter',
			'npc_dota_hero_huskar',
			'npc_dota_hero_invoker',
			'npc_dota_hero_jakiro',
			'npc_dota_hero_juggernaut',
			'npc_dota_hero_kunkka',
			'npc_dota_hero_legion_commander',
			'npc_dota_hero_lich',
			'npc_dota_hero_life_stealer',
			'npc_dota_hero_lina',
			'npc_dota_hero_lion',
			'npc_dota_hero_luna',
			'npc_dota_hero_magnataur',
			'npc_dota_hero_meepo',
			'npc_dota_hero_monkey_king',
			'npc_dota_hero_naga_siren',
			'npc_dota_hero_necrolyte',
			'npc_dota_hero_nevermore',
			'npc_dota_hero_night_stalker',
			'npc_dota_hero_ogre_magi',
			'npc_dota_hero_omniknight',
			'npc_dota_hero_oracle',
			'npc_dota_hero_phantom_assassin',
			'npc_dota_hero_phantom_lancer',
			'npc_dota_hero_puck',
			'npc_dota_hero_pudge',
			'npc_dota_hero_rattletrap',
			'npc_dota_hero_razor',
			'npc_dota_hero_sand_king',
			'npc_dota_hero_shadow_demon',
			'npc_dota_hero_shadow_shaman',
			'npc_dota_hero_skeleton_king',
			'npc_dota_hero_skywrath_mage',
			'npc_dota_hero_slardar',
			'npc_dota_hero_slark',
			'npc_dota_hero_sniper',
			'npc_dota_hero_sven',
			'npc_dota_hero_tidehunter',
			'npc_dota_hero_tiny',
			'npc_dota_hero_treant',
			'npc_dota_hero_tusk',
			'npc_dota_hero_undying',
			'npc_dota_hero_ursa',
			'npc_dota_hero_vengefulspirit',
			'npc_dota_hero_venomancer',
			'npc_dota_hero_viper',
			'npc_dota_hero_warlock',
			'npc_dota_hero_windrunner',
			'npc_dota_hero_witch_doctor',
			'npc_dota_hero_zuus',
}
local ListPickedHeroes = {};
local AllHeroesSelected = false;
local BanCycle = 1;
local PickCycle = 1;
local NeededTime = 29;
local Min = -5;
local Max = 25;
local CMTestMode = false;
local UnavailableHeroes = {}
local HeroLanes = {
	[1] = LANE_TOP,
	[2] = LANE_TOP,
	[3] = LANE_MID,
	[4] = LANE_BOT,
	[5] = LANE_BOT,
};
local PairsHeroNameNRole = {};
local humanPick = {};
function Think()
	if GetGameMode() == GAMEMODE_AP then
		AllPickLogic();
	elseif GetGameMode() == GAMEMODE_CM then
		CaptainModeLogic();
		AddToList();
	end
end
function AddToList()
	if not IsPlayerBot(GetCMCaptain()) then
		for _,h in pairs(allBotHeroes)
		do
			if IsCMPickedHero(GetTeam(), h) and not alreadyInTable(h) then
				table.insert(humanPick, h)
			end
		end
	end
end
function alreadyInTable(hero_name)
	for _,h in pairs(humanPick)
	do
		if hero_name == h then
			return true
		end
	end
	return false
end
function CaptainModeLogic()
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
        return
    end
	if not CMTestMode then
		if NeededTime == 29 then
			NeededTime = RandomInt( Min, Max );
		elseif NeededTime == 0 then
			NeededTime = RandomInt( Min, Max );
		end
	elseif CMTestMode then
		NeededTime = 29;
	end	
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then	
		PickCaptain();
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN10 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero();
		NeededTime = 0 
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero();	
		NeededTime = 0
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectsHero();	
	end	
end
function PickCaptain()
	if not IsHumanPlayerExist() or DotaTime() > -1 then
		if GetCMCaptain() == -1 then
			local CaptBot = GetFirstBot();
			if CaptBot ~= nil then
				SetCMCaptain(CaptBot)
			end
		end
	end
end
function IsHumanPlayerExist()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if not IsPlayerBot(id) then
			return true;
        end
    end
	return false;
end
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id;
			return BotId;
        end
    end
	return BotId;
end
function IsUnavailableHero(name)
	for _,uh in pairs(UnavailableHeroes)
	do
		if name == uh then
			return true;
		end	
	end
	return false;
end
function IsUnImplementedHeroes()
	for _,unh in pairs(UnImplementedHeroes)
	do
		if name == unh then
			return true;
		end	
	end
	return false;
end
function RandomHero()
	local hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
	while ( IsUnavailableHero(hero) or IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) ) 
	do
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end
	return hero;
end
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end	
	local BannedHero = RandomHero();
	print(BannedHero.." is banned")
	CMBanHero(BannedHero);
	BanCycle = BanCycle + 1;
end
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end	
	local PickedHero = RandomHero();
	
	if PickCycle == 1 then
		while not role.CanBeOfflaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "offlaner";
	elseif	PickCycle == 2 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 3 then
		while not role.CanBeMidlaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "midlaner";
	elseif	PickCycle == 4 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 5 then
		while not role.CanBeSafeLaneCarry(PickedHero) do
			PickedHero = RandomHero();
		end	
		PairsHeroNameNRole[PickedHero] = "carry";
	end
	CMPickHero(PickedHero);
	PickCycle = PickCycle + 1;
end
function WasHumansDonePicking()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) 
	do
        if not IsPlayerBot(id) then
			if GetSelectedHeroName(id) == nil or GetSelectedHeroName(id) == "" then
				return false;
			end	
        end
    end
	return true;
end
function SelectsHero()
	if not AllHeroesSelected and ( WasHumansDonePicking() or GetCMPhaseTimeRemaining() < 1 ) then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();
		for _,id in pairs(Players) 
		do
			local hero_name =  GetSelectedHeroName(id);
			if hero_name ~= nil and hero_name ~= "" then
				UpdateSelectedHeroes(hero_name)
				print(hero_name.." Removed")
			else
				table.insert(RestBotPlayers, id)
			end	
		end
		for i = 1, #RestBotPlayers
		do
			SelectHero(RestBotPlayers[i], ListPickedHeroes[i])
		end
		AllHeroesSelected = true;
	end
end
function FillLaneAssignmentTable()
	local supportAlreadyAssigned = false;
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name =  GetTeamMember(i):GetUnitName(); 
			if PairsHeroNameNRole[unit_name] == "support" and not supportAlreadyAssigned then
				HeroLanes[i] = LANE_TOP;
				supportAlreadyAssigned = true;
			elseif PairsHeroNameNRole[unit_name] == "support" and supportAlreadyAssigned then
				HeroLanes[i] = LANE_BOT;
			elseif PairsHeroNameNRole[unit_name] == "midlaner" then
				HeroLanes[i] = LANE_MID;
			elseif PairsHeroNameNRole[unit_name] == "offlaner" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_TOP;
				else
					HeroLanes[i] = LANE_BOT;
				end
			elseif PairsHeroNameNRole[unit_name] == "carry" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_BOT;
				else
					HeroLanes[i] = LANE_TOP;
				end	
			end
		end
	end	
end
function GetTeamSelectedHeroes()
	for _,sName in pairs(allBotHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
	for _,sName in pairs(UnImplementedHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end	
	end
end
function UpdateSelectedHeroes(selected)
	for i=1, #ListPickedHeroes
	do
		if ListPickedHeroes[i] == selected then
			table.remove(ListPickedHeroes, i);
		end
	end
end
local PickTime = 10;
local RandomTime = 0;
function AllPickLogic()
	 if not CanPick() then return end;
	 
	 local idx = 0;
	 for _,i in pairs(GetTeamPlayers(GetTeam())) 
	 do 
		if IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" 
		then 
			if testMode then
				hero = GetRandomHero() 
			else
				hero = PickRightHero(idx) 
			end
			SelectHero(i, hero); 
			PickTime = GameTime();
			RandomTime = 0;
			return;
		end
		idx = idx + 1;
	end 
	idx = 0;
end
function CanPick()
	if RandomTime == 0 then RandomTime = RandomInt((70/5)/2,70/5); end
	if GameTime() > 70 or IsHumansDonePicking() then return true end
	if RandomTime ~= 0 and GameTime() >= PickTime + RandomTime then return true end
	return false;
end
function PickRightHero(slot)
	local initHero = GetRandomHero();
	local Team = GetTeam();
	if slot == 0 then
		while not role.CanBeMidlaner(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 1 then
		while ( Team == TEAM_RADIANT and not role.CanBeOfflaner(initHero) ) or 
			  ( Team == TEAM_DIRE and not role.CanBeSafeLaneCarry(initHero) ) 
		do
			initHero = GetRandomHero();
		end
	elseif slot == 2 then
		while not role.CanBeSupport(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 3 then
		while not role.CanBeSupport(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 4 then
		while ( Team == TEAM_RADIANT and not role.CanBeSafeLaneCarry(initHero) ) or 
			  ( Team == TEAM_DIRE and not role.CanBeOfflaner(initHero) )
		do
			initHero = GetRandomHero();
		end
	end
	return initHero;
end
function IsHumansDonePicking() 
	for _,i in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i) then 
			return false; 
		end 
	end 
	for _,i in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i) then 
			return false; 
		end 
	end 
	return true; 
end
function PickHero(slot)
  local hero = GetRandomHero();
  SelectHero(slot, hero);
end
function GetPicks()
	local selectedHeroes = {};
    local pickedSlots = {};
	for _,i in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if GetSelectedHeroName(i) ~= "" then 
			selectedHeroes[i] =  GetSelectedHeroName(i);
		end 
	end 
	for _,i in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(i) ~= "" then 
			selectedHeroes[i] =  GetSelectedHeroName(i);
		end 
	end 
    return selectedHeroes;
end
function GetRandomHero()
    local hero;
    local picks = GetPicks();
    local selectedHeroes = {};
    for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
    end
	if testMode then
		hero = requiredHeroes[RandomInt(1, #requiredHeroes)];
	else
		hero = nil;
	end
	if (hero == nil) then
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end

    while ( selectedHeroes[hero] == true ) do
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end
    return hero;
end
function UpdateLaneAssignments()    
	if GetGameMode() == GAMEMODE_AP then
		return APLaneAssignment()
	elseif GetGameMode() == GAMEMODE_CM then
		return CMLaneAssignment()	
	end 
end
function FillLAHumanCaptain()
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name =  GetTeamMember(i):GetUnitName(); 
			local key = GetFromHumanPick(unit_name);
			if key ~= nil then
				if key == 1 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_BOT;
					else
						HeroLanes[i] = LANE_TOP;
					end
				elseif key == 2 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_BOT;
					else
						HeroLanes[i] = LANE_TOP;
					end	
				elseif key == 3 then
					HeroLanes[i] = LANE_MID;
				elseif key == 4 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_TOP;
					else
						HeroLanes[i] = LANE_BOT;
					end
				elseif key == 5 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_TOP;
					else
						HeroLanes[i] = LANE_BOT;
					end	
				end
			end
		end
	end	
end
function GetFromHumanPick(hero_name)
	local i = nil;
	for key,h in pairs(humanPick)
	do
		if hero_name == h then
			i = key;
		end	
	end
	return i;
end
function CMLaneAssignment()
	if IsPlayerBot(GetCMCaptain()) then
		FillLaneAssignmentTable();
	else
		FillLAHumanCaptain()
	end
	return HeroLanes;
end
function APLaneAssignment()

	 local lanecount = {
        [LANE_NONE] = 5,
        [LANE_MID] = 1,
        [LANE_TOP] = 2,
        [LANE_BOT] = 2,
    };
    local lanes = {
        [1] = LANE_TOP,
        [2] = LANE_TOP,
        [3] = LANE_MID,
        [4] = LANE_BOT,
        [5] = LANE_BOT,
    };
    local playercount = 0
    if ( GetTeam() == TEAM_RADIANT )
    then 
        local ids = GetTeamPlayers(TEAM_RADIANT)
        for i,v in pairs(ids) do
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end
        for i=1,playercount do
            local lane = GetLane( TEAM_RADIANT,GetTeamMember( i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end
        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
        return lanes
    elseif ( GetTeam() == TEAM_DIRE )
    then
        local ids = GetTeamPlayers(TEAM_DIRE)
        for i,v in pairs(ids) do
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end
        for i=1,playercount do
            local lane = GetLane( TEAM_DIRE, GetTeamMember( i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end
        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
        return lanes
    end
end
function GetLane( nTeam ,hHero )
        local vBot = GetLaneFrontLocation(nTeam, LANE_BOT, 0)
        local vTop = GetLaneFrontLocation(nTeam, LANE_TOP, 0)
        local vMid = GetLaneFrontLocation(nTeam, LANE_MID, 0)
        if GetUnitToLocationDistance(hHero, vBot) < 2500 then
            return LANE_BOT
        end
        if GetUnitToLocationDistance(hHero, vTop) < 2500 then
            return LANE_TOP
        end
        if GetUnitToLocationDistance(hHero, vMid) < 2500 then
            return LANE_MID
        end
        return LANE_NONE
end