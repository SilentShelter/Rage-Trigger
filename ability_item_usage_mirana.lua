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
local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local casthookDesire = 0;
local abilityDP = nil; 
local abilityHook = nil; 
local abilityPC = nil; 
local abilitySD = nil; 
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "mirana_starfall" ) end
	if abilityHook == nil then abilityHook = npcBot:GetAbilityByName( "mirana_arrow" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "mirana_leap" ) end
	if abilitySD == nil then abilitySD = npcBot:GetAbilityByName( "mirana_invis" ) end
	
	castDPDesire = ConsiderDarkPact();
	castHookDesire, castHookTarget = ConsiderHook();
	castPCDesire = ConsiderPounce();
	castSDDesire = ConsiderShadowDance();
	
	if ( castHookDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityHook, castHookTarget );
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySD );
		return;
	end
end
function ConsiderDarkPact()
	
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = abilityDP:GetSpecialValueInt( "starfall_radius" );
	local nRadius = abilityDP:GetSpecialValueInt( "starfall_secondary_radius" );
	local nDamage = abilityDP:GetAbilityDamage();
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	 
	if mutil.IsPushing(npcBot) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderHook()
	
	if ( not abilityHook:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nRadius = abilityHook:GetSpecialValueInt( "arrow_width" );
	local speed = abilityHook:GetSpecialValueInt( "arrow_speed" );
	local nDamage = abilityHook:GetAbilityDamage();
	local nCastRange = abilityHook:GetSpecialValueInt("arrow_range")
	local nCastPoint = abilityHook:GetCastPoint();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot)
			local moveCon = npcTarget:GetMovementDirectionStability();
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon == 0 then
				pLoc = npcTarget:GetLocation();
			end
			if not utils.AreEnemyCreepsBetweenMeAndLoc(pLoc, nRadius)  then
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderPounce()
	
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = abilityPC:GetSpecialValueInt( "leap_distance" );
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local ancient = GetAncient(GetTeam());
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcBot:IsFacingUnit(ancient, 10 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 600) and npcBot:IsFacingUnit(npcTarget, 10)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderShadowDance()
	
	if ( not abilitySD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		if  mutil.IsValidTarget(npcTarget) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and 
			not mutil.IsInRange(npcTarget, npcBot, 1000) and  mutil.IsInRange(npcTarget, npcBot, 2000) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
