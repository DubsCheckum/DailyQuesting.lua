-- Copyright © 2017 DubsCheckum <m3rcury@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys = require "Libs/syslib"

local Dialog = {state = false, text = {}, match = nil}

function Dialog:new(text)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	assert(text ~= nil, "The Dialog constructor expects an array of strings")
	o.state   = false
	o.text    = text
	o.match	  = nil
	return o
end

function Dialog:messageMatch(message)
	for key, text in pairs(self.text) do
		if sys.stringContains(message, text) then
			return true
		else
			local matched = string.match(message, text)
			if matched ~= nil then
				log("Found target: "..matched)
				self.match = matched
				return true
			end
		end
	end
	return false
end

-- function Dialog:regexMatch(message)
	-- log("here0")
	-- for key, text in pairs(self.text) do
		-- log("here1")
		-- local matched = string.match(message, text)
		-- if matched ~= nil then
			-- log("here2")
			-- self.match = matched
			-- return true
		-- end
	-- end
	-- return false
-- end

return Dialog
