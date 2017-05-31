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
local castDCDesire = 0;
local castBLDesire = 0;
local castSCDesire = 0;
local castTWDesire = 0;
local abilityDC = nil;
local abilityBL = nil;
local abilityTW = nil;
local abilitySC = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "magnataur_shockwave" ) end
	if abilityBL == nil then abilityBL = npcBot:GetAbilityByName( "magnataur_empower" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "magnataur_skewer" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "magnataur_reverse_polarity" ) end
	
	
	castDCDesire, castDCLocation = ConsiderDecay();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castSCDesire = ConsiderSlithereenCrush();
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
end
function ConsiderDecay()
	
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("shock_damage");
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if (  locationAoE.count >= 4 and #lanecreeps >= 4   ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/950)+nCastPoint);
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderBloodlust()
	
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		if not npcBot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if not npcBot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
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
	
	
	
	local nCastRange = abilityTW:GetSpecialValueInt("range");
	local nCastPoint = abilityTW:GetCastPoint( );
	
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
				local location = mutil.GetTeamFountain()
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/950)+nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderSlithereenCrush()
	
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilitySC:GetSpecialValueInt( "pull_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("polarity_damage");
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-100, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and tableNearbyEnemyHeroes ~= nil and #tableNearbyAllyHeroes > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local EnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 100, true, BOT_MODE_NONE );
			if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
				 and EnemyHeroes ~= nil and #EnemyHeroes >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
