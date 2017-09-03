-- Copyright © 2017 DubsCheckum <dubs@noemail>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"
local pf     = require "Pathfinder/MoveToApp"

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
		if getMapName() == "Celadon City" then
			return moveToMap("Celadon House")
		else
			return true
		end
	end
	return false
end

function CeladonQuest:isDone()
	if getMapName() == "Celadon City" and dialogs.celadonDone.state then
		return true
	else
		return false
	end
end

function CeladonQuest:CeladonHouse()
	if dialogs.targetKnown.state then
		self.target = dialogs.targetKnown.match
		log("TARGET: "..self.target)
		log("TARGET: "..dialogs.targetKnown.match)
		self.targetMap = targets[self.target][map]
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

function CeladonQuest:PokecenterCeladon()
	self:pokecenter("Celadon City")
end

function CeladonQuest:CeladonCity()
	if self:needPokecenter() 
		or not game.isTeamFullyHealed() 
		or not self.registeredPokecenter == "Pokecenter Celadon"
	then
		return moveToMap("Pokecenter Celadon")
	elseif dialogs.targetKnown.state then
		log("Going to hunt: "..self.target)
		--return pf.moveTo(self.targetMap)
	else
		return -- Quest Finish - Next
	end
end

function CeladonQuest:Route16()
	if not targetFound 
		and dialogs.targetKnown.state
		and self:canHunt()
	then
		return moveToGrass()
	end
end

return CeladonQuest