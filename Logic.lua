_G._savedEnv = getfenv()
module("logic", package.seeall)
function NCanCast( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsMagicImmune() and not npcEnemy:IsInvulnerable();
end
function MiCanCast( npcEnemy )
	return npcEnemy:CanBeSeen() and not npcEnemy:IsInvulnerable();
end
UCanCast=MiCanCast
function CheckFlag( nBehavior, nFlag )
	if ( nFlag == 0 ) then
		if ( nBehavior == 0 ) then
			return true;
		else
			return false;
		end
	end
	return ( (nBehavior / nFlag) % 2 ) >= 1;
end
function PerryGetHeroLevel()
    local npcBot = GetBot();
    local respawnTable = {8, 10, 12, 14, 16, 26, 28, 30, 32, 34, 36, 46, 48, 50, 52, 54, 56, 66, 70, 74, 78,  82, 86, 90, 100};
    local nRespawnTime = npcBot:GetRespawnTime() +1
    for k,v in pairs (respawnTable) do
        if v == nRespawnTime then
        return k
        end
    end
end
function enemyDisabled(npcEnemy)
	if npcEnemy:IsRooted( ) or npcEnemy:IsStunned( ) or npcEnemy:IsHexed( ) then
		return true;
	end
	return false;
end
function IsEnemy(hUnit)
	local ourTeam=GetTeam()
	local Team=GetTeamForPlayer(hUnit:GetPlayerID())
	if ourTeam==Team
	then
		return false
	else
		return true
	end
end
function PointToPointDistance(a,b)
	local x1=a.x
	local x2=b.x
	local y1=a.y
	local y2=b.y
	return math.sqrt(math.pow((y2-y1),2)+math.pow((x2-x1),2))
end 
function CDOTA_Bot_Script:GetForwardVector()
    local radians = self:GetFacing() * math.pi / 180
    local forward_vector = Vector(math.cos(radians), math.sin(radians))
    return forward_vector
end
function CDOTA_Bot_Script:IsFacingUnit( hTarget, degAccuracy )
    local direction = (hTarget:GetLocation() - self:GetLocation()):Normalized()
    local dot = direction:Dot(self:GetForwardVector())
    local radians = degAccuracy * math.pi / 180
    return dot > math.cos(radians)
end
function CDOTA_Bot_Script:GetXUnitsTowardsLocation( vLocation, nUnits)
    local direction = (vLocation - self:GetLocation()):Normalized()
    return self:GetLocation() + direction * nUnits
end
function CDOTA_Bot_Script:GetXUnitsInFront( nUnits )
    return self:GetLocation() + self:GetForwardVector() * nUnits
end
function CDOTA_Bot_Script:GetXUnitsInBehind( nUnits )
    return self:GetLocation() - self:GetForwardVector() * nUnits
end
function GetUnitsTowardsLocation(unit,target,nUnits)
	vMyLocation,vTargetLocation=unit:GetLocation(),target:GetLocation()
	local tempvector=(vTargetLocation-vMyLocation)/PointToPointDistance(vMyLocation,vTargetLocation)
	return vMyLocation+nUnits*tempvector
end
function RandomInCastRangePoint(unit,target,CastRange,distance)
	local i=0
	repeat
		l=GetUnitsTowardsLocation(unit,target,GetUnitToUnitDistance(unit,target)/2)+RandomVector(RandomInt(0,distance))
		d=GetUnitToLocationDistance(unit,l)
		i=i+1
	until( d<=CastRange or i>=10)
	if(i>=10)
	then
		return GetUnitsTowardsLocation(unit,target,distance)
	else
		return l
	end
end
function GetSafeVector(unit,distance)
	v=RandomVector(distance)
	if(unit:GetTeam()==TEAM_RADIANT)
	then
		if(v.x>0)
		then
			v.x=-v.x
		end
		if(v.y>0)
		then
			v.y=-v.y
		end
	else
		if(v.x<0)
		then
			v.x=-v.x
		end
		if(v.y<0)
		then
			v.y=-v.y
		end
	end
	return v
end
function Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end
function GetOtherTeam()
	if GetTeam()==TEAM_RADIANT then
		return TEAM_DIRE;
	else
		return TEAM_RADIANT;
	end
end
function GetWeakestUnit(EnemyUnits)
	
	if EnemyUnits==nil or #EnemyUnits==0 then
		return nil,10000;
	end
	
	local WeakestUnit=nil;
	local LowestHealth=10000;
	for _,unit in pairs(EnemyUnits) 
	do
		if unit~=nil and unit:IsAlive() 
		then
			if unit:GetHealth()<LowestHealth 
			then
				LowestHealth=unit:GetHealth();
				WeakestUnit=unit;
			end
		end
	end
	
	return WeakestUnit,LowestHealth
end
function GetStrongestUnit(EnemyUnits)
	
	if EnemyUnits==nil or #EnemyUnits==0 then
		return nil,0;
	end
	
	local StrongestUnit=nil;
	local HighestHealth=0;
	for _,unit in pairs(EnemyUnits) 
	do
		if unit~=nil and unit:IsAlive() 
		then
			if unit:GetHealth()>HighestHealth
			then
				HighestHealth=unit:GetHealth();
				StrongestUnit=unit;
			end
		end
	end
	
	return StrongestUnit,HighestHealth
end
function ItemPurchase(ItemsToBuy)
	local npcBot = GetBot();
		
	item_travel_boots_1 = nil;
	item_travel_boots_2 = nil;
	local item_travel_boots = NoNeedTpscrollForTravelBoots();
	item_travel_boots_1 = item_travel_boots[1];
	item_travel_boots_2 = item_travel_boots[2];
	
	if(npcBot.secretShopMode~=true and npcBot.sideShopMode ~=true or npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()+50)
	then
		WeNeedTpscroll();
	end
	if ( #ItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
	local sNextItem = ItemsToBuy[1];
	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) )
	
	if(IsItemSlotsFull())
	then
		if(GameTime()>15*60)
		then
			SellSpecifiedItem("item_faerie_fire")
			SellSpecifiedItem("item_enchanted_mango")
			SellSpecifiedItem("item_tango")
			SellSpecifiedItem("item_clarity")
			SellSpecifiedItem("item_flask")
		end
		if(GameTime()>20*60)
		then
			SellSpecifiedItem("item_stout_shield")
			SellSpecifiedItem("item_orb_of_venom")
		end
		if(GameTime()>30*60)
		then
			SellSpecifiedItem("item_branches")
			SellSpecifiedItem("item_bottle")
			SellSpecifiedItem("item_magic_wand")
			SellSpecifiedItem("item_magic_stick")
			SellSpecifiedItem("item_urn_of_shadows")
			SellSpecifiedItem("item_wind_lace")
			SellSpecifiedItem("item_ring_of_aquila")
			SellSpecifiedItem("item_ring_of_basilius")
		end
		if(GameTime()>40*60 and npcBot:GetGold()>2200 and (GetItemIncludeBackpack("item_travel_boots")==nil and GetItemIncludeBackpack("item_travel_boots_2")==nil) and npcBot.HaveTravelBoots~=true )
		then
			SellSpecifiedItem("item_arcane_boots")
			SellSpecifiedItem("item_phase_boots")
			SellSpecifiedItem("item_power_treads_agi")
			SellSpecifiedItem("item_power_treads_int")
			SellSpecifiedItem("item_power_treads_str")
			SellSpecifiedItem("item_tranquil_boots")
			table.insert(ItemsToBuy,"item_boots")
			table.insert(ItemsToBuy,"item_recipe_travel_boots")
			npcBot.HaveTravelBoots=true
		end
	end
	
	if(npcBot:DistanceFromFountain()<=1000 or npcBot:GetHealth()/npcBot:GetMaxHealth()<=0.4)
	then
		npcBot.secretShopMode = false;
		npcBot.sideShopMode = false;
	end
	
	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		local DeterminationShop="HomeShop"
		
		if(npcBot.secretShopMode~=true and npcBot.sideShopMode ~=true)
		then
			if(IsItemPurchasedFromSecretShop( sNextItem ) and IsItemPurchasedFromSideShop( sNextItem ))
			then
				if(npcBot:DistanceFromSecretShop() >= npcBot:DistanceFromSideShop())
				then
					DeterminationShop="SideShop"
				else
					DeterminationShop="SecretShop"
				end
			else
				if (IsItemPurchasedFromSideShop( sNextItem ) and npcBot:DistanceFromSideShop() <=3000) then
					DeterminationShop="SideShop"
				elseif (IsItemPurchasedFromSecretShop( sNextItem )) then
					DeterminationShop="SecretShop"
				end
			end
			
			if ( DeterminationShop=="SecretShop" ) then
				
				npcBot.secretShopMode = true;
				npcBot.sideShopMode = false;
			elseif ( DeterminationShop=="SideShop" ) then
				
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = true;
				
			end
		end
		
	
		
		local PurchaseResult
		
		if(npcBot.sideShopMode == true)
		then
			if(npcBot:DistanceFromSideShop() <= 200)
			then
				PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
			end
		elseif(npcBot.secretShopMode == true)
		then
			if(npcBot:DistanceFromSecretShop() <= 200)
			then
				PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
			end
			
			local courier=GetCourier(0)
			if(courier==nil)
			then
				BuyCourier()
			else
				if(courier:DistanceFromSecretShop() <= 200)
				then
					PurchaseResult=GetCourier(0):ActionImmediate_PurchaseItem( sNextItem )
					if(PurchaseResult==PURCHASE_ITEM_SUCCESS)
					then
						npcBot:ActionImmediate_Courier(GetCourier(0), COURIER_ACTION_TRANSFER_ITEMS)
					end
				end
			end
		else
			PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
		end
		
		if(PurchaseResult==PURCHASE_ITEM_SUCCESS)
		then
			
			npcBot.secretShopMode = false;
			npcBot.sideShopMode = false;
			table.remove( ItemsToBuy, 1 )
		end
		if(PurchaseResult==PURCHASE_ITEM_OUT_OF_STOCK)
		then
			SellSpecifiedItem("item_branches")
			SellSpecifiedItem("item_faerie_fire")
		end
		if(PurchaseResult==PURCHASE_ITEM_INVALID_ITEM_NAME or PurchaseResult==PURCHASE_ITEM_DISALLOWED_ITEM)
		then
			table.remove( ItemsToBuy, 1 )
		end
		if(PurchaseResult==PURCHASE_ITEM_NOT_AT_SECRET_SHOP)
		then
			npcBot.secretShopMode = true
		end
		
	end
end
function BuyCourier()
	local npcBot=GetBot()
	local courier=GetCourier(0)
	if(courier==nil)
	then
		if(npcBot:GetGold()>=GetItemCost("item_flying_courier"))
		then
			local info=npcBot:ActionImmediate_PurchaseItem("item_courier");
			if info ==PURCHASE_ITEM_SUCCESS then
				print(npcBot:GetUnitName()..' buy the courier',info);
			end
		end
	else
		if DotaTime()>60*4 and npcBot:GetGold()>=GetItemCost("item_flying_courier") and (courier:GetMaxHealth()==75) then
			local info=npcBot:ActionImmediate_PurchaseItem("item_flying_courier");
			if info ==PURCHASE_ITEM_SUCCESS then
				print(npcBot:GetUnitName()..' has upgraded the courier.',info);
			end
		end
	end
	
end
function NoNeedTpscrollForTravelBoots()
	local npcBot = GetBot();
	local item_travel_boots = {};
	local item_travel_boots_1 = nil;
	local item_travel_boots_2 = nil;
	for i = 0, 14 do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil and sCurItem:GetName() == "item_travel_boots_1" ) then
			item_travel_boots_1 = sCurItem;
		end
		if ( sCurItem ~= nil and sCurItem:GetName() == "item_travel_boots_2" ) then
			item_travel_boots_2 = sCurItem;
		end
	end
	if ( item_travel_boots_1 ~= nil or item_travel_boots_2 ~= nil) then
		for i = 0, 14 do
			local sCurItem = npcBot:GetItemInSlot(i);
			if ( sCurItem ~= nil and sCurItem:GetName() == "item_tpscroll" ) then
				npcBot:ActionImmediate_SellItem( "item_tpscroll" );
			end
		end
	end
	item_travel_boots[1] = item_travel_boots_1;
	item_travel_boots[2] = item_travel_boots_2;
	return item_travel_boots;
end
function WeNeedTpscroll()
	local npcBot = GetBot();
	
	local iScrollCount = 0;
	for i = 0, 14 do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil and sCurItem:GetName() == "item_tpscroll" ) then
			iScrollCount = iScrollCount + 1;
		end
	end
	
	if ( iScrollCount == 0 and item_travel_boots_1 == nil and item_travel_boots_2 == nil ) then
		if ( npcBot:DistanceFromSideShop() == 0 or npcBot:DistanceFromFountain() == 0 ) then
			if ( DotaTime() > 0 and DotaTime() < 20 * 60 ) then
				npcBot:ActionImmediate_PurchaseItem( "item_tpscroll" );
			elseif ( DotaTime() >= 20 * 60 ) then
				npcBot:ActionImmediate_PurchaseItem( "item_tpscroll" );
				npcBot:ActionImmediate_PurchaseItem( "item_tpscroll" );
			end
		end
	end
end
function SellSpecifiedItem( item_name )
	local npcBot = GetBot();
	local itemCount = 0;
	local item = nil;
	for i = 0, 14 
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil ) 
		then
			itemCount = itemCount + 1;
			if ( sCurItem:GetName() == item_name ) 
			then
				item = sCurItem;
			end
		end
	end
	if ( item ~= nil and itemCount > 5 and (npcBot:DistanceFromFountain() <= 600 or npcBot:DistanceFromSideShop() <= 200 or npcBot:DistanceFromSecretShop() <= 200) ) then
		npcBot:ActionImmediate_SellItem( item );
	end
end
function GetItemSlotsCount()
	local npcBot = GetBot();
	local itemCount = 0;
	local item = nil;
	for i = 0, 8
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil ) 
		then
			itemCount = itemCount + 1;
		end
	end
	
	return itemCount
end
function IsItemSlotsFull()
	local itemCount = GetItemSlotsCount();
	
	if(itemCount>=8)
	then
		return true
	else
		return false
	end
end
function checkItemBuild(ItemsToBuy)
	local ItemTableA=
	{
		"item_tango",
		"item_clarity",
		"item_faerie_fire",
		"item_enchanted_mango",
		"item_flask",
	}
	if(DotaTime()>0)
	then
		for _,item in pairs (ItemTableA)
		do
			for _1,item2 in pairs (ItemsToBuy)
			do
				if(item==item2)
				then
					table.remove(ItemsToBuy,_1)
				end
			end
		end
		
		local npcBot=GetBot()
		for _1,item2 in pairs (ItemsToBuy)
		do
			if(npcBot:FindItemSlot(item2)>0)
			then
				table.remove(ItemsToBuy,_1)
			end
		end
	end
end
local invisibleHeroes = {
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_treant",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_mirana",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_riki",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_invoker"
};
function GetItemIncludeBackpack(item_name)
	local npcBot=GetBot()
    for i = 0, 16 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
function CheckInvisibleEnemy()
		local enemyTeam=GetOtherTeam()
		if ( enemyTeam ~= nil ) then
			for _, id in pairs( GetTeamPlayers(enemyTeam) ) 
			do
				for _, invisibleHeroName in pairs(invisibleHeroes) 
				do
					if ( GetSelectedHeroName(id) == invisibleHeroName ) 
					then
						return true
					end
				end
			end
		end
		local enemys=GetUnitList(UNIT_LIST_ENEMY_HEROES)
		if ( enemys ~= nil ) then
			for _,npcEnemy in pairs(enemys)
			do
				if(npcEnemy:HasInvisibility(false))
				then
					return true
				end
			end
		end
		
		return false
end
local hasInvisibleEnemy = false
local BuySupportItem_Timer=DotaTime()
function BuySupportItem()
	local npcBot=GetBot()
	
	
	if(DotaTime()-BuySupportItem_Timer>=10)
	then
		BuySupportItem_Timer=DotaTime()
		hasInvisibleEnemy=CheckInvisibleEnemy()
	end
	
	if(GetItemSlotsCount()<6)
	then
		local item_ward_observer = GetItemIncludeBackpack( "item_ward_observer" );
		local item_ward_sentry2 = GetItemIncludeBackpack( "item_ward_dispenser" )
		if ( DotaTime() >= 0 and hasInvisibleEnemy == true ) then
			local item_dust = GetItemIncludeBackpack( "item_dust" );
			local item_ward_sentry = GetItemIncludeBackpack( "item_ward_sentry" )
			if ( item_dust==nil and item_ward_sentry==nil and item_ward_sentry2==nil and npcBot:GetGold() >= 2*GetItemCost("item_dust") ) then
				npcBot:ActionImmediate_PurchaseItem( "item_dust" );
			end
			if ( item_ward_observer==nil and item_dust==nil and item_ward_sentry==nil and item_ward_sentry2==nil and IsItemSlotsFull()==false and npcBot:GetGold() >= 2*GetItemCost("item_ward_sentry") ) then
				npcBot:ActionImmediate_PurchaseItem( "item_ward_sentry" );
			end
		end
		if ( item_ward_observer==nil and item_ward_sentry2==nil and GetItemStockCount("item_ward_observer") > 1 and npcBot:GetGold() >= GetItemCost("item_ward_observer") and DotaTime()<30*60) then
			npcBot:ActionImmediate_PurchaseItem( "item_ward_observer" );
		end
	end
	
end
function CheckAbilityBuild(AbilityToLevelUp)
	local npcBot=GetBot()
	if #AbilityToLevelUp > 26-npcBot:GetLevel() then
		for i=1, npcBot:GetLevel() do
			print("remove"..AbilityToLevelUp[1])
			table.remove(AbilityToLevelUp, 1)
		end
	end
end
local debug_mode = false
function DebugTalk(message)
	if(debug_mode==true)
	then
		local npcBot=GetBot()
		npcBot:ActionImmediate_Chat(message,true)
	end
end
function DebugTalk_Delay(message)
	local npcBot=GetBot()
	if(npcBot.LastSpeaktime==nil)
	then
		npcBot.LastSpeaktime=0
	end
	if(GameTime()-npcBot.LastSpeaktime>1)
	then
		npcBot:ActionImmediate_Chat(message,true)
		npcBot.LastSpeaktime=GameTime()
	end
end
local courierTime = -90;
local cState = -1;
function CourierUsageThink()
	if npcBot:IsInvulnerable() or not npcBot:IsIllusion() or GetNumCouriers() == 0 then
		return;
	end
	
	local npcCourier = GetCourier(0);	
	local cState = GetCourierState( npcCourier );
	if cState == COURIER_STATE_DEAD then
		return
	end
	
	if IsCourierNearShop(npcCourier) and IdleTime == 0 then
		IdleTime = DotaTime();
	elseif not IsCourierNearShop(npcCourier) then
		IdleTime = 0;
	end
	
	if  not npcBot:IsAlive() and cState == COURIER_STATE_DELIVERING_ITEMS  
		and npcBot:GetCourierValue( ) > 0 and DotaTime() > courierTime + 2.0
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS );
		courierTime = DotaTime();
		return
	end
	
	
	if  cState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() > 00 and 
	( not IsCourierNearShop(npcCourier) or ( IsCourierNearShop(npcCourier) and DotaTime() >= IdleTime + AllowedIddle ))
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and npcBot:IsAlive() and npcBot:GetCourierValue( ) > 0 
	   and not IsInvFull(npcBot) and IsCourierAvailable() and DotaTime() > courierTime + 2.0
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
		courierTime = DotaTime();
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and IsCourierAvailable() and DotaTime() > courierTime + 2.0 then
		local numPlayer =  GetTeamPlayers(GetTeam());
		local maxVal = 0;
		local target = nil;
		for i = 1, #numPlayer
		do
			local member =  GetTeamMember(i);
			if member ~= nil and IsPlayerBot(numPlayer[i]) and member:IsAlive() 
			then
				local SVal = member:GetStashValue();
				if SVal ~= 0 and SVal > maxVal then
					maxVal = SVal;
					target = member;
				end
			end
		end
		
		if target ~= nil 
		then
			target:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
			courierTime = DotaTime();
			return
		end
		
	end
	
end
function IsCourierNearShop(npcCourier)
local Shops = {
	SHOP_SIDE,
	SHOP_SIDE2,
	SHOP_SECRET,
	SHOP_SECRET2
}
for _,shop in pairs(Shops)
do
	local dist = GetUnitToLocationDistance(npcCourier, GetShopLocation(GetTeam(), shop));
	if dist < 600 then
		
		return true;
	end	
end
return false;
end
function IsInvFull(npcHero)
	for i=0, 8 do
		if(npcHero:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end
function CourierCanDeliverItems(npcCourier)
	if GetCourierState( npcCourier ) ~= COURIER_STATE_DELIVERING_ITEMS or GetCourierState( npcCourier ) ~= COURIER_ACTION_RETURN_STASH_ITEMS then
		return true;
	end
	return false;
end
for k,v in pairs( logic ) do _G._savedEnv[k] = v end