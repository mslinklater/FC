-- Lua FCCamera object class

FCCamera = {}

function FCCamera:New()
	print("FCCamera:New()")
	ret = {}
	ret.class = "FCCamera"

	ret.h = FCCameraManager.CreateCamera()

	setmetatable( ret, self )
	self.__index = self
	self.__newindex = function() error() end
	return ret
end

function FCCamera:Destroy()
	print("FCCamera:Destroy()")
	FCCameraManager.DestroyCamera( self.h )
end

function FCCamera:SetPosition( pos )
	if type( pos ) == "table" and pos.class == "FCVector3" then
		FCCameraManager.SetCameraPosition( self.h, pos )
	else
		FCError("FCCamera:SetPosition with a non-FCVector3 parameter")
	end
end

function FCCamera:SetTarget( pos )
	if type( pos ) == "table" and pos.class == "FCVector3" then
		FCCameraManager.SetCameraTarget( self.h, pos )
	else
		FCError("FCCamera:SetTarget with a non-FCVector3 parameter")
	end
end

function FCCamera:SetOrthographicProjection( x, y )
	if type(y) ~= nil then
		FCCameraManager.SetCameraOrthographicProjection( self.h, x, y )
	else
		FCCameraManager.SetCameraOrthographicProjection( self.h, x, 0 )
	end
end

