-- Random number generator

FCRandom = {}
FCRandom.__index = FCRandom

function FCRandom.New( seed )
	local ret = {}
	
	if seed == nil then
		seed = 1
	end
	
	ret.x = seed
	setmetatable( ret, FCRandom )
	return ret
end

function FCRandom:Get( )
	self.x = math.fmod(self.x * 16807, 2147483647)
	return self.x
end
