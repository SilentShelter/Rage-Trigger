if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_shutnik" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/Mylogic")
function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
local castFBDesire = 0;
local castSCDesire = 0;
local castTSDesire = 0;
local castRADesire = 0;
local castSoulRingDesire = 0;
local castBoTDesire = 0;
local abilityFB = nil;
local abilitySC = nil;
local abilityTS = nil;
local abilityRA = nil;
local timeCast = 0;
local channleTime = 3;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) or npcBot:HasModifier("modifier_tinker_rearm") then return end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "tinker_laser" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "tinker_heat_seeking_missile" ) end
	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "tinker_march_of_the_machines" ) end
	if abilityRA == nil then abilityRA = npcBot:GetAbilityByName( "tinker_rearm" ) end
	
	castFBDesire, castFBTarget = ConsiderFireblast();
	castSCDesire = ConsiderSlithereenCrush();
	castTSDesire, castTSLocation = ConsiderTombStone();
	castRADesire = ConsiderRearm();
	castSoulRingDesire, itemSR = ConsiderSoulRing() 
	castBoTDesire, itemBoT, castBoTLocation = ConsiderBoT() 
	
	channleTime = abilityRA:GetSpecialValueFloat("channel_tooltip");
	
	if castSoulRingDesire > 0 then
		npcBot:Action_UseAbility( itemSR );
		return
	end
	
	if castBoTDesire > 0 then
		npcBot:Action_UseAbilityOnLocation( itemBoT, castBoTLocation );
		return
	end
	
	if ( castTSDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTS, castTSLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
	if ( castRADesire > 0 and DotaTime() > timeCast + channleTime ) 
	then
		npcBot:Action_ClearActions(true);
		npcBot:ActionPush_UseAbility( abilityRA );
		timeCast = DotaTime();
		return;
	end
end
function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
function TravelOffCD()
	local bot1=IsItemAvailable("item_travel_boots");
	local bot2=IsItemAvailable("item_travel_boots_2");
	if bot1~=nil then
		return bot1:IsFullyCastable();
	end
	if bot2~=nil then
		return bot2:IsFullyCastable();
	end
	return true;
end
function ConsiderSoulRing()
	
	local sr=IsItemAvailable("item_soul_ring")
	
	if sr == nil then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	if not sr:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
    if npcBot:GetHealth() > 2 * 150 and currManaRatio < 0.90 and castRADesire > 0
	then
		return BOT_ACTION_DESIRE_HIGH, sr;
	end
	
	return BOT_ACTION_DESIRE_NONE, {};
end
function ConsiderBoT()
	local bot=IsItemAvailable("item_travel_boots")
	
	if bot == nil then
		return BOT_ACTION_DESIRE_NONE, {}, {};
	end
	
	if not bot:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, {}, {};
	end
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
    if npcBot:GetMana() < abilityRA:GetManaCost() and npcBot:DistanceFromFountain() > 0
	then
	    local location = mutil.GetTeamFountain();
		return BOT_ACTION_DESIRE_HIGH, bot, location;
	end
	
	return BOT_ACTION_DESIRE_NONE, {}, {};
end
function ConsiderFireblast()
	
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetSpecialValueInt("laser_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.55  
	then
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage  then
				return BOT_ACTION_DESIRE_LOW, creep;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderSlithereenCrush()
	
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nDamage = abilitySC:GetAbilityDamage();
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )  and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1200, 500, 0, 0 );
		if  locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderTombStone()
	local npcBot = GetBot();
	
	
	if ( not abilityTS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castFBDesire > 0 or castSCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = abilityTS:GetCastRange();
	local nCastPoint = abilityTS:GetCastPoint();
	local nRadius = abilityTS:GetSpecialValueInt("radius");
	
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 3 and (npcBot:GetMana() / npcBot:GetMaxMana()) > 0.45 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderRearm()
	local npcBot = GetBot();
	
	
	if ( npcBot:HasModifier("modifier_tinker_rearm") or not abilityRA:IsFullyCastable() or abilityRA:IsInAbilityPhase() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	if castFBDesire > 0 or castSCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nManaCost = abilityRA:GetManaCost()
	local botMana = npcBot:GetMana();
	
	if npcBot:DistanceFromFountain() == 0 and not TravelOffCD() then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( botMana >= nManaCost and mutil.IsValidTarget(npcTarget) and not abilityFB:IsCooldownReady() and not abilitySC:IsCooldownReady() 
		     and mutil.IsInRange(npcTarget, npcBot, 1000)   ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		if ( botMana >= nManaCost and not abilityTS:IsCooldownReady()  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE
end