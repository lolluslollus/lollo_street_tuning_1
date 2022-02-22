local transfUtilsUG = require('transf')


local helper = {}

local _maxPitch4Slider = 100 -- I need a high value coz the arrow key bumps it by 10 at every click
local _maxAngleAbs = 0.4 -- not too tilted, it looks stupid --0.36 -- More or less where the game starts complaining coz there is too much slope
local _pitchAdjustmentFactor = _maxAngleAbs / _maxPitch4Slider
local _paramX2Pitch = 10.0

------------------------- construction parameters ----------------------
helper.getPitchParamValues = function()
    local result = {}
    for i = -_maxPitch4Slider, _maxPitch4Slider do
        table.insert(result, #result + 1, tostring(i))
    end
    return result
end

helper.getDefaultPitchParamValue = function()
    return _maxPitch4Slider
end

-------------------------- pitch calculations --------------------------
helper.getPitchAngle = function(params, paramsPitch)
    -- note that writing into params has no effect coz it is passed by value
    local paramsParamX = params.paramX or 0
    local paramsPitch = paramsPitch or _maxPitch4Slider

    -- params.upgrade = true tells me that I am upgrading an existing construction
    local paramsPitchIndexBase0 = paramsPitch + paramsParamX * _paramX2Pitch

    paramsPitchIndexBase0 = math.max(0, paramsPitchIndexBase0)
    paramsPitchIndexBase0 = math.min(_maxPitch4Slider + _maxPitch4Slider, paramsPitchIndexBase0)

    return math.max(math.min((paramsPitchIndexBase0 - _maxPitch4Slider) * _pitchAdjustmentFactor, _maxAngleAbs), -_maxAngleAbs)
end

local _getXYZPitched = function(pitchAngle, x, y, z)
    -- local result = {x * math.cos(pitchAngle), y, math.sin(pitchAngle) * ((x - xMin) / (xMax - xMin) + xMin / (xMax - xMin)) + z}
    -- local result = {x * math.cos(pitchAngle), y, math.sin(pitchAngle) * x / (xMax - xMin) + z}
    local result = {
        x * math.cos(pitchAngle),
        y,
        math.sin(pitchAngle) * x + z
    }
    return result
end

local _getPosTanPitched = function(pitchAngle, x, y, z, tanX, tanY, tanZ)
    -- this is only ok with the data we use here. Do not use it as a general purpose routine.
    -- print('x, y, z, tanX, tanY, tanZ =', x, y, z, tanX, tanY, tanZ)
    -- local _tanLength = math.sqrt(tanX * tanX + tanY * tanY + tanZ * tanZ)
    local _sin = math.sin(pitchAngle)
    local _cos = math.cos(pitchAngle)
    local result = {
        {
            x * _cos,
            y,
            _sin * x + z
        },
        {
            _cos * tanX,
            tanY,
            -- tanX >= 0 and _sin * _tanLength or -_sin * _tanLength
            _sin * tanX
        }
    }
    -- print('transformation result =') debugPrint(result)
    return result
end

helper.getXYZPitched = function(pitchAngle, tbl)
    return _getXYZPitched(-pitchAngle, tbl[1], tbl[2], tbl[3])
end

helper.getPosTanPitched = function(pitchAngle, pos, tan)
    return _getPosTanPitched(-pitchAngle, pos[1], pos[2], pos[3], tan[1], tan[2], tan[3])
end

helper.getIdTransfPitched = function(pitchAngle)
    return transfUtilsUG.rotY(pitchAngle)
end

return helper
