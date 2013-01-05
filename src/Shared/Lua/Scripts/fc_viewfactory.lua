-- ViewFactory

FCViewFactory = {}

function FCViewFactory.AddViews( name, def, parentView )
	local viewName = nil

	if def.name ~= nil then
		viewName = def.name
	end

-- manage hierarchy

	if parentView ~= nil then
		def.instance = FCView:New( viewName, def.viewType, parentView )
		def.parentView = parentView
		parentView.subviews[ #parentView.subviews + 1 ] = def
	else
		def.instance = FCView:New( viewName, def.viewType, nil )
	end

	def.name = def.instance.name

	setmetatable( def, { __index = def.instance } )

	if def.frame == nil then def.frame = FCRectZero() end
	def.onCreateFrame = FCRectCopy( def.frame )
	def:SetFrame( def.frame )

-- pick up on properties

	if def.image ~= nil then def:SetImage( def.image ) end
	if def.contentMode ~= nil then def:SetContentMode( def.contentMode ) end
	

	if def.font ~= nil then def:SetFontWithSize( def.font.face, def.font.size ) end
	if def.textAlignment ~= nil then def:SetTextAlignment( def.textAlignment ) end
	if def.text ~= nil then def:SetText( def.text ) end
	if def.backgroundColor ~= nil then def:SetBackgroundColor( def.backgroundColor ) end
	if def.textColor ~= nil then def:SetTextColor( def.textColor ) end

-- descend hierarchy

	for subName, subDef in pairs( def ) do
		if type(subDef) == "table" and subDef.viewType ~= nil then
			FCViewFactory.AddViews( subName, subDef, def.instance )
		end
	end
end

function FCViewFactory.DestroyViews( def )
	for subName, subDef in pairs( def ) do
		if type(subDef) == "table" and subDef.viewType ~= nil then
			FCViewFactory.DestroyViews( subDef )
		end
	end

	-- remove from parents subViews

	if def.parentView then
		for n, v in pairs(def.parentView.subviews) do
			if v == def then
				v = def.parentView.subviews[ #def.parentView.subviews ]
				def.parentView.subviews[ #def.parentView.subviews ] = nil
			end
		end
	end
	
	-- restore some original values
	
	if def.onCreateFrame ~= nil then
		def.frame = FCRectCopy( def.onCreateFrame )
		def.onCreateFrame = nil
	end

	def.parentView = nil

	FCView.Destroy( def.instance )

	def.instance = nil
end

function FCViewFactory.Create(def)
	for n, d in pairs(def) do
		FCViewFactory.AddViews( n, d, nil )
	end
end

function FCViewFactory.Destroy( def )
	for n, d in pairs(def) do
		FCViewFactory.DestroyViews( d )
	end
end