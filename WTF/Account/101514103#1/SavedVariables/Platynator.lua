
PLATYNATOR_CONFIG = {
["Version"] = 1,
["CharacterSpecific"] = {
},
["Profiles"] = {
["DEFAULT"] = {
["stack_region_scale_y"] = 1.1,
["design_all"] = {
},
["closer_to_screen_edges"] = true,
["cast_scale"] = 1.1,
["simplified_nameplates"] = {
["minor"] = true,
["minion"] = true,
["instancesNormal"] = true,
},
["stacking_nameplates"] = {
["friend"] = false,
["enemy"] = true,
},
["designs_assigned"] = {
["enemySimplified"] = "_hare_simplified",
["friend"] = "_name-only",
["enemy"] = "_hare",
},
["cast_alpha"] = 1,
["obscured_alpha"] = 0.4,
["simplified_scale"] = 0.4,
["show_friendly_in_instances_1"] = "always",
["not_target_alpha"] = 1,
["click_region_scale_x"] = 1,
["apply_cvars"] = true,
["current_skin"] = "blizzard",
["target_scale"] = 1.2,
["designs"] = {
["_custom"] = {
["highlights"] = {
{
["color"] = {
["a"] = 1,
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["anchor"] = {
},
["kind"] = "target",
["scale"] = 1,
["height"] = 1,
["layer"] = 0,
["asset"] = "arrows",
["width"] = 1,
},
{
["color"] = {
["a"] = 1,
["b"] = 0.9215686917304992,
["g"] = 0.3725490272045136,
["r"] = 0.6941176652908325,
},
["layer"] = 0,
["asset"] = "bold",
["width"] = 1.03,
["anchor"] = {
},
["height"] = 1.24,
["kind"] = "mouseover",
["scale"] = 1,
["includeTarget"] = true,
},
},
["specialBars"] = {
},
["scale"] = 1,
["auras"] = {
{
["direction"] = "RIGHT",
["scale"] = 1,
["showCountdown"] = true,
["filters"] = {
["important"] = true,
["fromYou"] = true,
},
["textScale"] = 1,
["height"] = 1,
["anchor"] = {
"BOTTOMLEFT",
-63,
25,
},
["kind"] = "debuffs",
["showPandemic"] = true,
["sorting"] = {
["kind"] = "duration",
["reversed"] = false,
},
},
{
["direction"] = "LEFT",
["scale"] = 1,
["showCountdown"] = true,
["filters"] = {
["dispelable"] = false,
["important"] = true,
},
["height"] = 1,
["anchor"] = {
"LEFT",
-98,
0,
},
["kind"] = "buffs",
["textScale"] = 1,
["sorting"] = {
["kind"] = "duration",
["reversed"] = false,
},
},
{
["direction"] = "RIGHT",
["scale"] = 1,
["showCountdown"] = true,
["filters"] = {
["fromYou"] = false,
},
["height"] = 1,
["anchor"] = {
"RIGHT",
101,
0,
},
["kind"] = "crowdControl",
["textScale"] = 1,
["sorting"] = {
["kind"] = "duration",
["reversed"] = false,
},
},
},
["font"] = {
["outline"] = true,
["shadow"] = true,
["asset"] = "RobotoCondensed-Bold",
["slug"] = true,
},
["version"] = 1,
["bars"] = {
{
["relativeTo"] = 0,
["animate"] = false,
["marker"] = {
["asset"] = "wide/glow",
},
["layer"] = 1,
["border"] = {
["height"] = 1,
["color"] = {
["a"] = 1,
["b"] = 0,
["g"] = 0,
["r"] = 0,
},
["asset"] = "thin",
["width"] = 1,
},
["autoColors"] = {
{
["colors"] = {
},
["kind"] = "classColors",
},
{
["colors"] = {
["tapped"] = {
["b"] = 0.4313725490196079,
["g"] = 0.4313725490196079,
["r"] = 0.4313725490196079,
},
},
["kind"] = "tapped",
},
{
["combatOnly"] = false,
["colors"] = {
["safe"] = {
["b"] = 0.9019607843137256,
["g"] = 0.5882352941176471,
["r"] = 0.05882352941176471,
},
["warning"] = {
["b"] = 0,
["g"] = 0,
["r"] = 0.8,
},
["offtank"] = {
["b"] = 0.7843137254901961,
["g"] = 0.6666666666666666,
["r"] = 0.05882352941176471,
},
["transition"] = {
["b"] = 0,
["g"] = 0.6274509803921569,
["r"] = 1,
},
},
["kind"] = "threat",
["instancesOnly"] = false,
["useSafeColor"] = true,
},
{
["colors"] = {
["unfriendly"] = {
["r"] = 1,
["g"] = 0.5058823529411764,
["b"] = 0,
},
["neutral"] = {
["b"] = 0,
["g"] = 1,
["r"] = 1,
},
["hostile"] = {
["b"] = 0,
["g"] = 0,
["r"] = 1,
},
["friendly"] = {
["b"] = 0,
["g"] = 1,
["r"] = 0,
},
},
["kind"] = "reaction",
},
},
["absorb"] = {
["color"] = {
["a"] = 1,
["r"] = 1,
["g"] = 1,
["b"] = 1,
},
["asset"] = "wide/blizzard-absorb",
},
["anchor"] = {
},
["foreground"] = {
["asset"] = "wide/fade-bottom",
},
["background"] = {
["color"] = {
["a"] = 1,
["r"] = 1,
["g"] = 1,
["b"] = 1,
},
["applyColor"] = true,
["asset"] = "grey",
},
["kind"] = "health",
["scale"] = 1,
},
{
["marker"] = {
["asset"] = "wide/glow",
},
["layer"] = 1,
["border"] = {
["height"] = 1,
["color"] = {
["a"] = 1,
["b"] = 0,
["g"] = 0,
["r"] = 0,
},
["asset"] = "thin",
["width"] = 1,
},
["autoColors"] = {
{
["colors"] = {
["cast"] = {
["r"] = 1,
["g"] = 0.09411764705882353,
["b"] = 0.1529411764705883,
},
["channel"] = {
["r"] = 0.0392156862745098,
["g"] = 0.2627450980392157,
["b"] = 1,
},
},
["kind"] = "importantCast",
},
{
["colors"] = {
["uninterruptable"] = {
["b"] = 0.7647058823529411,
["g"] = 0.7529411764705882,
["r"] = 0.5137254901960784,
},
},
["kind"] = "uninterruptableCast",
},
{
["colors"] = {
["cast"] = {
["b"] = 0,
["g"] = 0.5490196078431373,
["r"] = 0.9882352941176472,
},
["interrupted"] = {
["b"] = 0.8784313725490196,
["g"] = 0.211764705882353,
["r"] = 0.9882352941176472,
},
["channel"] = {
["r"] = 0.2431372549019608,
["g"] = 0.7764705882352941,
["b"] = 0.2156862745098039,
},
},
["kind"] = "cast",
},
},
["scale"] = 1,
["foreground"] = {
["asset"] = "wide/fade-bottom",
},
["anchor"] = {
"TOP",
0,
-9,
},
["background"] = {
["color"] = {
["a"] = 1,
["r"] = 1,
["g"] = 1,
["b"] = 1,
},
["applyColor"] = true,
["asset"] = "grey",
},
["kind"] = "cast",
["interruptMarker"] = {
["asset"] = "none",
["color"] = {
["r"] = 1,
["g"] = 1,
["b"] = 1,
},
},
},
},
["markers"] = {
{
["scale"] = 0.8,
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["anchor"] = {
"RIGHT",
-64,
0,
},
["kind"] = "quest",
["asset"] = "normal/quest-blizzard",
["layer"] = 3,
},
{
["scale"] = 0.5,
["color"] = {
["b"] = 0.4980392156862745,
["g"] = 0.4823529411764706,
["r"] = 0.3921568627450981,
},
["anchor"] = {
"TOPRIGHT",
-50,
-12,
},
["kind"] = "cannotInterrupt",
["asset"] = "normal/shield-soft",
["layer"] = 3,
},
{
["openWorldOnly"] = false,
["scale"] = 0.8,
["kind"] = "elite",
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["layer"] = 3,
["asset"] = "special/blizzard-elite-midnight",
["anchor"] = {
"LEFT",
-61,
0,
},
},
{
["scale"] = 1,
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["anchor"] = {
"BOTTOM",
0,
20,
},
["kind"] = "raid",
["asset"] = "normal/blizzard-raid",
["layer"] = 3,
},
},
["texts"] = {
{
["displayTypes"] = {
"absolute",
},
["align"] = "CENTER",
["layer"] = 2,
["maxWidth"] = 0,
["significantFigures"] = 0,
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["anchor"] = {
},
["kind"] = "health",
["truncate"] = false,
["scale"] = 0.98,
},
{
["showWhenWowDoes"] = false,
["truncate"] = false,
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["layer"] = 2,
["maxWidth"] = 0.99,
["autoColors"] = {
},
["anchor"] = {
"BOTTOM",
0,
9,
},
["kind"] = "creatureName",
["scale"] = 1.1,
["align"] = "CENTER",
},
{
["color"] = {
["b"] = 1,
["g"] = 1,
["r"] = 1,
},
["scale"] = 1,
["kind"] = "castSpellName",
["truncate"] = false,
["align"] = "CENTER",
["layer"] = 2,
["anchor"] = {
"TOP",
0,
-12,
},
["maxWidth"] = 0,
},
},
},
},
["show_nameplates_only_needed"] = false,
["style"] = "_hare",
["click_region_scale_y"] = 1,
["global_scale"] = 1,
["clickable_nameplates"] = {
["friend"] = false,
["enemy"] = true,
},
["stack_region_scale_x"] = 1.2,
["show_nameplates"] = {
["friendlyMinion"] = false,
["enemyMinor"] = true,
["friendlyPlayer"] = true,
["friendlyNPC"] = true,
["enemyMinion"] = true,
["enemy"] = true,
},
},
},
}
