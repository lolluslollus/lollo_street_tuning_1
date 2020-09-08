local results = {}

local function _getModSettings1()
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return nil end
    return game.config._lolloStreetTuning
end

local function _getModSettings2()
    if type(api) ~= 'table' or type(api.res) ~= 'table' or type(api.res.getBaseConfig) ~= 'table' then return end

    local baseConfig = api.res.getBaseConfig()
    if not(baseConfig) then return end

    return baseConfig._lolloStreetTuning
end

results.get = function(fieldName)
    local modSettings = _getModSettings1() or _getModSettings2()
    if not(modSettings) then
        print('LOLLO street tuning cannot read modSettings')
        return nil
    end

    return modSettings[fieldName]
end

results.setModParamsFromRunFn = function(thisModParams)
    -- LOLLO NOTE if default values are set, modParams in runFn will be an empty table,
    -- so thisModParams here will be nil
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return end

    if type(game.config._lolloStreetTuning) ~= 'table' then
        game.config._lolloStreetTuning = {}
    end

    if type(thisModParams) == 'table' and thisModParams.lolloStreetTuning_YellowBusLaneStripes == 0 then
        game.config._lolloStreetTuning.lolloStreetTuning_YellowBusLaneStripes = 0
    else
        game.config._lolloStreetTuning.lolloStreetTuning_YellowBusLaneStripes = 1
    end
end

return results