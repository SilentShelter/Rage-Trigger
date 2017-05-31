local utils = require(GetScriptDirectory() .. "/util")
local jungleStatus = require(GetScriptDirectory() .."/jungle_status" )
local inspect = require(GetScriptDirectory() .. "/inspect")
local meepoStatus = require(GetScriptDirectory() .."/meepo_status" )
STATE_IDLE = "STATE_IDLE"
STATE_MOVING_TOCAMP = "STATE_MOVING_TOCAMP"
STATE_STACKING_CAMP = "STATE_STACKING_CAMP"
STATE_ATTACKING_CAMP = "STATE_ATTACKING_CAMP"
local state = STATE_IDLE
local npcBot = GetBot()
local player = npcBot:GetPlayerID()
local team = GetTeam()
local level = npcBot:GetLevel()
local clone = -1
jungleStatus.NewJungle()
local campToFarm = nil
local campToStack = nil
local creepRespawn = true
local runeRespawn = true
local min = 0
local sec = 0
local farmed = false
function GetDesire()
	local desireMultiplier = 1
	level = npcBot:GetLevel()
	min = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	local camplvl = CAMP_EASY
	if meepoStatus.GetIsFarmed() then
		return BOT_MODE_DESIRE_NONE
	end
	if(clone == -1) then
		if(level > 16)then
			clone = 3;
		elseif(level > 9)then
			clone = 2;
		elseif(level > 2)then
			clone = 1;
		else
			clone = 0;
		end
	end
	if level > 20 then
		desireMultiplier = .6
	end
	if creepRespawn and (min % 2) == 1 then
		jungleStatus.NewJungle() 
		runeRespawn = true
		creepRespawn = false
	end
	if runeRespawn and (min % 2) == 0 then
		runeRespawn = false
		creepRespawn = true
	end
	if jungleStatus.GetJungle(team) == nil then
	end
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1300, false, BOT_MODE_NONE );
	for _,v in pairs(tableNearbyAttackingAlliedHeroes) do
		if (v:GetActiveMode() == BOT_MODE_ATTACKING or
			v:GetActiveMode() == BOT_MODE_RETREAT or
			v:GetActiveMode() == BOT_MODE_DEFEND_ALLY)
		then
			return BOT_MODE_DESIRE_NONE
		end
	end
	if npcBot:GetHealth() < (npcBot:GetMaxHealth() * .2) then
		return BOT_MODE_DESIRE_NONE
	end
	if level < 5 then
		if min % 2 == 0 and sec > 40 then
			if clone == 1 then
				return BOT_MODE_DESIRE_HIGH
			else
				return BOT_MODE_DESIRE_NONE
			end
		else
			return BOT_MODE_DESIRE_NONE
		end
	end
	if level > 4 and level < 11 then
		if clone == 1 then
			return BOT_MODE_DESIRE_NONE
		end
			return BOT_MODE_DESIRE_HIGH
	else
		if clone == 0 then
			return BOT_MODE_DESIRE_NONE
		end
		return BOT_MODE_DESIRE_HIGH
	end
	return BOT_MODE_DESIRE_NONE
end
function OnStart()
	
end
function OnEnd() 
end
function Think()	
	if (not (state == STATE_MOVING_TOSTACK or
		state == STATE_STACKING_CAMP) and min % 2 == 0 and sec > 40) then
		local tableCreeps = npcBot:GetNearbyCreeps( 700, true ) 
		if tableCreeps[1] ~= nil then
			local remainingHealth = 0
			for _,v in pairs(tableCreeps) do
				remainingHealth = remainingHealth + v:GetHealth()
			end
			if remainingHealth > npcBot:GetEstimatedDamageToTarget( false, tableCreeps[1], 10.0, 1 ) then
				campToStack = campToFarm
				state = STATE_STACKING_CAMP
				return
			end
		end	
		if jungleStatus.GetJungle(team) == nil then			
			campToFarm = { [VECTOR] = utils.tableRuneSpawns[team][1] }
			state = STATE_IDLE
		else
			campToStack = npcBot:GetNearestNeutrals( jungleStatus.GetJungle(team))
			state = STATE_MOVING_TOSTACK
		end
	end
	if state == STATE_IDLE then
		local campsICanHandle = utils.deepcopy(jungleStatus.GetJungle(team))
		if campsICanHandle ~= nil then
			camplvl = CAMP_EASY
			if level > 4 then camplvl = CAMP_MEDIUM end
			if level > 8 then camplvl = CAMP_HARD end
			if level > 13 then camplvl = CAMP_ANCIENT end
			for i=#campsICanHandle,1,-1 do
				if campsICanHandle[i][DIFFICULTY] > camplvl then
					campsICanHandle[i] = nil	
				end
			end
			if campsICanHandle ~= nil then
				campToFarm = npcBot:GetNearestNeutrals(campsICanHandle)
			end
		end
		if campToFarm == nil then return end
		state = STATE_MOVING_TOCAMP
	end
	if state == STATE_MOVING_TOCAMP then
		if GetUnitToLocationDistance( npcBot, campToFarm[VECTOR] ) < 200 then
			state = STATE_ATTACKING_CAMP
		else
			npcBot:Action_MoveToLocation( campToFarm[VECTOR] )
			return
		end
	end
	if state == STATE_MOVING_TOSTACK then
		if GetUnitToLocationDistance( npcBot, campToStack[PRE_STACK_VECTOR] ) < 200 then
			state = STATE_STACKING_CAMP
		else
			npcBot:Action_MoveToLocation( campToStack[PRE_STACK_VECTOR] )
			return
		end
	end
	if state == STATE_ATTACKING_CAMP then
		local tableCreeps = npcBot:GetNearbyCreeps( 700, true ) 
		if tableCreeps[1] == nil then
			if GetUnitToLocationDistance( npcBot, campToFarm[VECTOR]) < 200 
			then
				jungleStatus.JungleCampClear( team, campToFarm[VECTOR] )
			end
			state = STATE_IDLE
		else
			if npcBot:GetAttackTarget() == nil then
				npcBot:Action_AttackUnit( tableCreeps[1], false )
			end
			return
		end	
	end
	if state == STATE_STACKING_CAMP then
		if min % 2 == 1 or campToStack == nil then 
			state = STATE_IDLE
			return
		elseif campToStack[STACK_TIME] <= sec then
			npcBot:Action_MoveToLocation( campToStack[STACK_VECTOR] )
			return
		elseif (campToStack[STACK_TIME] - 1) <= sec then
			local tableCreeps = npcBot:GetNearbyCreeps( 700, true ) 
			if tableCreeps[1] == nil then
				npcBot:Action_MoveToLocation( campToStack[STACK_VECTOR] )
			else
				if npcBot:GetAttackTarget() == nil then
					npcBot:Action_AttackUnit( tableCreeps[1], false )
				end
				return
			end	
		elseif (campToStack[STACK_TIME] - 1) > sec then
			npcBot:Action_MoveToLocation( campToStack[PRE_STACK_VECTOR] )
			return
		end
	end
end