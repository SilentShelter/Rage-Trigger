
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local npcBot = GetBot()
local ComboMana = 0
local debugmode=false
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}
for i=0,23,1 do
	local ability=npcBot:GetAbilityInSlot(i)
	if(ability~=nil)
	then
		if(ability:IsTalent()==true)
		then
			table.insert(Talents,ability:GetName())
		else
			table.insert(Abilities,ability:GetName())
			table.insert(AbilitiesReal,ability)
		end
	end
end
local AbilityToLevelUp=
{
	Abilities[1],
	Abilities[3],
	Abilities[2],
	Abilities[1],
	Abilities[1],
	Abilities[4],
	Abilities[1],
	Abilities[3],
	Abilities[3],
	"talent",
	Abilities[3],
	Abilities[4],
	Abilities[2],
	Abilities[2],
	"talent",
	Abilities[2],
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
		return Talents[1]
	end,
	function()
		return Talents[3]
	end,
	function()
		return Talents[5]
	end,
	function()
		return Talents[8]
	end
}
logic.CheckAbilityBuild(AbilityToLevelUp)
function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end
local castDesire = {}
local castTarget = {}
local castType = {}
function CanCast1( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
local CanCast={logic.NCanCast,logic.MiCanCast,logic.MiCanCast,logic.MiCanCast}
local enemyDisabled=logic.enemyDisabled
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
	if AbilitiesReal[3]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[3]:GetManaCost()
	end	
	if AbilitiesReal[4]:IsFullyCastable() or AbilitiesReal[4]:GetCooldownTimeRemaining()<=30
	then
		tempComboMana=tempComboMana+AbilitiesReal[4]:GetManaCost()
	end
	
	if AbilitiesReal[1]:GetLevel()<1 or AbilitiesReal[2]:GetLevel()<1 or AbilitiesReal[3]:GetLevel()<1 or AbilitiesReal[4]:GetLevel()<1
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
	
	
	castDesire[1], castTarget[1], castType[1] = Consider1();
	castDesire[2], castTarget[2], castType[2] = Consider2();
	castDesire[3], castTarget[3], castType[3] = Consider3();
	castDesire[4], castTarget[4], castType[4] = Consider4();
	
	if(debugmode==true) then
			for i=1,#AbilitiesReal
			do					
				if ( castDesire[i] > 0 ) 
				then
					if (castType[i]==nil or castType[i]=="target") and castTarget[i]~=nil
					then
						logic.DebugTalk("try to use skill "..i.." at "..castTarget[i]:GetUnitName().." Desire= "..castDesire[i])
					else
						logic.DebugTalk("try to use skill "..i.." Desire= "..castDesire[i])
					end
				end
			end
	end
	
	local HighestDesire=0
	local HighestDesireAbility=0
	local HighestDesireAbilityBumber=0
	for i,ability in pairs(AbilitiesReal)
	do
		if (castDesire[i]>HighestDesire)
		then
			HighestDesire=castDesire[i]
			HighestDesireAbilityBumber=i
		end
	end
	if( HighestDesire>0)
	then
		local j=HighestDesireAbilityBumber
		local ability=AbilitiesReal[j]
		
				if(castType[j]==nil)
				then
					if(logic.CheckFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_NO_TARGET))
					then
						npcBot:Action_UseAbility( ability )
						return
					elseif(logic.CheckFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_POINT))
					then
						npcBot:Action_UseAbilityOnLocation( ability , castTarget[j])
						return
					else
						npcBot:Action_UseAbilityOnEntity( ability , castTarget[j])
						return
					end
				else
					if(castType[j]=="Target")
					then
						npcBot:Action_UseAbilityOnEntity( ability , castTarget[j])
						return
					elseif(castType[j]=="Location")
					then
						npcBot:Action_UseAbilityOnLocation( ability , castTarget[j])
						return
					else
						npcBot:Action_UseAbility( ability )
						return
					end
				end
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
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
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
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy))
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
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	
	local enemys2 = npcBot:GetNearbyHeroes( 400, true, BOT_MODE_NONE );
	if(npcBot:WasRecentlyDamagedByAnyHero(5))
	then
		for _,npcEnemy in pairs( enemys2 )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy)) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if(ManaPercentage>0.5 or npcBot:GetMana()>ComboMana)
		then
			if (WeakestEnemy~=nil)
			then
				if ( CanCast[abilityNumber]( WeakestEnemy ) )
				then
					return BOT_ACTION_DESIRE_LOW,WeakestEnemy;
				end
			end
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
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
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
	local allys = npcBot:GetNearbyHeroes( CastRange+300, false, BOT_MODE_NONE );
	local WeakestAlly,AllyHealth=logic.GetWeakestUnit(allys)
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	

	for _,npcTarget in pairs( allys )
	do
		local enemys2 = npcTarget:GetNearbyHeroes(600,true,BOT_MODE_NONE)
		if(npcTarget:GetHealth()/npcTarget:GetMaxHealth()<=0.2+0.05*#enemys2)
		then
			local Damage2=0
			for _,npcEnemy in pairs( enemys2 )
			do
				Damage2 =Damage2 + npcEnemy:GetEstimatedDamageToTarget( true, npcBot, 2.0, DAMAGE_TYPE_ALL );
			end
			if(npcTarget:GetHealth()<Damage2*1.25 or npcTarget:GetHealth()/npcTarget:GetMaxHealth()<=0.25)
			then
				return BOT_ACTION_DESIRE_HIGH+0.15, npcTarget
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function Consider3()
	local abilityNumber=3
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetSpecialValueInt("damage")
	local Radius = ability:GetSpecialValueInt("damage_radius")
	local RadiusAlly = ability:GetSpecialValueInt("bounce_radius")
	local MaxTarget=ability:GetSpecialValueInt("max_targets")
	local DamageType=DAMAGE_TYPE_PHYSICAL
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( CastRange+300, false, BOT_MODE_NONE );
	local WeakestAlly,AllyHealth=logic.GetWeakestUnit(allys)
	local enemys = npcBot:GetNearbyHeroes(CastRange+200,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	for _,npcEnemy in pairs(enemys)
	do
		local allyCreeps = npcEnemy:GetNearbyCreeps(Radius,false)
		local allyHeroes = npcEnemy:GetNearbyHeroes(Radius,false,BOT_MODE_NONE)
		local RadiusCount = math.min(MaxTarget,#allyCreeps+#allyHeroes)
		local RealDamage = RadiusCount*Damage
		local Target
		if(allyCreeps~=nil)
		then
			Target=allyCreeps[1]
		else
			Target=allyHeroes[1]
		end
		
		
		
		if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				if(npcEnemy:GetHealth()<=npcEnemy:GetActualIncomingDamage(RealDamage,DamageType))
				then
					return BOT_ACTION_DESIRE_HIGH,Target;
				end
			end
		end
		
		
		if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
			 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
		then
			local npcEnemy2=npcBot:GetTarget()
			if(npcEnemy ~= nil)
			then
				if ( npcEnemy==npcEnemy2 ) 
				then
					if ( CanCast[abilityNumber]( npcEnemy ) )
					then
						return BOT_ACTION_DESIRE_MODERATE,Target
					end
				end
			end
		end
		
		
		if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
		then
			if(ManaPercentage>0.4 and RadiusCount>=3 )
			then
				if ( CanCast[abilityNumber]( npcEnemy ) )
				then
					return BOT_ACTION_DESIRE_LOW,Target
				end
			end
		end
	
	end
		
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	
	for _,npcTarget in pairs (allys)
	do
		local enemys2=npcTarget:GetNearbyHeroes(600,true,BOT_MODE_NONE)
		local allyHeroes = npcTarget:GetNearbyHeroes(RadiusAlly,false,BOT_MODE_NONE)
		local RadiusCount = #allyHeroes
		local HpFactor=math.min(0.9,0.3+0.05*#enemys2+0.3*ManaPercentage+0.1*RadiusCount)
		
		if(npcBot:GetActiveMode() == BOT_MODE_ATTACK)
		then
			HpFactor=math.min(0.9,HpFactor+0.2)
		end
		if(npcTarget:GetHealth()/npcTarget:GetMaxHealth()< HpFactor )
		then
			if ( CanCast[abilityNumber]( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget
			end
		end
		
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT )
	then
		if(ManaPercentage>0.5)
		then
			for _,npcTarget in pairs (creeps)
			do
				local enemyCreeps = npcTarget:GetNearbyCreeps(Radius,true)
				if(enemyCreeps~=nil and #enemyCreeps>=3)
				then
					return BOT_ACTION_DESIRE_LOW,npcTarget; 
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
	local Damage = 0
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() == BOT_MODE_ATTACK)
	then
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE-0.04, locationAoE.targetloc;
		end
			
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE-0.04, locationAoE.targetloc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end