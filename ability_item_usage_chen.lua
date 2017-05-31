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
local castUFBDesire = 0;
local castACDesire = 0;
local castHPDesire = 0;
local castHoGDesire = 0;
local abilityUFB = nil;
local abilityFB = nil;
local abilityAC = nil;
local abilityHP = nil;
local abilityHoG = nil;
local npcBot = nil;
function AbilityUsageThink()
	if npcBot == nil then npcBot = GetBot(); end
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "chen_penitence" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "chen_test_of_faith" ) end
	if abilityAC == nil then abilityAC = npcBot:GetAbilityByName( "chen_test_of_faith_teleport" ) end
	if abilityHP == nil then abilityHP = npcBot:GetAbilityByName( "chen_holy_persuasion" ) end
	if abilityHoG == nil then abilityHoG = npcBot:GetAbilityByName( "chen_hand_of_god" ) end
	
	castFBDesire, castFBTarget = ConsiderFireblast();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castACDesire, castACTarget = ConsiderAphoticShield();
	castHPDesire, castHPTarget = ConsiderHolyPersuasion();
	castHoGDesire = ConsiderHandofGod();
	
	if ( castHoGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityHoG );
		return;
	end
	
	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castHPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityHP, castHPTarget );
		return;
	end
end
function ConsiderUnrefinedFireblast()
	
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = abilityUFB:GetCastRange();
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
function ConsiderFireblast()
	
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetSpecialValueInt("damage_max");
	
	
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PURE) and
	   mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderHolyPersuasion()
	
	if ( not abilityHP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityHP:GetCastRange();
	
	local maxHP = 0;
	local NCreep = nil;
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 1300 );
	
	if npcBot:HasScepter() and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP 
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	elseif not npcBot:HasScepter() and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then	
		for _,neutral in pairs(tableNearbyNeutrals)
		do
			local NeutralHP = neutral:GetHealth();
			if NeutralHP > maxHP and not neutral:IsAncientCreep()
			then
				NCreep = neutral;
				maxHP = NeutralHP;
			end
		end
	end
	
	if NCreep ~= nil then
		return BOT_ACTION_DESIRE_LOW, NCreep;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderAphoticShield()
	
	if ( not abilityAC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityAC:GetCastRange();
	
	local lowHpAlly = nil;
	local nLowestHealth = 10000;
	local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
	for _,npcAlly in pairs( tableNearbyAllies )
	do
		if ( mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetUnitName() ~= npcBot:GetUnitName() )
		then
			local nAllyHP = npcAlly:GetHealth();
			if  ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) and
				( npcAlly:GetActiveMode() == BOT_MODE_RETREAT and npcAlly:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
			then
				nLowestHealth = nAllyHP;
				lowHpAlly = npcAlly;
			end
		end
	end
	if ( lowHpAlly ~= nil )
	then
		return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end
function ConsiderHandofGod()
	
	if ( not abilityHoG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	local maxDist = 0;
	local target = nil;
	for i = 1, #numPlayer
	do
		local Ally = GetTeamMember(i);
		if Ally:IsAlive() and 
			Ally:GetActiveMode() == BOT_MODE_RETREAT and Ally:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH and
			Ally:GetHealth() /Ally:GetMaxHealth() < 0.45 and Ally:WasRecentlyDamagedByAnyHero(2.0)
		then
			target = GetTeamMember(i);
			break;
		end
	end
	if target ~= nil then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
