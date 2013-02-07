-----------------------------------------------------------
-- Vector 3

FCVector3 = {}

function FCVector3.tostring( v )
	return( "{ " .. v.x .. ", " .. v.y .. ", " .. v.z .. " }" )
end

function FCVector3.add( a, b )
	return FCVector3Make( {a.x + b.x, a.y + b.y, a.z + b.z} )
end

function FCVector3.subtract( a, b )
	return FCVector3Make( {a.x - b.x, a.y - b.y, a.z - b.z} )
end

function FCVector3.cross( a, b )
	x = (a.y * b.z) - (a.z * b.y)
	y = (a.z * b.x) - (a.x * b.z)
	z = (a.x * b.y) - (a.y * b.x)
	return FCVector3Make( {x, y, z} )
end

function FCVector3.dot( a, b )
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

FCVector3.mt = { 
	__index = FCVector3,
	__newindex = function() error() end
	 }

FCVector3.mt.__tostring = FCVector3.tostring
FCVector3.mt.__add = FCVector3.add
FCVector3.mt.__sub = FCVector3.subtract
FCVector3.mt.__mul = FCVector3.cross
FCVector3.mt.__div = FCVector3.dot

function FCVector3Make( x, y, z )
	local vec = {}
	if x ~= nil then
		if type(x) == "table" then
			if getmetatable( x ) == FCVector3.mt then
				vec.x = x.x
				vec.y = x.y
				vec.z = x.z
			else
				vec.x = x[1]
				vec.y = x[2]
				vec.z = x[3]
			end
		else
			vec.x = x
			vec.y = y
			vec.z = z
		end
	else
		vec.x = 0
		vec.y = 0
		vec.z = 0
	end
	vec.class = "FCVector3"
	setmetatable( vec, FCVector3.mt )
	return vec
end

-----------------------------------------------------------
-- Vector 2

FCVector2 = {}

function FCVector2.tostring( v )
	return( "{ " .. v.x .. ", " .. v.y .. " }" )
end

function FCVector2.add( a, b )
	return FCVector2Make( {a.x + b.x, a.y + b.y} )
end

function FCVector2.subtract( a, b )
	return FCVector2Make( {a.x - b.x, a.y - b.y} )
end

function FCVector2.dot( a, b )
	return (a.x * b.x) + (a.y * b.y)
end

FCVector2.mt = { 
	__index = FCVector2,
	__newindex = function() error() end
	 }

FCVector2.mt.__tostring = FCVector2.tostring
FCVector2.mt.__add = FCVector2.add
FCVector2.mt.__sub = FCVector2.subtract
FCVector2.mt.__div = FCVector2.dot

function FCVector2Make( x, y )
	local vec = {}
	if x ~= nil then
		if type(x) == "table" then
			if getmetatable( x ) == FCVector2.mt then
				vec.x = x.x
				vec.y = x.y
			else
				vec.x = x[1]
				vec.y = x[2]
			end
		else
			vec.x = x
			vec.y = y
		end
	else
		vec.x = 0
		vec.y = 0
	end
	vec.class = "FCVector2"
	setmetatable( vec, FCVector2.mt )
	return vec
end

-----------------------------------------------------------
-- Vector 4

FCVector4 = {}

function FCVector4.tostring( v )
	return( "{ " .. v.x .. ", " .. v.y .. ", " .. v.z .. ", " .. v.w .. " }" )
end

function FCVector4.add( a, b )
	return FCVector4Make( {a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w} )
end

function FCVector4.subtract( a, b )
	return FCVector4Make( {a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w} )
end

function FCVector4.dot( a, b )
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z) + (a.w * b.w)
end

FCVector4.mt = { 
	__index = FCVector4,
	__newindex = function() error() end
	 }

FCVector4.mt.__tostring = FCVector4.tostring
FCVector4.mt.__add = FCVector4.add
FCVector4.mt.__sub = FCVector4.subtract
FCVector4.mt.__div = FCVector4.dot

function FCVector4Make( x, y, z, w )
	local vec = {}
	if x ~= nil then
		if type(x) == "table" then
			if getmetatable( x ) == FCVector4.mt then
				vec.x = x.x
				vec.y = x.y
				vec.z = x.z
				vec.w = x.w
			else
				vec.x = x[1]
				vec.y = x[2]
				vec.z = x[3]
				vec.w = x[4]
			end
		else
			vec.x = x
			vec.y = y
			vec.z = z
			vec.w = w
		end
	else
		vec.x = 0
		vec.y = 0
		vec.z = 0
		vec.w = 0
	end
	vec.class = "FCVector4"
	setmetatable( vec, FCVector4.mt )
	return vec
end

