-- Copyright © 2017 DubsCheckum <dubs@noemail>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"
--dofile "Quests/KantoTargets.lua"

local blacklist = require "blacklist"

local Quest = {}

function Quest:new(name, description, level, dialogs)
	local o = {}
	setmetatable(o, self)
	self.__index     = self
	o.name        = name
	o.description = description
	o.level       = level or 1
	o.dialogs     = dialogs
	o.training    = true
	return o
end

function Quest:isDoable()
	sys.error("Quest:isDoable", "function is not overloaded in quest: " .. self.name)
	return nil
end

function Quest:isDone()
	return self:isDoable() == false
end

function Quest:mapToFunction()
	local mapName = getMapName()
	local mapFunction = sys.removeCharacter(mapName, ' ')
	mapFunction = sys.removeCharacter(mapFunction, '.')
	return mapFunction
end

function Quest:standardMove(back, forward)
	if self.dialogs.targetKnown.state 
		and not self.targetFound 
		and not self:needPokecenter()
	then
		if type(forward) == "table" then
			return moveToCell(forward[1], forward[2])
		end
		return moveToMap(forward)
	else
		if type(back) == "table" then
			return moveToCell(back[1], back[2])
		end
		return moveToMap(back)
	end
end

function Quest:standardHunt(back, huntType)
	if not self:targetPokeFound() then
		huntType = huntType:lower()
		if huntType == "grass" then
			return moveToGrass()
		elseif huntType == "water" then
			return moveToWater()
		elseif huntType == "cave" then
			return moveToNormalGround()
		else
			sys.error("Quest:StandardHunt", "HuntType of ["..huntType.."] is not valid")
		end
	end
	return moveToMap(back)
end

function Quest:targetPokeFound()
	if self.target ~= nil then
		for i=1, getTeamSize() do
			if getPokemonName(i) == self.target then
				if getPokemonIndividualValue(i,"ATK")
					+ getPokemonIndividualValue(i,"DEF")
					+ getPokemonIndividualValue(i,"SPATK")
					+ getPokemonIndividualValue(i,"SPDEF")
					+ getPokemonIndividualValue(i,"SPD")
					+ getPokemonIndividualValue(i,"HP")
					>= minIVs
				then
					self.targetFound = true
					return i
				end
			end
		end
	end
	return false
end

-- function Quest:moveToTargetMap()
	-- local maps = targets[target][maps]
	-- for i=#maps, 1, -1 do
		-- local inRect = maps[i][inRect]
		-- if inRect ~= nil then
			-- if game.inRectangle() and getMapName() == inRect[5] then
				-- if maps[i - 1][inRect] then
					-- moveToMap(maps[i - 1])
				-- end
			-- end
		-- elseif getMapName() == maps[i] then
			-- moveToMap(maps[i - 1])
		-- end
	-- end
-- end

function Quest:hasMap()
	local mapFunction = self:mapToFunction()
	if self[mapFunction] then
		return true
	end
	return false
end

function Quest:pokecenter(exitMapName) -- idealy make it work without exitMapName
	self.registeredPokecenter = getMapName()
	sys.todo("add a moveDown() or moveToNearestLink() or getLinks() to PROShine")
	if not game.isTeamFullyHealed() then
		return usePokecenter()
	end
	return moveToMap(exitMapName)
end

-- at a point in the game we'll always need to buy the same things
-- use this function then
function Quest:pokemart(exitMapName)
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,5)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
			return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap(exitMapName)
	end
end

function Quest:isTrainingOver()
	if game.minTeamLevel() >= self.level then
		if self.training then -- end the training
			self:stopTraining()
		end
		return true
	end
	return false
end

-- function Quest:managePC()
	-- sys.timer(1)
	-- if not quest_lib.isSortedAtStart then
		-- for i=1, getTeamSize() do
			-- --assign designatedStrongPoke if it doesnt exist
			-- if getPokemonLevel(i) == 100 and quest_lib.designatedStrongPokeId == nil then
				-- quest_lib.designatedStrongPokeId = getPokemonUniqueId(i)
			-- end
			
			-- --deposit all except designatedStrongPoke
			-- if getPokemonUniqueId(i) ~= quest_lib.designatedStrongPokeId then
				-- sys.timerSwitch = false
				-- return depositPokemonToPC(i)
			-- end
		-- end
		-- quest_lib.isSortedAtStart = true
	-- else
		-- sys.timer(1)
		-- for i=1, getTeamSize() do
			-- if getPokemonName(i) == quest_lib.targetPoke and not isPokemonShiny(i) and getPokemonForm(i) == 0 and getPokemonLevel(i) < 50 then -- level requirement is a safety net
				-- if isDepositPokemon then
					-- sys.log1time("### Depositing "..quest_lib.targetPoke)
					-- sys.timerSwitch = false
					-- return depositPokemonToPC(i)
				-- elseif isReleasePokemon then
					-- sys.log1time("### Releasing "..quest_lib.targetPoke)
					-- sys.timerSwitch = false
					-- return releasePokemonFromTeam(i)
				-- end
			-- end
		-- end
	-- end
		
	-- log("### Depositing complete, returning to hunting")
	-- game.isRunFromAll = false
-- end

function Quest:leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = game.getFirstUsablePokemon()
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)
	
	if PokemonWithLeftovers > 0 then
		if PokemonNeedLeftovers == PokemonWithLeftovers  then
			return false -- now leftovers is on rightpokemon
		else
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
	else
		if hasItem(ItemName) then
			giveItemToPokemon(ItemName,PokemonNeedLeftovers)
			return true
		else
			return false-- don't have leftovers in bag and is not on pokemons
		end
	end
end

function Quest:useBike()
	if hasItem("Bicycle") then
		if isOutside() and not isMounted() and not isSurfing() and getMapName() ~= "Cianwood City" and getMapName() ~= "Route 41" then
			useItem("Bicycle")
			log("Using: Bicycle")
			return true --Mounting the Bike
		else
			return false
		end
	else
		return false
	end
end

function Quest:startTraining()
	self.training = true
end

function Quest:stopTraining()
	self.training = false
	self.healPokemonOnceTrainingIsOver = true
end

function Quest:needPokemart()
	-- TODO: ItemManager
	if getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return true
	end
	return false
end

function Quest:needPokecenter()
	if getPokemonHealthPercent(1) < 25
		--or (getTeamSize() == 6 and not self:targetPokeFound())
	then
		return true
	end
	return false
end

function Quest:message()
	return self.name .. ': ' .. self.description
end

function Quest:path()
	if self.inBattle then
		self.inBattle = false
		self:battleEnd()
	end
	if not isTeamSortedByLevelDescending() then
		return sortTeamByLevelDescending()
	end
	if self:leftovers() then
		return true
	end
	if self:useBike() then
		return true
	end
	local mapFunction = self:mapToFunction()
	assert(self[mapFunction] ~= nil, self.name .. " quest has no method for map: " .. getMapName())
	self[mapFunction](self)
end

function Quest:isPokemonBlacklisted(pokemonName)
	return sys.tableHasValue(blacklist, pokemonName)
end

function Quest:battleBegin()
	self.canRun = true
end

function Quest:battleEnd()
	self.canRun = true
end

function Quest:wildBattle()
	if isOpponentShiny() 
		or not isAlreadyCaught() 
		or getOpponentForm() ~= 0
	then
		if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") then
			return true
		end
	end
	
	-- if we do not try to catch it
	if getTeamSize() == 1 or getUsablePokemonCount() > 1 then
		local opponentLevel = getOpponentLevel()
		local myPokemonLvl  = getPokemonLevel(getActivePokemonNumber())
		if opponentLevel >= myPokemonLvl then
			local requestedId, requestedLevel = game.getMaxLevelUsablePokemon()
			if requestedId ~= nil and requestedLevel > myPokemonLvl then
				return sendPokemon(requestedId)
			end
		end
		return attack() or sendUsablePokemon() or run() or sendAnyPokemon()
	else
		if not self.canRun then
			return attack() or game.useAnyMove()
		end
		return run() or attack() or sendUsablePokemon() or sendAnyPokemon()
	end
end

function Quest:trainerBattle()
	-- bug: if last pokemons have only damaging but type ineffective
	-- attacks, then we cannot use the non damaging ones to continue.
	if not self.canRun then -- trying to switch while a pokemon is squeezed end up in an infinity loop
		return attack() or game.useAnyMove()
	end
	return attack() or sendUsablePokemon() or sendAnyPokemon() -- or game.useAnyMove()
end

function Quest:battle()
	if not self.inBattle then
		self.inBattle = true
		self:battleBegin()
	end
	if isWildBattle() then
		return self:wildBattle()
	else
		return self:trainerBattle()
	end
end

function Quest:dialog(message)
	if self.dialogs == nil then
		return false
	end
	for _, dialog in pairs(self.dialogs) do
		if dialog:messageMatch(message) then
			dialog.state = true
			return true
		end
	end
	return false
end

function Quest:battleMessage(message)
	if sys.stringContains(message, "You can not run away!") then
		sys.canRun = false
	elseif sys.stringContains(message, "black out") and self.level < 100 and self:isTrainingOver() then
		self.level = self.level + 1
		self:startTraining()
		log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		return true
	end
	return false
end

function Quest:systemMessage(message)
	return false
end

local hmMoves = {
	"cut",
	"surf",
	"flash",
	"dig"
}

function Quest:learningMove(moveName, pokemonIndex)
	return forgetAnyMoveExcept(hmMoves)
end

return Quest
