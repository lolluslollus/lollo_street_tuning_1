local helper = {}

local _maxExtraRadius4Slider = 100 -- I need a high value coz the arrow key bumps it by 10 at every click
local _extraRadiusAdjustmentFactor = 0.1
local _paramY2ExtraRadius = 16 / math.pi -- every keypress is 16 / PI

------------------------- construction parameters ----------------------
helper.getParamValues = function()
    local result = {}
    for i = 0, _maxExtraRadius4Slider do
        table.insert(result, #result + 1, tostring(i))
    end
    return result
end

helper.getDefaultParamValue = function()
    return 0
end

-------------------------- pitch calculations --------------------------
helper.getExtraRadius = function(params, paramsExtraRadius)
    -- note that writing into params has no effect coz it is passed by value
    local _paramsParamY = math.abs(params.paramY or 0)
    -- print('_paramsParamY =', _paramsParamY)
    local _paramsExtraRadius = paramsExtraRadius or 0

    -- params.upgrade = true tells me that I am upgrading an existing construction
    local paramsIndexBase0 = _paramsExtraRadius + _paramsParamY * _paramY2ExtraRadius
    -- print('paramsIndexBase0 =', paramsIndexBase0 or 'NIL')

    return paramsIndexBase0 * _extraRadiusAdjustmentFactor
end

return helper
