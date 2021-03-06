local helper = {}

local _maxPitch4Slider = 100 -- I need a high value coz the arrow key bumps it by 10 at every click
local _maxAngleAbs = 0.4 --0.36 -- More or less where the game starts complaining coz there is too much slope
local _pitchAdjustmentFactor = _maxAngleAbs / _maxPitch4Slider
local _paramX2Pitch = 10.0

-------------------------- pitch calculations --------------------------
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

helper.getXYZPitched = function(pitch, tbl)
    local result = _getXYZPitched(pitch, tbl[1], tbl[2], tbl[3], -1, 1)
    return result
end

helper.getIdTransfPitched = function(pitch)
    local pitchAdjusted = _getPitchAdjusted(pitch)
    local result = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    result[1] = math.cos(pitchAdjusted)
    result[3] = math.sin(pitchAdjusted)
    result[9] = math.sin(pitchAdjusted)
    result[11] = math.cos(pitchAdjusted)
    return result
end

------------------------- construction parameters ----------------------
local function _getMiddlePitchParamValue()
    return _maxPitch4Slider
end
helper.adjustParamsPitch = function(params)
    params.paramX = params.paramX or 0
    params.pitch = params.pitch or _getMiddlePitchParamValue()

    -- params.upgrade = true tells me that I am upgrading an existing construction
    if params.upgrade then
        params.pitch = params.pitch - _getMiddlePitchParamValue()
    else
        -- print('LOLLO adjusting params.pitch: params.paramX = ', params.paramX, 'params.pitch = ', params.pitch)
        params.pitch = params.pitch - _getMiddlePitchParamValue() + params.paramX * _paramX2Pitch
    end

    params.pitch = math.max(-_maxPitch4Slider, params.pitch)
    params.pitch = math.min(_maxPitch4Slider, params.pitch)

    return params.pitch
end
helper.getPitchParamValues = function()
    local result = {}
    for i = -_maxPitch4Slider, _maxPitch4Slider do
        table.insert(result, #result + 1, tostring(i))
    end
    return result
end
helper.getDefaultPitchParamValue = function()
    return _getMiddlePitchParamValue()
end

return helper
