local utils = require( GetScriptDirectory().."/logic" )
local EnemyData = {}
local UpdateFreq1 = 0.5
local UpdateFreq2 = 3.0
local heavyRightClickDamage = {
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_sniper",
    "npc_dota_hero_sven",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_ursa",
    "npc_dota_hero_weaver",
    "npc_dota_hero_skeleton_king"
}
local heavyManaDependentEnemies = {
    "npc_dota_hero_leshrac",
    "npc_dota_hero_medusa",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_storm_spirit",
    "npc_dota_hero_zuus"
}
function EnemyData.PurgeEnemy(id)
    EnemyData[id] = {  Name = "", Time1 = -100, Time2 = -100, Level = 1,
                       Alive = true, Health = -1, MaxHealth = -1, Mana = -1, Items = {}, MoveSpeed = 300, 
                       PhysDmg2 = {}, MagicDmg2 = {}, PureDmg2 = {}, AllDmg2 = {},
                       PhysDmg10 = {}, MagicDmg10 = {}, PureDmg10 = {}, AllDmg10 = {},
                       AttackDamage = 0, SecondsPerAttack = 1
                    }
end
function EnemyData.CheckAlive()
    local enemyIDs = GetTeamPlayers(utils.GetOtherTeam())
    
    for _, id in ipairs(enemyIDs) do
        if EnemyData[id] == nil then
            EnemyData.PurgeEnemy(id)
        end
        if IsHeroAlive(id) then
            EnemyData[id].Alive = true
        else
            EnemyData[id].Alive = false
        end
    end
end
function EnemyData.GetNumAlive()
    local numAlive = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" and v.Alive then
            numAlive = numAlive + 1
        end
    end
    return numAlive
end
function EnemyData.UpdateEnemyInfo(timeFreq)
    if ( GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS and GetGameState() ~= GAME_STATE_PRE_GAME ) then return end
    
    EnemyData.CheckAlive()
    
    local enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemy in pairs(enemies) do
        if not utils.ValidTarget(enemy) then
            utils.pause("enemy_data - wtf?")
        end
    
        local pid = enemy:GetPlayerID()
        EnemyData[pid].Name = utils.GetHeroName(enemy)
        if (GameTime() - EnemyData[pid].Time1) >= UpdateFreq1 then
            EnemyData[pid].Time1        = GameTime()
            EnemyData[pid].Level        = enemy:GetLevel()
            EnemyData[pid].Health       = enemy:GetHealth()
            EnemyData[pid].MaxHealth    = enemy:GetMaxHealth()
            EnemyData[pid].Mana         = enemy:GetMana()
            EnemyData[pid].MaxMana      = enemy:GetMaxMana()
            EnemyData[pid].MoveSpeed    = enemy:GetCurrentMovementSpeed()
            if (GameTime() - EnemyData[pid].Time2) >= UpdateFreq2 then
                EnemyData[pid].Time2 = GameTime()
                
                for i = 0, 5, 1 do
                    local item = enemy:GetItemInSlot(i)
                    if item ~= nil then
                        EnemyData[pid].Items[i] = item:GetName()
                    end
                end
                EnemyData[pid].SlowDur = enemy:GetSlowDuration(false)
                EnemyData[pid].StunDur = enemy:GetStunDuration(false)
                EnemyData[pid].HasSilence = enemy:HasSilence(false)
                EnemyData[pid].HasTruestrike = enemy:IsUnableToMiss()
                EnemyData[pid].AttackDamage = enemy:GetAttackDamage()
                EnemyData[pid].SecondsPerAttack = enemy:GetSecondsPerAttack()
                local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
                for _, ally in pairs(allies) do
                    EnemyData[pid].PhysDmg2[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 2.0, DAMAGE_TYPE_PHYSICAL)
                    EnemyData[pid].MagicDmg2[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 2.0, DAMAGE_TYPE_MAGICAL)
                    EnemyData[pid].PureDmg2[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 2.0, DAMAGE_TYPE_PURE)
                    EnemyData[pid].AllDmg2[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 2.0, DAMAGE_TYPE_ALL)
                    EnemyData[pid].PhysDmg10[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 10.0, DAMAGE_TYPE_PHYSICAL)
                    EnemyData[pid].MagicDmg10[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 10.0, DAMAGE_TYPE_MAGICAL)
                    EnemyData[pid].PureDmg10[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 10.0, DAMAGE_TYPE_PURE)
                    EnemyData[pid].AllDmg10[ally:GetPlayerID()] = enemy:GetEstimatedDamageToTarget(true, ally, 10.0, DAMAGE_TYPE_ALL)
                end
            end
        end
    end
end
function EnemyData.GetEnemyDmgs(pid, fDuration)
    local physDmg2 = 0
    local magicDmg2 = 0
    local pureDmg2 = 0
    local allDmg2 = 0
    local physDmg10 = 0
    local magicDmg10 = 0
    local pureDmg10 = 0
    local allDmg10 = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" and v.PhysDmg2[pid] then
            physDmg2    = physDmg2 + v.PhysDmg2[pid]
            magicDmg2   = magicDmg2 + v.MagicDmg2[pid]
            pureDmg2    = pureDmg2 + v.PureDmg2[pid]
            allDmg2     = allDmg2 + v.AllDmg2[pid]
            physDmg10   = physDmg10 + v.PhysDmg10[pid]
            magicDmg10  = magicDmg10 + v.MagicDmg10[pid]
            pureDmg10   = pureDmg10 + v.PureDmg10[pid]
            allDmg10    = allDmg10 + v.AllDmg10[pid]
        end
    end
    local totalDmg2 = physDmg2 + magicDmg2 + pureDmg2
    local totalDmg10 = physDmg10 + magicDmg10 + pureDmg10
    
	if fDuration <= 2.0 then
        return physDmg2, magicDmg2, pureDmg2
    end
    return physDmg10, magicDmg10, pureDmg10
end
function EnemyData.GetEnemySlowDuration(ePID)
    local duration = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number"  and k == ePID then
            duration = v.SlowDur
            break
        end
    end
    return duration
end
function EnemyData.GetEnemyStunDuration(ePID)
    local duration = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number"  and k == ePID then
            duration = v.StunDur
            break
        end
    end
    return duration
end
function EnemyData.GetEnemyTeamSlowDuration()
    local duration = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" then
            duration = duration + v.SlowDur
        end
    end
    return duration
end
function EnemyData.GetEnemyTeamStunDuration()
    local duration = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" then
            duration = duration + v.StunDur
        end
    end
    return duration
end
function EnemyData.GetEnemyTeamNumSilences()
    local num = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" then
            if v.HasSilence then
                num = num + 1
            end
        end
    end
    return num
end
function EnemyData.GetEnemyTeamNumTruestrike()
    local num = 0
    for k, v in pairs(EnemyData) do
        if type(k) == "number" then
            if v.HasTruestrike then
                num = num + 1
            end
        end
    end
    return num
end
function EnemyData.PrintEnemyInfo()
    for k, v in pairs(EnemyData) do
        if type(k) == "number" and v.Name ~= "" then
            print("")
            print("     Name: ", v.Name)
            print("    Level: ", v.Level)
            print("Last Seen: ", v.Time1)
            print("   Health: ", v.Health)
            print("     Mana: ", v.Mana)
            print("       MS: ", v.MoveSpeed)
            local iStr = ""
            for k2, v2 in pairs(v.Items) do
                iStr = iStr .. v2 .. " "
            end
            print("    Items: { "..iStr.." }")
        end
    end
end
return EnemyData