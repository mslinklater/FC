-- Stats tracking

FCStats = {}

function FCStats.Inc( name )

	local gcid = FCDevice.GetGameCenterID()	
	if gcid == nil then
		gcid = "local"
	end

	val = FCPersistentData.GetNumber( "stats." .. gcid .. "." .. name )
	if val then
		val = val + 1
	else
		val = 1
	end
	FCPersistentData.SetNumber( "stats." .. gcid .. "." .. name, val )
end

function FCStats.Get( name )
	local gcid = FCDevice.GetGameCenterID()	
	if gcid == nil then
		gcid = "local"
	end

	return FCPersistentData.GetNumber( "stats." .. gcid .. "." .. name )
end
