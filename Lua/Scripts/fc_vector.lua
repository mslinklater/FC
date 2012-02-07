-- Simply vector class

FCVector3 = {}

function FCVector3.new( v )
	local vec = {}
	setmetatable( vec, FCVector3.mt )
	if v ~= nil then
		if getmetatable( v ) == FCVector3.mt then
			vec.x = v.x
			vec.y = v.y
			vec.z = v.z
		else
			vec.x = v[1]
			vec.y = v[2]
			vec.z = v[3]
		end
	else
		vec.x = 0
		vec.y = 0
		vec.z = 0
	end
	return vec
end

function FCVector3.add( a, b )
	return FCVector3.new( {a.x + b.x, a.y + b.y, a.z + b.z} )
end

function FCVector3.subtract( a, b )
	return FCVector3.new( {a.x - b.x, a.y - b.y, a.z - b.z} )
end

function FCVector3.cross( a, b )
	x = (a.y * b.z) - (a.z * b.y)
	y = (a.z * b.x) - (a.x * b.z)
	z = (a.x * b.y) - (a.y * b.x)
	return FCVector3.new( {x, y, z} )
end

function FCVector3.dot( a, b )
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

function FCVector3.tostring( v )
	return( "{ x = " .. v.x .. ", y = " .. v.y .. ", z = " .. v.z .. " }" )
end

FCVector3.mt = {}
FCVector3.mt.__tostring = FCVector3.tostring
FCVector3.mt.__add = FCVector3.add
FCVector3.mt.__sub = FCVector3.subtract
FCVector3.mt.__mul = FCVector3.cross
FCVector3.mt.__div = FCVector3.dot
