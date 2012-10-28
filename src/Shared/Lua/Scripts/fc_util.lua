-- Utility functions

function FCPrintTable( tbl, recurse )
	if tbl == nil then
		print("table is nil")
		return
	end
	for k,v in pairs(tbl) do
		if type(v) == "table" and recurse ~= nil then
			print("TABLE: " .. k)
			FCPrintTable(v, recurse)
		else
			print( k, v )
		end
	end
end

