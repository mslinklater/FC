
FCColor = {}
FCColor.mt = {
	__index = FCColor,
	__newindex = function() error() end
}

function FCColorMake( r, g, b, a )
	ret = {}

	ret.class = "FCColor"
	ret.r = r or 0
	ret.g = g or 0
	ret.b = b or 0
	ret.a = a or 0

	setmetatable( ret, FCColor.mt )

	return ret
end

-- Standard colors

kClearColor = FCColorMake( 0, 0, 0, 0 )
kBlackColor = FCColorMake( 0, 0, 0, 1 )
kWhiteColor = FCColorMake( 1, 1, 1, 1 )
kRedColor = FCColorMake( 1, 0, 0, 1 )
kGreenColor = FCColorMake( 0, 1, 0, 1 )
kBlueColor = FCColorMake( 0, 0, 1, 1 )
kCyanColor = FCColorMake( 0, 1, 1, 1 )
kMagentaColor = FCColorMake( 1, 0, 1, 1 )
kYellowColor = FCColorMake( 1, 1, 0, 1 )
