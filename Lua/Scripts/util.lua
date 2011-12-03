-- Utility functions

function PrintTable( tbl, recurse )
	if tbl == nil then
		FCLog("table is nil")
		return
	end
	for k,v in pairs(tbl) do
		if type(v) == "table" and recurse ~= nil then
			print("TABLE: " .. k)
			PrintTable(v, recurse)
		else
			print(k,v)
		end
	end
end

