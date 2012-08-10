-- Lua FCView object class

FCView = {}

function FCView:New( name, classType )
	ret = {}
	ret.m_name = name
	ret.m_classType = classType

	FCViewManager.CreateView( name, classType )

	-- setup the metatable entries

	setmetatable( ret, self )
	self.__index = self
	self.__newindex = function() error() end

	return ret
end

function FCView:Destroy()
	FCViewManager.DestroyView( self.m_name )
end

function FCView:SetBackgroundColor( color )
	FCViewManager.SetBackgroundColor( self.m_name, color )
end

function FCView:SetFrame( frame, duration )
	FCViewManager.SetFrame( self.m_name, frame, duration )
end

function FCView:SetAlpha( alpha, duration )
	FCViewManager.SetAlpha( self.m_name, alpha, duration )
end

function FCView:SetText( text )
	FCViewManager.SetText( self.m_name, text )
end

function FCView:SetImage( image )
	FCViewManager.SetImage( self.m_name, image )
end

function FCView:SetOnSelectLuaFunction( func )
	FCViewManager.SetOnSelectLuaFunction( self.m_name, func )
end

function FCView:SetViewPropertyInteger( prop, value )
	FCViewManager.SetViewPropertyInteger( self.m_name, prop, value )
end

function FCView:SetViewPropertyString( prop, value )
	FCViewManager.SetViewPropertyString( self.m_name, prop, value )
end

