local pitchUtil = {}
local _maxAngleAbs = 0.36
local _paramXFactor = 0.05

local _getParamsXAdjusted = function(paramX)
    return math.max(math.min(paramX * _paramXFactor, _maxAngleAbs), -_maxAngleAbs)
end

local _getXYZPitched = function(paramX, x, y, z, xMin, xMax)
    --print('LOLLO x, y, z = ', x, y, z)
    local paramXAdjusted = _getParamsXAdjusted(paramX)
    -- local result = {x * math.cos(paramXAdjusted), y, math.sin(paramXAdjusted) * ((x - xMin) / (xMax - xMin) + xMin / (xMax - xMin)) + z}
    -- local result = {x * math.cos(paramXAdjusted), y, math.sin(paramXAdjusted) * x / (xMax - xMin) + z}
    local result = {
        x * math.cos(paramXAdjusted),
        y,
        math.sin(paramXAdjusted) * x + z
    }
    return result
end

pitchUtil.getXYZPitched = function(paramX, tbl)
    --print('LOLLO pitch params = ', paramX)
    --require('luadump')(true)(tbl)
    local result = _getXYZPitched(paramX, tbl[1], tbl[2], tbl[3], -1, 1)
    --print('LOLLO pitch result = ')
    --require('luadump')(true)(result)
    return result
end

pitchUtil.getIdTransfPitched = function(paramX)
    local paramXAdjusted = _getParamsXAdjusted(paramX)
    local result = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    result[1] = math.cos(paramXAdjusted)
    result[3] = math.sin(paramXAdjusted)
    result[9] = math.sin(paramXAdjusted)
    result[11] = math.cos(paramXAdjusted)

    --print('LOLLO transf pitch result = ')
    --require('luadump')(true)(result)
    return result
end

local _maxPitch = 10
pitchUtil.getPitchValues = function()
    local result = {}
    for i = -_maxPitch, _maxPitch do
        table.insert(result, #result + 1, tostring(i))
    end
    return result
end
pitchUtil.getMiddlePitch = function()
    return _maxPitch
end
pitchUtil.getDefaultPitch = function()
    return pitchUtil.getMiddlePitch()
end

return pitchUtil