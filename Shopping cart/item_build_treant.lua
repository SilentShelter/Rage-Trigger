X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildlogic");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));
X["items"] = { 
	"item_poor_mans_shield",
	"item_boots",
	"item_magic_wand",
	"item_tranquil_boots",
	"item_medallion_of_courage",
	"item_blink",
	"item_solar_crest",
	"item_cyclone",
	"item_lotus_orb",
	"item_shivas_guard"
};			
X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,3,3,4,3,2,2,2,4,1,1,1,4}, skills, 
	  {1,4,6,7}, talents
);
return X