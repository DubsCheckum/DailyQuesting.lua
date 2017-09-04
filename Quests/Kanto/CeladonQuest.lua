-- Copyright © 2017 DubsCheckum <dubs@noemail>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = "Celadon Daily Quest"
local description = "Going to Celadon to complete the Task Master's task"

local dialogs = {
	targetKnown = Dialog:new({
		"You shall hunt for ([%w-']+), then",
		"Did you obtain ([%w-']+) already?"
	}),
	targetSubmitted = Dialog:new({
		"Speak to my wife now to reap your reward!",
		"You are due for your reward before proceedingly taking on a new task;"
	}),
	needRelog = Dialog:new({
		"That Pokemon's data is not wholly saved yet;"
	}),
	celadonDone = Dialog:new({ 
		"You have been rewarded the",
		"I can only reward you so limitedly,"
	})
}

local CeladonQuest = Quest:new()

function CeladonQuest:new()
	local o =  Quest.new(CeladonQuest, name, description, level, dialogs)
	o.target = nil
	o.targetMap = nil
	o.targetFound = false
	return o
end

function CeladonQuest:isDoable()
	if self:hasMap() then
		return true
	end
	return false
end

function CeladonQuest:isDone()
	if getMapName() == "Celadon City" and dialogs.celadonDone.state then
		return true
	end
	return false
end

function CeladonQuest:PokecenterCeladon()
	self:pokecenter("Celadon City")
end

function CeladonQuest:CeladonCity()
	if self:needPokecenter() 
		or not game.isTeamFullyHealed() 
		or not self.registeredPokecenter == "Pokecenter Celadon"
	then
		return moveToMap("Pokecenter Celadon")
	elseif dialogs.targetKnown.state and self.target ~= nil then
		log("Going to hunt: "..self.target)
		logToFile("target.txt", os.date('date = {hour = "%H", minute = "%M", seconds = "%S"}\r\ntarget = "'..self.target..'"'), true)
		if self.target == "Doduo" then
			return moveToMap("Link")
		else
			return moveToMap("Route 7")
		end
	else
		if isNpcOnCell(43,44) then -- Rocket Grunt
			return talkToNpcOnCell(43,44)
		end
		return moveToMap("Celadon House")
	end
end

function CeladonQuest:CeladonHouse()
	if dialogs.targetKnown.state then
		self.target = dialogs.targetKnown.match
	end
	if dialogs.targetSubmitted.state then
		pushDialogAnswer(4)
		pushDialogAnswer(3)
		pushDialogAnswer(2)
		pushDialogAnswer(1)
		return talkToNpcOnCell(11,5) -- reward master
	elseif not dialogs.targetKnown.state or self.targetFound then
		pushDialogAnswer("Yes.")
		pushDialogAnswer(getTeamSize())
		return talkToNpcOnCell(8,5) -- task master
	else
		return moveToMap("Celadon City")
	end
end

function CeladonQuest:Route16()
	self:standardHunt("Celadon City")
end

function CeladonQuest:Route7()
	self:standardMove("Celadon City", "Route 7 Stop House")
end

function CeladonQuest:Route7StopHouse()
	self:standardMove("Route 7", "Link")
end

function CeladonQuest:SaffronCity()
	local up    = {"Oddish","Pidgey","Spearow"}
	local right = {"Geodude","Magnemite","NidoranF","Nidoran M"}
	local down  = {"Bellsprout","Caterpie","Diglett","Drowzee","Horsea","Krabby","Sandshrew","Weedle","Zubat"}
	
	if sys.tableHasValue(up, self.target) then
		return self:standardMove("Route 7 Stop House", "Route 5 Stop House")
	elseif sys.tableHasValue(right, self.target) then
		return self:standardMove("Route 7 Stop House", "Route 8 Stop House")
	elseif sys.tableHasValue(down, self.target) then
		return self:standardMove("Route 7 Stop House", "Route 6 Stop House")
	else
		return moveToMap("Route 7 Stop House")
		--sys.error("CeladonQuest:SaffronCity", "Target map unknown ["..self.target.."]")
	end
end

--
-- up from saffron
--

function CeladonQuest:Route5StopHouse()
	self:standardMove("Saffron City", "Route 5")
end

function CeladonQuest:Route5()
	self:standardMove("Route 5 Stop House", "Cerulean City")
end

function CeladonQuest:CeruleanCity()
	up = {"Bellsprout","Oddish"}
	left = {"Pidgey","Spearow"}

	if self:needPokecenter() then
		return moveToMap("Pokecenter Cerulean")
	elseif sys.tableHasValue(up, self.target) then
		return self:standardMove("Route 5", "Route 24")
	elseif sys.tableHasValue(left, self.target) then
		return self:standardMove("Route 5", "Route 4")
	else
		return moveToMap("Route 5")
		--sys.error("CeladonQuest:CeruleanCity", "Target map unknown ["..self.target.."]")
	end
end

function CeladonQuest:PokecenterCerulean()
	self:pokecenter("Cerulean City")
end

--
-- right from saffron
--

function CeladonQuest:Route8StopHouse()
	self:standardMove("Link", "Route 8")
end

function CeladonQuest:Route8()
	self:standardMove("Route 8 Stop House", "Lavender Town")
end

function CeladonQuest:LavenderTown()
	if self:needPokecenter() then
		return moveToMap("Pokecenter Lavender")
	end
	return self:standardMove("Route 8", "Route 10")
end

function CeladonQuest:PokecenterLavender()
	return self:pokecenter("Lavender Town")
end

function CeladonQuest:Route10()
	if game.inRectangle(2,45,31,71) then -- lower half
		return self:standardMove("Lavender Town", {5,44})
	elseif game.inRectangle(10,0,24,11) then -- upper half
		if isNpcOnCell(13,6) then -- PokeStop
			return talkToNpcOnCell(13,6)
		end
		local _targets = {"Magnemite","NidoranF","Nidoran M"}
		if sys.tableHasValue(_targets, dialogs.targetKnown.match)
			and not self:targetPokeFound()
		then
			return standardHunt("Lavender Town") or standardHunt("Rock Tunnel 1")
		end
		return self:standardMove("Rock Tunnel 1", "Route 9")
	end
end

function CeladonQuest:RockTunnel1()
	return self:standardMove({21,32}, {7,30})
	or self:standardMove({8,15}, {7,7})
	or self:standardMove({35,16}, {43,11})
end

function CeladonQuest:RockTunnel2()
	return self:standardMove({8,26}, {10,13})
	or self:standardMove({7,5}, {36,16})
end

-- down from saffron
function CeladonQuest:Route6StopHouse()
	self:standardMove("Link", "Route 6")
end

function CeladonQuest:Route6()
	sys.todo("Collect berries")
	self:standardMove("Route 6 Stop House", "Vermilion City")
end

function CeladonQuest:VermilionCity()
	if self:needPokecenter() then
		return moveToMap("Pokecenter Vermilion")
	end
	return self:standardMove("Route 6", "Route 11")
end

function CeladonQuest:PokecenterVermilion()
	self:pokecenter("Vermilion City")
end

function CeladonQuest:Route11()
	self:standardMove("Vermilion City", "Digletts Cave Entrance 2")
end

function CeladonQuest:DiglettsCaveEntrance2()
	local _targets = {"Diglett","Dugtrio","Zubat"}
	if sys.tableHasValue(_targets, self.target)
		and not self:targetPokeFound()
		and self.target ~= nil
	then
		return self:standardHunt("Route 11", "cave")
	end
	self:standardMove("Route 11", "Digletts Cave")
end

return CeladonQuest