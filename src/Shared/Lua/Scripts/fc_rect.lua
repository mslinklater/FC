-- fcrect

FCRect = {}
FCRect.mt = { 
	__index = FCRect,
	__newindex = function() error() end
	 }

function FCRectMake( x, y, w, h )
	ret = {}

	ret.class = "FCRect"
	ret.x = x or 0
	ret.y = y or 0
	ret.w = w or 0
	ret.h = h or 0

	setmetatable( ret, FCRect.mt )

	return ret
end

function FCRectZero()
	return FCRectMake( 0, 0, 0, 0 )
end

function FCRectOne()	-- handy for views
	return FCRectMake( 0, 0, 1, 1 )
end
