X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(3));

X["items"] = { 
	"item_poor_mans_shield",
	"item_boots",
	"item_hand_of_midas",
	"item_phase_boots",
	"item_blade_mail",
	"item_shadow_blade",
	"item_shivas_guard",
	"item_assault",
	"item_silver_edge",
	"item_heart",
};	

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,2,1,4,2,1,2,1,4,3,3,3,4}, skills, 
	  {2,4,6,7}, talents
);

return X