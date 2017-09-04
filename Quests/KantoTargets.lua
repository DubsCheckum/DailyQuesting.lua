targets = {
	
	--Pokecenter and Pokemart maps are from the hunting location until the nearest pokecenter/pokemart
	--Maps are from the hunting location to the Quest Master's city (including the city name at end)
	
	--Poke = {["pokecenter"] = {"map1", "map2", "map3" ["pokemart"] = {"map1", "map2", "map3", ["maps"] = {"map1" etc...}}, huntType = {groundType, exit}}
	
	["Bellsprout"] = {["map"] = {"Route 24", ""}, ["huntType"] = {"GRASS",""}},
	["Caterpie"]   = {["map"] = {"Viridian City"}, ["huntType"] = {"GRASS",""}},
	["Diglett"]    = {"Digletts Cave Entrance 2", ["huntType"] = {"NEAREXIT","Route 11"}},
	["Doduo"]      = {["pokecenter"] = {"Route 16", "Celadon City"}, ["pokemart"] = {}, ["maps"] = {"Celadon City", "Route 16"}},
	["Drowzee"]    = {"Route 11", ["huntType"] = {"GRASS",""}},
	["Geodude"]    = {"Rock Tunnel 1", ["huntType"] = {"NEAREXIT","Route 10"}},
	["Horsea"]     = {"Route 6", ["huntType"] = {"WATER",""}},
	["Krabby"]     = {"Route 6", ["huntType"] = {"WATER",""}},
	["Magikarp"]   = {"Route 10", ["huntType"] = {"WATER",""}},
	["Magnemite"]  = {"Route 10", ["huntType"] = {"GRASS",""}},
	["NidoranF"]   = {["map"] = {"Route 10"}, ["huntType"] = {"GRASS",""}},
	["Nidoran M"]   = {"Route 10", ["huntType"] = {"GRASS",""}},
	["Oddish"]     = {"Route 25", ["huntType"] = {"GRASS",""}},
	["Pidgey"]     = {"Route 4", ["huntType"] = {"GRASS",""}},
	["Sandshrew"]  = {"Digletts Cave", ["huntType"] = {"NEAREXIT","Digletts Cave Entrance 2"}},
	["Slowpoke"]   = {"Route 12", ["huntType"] = {"WATER",""}},
	["Spearow"]    = {"Route 4", ["huntType"] = {"GRASS",""}},
	["Tentacool"]  = {"Route 10", ["huntType"] = {"WATER",""}},
	["Venonat"]    = {"Route 12", ["huntType"] = {"GRASS",""}},
	["Weedle"]     = {"Viridian Forest", ["huntType"] = {"GRASS",""}},
	["Zubat"]      = {"Digletts Cave Entrance 2", ["huntType"] = {"NEAREXIT","Route 10"}},
	
	--Item = {Location, coords = {x,y}},
	
	["HP Up"]          = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Protein"]        = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Iron"]           = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Carbos"]         = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Calcium"]        = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Zinc"]           = {"Celadon Mart 5", ["coords"] = {3,9}},
	["Bone Moss"]      = {"Pokemon Tower 3F", ["coords"] = {16,7}},
	["Hearth Peach"]   = {"Viridian Forest", ["coords"] = {42,62}},
	["Sparky Blossom"] = {"Power Plant", ["coords"] = {1,1}},
	
	--If you encounter the error "Could not load script Questing.lua: unexpected symbol near '['" it means you forgot a comma
	--Good luck with finding that!

}
















