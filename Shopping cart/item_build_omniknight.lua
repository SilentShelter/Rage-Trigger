X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_boots",
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_pipe",
	"item_lotus_orb",
	"item_guardian_greaves",
	"item_shivas_guard",
	"item_radiance"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {2,4,5,7}, talents
);

return X