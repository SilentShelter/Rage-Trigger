
require(GetScriptDirectory() ..  "/logic")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local npcBot = GetBot()
local ComboMana = 0
local debugmode=false
local Talents ={}
for i=0,23,1 do
	local ability=npcBot:GetAbilityInSlot(i)
	if(ability~=nil and ability:IsTalent()==true)
	then
		table.insert(Talents,ability:GetName())
	end
end
local Abilities =
{
	"treant_natures_guise",
	"treant_leech_seed",
	"treant_living_armor",
	"treant_overgrowth",
	"treant_eyes_in_the_forest",
}
local AbilitiesReal =
{
	npcBot:GetAbilityByName(Abilities[1]),
	npcBot:GetAbilityByName(Abilities[2]),
	npcBot:GetAbilityByName(Abilities[3]),
	npcBot:GetAbilityByName(Abilities[4]),
	npcBot:GetAbilityByName(Abilities[5])
}
local AbilityToLevelUp=
{
	Abilities[1],
	Abilities[3],
	Abilities[3],
	Abilities[2],
	Abilities[3],
	Abilities[4],
	Abilities[3],
	Abilities[2],
	Abilities[2],
	"talent",
	Abilities[2],
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
		return Talents[4]
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
local castLocation = {}
local castType = {}
function CanCast1( npcEnemy )
	return true
end
function CanCast2( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function CanCast3( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsInvulnerable();
end
function CanCast4( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsInvulnerable();
end
function CanCast5( npcEnemy )
	return true
end
local CanCast={CanCast1,CanCast2,CanCast3,CanCast4,CanCast5}
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
	
	if AbilitiesReal[2]:GetLevel()<1 or AbilitiesReal[3]:GetLevel()<1 or AbilitiesReal[4]:GetLevel()<1
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
	
	
	castDesire[1]=0
	castDesire[2], castTarget[2] = Consider2();
	castDesire[3], castTarget[3] = Consider3();
	castDesire[4] = Consider4();
	castDesire[5], castTarget[5] = Consider4();
	
	if(debugmode==true) then
		if(npcBot.LastSpeaktime==nil)
		then
			npcBot.LastSpeaktime=0
		end
		if(GameTime()-npcBot.LastSpeaktime>1)
		then
			for i=1,5,1
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
	
	if ( castDesire[4] > 0 ) 
	then
		npcBot:Action_UseAbility( AbilitiesReal[4] );
		return
	end
	if ( castDesire[3] > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( AbilitiesReal[3], castTarget[3] );
		return
	end
	
	if ( castDesire[2] > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( AbilitiesReal[2], castTarget[2] );
		return
	end
	if ( castDesire[5] > 0 ) 
	then
		npcBot:Action_UseAbilityOnTree( AbilitiesReal[5], castTarget[5] );
		return
	end
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
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	local StrongestCreep,CreepHealth2=logic.GetStrongestUnit(creeps)
	
	
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
		if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana))
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
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if(CreepHealth2>=600 and npcBot:GetMana()>ComboMana)
		then
			return BOT_ACTION_DESIRE_LOW, StrongestCreep;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
		if (#creeps >= 3 ) 
		then
			if (ManaPercentage>0.5 or npcBot:GetMana()>ComboMana)
			then
				if ( CanCast[abilityNumber]( creeps[1] ) and GetUnitToUnitDistance(npcBot,creeps[1])< CastRange + 75*#allys )
				then
					return BOT_ACTION_DESIRE_LOW, creeps[1];
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
function Consider3()
	local abilityNumber=3
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	
	local HeroHealth=10000
	local allys = npcBot:GetNearbyHeroes( CastRange+300, false, BOT_MODE_NONE );
	local WeakestAlly,AllyHealth=logic.GetWeakestUnit(allys)
	local allys2 = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT) 
	then
		if(#enemys>=1)
		then
			return BOT_ACTION_DESIRE_HIGH,npcBot; 	
		end
	end
	
	
	if(	npcBot:GetActiveMode() == BOT_MODE_ROAM or
		npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		if (WeakestAlly~=nil)
		then
			if(AllyHealth/WeakestAlly:GetMaxHealth()<0.3+0.4*ManaPercentage)
			then
				return BOT_ACTION_DESIRE_MODERATE,WeakestAlly
			end
		end
			
		for _,npcTarget in pairs( allys )
		do
			if(npcTarget:GetHealth()/npcTarget:GetMaxHealth()<(0.6+#enemys*0.05+0.2*ManaPercentage) or npcTarget:WasRecentlyDamagedByAnyHero(5.0))
			then
				if ( CanCast[abilityNumber]( npcTarget ) )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget
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
		
		if(ManaPercentage>0.4)
		then
			if ( npcEnemy ~= nil ) 
			then
				if ( CanCast[abilityNumber]( npcBot ))
				then
					return BOT_ACTION_DESIRE_MODERATE, npcBot;
				end
			end
		end
	end
	
	local WeakestAlly2=nil;
	local HighestFactor=0
	do
		for i,npcTarget in pairs(allys2)
		do
			if(npcTarget:IsAlive() and npcTarget:DistanceFromFountain()>=1000)
			then
				local Threats=npcTarget:GetNearbyHeroes(900,true,BOT_MODE_NONE);
				local Towers=npcTarget:GetNearbyTowers(900,true);
				local TempFactor=(1-npcTarget:GetHealth()/npcTarget:GetMaxHealth())+(#Threats+#Towers)*0.05+0.05*(5-math.min(5,npcTarget:TimeSinceDamagedByAnyHero()))
				
				if TempFactor>HighestFactor
				then
					WeakestAlly2=npcTarget;
					HighestFactor=TempFactor
				end
			
				if(HighestFactor>=0.4)
				then
					if ( CanCast[abilityNumber]( npcTarget ) )
					then
						return BOT_ACTION_DESIRE_MODERATE, WeakestAlly2
					end
				end
			end
		end
	end
	
	if (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
	then
		local WeakestTower=nil
		local LowestHP=1;
		for i=0,11,1 
		do
			local tower=GetTower(GetTeam(),i);
			if (tower~=nil)
			then
				local creeps_t=tower:GetNearbyCreeps(800,true)
				if(creeps_t==nil)
				then
					creeps_t={}
				end
				if (tower:IsAlive() and tower:GetHealth()/tower:GetMaxHealth()<LowestHP and #creeps_t<=2) 
				then
					LowestHP=tower:GetHealth()/tower:GetMaxHealth();
					WeakestTower=tower;
				end
			end
		end
		
		if LowestHP<0.80 then
			return BOT_ACTION_DESIRE_LOW, WeakestTower
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 ) 
		then
			if(ManaPercentage>0.5)
			then
				return BOT_ACTION_DESIRE_LOW,npcBot; 
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
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		if ( npcBot:WasRecentlyDamagedByAnyHero(2) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE-0.05
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		if ( #enemys+#allys >= 4 and #enemys >=2) 
		then
			return BOT_ACTION_DESIRE_HIGH
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
function Consider5()
	local abilityNumber=5
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() or not npcBot:HasScepter()  then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	
	local trees=npcBot:GetNearbyTrees( CastRange )
	
	if ( npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if ( #trees>=1 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE,trees[1]
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end