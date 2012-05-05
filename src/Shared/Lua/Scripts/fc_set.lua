-- Set container

FCSet = {}

function FCSet.new( t )
	local set = {}
	setmetatable( set, FCSet.mt )
	for _, l in ipairs( t ) do
		set[ l ] = true
	end
	return set
end

function FCSet.union( a, b )
	if DEBUG then
		assert( getmetatable( a ) == FCSet.mt )
		assert( getmetatable( b ) == FCSet.mt )
	end

	local res = FCSet.new{}
	for k in pairs( a ) do
		res[ k ] = true
	end
	for k in pairs( b ) do
		res[ k ] = true
	end
	return res
end

function FCSet.intersection( a, b )
	if DEBUG then
		assert( getmetatable( a ) == FCSet.mt )
		assert( getmetatable( b ) == FCSet.mt )
	end

	local res = FCSet.new{}
	for k in pairs( a ) do
		res[ k ] = b[ k ]
	end
	return res
end

function FCSet.lessthanorequal( a, b )
	if DEBUG then
		assert( getmetatable( a ) == FCSet.mt )
		assert( getmetatable( b ) == FCSet.mt )
	end
	
	for k in pairs( a ) do
		if not b[k] then 
			return false
		end
	end
	return true
end

function FCSet.lessthan( a, b )
	if DEBUG then
		assert( getmetatable( a ) == FCSet.mt )
		assert( getmetatable( b ) == FCSet.mt )
	end
	
	return (a <= b) and not (b <= a )
end

function FCSet.equal( a, b )
	return (a <= b) and (b <= a)
end

function FCSet.tostring( set )
	if DEBUG then
		assert( getmetatable( set ) == FCSet.mt )
	end
	
	local s = "{"
	local sep = ""
	for e in pairs(set) do
		s = s .. sep .. e
		sep = ", "
	end
	return s .. "}"
end

function FCSet.print( s )
	print( FCSet.tostring( s ) )
end

-- Metatable

FCSet.mt = {}

FCSet.mt.__add = FCSet.union
FCSet.mt.__mul = FCSet.intersection
FCSet.mt.__le = FCSet.lessthanorequal
FCSet.mt.__lt = FCSet.lessthan
FCSet.mt.__eq = FCSet.equal
FCSet.mt.__tostring = FCSet.tostring