-- Copyright © 2017 
-- Scriptwriters Shutnik, AdamQQQ, Arizona Fauzie, Furious Puppy.
-- AdamQQQ 36 hero basic AI \ Warding AI \ Complex scipts for logical decisions
-- Arizona Fauzie  43 hero basic AI \ Rune AI \ ItemBuilds AI \ Complex scripts for Meepo and Invoker
-- Furious Puppy 12 hero basic AI \ Glyph AI \ Retreat logic
-- Shutnik 22 hero basic AI \ Laning behavior \ Map awarness logic \ Skill preferences \ Code adaptation

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

herofile = {};
herofile.tableNeutral = { };
herofile.TableEnemyPlayerID = { };
herofile.TableEnemyPlayerHandle = { };
herofile.TableEnemyPlayerLaneNum = { };
herofile.TableEnemyPlayerSpeed = {300,300,300,300,300};
herofile.TableEnemyPlayerAttack = {50,50,50,50,50};
herofile.TableEnemyPlayerAttackRange = {800,800,800,800,800};
herofile.TableEnemyPlayerPriority = {0,0,0,0,0};
herofile.TableLastSeenInfo = { }; 
herofile.ExtrapolatedLocation_five =  { };
herofile.TableEnemyHeroHP = {9999,9999,9999,9999,9999};
herofile.TableEnemyHeroMaxHP = {9999,9999,9999,9999,9999};
herofile.TableEnemyHeroMana = {9999,9999,9999,9999,9999};
herofile.TableEnemyHeroPower = {0, 0, 0, 0, 0};
herofile.TableEnemyHeroNetWorth = {625,625,625,625,625};
herofile.TableEnemyHeroTag = { };
herofile.TableEnemyHeroPriorityIndex = { };
herofile.TableAllyPlayerID = { };
herofile.TableAllyHeroRole = { 5, 5, 5, 5, 5};
herofile.TableAllyHeroLaneNum = { };
herofile.TableAllyHeroCom = { };
herofile.TableAllyHeroTarget = { };
herofile.TableAllyHeroTime = { };
herofile.TableAllyHeroLoc = { };
herofile.TableAllyHeroString = { };
herofile.TableAllyHeroState = { };
herofile.TableAllyTeamFightState = { };
herofile.TableAllyHeroHandle = { };
herofile.TableAllyHeroPriority = { 0, 0, 0, 0, 0 };
return herofile;