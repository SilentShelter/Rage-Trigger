X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_boots",
	"item_magic_wand",
	"item_arcane_boots",
	"item_force_staff",
	"item_cyclone",
	"item_rod_of_atos",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,3,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {2,4,6,7}, talents
);

return X