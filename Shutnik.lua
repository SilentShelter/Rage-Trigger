
require( GetScriptDirectory().."/constants" )
local gHeroVar = require( GetScriptDirectory().."/global_hero_data" )

U = {}

U.creeps = nil
U.Lanes={[1]=LANE_BOT,[2]=LANE_MID,[3]=LANE_TOP};

U.Locations = {
["RadiantShop"]= Vector(-4739,1263),
["DireShop"]= Vector(4559,-1554),
["BotShop"]= Vector(7253,-4128),
["TopShop"]= Vector(-7236,4444),

["RadiantBase"]= Vector(-7200,-6666),
["RBT1"]= Vector(4896,-6140),
["RBT2"]= Vector(-128,-6244),
["RBT3"]= Vector(-3966,-6110),
["RMT1"]= Vector(-1663,-1510),
["RMT2"]= Vector(-3559,-2783),
["RMT3"]= Vector(-4647,-4135),
["RTT1"]= Vector(-6202,1831),
["RTT2"]= Vector(-6157,-860),
["RTT3"]= Vector(-6591,-3397),
["RadiantTopShrine"]= Vector(-4229,1299),
["RadiantBotShrine"]= Vector(622,-2555),

["DireBase"]= Vector(7137,6548),
["DBT1"]= Vector(6215,-1639),
["DBT2"]= Vector(6242,400),
["DBT3"]= Vector(-6307,3043),
["DMT1"]= Vector(1002,330),
["DMT2"]= Vector(2477,2114),
["DMT3"]= Vector(4197,3756),
["DTT1"]= Vector(-4714,6016),
["DTT2"]= Vector(0,6020),
["DTT3"]= Vector(3512,5778),
["DireTopShrine"]= Vector(-139,2533),
["DireBotShrine"]= Vector(4173,-1613),
};

U["tableNeutralCamps"] = {
    [constants.TEAM_RADIANT] = {
        [1] = {
            [constants.DIFFICULTY] = constants.CAMP_EASY,
            [constants.VECTOR] = constants.RAD_SAFE_EASY,
            [constants.STACK_TIME] = constants.RAD_SAFE_EASY_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_SAFE_EASY_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_SAFE_EASY_STACK
        },
        [2] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.RAD_SAFE_MEDIUM,
            [constants.STACK_TIME] = constants.RAD_SAFE_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_SAFE_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_SAFE_MEDIUM_STACK
        },
        [3] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.RAD_MID_MEDIUM,
            [constants.STACK_TIME] = constants.RAD_MID_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_MID_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_MID_MEDIUM_STACK
        },
        [4] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.RAD_OFF_MEDIUM,
            [constants.STACK_TIME] = constants.RAD_OFF_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_OFF_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_OFF_MEDIUM_STACK
        },
        [5] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.RAD_OFF_HARD,
            [constants.STACK_TIME] = constants.RAD_OFF_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_OFF_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_OFF_HARD_STACK
        },
        [6] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.RAD_MID_HARD,
            [constants.STACK_TIME] = constants.RAD_MID_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_MID_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_MID_HARD_STACK
        },
        [7] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.RAD_SAFE_HARD,
            [constants.STACK_TIME] = constants.RAD_SAFE_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_SAFE_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_SAFE_HARD_STACK
        },
        [8] = {
            [constants.DIFFICULTY] = constants.CAMP_ANCIENT,
            [constants.VECTOR] = constants.RAD_MID_ANCIENT,
            [constants.STACK_TIME] = constants.RAD_MID_ANCIENT_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_MID_ANCIENT_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_MID_ANCIENT_STACK
        },
        [9] = {
            [constants.DIFFICULTY] = constants.CAMP_ANCIENT,
            [constants.VECTOR] = constants.RAD_OFF_ANCIENT,
            [constants.STACK_TIME] = constants.RAD_OFF_ANCIENT_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.RAD_OFF_ANCIENT_PRESTACK,
            [constants.STACK_VECTOR] = constants.RAD_OFF_ANCIENT_STACK
        }
    },
    [constants.TEAM_DIRE] = {
        [1] = {
            [constants.DIFFICULTY] = constants.CAMP_EASY,
            [constants.VECTOR] = constants.DIRE_SAFE_EASY,
            [constants.STACK_TIME] = constants.DIRE_SAFE_EASY_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_SAFE_EASY_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_SAFE_EASY_STACK
        },
        [2] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.DIRE_SAFE_MEDIUM,
            [constants.STACK_TIME] = constants.DIRE_SAFE_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_SAFE_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_SAFE_MEDIUM_STACK
        },
        [3] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.DIRE_MID_MEDIUM,
            [constants.STACK_TIME] = constants.DIRE_MID_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_MID_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_MID_MEDIUM_STACK
        },
        [4] = {
            [constants.DIFFICULTY] = constants.CAMP_MEDIUM,
            [constants.VECTOR] = constants.DIRE_OFF_MEDIUM,
            [constants.STACK_TIME] = constants.DIRE_OFF_MEDIUM_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_OFF_MEDIUM_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_OFF_MEDIUM_STACK
        },
        [5] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.DIRE_OFF_HARD,
            [constants.STACK_TIME] = constants.DIRE_OFF_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_OFF_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_OFF_HARD_STACK
        },
        [6] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.DIRE_MID_HARD,
            [constants.STACK_TIME] = constants.DIRE_MID_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_MID_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_MID_HARD_STACK
        },
        [7] = {
            [constants.DIFFICULTY] = constants.CAMP_HARD,
            [constants.VECTOR] = constants.DIRE_SAFE_HARD,
            [constants.STACK_TIME] = constants.DIRE_SAFE_HARD_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_SAFE_HARD_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_SAFE_HARD_STACK
        },
        [8] = {
            [constants.DIFFICULTY] = constants.CAMP_ANCIENT,
            [constants.VECTOR] = constants.DIRE_MID_ANCIENT,
            [constants.STACK_TIME] = constants.DIRE_MID_ANCIENT_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_MID_ANCIENT_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_MID_ANCIENT_STACK
        },
        [9] = {
            [constants.DIFFICULTY] = constants.CAMP_ANCIENT,
            [constants.VECTOR] = constants.DIRE_OFF_ANCIENT,
            [constants.STACK_TIME] = constants.DIRE_OFF_ANCIENT_STACKTIME,
            [constants.PRE_STACK_VECTOR] = constants.DIRE_OFF_ANCIENT_PRESTACK,
            [constants.STACK_VECTOR] = constants.DIRE_OFF_ANCIENT_STACK
        }
    }
}

U.SIDE_SHOP_TOP = Vector(-7220,4430)
U.SIDE_SHOP_BOT = Vector(7249,-4113)
U.SECRET_SHOP_RADIANT = Vector(-4472,1328)
U.SECRET_SHOP_DIRE = Vector(4586,-1588)
U.ROSHAN = Vector(-2405, 1905)

U.MapSafeSpots = {
    Vector(-7180, 4811),
    Vector(-6237, 4985),
    Vector(-6998, 3659),
    Vector(-5255, 4484),
    Vector(-6159, 3385),
    Vector(-4433, 4719),
    Vector(-3377, 5090),
    Vector(-2825, 4122),
    Vector(-3255, 5888),
    Vector(-2217, 6228),
    Vector(-1943, 4920),
    Vector(-795, 4994),
    Vector(-22, 4096),
    Vector(-1547, 3720),
    Vector(-934, 3393),
    Vector(-1973, 2805),
    Vector(-3560, 2460),
    Vector(1521, 4209),
    Vector(2843, 3738),
    Vector(2104, 3646),
    Vector(1817, 2787),
    Vector(1039, 2342),
    Vector(3990, 2831),
    Vector(-196, 2329),
    Vector(4173, 1950),
    Vector(3599, 1042),
    Vector(3160, -148),
    Vector(5146, 1849),
    Vector(1965, 571),
    Vector(1982, -113),
    Vector(2399, -1029),
    Vector(1669, -816),
    Vector(-335, 1282),
    Vector(-300, 209),
    Vector(-1743, 1195),
    Vector(-2012, 462),
    Vector(-2504, 9),
    Vector(-3338, -1213),
    Vector(-1221, -471),
    Vector(-517, -1230),
    Vector(-535, -2006),
    Vector(-1274, -2486),
    Vector(700, -2608),
    Vector(2021, -2425),
    Vector(2838, -2085),
    Vector(4386, -1535),
    Vector(4803, -131),
    Vector(-4525, 1317),
    Vector(-5003, 314),
    Vector(-5994, 628),
    Vector(-3447, -1117),
    Vector(-4872, -1056),
    Vector(-4412, -1884),
    Vector(-2873, -2041),
    Vector(-2417, -2465),
    Vector(-2404, -2791),
    Vector(-1908, -3027),
    Vector(-1704, -3795),
    Vector(-400, -4353),
    Vector(1095, -4327),
    Vector(-2817, -3969),
    Vector(1469, -4745),
    Vector(3269, -5295),
    Vector(3156, -6132),
    Vector(2025, -6211),
    Vector(3703, -3768),
    Vector(4486, -5033),
    Vector(5972, -4964),
    Vector(7354, -4144),
    Vector(7467, -3149),
    Vector(-3992, 3886),
    Vector(-5444, 3999)
}

U.RadiantSafeSpots = {unpack(U.MapSafeSpots)}
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RadiantBase
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RBT1
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RBT2
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RBT3
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RMT1
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RMT2
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RMT3
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RTT1
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RTT2
U.RadiantSafeSpots[#U.RadiantSafeSpots+1] = U.Locations.RTT3

U.DireSafeSpots = {unpack(U.MapSafeSpots)}
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DireBase
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DBT1
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DBT2
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DBT3
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DMT1
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DMT2
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DMT3
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DTT1
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DTT2
U.DireSafeSpots[#U.DireSafeSpots+1] = U.Locations.DTT3

function setHeroVar(var, value)
    local bot = GetBot()
    gHeroVar.SetVar(bot:GetPlayerID(), var, value)
end

function getHeroVar(var)
    local bot = GetBot()
    return gHeroVar.GetVar(bot:GetPlayerID(), var)
end

function U.GetOppositeTeamTo(team)
  if team == constants.TEAM_RADIANT then
    return constants.TEAM_DIRE
  else
    return constants.TEAM_RADIANT
  end
end

function U.InTable (tab, val)
    if not tab then return false end
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

function U.PosInTable(tab, val)
    for index,value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return -1
end

function U.Spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function U.PairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function ()
       i = i + 1
       if a[i] == nil then return nil
       else return a[i], t[a[i]]
       end
    end
    return iter
end

function U.SortFunc(a , b)
    if a < b then
        return true
    end
    return false
end

function U.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[U.deepcopy(orig_key)] = U.deepcopy(orig_value)
        end
        setmetatable(copy, U.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function U.clone(org)
    return {unpack(org)}
end

function U.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function U.GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function U.VectorTowards(start, towards, distance)
    local facing = towards - start
    local direction = facing / U.GetDistance(facing, Vector(0,0))
    return start + (direction * distance)
end

function U.VectorAway(start, towards, distance)
    local facing = start - towards
    local direction = facing / U.GetDistance(facing, Vector(0,0))
    return start + (direction * distance)
end

function U.Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function U.GetHeightDiff(hUnit1, hUnit2)
    if not U.ValidTarget(hUnit1) then return 0 end
    
    if type(hUnit2) == "number" then
        return (hUnit1:GetLocation().z - hUnit2)
    end
    
    if not U.ValidTarget(hUnit2) then return 0 end
    
    return (hUnit1:GetLocation().z - hUnit2:GetLocation().z)
end

function U.EnemyDistanceFromTheirAncient( hEnemy )
    local locAncient = GetAncient(U.GetOtherTeam()):GetLocation()
    if U.ValidTarget(hEnemy) then
        return U.GetDistance( locAncient, hEnemy:GetLocation() )
    end
    return 0
end

function U.TimeForEnemyToGetIntoTheirBase( hEnemy )
    local distFromBase = U.EnemyDistanceFromTheirAncient( hEnemy )
    return distFromBase/hEnemy:GetCurrentMovementSpeed()
end

function U.IsFacingLocation(hero, loc, delta)
    if not U.ValidTarget(hero) then return false end

    local facing = hero:GetFacing()
    local moveVect = loc - hero:GetLocation()

    moveVect = moveVect / (U.GetDistance(Vector(0,0), moveVect))

    local moveAngle = math.atan2(moveVect.y, moveVect.x)/math.pi * 180

    if moveAngle < 0 then
        moveAngle = 360 + moveAngle
    end
    facing = (facing + 360) % 360

    if (math.abs(moveAngle - facing) < delta or
        math.abs(moveAngle + 360 - facing) < delta or
        math.abs(moveAngle - 360 - facing) < delta) then
        return true
    end
    return false
end

function U.AreTreesBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()

    local trees = bot:GetNearbyTrees(Min(1600, GetUnitToLocationDistance(bot, loc)))

    for _, tree in pairs(trees) do
        local x = GetTreeLocation(tree)
        local y = bot:GetLocation()
        local z = loc

        if x ~= y then
            local a = 1
            local b = 1
            local c = 0

            if x.x - y.x == 0 then
                b = 0
                c = -x.x
            else
                a =- (x.y - y.y)/(x.x - y.x)
                c =- (x.y + x.x*a)
            end

            local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
            if d <= lineOfSightThickness and
                GetUnitToLocationDistance(bot, loc) > (U.GetDistance(x,loc) + 50) then
                return true
            end
        end
    end
    return false
end

function U.GetEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fCreepList = {}

    local eCreeps = gHeroVar.GetNearbyEnemyCreep(bot, Min(1600, GetUnitToLocationDistance(bot, loc)))

    for _, eCreep in pairs(eCreeps) do
        if U.ValidTarget(eCreep) then
            local x = eCreep:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (U.GetDistance(x,loc) + 50) then
                    table.insert(fCreepList, eCreep)
                end
            end
        end
    end
    return fCreepList
end

function U.AreEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    return #U.GetEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness) > 0
end

function U.GetFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fCreepList = {}

    local fCreeps = gHeroVar.GetNearbyAlliedCreep(bot, Min(1600, GetUnitToLocationDistance(bot, loc)))

    for _, fCreep in pairs(fCreeps) do
        if U.ValidTarget(fCreep) then
            local x = fCreep:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (U.GetDistance(x,loc) + 50) then
                    table.insert(fCreepList, fCreep)
                end
            end
        end
    end
    return fCreepList
end

function U.AreFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    return #U.GetFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness) > 0
end

function U.AreCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    if not U.AreEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness) then
        return U.AreFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    end
    return true
end

function U.GetCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    return { unpack(U.GetEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)), unpack(U.GetFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)) }
end

function U.GetFriendlyHeroesBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fHeroList = {}

    local fHeroes = gHeroVar.GetNearbyAllies(bot, Min(1600, GetUnitToLocationDistance(bot, loc)))

    for _, fHero in pairs(fHeroes) do
        if U.ValidTarget(fHero) then
            local x = fHero:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (U.GetDistance(x,loc) + 50) then
                    table.insert(fHeroList, fHero)
                end
            end
        end
    end
    return fHeroList
end

function U.GetEnemyHeroesBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fHeroList = {}

    local fHeroes = gHeroVar.GetNearbyEnemies(bot, Min(1600, GetUnitToLocationDistance(bot, loc)))

    for _, fHero in pairs(fHeroes) do
        if U.ValidTarget(fHero) then
            local x = fHero:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (U.GetDistance(x,loc) + 50) then
                    table.insert(fHeroList, fHero)
                end
            end
        end
    end
    return fHeroList
end

function U.PredictPosition(hHero, fTime)
    local loc = hHero:GetLocation()
	local v = hHero:GetVelocity()
	return Vector( loc.x + fTime * v.x, loc.y + fTime * v.y, loc.z )
end

function U.GetHeroName(bot)
    local sName = bot:GetUnitName()
    return string.sub(sName, 15, string.len(sName));
end

function U.IsBusy(bot)
    if bot:IsChanneling() then return true end
    if bot:NumQueuedActions() > 0 then return true end
    if bot:IsCastingAbility() then
        if bot.AbilityOnEntityUseTime and (GameTime() - bot.AbilityOnEntityUseTime) > 3.0 then return false end
        return true
    end
    return false
end

function U.IsCore( hHero )
    if not hHero:IsBot() then return true end

    if gHeroVar.GetVar(hHero:GetPlayerID(), "Role") == constants.ROLE_HARDCARRY
        or gHeroVar.GetVar(hHero:GetPlayerID(), "Role") == constants.ROLE_MID
        or gHeroVar.GetVar(hHero:GetPlayerID(), "Role") == constants.ROLE_OFFLANE
        or gHeroVar.GetVar(hHero:GetPlayerID(), "Role") == constants.ROLE_JUNGLER then
            return true
    end
    return false
end

function U.IsMelee(hero)
    return hero:GetAttackRange() < 320.0
end

function U.PartyChat(msg)
    local bot = GetBot()
    bot:ActionImmediate_Chat(msg, false)
end

function U.AllChat(msg)
    local bot = GetBot()
    bot:ActionImmediate_Chat(msg, true)
end

function U.ValidTarget(target)
    if target and not target:IsNull() and target:IsAlive() then
        return true
    end
    return false
end

function U.NotNilOrDead(unit)
    if unit == nil or unit:IsNull() then
        return false
    end
    if unit:IsAlive() then
        return true
    end
    return false
end

function U.TimePassed(prevTime, amount)
    if ( (GameTime() - prevTime) > amount ) then
        return true, GameTime()
    else
        return false, GameTime()
    end
end

function U.LevelUp(bot, AbilityPriority)
    if ( GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS and GetGameState() ~= GAME_STATE_PRE_GAME ) then return end

    local ability = bot:GetAbilityByName(AbilityPriority[1])

    if ( ability == nil ) then
        U.myPrint(" FAILED AT Leveling " .. AbilityPriority[1] )
        table.remove( AbilityPriority, 1 )
        return
    end

    if ( ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel() ) then
        bot:ActionImmediate_LevelAbility(AbilityPriority[1])
        U.myPrint( " Leveling " .. ability:GetName() )
        table.remove( AbilityPriority, 1 )
    end
end

function U.GetOtherTeam()
    if GetTeam() == TEAM_RADIANT then
        return TEAM_DIRE
    else
        return TEAM_RADIANT
    end
end

function U.TreadCycle(bot, stat)
    return false
end

function U.PositionAlongLane(hUnit, lane)
    local unitPos = hUnit:GetLocation()
    local fAmount = GetAmountAlongLane(lane, unitPos)
    local bInLane = false
    if fAmount.distance <= 1600 then
        bInLane = true
    end
    setHeroVar("IsInLane", bInLane)

    return fAmount.amount
end

function U.NearestLane(hUnit)
    local unitPos = hUnit:GetLocation()
    for i = 1, 3, 1 do
        local fAmount = GetAmountAlongLane(i, unitPos)
        if fAmount.distance <= 1600 then return i end
    end
    return 0
end

function U.MoveSafelyToLocation(bot, dest)
    gHeroVar.HeroMoveToLocation(bot, dest)
end

function U.IsInLane()
    local bot = GetBot()

    setHeroVar("RetreatLane", getHeroVar("CurLane"))
    setHeroVar("RetreatPos", getHeroVar("LanePos"))

    local minDis = 10000

    for i = 1, #U.Lanes, 1 do
        local lAmnt = U.PositionAlongLane(bot, U.Lanes[i])
        local thisDis = U.GetDistance(GetLocationAlongLane(U.Lanes[i], lAmnt), bot:GetLocation())

        if thisDis < minDis then
            setHeroVar("RetreatLane", U.Lanes[i])
            setHeroVar("RetreatPos", lAmnt)
        end
    end

    return getHeroVar("IsInLane"), getHeroVar("RetreatLane")
end

function U.EnemiesNearLocation(bot, loc, dist)
    if loc == nil then
        return 0
    end

    local num = 0
    local listEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _, enemy in pairs(listEnemies) do
        if U.ValidTarget(enemy) and U.GetDistance(enemy:GetLocation(), loc) <= dist then
            num = num + 1
        end
    end

    return num
end

function U.GetWardingSpot(lane)


    local laneTower1 = U.GetLaneTower(U.GetOtherTeam(), lane, 1)
    local laneTower2 = U.GetLaneTower(U.GetOtherTeam(), lane, 2)

    if U.ValidTarget(laneTower1) then

        if GetTeam() == TEAM_RADIANT then
            if lane == LANE_BOT then
                return {Vector(3552, -1522), Vector(5684, -3228)}
            elseif lane == LANE_MID then
                return {Vector(-874, 1191)}
            elseif lane == LANE_TOP then
                return {Vector(-3069, 3873)}
            end
        else
            if lane == LANE_TOP then
                return {Vector(-5105, 2083)}
            elseif lane == LANE_MID then
                return {Vector(-130, -1047)}
            elseif lane == LANE_BOT then
                return {Vector(4199, -4763)}
            end
        end
    elseif U.ValidTarget(laneTower2) then
        if GetTeam() == TEAM_RADIANT then
            if lane == LANE_BOT then
                return {Vector(5072, 761), Vector(3096, -211)}
            elseif lane == LANE_MID then
                return {Vector(218, 2393)}
            elseif lane == LANE_TOP then
                return {Vector(1021, 4641)}
            end
        else
            if lane == LANE_TOP then
                return {Vector(-4380, -1283)}
            elseif lane == LANE_MID then
                return {Vector(-4380, -1283)}
            elseif lane == LANE_BOT then
                return {Vector(-1035, -4588)}
            end
        end
    else
        U.myPrint("WARDING: Not implemented past a tower dropping...")
        return nil
    end
    return nil
end

function U.NextNeutralSpawn()
    if DotaTime() < 30 then
        return 30
    else
        local respawnFreq = 60
        t = math.ceil((DotaTime() - 60) / respawnFreq) * respawnFreq + 60
        return t
    end
end

function U.NearestNeutralCamp( hUnit, tCamps )
    local closestDistance = 1000000
    local closestCamp = nil
    local secondClosestCamp = nil
    for k,v in ipairs(tCamps) do
        if v ~= nil and GetUnitToLocationDistance( hUnit, v[constants.VECTOR] ) < closestDistance then
            closestDistance = GetUnitToLocationDistance( hUnit, v[constants.VECTOR] )
            if closestCamp ~= nil then secondClosestCamp = closestCamp end
            closestCamp = v

        end
    end
    return closestCamp, secondClosestCamp
end

function U.GetTowerLocation(side, lane, n)
    if (side==0) then
        if (lane==LANE_TOP) then
            if (n==1) then
                return U.Locations["RTT1"];
            elseif (n==2) then
                return U.Locations["RTT2"];
            elseif (n==3) then
                return U.Locations["RTT3"];
            end
        elseif (lane==LANE_MID) then
            if (n==1) then
                return U.Locations["RMT1"];
            elseif (n==2) then
                return U.Locations["RMT2"];
            elseif (n==3) then
                return U.Locations["RMT3"];
            end
        elseif (lane==LANE_BOT) then
            if (n==1) then
                return U.Locations["RBT1"];
            elseif (n==2) then
                return U.Locations["RBT2"];
            elseif (n==3) then
                return U.Locations["RBT3"];
            end
        end
    elseif(side==1) then
        if (lane==LANE_TOP) then
            if (n==1) then
                return U.Locations["DTT1"];
            elseif (n==2) then
                return U.Locations["DTT2"];
            elseif (n==3) then
                return U.Locations["DTT3"];
            end
        elseif (lane==LANE_MID) then
            if (n==1) then
                return U.Locations["DMT1"];
            elseif (n==2) then
                return U.Locations["DMT2"];
            elseif (n==3) then
                return U.Locations["DMT3"];
            end
        elseif (lane==LANE_BOT) then
            if (n==1) then
                return U.Locations["DBT1"];
            elseif (n==2) then
                return U.Locations["DBT2"];
            elseif (n==3) then
                return U.Locations["DBT3"];
            end
        end
    end
    return nil;
end

function U.GetLaneTower(team, lane, i)
    if i > 3 and i < 6 then
        return GetTower(team, 5 + i)
    end

    local j = i - 1
    if lane == LANE_MID then
        j = j + 3
    elseif lane == LANE_BOT then
        j = j + 6
    end

    if j < 9 and j > -1 and (lane == LANE_BOT or lane == LANE_MID or lane == LANE_TOP) then
        return GetTower(team, j)
    end

    return nil
end

function U.GetLaneTowerAttackTarget(team, lane, i)
    if i > 3 and i < 6 then
        return GetTowerAttackTarget(team, 5 + i)
    end

    local j = i - 1
    if lane == LANE_MID then
        j = j + 3
    elseif lane == LANE_BOT then
        j = j + 6
    end

    if j < 9 and j > -1 and (lane == LANE_BOT or lane == LANE_MID or lane == LANE_TOP) then
        return GetTowerAttackTarget(team, j)
    end

    return nil
end

function U.Fountain(team)
    if team == TEAM_RADIANT then
        return Vector(-7093, -6542)
    end
    return Vector(7015, 6534)
end

function U.GetCenterOfCreeps(creeps)
    local center=Vector(0,0);
    local n=0.0;
    local meleeW=2;
    if creeps==nil or #creeps==0 then
        return nil;
    end

    for _,creep in pairs(creeps) do
        if (string.find(creep:GetUnitName(),"melee")~=nil) then
            center = center + (creep:GetLocation())*meleeW;
            n=n+meleeW;
        else
            n=n+1;
            center = center + creep:GetLocation();
        end
    end
    if n==0 then
        return nil;
    end
    center=center/n;

    return center;
end

function U.CreepGC()
    local swp_table = {}
    for handle,time_health in pairs(self["creeps"])
    do
        local rm = false;
        for t,_ in pairs(time_health)
        do
            if(GameTime() - t > 60) then
                rm = true;
            end
            break;
        end
        if not rm then
            swp_table[handle] = time_health;
        end
    end

    U.creeps = swp_table;
end

function U.UpdateCreepHealth(creep)
    if U.creeps == nil then
        U.creeps = {};
    end

    if(U.creeps[creep] == nil) then
        U.creeps[creep] = {};
    end
    if(creep:GetHealth() < creep:GetMaxHealth()) then
        U.creeps[creep][GameTime()] = creep:GetHealth();
    end

    if(#U.creeps > 1000) then
        self:CreepGC();
    end
end

function U.GetCreepHealthDeltaPerSec(creep)
    if U.creeps == nil then
        U.creeps = {};
    end

    if(U.creeps[creep] == nil) then
        return 0;
    else
        for _time,_health in U.PairsByKeys(U.creeps[creep],U.SortFunc) do
            if(GameTime() - _time < 3) then
                local e = (_health - creep:GetHealth()) / (GameTime() - _time);
                return e;
            end
        end
        return 0;
    end
end

function U.GetWeakestCreep(creeps)
    local WeakestCreep = nil
    local LowestHealth = 100000

    for _,creep in pairs(creeps) do
        U.UpdateCreepHealth(creep)
        if U.ValidTarget(creep) then
            if creep:GetHealth() < LowestHealth then
                LowestHealth = creep:GetHealth()
                WeakestCreep = creep
            end
        end
    end

    return WeakestCreep, LowestHealth
end

function U.IsHeroAttackingMe(hero, fTime)
    if not U.ValidTarget(hero) then return false end

    local fTime = fTime or 2.0
    local bot = GetBot()

    if bot:WasRecentlyDamagedByHero(hero, fTime) then
        return true
    end
    return false
end

function U.IsAnyHeroAttackingMe(fTime)
    local fTime = fTime or 2.0
    local bot = GetBot()

    if bot:WasRecentlyDamagedByAnyHero(fTime) then
        return true
    end
    return false
end

function U.IsTowerAttackingMe()
    local bot = GetBot()
    local nearEnemyTowers = gHeroVar.GetNearbyEnemyTowers(bot, 750)

    if #nearEnemyTowers == 0 then return false end

    local lane = U.NearestLane(bot)
    if lane == 0 then return false end

    for i = 1, 5, 1 do
        local target = U.GetLaneTowerAttackTarget(U.GetOtherTeam(), lane, i)
        if U.ValidTarget(target) then
            if bot == target then return true end
        end
    end

    return false
end

function U.IsCreepAttackingMe(fTime)
    local fTime = fTime or 1.0
    local bot = GetBot()

    if bot:WasRecentlyDamagedByCreep(fTime) then
        return true
    end
    return false
end

function U.CanHarass(bot, hTarget)

    local otherEnemiesInWay = U.GetEnemyHeroesBetweenMeAndLoc(hTarget:GetLocation()+100, 500)
    if #otherEnemiesInWay == 0 then
        return true
    end

    return false
end

function U.GetCenter( hUnits )
    if hUnits == nil or #hUnits == 0 then
        return nil
    end

    local sum = Vector(0.0, 0.0)
    local hn = 0.0

    for _, hUnit in pairs(hUnits) do
        if U.ValidTarget(hUnit) then
            sum = sum + hUnit:GetLocation()
            hn = hn + 1
        end
    end
    return sum/hn
end

function U.DirectionAwayFromDanger(listDangerHandles, origDir)
    local safeDir = origDir
    local bot = GetBot()

    local otherEnemiesInWay = U.GetEnemyHeroesBetweenMeAndLoc(U.VectorTowards(bot:GetLocation(), safeDir, 1600), 1000)
    if #otherEnemiesInWay == 0 then
        return safeDir
    end
    
    if #listDangerHandles > 0 then
        local dangerPoint = U.GetCenter(listDangerHandles)
        safeDir = U.VectorAway(bot:GetLocation(), dangerPoint, 500)
    end

    return safeDir
end
function U.GetWeakestHero(bot, r, unitList)
    local EnemyHeroes = unitList
    if EnemyHeroes == nil or #EnemyHeroes == 0 then
        EnemyHeroes = gHeroVar.GetNearbyEnemies(bot, r)
    else
        local filteredList = {}
        for _, hero in pairs(EnemyHeroes) do
            if U.ValidTarget(hero) and GetUnitToUnitDistance(bot, hero) <= r then
                table.insert(filteredList, hero)
            end
        end
        EnemyHeroes = filteredList
    end

    if EnemyHeroes == nil or #EnemyHeroes == 0 then
        return nil, 10000
    end

    local WeakestHero = nil
    local LowestHealth = 10000

    for _, hero in ipairs(EnemyHeroes) do
        if U.ValidTarget(hero) then
            if hero:GetHealth() < LowestHealth then
                LowestHealth = hero:GetHealth()
                WeakestHero = hero
            end
        end
    end

    return WeakestHero, LowestHealth
end

function U.EnemyHasBreakableBuff(enemy)
    if not U.ValidTarget(enemy) then return false end

    if enemy:HasModifier("modifier_clarity_potion") or
        enemy:HasModifier("modifier_flask_healing") or
        enemy:HasModifier("modifier_bottle_regeneration") then
        return true
    end
    return false
end

function U.UseOrbEffect(bot)
    local orb = getHeroVar("HasOrbAbility")
    if orb then
        local ability = bot:GetAbilityByName(orb)
        if ability ~= nil and ability:IsFullyCastable() then
            local target = nil
            if U.ValidTarget(getHeroVar("Target")) then
                target = getHeroVar("Target")
            else
                target, _ = U.GetWeakestHero(bot, bot:GetAttackRange()+bot:GetBoundingRadius())
            end
            if U.ValidTarget(target) and GetUnitToUnitDistance(bot, target) < (bot:GetAttackRange()+bot:GetBoundingRadius()) then
                U.TreadCycle(bot, constants.INTELLIGENCE)
                gHeroVar.HeroUseAbilityOnEntity(bot, ability, target)
                return true
            end
        end
    end
    return false
end

function U.IsTargetMagicImmune(target)
    return target:IsInvulnerable() or target:IsMagicImmune()
end

function U.IsCrowdControlled(enemy)
    return enemy:IsRooted() or enemy:IsHexed() or enemy:IsStunned()
end

function U.IsUnableToCast(enemy)
    return U.IsCrowdControlled(enemy) or enemy:IsNightmared() or enemy:IsSilenced()
end

function U.IsUnitCrowdControlled(e)
    return U.IsCrowdControlled(e) or e:IsNightmared() or e:IsDisarmed() or e:IsBlind() or e:IsSilenced() or e:IsMuted()
end

function U.DropTowerAggro(bot, nearbyAlliedCreep)
    local nearbyTowers = gHeroVar.GetNearbyEnemyTowers(bot, 750)
    if #nearbyAlliedCreep > 0 and #nearbyTowers == 1 then
        for _, aCreep in pairs(nearbyAlliedCreep) do
            if U.ValidTarget(aCreep) and GetUnitToUnitDistance(aCreep, nearbyTowers[1]) < 700 then
                gHeroVar.HeroAttackUnit(bot, aCreep, true)
                return true
            end
        end
    end
    return false
end
function U.InTeamFight(bot, range)
    local checkDist = 1000
    if range then checkDist = range end

    local alliesInTeamfight = {}

    local allyList = GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _, ally in pairs(allyList) do
        if ally:IsAlive() and not ally:IsIllusion() and ally:IsBot() and
            GetUnitToUnitDistance(bot, ally) <= checkDist and
            ally.SelfRef:getCurrentMode():GetName() == "fight" then
            table.insert(alliesInTeamfight, ally)
        end
    end

    return alliesInTeamfight
end
function U.GetScariestEnemy(bot, range, bConsiderMagicImmune)
    local mostDangerousEnemy = nil
    local mostDangerousDamage = 0

    local checkForMagicImmunity = false
    if bConsiderMagicImmune then checkForMagicImmunity = bConsiderMagicImmune end

    for _, npcEnemy in pairs( gHeroVar.GetNearbyEnemies( bot, range ) ) do
        if not U.IsUnitCrowdControlled(npcEnemy) and not npcEnemy:IsInvulnerable() then
            if checkForMagicImmunity then
                local Damage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL )
                if Damage > mostDangerousDamage then
                    mostDangerousDamage = Damage
                    mostDangerousEnemy = npcEnemy
                end
            else
                if not npcEnemy:IsMagicImmune() then
                    local Damage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL )
                    if Damage > mostDangerousDamage then
                        mostDangerousDamage = Damage
                        mostDangerousEnemy = npcEnemy
                    end
                end
            end
        end
    end

    return mostDangerousEnemy
end
function U.NumberOfItems(bot)
    local n = 0

    for i = 0, 5, 1 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil then
            n = n+1
        end
    end

    return n
end

function U.NumberOfItemsInBackpack(bot)
    local n = 0

    for i = 6, 8, 1 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil then
            n = n+1
        end
    end

    return n
end

function U.NumberOfItemsInStash(bot)
    if bot:GetStashValue() == 0 then return 0 end
    local n = 0
    for i = 9, 14, 1 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil then
            n = n+1
        end
    end
    return n
end

function U.HaveItem(bot, item_name)
    local slot = bot:FindItemSlot(item_name)
    if slot ~= ITEM_SLOT_TYPE_INVALID then
        local slot_type = bot:GetItemSlotType(slot)
        if slot_type == ITEM_SLOT_TYPE_MAIN then
            return bot:GetItemInSlot(slot), true
        elseif slot_type == ITEM_SLOT_TYPE_BACKPACK then
            return U.MoveItemsFromBackpackToInventory(bot, slot)
        elseif slot_type == ITEM_SLOT_TYPE_STASH then
            if bot:DistanceFromFountain() < 500 then
                if U.NumberOfItems(bot) < 6 then
                    U.MoveItemsFromStashToInventory(bot)
                    return nil, false
                else
                    U.myPrint("FIXME: Implement swapping STASH to MAIN INVENTORY of item: ", item_name)
                    return bot:GetItemInSlot(slot), false
                end
            end
            return nil, false
        else
            U.pause("ERROR: condition should not be hit: ", item_name)
            return nil, false
        end
    end

    return nil, false
end

function U.MoveItemsFromBackpackToInventory(bot, bpSlot)
    if U.NumberOfItems(bot) < 6 then
        for i = 0, 5, 1 do
            if bot:GetItemInSlot(i) == nil then
                bot:ActionImmediate_SwapItems(i, bpSlot)
                return bot:GetItemInSlot(i), true
            end
        end
    else
        local bpItem = bot:GetItemInSlot(bpSlot)
        if bpItem:GetName() == "item_tpscroll" or bpItem:GetName() == "item_tome_of_knowledge" then
            bot:ActionImmediate_SwapItems(5, bpSlot)
            return bot:GetItemInSlot(5), true
        else
            U.myPrint("FIXME: Implement swapping BACKPACK to MAIN INVENTORY of item: ", bpItem:GetName())
            return bpItem, false
        end
    end
    return nil, false
end

function U.MoveItemsFromStashToInventory(bot)
    if U.NumberOfItems(bot) == 6 and U.NumberOfItemsInBackpack(bot) == 3 then return end
    if U.NumberOfItemsInStash(bot) == 0 then return end

    for i = 0, 5, 1 do
        if bot:GetItemInSlot(i) == nil then
            for j = 9, 14, 1 do
                local item = bot:GetItemInSlot(j)
                if item ~= nil then
                    bot:ActionImmediate_SwapItems(i, j)
                    return
                end
            end
        end
    end

    for i = 6, 8, 1 do
        if bot:GetItemInSlot(i) == nil then
            for j = 9, 14, 1 do
                local item = bot:GetItemInSlot(j)
                if item ~= nil then
                    bot:ActionImmediate_SwapItems(i, j)
                    return
                end
            end
        end
    end
end

function U.GetFreeSlotInBackPack(bot)
    for i = 6, 8, 1 do
        if bot:GetItemInSlot(i) == nil then
            return i
        end
    end
    return -1
end

function U.HaveTeleportation(bot)
    if U.GetHeroName(bot) == "furion" then
        return true
    end

    local tp, _ = U.HaveItem(bot, "item_tpscroll")
    if tp == nil then
        tp, _ = U.HaveItem(bot, "item_travel_boots_1")
    end
    if tp == nil then
        tp, _ = U.HaveItem(bot, "item_travel_boots_2")
    end

    return tp ~= nil
end

function U.GetTeleportationAbility(bot)
    if U.GetHeroName(bot) == "furion" then
        local ability = bot:GetAbilityByName("furion_teleportation")
        if ability ~= nil and ability:IsFullyCastable() then
            return ability
        end
    end

    local tp = U.IsItemAvailable("item_tpscroll")
    if tp then
        return tp
    end

    tp = U.IsItemAvailable("item_travel_boots_1")
    if tp then
        return tp
    end

    tp = U.IsItemAvailable("item_travel_boots_2")
    if tp then
        return tp
    end

    return nil
end

function U.IsItemAvailable(item_name)
    local bot = GetBot()

    local item, bMainInv = U.HaveItem(bot, item_name)
    if item ~= nil and bMainInv and item:IsFullyCastable() then
        return item
    end

    return nil
end

function U.HasImportantItem()
     local bot = GetBot()

    for i = 9, 14, 1 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil then
            if string.find(item:GetName(),"recipe") ~= nil or string.find(item:GetName(),"item_boots") ~= nil or string.find(item:GetName(),"item_bottle") then
                return true
            end

            if(item:GetName()=="item_ward_observer" and item:GetCurrentCharges() > 1) then
                return true
            end
            if(item:GetName()=="item_ward_sentry") then
                return true
            end
            if(item:GetName()=="item_ward_dispenser") then
                return true
            end
        end
    end

    return false
end

function U.CourierThink(bot)
    if GetNumCouriers() == 0 then return end
    if bot:IsIllusion() then return end
    local courier   = GetCourier(0)
    local state     = GetCourierState(courier)
    if state == COURIER_STATE_DEAD or courier:GetHealth() < 1 then return end
    local checkLevel, newTime = U.TimePassed(getHeroVar("LastCourierThink"), 1.0)
    if not checkLevel then return end
    setHeroVar("LastCourierThink", newTime)
    if courier:WasRecentlyDamagedByAnyHero(2) or courier:WasRecentlyDamagedByTower(2) then
        if IsFlyingCourier(courier) and (GameTime() - gHeroVar.GetGlobalVar("LastCourierBurst")) > 90.0 then
            bot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST)
            gHeroVar.SetGlobalVar("LastCourierBurst", GameTime())
            return
        end
        bot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN)
        return
    end
    if IsFlyingCourier(courier) and (GameTime() - gHeroVar.GetGlobalVar("LastCourierBurst")) > 90.0 then
        if state == COURIER_STATE_DELIVERING_ITEMS then
            bot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST)
            gHeroVar.SetGlobalVar("LastCourierBurst", GameTime())
            return
        end
    end
    if state ~= COURIER_STATE_DEAD and state ~= COURIER_STATE_MOVING and state ~= COURIER_STATE_AT_BASE then
        bot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN)
        return
    end
    if bot:IsAlive() and (bot:GetStashValue() > 500 or bot:GetCourierValue() > 0 or U.HasImportantItem()) and state ~= COURIER_STATE_DELIVERING_ITEMS then
        bot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
        return
    end
    if state ~= COURIER_STATE_DEAD and state == COURIER_STATE_AT_BASE and
        (not bot:IsAlive()) and bot:GetCourierValue() > 0 then
        bot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN_STASH_ITEMS)
        return
    end
end
function U.GetNearestTree(bot)
    local trees = bot:GetNearbyTrees(700)
    local eTowers = gHeroVar.GetNearbyEnemyTowers(bot, 1600)
    for _, tree in pairs(trees) do
        local treeLoc = GetTreeLocation(tree)
        if #eTowers == 0 or U.GetDistance(treeLoc, eTowers[1]:GetLocation()) > 900 then
            if U.GetHeightDiff(bot, treeLoc[3]) == 0 then
                return tree
            end
        end
    end
    return nil
end
function U.pause(...)
    U.myPrint(...)
    DebugPause()
end
function U.myPrint(...)
    local args = {...}
    local botname = U.GetHeroName(GetBot())
    local msg = tostring(U.Round(GameTime(), 3)).." [" .. botname .. "]: "
    for i,v in ipairs(args) do
        msg = msg .. tostring(v)
    end
      print(msg)
end

return U;