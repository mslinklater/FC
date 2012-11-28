-- Base for all FC Lua classes

function InheritsFrom( baseClass )
	local new_class = {}
	local class_mt = { __index = new_class }
	
	function new_class:New()
		local newinst = {}
		setmetatable( newinst, class_mt )
		return newinst
	end

	if baseClass then
		setmetatable( new_class, { __index = baseClass } )
	end

	return new_class
end

FCBase = {}
