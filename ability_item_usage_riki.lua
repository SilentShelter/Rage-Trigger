
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local npcBot = GetBot()
local ComboMana = 0
local debugmode=false
local Talents ={}
local Abilities ={}
for i=0,23,1 do
	local ability=npcBot:GetAbilityInSlot(i)
	if(ability~=nil)
	then
		if(ability:IsTalent()==true)
		then
			table.insert(Talents,ability:GetName())
		else
			table.insert(Abilities,ability:GetName())
		end
	end
end
local AbilitiesReal =
{
	npcBot:GetAbilityByName(Abilities[1]),
	npcBot:GetAbilityByName(Abilities[2]),
	npcBot:GetAbilityByName(Abilities[3]),
	npcBot:GetAbilityByName(Abilities[4])
}
local AbilityToLevelUp=
{
	Abilities[3],
	Abilities[2],
	Abilities[1],
	Abilities[2],
	Abilities[2],
	Abilities[4],
	Abilities[2],
	Abilities[3],
	Abilities[3],
	"talent",
	Abilities[3],
	Abilities[4],
	Abilities[1],
	Abilities[1],
	"talent",
	Abilities[1],
	"nil",
	Abilities[4],
	"nil",
	"talent",
	"nil",
	"nil",
	"nil",
	"nil",
	"talent",
}
local TalentTree={
	function()
		return Talents[2]
	end,
	function()
		return Talents[3]
	end,
	function()
		return Talents[6]
	end,
	function()
		return Talents[7]
	end
}
logic.CheckAbilityBuild(AbilityToLevelUp)
function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end
local castDesire = {}
local castTarget = {}
local castLocation = {}
local castType = {}
function CanCast1( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function CanCast2( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function CanCast4( npcEnemy )
	return true
end
local CanCast={CanCast1,CanCast2,CanCast3,CanCast4}
function enemyDisabled(npcEnemy)
	if npcEnemy:IsRooted( ) or npcEnemy:IsStunned( ) or npcEnemy:IsHexed( ) then
		return true;
	end
	return false;
end
local function GetComboDamage()
	return npcBot:GetOffensivePower()
end
local function GetComboMana()
	
	local tempComboMana=0
	if AbilitiesReal[1]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[1]:GetManaCost()
	end
	if AbilitiesReal[2]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[2]:GetManaCost()
	end
	if AbilitiesReal[4]:IsFullyCastable() or AbilitiesReal[4]:GetCooldownTimeRemaining()<=30
	then
		tempComboMana=tempComboMana+AbilitiesReal[4]:GetManaCost()
	end
	
	if AbilitiesReal[1]:GetLevel()<1 or AbilitiesReal[2]:GetLevel()<1 or AbilitiesReal[4]:GetLevel()<1
	then
		tempComboMana=300;
	end
	
	ComboMana=tempComboMana
	return
end
function AbilityUsageThink()
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	
	castDesire[1], castLocation[1] = Consider1();
	castDesire[2], castTarget[2] = Consider2();
	castDesire[3]=0
	castDesire[4] = Consider4();
	
	if(debugmode==true) then
		if(npcBot.LastSpeaktime==nil)
		then
			npcBot.LastSpeaktime=0
		end
		if(GameTime()-npcBot.LastSpeaktime>1)
		then
			for i=1,4,1
			do					
				if ( castDesire[i] > 0 ) 
				then
					if (castType[i]==nil or castType[i]=="target") and castTarget[i]~=nil
					then
						npcBot:ActionImmediate_Chat("try to use skill "..i.." at "..castTarget[i]:GetUnitName().." Desire= "..castDesire[i],true)
					else
						npcBot:ActionImmediate_Chat("try to use skill "..i.." Desire= "..castDesire[i],true)
					end
					npcBot.LastSpeaktime=GameTime()
				end
			end
		end
	end
	
	if ( castDesire[2] > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( AbilitiesReal[2], castTarget[2] );
		return
	end
	if ( castDesire[1] > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( AbilitiesReal[1], castLocation[1] );
		return
	end
	
	if ( castDesire[4] > 0 ) 
	then
		npcBot:Action_UseAbility( AbilitiesReal[4] );
		return
	end
end
function Consider1()	
	local abilityNumber=1
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local CastPoint = ability:GetCastPoint()
	local Radius=ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy )) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetUnitLocation()
		end
	end
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetExtrapolatedLocation(CastPoint+0.5); 
				end
			end
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		for _,npcEnemy in pairs( enemys )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				local Damage2 = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( Damage2 > nMostDangerousDamage )
				then
					nMostDangerousDamage = Damage2;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy:GetExtrapolatedLocation(CastPoint+0.5);
		end
	end
		
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange) 
			then
				if ( CanCast[abilityNumber]( npcEnemy )) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(CastPoint+0.5);
				end
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, CastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
		
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(CastPoint+0.5);
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider2()
	local abilityNumber=2
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy ) and AbilitiesReal[1]:IsFullyCastable()) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end
	
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_PHYSICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana) and npcBot:GetMana()>ComboMana and #allys+1 >=#enemys)
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
				end
			end
		end
	end
	
	
	if((npcBot:WasRecentlyDamagedByAnyHero(5) and npcBot:GetActiveMode() == BOT_MODE_RETREAT))
	then
		local allydistance=npcBot:DistanceFromFountain()
		local npcEnemy
		for _,tempEnemy in pairs( allys )
		do
			tempdistance=tempEnemy:DistanceFromFountain()
			if (tempdistance<allydistance)
			then
				npcEnemy=tempEnemy
				allydistance=tempdistance
			end
		end
		if (npcEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( npcEnemy ))
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		
		if(ManaPercentage>0.4 or npcBot:GetMana()>ComboMana and #allys >=#enemys)
		then
			if ( npcEnemy ~= nil ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy )  and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider4()
	local abilityNumber=4
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local linears=GetLinearProjectiles()
	if(npcBot:GetActiveMode() == BOT_MODE_RETREAT and #enemys>=1)
	then
		for _,linear in pairs(linears)
		do
			if(GetTeamForPlayer(linear.playerid)~=GetTeam() and GetUnitToLocationDistance(npcBot,linear.location)<=600)
			then
				return BOT_ACTION_DESIRE_HIGH+0.05
			end
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		if ( #enemys+#allys >= 6-2*HealthPercentage and #enemys>=2) 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE-0.05
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( npcEnemy:GetHealth()<=npcEnemy:GetActualIncomingDamage(npcBot:GetOffensivePower(),DAMAGE_TYPE_MAGICAL) and GetUnitToUnitDistance(npcEnemy,npcBot)<=Radius-200)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end