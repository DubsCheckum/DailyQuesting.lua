-- Copyright © 2017 DubsCheckum <dubs@noemail>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"
--local pf     = require "Pathfinder/MoveToApp"

local name		  = "Kanto Daycare Quest"
local description = "Going to Celadon to complete the Task Master's task"

local dialogs = {
	targetKnown = Dialog:new({
		"You shall hunt for ([%w-']+), then",
		"Did you obtain ([%w-']+) already?"
	}),
}

local DaycareKantoQuest = Quest:new()

function DaycareKantoQuest:new()
	local o =  Quest.new(DaycareKantoQuest, name, description, level, dialogs)
	o.target = nil
	o.targetMap = nil
	o.targetFound = false
	return o
end

function DaycareKantoQuest:isDoable()
	if self:hasMap() then
		return true
	end
	return pf.moveTo("Celadon City")
end

function DaycareKantoQuest:isDone()
	if getMapName() == "Celadon City" and dialogs.celadonDone.state then
		return true
	end
	return false
end

return DaycareKantoQuest