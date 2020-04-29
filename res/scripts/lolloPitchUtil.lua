local pitchUtil = {}
local _maxAngleAbs = 0.36
local _pitchAdjustmentFactor = 0.004

local _getPitchAdjusted = function(pitch)
    return math.max(math.min(pitch * _pitchAdjustmentFactor, _maxAngleAbs), -_maxAngleAbs)
end

local _getXYZPitched = function(pitch, x, y, z, xMin, xMax)
    local pitchAdjusted = _getPitchAdjusted(pitch)
    -- local result = {x * math.cos(pitchAdjusted), y, math.sin(pitchAdjusted) * ((x - xMin) / (xMax - xMin) + xMin / (xMax - xMin)) + z}
    -- local result = {x * math.cos(pitchAdjusted), y, math.sin(pitchAdjusted) * x / (xMax - xMin) + z}
    local result = {
        x * math.cos(pitchAdjusted),
        y,
        math.sin(pitchAdjusted) * x + z
    }
    return result
end

pitchUtil.getXYZPitched = function(pitch, tbl)
    local result = _getXYZPitched(pitch, tbl[1], tbl[2], tbl[3], -1, 1)
    return result
end

pitchUtil.getIdTransfPitched = function(pitch)
    local pitchAdjusted = _getPitchAdjusted(pitch)
    local result = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    result[1] = math.cos(pitchAdjusted)
    result[3] = math.sin(pitchAdjusted)
    result[9] = math.sin(pitchAdjusted)
    result[11] = math.cos(pitchAdjusted)
    return result
end

local _maxPitch4Slider = 100 -- I need a high value coz the arrow key bumps it by 10 at every click
pitchUtil.getPitchParamValues = function()
    local result = {}
    for i = -_maxPitch4Slider, _maxPitch4Slider do
        table.insert(result, #result + 1, tostring(i))
    end
    return result
end
pitchUtil.getMiddlePitchParamValue = function()
    return _maxPitch4Slider
end
pitchUtil.getDefaultPitchParamValue = function()
    return pitchUtil.getMiddlePitchParamValue()
end

return pitchUtil