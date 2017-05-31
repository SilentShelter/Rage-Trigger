
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
	Abilities[1],
	Abilities[2],
	Abilities[2],
	Abilities[2],
	Abilities[4],
	Abilities[2],
	Abilities[1],
	Abilities[1],
	"talent",
	Abilities[1],
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
function CanCast3( npcEnemy )
	return
end
function CanCast4( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
local CanCast={CanCast1,CanCast2,CanCast3,CanCast4}
local function GetComboDamage()
	local sum=0
	
	if AbilitiesReal[1]:IsFullyCastable()
	then
		sum=sum+AbilitiesReal[1]:GetAbilityDamage();
	end
	if AbilitiesReal[2]:IsFullyCastable()
	then
		sum=sum+AbilitiesReal[2]:GetAbilityDamage();
	end
	
	return sum
end
local function GetComboMana()
	
	local tempComboMana=0
	if AbilitiesReal[1]:IsFullyCastable()
	then
		tempComboMana=tempComboMana+AbilitiesReal[1]:GetManaCost()
	end
	if AbilitiesReal[4]:IsFullyCastable() or AbilitiesReal[4]:GetCooldownTimeRemaining()<=30
	then
		tempComboMana=tempComboMana+AbilitiesReal[4]:GetManaCost()
	end
	
	if AbilitiesReal[1]:GetLevel()<1 or AbilitiesReal[4]:GetLevel()<1
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
	
	local i=npcBot:FindItemSlot("item_blink")
	if(i>=0 and i<=5)
	then
		blink=npcBot:GetItemInSlot(i)
		i=nil
	end
	
	
	castDesire[1], castTarget[1],castType[1] = Consider1();
	castDesire[2], castTarget[2]= Consider2();
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
					npcBot:ActionImmediate_Chat("try to use skill "..i.." Desire= "..castDesire[i],true)
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
	if ( castDesire[1] > 0 ) 
	then		
		if(castTarget[1]=="immediately")
		then
			npcBot:Action_UseAbility( AbilitiesReal[1] );
			return
		end
		
		if(castType[1]=="blink")
		then
			npcBot:Action_UseAbilityOnLocation( blink, castTarget[1] );
			
			return
		else
			if(castTarget[1]~=nil and GetUnitToUnitDistance(npcBot,castTarget[1])>=300 and GetUnitToUnitDistance(npcBot,castTarget[1])<=1200 and blink~=nil and blink:IsFullyCastable())
			then
				npcBot:Action_UseAbilityOnLocation( blink, castTarget[1]:GetLocation() );
			end
			if(GetUnitToUnitDistance(npcBot,castTarget[1])< AbilitiesReal[1]:GetAOERadius()-AbilitiesReal[1]:GetCastPoint()*castTarget[1]:GetCurrentMovementSpeed())
			then
				npcBot:Action_UseAbility( AbilitiesReal[1] );
				return
			end
		end
	end
	
	if ( castDesire[2] > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( AbilitiesReal[2], castTarget[2] );
		return
	end
end
function Consider1()
	local abilityNumber=1
	
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = 0
	local Damage = ability:GetAbilityDamage()
	local Radius = ability:GetAOERadius()-50
	local CastPoint = ability:GetCastPoint()
	
	if(blink~=nil and blink:IsFullyCastable())
	then
		CastRange=CastRange+1200
		if(npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
		then
			local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH+0.05, locationAoE.targetloc,"blink";
			end
		end
	end
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(Radius+300,true)
	local WeakestCreep,CreepHealth=logic.GetWeakestUnit(creeps)
	
	
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy )) 
		then
			return BOT_ACTION_DESIRE_HIGH,npcEnemy
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
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy
				end
			end
		end
	end
	
	
	if((npcBot:WasRecentlyDamagedByAnyHero(2) and #enemys>=1) or #enemys >=2)
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH,"immediately"
			end
		end
	end
	

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.4 or npcBot:GetMana()>ComboMana) and ability:GetLevel()>=2 )
		then
			if (WeakestEnemy~=nil)
			then
				if ( CanCast[abilityNumber]( WeakestEnemy ) )
				then
					if(GetUnitToUnitDistance(npcBot,WeakestEnemy)<Radius-CastPoint*WeakestEnemy:GetCurrentMovementSpeed())
					then
						return BOT_ACTION_DESIRE_LOW,WeakestEnemy
					end
				end
			end
		end
	end
	
	 
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 ) 
		then
			if(CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW,WeakestCreep
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
			if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)<=Radius)
			then
				return BOT_ACTION_DESIRE_MODERATE,npcEnemy
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
	
	if npcBot:HasModifier("modifier_centaur_stampede") and AbilitiesReal[1]:IsFullyCastable() then
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
		
	  
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM )
	then
		if ( #creeps >= 2 ) 
		then
			if(CreepHealth<=WeakestCreep:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) and HealthPercentage>=0.4)
			then
				return BOT_ACTION_DESIRE_LOW, WeakestCreep;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
		if ( #creeps >= 3 ) 
		then
			if ( CanCast[abilityNumber]( creeps[1] )and GetUnitToUnitDistance(npcBot,creeps[1])< CastRange + 75*#allys and HealthPercentage>=0.6-0.05*#allys)
			then
				return BOT_ACTION_DESIRE_LOW, creeps[1];
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
			if ( CanCast[abilityNumber]( npcEnemy )  and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys and HealthPercentage>=0.6-0.05*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
	
	local CastRange = 1200
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=logic.GetWeakestUnit(enemys)
	
	
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if((HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana) and GetUnitToUnitDistance(npcBot,WeakestEnemy)>=600)
				then
					return BOT_ACTION_DESIRE_HIGH; 
				end
			end
		end
	end
		
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		if(#allys >=2)
		then
			local npcEnemy = npcBot:GetTarget();
			if ( npcEnemy ~= nil ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy )  and GetUnitToUnitDistance(npcBot,npcEnemy)>=600)
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
	
end
function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end