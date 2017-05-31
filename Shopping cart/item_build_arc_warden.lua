X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_wraith_band",
	"item_boots",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_maelstrom",
	"item_dragon_lance",
	"item_manta",
	"item_mjollnir",
	"item_black_king_bar",
	"item_greater_crit",
	"item_hurricane_pike"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,2,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {2,3,5,8}, talents
);

return X