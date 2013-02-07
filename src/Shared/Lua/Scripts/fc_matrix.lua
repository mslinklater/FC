-- Matrix44 type

FCMatrix44 = {}


function FCMatrix44.tostring( m )
	return "printing"
end

FCMatrix44.mt = {
	__index = FCMatrix44,
	__newindex = function() error() end
}
FCMatrix44.mt.__tostring = FCMatrix44.tostring

function FCMatrix44Make( m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 )
	local mat = {}
	if m00 ~= nil then
	else
		-- empty init
		mat[0] = {}
		mat[0][0] = 0
		mat[0][1] = 0
		mat[0][2] = 0
		mat[0][3] = 0
		mat[1] = {}
		mat[1][0] = 0
		mat[1][1] = 0
		mat[1][2] = 0
		mat[1][3] = 0
		mat[2] = {}
		mat[2][0] = 0
		mat[2][1] = 0
		mat[2][2] = 0
		mat[2][3] = 0
		mat[3] = {}
		mat[3][0] = 0
		mat[3][1] = 0
		mat[3][2] = 0
		mat[3][3] = 0
	end
	mat.class = "FCMatrix44"
	setmetatable( mat, FCMatrix44.mt )

	return mat
end