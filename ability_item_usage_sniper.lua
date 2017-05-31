
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local debugmode=false
local npcBot = GetBot()
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}
ability_item_usage_generic.InitAbility(Abilities,AbilitiesReal,Talents) 
local AbilityToLevelUp=
{
	Abilities[1],
	Abilities[3],
	Abilities[1],
	Abilities[2],
	Abilities[1],
	Abilities[4],
	Abilities[1],
	Abilities[2],
	Abilities[2],
	"talent",
	Abilities[2],
	Abilities[4],
	Abilities[3],
	Abilities[3],
	"talent",
	Abilities[3],
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
		return Talents[4]
	end,
	function()
		return Talents[5]
	end,
	function()
		return Talents[7]
	end
}
logic.CheckAbilityBuild(AbilityToLevelUp)
function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end
local cast={} cast.Desire={} cast.Target={} cast.Type={}
local Consider ={}
local CanCast={logic.NCanCast,logic.NCanCast,logic.NCanCast,logic.UCanCast}
local enemyDisabled=logic.enemyDisabled
function GetComboDamage()
	return ability_item_usage_generic.GetComboDamage(AbilitiesReal)
end
function GetComboMana()
	return ability_item_usage_generic.GetComboMana(AbilitiesReal)
end
Consider[1]=function()
	local Radius = AbilitiesReal[1]:GetAOERadius()
	
	if(npcBot.Sniper1==nil)
	then
		npcBot.Sniper1={}
	end
	
	local desire,templocation=Consider1()
	
	if(desire~=0)
	then
		for _,i in pairs(npcBot.Sniper1)
		do
			if(DotaTime()>=i.timer+10)
			then
				table.remove(npcBot.Sniper1,_)
			end
			if(logic.PointToPointDistance(i.location,templocation))<Radius*1.5 or (DotaTime()-i.timer<=2)
			then
				desire=0
			end
		end
	end
	
	if(desire==0) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	else
		table.insert(npcBot.Sniper1,{timer=DotaTime(),location=templocation})
		return desire,templocation
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
	local Radius = ability:GetAOERadius()
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetExtrapolatedLocation(CastPoint); 
				end
			end
		end
	end
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, Damage );
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(CastPoint);
				end
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	
		local npcEnemy = npcBot:GetTarget();
		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(CastPoint);
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
Consider[4]=function()
	local abilityNumber=4
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys2 = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE)
	local enemys = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for i,enemy in pairs(enemys)
	do
		if(GetUnitToUnitDistance(npcBot,enemy)>CastRange)
		then
			table.remove(enemys,i)
		end
	end
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy )) 
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
				if(HeroHealth+WeakestEnemy:GetHealthRegen()*CastPoint<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
				end
			end
		end
	end
	
	

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT) 
	then
		if(ManaPercentage>0.5 or npcBot:GetMana()>ComboMana )
		then
			if (WeakestEnemy~=nil and #enemys2==0)
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
		if ( npcEnemy ~= nil and #enemys2==0) 
		then
			if ( CanCast[abilityNumber]( npcEnemy )  and GetUnitToUnitDistance(npcBot,npcEnemy)>600)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function AbilityUsageThink()
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	ComboMana=GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	cast=ability_item_usage_generic.ConsiderAbility(AbilitiesReal,Consider)
	
	if(debugmode==true)
	then
		ability_item_usage_generic.PrintDebugInfo(AbilitiesReal,cast)
	end
	ability_item_usage_generic.UseAbility(AbilitiesReal,cast)
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end