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
local castSSDesire = 0;
local castSWDesire = 0;
local castIHDesire = 0;
local abilitySS = nil;
local abilitySW = nil;
local abilityIH = nil;
local cast = false;
local timeCast = 0;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "broodmother_spawn_spiderlings" ); end
	if abilitySW == nil then abilitySW = npcBot:GetAbilityByName( "broodmother_spin_web" ); end
	if abilityIH == nil then abilityIH = npcBot:GetAbilityByName( "broodmother_insatiable_hunger" ); end
	
	castSSDesire, castSSTarget = ConsiderSpawnSpiderlings();
	castSWDesire, castSWLocation = ConsiderSpinWeb();
	castIHDesire = ConsiderInsatiableHunger();
	
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySS, castSSTarget );
		return;
	end
	if ( castSWDesire > 0 and DotaTime() >= timeCast + 0.8 ) 
	then
		npcBot:ActionPush_UseAbilityOnLocation( abilitySW, castSWLocation );
		timeCast = DotaTime();
		return;
	end
	if ( castIHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIH );
		return;
	end
	
end
function LocationOverlapWeb(location, nRadius)
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_broodmother_web"
		then
			local flag = ( 2*nRadius ) - 100;
			if GetUnitToLocationDistance(u, location) <= flag then
				return true
			end
		end
	end
	return false;
end
function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end
	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end
function ConsiderSpawnSpiderlings()
	
	if ( not abilitySS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilitySS:GetCastRange();
	local nDamage = abilitySS:GetSpecialValueInt("damage");
	local level = abilitySS:GetLevel();
	local mana = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_LANING or
		mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange + 200, true );
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if mutil.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL) and mana > .45 then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderSpinWeb()
	
	if ( not abilitySW:IsFullyCastable() or npcBot:IsCastingAbility() or abilitySW:IsInAbilityPhase() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilitySW:GetSpecialValueInt( "radius" );
	local nCastRange = 900;
	local nCastPoint = abilitySW:GetCastPoint( );
    
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
	end
	
		
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and 
				not LocationOverlapWeb(GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange ), nRadius) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange );
			end
		end
	end
	if mutil.IsPushing(npcBot) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius / 3, 0, 0 );
		if locationAoE.count >= 3 and #lanecreeps >= 3 and not LocationOverlapWeb(locationAoE.targetloc, nRadius) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if mutil.IsDefending(npcBot)
	then
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, false);
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and not LocationOverlapWeb(npcBot:GetLocation(), nRadius) then
			return BOT_MODE_DESIRE_MODERATE, npcBot:GetLocation();
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and 
			not LocationOverlapWeb(npcTarget:GetExtrapolatedLocation( nCastPoint ), nRadius)   
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderInsatiableHunger()
	
	if ( not abilityIH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nAttackRange = npcBot:GetAttackRange();
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 2*nAttackRange)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
