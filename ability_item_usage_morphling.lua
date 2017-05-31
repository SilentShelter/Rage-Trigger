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
local castTWDesire = 0;
local castTDDesire = 0;
local castRCDesire = 0;
local castMRADesire = 0;
local castMRSDesire = 0;
local castGhostDesire = 0;
local castEBDesire = 0;
local itemGhost = nil;
local itemEB = nil;
local alreadyCastEB = false;
local abilityFB = nil;
local abilityTW = nil;
local abilityMRA = nil;
local abilityMRS = nil;
local abilityRC = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "morphling_adaptive_strike" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "morphling_waveform" ) end
	if abilityMRA == nil then abilityMRA = npcBot:GetAbilityByName( "morphling_morph_agi" ) end
	if abilityMRS == nil then abilityMRS = npcBot:GetAbilityByName( "morphling_morph_str" ) end
	if abilityRC == nil then abilityRC = npcBot:GetAbilityByName( "morphling_replicate" ) end
	itemGhost = IsItemAvailable("item_ghost");
	itemEB = IsItemAvailable("item_ethereal_blade");
	
	
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castMRADesire = ConsiderMorphAgility();
	castMRSDesire = ConsiderMorphStrength();
	castRCDesire, castRCTarget = ConsiderReplicate();
	castGhostDesire = ConsiderGhostScepter();
	castEBDesire, castEBTarget = ConsiderEtherealBlade();
	
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	
	if ( castEBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( itemEB, castEBTarget );
		alreadyCastEB = true;
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		alreadyCastEB = false;
		return;
	end
	if ( castRCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
		return;
	end
	
	if castMRSDesire > 0 then
		npcBot:Action_UseAbility( abilityMRS );
		return;
	end
	
	if castMRADesire > 0 then
		npcBot:Action_UseAbility( abilityMRA );
		return;
	end
	
	if castGhostDesire > 0 then
		npcBot:Action_UseAbility( itemGhost );
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
	
function ConsiderFireblast()
	
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castEBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nMinAGIX = abilityFB:GetSpecialValueFloat("damage_min");
	local nMaxAGIX =  abilityFB:GetSpecialValueFloat("damage_max");
	local nMinStun = abilityFB:GetSpecialValueFloat("stun_min");
	local nMaxStun = abilityFB:GetSpecialValueFloat("stun_max");
	local nAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nDamage = 0; 
	local nStun = 0; 
	
	if nAGI > nSTR and ( nAGI - nSTR ) / nSTR >= 0.5 then
		nDamage = nMaxAGIX * nAGI;
	else
		nDamage = nMinAGIX * nAGI;
	end
	
	if nSTR > nAGI and ( nSTR - nAGI ) / nAGI >= 0.5 then
		nStun = nMaxStun;
	else
		nStun = nMinStun;
	end
	
	if alreadyCastEB then
		
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL ) and mutil.CanCastOnMagicImmune(npcTarget) 
	   and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) and nStun > nMinStun ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
			   and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and ( mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL )  or nStun > nMinStun )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end	
function ConsiderTimeWalk()
	
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = abilityTW:GetCastRange()
	local nCastPoint = abilityTW:GetCastPoint();
	local nSpeed = abilityTW:GetSpecialValueInt("speed");
	local nDamage = abilityTW:GetAbilityDamage();
	local nAttackRange = npcBot:GetAttackRange();
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange );
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, npcBot )/ nSpeed ) + nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderMorphAgility()
	
	
	if ( not abilityMRA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	local nBonusAgi = abilityMRA:GetSpecialValueInt("bonus_attributes");
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	if currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) < 2.0 and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) >= 2.0 and abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif npcBot:DistanceFromFountain() == 0 and currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then	
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderMorphStrength()
	
	if ( not abilityMRS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local currAGI = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and not abilityMRS:GetToggleState() then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif tableNearbyEnemyHeroes == nil and #tableNearbyEnemyHeroes < 1 and abilityMRS:GetToggleState() then 	
			return BOT_ACTION_DESIRE_MODERATE;
		end
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) <= 2.5 and abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;	
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) > 2.5 and not abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderReplicate()
	
	if ( not abilityRC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityRC:GetCastRange();
	local nCastPoint = abilityRC:GetCastPoint();
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 ) 
		then 
			local nMaxAD = 0;
			local target = nil;
			for _,enemy in pairs(tableNearbyEnemyHeroes)
			do
				local enemyAD = enemy:GetAttackDamage();
				if enemyAD > nMaxAD then
					target = enemy;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		   and npcTarget:GetHealth()/npcTarget:GetMaxHealth() > 0.8  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end	
function ConsiderGhostScepter()
	if ( itemGhost == nil or not itemGhost:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderEtherealBlade()
	if ( itemEB == nil or not itemEB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local nCastRange = abilityFB:GetCastRange();
	if mutil.IsRetreating(npcBot)
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end