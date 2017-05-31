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
local castSADesire = 0;
local castDRDesire = 0;
local castSSDesire = 0;
local abilitySA = "";
local abilityDR = "";
local abilityEA = "";
local abilitySS = "";
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilitySA == "" then abilitySA = npcBot:GetAbilityByName( "obsidian_destroyer_arcane_orb" ); end 
	if abilityDR == "" then abilityDR = npcBot:GetAbilityByName( "obsidian_destroyer_astral_imprisonment" ); end 
	if abilityEA == "" then abilityEA = npcBot:GetAbilityByName( "obsidian_destroyer_essence_aura" ); end
	if abilitySS == "" then abilitySS = npcBot:GetAbilityByName( "obsidian_destroyer_sanity_eclipse" ); end
	
	if abilitySA:IsTrained() and abilityEA:GetLevel() >= 3 and not abilitySA:GetAutoCastState( )  then
		abilitySA:ToggleAutoCast();
	end
	
	castSADesire, castSATarget = ConsiderSearingArrows()
	castDRDesire, castDRTarget = ConsiderDisruption();
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	
	if castSADesire > 0 
	then
		npcBot:Action_UseAbilityOnEntity(abilitySA, castSATarget);
	end
	if ( castDRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDR, castDRTarget );
		return;
	end
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end
	
end
function ConsiderSearingArrows()
	if ( not abilitySA:IsFullyCastable() or abilitySA:GetAutoCastState( ) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	local attackRange = npcBot:GetAttackRange()
	
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function ConsiderDisruption()
	
	if ( not abilityDR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityDR:GetCastRange();
	local nDamage = abilityDR:GetSpecialValueInt("damage");
	
	
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes == 2 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		else
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) and mutil.CanCastOnNonMagicImmune( npcEnemy ) 
		    and not mutil.IsDisabled(true, npcEnemy) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
		    not mutil.IsDisabled(true, npcTarget) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderStaticStorm()
	
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local MyIntVal = npcBot:GetAttributeValue(ATTRIBUTE_INTELLECT); 
	local nMultiplier = abilitySS:GetSpecialValueInt( "damage_multiplier" );
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	
	if (  mutil.IsRetreating(npcBot)  and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 ) 
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyInt = npcEnemy:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and mutil.CanKillTarget(npcEnemy,nDamage, DAMAGE_TYPE_MAGICAL ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			local EnemyInt = npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and mutil.CanKillTarget(npcTarget,nDamage, DAMAGE_TYPE_MAGICAL ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
