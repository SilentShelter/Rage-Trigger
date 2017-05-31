local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot();
local RB = Vector(-7200,-6666)
local DB = Vector(7137,6548)
local CastDMDesire = 0
local CastCYDesire = 0
local CastWWDesire = 0
local CastHBDesire = 0
local AttackDesire = 0
local MoveDesire = 0
local RetreatDesire = 0
local castSCDesire = 0;
local castCHDesire = 0;
local radius = 1000;
function  MinionThink(  hMinionUnit ) 
if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_storm") then
		
		if ( hMinionUnit:IsUsingAbility() ) then return end
		
		abilityDM = hMinionUnit:GetAbilityByName( "brewmaster_storm_dispel_magic" );
		abilityCY = hMinionUnit:GetAbilityByName( "brewmaster_storm_cyclone" );
		abilityWW = hMinionUnit:GetAbilityByName( "brewmaster_storm_wind_walk" );
		abilityCH = hMinionUnit:GetAbilityByName( "brewmaster_drunken_haze" );
		CastDMDesire, DMLocation = ConsiderDM(hMinionUnit); 
		CastCYDesire, CYTarget = ConsiderCY(hMinionUnit); 
		castCHDesire, castCHTarget = ConsiderCorrosiveHaze(hMinionUnit);
		CastWWDesire, WWTarget = ConsiderWW(hMinionUnit); 
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if ( CastDMDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnLocation( abilityDM, DMLocation );
			return;
		end
		
		if ( CastCYDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityCY, CYTarget );
			return;
		end
		
		if ( castCHDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
			return;
		end
		
		if ( CastWWDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityWW, WWTarget );
			return;
		end
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_earth") then
		
		if ( hMinionUnit:IsUsingAbility() ) then return end
		
		abilityHB = hMinionUnit:GetAbilityByName( "brewmaster_earth_hurl_boulder" );
		abilitySC = hMinionUnit:GetAbilityByName( "brewmaster_thunder_clap" );
		castSCDesire = ConsiderSlithereenCrush(hMinionUnit);
		CastHBDesire, HBTarget = ConsiderHB(hMinionUnit); 
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		RetreatDesire, RetreatLocation = ConsiderRetreat(hMinionUnit); 
		
		if ( RetreatDesire > 0 ) 
		then
			hMinionUnit:Action_MoveToLocation( RetreatLocation );
			return;
		end
		if ( castSCDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbility( abilitySC );
			return;
		end
		if ( CastHBDesire > 0 ) 
		then
			hMinionUnit:Action_UseAbilityOnEntity( abilityHB, HBTarget );
			return;
		end
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then	
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_fire") then
		
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
		
	end
	
	if hMinionUnit:IsIllusion() then
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit); 
		
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( bot:GetLocation() + RandomVector(100) );
			return
		end
		
	end
end
	
end
function CanCastCYOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsNightmared( ) or npcTarget:IsSilenced( ) then
		return true;
	end
	return false;
end
function GetFountain(enemy)
	if enemy then
		if GetTeam( ) == TEAM_DIRE then
			return RB;
		else
			return DB;
		end
	else
		if GetTeam( ) == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end
function ConsiderAttacking(hMinionUnit)
    local radius = 1600;
	local Target = nil;
	if IsDisabled(hMinionUnit) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
    local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( radius, true, BOT_MODE_NONE );
	if NearbyEnemyHeroes ~= nil and #NearbyEnemyHeroes > 0 then
		Target = GetClosestUnit(NearbyEnemyHeroes);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyCreeps = hMinionUnit:GetNearbyLaneCreeps( radius, true );
	if  NearbyEnemyCreeps ~= nil and #NearbyEnemyCreeps > 0 then
	    Target = GetClosestUnit(NearbyEnemyCreeps);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyTowers = hMinionUnit:GetNearbyTowers( radius, true );
	if  NearbyEnemyTowers ~= nil and #NearbyEnemyTowers > 0 then
		Target = GetClosestUnit(NearbyEnemyTowers);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	local NearbyEnemyBarracks = hMinionUnit:GetNearbyBarracks( radius, true );
	if  NearbyEnemyBarracks ~= nil and #NearbyEnemyBarracks > 0 then
		Target = GetClosestUnit(NearbyEnemyBarracks);
		return BOT_ACTION_DESIRE_LOW, Target;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function GetClosestUnit(tableNearbyEntity)	
	local target = tableNearbyEntity[1];
	local minHP = tableNearbyEntity[1]:GetHealth();
	for _,unit in pairs(tableNearbyEntity)
	do
		local HP = unit:GetHealth();
		if HP < minHP then
			target = unit;
			minHP = HP;
		end
	end
	return target;
end
function ConsiderMove(hMinionUnit)
	local radius = 1000;
	local NearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( radius, true, BOT_MODE_NONE );
	local NearbyEnemyCreeps = hMinionUnit:GetNearbyLaneCreeps( radius, true );
	local NearbyEnemyTowers = hMinionUnit:GetNearbyTowers( radius, true );
	local NearbyEnemyBarracks = hMinionUnit:GetNearbyBarracks( radius, true );
	
	if NearbyEnemyHeroes[1] == nil and NearbyEnemyCreeps[1] == nil and NearbyEnemyTowers[1] == nil and NearbyEnemyBarracks[1] == nil then
		local location = GetFountain(true)
		return BOT_ACTION_DESIRE_LOW, location;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderRetreat(hMinionUnit)
	local tableNearbyAllyHeroes = hMinionUnit:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 and #tableNearbyEnemyHeroes >= 2 then
		local location = GetFountain(false)
		return BOT_ACTION_DESIRE_LOW, location+RandomVector(300);
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderDM(hMinionUnit)
	if not abilityDM:IsFullyCastable() or abilityDM:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityDM:GetCastRange();
	local nRadius = abilityDM:GetSpecialValueInt( "radius" );
	
	local Allies = hMinionUnit:GetNearbyHeroes( nCastRange + nRadius, false, BOT_MODE_NONE );
	for _,Ally in pairs( Allies )
	do
		if ( IsDisabled(Ally) ) 
		then
			return BOT_ACTION_DESIRE_LOW, Ally:GetLocation();
		end
	end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if #tableNearbyEnemyHeroes == 1 and tableNearbyEnemyHeroes[1]:HasModifier("modifier_brewmaster_storm_cyclone") then
		return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation()
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderCY(hMinionUnit)
	if not abilityCY:IsFullyCastable() or abilityCY:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityCY:GetCastRange();
	
	
	local tableNearbyAttackingAlliedHeroes = hMinionUnit:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local EnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( EnemyHeroes )
		do
			if ( CanCastCYOnTarget( npcEnemy ) and not IsDisabled(npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, hMinionUnit, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_LOW, npcMostDangerousEnemy;
		end
	end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 2*nCastRange, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and not IsDisabled(npcEnemy) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderCorrosiveHaze(hMinionUnit)
	if not abilityCH:IsFullyCastable() or abilityCH:IsHidden() or not bot:HasScepter() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityCH:GetCastRange();
	
	
	local tableNearbyAttackingAlliedHeroes = hMinionUnit:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local EnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( EnemyHeroes )
		do
			if ( CanCastCYOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, hMinionUnit, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_LOW, npcMostDangerousEnemy;
		end
	end
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderWW(hMinionUnit)
	if not abilityWW:IsFullyCastable() or abilityWW:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityWW:GetCastRange();
	local tableNearbyAllyHeroes = hMinionUnit:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	
	if ( tableNearbyEnemyHeroes == nil and #tableNearbyEnemyHeroes == 0 ) then
		return BOT_ACTION_DESIRE_HIGH, hMinionUnit;
	else
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			return BOT_ACTION_DESIRE_LOW, npcAlly;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderSlithereenCrush(hMinionUnit)
	
	if ( not abilitySC:IsFullyCastable() or abilitySC:IsHidden() or not bot:HasScepter() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("damage");
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( nRadius-150, true, BOT_MODE_NONE );
	
	if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) then
		return BOT_ACTION_DESIRE_HIGH;
	end
	return BOT_ACTION_DESIRE_NONE;
end
function ConsiderHB(hMinionUnit)
	if not abilityHB:IsFullyCastable() or abilityHB:IsHidden() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityHB:GetCastRange();
	
	local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and GetUnitToUnitDistance(npcEnemy, hMinionUnit) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( CanCastCYOnTarget( npcEnemy ) and npcEnemy:GetActiveMode() == BOT_MODE_RETREAT )
		then
			return BOT_ACTION_DESIRE_LOW, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
