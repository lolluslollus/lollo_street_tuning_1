local tu = require "texutil"

function data()
-- return {
-- 	texture = tu.makeMaterialIndexTexture("res/textures/terrain/material/mat255.tga", "REPEAT", "REPEAT"),
-- 	-- texture = tu.makeMaterialIndexTexture("res/textures/terrain/material/town_dark.tga", "REPEAT", "REPEAT"),
-- 	texSize = { 64.0, 64.0 },
-- 	materialIndexMap = {
-- 		-- [50] = "grass_brown.lua",
-- 		-- [100] = "dirt.lua",
-- 		-- [150] = "shared/gravel_03.lua",
-- 		[0] = 'dirt.lua',
-- 	},

-- 	priority = 12000
-- }
-- end
return {
	priority = 12000,

	indices = {
		data = "1",
		size = { 1, 1 },
	},
	texSize = { 1, 1 },
	materialIndexMap = {
		"shared/asphalt_like_street.lua",
	},
}
end
